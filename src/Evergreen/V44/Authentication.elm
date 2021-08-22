module Evergreen.V44.Authentication exposing (..)

import Dict
import Evergreen.V44.Credentials
import Evergreen.V44.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V44.User.User
    , credentials : Evergreen.V44.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
