module Yaml exposing (decodeData, encodeData)

-- for decoders

import Data exposing (Datum)
import Time
import Yaml.Decode as Decode exposing(Decoder)
import Yaml.Encode as Encode exposing (Encoder)


decodeData : String -> Result Decode.Error (List Datum)
decodeData str =
    Decode.fromString (Decode.list datumDecoder) str

datumDecoder : Decoder Datum
datumDecoder =
   Decode.map7 Datum
     (Decode.field "id" Decode.string)
     (Decode.field "title" Decode.string)
     (Decode.field "username" Decode.string)
     (Decode.field "content" Decode.string)
     (Decode.field "tags" (Decode.list Decode.string))
     (Decode.field "creationDate" (Decode.int |> Decode.map Time.millisToPosix))
     (Decode.field "modificationDate" (Decode.int |> Decode.map Time.millisToPosix))



-- ENCODE

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
        , ( "creationDate", Encode.int (Time.posixToMillis datum.creationDate) )
        , ( "modificationDate", Encode.int (Time.posixToMillis datum.creationDate) )
        ]


testDatum =
    { id = "UUJJ"
    , title = "Course Notes"
    , username = "Jim"
    , content = "Gotta get started."
    , tags = [ "aa", "bb" ]
    , creationDate = Time.millisToPosix 0
    , modificationDate = Time.millisToPosix 1
    }
