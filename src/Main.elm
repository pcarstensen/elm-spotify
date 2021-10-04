module Main exposing (main)

import Browser exposing (UrlRequest)
import Browser.Navigation as Nav
import Helper.Url
import Html exposing (Html)
import Pages.Album as Album
import Pages.Artist as Artist
import Pages.Home as Home
import Pages.Playlist as Playlist
import Pages.Search as Search
import Pages.Track as Track
import Ports
import Route exposing (Route)
import Url exposing (Url)
import View


type Msg
    = HomePageMsg Home.Msg
    | PlaylistPageMsg Playlist.Msg
    | SearchPageMsg Search.Msg
    | AlbumPageMsg Album.Msg
    | TrackPageMsg Track.Msg
    | ArtistPageMsg Artist.Msg
    | LinkClicked UrlRequest
    | UrlChanged Url


type alias Model =
    { route : Route
    , page : Page
    , navKey : Nav.Key
    , token : Maybe String
    }



{-
   Client ID, die unter dem Spotify-Dashboard zufinden ist.
   https://developer.spotify.com/dashboard
-}


clientId : String
clientId =
    "ea04bf0ed5724454a305d1e011112e6d"


type Page
    = NotFoundPage
    | Home Home.Model
    | Search Search.Model
    | Playlist Playlist.Model
    | Artist Artist.Model
    | Album Album.Model
    | Track Track.Model


main : Program (Maybe String) Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


init : Maybe String -> Url -> Nav.Key -> ( Model, Cmd Msg )
init token url navKey =
    let
        model =
            { route = Route.parseUrl url
            , page = NotFoundPage
            , navKey = navKey
            , token = token
            }

        {-
           Beim Start der Anwendung wird initial im Speicher des Browsers nach einem Cookie, der den Auth 2.0 Token enthält, gesucht.
           Dieser wird dann als flag (Typ Maybe String) in die Main.init Funktion übergeben. Besitzt 'token' den Wert Nothing, wird ein neuer
           Token generiert und aus der URL entnommen.

           Siehe index.html für die Cookie-Funktionen.
        -}
        urlToken =
            case token of
                Just v ->
                    Just v

                Nothing ->
                    Helper.Url.getToken url

        cmds =
            case urlToken of
                Just v ->
                    -- speichert den Token im Browserspeicher.
                    Ports.setStorage v

                Nothing ->
                    Nav.load ("https://accounts.spotify.com/authorize?response_type=token&client_id=" ++ clientId ++ "&redirect_uri=http://localhost:8000/home")
    in
    initCurrentPage ( { model | token = urlToken }, cmds )


initCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
initCurrentPage ( model, existingCmds ) =
    let
        ( currentPage, mappedPageCmds ) =
            case model.route of
                Route.NotFound ->
                    ( NotFoundPage, Cmd.none )

                Route.Home ->
                    let
                        ( pageModel, pageCmds ) =
                            Home.init model.token
                    in
                    ( Home pageModel, Cmd.map HomePageMsg pageCmds )

                Route.Playlist id ->
                    let
                        ( pageModel, pageCmds ) =
                            Playlist.init id model.token
                    in
                    ( Playlist pageModel, Cmd.map PlaylistPageMsg pageCmds )

                Route.Search ->
                    let
                        ( pageModel, pageCmds ) =
                            Search.init model.token
                    in
                    ( Search pageModel, Cmd.map SearchPageMsg pageCmds )

                Route.Artist id ->
                    let
                        ( pageModel, pageCmds ) =
                            Artist.init id model.token
                    in
                    ( Artist pageModel, Cmd.map ArtistPageMsg pageCmds )

                Route.Track id ->
                    let
                        ( pageModel, pageCmds ) =
                            Track.init id model.token
                    in
                    ( Track pageModel, Cmd.map TrackPageMsg pageCmds )

                Route.Album id ->
                    let
                        ( pageModel, pageCmds ) =
                            Album.init id model.token
                    in
                    ( Album pageModel, Cmd.map AlbumPageMsg pageCmds )
    in
    ( { model | page = currentPage }
    , Cmd.batch [ existingCmds, mappedPageCmds ]
    )


view : Model -> Browser.Document Msg
view model =
    { title = "Spotify Elm"
    , body = [ currentView model ]
    }


currentView : Model -> Html Msg
currentView model =
    case model.page of
        NotFoundPage ->
            View.notFoundView

        Home pageModel ->
            Home.view pageModel |> Html.map HomePageMsg

        Playlist pageModel ->
            Playlist.view pageModel |> Html.map PlaylistPageMsg

        Search pageModel ->
            Search.view pageModel |> Html.map SearchPageMsg

        Album pageModel ->
            Album.view pageModel |> Html.map AlbumPageMsg

        Track pageModel ->
            Track.view pageModel |> Html.map TrackPageMsg

        Artist pageModel ->
            Artist.view pageModel |> Html.map ArtistPageMsg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( HomePageMsg subMsg, Home pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    Home.update subMsg pageModel
            in
            ( { model | page = Home updatedPageModel, token = pageModel.token }
            , Cmd.map HomePageMsg updatedCmd
            )

        ( PlaylistPageMsg subMsg, Playlist pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    Playlist.update subMsg pageModel
            in
            ( { model | page = Playlist updatedPageModel }
            , Cmd.map PlaylistPageMsg updatedCmd
            )

        ( SearchPageMsg subMsg, Search pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    Search.update subMsg pageModel
            in
            ( { model | page = Search updatedPageModel }
            , Cmd.map SearchPageMsg updatedCmd
            )

        ( AlbumPageMsg subMsg, Album pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    Album.update subMsg pageModel
            in
            ( { model | page = Album updatedPageModel }
            , Cmd.map AlbumPageMsg updatedCmd
            )

        ( TrackPageMsg subMsg, Track pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    Track.update subMsg pageModel
            in
            ( { model | page = Track updatedPageModel }
            , Cmd.map TrackPageMsg updatedCmd
            )

        ( ArtistPageMsg subMsg, Artist pageModel ) ->
            let
                ( updatedPageModel, updatedCmd ) =
                    Artist.update subMsg pageModel
            in
            ( { model | page = Artist updatedPageModel }
            , Cmd.map ArtistPageMsg updatedCmd
            )

        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl model.navKey (Url.toString url)
                    )

                Browser.External url ->
                    ( model
                    , Nav.load url
                    )

        ( UrlChanged url, _ ) ->
            let
                newRoute =
                    Route.parseUrl url
            in
            ( { model | route = newRoute }, Cmd.none )
                |> initCurrentPage

        _ ->
            ( model, Cmd.none )
