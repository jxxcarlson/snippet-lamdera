module User exposing (User, defaultUser, guest)


type alias User =
    { username : String
    , id : String
    , realname : String
    , email : String
    }


defaultUser =
    { username = "jxxcarlson"
    , id = "ekvdo-oaeaw"
    , realname = "James Carlson"
    , email = "jxxcarlson@gmail.com"
    }


guest =
    { username = "guest"
    , id = "ekvdo-tseug"
    , realname = "Guest"
    , email = "guest@nonexistent.com"
    }
