module Components.ContractsPage exposing (Msg(..), State, init, subscriptions, update, view)

import Auth exposing (AuthState(..), doRefreshToken)
import Components.Loading as Loading exposing (GqlData, ModalData, RequestResult(..), viewGqlErrors, withMapData, withMaybeData, withMaybeDataMap)
import Components.Markdown exposing (renderMarkdown)
import Components.ModalConfirm as ModalConfirm exposing (ModalConfirm)
import Date exposing (formatTime)
import Dict exposing (Dict)
import Extra exposing (ternary)
import Extra.Events exposing (onClickPD, onClickPD2)
import Form exposing (isPostEmpty, isPostSendable)
import Fractal.Enum.ContractType as ContractType
import Fractal.Enum.TensionEvent as TensionEvent
import Generated.Route as Route exposing (Route, toHref)
import Global exposing (send, sendNow, sendSleep)
import Html exposing (Html, a, br, button, div, h1, h2, hr, i, input, label, li, nav, option, p, pre, section, select, span, table, tbody, td, text, textarea, tfoot, th, thead, tr, ul)
import Html.Attributes exposing (attribute, checked, class, classList, colspan, disabled, for, href, id, list, name, placeholder, required, rows, selected, target, type_, value)
import Html.Events exposing (onBlur, onClick, onFocus, onInput, onMouseEnter)
import Icon as I
import Iso8601 exposing (fromTime)
import List.Extra as LE
import Maybe exposing (withDefault)
import ModelCommon exposing (Apis, GlobalCmd(..), UserState(..))
import ModelCommon.Codecs exposing (FractalBaseRoute(..), uriFromUsername)
import ModelCommon.View exposing (getAvatar, viewTensionDateAndUserC, viewUpdated, viewUsernameLink)
import ModelSchema exposing (..)
import Ports
import Query.QueryContract exposing (getContract, getContractComments, getContracts)
import Text as T exposing (textH, textT, upH)
import Time


type State
    = State Model


type alias Model =
    { user : UserState
    , rootnameid : String
    , contracts_result : GqlData Contracts -- result of any query
    , contract_result : GqlData Contract
    , form : MyForm -- user inputs
    , activeView : ContractsPageView

    -- Common
    , refresh_trial : Int -- use to refresh user token
    , modal_confirm : ModalConfirm Msg
    }


type ContractsPageView
    = ContractView
    | ContractsView


initModel : String -> UserState -> Model
initModel rootnameid user =
    { user = user
    , rootnameid = rootnameid
    , contracts_result = NotAsked
    , contract_result = NotAsked
    , form = initForm user
    , activeView = ContractsView

    -- Common
    , refresh_trial = 0
    , modal_confirm = ModalConfirm.init NoMsg
    }


type alias Contracts =
    List Contract


type alias MyForm =
    { uctx : UserCtx
    , tid : String
    , cid : String
    , page : Int
    , page_len : Int
    , events_type : Maybe (List TensionEvent.TensionEvent)
    , post : Post
    }


initForm : UserState -> MyForm
initForm user =
    { uctx =
        case user of
            LoggedIn uctx ->
                uctx

            LoggedOut ->
                UserCtx "" Nothing (UserRights False False) []
    , tid = ""
    , cid = ""
    , page = 0
    , page_len = 10
    , events_type = Nothing
    , post = Dict.empty
    }


init : String -> UserState -> State
init rid user =
    initModel rid user |> State



-- Global methods
--isOpen_ : State -> Bool
--isOpen_ (State model) =
--    model.isOpen
--- State Controls


reset : String -> Model -> Model
reset rid model =
    initModel rid model.user


updatePost : String -> String -> Model -> Model
updatePost field value model =
    let
        form =
            model.form
    in
    { model | form = { form | post = Dict.insert field value form.post } }


setContractsResult : GqlData Contracts -> Model -> Model
setContractsResult result model =
    { model | contracts_result = result }


setContractResult : GqlData Contract -> Model -> Model
setContractResult result model =
    { model | contract_result = result }



