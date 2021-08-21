module View.Large exposing (..)

import Data exposing (Datum)
import Element as E exposing (Element)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Html exposing (Html)
import Markdown.Option
import Markdown.Render
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
    E.column (mainColumnStyle model)
        [ E.column [ E.spacing 12, E.width (appWidth_ 0 model), E.height (E.px (appHeight model)) ]
            [ E.row [ E.width (appWidth_ 0 model) ] [ title "Snippet Manager", E.el [ E.alignRight ] (Button.expandCollapseView model.viewMode) ]
            , header model
            , E.row [ E.spacing 12 ] [ lhs model, rhs model ]
            , footer model
            ]
        ]


lhs model =
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
    E.column [ E.spacing 12, E.width (panelWidth 0 model) ]
        [ E.column [ E.spacing 12 ]
            [ E.row [ E.spacing 8, E.width (panelWidth 0 model) ]
                [ View.Input.snippetFilter model (panelWidth_ -230 model)
                , Button.searchByStarred
                , Button.sortByModificationDate
                , Button.randomize
                , E.el [ Font.color Color.white, Font.size 14, E.alignRight ] (E.text ratio)
                ]
            , viewSnippets model filteredSnippets
            ]
        ]


rhs model =
    E.column [ E.spacing 12, E.width (panelWidth 0 model) ]
        [ E.column [ E.spacing 12 ]
            [ View.Utility.showIf (model.appMode == EditMode) (rhsHeader model)
            , View.Utility.showIf (model.appMode /= EditMode) (rhsHeader model)
            , View.Input.snippetText model (panelWidth_ 0 model) (appHeight model - 154) model.snippetText
            ]
        ]


viewSnippets : Model -> List Datum -> Element FrontendMsg
viewSnippets model filteredSnippets =
    E.column
        [ E.paddingXY 0 0
        , E.scrollbarY
        , E.width (panelWidth 0 model)
        , E.height (E.px (appHeight model - 155))
        , Background.color Color.blueGray
        ]
        (List.map (viewSnippet model) filteredSnippets)


viewSnippet : Model -> Datum -> Element FrontendMsg
viewSnippet model datum =
    E.row
        [ Font.size 14
        , Border.widthEach { bottom = 2, top = 0, left = 0, right = 0 }
        , Border.color Color.darkBlue
        , E.height (E.px 36)
        , E.width (appWidth_ 0 model)
        , Background.color Color.veryPaleBlue
        ]
        [ View.Utility.cssNode "markdown.css"
        , E.row [ E.spacing 12, E.paddingEach { left = 6, right = 0, top = 0, bottom = 0 } ]
            [ E.el [] (Button.editItem model.appMode datum)
            , E.column
                [ E.width (appWidth_ 0 model)
                , E.clipY
                , E.height (E.px 36)
                , E.moveUp 3
                , View.Utility.elementAttribute "line-height" "1.5"
                ]
                [ Markdown.Render.toHtml Markdown.Option.ExtendedMath datum.content
                    |> Html.map MarkdownMsg
                    |> E.html
                ]
            ]
        ]


footer model =
    E.row
        [ E.spacing 12
        , E.paddingXY 0 8
        , E.height (E.px 25)
        , E.width (appWidth_ 0 model)
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
    E.row [ E.width (panelWidth 0 model), E.spacing 12 ] []


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
        , Button.fetch
        ]


rhsHeader model =
    E.row [ E.spacing 12 ]
        [ Button.starSnippet
        , Button.save
        , Button.cancel
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


viewDummy : Model -> Element FrontendMsg
viewDummy model =
    E.column
        [ E.paddingEach { left = 24, right = 24, top = 12, bottom = 96 }
        , Background.color Color.veryPaleBlue
        , E.width (panelWidth 0 model)
        , E.height (E.px (panelHeight_ model))
        , E.centerX
        , Font.size 14
        , E.alignTop
        ]
        []



-- DIMENSIONS


searchDocPaneHeight =
    70


docListWidth =
    220


appHeight : { a | windowHeight : number } -> number
appHeight model =
    model.windowHeight - 100


panelHeight_ model =
    appHeight model - 110


appWidth_ : Int -> { a | windowWidth : Int } -> E.Length
appWidth_ delta model =
    E.px (min 1110 model.windowWidth + delta)


panelWidth : Int -> { a | windowWidth : Int } -> E.Length
panelWidth delta model =
    E.px (panelWidth_ delta model)


panelWidth_ : Int -> { a | windowWidth : Int } -> Int
panelWidth_ delta model =
    round (min 549 (0.48 * toFloat model.windowWidth)) + delta


mainColumnStyle model =
    [ E.centerX
    , E.centerY
    , View.Style.bgGray 0.5
    , E.paddingXY 20 20
    , E.width (appWidth_ 40 model)
    , E.height (E.px (appHeight model + 40))
    ]


title : String -> Element msg
title str =
    E.row [ E.paddingEach { top = 0, bottom = 8, left = 0, right = 0 }, E.centerX, View.Style.fgGray 0.9 ] [ E.text str ]
