module Router exposing (Route(..), route, toRoute)

-- import Page.Home as Home
-- import Page.Settings as Settings
-- import Page.NotFound as NotFound

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Url
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, string, top)


type Route
    = Home
    | NotFound


route : Parser (Route -> a) a
route =
    oneOf
        [ map Home top
        , map NotFound (s "404")
        ]


toRoute : Url.Url -> Route
toRoute string =
    case string.path of
        "" ->
            NotFound

        _ ->
            Maybe.withDefault NotFound (parse route string)
