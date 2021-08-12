module View.Main exposing (view)

import Data exposing (Datum)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Html exposing (Html)
import Markdown.Option
import Markdown.Render
import Time
import Types exposing (..)
import View.Button as Button
import View.Color as Color
import View.Input
import View.Popup
import View.Style
import View.Utility


type alias Model =
    FrontendModel


view : Model -> Html FrontendMsg
view model =
    E.layoutWith { options = [ E.focusStyle View.Utility.noFocus ] }
        [ View.Style.bgGray 0.2, E.clipX, E.clipY ]
        (mainColumn model)


mainColumn : Model -> Element FrontendMsg
mainColumn model =
    let
        filteredSnippets =
            Data.filter (String.trim model.inputSnippetFilter) model.snippets

        numberOfSnippets =
            String.fromInt (List.length model.snippets)

        numberOfFilteredSnippets =
            String.fromInt (List.length filteredSnippets)

        ratio =
            numberOfFilteredSnippets ++ "/" ++ numberOfSnippets
    in
    E.column (mainColumnStyle model)
        [ E.column [ E.spacing 12, E.width (E.px <| appWidth_ model), E.height (E.px (appHeight_ model)) ]
            [ title "Snippet Manager"
            , header model
            , E.column [ E.spacing 12 ]
                [ E.column [ E.spacing 12 ]
                    [ View.Input.snippetText model (appWidth_ model) model.snippetText
                    , E.row [ E.spacing 8, E.width (E.px (appWidth_ model)) ]
                        [ View.Input.snippetFilter model (appWidth_ model - 190)
                        , Button.searchByStarred
                        , Button.sortByModificationDate
                        , Button.randomize
                        , E.el [ Font.color Color.white, Font.size 14, E.alignRight ] (E.text ratio)
                        ]
                    , viewSnippets model filteredSnippets
                    ]
                ]
            , footer model
            ]
        ]



-- (List.map (viewSnippet model)


viewSnippets : Model -> List Datum -> Element FrontendMsg
viewSnippets model filteredSnippets =
    E.column
        [ E.spacing 12
        , E.paddingXY 0 0
        , E.scrollbarY
        , E.width (E.px <| appWidth_ model)
        , E.height (E.px (appHeight_ model - 270))
        , Background.color Color.darkBlue
        ]
        (List.map (viewSnippet model) filteredSnippets)


viewSnippet : Model -> Datum -> Element FrontendMsg
viewSnippet model datum =
    let
        predicate =
            Just datum.id == Maybe.map .id model.currentSnippet && model.viewMode == Expanded

        h =
            if predicate then
                300

            else
                60

        scroll =
            if predicate then
                E.scrollbarY

            else
                E.clipY
    in
    E.row
        [ Font.size 14
        , E.spacing 12
        , E.paddingEach { top = 10, left = 10, right = 10, bottom = 0 }
        , E.width (E.px <| appWidth_ model)
        , Background.color Color.veryPaleBlue
        ]
        [ View.Utility.cssNode "markdown.css"
        , E.column [ E.alignTop, E.spacing 8 ] [ E.el [] (Button.editItem datum), Button.expandCollapse datum ]
        , E.column
            [ E.width (E.px <| appWidth_ model)
            , E.height (E.px h)
            , scroll
            , E.alignTop
            , E.moveUp 16

            -- , Background.color Color.white
            , View.Utility.elementAttribute "line-height" "1.5"
            ]
            [ Markdown.Render.toHtml Markdown.Option.ExtendedMath datum.content
                |> Html.map MarkdownMsg
                |> E.html
            ]
        ]


footer model =
    E.row
        [ E.spacing 12
        , E.paddingXY 0 8
        , E.height (E.px 25)
        , E.width (E.px <| appWidth_ model)
        , Font.size 14
        , E.inFront (View.Popup.admin model)
        ]
        [ Button.adminPopup model
        , Button.exportYaml
        , messageRow model
        ]


messageRow model =
    E.row
        [ E.width E.fill
        , E.height (E.px 30)
        , E.paddingXY 8 4
        , View.Style.bgGray 0.1
        , View.Style.fgGray 1.0
        ]
        [ E.text model.message ]


footerButtons model =
    E.row [ E.width (E.px (panelWidth_ model)), E.spacing 12 ] []


header model =
    case model.currentUser of
        Nothing ->
            notSignedInHeader model

        Just user ->
            signedInHeader model user


notSignedInHeader model =
    E.row
        [ E.spacing 12
        , Font.size 14
        ]
        [ Button.signIn
        , View.Input.usernameInput model
        , View.Input.passwordInput model
        , E.el [ E.height (E.px 31), E.paddingXY 12 3, Background.color Color.paleBlue ]
            (E.el [ E.centerY ] (E.text model.message))
        ]


signedInHeader model user =
    E.row [ E.spacing 12 ]
        [ Button.signOut user.username
        , Button.save
        , Button.delete
        ]


docsInfo model n =
    let
        total =
            List.length model.documents
    in
    E.el
        [ E.height (E.px 30)
        , E.width (E.px docListWidth)
        , Font.size 16
        , E.paddingXY 12 7
        , Background.color Color.paleViolet
        , Font.color Color.lightBlue
        ]
        (E.text <| "filtered/fetched = " ++ String.fromInt n ++ "/" ++ String.fromInt total)


docList_ : Model -> List (Element FrontendMsg) -> Element FrontendMsg
docList_ model filteredDocs =
    E.column
        [ View.Style.bgGray 0.85
        , E.height (E.px (panelHeight_ model - searchDocPaneHeight))
        , E.spacing 4
        , E.width (E.px docListWidth)
        , E.paddingXY 8 12
        , Background.color Color.paleViolet
        , E.scrollbarY
        ]
        filteredDocs


viewDummy : Model -> Element FrontendMsg
viewDummy model =
    E.column
        [ E.paddingEach { left = 24, right = 24, top = 12, bottom = 96 }
        , Background.color Color.veryPaleBlue
        , E.width (E.px (panelWidth_ model))
        , E.height (E.px (panelHeight_ model))
        , E.centerX
        , Font.size 14
        , E.alignTop
        ]
        []



-- DIMENSIONS


searchDocPaneHeight =
    70


panelWidth_ model =
    min 600 ((model.windowWidth - 100 - docListWidth) // 2)


docListWidth =
    220


appHeight_ model =
    model.windowHeight - 100


panelHeight_ model =
    appHeight_ model - 110


appWidth_ model =
    min 500 model.windowWidth


mainColumnStyle model =
    [ E.centerX
    , E.centerY
    , View.Style.bgGray 0.5
    , E.paddingXY 20 20
    , E.width (E.px (appWidth_ model + 40))
    , E.height (E.px (appHeight_ model + 40))
    ]


title : String -> Element msg
title str =
    E.row [ E.paddingEach { top = 0, bottom = 8, left = 0, right = 0 }, E.centerX, View.Style.fgGray 0.9 ] [ E.text str ]
