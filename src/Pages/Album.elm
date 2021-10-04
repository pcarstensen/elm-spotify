module Pages.Album exposing (Model, Msg(..), init, update, view)

import Helper.Fold exposing (foldMaybe)
import Html exposing (Html, div, h1, p, text)
import Html.Attributes exposing (attribute, class, style)
import RemoteData exposing (RemoteData(..), WebData)
import Spotify.Api as Spotify
import Spotify.Decoder as Spotify
import Spotify.Models as Spotify
import View


type Msg
    = AlbumData (WebData Spotify.Album)


type alias Model =
    { token : Maybe String
    , id : String
    , album : WebData Spotify.Album
    }


init : String -> Maybe String -> ( Model, Cmd Msg )
init id token =
    ( { token = token
      , id = id
      , album = NotAsked
      }
    , foldMaybe (getAlbum id) Cmd.none token
    )


view : Model -> Html Msg
view model =
    div [ style "width" "100%", style "height" "100%" ]
        [ View.viewNavBar
        , View.viewRequest viewAlbum
            model.album
        ]


viewAlbum : Spotify.Album -> Html Msg
viewAlbum album =
    div []
        [ div [ class "card bg-dark text-white text-cente container" ]
            [ div [ class "card-body" ]
                [ h1 [ class "card-title" ] [ text "Playlist" ]
                , foldMaybe (View.viewImage 300 300) (text "") album.images
                , p [ class "card-text h3 mt-3" ] [ text ("Name: " ++ album.name) ]
                ]
            ]
        , foldMaybe viewTracks (text "") album.tracks
        ]


viewTracks : List Spotify.Track -> Html Msg
viewTracks items =
    div [ class "text-center" ]
        [ h1 [] [ text "Tracks" ]
        , div [ class "container d-flex", attribute "style" "overflow-x: scroll;" ] (View.viewItems items)
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AlbumData response ->
            ( { model | album = response }, Cmd.none )


getAlbum : String -> String -> Cmd Msg
getAlbum id authToken =
    Spotify.get ("https://api.spotify.com/v1/albums/" ++ id) AlbumData Spotify.albumDecoder authToken
