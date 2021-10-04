module Helper.Fold exposing (foldMaybe)


foldMaybe : (a -> b) -> b -> Maybe a -> b
foldMaybe just nothing maybe =
    case maybe of
        Nothing ->
            nothing

        Just value ->
            just value



{- foldWebdata : b -> b -> (Http.Error -> b) -> (a -> b) -> WebData a -> b
   foldWebdata notAsked loading failure success webdata =
       case webdata of
           RemoteData.NotAsked ->
               notAsked

           RemoteData.Loading ->
               loading

           RemoteData.Failure err ->
               failure err

           RemoteData.Success value ->
               success value
-}
