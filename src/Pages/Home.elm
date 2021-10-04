module Pages.Home exposing (Model, Msg(..), init, update, view)

import Helper.Fold exposing (foldMaybe)
import Html exposing (Html, div, h1, text)
import Html.Attributes exposing (class, style)
import RemoteData exposing (RemoteData(..), WebData)
import Spotify.Api as Spotify
import Spotify.Decoder as Spotify
import Spotify.Models as Spotify
import View


type alias Model =
    { token : Maybe String
    , playlistResponse : WebData (List Spotify.Playlist)
    , profileResponse : WebData Spotify.Profile
    }


init : Maybe String -> ( Model, Cmd Msg )
init token =
    ( { token = token
      , playlistResponse = NotAsked
      , profileResponse = NotAsked
      }
    , foldMaybe
        getProfile
        Cmd.none
        token
    )


view : Model -> Html Msg
view model =
    -- navbar
    div [ style "width" "100%", style "height" "100%" ]
        [ View.viewNavBar

        -- img
        , div [ class "masthead fw-bold d-flex text-white justify-content-evenly", style "font-size" "40px" ]
            [ div [] [ text "Wilkommen" ]
            , View.viewRequest viewProfile model.profileResponse
            ]

        -- content
        , div [ class "container mt-5" ] [ View.viewRequest viewPlaylists model.playlistResponse ]
        ]


viewProfile : Spotify.Profile -> Html Msg
viewProfile profile =
    div [] [ text profile.username ]


type Msg
    = PlaylistData (WebData (List Spotify.Playlist))
    | ProfileData (WebData Spotify.Profile)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        PlaylistData response ->
            ( { model | playlistResponse = response }
            , Cmd.none
            )

        ProfileData req ->
            case req of
                RemoteData.Success response ->
                    ( { model | profileResponse = req }
                    , foldMaybe (getPlaylists response.username) Cmd.none model.token
                    )

                _ ->
                    ( model, Cmd.none )


viewPlaylists : List Spotify.Playlist -> Html Msg
viewPlaylists list =
    div []
        [ h1 [] [ text "Deine Playlists" ]
        , div [ class "d-flex" ] (View.viewPlaylist list)
        ]


getPlaylists : String -> String -> Cmd Msg
getPlaylists id authToken =
    Spotify.get
        ("https://api.spotify.com/v1/users/" ++ id ++ "/playlists")
        PlaylistData
        Spotify.playlistsDecoder
        authToken


getProfile : String -> Cmd Msg
getProfile authToken =
    Spotify.get
        "https://api.spotify.com/v1/me"
        ProfileData
        Spotify.profileDecoder
        authToken
