module Evergreen.V58.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Evergreen.V58.Authentication
import Evergreen.V58.Data
import Evergreen.V58.User
import Http
import Markdown.Render
import Random
import Time
import Url


type AppMode
    = ViewMode
    | NewSnippetMode
    | EditMode


type SnippetViewMode
    = SnippetExpanded
    | SnippetCollapsed


type SortMode
    = SortByDate
    | SortAlphabetically
    | SortAtRandom


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
    , users : List Evergreen.V58.User.User
    , currentUser : Maybe Evergreen.V58.User.User
    , inputUsername : String
    , inputPassword : String
    , snippetText : String
    , snippets : List Evergreen.V58.Data.Datum
    , currentSnippet : Maybe Evergreen.V58.Data.Datum
    , inputSnippetFilter : String
    , snippetViewMode : SnippetViewMode
    , sortMode : SortMode
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
    , dataDict : Evergreen.V58.Data.DataDict
    , authenticationDict : Evergreen.V58.Authentication.AuthenticationDict
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
    | Help
    | Close
    | EditItem Evergreen.V58.Data.Datum
    | ViewContent Evergreen.V58.Data.Datum
    | Delete
    | InputSnippetFilter String
    | ExpandContractItem Evergreen.V58.Data.Datum
    | RandomOrder
    | ModificationOrder
    | AlphabeticOrder
    | RandomizedOrder (List Evergreen.V58.Data.Datum)
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
    | SaveDatum Username Evergreen.V58.Data.Datum
    | SendUserData Username
    | UpdateDatum Username Evergreen.V58.Data.Datum
    | DeleteSnippetFromStore Username Evergreen.V58.Data.DataId
    | SignInOrSignUp String String


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendMessage String
    | GotUsers (List Evergreen.V58.User.User)
    | GotUserData (List Evergreen.V58.Data.Datum)
    | SendUser Evergreen.V58.User.User
