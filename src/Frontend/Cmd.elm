module Frontend.Cmd exposing (setupWindow)

import Browser.Dom as Dom
import Task
import Types exposing (FrontendModel, FrontendMsg(..), ToBackend(..))


setupWindow : Cmd FrontendMsg
setupWindow =
    Task.perform GotViewport Dom.getViewport