-- utils


canExitSafe : Model -> Bool
canExitSafe model =
    -- Condition to close safely (e.g. empty form data)
    (hasData model && withMaybeData model.contracts_result == Nothing) == False


hasData : Model -> Bool
hasData model =
    -- When you can commit (e.g. empty form data)
    isPostEmpty [ "message" ] model.form.post == False



-- ------------------------------
-- U P D A T E
-- ------------------------------


type Msg
    = -- Data
      OnLoad String (Maybe String)
    | OnChangePost String String
    | DoClickContract String
    | DoQueryContracts
    | DoQueryContract String
    | DoQueryContractComments String
    | OnSubmit (Time.Posix -> Msg)
    | OnContractsAck (GqlData Contracts)
    | OnContractAck (GqlData Contract)
    | OnContractCommentsAck (GqlData ContractComments)
      -- Confirm Modal
    | DoModalConfirmOpen Msg (List ( String, String ))
    | DoModalConfirmClose ModalData
    | DoModalConfirmSend
      -- Common
    | NoMsg
    | LogErr String


type alias Out =
    { cmds : List (Cmd Msg)
    , gcmds : List GlobalCmd
    , result : Maybe ( Bool, Contracts ) -- define what data is to be returned
    }


noOut : Out
noOut =
    Out [] [] Nothing


out0 : List (Cmd Msg) -> Out
out0 cmds =
    Out cmds [] Nothing


out1 : List GlobalCmd -> Out
out1 cmds =
    Out [] cmds Nothing


out2 : List (Cmd Msg) -> List GlobalCmd -> Out
out2 cmds gcmds =
    Out cmds gcmds Nothing


update : Apis -> Msg -> State -> ( State, Out )
update apis message (State model) =
    update_ apis message model
        |> Tuple.mapFirst State


update_ apis message model =
    case message of
        -- Data
        OnLoad tid cid_m ->
            let
                form =
                    model.form

                f =
                    { form | tid = tid, cid = withDefault form.cid cid_m }
            in
            case cid_m of
                Just cid ->
                    ( { model | form = f, activeView = ContractView }, out0 [ send (DoQueryContract cid) ] )

                Nothing ->
                    ( { model | form = f, activeView = ContractsView }, out0 [ send DoQueryContracts ] )

        OnChangePost field value ->
            ( updatePost field value model, noOut )

        DoClickContract cid ->
            let
                form =
                    model.form

                f =
                    { form | cid = cid }

                --contract_m =
                --    model.contracts_result
                --        |> withMaybeDataMap
                --            (\cs ->
                --                LE.find (\c -> c.id == cid) cs
                --            )
                --        |> withDefault Nothing
                url =
                    Route.Tension_Dynamic_Dynamic_Contract_Dynamic { param1 = model.rootnameid, param2 = model.form.tid, param3 = cid } |> toHref
            in
            ( { model | form = f, activeView = ContractView }, out1 [ DoNavigate url ] )

        DoQueryContracts ->
            ( { model | contracts_result = LoadingSlowly }, out0 [ getContracts apis.gql model.form OnContractsAck ] )

        DoQueryContract cid ->
            ( { model | contract_result = LoadingSlowly }, out0 [ getContract apis.gql model.form OnContractAck ] )

        DoQueryContractComments cid ->
            let
                form =
                    model.form

                f =
                    { form | cid = cid }
            in
            ( { model | form = f }, out0 [ getContractComments apis.gql f OnContractCommentsAck ] )

        OnSubmit next ->
            ( model
            , out0 [ sendNow next ]
            )

        OnContractsAck result ->
            let
                data =
                    setContractsResult result model
            in
            case doRefreshToken result data.refresh_trial of
                Authenticate ->
                    ( setContractsResult NotAsked model
                    , out1 [ DoAuth data.form.uctx ]
                    )

                RefreshToken i ->
                    ( { data | refresh_trial = i }, out2 [ sendSleep DoQueryContracts 500 ] [ DoUpdateToken ] )

                OkAuth d ->
                    ( data, Out [] [] (Just ( True, d )) )

                NoAuth ->
                    ( data, noOut )

        OnContractAck result ->
            let
                data =
                    setContractResult result model
            in
            case doRefreshToken result data.refresh_trial of
                Authenticate ->
                    ( setContractResult NotAsked model
                    , out1 [ DoAuth data.form.uctx ]
                    )

                RefreshToken i ->
                    ( { data | refresh_trial = i }, out2 [ sendSleep (DoQueryContract model.form.cid) 500 ] [ DoUpdateToken ] )

                OkAuth d ->
                    ( data, Out [ send (DoQueryContractComments d.id) ] [] (Just ( True, [ d ] )) )

                NoAuth ->
                    ( data, noOut )

        OnContractCommentsAck result ->
            let
                newResult =
                    model.contract_result
                        |> withMapData
                            (\c ->
                                withMaybeDataMap (\r -> { c | comments = r.comments }) result
                                    |> withDefault c
                            )

                data =
                    setContractResult newResult model
            in
            case doRefreshToken result data.refresh_trial of
                Authenticate ->
                    ( setContractResult NotAsked model
                    , out1 [ DoAuth data.form.uctx ]
                    )

                RefreshToken i ->
                    ( { data | refresh_trial = i }, out2 [ sendSleep (DoQueryContractComments model.form.cid) 500 ] [ DoUpdateToken ] )

                OkAuth d ->
                    ( data, Out [] [] (Just ( True, [] )) )

                NoAuth ->
                    ( data, noOut )

        -- Confirm Modal
        DoModalConfirmOpen msg txts ->
            ( { model | modal_confirm = ModalConfirm.open msg txts model.modal_confirm }, noOut )

        DoModalConfirmClose _ ->
            ( { model | modal_confirm = ModalConfirm.close model.modal_confirm }, noOut )

        DoModalConfirmSend ->
            ( { model | modal_confirm = ModalConfirm.close model.modal_confirm }, out0 [ send model.modal_confirm.msg ] )

        -- Common
        NoMsg ->
            ( model, noOut )

        LogErr err ->
            ( model, out0 [ Ports.logErr err ] )


