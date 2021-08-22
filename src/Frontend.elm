module Frontend exposing (..)

import Authentication
import Browser exposing (UrlRequest(..))
import Browser.Events
import Browser.Navigation as Nav
import Data
import File.Download as Download
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
import View.Large
import View.Small


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
      , appMode = ViewMode

      -- ADMIN
      , users = []

      -- UI
      , windowWidth = 1200
      , windowHeight = 900
      , popupStatus = PopupClosed

      -- DATA
      , snippetText = ""
      , snippets = []
      , currentSnippet = Just Data.startupDocument
      , inputSnippetFilter = ""
      , snippetViewMode = SnippetCollapsed

      -- USER
      , currentUser = Nothing
      , inputUsername = ""
      , inputPassword = ""
      , viewMode = LargeView
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
                ( { model | currentSnippet = Just Data.signInDocument }
                , sendToBackend (SignInOrSignUp model.inputUsername (Authentication.encryptForTransit model.inputPassword))
                )

            else
                ( { model | message = "Password must be at least 8 letters long.", currentSnippet = Just Data.signInDocument }, Cmd.none )

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
                , currentSnippet = Just Data.signOutDocument
                , appMode = ViewMode
              }
            , Cmd.none
            )

        -- DATA
        InputSnippet str ->
            ( { model | snippetText = str }, Cmd.none )

        InputSnippetFilter str ->
            ( { model | inputSnippetFilter = str }, Cmd.none )

        SearchBy str ->
            let
                inputSnippetFilter =
                    if str == "★" then
                        "★" ++ model.inputSnippetFilter

                    else
                        str
            in
            ( { model | inputSnippetFilter = inputSnippetFilter }, Cmd.none )

        StarSnippet ->
            let
                newSnippetText =
                    if String.slice 0 1 model.snippetText == "★" then
                        "★" ++ model.snippetText

                    else
                        "★ " ++ model.snippetText
            in
            ( { model | snippetText = newSnippetText }, Cmd.none )

        ModificationOrder ->
            ( { model | snippets = List.sortBy (\snip -> -(Time.posixToMillis snip.modificationData)) model.snippets }, Cmd.none )

        AlphabeticOrder ->
            ( { model | snippets = List.sortBy (\snip -> snip.content) model.snippets }, Cmd.none )

        RandomOrder ->
            let
                { token, seed } =
                    Token.get model.randomSeed
            in
            ( { model | randomSeed = seed }, Random.generate RandomizedOrder (Random.List.shuffle model.snippets) )

        RandomizedOrder snippets_ ->
            ( { model | snippets = snippets_ }, Cmd.none )

        Fetch ->
            case model.currentUser of
                Nothing ->
                    ( model, Cmd.none )

                Just user ->
                    ( model, sendToBackend (SendUserData user.username) )

        Help ->
            ( { model | currentSnippet = Just Data.welcomeDocument, appMode = ViewMode }, Cmd.none )

        Save ->
            case model.currentUser of
                Nothing ->
                    ( model, Cmd.none )

                Just user ->
                    case model.appMode of
                        ViewMode ->
                            ( model, Cmd.none )

                        NewSnippetMode ->
                            case model.currentSnippet of
                                Nothing ->
                                    ( model, Cmd.none )

                                Just snippet ->
                                    let
                                        { token, seed } =
                                            Token.get model.randomSeed

                                        newSnippet =
                                            { snippet
                                                | content = model.snippetText |> Data.fixUrls
                                                , modificationData = model.currentTime
                                                , id = token
                                            }

                                        newSnippets =
                                            newSnippet :: model.snippets
                                    in
                                    ( { model
                                        | snippets = newSnippets
                                        , currentSnippet = Just newSnippet
                                        , appMode = ViewMode
                                        , snippetText = newSnippet.content
                                        , randomSeed = seed
                                      }
                                    , sendToBackend (SaveDatum user.username newSnippet)
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
                                        , currentSnippet = Just newSnippet
                                        , appMode = ViewMode
                                        , snippetText = newSnippet.content
                                      }
                                    , sendToBackend (UpdateDatum user.username newSnippet)
                                    )

        Close ->
            ( { model | appMode = ViewMode, snippetText = "" }, Cmd.none )

        Delete ->
            case model.currentSnippet of
                Nothing ->
                    ( model, Cmd.none )

                Just snippet ->
                    ( { model
                        | currentSnippet = Just Data.deletedSnippetDocument
                        , snippetText = ""
                        , appMode = ViewMode
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

        New ->
            ( { model
                | snippetText = ""
                , appMode = NewSnippetMode
              }
            , Cmd.none
            )

        ViewContent datum ->
            ( { model | currentSnippet = Just datum, appMode = ViewMode }, Cmd.none )

        ExpandContractItem datum ->
            let
                toggleViewMode mode =
                    case mode of
                        SnippetExpanded ->
                            SnippetCollapsed

                        SnippetCollapsed ->
                            SnippetExpanded
            in
            ( { model
                | currentSnippet = Just datum
                , snippetViewMode = toggleViewMode model.snippetViewMode
              }
            , Cmd.none
            )

        MarkdownMsg _ ->
            ( model, Cmd.none )

        ExportYaml ->
            ( model, Frontend.Update.exportSnippets model )

        -- UI
        ExpandContractView ->
            let
                newViewMode =
                    case model.viewMode of
                        SmallView ->
                            LargeView

                        LargeView ->
                            SmallView
            in
            ( { model | viewMode = newViewMode }, Cmd.none )

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
            let
                snippets =
                    List.sortBy (\snip -> -(Time.posixToMillis snip.modificationData)) dataList

                currentSnippet =
                    case List.head snippets of
                        Nothing ->
                            Just Data.noDocsDocument

                        Just snippet ->
                            Just snippet
            in
            ( { model | snippets = snippets, currentSnippet = currentSnippet }, Cmd.none )

        -- USER
        SendUser user ->
            ( { model | currentUser = Just user, currentSnippet = Just Data.signedInDocument }, Cmd.none )

        SendMessage message ->
            ( { model | message = message }, Cmd.none )


view : Model -> { title : String, body : List (Html.Html FrontendMsg) }
view model =
    { title = "Snippets"
    , body =
        case model.viewMode of
            SmallView ->
                [ View.Small.view model ]

            LargeView ->
                [ View.Large.view model ]
    }
