module Evergreen.V3.Types exposing (..)

import Browser
import Browser.Dom
import Browser.Navigation
import Evergreen.V3.Authentication
import Evergreen.V3.Data
import Evergreen.V3.User
import Http
import Markdown.Render
import Random
import Time
import Url


type AppMode
    = EntryMode
    | EditMode


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
    , users : List Evergreen.V3.User.User
    , currentUser : Maybe Evergreen.V3.User.User
    , inputUsername : String
    , inputPassword : String
    , snippetText : String
    , snippets : List Evergreen.V3.Data.Datum
    , currentSnippet : Maybe Evergreen.V3.Data.Datum
    , windowWidth : Int
    , windowHeight : Int
    , popupStatus : PopupStatus
    }


type alias BackendModel =
    { message : String
    , randomSeed : Random.Seed
    , randomAtmosphericInt : Maybe Int
    , currentTime : Time.Posix
    , dataDict : Evergreen.V3.Data.DataDict
    , authenticationDict : Evergreen.V3.Authentication.AuthenticationDict
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
    | Save
    | MarkdownMsg Markdown.Render.MarkdownMsg
    | EditItem Evergreen.V3.Data.Datum
    | AdminRunTask
    | GetUsers


type alias Username =
    String


type ToBackend
    = NoOpToBackend
    | RunTask
    | SendUsers
    | SaveDatum Username Evergreen.V3.Data.Datum
    | SendUserData Username
    | UpdateDatum Username Evergreen.V3.Data.Datum
    | SignInOrSignUp String String


type BackendMsg
    = NoOpBackendMsg
    | GotAtomsphericRandomNumber (Result Http.Error String)
    | Tick Time.Posix


type ToFrontend
    = NoOpToFrontend
    | SendMessage String
    | GotUsers (List Evergreen.V3.User.User)
    | GotUserData (List Evergreen.V3.Data.Datum)
    | SendUser Evergreen.V3.User.User
