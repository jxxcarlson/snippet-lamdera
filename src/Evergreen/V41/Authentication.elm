module Evergreen.V41.Authentication exposing (..)

import Dict
import Evergreen.V41.Credentials
import Evergreen.V41.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V41.User.User
    , credentials : Evergreen.V41.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
