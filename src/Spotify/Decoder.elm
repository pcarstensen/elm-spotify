module Spotify.Decoder exposing
    ( albumDecoder
    , artistAlbumDecoder
    , artistDecoder
    , itemDecoder
    , playlistDecoder
    , playlistItemDecoder
    , playlistsDecoder
    , profileDecoder
    , searchResultDecoder
    )

import Json.Decode as Decode
import Spotify.Models exposing (Album, Artist, Playlist, Profile, SearchResult, Track)



-- Aus der Vorlesung


apply : Decode.Decoder a -> Decode.Decoder (a -> b) -> Decode.Decoder b
apply =
    Decode.map2 (|>)



-- Helper


helpDecoder : Decode.Decoder a -> Decode.Decoder a
helpDecoder decoder =
    Decode.field "items" decoder



-- Basic Decoder


profileDecoder : Decode.Decoder Profile
profileDecoder =
    Decode.succeed Profile
        |> apply (Decode.field "display_name" Decode.string)
        |> apply (Decode.field "id" Decode.string)
        |> apply (Decode.field "images" imageDecoder)
        |> apply (Decode.field "followers" (Decode.field "total" Decode.int))


imageDecoder : Decode.Decoder (List String)
imageDecoder =
    Decode.list (Decode.field "url" Decode.string)


playlistDecoder : Decode.Decoder Playlist
playlistDecoder =
    Decode.succeed Playlist
        |> apply (Decode.field "id" Decode.string)
        |> apply (Decode.field "name" Decode.string)
        |> apply (Decode.field "images" imageDecoder)
        |> apply (Decode.field "description" Decode.string)
        |> apply (Decode.field "owner" (Decode.field "display_name" Decode.string))
        |> apply (Decode.field "tracks" (Decode.field "total" Decode.int))


itemDecoder : Decode.Decoder Track
itemDecoder =
    Decode.succeed Track
        |> apply (Decode.field "id" Decode.string)
        |> apply (Decode.field "name" Decode.string)
        |> apply
            (Decode.field "artists"
                (Decode.list
                    artistDecoder
                )
            )
        |> apply (Decode.maybe (Decode.field "album" (Decode.field "images" imageDecoder)))


artistDecoder : Decode.Decoder Artist
artistDecoder =
    Decode.succeed Artist
        |> apply (Decode.field "id" Decode.string)
        |> apply (Decode.field "name" Decode.string)
        |> apply (Decode.maybe (Decode.field "images" imageDecoder))


albumDecoder : Decode.Decoder Album
albumDecoder =
    Decode.succeed Album
        |> apply (Decode.field "id" Decode.string)
        |> apply (Decode.field "name" Decode.string)
        |> apply (Decode.maybe (Decode.field "images" imageDecoder))
        |> apply
            (Decode.maybe
                (Decode.field "tracks" (helpDecoder (Decode.list itemDecoder)))
            )



-- Extra Decoder


playlistItemDecoder : Decode.Decoder (List Track)
playlistItemDecoder =
    helpDecoder
        (Decode.list
            (Decode.field "track" itemDecoder)
        )


searchResultDecoder : Decode.Decoder SearchResult
searchResultDecoder =
    Decode.succeed SearchResult
        |> apply (Decode.field "albums" (helpDecoder (Decode.list albumDecoder)))
        |> apply (Decode.field "tracks" (helpDecoder (Decode.list itemDecoder)))
        |> apply (Decode.field "artists" (helpDecoder (Decode.list artistDecoder)))
        |> apply (Decode.field "playlists" (helpDecoder (Decode.list playlistDecoder)))


playlistsDecoder : Decode.Decoder (List Playlist)
playlistsDecoder =
    helpDecoder (Decode.list playlistDecoder)


artistAlbumDecoder : Decode.Decoder (List Album)
artistAlbumDecoder =
    helpDecoder (Decode.list albumDecoder)
