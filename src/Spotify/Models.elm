module Spotify.Models exposing (Album, Artist, Playlist, Profile, SearchResult, Track)


type alias Profile =
    { id : String
    , username : String
    , images : List String
    , followers : Int
    }


type alias Playlist =
    { id : String
    , name : String
    , images : List String
    , description : String
    , owner : String
    , tracks : Int
    }


type alias Track =
    { id : String
    , name : String
    , artist : List Artist
    , images : Maybe (List String)
    }


type alias Artist =
    { id : String
    , name : String
    , images : Maybe (List String)
    }


type alias Album =
    { id : String
    , name : String
    , images : Maybe (List String)
    , tracks : Maybe (List Track)
    }


type alias SearchResult =
    { albums : List Album
    , tracks : List Track
    , artists : List Artist
    , playlists : List Playlist
    }
