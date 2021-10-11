module Evergreen.V77.Authentication exposing (..)

import Dict
import Evergreen.V77.Credentials
import Evergreen.V77.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V77.User.User
    , credentials : Evergreen.V77.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
