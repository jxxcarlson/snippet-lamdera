module Evergreen.V77.Data exposing (..)

import Dict
import Time


type alias Username =
    String


type alias Datum =
    { id : String
    , title : String
    , username : Username
    , content : String
    , tags : List String
    , creationDate : Time.Posix
    , modificationDate : Time.Posix
    }


type alias DataFile =
    { data : List Datum
    , username : Username
    , creationDate : Time.Posix
    , modificationDate : Time.Posix
    }


type alias DataDict =
    Dict.Dict Username DataFile


type alias DataId =
    String
