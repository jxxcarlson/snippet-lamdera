module Yaml exposing (..)

-- for decoders

import Data exposing (Datum)
import Time
import Yaml.Decode
import Yaml.Encode as Encode exposing (Encoder)


encodeData : List Datum -> String
encodeData data =
    Encode.toString 4 (dataEncoder data)


dataEncoder : List Datum -> Encoder
dataEncoder data =
    Encode.list datumEncoder data


datumEncoder : Datum -> Encoder
datumEncoder datum =
    Encode.record
        [ ( "id", Encode.string datum.id )
        , ( "title", Encode.string datum.title )
        , ( "username", Encode.string datum.username )
        , ( "content", Encode.string datum.content )
        , ( "tags", Encode.list Encode.string datum.tags )
        , ( "creationDate", Encode.int (Time.posixToMillis datum.creationData) )
        , ( "modificationDate", Encode.int (Time.posixToMillis datum.creationData) )
        ]


testDatum =
    { id = "UUJJ"
    , title = "Course Notes"
    , username = "Jim"
    , content = "Gotta get started."
    , tags = [ "aa", "bb" ]
    , creationData = Time.millisToPosix 0
    , modificationData = Time.millisToPosix 1
    }
