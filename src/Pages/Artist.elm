module Pages.Artist exposing (Model, Msg(..), init, update, view)

import Helper.Fold exposing (foldMaybe)
import Html exposing (Html, div, h1, p, text)
import Html.Attributes exposing (attribute, class, style)
import RemoteData exposing (RemoteData(..), WebData)
import Spotify.Api as Spotify
import Spotify.Decoder as Spotify
import Spotify.Models as Spotify
import View


type Msg
    = ArtistData (WebData Spotify.Artist)
    | AlbumsData (WebData (List Spotify.Album))


type alias Model =
    { token : Maybe String
    , id : String
    , artist : WebData Spotify.Artist
    , albums : WebData (List Spotify.Album)
    }


init : String -> Maybe String -> ( Model, Cmd Msg )
init id token =
    ( { token = token
      , id = id
      , artist = NotAsked
      , albums = NotAsked
      }
    , Cmd.batch
        [ foldMaybe (getArtist id) Cmd.none token
        , foldMaybe (getArtistAlbums id) Cmd.none token
        ]
    )


view : Model -> Html Msg
view model =
    div [ style "width" "100%", style "height" "100%" ]
        [ View.viewNavBar
        , div [ class "container" ]
            [ View.viewRequest
                viewArtist
                model.artist
            , View.viewRequest
                viewAlbums
                model.albums
            ]
        ]


viewAlbums : List Spotify.Album -> Html Msg
viewAlbums albums =
    div []
        [ h1 [] [ text "Alben" ]
        , div [ class "container d-flex", attribute "style" "overflow-x: scroll;" ] (View.viewAlbums albums)
        ]


viewArtist : Spotify.Artist -> Html Msg
viewArtist artist =
    div [ class "card bg-dark text-white text-cente container" ]
        [ div [ class "card-body" ]
            [ h1 [ class "card-title" ] [ text "Künslter" ]
            , foldMaybe (View.viewImage 300 300) (text "") artist.images
            , p [ class "card-text h3 mt-3" ] [ text ("Name: " ++ artist.name) ]
            ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ArtistData response ->
            ( { model | artist = response }, Cmd.none )

        AlbumsData response ->
            ( { model | albums = response }, Cmd.none )


getArtist : String -> String -> Cmd Msg
getArtist id authToken =
    Spotify.get ("https://api.spotify.com/v1/artists/" ++ id) ArtistData Spotify.artistDecoder authToken


getArtistAlbums : String -> String -> Cmd Msg
getArtistAlbums id authToken =
    Spotify.get ("https://api.spotify.com/v1/artists/" ++ id ++ "/albums") AlbumsData Spotify.artistAlbumDecoder authToken
