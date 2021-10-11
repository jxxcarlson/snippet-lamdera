module Codec exposing (decodeData, encodeData)

import Data exposing (Datum)
import Json.Decode as D
import Json.Encode as E
import Time


decodeData : String -> Result D.Error (List Datum)
decodeData str =
    D.decodeString dataDecoder str


dataDecoder : D.Decoder (List Datum)
dataDecoder =
    D.list datumDecoder


datumDecoder : D.Decoder Datum
datumDecoder =
    D.map7 Datum
        (D.field "id" D.string)
        (D.field "title" D.string)
        (D.field "username" D.string)
        (D.field "content" D.string)
        (D.field "tags" (D.list D.string))
        (D.field "creationDate" (D.int |> D.map Time.millisToPosix))
        (D.field "creationDate" D.int |> D.map Time.millisToPosix)


type alias Datum2 =
    { id : String
    , title : String
    , username : String
    , content : String
    , tags : List String
    , creationDate : Time.Posix
    , modificationDate : Time.Posix
    }


encodeData : List Datum -> String
encodeData data =
    E.encode 3 (dataEncoder data)


dataEncoder : List Datum -> E.Value
dataEncoder data =
    E.list datumEncoder data


datumEncoder : Datum -> E.Value
datumEncoder datum =
    E.object
        [ ( "id", E.string datum.id )
        , ( "title", E.string datum.title )
        , ( "username", E.string datum.username )
        , ( "content", E.string datum.content )
        , ( "tags", E.list E.string datum.tags )
        , ( "creationDate", E.int (Time.posixToMillis datum.creationDate) )
        , ( "modificationDate", E.int (Time.posixToMillis datum.creationDate) )
        ]
