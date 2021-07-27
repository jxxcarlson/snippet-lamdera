module Frontend.Update exposing (exportSnippets, updateWithViewport)

import File.Download as Download
import Lamdera exposing (sendToBackend)
import List.Extra
import Types exposing (..)
import Yaml


updateWithViewport vp model =
    let
        w =
            round vp.viewport.width

        h =
            round vp.viewport.height
    in
    ( { model
        | windowWidth = w
        , windowHeight = h
      }
    , Cmd.none
    )


exportSnippets : FrontendModel -> Cmd msg
exportSnippets model =
    Download.string "snippets.yaml" "text/yaml" (Yaml.encodeData model.snippets)
