module Components.LabelSearchPanel exposing (Msg, State, init, subscriptions, update, view, viewNew)

import Auth exposing (AuthState(..), doRefreshToken)
import Codecs exposing (LookupResult)
import Components.I as I
import Components.Loading as Loading exposing (GqlData, RequestResult(..), loadingSpin, viewGqlErrors, withMapData, withMaybeData, withMaybeDataMap)
import Dict exposing (Dict)
import Extra exposing (ternary)
import Fractal.Enum.TensionEvent as TensionEvent
import Global exposing (send, sendNow, sendSleep)
import Html exposing (Html, a, br, button, canvas, datalist, div, h1, h2, hr, i, input, label, li, nav, option, p, select, span, tbody, td, text, textarea, th, thead, tr, ul)
import Html.Attributes exposing (attribute, class, classList, disabled, href, id, list, name, placeholder, required, rows, selected, type_, value)
import Html.Events exposing (onBlur, onClick, onFocus, onInput, onMouseEnter)
import Iso8601 exposing (fromTime)
import List.Extra as LE
import Maybe exposing (withDefault)
import ModelCommon exposing (Apis, GlobalCmd(..), LabelForm, UserState(..), initLabelForm)
import ModelCommon.Codecs exposing (nearestCircleid)
import ModelCommon.View exposing (viewLabel, viewLabels)
import ModelSchema exposing (..)
import Ports
import Query.PatchTension exposing (setLabel)
import Query.QueryNode exposing (queryLabelsUp)
import Task
import Text as T exposing (textH, textT, upH)
import Time


type State
    = State Model


type alias Model =
    { isOpen : Bool
    , form : LabelForm
    , click_result : GqlData IdPayload

    -- Lookup
    , lookup : List Label
    , pattern : String -- search pattern
    , labels_data : GqlData (List Label)

    --, init_lookup : List Label -> Cmd Msg
    --, search_lookup : String -> Cmd Msg
    -- Common
    , refresh_trial : Int
    }


init : String -> UserState -> State
init tid user =
    initModel tid user |> State


initModel : String -> UserState -> Model
initModel tid user =
    { isOpen = False
    , form = initLabelForm tid user
    , click_result = NotAsked

    -- Lookup
    , lookup = []
    , pattern = ""
    , labels_data = NotAsked

    -- Common
    , refresh_trial = 0
    }



-- State control


open : List String -> Model -> Model
open targets data =
    let
        form =
            data.form
    in
    { data | isOpen = True, form = { form | targets = targets } }


close : Model -> Model
close data =
    let
        form =
            data.form
    in
    { data | isOpen = False, click_result = NotAsked, pattern = "" }


click : Label -> Bool -> Model -> Model
click label isNew data =
    let
        form =
            data.form
    in
    { data | form = { form | label = label, isNew = isNew } }


setClickResult : GqlData IdPayload -> Model -> Model
setClickResult result data =
    { data | click_result = result }



-- Update Form


setEvents : List TensionEvent.TensionEvent -> Model -> Model
setEvents events data =
    let
        f =
            data.form
    in
    { data | form = { f | events_type = Just events } }


post : String -> String -> Model -> Model
post field value data =
    let
        f =
            data.form
    in
    { data | form = { f | post = Dict.insert field value f.post } }


setPattern : String -> Model -> Model
setPattern pattern data =
    let
        form =
            data.form
    in
    { data | pattern = pattern }



-- ------------------------------
-- U P D A T E
-- ------------------------------


type Msg
    = OnOpen (List String)
    | OnClose
    | OnChangePattern String
    | ChangeLabelLookup (LookupResult Label)
    | OnLabelClick Label Bool Time.Posix
    | OnLabelClickInt Label Bool Time.Posix
    | OnLabelAck (GqlData IdPayload)
    | OnSubmit (Time.Posix -> Msg)
    | OnGotLabels (GqlData (List Label))
    | SetLabel LabelForm


type alias Out =
    { cmds : List (Cmd Msg)
    , gcmds : List GlobalCmd
    , result : Maybe ( Bool, Label )
    }


noOut : Out
noOut =
    Out [] [] Nothing


out1 : List (Cmd Msg) -> Out
out1 cmds =
    Out cmds [] Nothing


out2 : List GlobalCmd -> Out
out2 cmds =
    Out [] cmds Nothing


update : Apis -> Msg -> State -> ( State, Out )
update apis message (State model) =
    update_ apis message model
        |> Tuple.mapFirst State


