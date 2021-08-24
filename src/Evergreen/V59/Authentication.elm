module Evergreen.V59.Authentication exposing (..)

import Dict
import Evergreen.V59.Credentials
import Evergreen.V59.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V59.User.User
    , credentials : Evergreen.V59.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
