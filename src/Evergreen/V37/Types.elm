module Evergreen.V37.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Evergreen.V37.Authentication
import Evergreen.V37.Data
import Evergreen.V37.User
import Http
import Markdown.Render
import Random
import Time
import Url


type AppMode
    = EntryMode
    | EditMode


type SnippetViewMode
    = SnippetExpanded
    | SnippetCollapsed


type PopupWindow
    = AdminPopup


type PopupStatus
    = PopupOpen PopupWindow
    | PopupClosed


type ViewMode
    = SmallView
    | LargeView


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , url : Url.Url
    , message : String
    , currentTime : Time.Posix
    , randomSeed : Random.Seed
    , appMode : AppMode
    , users : List Evergreen.V37.User.User
    , currentUser : Maybe Evergreen.V37.User.User
    , inputUsername : String
    , inputPassword : String
    , snippetText : String
    , snippets : List Evergreen.V37.Data.Datum
    , currentSnippet : Maybe Evergreen.V37.Data.Datum
    , inputSnippetFilter : String
    , snippetViewMode : SnippetViewMode
    , windowWidth : Int
    , windowHeight : Int
    , popupStatus : PopupStatus
    , viewMode : ViewMode
    }


type alias BackendModel =
    { message : String
    , randomSeed : Random.Seed
    , randomAtmosphericInt : Maybe Int
    , currentTime : Time.Posix
    , dataDict : Evergreen.V37.Data.DataDict
    , authenticationDict : Evergreen.V37.Authentication.AuthenticationDict
    }


type FrontendMsg
    = UrlClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotViewport Browser.Dom.Viewport
    | NoOpFrontendMsg
    | FETick Time.Posix
    | GotAtomsphericRandomNumberFE (Result Http.Error String)
    | GotNewWindowDimensions Int Int
    | ChangePopupStatus PopupStatus
    | SignIn
    | SignOut
    | InputUsername String
    | InputPassword String
    | InputSnippet String
    | SearchBy String
    | StarSnippet
    | Save
    | Fetch
    | Cancel
    | EditItem AppMode Evergreen.V37.Data.Datum
    | Delete
    | InputSnippetFilter String
    | ExpandContractItem Evergreen.V37.Data.Datum
    | RandomOrder
    | ModificationOrder
    | RandomizedOrder (List Evergreen.V37.Data.Datum)
    | MarkdownMsg Markdown.Render.MarkdownMsg
    | ExportYaml
    | ExpandContractView
    | AdminRunTask
    | GetUsers


type alias Username =
    String


type ToBackend
    = NoOpToBackend
    | RunTask
    | SendUsers
    | SaveDatum Username Evergreen.V37.Data.Datum
    | SendUserData Username
    | UpdateDatum Username Evergreen.V37.Data.Datum
    | DeleteSnippetFromStore Username Evergreen.V37.Data.DataId
    | SignInOrSignUp String String


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendMessage String
    | GotUsers (List Evergreen.V37.User.User)
    | GotUserData (List Evergreen.V37.Data.Datum)
    | SendUser Evergreen.V37.User.User
