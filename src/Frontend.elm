module Frontend exposing (..)

import Authentication
import Browser exposing (UrlRequest(..))
import Browser.Events
import Browser.Navigation as Nav
import Data
import Frontend.Cmd
import Frontend.Update
import Html exposing (Html)
import Lamdera exposing (sendToBackend)
import List.Extra
import Random
import Random.List
import Time
import Token
import Types exposing (..)
import Url exposing (Url)
import Util
import View.Main


type alias Model =
    FrontendModel


app =
    Lamdera.frontend
        { init = init
        , onUrlRequest = UrlClicked
        , onUrlChange = UrlChanged
        , update = update
        , updateFromBackend = updateFromBackend
        , subscriptions = subscriptions
        , view = view
        }


subscriptions model =
    Sub.batch
        [ Browser.Events.onResize (\w h -> GotNewWindowDimensions w h)
        , Time.every 1000 FETick
        ]


init : Url.Url -> Nav.Key -> ( Model, Cmd FrontendMsg )
init url key =
    ( { key = key
      , url = url
      , message = "Welcome!"
      , currentTime = Time.millisToPosix 0
      , randomSeed = Random.initialSeed 1234
      , appMode = EntryMode

      -- ADMIN
      , users = []

      -- UI
      , windowWidth = 600
      , windowHeight = 900
      , popupStatus = PopupClosed

      -- DATA
      , snippetText = ""
      , snippets = []
      , currentSnippet = Nothing
      , inputSnippetFilter = ""
      , viewMode = Collapsed

      -- USER
      , currentUser = Nothing
      , inputUsername = ""
      , inputPassword = ""
      }
    , Cmd.batch [ Frontend.Cmd.setupWindow, Frontend.Cmd.getRandomNumberFE ]
    )


update : FrontendMsg -> Model -> ( Model, Cmd FrontendMsg )
update msg model =
    case msg of
        UrlClicked urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model, Cmd.none )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UrlChanged url ->
            ( { model | url = url }, Cmd.none )

        FETick time ->
            ( { model | currentTime = time }, Cmd.none )

        GotAtomsphericRandomNumberFE result ->
            case result of
                Ok str ->
                    case String.toInt (String.trim str) of
                        Nothing ->
                            ( { model | message = "Failed to get atmospheric random number" }, Cmd.none )

                        Just rn ->
                            let
                                newRandomSeed =
                                    Random.initialSeed rn
                            in
                            ( { model
                                | randomSeed = newRandomSeed
                              }
                            , Cmd.none
                            )

                Err _ ->
                    ( model, Cmd.none )

        -- UI
        GotNewWindowDimensions w h ->
            ( { model | windowWidth = w, windowHeight = h }, Cmd.none )

        ChangePopupStatus status ->
            ( { model | popupStatus = status }, Cmd.none )

        GotViewport vp ->
            Frontend.Update.updateWithViewport vp model

        NoOpFrontendMsg ->
            ( model, Cmd.none )

        -- USER
        SignIn ->
            if String.length model.inputPassword >= 8 then
                ( model
                , sendToBackend (SignInOrSignUp model.inputUsername (Authentication.encryptForTransit model.inputPassword))
                )

            else
                ( { model | message = "Password must be at least 8 letters long." }, Cmd.none )

        InputUsername str ->
            ( { model | inputUsername = str }, Cmd.none )

        InputPassword str ->
            ( { model | inputPassword = str }, Cmd.none )

        SignOut ->
            ( { model
                | currentUser = Nothing
                , message = "Signed out"
                , inputUsername = ""
                , inputPassword = ""
                , snippetText = ""
                , snippets = []
              }
            , Cmd.none
            )

        -- DATA
        InputSnippet str ->
            ( { model | snippetText = str }, Cmd.none )

        InputSnippetFilter str ->
            ( { model | inputSnippetFilter = str }, Cmd.none )

        ModificationOrder ->
            ( { model | snippets = List.sortBy (\snip -> -(Time.posixToMillis snip.modificationData)) model.snippets }, Cmd.none )

        RandomOrder ->
            let
                { token, seed } =
                    Token.get model.randomSeed
            in
            ( { model | randomSeed = seed }, Random.generate RandomizedOrder (Random.List.shuffle model.snippets) )

        RandomizedOrder snippets_ ->
            ( { model | snippets = snippets_ }, Cmd.none )

        Save ->
            case model.currentUser of
                Nothing ->
                    ( model, Cmd.none )

                Just user ->
                    case model.appMode of
                        EntryMode ->
                            let
                                { token, seed } =
                                    Token.get model.randomSeed

                                snippet =
                                    Data.make user.username model.currentTime token model.snippetText
                            in
                            ( { model
                                | snippets = snippet :: model.snippets
                                , randomSeed = seed
                                , currentSnippet = Nothing
                                , snippetText = ""
                              }
                            , sendToBackend (SaveDatum user.username snippet)
                            )

                        EditMode ->
                            case model.currentSnippet of
                                Nothing ->
                                    ( model, Cmd.none )

                                Just snippet ->
                                    let
                                        newSnippet =
                                            { snippet
                                                | content = model.snippetText |> Data.fixUrls
                                                , modificationData = model.currentTime
                                            }

                                        newSnippets =
                                            List.Extra.setIf (\snip -> snip.id == newSnippet.id) newSnippet model.snippets
                                    in
                                    ( { model
                                        | snippets = newSnippets
                                        , appMode = EntryMode
                                        , currentSnippet = Nothing
                                        , snippetText = ""
                                      }
                                    , sendToBackend (UpdateDatum user.username newSnippet)
                                    )

        Delete ->
            case model.currentSnippet of
                Nothing ->
                    ( model, Cmd.none )

                Just snippet ->
                    ( { model
                        | currentSnippet = Nothing
                        , snippetText = ""
                        , appMode = EntryMode
                        , snippets = List.filter (\snip -> snip.id /= snippet.id) model.snippets
                      }
                    , sendToBackend (DeleteSnippetFromStore snippet.username snippet.id)
                    )

        EditItem datum ->
            ( { model
                | message = "Editing " ++ datum.id
                , currentSnippet = Just datum
                , snippetText = datum.content
                , appMode = EditMode
              }
            , Cmd.none
            )

        ExpandContractItem datum ->
            let
                toggleViewMode mode =
                    case mode of
                        Expanded ->
                            Collapsed

                        Collapsed ->
                            Expanded
            in
            ( { model
                | currentSnippet = Just datum
                , viewMode = toggleViewMode model.viewMode
              }
            , Cmd.none
            )

        MarkdownMsg _ ->
            ( model, Cmd.none )

        -- ADMIN
        AdminRunTask ->
            ( model, sendToBackend RunTask )

        GetUsers ->
            ( model, sendToBackend SendUsers )


updateFromBackend : ToFrontend -> Model -> ( Model, Cmd FrontendMsg )
updateFromBackend msg model =
    case msg of
        NoOpToFrontend ->
            ( model, Cmd.none )

        -- ADMIN
        GotUsers users ->
            ( { model | users = users }, Cmd.none )

        -- DATA
        GotUserData dataList ->
            ( { model | snippets = dataList }, Cmd.none )

        -- USER
        SendUser user ->
            ( { model | currentUser = Just user }, Cmd.none )

        SendMessage message ->
            ( { model | message = message }, Cmd.none )


view : Model -> { title : String, body : List (Html.Html FrontendMsg) }
view model =
    { title = ""
    , body =
        [ View.Main.view model ]
    }
