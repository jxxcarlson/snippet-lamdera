module Data exposing (Data, DataDict, DataFile)

import Dict exposing (Dict)
import Time


type alias Username =
    String


type alias Data =
    { id : String
    , title : String
    , username : Username
    , content : String
    , tags : List String
    , creationData : Time.Posix
    , modificationData : Time.Posix
    }


type alias DataFile =
    { data : List Data
    , username : Username
    , creationData : Time.Posix
    , modificationData : Time.Posix
    }


type alias DataDict =
    Dict Username DataFile
