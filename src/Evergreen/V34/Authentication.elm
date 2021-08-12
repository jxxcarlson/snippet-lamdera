module Evergreen.V34.Authentication exposing (..)

import Dict
import Evergreen.V34.Credentials
import Evergreen.V34.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V34.User.User
    , credentials : Evergreen.V34.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
