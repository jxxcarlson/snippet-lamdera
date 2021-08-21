module View.Button exposing
    ( adminPopup
    , cancel
    , delete
    , editItem
    , expandCollapse
    , expandCollapseView
    , exportYaml
    , fetch
    , getUsers
    , linkTemplate
    , new
    , randomize
    , runTask
    , save
    , searchByStarred
    , signIn
    , signOut
    , sortByModificationDate
    , starSnippet
    )

import Config
import Element as E exposing (Element)
import Element.Background as Background
import Element.Font as Font
import Element.Input as Input
import Types exposing (..)
import View.Color as Color
import View.Style
import View.Utility



-- TEMPLATES


buttonTemplate : List (E.Attribute msg) -> msg -> String -> Element msg
buttonTemplate attrList msg label_ =
    E.row ([ View.Style.bgGray 0.2, E.pointer, E.mouseDown [ Background.color Color.darkRed ] ] ++ attrList)
        [ Input.button View.Style.buttonStyle
            { onPress = Just msg
            , label = E.el [ E.centerX, E.centerY, Font.size 14 ] (E.text label_)
            }
        ]


linkTemplate : msg -> E.Color -> String -> Element msg
linkTemplate msg fontColor label_ =
    E.row [ E.pointer, E.mouseDown [ Background.color Color.paleBlue ] ]
        [ Input.button linkStyle
            { onPress = Just msg
            , label = E.el [ E.centerX, E.centerY, Font.size 14, Font.color fontColor ] (E.text label_)
            }
        ]


linkStyle =
    [ Font.color (E.rgb255 255 255 255)
    , E.paddingXY 8 2
    ]



-- USER


signOut username =
    buttonTemplate [] SignOut ("Sign out " ++ username)



-- USER


signIn : Element FrontendMsg
signIn =
    buttonTemplate [] SignIn "Sign in | Sign up"



-- DATA


randomize : Element FrontendMsg
randomize =
    buttonTemplate [ View.Utility.elementAttribute "title" "Randomize snippets" ] RandomOrder "R"


sortByModificationDate =
    buttonTemplate [ View.Utility.elementAttribute "title" "Sort by date modified" ] ModificationOrder "M"


searchByStarred : Element FrontendMsg
searchByStarred =
    buttonTemplate [ View.Utility.elementAttribute "title" "Search by ★" ] (SearchBy "★") "★"


starSnippet : Element FrontendMsg
starSnippet =
    buttonTemplate [ View.Utility.elementAttribute "title" "Star snippet" ] StarSnippet "★"


save : Element FrontendMsg
save =
    buttonTemplate [] Save "Save"


fetch : Element FrontendMsg
fetch =
    buttonTemplate [] Fetch "Fetch"


cancel : Element FrontendMsg
cancel =
    buttonTemplate [] Close "Close"


new : Element FrontendMsg
new =
    buttonTemplate [] New "New"


delete : Element FrontendMsg
delete =
    buttonTemplate [] Delete "Delete"


exportYaml : Element FrontendMsg
exportYaml =
    buttonTemplate [] ExportYaml "Export"


editItem appMode datum =
    buttonTemplate
        [ E.width (E.px 20)
        , E.height (E.px 20)
        , Background.color Color.medBlue
        , Font.color Color.palePink
        , View.Utility.elementAttribute "title" "Click to edit or display this item"
        ]
        (EditItem datum)
        ""


expandCollapse datum =
    buttonTemplate
        [ E.width (E.px 20)
        , E.height (E.px 20)
        , Background.color Color.lightBlue2
        , Font.color Color.palePink
        , View.Utility.elementAttribute "title" "Click to expand/collapse item"
        ]
        (ExpandContractItem datum)
        ""


expandCollapseView viewMode =
    case viewMode of
        SmallView ->
            buttonTemplate
                [ E.width (E.px 10)
                , E.height (E.px 20)
                , Background.color Color.lightBlue2
                , Font.color Color.palePink
                , View.Utility.elementAttribute "title" "Click for expanded view"
                ]
                ExpandContractView
                ""

        LargeView ->
            buttonTemplate
                [ E.width (E.px 40)
                , E.height (E.px 20)
                , Background.color Color.lightBlue2
                , Font.color Color.palePink
                , View.Utility.elementAttribute "title" "Click for small view"
                ]
                ExpandContractView
                ""



-- ADMIN


runTask : Element FrontendMsg
runTask =
    buttonTemplate [] AdminRunTask "Run Task"


adminPopup : FrontendModel -> Element FrontendMsg
adminPopup model =
    let
        nextState : PopupStatus
        nextState =
            case model.popupStatus of
                PopupClosed ->
                    PopupOpen AdminPopup

                PopupOpen AdminPopup ->
                    PopupClosed

        isVisible =
            Maybe.map .username model.currentUser == Just Config.administrator
    in
    View.Utility.showIf isVisible <| buttonTemplate [] (ChangePopupStatus nextState) "Admin"


getUsers =
    buttonTemplate [] GetUsers "Get Users"
