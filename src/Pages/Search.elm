module Pages.Search exposing (Model, Msg(..), init, update, view)

import Helper.Fold exposing (foldMaybe)
import Html exposing (Html, button, div, h1, input, text)
import Html.Attributes exposing (attribute, class, id, placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)
import RemoteData exposing (RemoteData(..), WebData)
import Spotify.Api as Spotify
import Spotify.Decoder as Spotify
import Spotify.Models as Spotify
import View


type alias Model =
    { token : Maybe String
    , setSearchQuery : String
    , searchResponse : WebData Spotify.SearchResult
    }


init : Maybe String -> ( Model, Cmd Msg )
init token =
    ( { token = token
      , setSearchQuery = ""
      , searchResponse = NotAsked
      }
    , Cmd.none
    )


view : Model -> Html Msg
view model =
    div [ style "width" "100%", style "height" "100%" ]
        [ View.viewNavBar
        , viewSearch model.setSearchQuery
        , View.viewRequest viewResult model.searchResponse
        ]


type Msg
    = SearchQueryData (WebData Spotify.SearchResult)
    | Search
    | ChangeSearchQuery String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchQueryData req ->
            case req of
                RemoteData.Success _ ->
                    ( { model | searchResponse = req }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        Search ->
            ( model, foldMaybe (getSearchQuery model.setSearchQuery) Cmd.none model.token )

        ChangeSearchQuery value ->
            ( { model | setSearchQuery = value }
            , Cmd.none
            )


viewResult : Spotify.SearchResult -> Html Msg
viewResult result =
    div [ class "text-center container" ]
        [ div []
            [ h1 [] [ text "Playlists" ]
            , div [ class "container d-flex", attribute "style" "overflow-x: scroll;" ] (View.viewPlaylist result.playlists)
            ]
        , div []
            [ h1 [] [ text "Tracks" ]
            , div [ class "container d-flex", attribute "style" "overflow-x: scroll;" ] (View.viewItems result.tracks)
            ]
        , div []
            [ h1 [] [ text "Alben" ]
            , div [ class "container d-flex", attribute "style" "overflow-x: scroll;" ] (View.viewAlbums result.albums)
            ]
        , div
            []
            [ h1 [] [ text "Künstler" ]
            , div [ class "container d-flex", attribute "style" "overflow-x: scroll;" ] (View.viewArtistsWithImage result.artists)
            ]
        ]


viewSearch : String -> Html Msg
viewSearch str =
    div
        [ class "input-group container", style "width" "40%" ]
        [ input
            [ attribute "aria-describedby" "searchButton"
            , attribute "aria-label" "Suche Tracks, Künstler, Alben, Playlists .."
            , class "form-control"
            , placeholder "Suche Tracks, Künstler, Alben, Playlists .."
            , type_ "text"
            , onInput ChangeSearchQuery
            , value str
            , class "fs-2"
            ]
            []
        , button [ class "btn btn-success fs-4", id "searchButton", type_ "button", onClick Search ]
            [ text "Suchen" ]
        ]


getSearchQuery : String -> String -> Cmd Msg
getSearchQuery searchString authToken =
    Spotify.get
        ("https://api.spotify.com/v1/search?q="
            ++ searchString
            ++ "&type=album%2Cartist%2Cplaylist%2Ctrack"
        )
        SearchQueryData
        Spotify.searchResultDecoder
        authToken
