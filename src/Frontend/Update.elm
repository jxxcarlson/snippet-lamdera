module Frontend.Update exposing (exportSnippets, updateWithViewport)

import Element
import File.Download as Download
import Types exposing (..)
import Yaml


updateWithViewport vp model =
    let
        w =
            round vp.viewport.width

        h =
            round vp.viewport.height

        device =
            Element.classifyDevice { width = w, height = h }

        viewMode =
            case device.class of
                Element.Phone ->
                    SmallView

                _ ->
                    LargeView
    in
    ( { model
        | windowWidth = w
        , windowHeight = h
        , device = device.class
        , viewMode = viewMode
      }
    , Cmd.none
    )


exportSnippets : FrontendModel -> Cmd msg
exportSnippets model =
    Download.string "snippets.yaml" "text/yaml" (Yaml.encodeData model.snippets)
