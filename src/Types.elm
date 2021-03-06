module Types exposing (..)

import Authentication exposing (AuthenticationDict)
import Browser exposing (UrlRequest)
import Browser.Dom as Dom
import Browser.Navigation exposing (Key)
import Data exposing (DataDict, DataId, Datum)
import Element
import File exposing (File)
import Http
import Random
import Time
import Url exposing (Url)
import User exposing (User)


type alias Username =
    String


type alias FrontendModel =
    { key : Key
    , url : Url
    , message : String
    , currentTime : Time.Posix
    , randomSeed : Random.Seed
    , appMode : AppMode

    -- ADMIN
    , users : List User

    -- USER
    , currentUser : Maybe User
    , inputUsername : String
    , inputPassword : String

    -- DATA
    , snippetText : String
    , snippets : List Datum
    , currentSnippet : Maybe Datum
    , inputSnippetFilter : String
    , snippetViewMode : SnippetViewMode
    , sortMode : SortMode

    -- UI
    , windowWidth : Int
    , windowHeight : Int
    , popupStatus : PopupStatus
    , viewMode : ViewMode
    , device : Element.DeviceClass
    }


type SortMode
    = SortByDate
    | SortAlphabetically
    | SortAtRandom


type ViewMode
    = SmallView
    | LargeView


type SnippetViewMode
    = SnippetExpanded
    | SnippetCollapsed


type AppMode
    = ViewMode
    | NewSnippetMode
    | EditMode


type PopupWindow
    = AdminPopup


type PopupStatus
    = PopupOpen PopupWindow
    | PopupClosed


type alias BackendModel =
    { message : String

    -- SYSTEM
    , randomSeed : Random.Seed
    , randomAtmosphericInt : Maybe Int
    , currentTime : Time.Posix

    -- DATA
    , dataDict : DataDict

    -- USER
    , authenticationDict : AuthenticationDict
    }


type FrontendMsg
    = UrlClicked UrlRequest
    | UrlChanged Url
    | GotViewport Dom.Viewport
    | NoOpFrontendMsg
    | FETick Time.Posix
    | GotAtomsphericRandomNumberFE (Result Http.Error String)
      -- UI
    | GotNewWindowDimensions Int Int
    | ChangePopupStatus PopupStatus
    | SetViewPortForElement (Result Dom.Error ( Dom.Element, Dom.Viewport ))
      -- USER
    | SignIn
    | SignOut
    | InputUsername String
    | InputPassword String
      -- DATA
    | InputSnippet String
    | SearchBy String
    | StarSnippet
    | New
    | Save
    | Fetch
    | Help
    | Close
    | EditItem Datum
    | ViewContent Datum
    | Delete
    | InputSnippetFilter String
    | ExpandContractItem Datum
    | RandomOrder
    | ModificationOrder
    | AlphabeticOrder
    | RandomizedOrder (List Datum)
    | ExportJson
    | JsonRequested
    | JsonSelected File
    | JsonLoaded String
      -- UI
    | ExpandContractView
      -- ADMIN
    | AdminRunTask
    | GetUsers


type ToBackend
    = NoOpToBackend
      -- ADMIN
    | RunTask
    | SendUsers
      -- DATA
    | SaveDatum Username Datum
    | SendUserData Username
    | UpdateDatum Username Datum
    | DeleteSnippetFromStore Username DataId
      -- USER
    | SignInOrSignUp String String


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendMessage String
      -- ADMIN
    | GotUsers (List User)
      -- DATA
    | GotUserData (List Datum)
      -- USER
    | SendUser User


type ExtendedInteger
    = Finite Int
    | Infinity
