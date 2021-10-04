module Route exposing (Route(..), parseUrl)

import Url exposing (Url)
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, string, top)


type Route
    = NotFound
    | Home
    | Playlist String
    | Track String
    | Album String
    | Artist String
    | Search


parseUrl : Url -> Route
parseUrl url =
    case parse matchRoute url of
        Just route ->
            route

        Nothing ->
            NotFound



{-
   Routing:
   Default -> Home

   Beispiel:
   http://localhost:8000/playlist/id -> Playlist id
-}


matchRoute : Parser (Route -> a) a
matchRoute =
    oneOf
        [ map Home top
        , map Home (s "home")
        , map Search (s "search")
        , map Track (s "track" </> string)
        , map Album (s "album" </> string)
        , map Artist (s "artist" </> string)
        , map Playlist (s "playlist" </> string)
        ]
