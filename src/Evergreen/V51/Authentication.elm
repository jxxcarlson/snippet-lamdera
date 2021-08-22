module Evergreen.V51.Authentication exposing (..)

import Dict
import Evergreen.V51.Credentials
import Evergreen.V51.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V51.User.User
    , credentials : Evergreen.V51.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
