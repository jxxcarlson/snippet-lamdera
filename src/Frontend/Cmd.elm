module Frontend.Cmd exposing (getRandomNumberFE, setupWindow)

import Browser.Dom as Dom
import Http
import Task
import Types exposing (FrontendModel, FrontendMsg(..), ToBackend(..))


setupWindow : Cmd FrontendMsg
setupWindow =
    Task.perform GotViewport Dom.getViewport


getRandomNumberFE : Cmd FrontendMsg
getRandomNumberFE =
    Http.get
        { url = randomNumberUrl 9
        , expect = Http.expectString GotAtomsphericRandomNumberFE
        }


{-| maxDigits < 10
-}
randomNumberUrl : Int -> String
randomNumberUrl maxDigits =
    let
        maxNumber =
            10 ^ maxDigits

        prefix =
            "https://www.random.org/integers/?num=1&min=1&max="

        suffix =
            "&col=1&base=10&format=plain&rnd=new"
    in
    prefix ++ String.fromInt maxNumber ++ suffix
