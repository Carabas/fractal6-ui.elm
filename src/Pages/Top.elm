module Pages.Top exposing (Flags, Model, Msg, page)

import Assets as A
import Browser.Navigation as Nav
import Components.AuthModal exposing (UserAuthForm)
import Dict exposing (Dict)
import Extra exposing (ternary, textH, upH)
import Extra.Events exposing (onClickPD, onKeydown)
import Form exposing (isLoginSendable, isSignupSendable)
import Generated.Route as Route exposing (Route, toHref)
import Global exposing (Msg(..), send, sendSleep)
import Html exposing (Html, a, br, button, div, h1, h2, hr, i, input, label, li, nav, p, span, strong, text, textarea, ul)
import Html.Attributes exposing (attribute, class, classList, disabled, href, id, name, placeholder, required, rows, target, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as JD
import Json.Encode as JE
import Loading exposing (WebData, expectJson, viewHttpErrors)
import Maybe exposing (withDefault)
import ModelCommon exposing (..)
import ModelCommon.Codecs exposing (FractalBaseRoute(..), toString)
import ModelCommon.Requests exposing (login, signup)
import ModelSchema exposing (..)
import Page exposing (Document, Page)
import Ports
import RemoteData exposing (RemoteData)
import Task
import Text as T



---- PROGRAM ----


page : Page Flags Model Msg
page =
    Page.component
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


type alias Flags =
    ()



---- MODEL ----


type alias Model =
    { form : UserAuthForm
    , result : WebData UserCtx
    , viewMode : ViewMode
    }


type ViewMode
    = Login
    | Signup



---- MSG ----


type Msg
    = SubmitUser UserAuthForm
    | ChangeUserPost String String
    | GotSignin (WebData UserCtx)
    | GotSignup (WebData Bool)
    | ChangeViewMode ViewMode
    | SubmitEnter Int



---- INIT ----


init : Global.Model -> Flags -> ( Model, Cmd Msg, Cmd Global.Msg )
init global flags =
    let
        gcmd =
            case global.session.user of
                LoggedIn uctx ->
                    Nav.replaceUrl global.key <| toString UsersBaseUri uctx.username []

                LoggedOut ->
                    Cmd.none

        model =
            { form = { post = Dict.empty }
            , result = RemoteData.NotAsked
            , viewMode = Login
            }
    in
    ( model
    , Cmd.none
    , Cmd.batch [ gcmd, send (UpdateSessionFocus Nothing) ]
    )



---- UPDATE ----


update : Global.Model -> Msg -> Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update global msg model =
    let
        apis =
            global.session.apis
    in
    case msg of
        ChangeUserPost field value ->
            let
                form =
                    model.form

                formUpdated =
                    { form | post = Dict.insert field value form.post }
            in
            ( { model | form = formUpdated }, Cmd.none, Cmd.none )

        SubmitUser form ->
            ( { model | result = RemoteData.Loading }
            , case model.viewMode of
                Login ->
                    login apis form.post GotSignin

                Signup ->
                    signup apis form.post GotSignup
            , Cmd.none
            )

        GotSignin result ->
            let
                cmds =
                    case result of
                        RemoteData.Success uctx ->
                            [ send (UpdateUserSession uctx)
                            , sendSleep RedirectOnLoggedIn 333
                            ]

                        _ ->
                            []
            in
            ( { model | result = result }
            , Cmd.none
            , Cmd.batch cmds
            )

        GotSignup result ->
            ( case result of
                RemoteData.Failure err ->
                    { model | result = RemoteData.Failure err }

                _ ->
                    model
            , case result of
                RemoteData.Success ok ->
                    Nav.pushUrl global.key (toHref Route.Verification ++ "?email=" ++ (Dict.get "email" model.form.post |> withDefault ""))

                _ ->
                    Cmd.none
            , Cmd.none
            )

        ChangeViewMode viewMode ->
            let
                form =
                    model.form
            in
            ( { model | viewMode = viewMode, result = RemoteData.NotAsked }, Cmd.none, Ports.bulma_driver "" )

        SubmitEnter key ->
            case key of
                13 ->
                    --ENTER
                    let
                        isSendable =
                            case model.viewMode of
                                Login ->
                                    isLoginSendable model.form.post

                                Signup ->
                                    isSignupSendable model.form.post
                    in
                    if isSendable then
                        ( model, send (SubmitUser model.form), Cmd.none )

                    else
                        ( model, Cmd.none, Cmd.none )

                _ ->
                    ( model, Cmd.none, Cmd.none )


subscriptions : Global.Model -> Model -> Sub Msg
subscriptions global model =
    Sub.none


view : Global.Model -> Model -> Document Msg
view global model =
    { title = "Login"
    , body = [ view_ global model ]
    }


view_ : Global.Model -> Model -> Html Msg
view_ global model =
    viewHero model


viewHero : Model -> Html Msg
viewHero model =
    div [ id "welcome", class "hero is-bold" ]
        [ div [ class "hero-body" ]
            [ div [ class "columns is-centered" ]
                [ div [ class "column is-6-desktop is-6-widescreen is-6-fullhd" ]
                    [ h1 [ class "title is-1" ]
                        --[ text "Build unstoppable organizations" ]
                        --[ text "Self-organization", br [] [], text "for humans" ]
                        [ text "Collective Intelligence", br [] [], text "at Work" ]
                    , h2 [ class "subtitle" ] <|
                        List.intersperse (text " ")
                            [ span [ class "has-text-weight-semibold" ] [ text "Fractale" ]
                            , text "is a collaborative platform inspired by"
                            , text "self-organized systems and open source culture."
                            , text "Join a network that enact collective intelligence to build transparent and resilient organization."

                            --Design your organisations roles and cirlces, invite members, manage your tensions..
                            ]
                    ]
                , div [ class "column is-4-desktop is-4-widescreen is-3-fullhd" ]
                    [ viewSignBox model ]
                ]
            ]
        ]


viewSignBox : Model -> Html Msg
viewSignBox model =
    div [ class "card" ]
        [ div [ class "card-header" ]
            [ div [ class "card-header-title tabs is-fullwidth" ]
                [ ul []
                    [ li [ classList [ ( "is-active", model.viewMode == Login ) ] ]
                        [ a [ onClickPD (ChangeViewMode Login), target "_blank" ] [ text "Login" ] ]
                    , li [ classList [ ( "is-active", model.viewMode == Signup ) ] ]
                        [ a [ onClickPD (ChangeViewMode Signup), target "_blank" ] [ text "Signup" ] ]
                    ]
                ]
            ]
        , div [ class "card-content" ]
            [ case model.viewMode of
                Login ->
                    viewLogin model

                Signup ->
                    viewSignup model
            , div []
                [ case model.result of
                    RemoteData.Failure err ->
                        viewHttpErrors err

                    _ ->
                        text ""
                ]
            ]
        ]


viewLogin : Model -> Html Msg
viewLogin model =
    div []
        [ A.welcome
        , div [ class "field is-horizntl" ]
            [ div [ class "field-lbl" ] [ label [ class "label" ] [ text T.username ] ]
            , div [ class "field-body" ]
                [ div [ class "field" ]
                    [ div [ class "control" ]
                        [ input
                            [ class "input autofocus followFocus"
                            , attribute "data-nextfocus" "passwordInput"
                            , type_ "text"
                            , placeholder "username or email"
                            , name "username"
                            , value (Dict.get "username" model.form.post |> withDefault "")
                            , attribute "autocomplete" "username"
                            , required True
                            , onInput (ChangeUserPost "username")
                            , onKeydown SubmitEnter
                            ]
                            []
                        ]
                    ]
                ]
            ]
        , div [ class "field is-horizntl" ]
            [ div [ class "field-lbl" ] [ label [ class "label" ] [ text T.password ] ]
            , div [ class "field-body" ]
                [ div [ class "field" ]
                    [ div [ class "control" ]
                        [ input
                            [ id "passwordInput"
                            , class "input"
                            , type_ "password"
                            , placeholder "password"
                            , name "password"
                            , value (Dict.get "password" model.form.post |> withDefault "")
                            , attribute "autocomplete" "password"
                            , required True
                            , onInput (ChangeUserPost "password")
                            , onKeydown SubmitEnter
                            ]
                            []
                        ]
                    ]
                ]
            ]
        , br [] []
        , div [ class "is-size-7 is-pulled-left" ]
            [ span [ class "mr-2" ] [ text T.needAnAccount ]
            , a [ onClickPD (ChangeViewMode Signup), target "_blank" ] [ text T.signupNow ]
            , br [ class "mb-1" ] []
            , a [ href (toHref Route.PasswordReset) ] [ textH T.passwordForgotten ]
            ]
        , div [ class "field is-grouped is-grouped-right" ]
            [ div [ class "control" ]
                [ if isLoginSendable model.form.post then
                    button
                        [ id "submitButton"
                        , class "button is-success"
                        , classList [ ( "is-loading", model.result == RemoteData.Loading ) ]
                        , onClick (SubmitUser model.form)
                        ]
                        [ text T.signin ]

                  else
                    button [ class "button", disabled True ] [ text T.signin ]
                ]
            ]
        ]


viewSignup : Model -> Html Msg
viewSignup model =
    div []
        [ A.welcome
        , div [ class "subtitle is-size-6 is-strong" ] [ text T.createYourAccount, text ":" ]
        , div [ class "field is-horizntl" ]
            [ div [ class "field-lbl" ] [ label [ class "label" ] [ text T.email ] ]
            , div [ class "field-body" ]
                [ div [ class "field" ]
                    [ div [ class "control" ]
                        [ input
                            [ class "input autofocus followFocus"
                            , attribute "data-nextfocus" "usernameInput2"
                            , type_ "text"
                            , placeholder "email"
                            , name "email"
                            , value (Dict.get "email" model.form.post |> withDefault "")
                            , attribute "autocomplete" "email"
                            , required True
                            , onInput (ChangeUserPost "email")
                            ]
                            []
                        ]
                    ]
                ]
            ]
        , div [ class "field is-horizntl" ]
            [ div [ class "field-lbl" ] [ label [ class "label" ] [ text T.username ] ]
            , div [ class "field-body" ]
                [ div [ class "field" ]
                    [ div [ class "control" ]
                        [ input
                            [ id "usernameInput2"
                            , class "input followFocus"
                            , attribute "data-nextfocus" "passwordInput2"
                            , type_ "text"
                            , placeholder "username"
                            , name "username"
                            , value (Dict.get "username" model.form.post |> withDefault "")
                            , attribute "autocomplete" "username"
                            , required True
                            , onInput (ChangeUserPost "username")
                            ]
                            []
                        ]
                    ]
                ]
            ]
        , div [ class "field is-horizntl" ]
            [ div [ class "field-lbl" ] [ label [ class "label" ] [ text T.password ] ]
            , div [ class "field-body" ]
                [ div [ class "field" ]
                    [ div [ class "control" ]
                        [ input
                            [ id "passwordInput2"
                            , class "input"
                            , type_ "password"
                            , placeholder "password"
                            , name "password"
                            , value (Dict.get "password" model.form.post |> withDefault "")
                            , attribute "autocomplete" "password"
                            , required True
                            , onInput (ChangeUserPost "password")
                            , onKeydown SubmitEnter
                            ]
                            []
                        , p [ class "help" ] [ text "Password must be 8 characters or longer." ]
                        ]
                    ]
                ]
            ]
        , br [] []
        , div [ class "is-size-7 is-pulled-left" ]
            [ span [ class "mr-2" ] [ text T.alreadyAnAccount ]
            , a [ onClickPD (ChangeViewMode Login), target "_blank" ] [ textH T.signinNow ]
            ]
        , div [ class "field is-grouped is-grouped-right" ]
            [ div [ class "control" ]
                [ if isSignupSendable model.form.post then
                    button
                        [ id "submitButton2"
                        , class "button is-success"
                        , classList [ ( "is-loading", model.result == RemoteData.Loading ) ]
                        , onClick (SubmitUser model.form)
                        ]
                        [ text T.signup ]

                  else
                    button [ class "button", disabled True ] [ text T.signup ]
                ]
            ]
        ]
