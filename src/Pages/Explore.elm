module Pages.Explore exposing (Flags, Model, Msg, page)

import Components.Fa as Fa
import Components.HelperBar as HelperBar
import Components.Loading as Loading exposing (viewAuthNeeded, viewGqlErrors, viewHttpErrors, viewWarnings)
import Components.Text as Text exposing (..)
import Date exposing (formatTime)
import Dict exposing (Dict)
import Extra exposing (ternary)
import Fractal.Enum.NodeType as NodeType
import Global exposing (Msg(..))
import Html exposing (Html, a, br, button, div, h1, h2, hr, i, input, li, nav, p, span, text, textarea, ul)
import Html.Attributes exposing (attribute, class, classList, disabled, href, id, placeholder, rows, type_)
import Html.Events exposing (onClick, onInput, onMouseEnter)
import Iso8601 exposing (fromTime)
import Maybe exposing (withDefault)
import ModelCommon exposing (..)
import ModelCommon.Uri exposing (FractalBaseRoute(..), uriFromNameid)
import ModelCommon.View exposing (getAvatar)
import ModelSchema exposing (..)
import Page exposing (Document, Page)
import Ports
import Query.QueryNodes exposing (NodeExt, queryPublicOrga)
import Task
import Time


type alias Flags =
    ()


type alias Node =
    NodeExt


type alias Model =
    { orgas : GqlData (List Node)
    }


type Msg
    = GotOrga (GqlData (List Node))


page : Page Flags Model Msg
page =
    Page.component
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


init : Global.Model -> Flags -> ( Model, Cmd Msg, Cmd Global.Msg )
init global flags =
    let
        model =
            { orgas = Loading
            }

        cmds =
            [ queryPublicOrga GotOrga
            ]
    in
    ( model
    , Cmd.batch cmds
    , Cmd.none
    )


update : Global.Model -> Msg -> Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update global msg model =
    case msg of
        -- Gql queries
        GotOrga result ->
            ( { model | orgas = result }, Cmd.none, Cmd.none )


subscriptions : Global.Model -> Model -> Sub Msg
subscriptions global model =
    Sub.none


view : Global.Model -> Model -> Document Msg
view global model =
    { title = "Explore"
    , body = [ view_ global model ]
    }


view_ : Global.Model -> Model -> Html Msg
view_ global model =
    div [ id "explore", class "columns" ]
        [ div [ class "column is-offset-2 is-5 " ]
            [ div [ class "section" ]
                [ viewOrgas model ]
            ]
        ]


viewOrgas : Model -> Html Msg
viewOrgas model =
    div [ class "section" ] <|
        case model.orgas of
            Loading ->
                [ div [] [] ]

            NotAsked ->
                [ div [] [] ]

            LoadingSlowly ->
                [ div [ class "spinner" ] [] ]

            Failure err ->
                [ viewGqlErrors err ]

            Success nodes ->
                nodes
                    |> List.map (\n -> viewOrgaMedia n)
                    |> List.append [ div [ class "subtitle" ] [ text "Public Organisation" ], br [] [] ]


viewOrgaMedia : Node -> Html Msg
viewOrgaMedia node =
    let
        n_member =
            node.stats |> Maybe.map (\s -> s.n_member |> withDefault 0) |> withDefault 0 |> String.fromInt

        n_guest =
            node.stats |> Maybe.map (\s -> s.n_guest |> withDefault 0) |> withDefault 0 |> String.fromInt
    in
    div [ class "media" ]
        [ div [ class "media-left" ] [ div [ class "image is-48x48 circleBase circle1" ] [ getAvatar node.name ] ]
        , div [ class "media-content" ]
            [ div [ class "" ]
                [ div [ class "" ] [ a [ href (uriFromNameid OverviewBaseUri node.nameid) ] [ text node.name ] ]
                , div [ class "is-italic" ] [ text "about this organisation" ]
                ]
            ]
        , div [ class "media-right" ]
            [ div [ class "level levelExplore" ]
                [ div [ class "level-item" ]
                    [ span [ class "tags has-addons" ]
                        [ span [ class "tag is-light" ] [ text "member" ], span [ class "tag is-white" ] [ text n_member ] ]
                    ]
                , div [ class "level-item" ]
                    [ span [ class "tags has-addons" ]
                        [ span [ class "tag is-light" ] [ text "guest" ], span [ class "tag is-white" ] [ text n_guest ] ]
                    ]
                ]
            ]
        ]
