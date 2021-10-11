module Evergreen.V77.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Element
import Evergreen.V77.Authentication
import Evergreen.V77.Data
import Evergreen.V77.User
import File exposing (File)
import Http
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
    , users : List Evergreen.V77.User.User
    , currentUser : Maybe Evergreen.V77.User.User
    , inputUsername : String
    , inputPassword : String
    , snippetText : String
    , snippets : List Evergreen.V77.Data.Datum
    , currentSnippet : Maybe Evergreen.V77.Data.Datum
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
    , dataDict : Evergreen.V77.Data.DataDict
    , authenticationDict : Evergreen.V77.Authentication.AuthenticationDict
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
    | SetViewPortForElement (Result Browser.Dom.Error ( Browser.Dom.Element, Browser.Dom.Viewport ))
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
    | EditItem Evergreen.V77.Data.Datum
    | ViewContent Evergreen.V77.Data.Datum
    | Delete
    | InputSnippetFilter String
    | ExpandContractItem Evergreen.V77.Data.Datum
    | RandomOrder
    | ModificationOrder
    | AlphabeticOrder
    | RandomizedOrder (List Evergreen.V77.Data.Datum)
    | ExportJson
    | JsonRequested
    | JsonSelected File
    | JsonLoaded String
    | ExpandContractView
    | AdminRunTask
    | GetUsers


type alias Username =
    String


type ToBackend
    = NoOpToBackend
    | RunTask
    | SendUsers
    | SaveDatum Username Evergreen.V77.Data.Datum
    | SendUserData Username
    | UpdateDatum Username Evergreen.V77.Data.Datum
    | DeleteSnippetFromStore Username Evergreen.V77.Data.DataId
    | SignInOrSignUp String String


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendMessage String
    | GotUsers (List Evergreen.V77.User.User)
    | GotUserData (List Evergreen.V77.Data.Datum)
    | SendUser Evergreen.V77.User.User