subscriptions =
    []



-- ------------------------------
-- V I E W
-- ------------------------------


type alias Op =
    {}


view : Op -> State -> Html Msg
view op (State model) =
    div [ class "columns" ]
        [ div
            [ class "slider column is-12"
            , classList [ ( "is-slide-left", model.activeView /= ContractsView ), ( "is-transparent", model.activeView /= ContractsView ) ]
            ]
            [ viewContracts op model ]
        , div
            [ class "slider column is-12"
            , classList [ ( "is-slide-left", model.activeView == ContractView ), ( "is-transparent", model.activeView /= ContractView ) ]
            ]
            [ viewContract op model ]
        ]


viewContracts : Op -> Model -> Html Msg
viewContracts op model =
    case model.contracts_result of
        Success data ->
            viewContractsTable data op model

        Failure err ->
            viewGqlErrors err

        LoadingSlowly ->
            div [ class "spinner" ] []

        _ ->
            text ""


viewContractsTable : Contracts -> Op -> Model -> Html Msg
viewContractsTable data op model =
    let
        headers =
            [ "Event", "Validation", "Author", "Opened", "" ]
    in
    table
        [ class "table is-fullwidth tensionContracts"
        ]
        [ thead [ class "is-size-7" ]
            [ tr [] (headers |> List.map (\x -> th [ class "has-text-weight-light" ] [ textH x ]))
            ]
        , data
            |> List.map (\d -> viewRow d model)
            |> List.concat
            |> tbody []
        ]


