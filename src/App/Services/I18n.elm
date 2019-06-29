module Services.I18n exposing (get, getLangString)

import Types exposing (..)
import Dict exposing (Dict)


getLangString : Language -> String
getLangString lang =
    case lang of
        English ->
            "en"

        Russian ->
            "ru"

        Ukrainian ->
            "uk"


get : TranslateStatus -> String -> String
get status key =
    case status of
        TranslateSuccess translate ->
            translate
                |> Dict.get key
                |> Maybe.withDefault key

        TranslateFailure ->
            ""

        TranslateLoading ->
            ""
