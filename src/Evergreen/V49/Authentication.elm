module Evergreen.V49.Authentication exposing (..)

import Dict
import Evergreen.V49.Credentials
import Evergreen.V49.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V49.User.User
    , credentials : Evergreen.V49.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
