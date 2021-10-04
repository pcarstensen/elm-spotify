module Helper.Url exposing (getToken)

import Url exposing (Url)


preprocessHash : Url -> List ( String, String )
preprocessHash url =
    let
        fragment =
            url.fragment

        parts =
            case fragment of
                Just v ->
                    String.split "&" v

                Nothing ->
                    []

        split str =
            String.split "=" str

        transformProperties ll =
            case ll of
                [] ->
                    []

                x1 :: xs1 ->
                    case xs1 of
                        [] ->
                            []

                        x2 :: xs2 ->
                            ( x1, x2 ) :: transformProperties xs2
    in
    transformProperties (List.concat (List.map split parts))


getHashProperty : String -> List ( String, String ) -> Maybe String
getHashProperty property list =
    case list of
        [] ->
            Nothing

        ( key, value ) :: xs ->
            if key == property then
                Just value

            else
                getHashProperty property xs


getToken : Url -> Maybe String
getToken url =
    getHashProperty "access_token" (preprocessHash url)
