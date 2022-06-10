module Pages.Login exposing (Flags, Model, Msg, page)

import Assets as A
import Browser.Navigation as Nav
import Components.AuthModal exposing (UserAuthForm)
import Components.Loading as Loading exposing (WebData, expectJson, viewHttpErrors)
import Dict exposing (Dict)
import Extra.Events exposing (onKeydown)
import Form exposing (isLoginSendable)
import Generated.Route as Route exposing (Route)
import Global exposing (Msg(..), send, sendSleep)
import Html exposing (Html, a, br, button, div, h1, h2, hr, i, input, label, li, nav, p, span, text, textarea, ul)
import Html.Attributes exposing (attribute, class, classList, disabled, href, id, name, placeholder, required, rows, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as JD
import Json.Encode as JE
import Maybe exposing (withDefault)
import ModelCommon exposing (..)
import ModelCommon.Requests exposing (login)
import ModelSchema exposing (..)
import Page exposing (Document, Page)
import RemoteData exposing (RemoteData)
import Task
import Text as T exposing (textH, textT)


page : Page Flags Model Msg
page =
    Page.component
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



--
-- Model
--


type alias Model =
    { form : UserAuthForm
    , result : WebData UserCtx
    }



--
-- Init
--


type alias Flags =
    ()


init : Global.Model -> Flags -> ( Model, Cmd Msg, Cmd Global.Msg )
init global flags =
    let
        gcmd =
            case global.session.user of
                LoggedIn uctx ->
                    Global.navigate <| Route.Dynamic { param1 = uctx.username }

                LoggedOut ->
                    Cmd.none

        model =
            { form = { post = Dict.empty }
            , result = RemoteData.NotAsked
            }
    in
    ( model
    , Cmd.none
    , Cmd.batch [ gcmd, send (UpdateSessionFocus Nothing) ]
    )



--
-- Update
--


type Msg
    = SubmitUser UserAuthForm
    | ChangeUserPost String String
    | GotSignin (WebData UserCtx) -- use remotedata.
    | SubmitKeyDown Int


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
            , login apis form.post GotSignin
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

        SubmitKeyDown key ->
            case key of
                13 ->
                    --ENTER
                    if isLoginSendable model.form.post then
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
    div [ class "columns is-centered section" ]
        [ div [ class "" ]
            [ viewLogin global model ]
        ]


viewLogin : Global.Model -> Model -> Html Msg
viewLogin global model =
    div [ id "loginForm" ]
        [ div [ class "card" ]
            [ div [ class "card-header" ]
                [ div [ class "card-header-title" ]
                    [ text "Login" ]
                ]
            , div [ class "card-content" ]
                [ A.welcome
                , div [ class "field is-horizntl" ]
                    [ div [ class "field-lbl" ] [ label [ class "label" ] [ text "Username" ] ]
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
                                    ]
                                    []
                                ]
                            ]
                        ]
                    ]
                , div [ class "field is-horizntl" ]
                    [ div [ class "field-lbl" ] [ label [ class "label" ] [ text "Password" ] ]
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
                                    , onKeydown SubmitKeyDown
                                    ]
                                    []
                                ]
                            ]
                        ]
                    ]
                , br [] []
                , div [ attribute "style" "width: 225px;" ]
                    [ a [ class "is-size-7 is-pulled-left mb-2", href (Route.toHref Route.Signup) ]
                        [ textH T.createAccount ]
                    , a [ class "is-size-7 is-pulled-left", href (Route.toHref Route.PasswordReset) ]
                        [ textH T.passwordForgotten ]
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
                                [ text "Sign in" ]

                          else
                            button [ class "button", disabled True ]
                                [ text "Sign in" ]
                        ]
                    ]
                ]
            ]
        , div []
            [ case model.result of
                RemoteData.Failure err ->
                    viewHttpErrors err

                _ ->
                    text ""
            ]
        ]
