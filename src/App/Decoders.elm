module Decoders exposing (decodeTranslations)

import Types exposing (..)
import Json.Decode exposing (Decoder, dict, string)


decodeTranslations : Decoder Translation
decodeTranslations =
    dict string
