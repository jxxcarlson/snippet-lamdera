module Evergreen.V43.Authentication exposing (..)

import Dict
import Evergreen.V43.Credentials
import Evergreen.V43.User


type alias Username =
    String


type alias UserData =
    { user : Evergreen.V43.User.User
    , credentials : Evergreen.V43.Credentials.Credentials
    }


type alias AuthenticationDict =
    Dict.Dict Username UserData
