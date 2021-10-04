module Pages.Track exposing (Model, Msg(..), init, update, view)

import Helper.Fold exposing (foldMaybe)
import Html exposing (Html, div, h1, h3, text)
import Html.Attributes exposing (class, style)
import RemoteData exposing (RemoteData(..), WebData)
import Spotify.Api as Spotify
import Spotify.Decoder as Spotify
import Spotify.Models as Spotify
import View


type Msg
    = TrackData (WebData Spotify.Track)


type alias Model =
    { token : Maybe String
    , id : String
    , track : WebData Spotify.Track
    }


init : String -> Maybe String -> ( Model, Cmd Msg )
init id token =
    ( { token = token
      , id = id
      , track = NotAsked
      }
    , foldMaybe (getTrack id) Cmd.none token
    )


view : Model -> Html Msg
view model =
    div [ style "width" "100%", style "height" "100%" ]
        [ View.viewNavBar
        , div [ class "container" ]
            [ View.viewRequest
                viewTrack
                model.track
            ]
        ]


viewTrack : Spotify.Track -> Html Msg
viewTrack track =
    div [ class "card text-black" ]
        [ div [ class "row g-0" ]
            [ div [ class "col-md-4" ]
                [ foldMaybe (View.viewImage 300 300) (text "") track.images
                ]
            , div [ class "col-md-8" ]
                [ div [ class "card-body" ]
                    [ h1 [ class "card-title" ]
                        [ text track.name ]
                    , h3 [ class "card-text" ]
                        (View.viewArtist
                            track.artist
                        )
                    ]
                ]
            ]
        ]


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        TrackData response ->
            ( { model | track = response }, Cmd.none )


getTrack : String -> String -> Cmd Msg
getTrack id authToken =
    Spotify.get ("https://api.spotify.com/v1/tracks/" ++ id) TrackData Spotify.itemDecoder authToken