viewRow : Contract -> Model -> List (Html Msg)
viewRow d model =
    [ tr [ class "mediaBox", onClick (DoClickContract d.id) ]
        [ td []
            [ a
                [ href (Route.Tension_Dynamic_Dynamic_Contract_Dynamic { param1 = model.rootnameid, param2 = model.form.tid, param3 = d.id } |> toHref) ]
                [ viewContractEvent d ]
            ]
        , td [] [ viewContractType d ]
        , td [ class "has-links-light" ] [ viewUsernameLink d.createdBy.username ]
        , td [] [ text (formatTime d.createdAt) ]

        -- participant
        -- n comments icons
        , td [ class "is-aligned-right is-size-7", attribute "style" "min-width: 6rem;" ]
            [ span
                [ class "button-light"

                --, onClick <| DoModalConfirmOpen (Submit <| SubmitDeleteLabel d.id) [ ( T.confirmDeleteLabel, "" ), ( d.name, "is-strong" ), ( "?", "" ) ]
                ]
                [ text "Cancel" ]
            ]
        ]
    ]
        ++ (case model.contract_result of
                Failure err ->
                    [ td [] [ viewGqlErrors err ] ]

                _ ->
                    []
           )


viewContract : Op -> Model -> Html Msg
viewContract op model =
    case model.contract_result of
        Success data ->
            viewContractPage data op model

        Failure err ->
            viewGqlErrors err

        LoadingSlowly ->
            div [ class "spinner" ] []

        _ ->
            text ""


viewContractPage : Contract -> Op -> Model -> Html Msg
viewContractPage data op model =
    div []
        [ text "contract page"
        , case data.comments of
            Nothing ->
                div [ class "spinner" ] []

            Just comments ->
                comments
                    |> List.map
                        (\c ->
                            let
                                isAuthor =
                                    c.createdBy.username == model.form.uctx.username
                            in
                            viewComment c isAuthor
                        )
                    |> div []
        , div [] [ text "input box here" ]
        ]


viewContractEvent : Contract -> Html Msg
viewContractEvent d =
    span []
        [ case d.event.event_type of
            TensionEvent.Moved ->
                textH "tension movement"

            _ ->
                text ""
        ]


viewContractType : Contract -> Html Msg
viewContractType d =
    span []
        [ case d.contract_type of
            ContractType.AnyCoordoDual ->
                text "Coordo validation"

            _ ->
                text ""
        ]


viewComment : Comment -> Bool -> Html Msg
viewComment c isAuthor =
    div [ class "media section is-paddingless" ]
        [ div [ class "media-left" ] [ a [ class "image circleBase circle1", href (uriFromUsername UsersBaseUri c.createdBy.username) ] [ getAvatar c.createdBy.username ] ]
        , div
            [ class "media-content"
            , attribute "style" "width: 66.66667%;"
            ]
            [ if False then
                --if model.comment_form.id == c.id then
                --viewUpdateInput model.comment_form.uctx c model.comment_form model.comment_result
                text "edit box"

              else
                div [ class "message" ]
                    [ div [ class "message-header" ]
                        [ viewTensionDateAndUserC c.createdAt c.createdBy
                        , case c.updatedAt of
                            Just updatedAt ->
                                viewUpdated updatedAt

                            Nothing ->
                                text ""
                        , if isAuthor then
                            div [ class "dropdown is-right is-pulled-right " ]
                                [ div [ class "dropdown-trigger" ]
                                    [ div
                                        [ class "ellipsis"
                                        , attribute "aria-controls" ("dropdown-menu_ellipsis" ++ c.id)
                                        , attribute "aria-haspopup" "true"
                                        ]
                                        [ I.icon "icon-ellipsis-v" ]
                                    ]
                                , div [ id ("dropdown-menu_ellipsis" ++ c.id), class "dropdown-menu", attribute "role" "menu" ]
                                    [ div [ class "dropdown-content" ]
                                        --[ div [ class "dropdown-item button-light" ] [ p [ onClick (DoUpdateComment c.id) ] [ textH T.edit ] ] ]
                                        []
                                    ]
                                ]

                          else
                            text ""
                        ]
                    , div [ class "message-body" ]
                        [ case c.message of
                            "" ->
                                div [ class "is-italic" ] [ text "No description provided." ]

                            message ->
                                renderMarkdown "is-light" message
                        ]
                    ]
            ]
        ]