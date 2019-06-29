module Main exposing (Model, Msg(..), init, main)

import Decoders exposing (..)
import Pages.NotFound as NotFound
import Router exposing (..)
import Types exposing (..)
import Browser
import Browser.Navigation as Nav
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Services.I18n as I18n exposing (..)
import Url
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, string, top)


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , route : Route
    , language : Language
    , translation : TranslateStatus
    }


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | MsgNotFound NotFound.Msg
    | HandleTranslateResponse (Result Http.Error Translation)
    | Back


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        route =
            toRoute url
    in
    ( { key = key
      , url = url
      , route = route
      , language = English
      , translation = TranslateLoading
      }
    , English |> getLangString |> getTranslation
    )


getTranslation : String -> Cmd Msg
getTranslation lang =
    Http.get
        { url = "/translations/" ++ lang ++ ".json"
        , expect = Http.expectJson HandleTranslateResponse decodeTranslations
        }



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgNotFound _ ->
            ( model
            , Cmd.none
            )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            let
                route =
                    toRoute url
            in
            ( { model | url = url, route = route }
            , Cmd.none
            )

        HandleTranslateResponse result ->
            case result of
                Ok translation ->
                    ( { model | translation = TranslateSuccess translation }, Cmd.none )

                Err _ ->
                    ( { model | translation = TranslateFailure }, Cmd.none )

        -- ChangeLanguage select ->
        --     let
        --         oldSettings =
        --             model.settings
        --         newSettings =
        --             { oldSettings | language = select }
        --     in
        --     ( { model | settings = newSettings }
        --     , Cmd.batch [ saveSettings newSettings, getTranslation select ]
        --     )
        Back ->
            ( model
            , Nav.back model.key 1
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



--VIEW


view : Model -> Browser.Document Msg
view model =
    let
        trans =
            I18n.get model.translation
    in
    case model.translation of
        TranslateLoading ->
            { title = trans "LOADING"
            , body = [ loader ]
            }

        TranslateSuccess _ ->
            let
                viewPage pageview =
                    let
                        { title, content } =
                            pageview model
                    in
                    { title = title
                    , body = [ nav model, content, footer model ]
                    }
            in
            case model.route of
                Home ->
                    viewPage homeView

                NotFound ->
                    let
                        { title, body } =
                            NotFound.view (NotFound.Model model.translation)
                    in
                    { title = title
                    , body = List.map (Html.map MsgNotFound) body
                    }

        TranslateFailure ->
            { title = trans "FAILURE"
            , body = [ loader ]
            }


nav : Model -> Html Msg
nav model =
    let
        trans =
            I18n.get model.translation
    in
    header []
        [ Html.nav [ class "navbar", id "myNavBar" ]
            [ ul [ class "nav" ]
                [ li []
                    [ a [ href "/" ]
                        [ span [] [ text (trans "HOME") ] ]
                    ]
                , li []
                    [ a [ href "/404" ]
                        [ span [] [ text (trans "NOT.FOUND") ] ]
                    ]
                ]
            ]
        ]


footer : Model -> Html Msg
footer model =
    let
        trans =
            I18n.get model.translation
    in
    Html.footer [ class "container" ]
        [ Html.nav []
            [ ul []
                [ li []
                    [ a [ href "/about" ]
                        [ text (trans "ABOUT") ]
                    ]
                , li []
                    [ a [ href "/contact" ]
                        [ text (trans "CONTACT") ]
                    ]
                ]
            ]
        , small [] [ text "Copyright © 2019" ]
        ]


homeView : Model -> { title : String, content : Html Msg }
homeView model =
    let
        trans =
            I18n.get model.translation
    in
    { title = trans "HOME"
    , content =
        main_ [ id "content", class "container home", tabindex -1 ]
            [ div []
                [ span [] [ text "HOME" ]
                ]
            ]
    }


loader =
    div [ class "loader" ] []


toRoute : Url.Url -> Route
toRoute string =
    case string.path of
        "" ->
            NotFound

        _ ->
            Maybe.withDefault NotFound (parse route string)
