module Evergreen.V43.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Evergreen.V43.Authentication
import Evergreen.V43.Data
import Evergreen.V43.User
import Http
import Markdown.Render
import Random
import Time
import Url


type AppMode
    = ViewMode
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
    , users : List Evergreen.V43.User.User
    , currentUser : Maybe Evergreen.V43.User.User
    , inputUsername : String
    , inputPassword : String
    , snippetText : String
    , snippets : List Evergreen.V43.Data.Datum
    , currentSnippet : Maybe Evergreen.V43.Data.Datum
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
    , dataDict : Evergreen.V43.Data.DataDict
    , authenticationDict : Evergreen.V43.Authentication.AuthenticationDict
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
    | New
    | Save
    | Fetch
    | Close
    | EditItem Evergreen.V43.Data.Datum
    | ViewContent Evergreen.V43.Data.Datum
    | Delete
    | InputSnippetFilter String
    | ExpandContractItem Evergreen.V43.Data.Datum
    | RandomOrder
    | ModificationOrder
    | RandomizedOrder (List Evergreen.V43.Data.Datum)
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
    | SaveDatum Username Evergreen.V43.Data.Datum
    | SendUserData Username
    | UpdateDatum Username Evergreen.V43.Data.Datum
    | DeleteSnippetFromStore Username Evergreen.V43.Data.DataId
    | SignInOrSignUp String String


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendMessage String
    | GotUsers (List Evergreen.V43.User.User)
    | GotUserData (List Evergreen.V43.Data.Datum)
    | SendUser Evergreen.V43.User.User
