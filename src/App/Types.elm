module Types exposing (Language(..), TranslateStatus(..), Translation)

import Browser
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (Html)


type TranslateStatus
    = TranslateFailure
    | TranslateLoading
    | TranslateSuccess Translation


type Language
    = English
    | Russian
    | Ukrainian


type alias Translation =
    Dict String String
