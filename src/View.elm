module View exposing
    ( notFoundView
    , viewAlbums
    , viewArtist
    , viewArtistsWithImage
    , viewImage
    , viewItems
    , viewNavBar
    , viewPlaylist
    , viewRequest
    )

import Helper.Fold exposing (foldMaybe)
import Html exposing (Html, a, div, h1, h3, h5, img, nav, p, text)
import Html.Attributes exposing (attribute, class, height, href, src, width)
import RemoteData exposing (WebData)
import Spotify.Decoder as Spotify
import Spotify.Models as Spotify


viewRequest : (a -> Html msg) -> WebData a -> Html msg
viewRequest f req =
    case req of
        RemoteData.Success a ->
            f a

        _ ->
            text ""


viewImage : Int -> Int -> List String -> Html msg
viewImage w h list =
    case list of
        [] ->
            text ""

        imageUrl :: _ ->
            img [ src imageUrl, width w, height h ] []


viewArtist : List Spotify.Artist -> List (Html msg)
viewArtist artists =
    let
        show : Spotify.Artist -> String -> Html msg
        show artist str =
            a [ href ("/artist/" ++ artist.id) ]
                [ text (artist.name ++ str) ]
    in
    case artists of
        [] ->
            []

        artist :: [] ->
            [ show artist "" ]

        artist :: rest ->
            show artist "," :: viewArtist rest


viewPlaylist : List Spotify.Playlist -> List (Html msg)
viewPlaylist list =
    case list of
        [] ->
            []

        playlist :: rest ->
            div [ class "card text-white bg-dark me-5", attribute "style" "width: 202px; flex-shrink: 0;" ]
                [ viewImage 200 200 playlist.images
                , div [ class "card-body fs-5" ]
                    [ h5 [ class "card-title" ]
                        [ text playlist.name ]
                    , p [ class "card-text" ]
                        [ text ("Besitzer: " ++ playlist.owner) ]
                    , p [ class "card-text" ]
                        [ text ("Anzahl der Tracks: " ++ String.fromInt playlist.tracks) ]
                    ]
                , div [ class "card-footer text-center" ]
                    [ a [ class "btn btn-success ", href ("/playlist/" ++ playlist.id) ]
                        [ text "Zur Playlist" ]
                    ]
                ]
                :: viewPlaylist rest


viewItems : List Spotify.Track -> List (Html msg)
viewItems items =
    case items of
        [] ->
            []

        item :: rest ->
            div [ class "card text-white bg-dark me-5", attribute "style" "width: 200px; flex-shrink: 0;" ]
                [ foldMaybe (viewImage 200 200) (text "") item.images
                , div [ class "card-body fs-5" ]
                    [ h5 [ class "card-title" ]
                        [ text item.name ]
                    , p [ class "card-text" ]
                        (viewArtist
                            item.artist
                        )
                    ]
                , div [ class "card-footer text-center" ]
                    [ a [ class "btn btn-success ", href ("/track/" ++ item.id) ]
                        [ text "Zum Track" ]
                    ]
                ]
                :: viewItems rest


viewAlbums : List Spotify.Album -> List (Html msg)
viewAlbums albums =
    case albums of
        [] ->
            []

        album :: rest ->
            div [ class "card text-white bg-dark me-5", attribute "style" "width: 200px; flex-shrink: 0;", height 300 ]
                [ foldMaybe (viewImage 200 200) (text "") album.images
                , div [ class "card-body fs-5" ]
                    [ h5 [ class "card-title" ]
                        [ text album.name ]
                    , div [ class "card-footer text-center" ]
                        [ a [ class "btn btn-success ", href ("/album/" ++ album.id) ]
                            [ text "Zum Album" ]
                        ]
                    ]
                ]
                :: viewAlbums rest


viewArtistsWithImage : List Spotify.Artist -> List (Html msg)
viewArtistsWithImage artists =
    case artists of
        [] ->
            []

        artist :: rest ->
            div [ class "card text-white bg-dark me-5", attribute "style" "width: 200px; flex-shrink: 0;", height 300 ]
                [ foldMaybe (viewImage 200 200) (text "") artist.images
                , div [ class "card-body fs-5" ]
                    [ h5 [ class "card-title" ]
                        [ text artist.name ]
                    , div [ class "card-footer text-center" ]
                        [ a [ class "btn btn-success ", href ("/artist/" ++ artist.id) ]
                            [ text "Zum Künstler" ]
                        ]
                    ]
                ]
                :: viewArtistsWithImage rest


viewNavBar : Html msg
viewNavBar =
    nav [ class "navbar navbar-dark bg-dark" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", href "/home" ]
                [ img [ attribute "height" "45", src "/src/assets/logo.png", attribute "width" "45" ]
                    []
                ]
            , h1 [ class "text-white" ] [ text "Spotify LITE" ]
            , div [ class "navbar-nav fs-3 " ] [ a [ class "nav-link active", href "/search" ] [ text "Suche" ] ]
            ]
        ]


notFoundView : Html msg
notFoundView =
    h3 [] [ text "404 page not found" ]
