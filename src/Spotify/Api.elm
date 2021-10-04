module Spotify.Api exposing (get)

import Http
import HttpBuilder
import Json.Decode as Decode
import RemoteData exposing (WebData)


get : String -> (WebData a -> msg) -> Decode.Decoder a -> String -> Cmd msg
get url data decoder authToken =
    HttpBuilder.get url
        |> HttpBuilder.withHeader "Authorization" ("Bearer " ++ authToken)
        |> HttpBuilder.withExpect (Http.expectJson (RemoteData.fromResult >> data) decoder)
        |> HttpBuilder.request



{-
   Zu Beginn des Projektes habe ich mit Hilfe dieser API Schnittstelle einen Auth 2.0 Token anfragen können.
   Leider bin ich später auf einen für mich nicht lösbaren Fehler gestoßen.
   Desshalb wird der Token über die URL und einen Redirect-Link empfangen.

   Quelle: https://community.spotify.com/t5/Spotify-for-Developers/Refresh-Token-API-returning-CORS-errors/td-p/5217897

-}
{- postToken : (WebData a -> msg) -> Decode.Decoder a -> Cmd msg
   postToken data decoder =
       HttpBuilder.post "https://accounts.spotify.com/api/token"
           |> HttpBuilder.withHeader "Authorization" ("Basic " ++ "ZWEwNGJmMGVkNTcyNDQ1NGEzMDVkMWUwMTExMTJlNmQ6ZGIwM2E5ZjMyYTk0NDgyNzg1NTg1MmZjODhmYmM0ZmQ=")
           |> HttpBuilder.withBody (Http.stringBody "grant_type" "client_credentials")
           |> HttpBuilder.withExpect (Http.expectJson (RemoteData.fromResult >> data) decoder)
           |> HttpBuilder.request
-}
