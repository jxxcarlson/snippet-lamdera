module Evergreen.V32.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Evergreen.V32.Authentication
import Evergreen.V32.Data
import Evergreen.V32.User
import Http
import Markdown.Render
import Random
import Time
import Url


type AppMode
    = EntryMode
    | EditMode


type ViewMode
    = Expanded
    | Collapsed


type PopupWindow
    = AdminPopup


type PopupStatus
    = PopupOpen PopupWindow
    | PopupClosed


type alias FrontendModel =
    { key : Browser.Navigation.Key
    , url : Url.Url
    , message : String
    , currentTime : Time.Posix
    , randomSeed : Random.Seed
    , appMode : AppMode
    , users : List Evergreen.V32.User.User
    , currentUser : Maybe Evergreen.V32.User.User
    , inputUsername : String
    , inputPassword : String
    , snippetText : String
    , snippets : List Evergreen.V32.Data.Datum
    , currentSnippet : Maybe Evergreen.V32.Data.Datum
    , inputSnippetFilter : String
    , viewMode : ViewMode
    , windowWidth : Int
    , windowHeight : Int
    , popupStatus : PopupStatus
    }


type alias BackendModel =
    { message : String
    , randomSeed : Random.Seed
    , randomAtmosphericInt : Maybe Int
    , currentTime : Time.Posix
    , dataDict : Evergreen.V32.Data.DataDict
    , authenticationDict : Evergreen.V32.Authentication.AuthenticationDict
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
    | EditItem Evergreen.V32.Data.Datum
    | Delete
    | InputSnippetFilter String
    | ExpandContractItem Evergreen.V32.Data.Datum
    | RandomOrder
    | ModificationOrder
    | RandomizedOrder (List Evergreen.V32.Data.Datum)
    | MarkdownMsg Markdown.Render.MarkdownMsg
    | ExportYaml
    | AdminRunTask
    | GetUsers


type alias Username =
    String


type ToBackend
    = NoOpToBackend
    | RunTask
    | SendUsers
    | SaveDatum Username Evergreen.V32.Data.Datum
    | SendUserData Username
    | UpdateDatum Username Evergreen.V32.Data.Datum
    | DeleteSnippetFromStore Username Evergreen.V32.Data.DataId
    | SignInOrSignUp String String


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendMessage String
    | GotUsers (List Evergreen.V32.User.User)
    | GotUserData (List Evergreen.V32.Data.Datum)
    | SendUser Evergreen.V32.User.User