update_ : Apis -> Msg -> Model -> ( Model, Out )
update_ apis message model =
    case message of
        OnOpen targets ->
            if model.isOpen == False then
                let
                    k =
                        Debug.log "label up" targets

                    cmd =
                        ternary (targets /= model.form.targets)
                            [ queryLabelsUp apis.gql targets OnGotLabels ]
                            []
                in
                ( open targets model
                , out1 <|
                    [ Ports.outsideClickClose "cancelLabelsFromJs" "labelsPanelContent"
                    , Ports.inheritWith "labelSearchPanel"
                    , Ports.focusOn "userInput"
                    ]
                        ++ cmd
                )

            else
                ( model, noOut )

        OnClose ->
            ( close model, noOut )

        OnGotLabels result ->
            ( { model | labels_data = result }
            , out1 <|
                case result of
                    Success r ->
                        [ Ports.initLabelSearch r ]

                    _ ->
                        []
            )

        OnChangePattern pattern ->
            ( setPattern pattern model
            , out1 [ Ports.searchLabel pattern ]
            )

        ChangeLabelLookup data ->
            case data of
                Ok d ->
                    ( { model | lookup = d }, noOut )

                Err err ->
                    ( model, out1 [ Ports.logErr err ] )

        OnLabelClick label isNew time ->
            let
                data =
                    click label isNew model
                        |> post "createdAt" (fromTime time)
                        |> post (ternary isNew "new" "old") (label.name ++ "§" ++ withDefault "" label.color)
                        |> setEvents [ ternary isNew TensionEvent.LabelAdded TensionEvent.LabelRemoved ]
                        |> setClickResult LoadingSlowly
            in
            ( data
            , out1 [ send (SetLabel data.form) ]
            )

        OnLabelClickInt label isNew time ->
            let
                data =
                    click label isNew model
                        |> post "new" (label.name ++ "§" ++ withDefault "" label.color)
                        |> setEvents [ TensionEvent.LabelAdded ]
            in
            ( data, Out [] [] (Just ( data.form.isNew, data.form.label )) )

        OnLabelAck result ->
            let
                data =
                    setClickResult result model
            in
            case doRefreshToken result data.refresh_trial of
                Authenticate ->
                    ( setClickResult NotAsked data
                    , out2 [ DoAuth data.form.uctx ]
                    )

                RefreshToken i ->
                    ( { data | refresh_trial = i }, Out [ sendSleep (SetLabel data.form) 500 ] [ DoUpdateToken ] Nothing )

                OkAuth _ ->
                    ( data, Out [] [] (Just ( data.form.isNew, data.form.label )) )

                NoAuth ->
                    ( data, noOut )

        OnSubmit next ->
            ( model
            , out1 [ sendNow next ]
            )

        SetLabel form ->
            ( model
            , out1 [ setLabel apis.gql form OnLabelAck ]
            )


subscriptions =
    [ Ports.cancelLabelsFromJs (always OnClose)
    , Ports.lookupLabelFromJs ChangeLabelLookup
    ]



-- ------------------------------
-- V I E W
-- ------------------------------


type alias Op =
    { selectedLabels : List Label
    , targets : List String
    , isAdmin : Bool
    }


view_ : Bool -> Op -> State -> Html Msg
view_ isInternal op (State model) =
    nav [ id "labelSearchPanel", class "panel sidePanel" ]
        [ case model.labels_data of
            Success labels_d ->
                let
                    labels =
                        if model.pattern == "" then
                            op.selectedLabels
                                ++ labels_d
                                |> LE.uniqueBy (\u -> u.name)

                        else
                            LE.uniqueBy (\u -> u.name) model.lookup
                in
                div [] <|
                    ternary isInternal List.reverse identity <|
                        [ div [ class "panel-block" ]
                            [ p [ class "control has-icons-left" ]
                                [ input
                                    [ id "userInput"
                                    , class "input autofocus"
                                    , type_ "text"
                                    , placeholder (upH T.searchLabels)
                                    , value model.pattern
                                    , onInput OnChangePattern
                                    ]
                                    []
                                , span [ class "icon is-left" ] [ i [ attribute "aria-hidden" "true", class "icon-search" ] [] ]
                                ]
                            ]
                        , case model.click_result of
                            Failure err ->
                                viewGqlErrors err

                            _ ->
                                div [] []
                        , viewLabelSelectors isInternal labels op model
                        ]

            Loading ->
                div [ class "spinner" ] [ text "" ]

            LoadingSlowly ->
                div [ class "spinner" ] [ text "" ]

            NotAsked ->
                div [] []

            Failure err ->
                viewGqlErrors err
        ]


viewLabelSelectors : Bool -> List Label -> Op -> Model -> Html Msg
viewLabelSelectors isInternal labels op model =
    div [ class "selectors" ] <|
        if labels == [] then
            [ p [ class "panel-block" ] [ textH T.noResultsFound ] ]

        else
            labels
                |> List.map
                    (\l ->
                        let
                            isActive =
                                List.member l op.selectedLabels

                            iconCls =
                                ternary isActive "icon-check-square" "icon-square"

                            isLoading =
                                model.click_result == LoadingSlowly && l.id == model.form.label.id
                        in
                        p
                            [ class "panel-block"
                            , classList [ ( "is-active", isActive ) ]
                            , ternary isInternal
                                (onClick (OnSubmit <| OnLabelClickInt l (isActive == False)))
                                (onClick (OnSubmit <| OnLabelClick l (isActive == False)))
                            ]
                            [ span [ class "panel-icon" ] [ I.icon iconCls ]
                            , viewLabel "" l
                            , loadingSpin isLoading
                            ]
                    )



--
-- Input View
--


view : Op -> State -> Html Msg
view op (State model) =
    div []
        [ h2
            [ class "subtitle"
            , classList [ ( "is-w", op.isAdmin ) ]
            , onClick (OnOpen op.targets)
            ]
            [ textH T.labels
            , if model.isOpen then
                I.icon "icon-x is-pulled-right"

              else if op.isAdmin then
                I.icon "icon-settings is-pulled-right"

              else
                text ""
            ]
        , div [ id "labelsPanelContent" ]
            [ if model.isOpen then
                view_ False op (State model)

              else
                text ""
            ]
        ]


viewNew : Op -> State -> Html Msg
viewNew op (State model) =
    div []
        [ div [ id "labelsPanelContent", class "is-reversed" ]
            [ if model.isOpen then
                view_ True op (State model)

              else
                text ""
            ]
        , div [ class "button is-small is-light mr-2", onClick (OnOpen op.targets) ]
            [ I.icon1 "icon-plus" "", text "Label" ]
        , if List.length op.selectedLabels > 0 then
            viewLabels op.selectedLabels

          else
            text ""
        ]