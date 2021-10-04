module Pages.Playlist exposing (Model, Msg(..), init, update, view)

import Helper.Fold exposing (foldMaybe)
import Html exposing (Html, div, h1, p, text)
import Html.Attributes exposing (attribute, class, style)
import RemoteData exposing (RemoteData(..), WebData)
import Spotify.Api as Spotify
import Spotify.Decoder as Spotify
import Spotify.Models as Spotify
import View


type alias Model =
    { token : Maybe String
    , id : String
    , items : WebData (List Spotify.Track)
    , playlist : WebData Spotify.Playlist
    }


init : String -> Maybe String -> ( Model, Cmd Msg )
init id token =
    ( { token = token
      , id = id
      , items = NotAsked
      , playlist = NotAsked
      }
    , Cmd.batch
        [ foldMaybe (getPlaylistItems id) Cmd.none token
        , foldMaybe (getPlaylist id) Cmd.none token
        ]
    )


view : Model -> Html Msg
view model =
    div [ style "width" "100%", style "height" "100%" ]
        [ View.viewNavBar
        , View.viewRequest viewPlaylist
            model.playlist
        , div [ class "text-center" ]
            [ h1 [] [ text "Songs" ]
            , View.viewRequest
                viewPlaylistTracks
                model.items
            ]
        ]


viewPlaylistTracks : List Spotify.Track -> Html Msg
viewPlaylistTracks tracks =
    div [ class "container d-flex", attribute "style" "overflow-x: scroll;" ]
        (View.viewItems
            tracks
        )


viewPlaylist : Spotify.Playlist -> Html Msg
viewPlaylist playlist =
    div [ class "card bg-dark text-white text-cente container" ]
        [ div [ class "card-body" ]
            [ h1 [ class "card-title" ] [ text "Playlist" ]
            , View.viewImage 300 300 playlist.images
            , p [ class "card-text h3 mt-3" ] [ text ("Name: " ++ playlist.name) ]
            ]
        ]


type Msg
    = ItemsData (WebData (List Spotify.Track))
    | PlaylistData (WebData Spotify.Playlist)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ItemsData response ->
            ( { model | items = response }
            , Cmd.none
            )

        PlaylistData response ->
            ( { model | playlist = response }
            , Cmd.none
            )


getPlaylistItems : String -> String -> Cmd Msg
getPlaylistItems playlistId authToken =
    Spotify.get ("https://api.spotify.com/v1/playlists/" ++ playlistId ++ "/tracks") ItemsData Spotify.playlistItemDecoder authToken


getPlaylist : String -> String -> Cmd Msg
getPlaylist playlistId authToken =
    Spotify.get ("https://api.spotify.com/v1/playlists/" ++ playlistId) PlaylistData Spotify.playlistDecoder authToken
