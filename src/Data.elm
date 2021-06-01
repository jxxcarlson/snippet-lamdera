module Data exposing
    ( DataDict
    , DataFile
    , Datum
    , insertDatum
    , make
    , setupUser
    )

import Dict exposing (Dict)
import Time


type alias Username =
    String


type alias Datum =
    { id : String
    , title : String
    , username : Username
    , content : String
    , tags : List String
    , creationData : Time.Posix
    , modificationData : Time.Posix
    }


make : Username -> Time.Posix -> String -> String -> Datum
make username currentTime id content =
    { id = id
    , title = content |> String.lines |> List.head |> Maybe.withDefault "TITLE"
    , username = username
    , content = content
    , tags = []
    , creationData = currentTime
    , modificationData = currentTime
    }


type alias DataFile =
    { data : List Datum
    , username : Username
    , creationData : Time.Posix
    , modificationData : Time.Posix
    }


type alias DataDict =
    Dict Username DataFile


setupUser : Time.Posix -> Username -> DataDict -> DataDict
setupUser currentTime username dataDict =
    let
        newDataFile =
            { data = []
            , username = username
            , creationData = currentTime
            , modificationData = currentTime
            }
    in
    Dict.insert username newDataFile dataDict


insertDatum : Username -> Datum -> DataDict -> DataDict
insertDatum username datum dataDict =
    case Dict.get username dataDict of
        Nothing ->
            dataDict

        Just dataFile ->
            Dict.insert username { dataFile | data = datum :: dataFile.data } dataDict
