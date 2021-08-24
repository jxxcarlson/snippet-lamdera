module Evergreen.V59.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Element
import Evergreen.V59.Authentication
import Evergreen.V59.Data
import Evergreen.V59.User
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
    , users : List Evergreen.V59.User.User
    , currentUser : Maybe Evergreen.V59.User.User
    , inputUsername : String
    , inputPassword : String
    , snippetText : String
    , snippets : List Evergreen.V59.Data.Datum
    , currentSnippet : Maybe Evergreen.V59.Data.Datum
    , inputSnippetFilter : String
    , snippetViewMode : SnippetViewMode
    , sortMode : SortMode
    , windowWidth : Int
    , windowHeight : Int
    , popupStatus : PopupStatus
    , viewMode : ViewMode
    , device : Element.DeviceClass
    }


type alias BackendModel =
    { message : String
    , randomSeed : Random.Seed
    , randomAtmosphericInt : Maybe Int
    , currentTime : Time.Posix
    , dataDict : Evergreen.V59.Data.DataDict
    , authenticationDict : Evergreen.V59.Authentication.AuthenticationDict
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
    | EditItem Evergreen.V59.Data.Datum
    | ViewContent Evergreen.V59.Data.Datum
    | Delete
    | InputSnippetFilter String
    | ExpandContractItem Evergreen.V59.Data.Datum
    | RandomOrder
    | ModificationOrder
    | AlphabeticOrder
    | RandomizedOrder (List Evergreen.V59.Data.Datum)
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
    | SaveDatum Username Evergreen.V59.Data.Datum
    | SendUserData Username
    | UpdateDatum Username Evergreen.V59.Data.Datum
    | DeleteSnippetFromStore Username Evergreen.V59.Data.DataId
    | SignInOrSignUp String String


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendMessage String
    | GotUsers (List Evergreen.V59.User.User)
    | GotUserData (List Evergreen.V59.Data.Datum)
    | SendUser Evergreen.V59.User.User
