module Org.Tension exposing (Flags, Model, Msg, TensionTab(..), init, page, subscriptions, update, view)

import Assets as A
import Auth exposing (ErrState(..), parseErr)
import Browser.Navigation as Nav
import Codecs exposing (LookupResult, QuickDoc)
import Components.ActionPanel as ActionPanel
import Components.AuthModal as AuthModal
import Components.Comments exposing (viewComment, viewCommentInput)
import Components.ContractsPage as ContractsPage
import Components.HelperBar as HelperBar exposing (HelperBar)
import Components.JoinOrga as JoinOrga
import Components.LabelSearchPanel as LabelSearchPanel
import Components.MoveTension as MoveTension
import Components.NodeDoc as NodeDoc exposing (NodeDoc, NodeEdit(..), NodeView(..))
import Components.OrgaMenu as OrgaMenu
import Components.SelectType as SelectType
import Components.TreeMenu as TreeMenu
import Components.UserSearchPanel as UserSearchPanel
import Dict exposing (Dict)
import Extra exposing (decap, ternary, textD, textH, upH)
import Extra.Date exposing (formatDate)
import Extra.Url exposing (queryBuilder, queryParser)
import Form exposing (isPostSendable)
import Form.Help as Help
import Form.NewTension as NTF exposing (NewTensionInput(..), TensionTab(..))
import Fractal.Enum.BlobType as BlobType
import Fractal.Enum.Lang as Lang
import Fractal.Enum.NodeMode as NodeMode
import Fractal.Enum.NodeType as NodeType
import Fractal.Enum.NodeVisibility as NodeVisibility
import Fractal.Enum.RoleType as RoleType
import Fractal.Enum.TensionAction as TensionAction
import Fractal.Enum.TensionEvent as TensionEvent
import Fractal.Enum.TensionStatus as TensionStatus
import Fractal.Enum.TensionType as TensionType
import Generated.Route as Route exposing (Route, toHref)
import Global exposing (Msg(..), send, sendNow, sendSleep)
import Html exposing (Html, a, br, button, div, h1, h2, hr, i, input, li, nav, p, span, strong, text, textarea, ul)
import Html.Attributes exposing (attribute, class, classList, disabled, href, id, placeholder, readonly, rows, spellcheck, style, target, type_, value)
import Html.Events exposing (onClick, onInput, onMouseEnter)
import Html.Lazy as Lazy
import Iso8601 exposing (fromTime)
import List.Extra as LE
import Loading
    exposing
        ( GqlData
        , ModalData
        , RequestResult(..)
        , WebData
        , fromMaybeData
        , isFailure
        , isSuccess
        , loadingSpin
        , viewAuthNeeded
        , viewGqlErrors
        , viewHttpErrors
        , viewMaybeErrors
        , withDefaultData
        , withMapData
        , withMaybeData
        , withMaybeDataMap
        )
import Maybe exposing (withDefault)
import ModelCommon exposing (..)
import ModelCommon.Codecs
    exposing
        ( ActionType(..)
        , DocType(..)
        , FocusState
        , FractalBaseRoute(..)
        , NodeFocus
        , eor2ur
        , focusFromNameid
        , focusFromPath
        , focusState
        , getOrgaRoles
        , getTensionCharac
        , isOwner
        , nid2rootid
        , nodeFromFragment
        , tensionAction2NodeType
        , uriFromNameid
        , uriFromUsername
        )
import ModelCommon.View
    exposing
        ( action2icon
        , action2str
        , archiveActionToggle
        , auth2icon
        , auth2val
        , statusColor
        , tensionIcon2
        , tensionStatus2String
        , tensionTypeColor
        , viewCircleTarget
        , viewJoinNeeded
        , viewLabel
        , viewLabels
        , viewNodeRefShort
        , viewRole
        , viewRoleExt
        , viewTensionDateAndUser
        , viewTensionDateAndUserC
        , viewUpdated
        , viewUser0
        , viewUser2
        , viewUserFull
        , viewUsernameLink
        , viewUsers
        , visibility2icon
        )
import ModelSchema exposing (..)
import Page exposing (Document, Page)
import Ports
import Query.PatchTension exposing (actionRequest, patchComment, patchLiteral, publishBlob, pushTensionPatch)
import Query.PatchUser exposing (markAsRead, toggleTensionSubscription)
import Query.QueryNode exposing (queryLocalGraph)
import Query.QueryTension exposing (getTensionBlobs, getTensionComments, getTensionHead)
import Query.QueryUser exposing (getIsSubscribe)
import RemoteData exposing (RemoteData)
import Scroll
import Session exposing (GlobalCmd(..), LabelSearchPanelOnClickAction(..), UserSearchPanelOnClickAction(..))
import String.Extra as SE
import String.Format as Format
import Task
import Text as T
import Time
import Url exposing (Url)



---- PROGRAM ----


type alias Flags =
    { param1 : String
    , param2 : String
    , param3 : TensionTab
    , param4 : Maybe String
    }


page : Page Flags Model Msg
page =
    Page.component
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


mapGlobalOutcmds : List GlobalCmd -> ( List (Cmd Msg), List (Cmd Global.Msg) )
mapGlobalOutcmds gcmds =
    gcmds
        |> List.map
            (\m ->
                case m of
                    DoNavigate link ->
                        ( send (Navigate link), Cmd.none )

                    DoReplaceUrl url ->
                        ( Cmd.none, send (ReplaceUrl url) )

                    DoUpdateToken ->
                        ( Cmd.none, send UpdateUserToken )

                    DoUpdateUserSession uctx ->
                        ( Cmd.none, send (UpdateUserSession uctx) )

                    DoUpdateOrgs orgs ->
                        ( Cmd.none, send (UpdateSessionOrgs orgs) )

                    DoCreateTension nameid ->
                        ( Cmd.map NewTensionMsg <| send (NTF.OnOpen (FromNameid nameid)), Cmd.none )

                    -- Tree Data
                    DoUpdateTree tree ->
                        ( Cmd.none, send (UpdateSessionTree tree) )

                    DoUpdatePath path ->
                        ( Cmd.none, send (UpdateSessionPath path) )

                    DoFocus nameid ->
                        ( Cmd.none, send (NavigateNode nameid) )

                    DoFetchNode nameid ->
                        ( Cmd.map TreeMenuMsg <| send (TreeMenu.FetchNewNode nameid False), Cmd.none )

                    DoAddNodes nodes ->
                        ( Cmd.map TreeMenuMsg <| send (TreeMenu.AddNodes nodes), Cmd.none )

                    DoUpdateNode nameid fun ->
                        ( Cmd.map TreeMenuMsg <| send (TreeMenu.UpdateNode nameid fun), Cmd.none )

                    DoDelNodes nameids ->
                        ( Cmd.map TreeMenuMsg <| send (TreeMenu.DelNodes nameids), Cmd.none )

                    DoMoveNode a b c ->
                        ( Cmd.map TreeMenuMsg <| send (TreeMenu.MoveNode a b c), Cmd.none )

                    _ ->
                        ( Cmd.none, Cmd.none )
            )
        |> List.unzip



---- MODEL ----


type alias Model =
    { -- Focus
      node_focus : NodeFocus
    , path_data : GqlData LocalGraph
    , lookup_users : List User

    -- Page
    , focusState : FocusState
    , tensionid : String
    , baseUri : FractalBaseRoute
    , contractid : Maybe String
    , activeTab : TensionTab
    , nodeView : NodeView
    , jumpTo : Maybe String
    , tension_head : GqlData TensionHead
    , tension_comments : GqlData TensionComments
    , tension_blobs : GqlData TensionBlobs
    , expandedEvents : List Int
    , subscribe_result : GqlData Bool
    , eid : String
    , unsubscribe : String

    -- Form (Title, Status, Comment)
    , tension_form : TensionForm
    , tension_patch : GqlData PatchTensionPayloadID

    -- Title Result
    , isTitleEdit : Bool
    , title_result : GqlData IdPayload

    -- Comment Edit
    , comment_form : CommentPatchForm
    , comment_result : GqlData Comment

    -- Blob Edit
    , nodeDoc : NodeDoc
    , publish_result : GqlData TensionBlobFlag
    , hasBeenPushed : Bool

    -- Side Pane
    , isTensionAdmin : Bool
    , isAssigneeOpen : Bool
    , isLabelOpen : Bool

    -- Common
    , inputViewMode : InputViewMode
    , helperBar : HelperBar
    , refresh_trial : Int
    , now : Time.Posix
    , lang : Lang.Lang
    , empty : {}

    -- Components
    , help : Help.State
    , tensionForm : NTF.State
    , assigneesPanel : UserSearchPanel.State
    , labelsPanel : LabelSearchPanel.State
    , actionPanel : ActionPanel.State
    , moveTension : MoveTension.State
    , contractsPage : ContractsPage.State
    , selectType : SelectType.State
    , joinOrga : JoinOrga.State
    , authModal : AuthModal.State
    , orgaMenu : OrgaMenu.State
    , treeMenu : TreeMenu.State
    }



-- Query parameters


type TensionTab
    = Conversation
    | Document
    | Contracts



---- MSG ----


type Msg
    = PassedSlowLoadTreshold -- timer
    | LoadTensionHead
    | LoadTensionComments
    | PushCommentPatch
    | PushTitle
    | PushBlob_ TensionForm
    | PublishBlob
    | Submit Bool (Time.Posix -> Msg) -- Get Current Time
      -- Data Queries
    | GotPath Bool (GqlData LocalGraph)
      -- Page
    | GotTensionHead (GqlData TensionHead)
    | GotIsSubscribe (GqlData Bool)
    | GotTensionComments (GqlData TensionComments)
    | GotTensionBlobs (GqlData TensionBlobs)
    | ExpandEvent Int
    | ToggleSubscription String
    | DoUnsubscribe String
    | OnCloseUnsubscribe
    | MarkAsRead String
    | GotMarkAsRead (GqlData IdPayload)
      --
      -- Page Action
      --
      -- new comment
    | ChangeTensionPost String String -- {field value}
    | SubmitComment (Maybe TensionStatus.TensionStatus) Time.Posix
    | CommentAck (GqlData PatchTensionPayloadID)
      -- edit comment
    | DoUpdateComment Comment
    | CancelCommentPatch
    | ChangeCommentPost String String
    | SubmitCommentPatch Time.Posix
    | CommentPatchAck (GqlData Comment)
      -- edit title
    | DoChangeTitle
    | CancelTitle
    | SubmitTitle Time.Posix
    | TitleAck (GqlData IdPayload)
      -- Blob doc edit
    | ChangeBlobEdit NodeEdit
    | ChangeBlobPost String String
    | AddDomains
    | AddPolicies
    | AddResponsabilities
      -- Blob Submit
    | CommitBlob NodeDoc Time.Posix
    | BlobAck (GqlData PatchTensionPayloadID)
    | PushBlob String Time.Posix
    | PushBlobAck (GqlData TensionBlobFlag)
    | CancelBlob
      -- Assignees
    | DoAssigneeEdit
      -- Labels
    | DoLabelEdit
      -- move tension
    | DoMove TensionHead
      -- Node Action
    | OpenActionPanel String String (Maybe ( Int, Int ))
      -- Common
    | NoMsg
    | LogErr String
    | Navigate String
    | ChangeInputViewMode InputViewMode
    | ChangeUpdateViewMode InputViewMode
    | ExpandRoles
    | CollapseRoles
    | ScrollToElement String
    | UpdateUctx UserCtx
      -- Components
    | HelpMsg Help.Msg
    | NewTensionMsg NTF.Msg
    | UserSearchPanelMsg UserSearchPanel.Msg
    | LabelSearchPanelMsg LabelSearchPanel.Msg
    | MoveTensionMsg MoveTension.Msg
    | ContractsPageMsg ContractsPage.Msg
    | SelectTypeMsg SelectType.Msg
    | ActionPanelMsg ActionPanel.Msg
    | JoinOrgaMsg JoinOrga.Msg
    | AuthModalMsg AuthModal.Msg
    | OrgaMenuMsg OrgaMenu.Msg
    | TreeMenuMsg TreeMenu.Msg



---- INIT ----


init : Global.Model -> Flags -> ( Model, Cmd Msg, Cmd Global.Msg )
init global flags =
    let
        apis =
            global.session.apis

        -- Query parameters
        query =
            queryParser global.url

        -- Focus
        rootnameid =
            flags.param1 |> Url.percentDecode |> withDefault ""

        tid =
            flags.param2

        tab =
            flags.param3

        cid_m =
            flags.param4

        -- Focus
        newFocus_ =
            NodeFocus rootnameid rootnameid NodeType.Circle

        -- What has changed
        baseUri =
            case tab of
                Conversation ->
                    --TensionBaseUri
                    -- better UX to redirect to tensions list when navigating tensions.
                    TensionsBaseUri

                Document ->
                    MandateBaseUri

                Contracts ->
                    ContractsBaseUri

        fs =
            focusState TensionBaseUri global.session.referer global.url global.session.node_focus newFocus_

        newFocus =
            if fs.orgChange then
                -- This allow TreeMenu to reload in case of orgChange
                newFocus_

            else
                global.session.path_data
                    |> Maybe.map focusFromPath
                    |> withDefault newFocus_

        refresh =
            Maybe.map (\th -> tensionChanged2 th global.url) global.session.tension_head |> withDefault True

        nodeView =
            Dict.get "v" query |> withDefault [] |> List.head |> withDefault "" |> NodeDoc.nodeViewDecoder

        model =
            { node_focus = newFocus
            , lookup_users = []
            , tensionid = tid
            , baseUri = baseUri
            , contractid = cid_m
            , activeTab = tab
            , nodeView = nodeView
            , jumpTo = Dict.get "goto" query |> Maybe.map List.head |> withDefault Nothing
            , path_data = ternary fs.orgChange Loading (fromMaybeData global.session.path_data Loading)
            , tension_head = ternary fs.orgChange Loading (fromMaybeData global.session.tension_head Loading)
            , focusState = fs
            , tension_comments = Loading
            , tension_blobs = Loading
            , expandedEvents = []
            , subscribe_result = NotAsked
            , eid = ""
            , unsubscribe = ""

            -- Form (Title, Status, Comment)
            , tension_form = initTensionForm tid global.session.user

            -- Push Comment / Change status
            , tension_patch = NotAsked

            -- Title Result
            , isTitleEdit = False
            , title_result = NotAsked

            -- Comment Edit
            , comment_form = initCommentPatchForm global.session.user
            , comment_result = NotAsked

            -- Blob Edit
            , nodeDoc =
                NodeDoc.init tid nodeView global.session.user
                    |> (\x ->
                            case global.session.tension_head of
                                Just th ->
                                    NodeDoc.initBlob (nodeFromTension th) x

                                Nothing ->
                                    x
                       )
            , publish_result = NotAsked
            , hasBeenPushed =
                case global.session.tension_head of
                    Just th ->
                        th.history |> withDefault [] |> List.map (\e -> e.event_type) |> List.member TensionEvent.BlobPushed

                    Nothing ->
                        False

            -- Side Pane
            , isTensionAdmin = withDefault False global.session.isAdmin
            , isAssigneeOpen = False
            , assigneesPanel = UserSearchPanel.init tid AssignUser global.session.user
            , isLabelOpen = False
            , labelsPanel = LabelSearchPanel.init tid AssignLabel global.session.user

            -- Common
            , inputViewMode = Write
            , helperBar = HelperBar.create
            , help = Help.init global.session.user global.session.screen
            , tensionForm = NTF.init global.session.user global.session.screen
            , refresh_trial = 0
            , moveTension = MoveTension.init global.session.user
            , contractsPage = ContractsPage.init rootnameid global.session.user
            , selectType = SelectType.init tid global.session.user
            , actionPanel = ActionPanel.init global.session.user
            , now = global.now
            , lang = global.session.lang
            , empty = {}
            , joinOrga = JoinOrga.init newFocus.nameid global.session.user global.session.screen

            -- Oen a sigin dialog if contracts are requested
            , authModal = AuthModal.init global.session.user (Dict.get "puid" query |> Maybe.map List.head |> withDefault (ternary (baseUri == ContractsBaseUri) (Just "") Nothing))
            , orgaMenu = OrgaMenu.init newFocus global.session.orga_menu global.session.orgs_data global.session.user
            , treeMenu = TreeMenu.init baseUri global.url.query newFocus global.session.tree_menu global.session.tree_data global.session.user
            }
    in
    ( { model | subscribe_result = withMapData (\x -> withDefault False x.isSubscribed) model.tension_head }
    , Cmd.batch (refresh_cmds refresh global model)
    , if fs.menuChange || refresh then
        -- No refresh here because all the focus is not encoded in the tension URL.
        send (UpdateSessionFocus (Just newFocus))

      else
        Cmd.none
    )


refresh_cmds : Bool -> Global.Model -> Model -> List (Cmd Msg)
refresh_cmds refresh global model =
    let
        apis =
            global.session.apis

        query =
            queryParser global.url
    in
    [ if refresh then
        send LoadTensionHead

      else
        Cmd.none
    , case model.activeTab of
        Conversation ->
            getTensionComments apis model.tensionid GotTensionComments

        Document ->
            if NodeDoc.getNodeView model.nodeDoc == NodeVersions then
                getTensionBlobs apis model.tensionid GotTensionBlobs

            else
                Cmd.none

        Contracts ->
            Cmd.map ContractsPageMsg (send (ContractsPage.OnLoad model.tensionid model.contractid))
    , if model.node_focus.rootnameid == "" && not refresh then
        -- Fix contract with empty rootnameid redirection
        case model.tension_head of
            Success th ->
                Cmd.map ContractsPageMsg (send (ContractsPage.SetRootnameid (nid2rootid th.receiver.nameid)))

            _ ->
                Cmd.none

      else
        Cmd.none
    , sendSleep PassedSlowLoadTreshold 500
    , case Dict.get "eid" query |> Maybe.map List.head |> withDefault Nothing of
        Just eid ->
            send (MarkAsRead eid)

        Nothing ->
            Cmd.none
    , case Dict.get "unsubscribe" query |> Maybe.map List.head |> withDefault Nothing of
        Just "email" ->
            send (DoUnsubscribe "email")

        _ ->
            Cmd.none
    , Cmd.map AuthModalMsg (send AuthModal.OnStart)
    , Cmd.map OrgaMenuMsg (send OrgaMenu.OnLoad)
    , Cmd.map TreeMenuMsg (send TreeMenu.OnLoad)
    ]



--- UPDATE ----


update : Global.Model -> Msg -> Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update global message model =
    let
        apis =
            global.session.apis
    in
    case message of
        LoadTensionHead ->
            let
                ( uctx, cmd ) =
                    case global.session.user of
                        LoggedIn uctx_ ->
                            ( uctx_
                              -- Now directly loaded in TensionLoad query
                              --, getIsSubscribe apis uctx_.username model.tensionid GotIsSubscribe
                            , Cmd.none
                            )

                        LoggedOut ->
                            ( initUserctx, Cmd.none )
            in
            ( model, Cmd.batch [ getTensionHead apis uctx model.tensionid GotTensionHead, cmd ], Cmd.none )

        LoadTensionComments ->
            ( model, pushTensionPatch apis model.tension_form CommentAck, Cmd.none )

        PushCommentPatch ->
            ( model, patchComment apis model.comment_form CommentPatchAck, Cmd.none )

        PushTitle ->
            ( model, patchLiteral apis model.tension_form TitleAck, Cmd.none )

        PushBlob_ form ->
            ( model, pushTensionPatch apis form BlobAck, Cmd.none )

        PublishBlob ->
            let
                form =
                    model.tension_form

                bid =
                    form.events
                        |> List.filter (\x -> x.event_type == TensionEvent.BlobPushed)
                        |> List.head
                        |> Maybe.map .new
                        |> withDefault ""
            in
            ( model, publishBlob apis bid form PushBlobAck, Cmd.none )

        PassedSlowLoadTreshold ->
            let
                tension_h =
                    ternary (model.tension_head == Loading) LoadingSlowly model.tension_head

                tension_c =
                    ternary (model.tension_comments == Loading) LoadingSlowly model.tension_comments

                tension_b =
                    ternary (model.tension_blobs == Loading) LoadingSlowly model.tension_blobs
            in
            ( { model | tension_head = tension_h, tension_comments = tension_c, tension_blobs = tension_b }, Cmd.none, Cmd.none )

        Submit isLoading nextMsg ->
            if isLoading then
                ( model, Cmd.none, Cmd.none )

            else
                ( model, Task.perform nextMsg Time.now, Cmd.none )

        -- Data queries
        GotPath isInit result ->
            case result of
                Success path ->
                    let
                        prevPath =
                            if isInit then
                                { path | path = [] }

                            else
                                withDefaultData path model.path_data
                    in
                    case path.root of
                        Just root ->
                            let
                                newPath =
                                    { prevPath | root = Just root, path = path.path ++ (List.tail prevPath.path |> withDefault []) }

                                isAdmin =
                                    getTensionRights (uctxFromUser global.session.user) model.tension_head result

                                newFocus =
                                    focusFromNameid newPath.focus.nameid
                            in
                            ( { model | path_data = Success newPath, isTensionAdmin = isAdmin, node_focus = newFocus }
                            , Cmd.batch
                                [ Maybe.map (\did -> send (ScrollToElement did)) model.jumpTo |> withDefault Cmd.none
                                , Cmd.map TreeMenuMsg (send (TreeMenu.OnUpdateFocus newFocus))
                                , Cmd.map OrgaMenuMsg (send (OrgaMenu.OnUpdateFocus newFocus))
                                ]
                            , Cmd.batch
                                [ send (UpdateSessionPath (Just newPath))
                                , send (UpdateSessionAdmin (Just isAdmin))
                                , send (UpdateSessionFocusOnly (Just newFocus))
                                ]
                            )

                        Nothing ->
                            let
                                newPath =
                                    { prevPath | path = path.path ++ (List.tail prevPath.path |> withDefault []) }

                                nameid =
                                    List.head path.path |> Maybe.map .nameid |> withDefault ""
                            in
                            ( { model | path_data = Success newPath }
                            , queryLocalGraph apis nameid (GotPath False)
                            , Cmd.none
                            )

                _ ->
                    ( { model | path_data = result }, Cmd.none, Cmd.none )

        -- Page
        GotTensionHead result ->
            case parseErr result model.refresh_trial of
                Authenticate ->
                    ( model, Ports.raiseAuthModal (uctxFromUser global.session.user), Cmd.none )

                RefreshToken i ->
                    ( { model | refresh_trial = i }, sendSleep LoadTensionHead 500, send UpdateUserToken )

                OkAuth th ->
                    let
                        hasBeenPushed =
                            th.history |> withDefault [] |> List.map (\e -> e.event_type) |> List.member TensionEvent.BlobPushed

                        ( targetid, nodeDoc ) =
                            case th.action of
                                Just action ->
                                    case (getTensionCharac action).doc_type of
                                        NODE _ ->
                                            let
                                                node =
                                                    nodeFromTension th
                                            in
                                            ( ternary hasBeenPushed (NodeDoc.getNodeNameid th.receiver.nameid node) th.receiver.nameid
                                            , NodeDoc.initBlob node model.nodeDoc
                                            )

                                        MD ->
                                            -- not implemented
                                            ( th.receiver.nameid, model.nodeDoc )

                                Nothing ->
                                    -- No Document attached or Unknown format
                                    ( th.receiver.nameid, model.nodeDoc )
                    in
                    ( { model
                        | tension_head = result
                        , hasBeenPushed = hasBeenPushed
                        , subscribe_result = fromMaybeData th.isSubscribed NotAsked
                        , nodeDoc = nodeDoc
                      }
                    , Cmd.batch
                        [ if model.focusState.orgChange || not (isSuccess model.path_data) then
                            -- Do not change the context of the user anonimosly, its confusing
                            queryLocalGraph apis (nid2rootid targetid) (GotPath True)

                          else
                            Cmd.none
                        , Ports.bulma_driver ""
                        , Cmd.map ContractsPageMsg (send (ContractsPage.SetRootnameid (nid2rootid targetid)))
                        ]
                    , send (UpdateSessionTensionHead (withMaybeData result))
                    )

                _ ->
                    ( { model | tension_head = result }
                    , Ports.bulma_driver ""
                    , send (UpdateSessionTensionHead (withMaybeData result))
                    )

        GotIsSubscribe result ->
            case parseErr result model.refresh_trial of
                Authenticate ->
                    ( model, Ports.raiseAuthModal (uctxFromUser global.session.user), Cmd.none )

                RefreshToken i ->
                    ( { model | refresh_trial = i }, sendSleep LoadTensionHead 500, send UpdateUserToken )

                OkAuth d ->
                    let
                        th =
                            withMapData (\x -> { x | isSubscribed = Just d }) model.tension_head
                    in
                    ( { model | subscribe_result = result, tension_head = th }, Cmd.none, send (UpdateSessionTensionHead (withMaybeData th)) )

                _ ->
                    ( { model | subscribe_result = result }, Cmd.none, Cmd.none )

        GotTensionComments result ->
            ( { model | tension_comments = result }, Cmd.none, Ports.bulma_driver "" )

        GotTensionBlobs result ->
            ( { model | tension_blobs = result }, Cmd.none, Ports.bulma_driver "" )

        ExpandEvent i ->
            -- @fix/bulma: dropdown clidk handler lost during the operation
            ( { model | expandedEvents = model.expandedEvents ++ [ i ] }, Cmd.none, Ports.bulma_driver "" )

        ToggleSubscription username ->
            case model.tension_head of
                Success th ->
                    ( { model | subscribe_result = LoadingSlowly }
                    , toggleTensionSubscription apis username model.tensionid (not (withDefault False th.isSubscribed)) GotIsSubscribe
                    , Cmd.none
                    )

                _ ->
                    ( model, Cmd.none, Cmd.none )

        DoUnsubscribe name ->
            case global.session.user of
                LoggedIn uctx ->
                    ( { model | unsubscribe = name }
                    , toggleTensionSubscription apis uctx.username model.tensionid False GotIsSubscribe
                    , Cmd.none
                    )

                LoggedOut ->
                    ( model, Cmd.none, Cmd.none )

        OnCloseUnsubscribe ->
            ( { model | unsubscribe = "" }, Cmd.none, Cmd.none )

        MarkAsRead eid ->
            ( { model | eid = eid }, markAsRead apis eid True GotMarkAsRead, Cmd.none )

        GotMarkAsRead result ->
            case parseErr result model.refresh_trial of
                Authenticate ->
                    ( model, Ports.raiseAuthModal (uctxFromUser global.session.user), Cmd.none )

                RefreshToken i ->
                    ( { model | refresh_trial = i }, sendSleep (MarkAsRead model.eid) 500, send UpdateUserToken )

                OkAuth _ ->
                    ( model, Cmd.none, Cmd.none )

                _ ->
                    ( model, Cmd.none, Cmd.none )

        -- Page Action
        ChangeTensionPost field value ->
            let
                form =
                    model.tension_form

                newForm =
                    if field == "message" && value == "" then
                        { form | post = Dict.remove field form.post }

                    else
                        { form | post = Dict.insert field value form.post }
            in
            ( { model | tension_form = newForm }, Cmd.none, Cmd.none )

        SubmitComment status_m time ->
            let
                form =
                    model.tension_form

                eventStatus =
                    case status_m of
                        Just TensionStatus.Open ->
                            [ Ev TensionEvent.Reopened "Closed" "Open" ]

                        Just TensionStatus.Closed ->
                            [ Ev TensionEvent.Closed "Open" "Closed" ]

                        Nothing ->
                            []

                newForm =
                    { form
                        | post = Dict.insert "createdAt" (fromTime time) form.post
                        , status = status_m
                        , events = eventStatus
                    }
            in
            ( { model | tension_form = newForm, tension_patch = LoadingSlowly }
            , send LoadTensionComments
            , Cmd.none
            )

        CommentAck result ->
            case parseErr result model.refresh_trial of
                Authenticate ->
                    ( { model | tension_patch = NotAsked }, Ports.raiseAuthModal (uctxFromUser global.session.user), Cmd.none )

                RefreshToken i ->
                    ( { model | refresh_trial = i }, sendSleep LoadTensionComments 500, send UpdateUserToken )

                OkAuth tp ->
                    let
                        events =
                            model.tension_form.events

                        tension_h =
                            case model.tension_head of
                                Success t ->
                                    Success
                                        { t
                                            | status = withDefault t.status model.tension_form.status
                                            , history =
                                                withDefault [] t.history
                                                    ++ (events
                                                            |> List.map (\e -> eventFromForm e model.tension_form)
                                                       )
                                                    |> Just
                                        }

                                other ->
                                    other

                        tension_c =
                            if (Dict.get "message" model.tension_form.post |> withDefault "") /= "" then
                                case model.tension_comments of
                                    Success t ->
                                        Success { t | comments = Just (withDefault [] t.comments ++ withDefault [] tp.comments) }

                                    other ->
                                        other

                            else
                                model.tension_comments

                        resetForm =
                            initTensionForm model.tensionid global.session.user
                    in
                    ( { model
                        | tension_head = tension_h
                        , tension_comments = tension_c
                        , tension_form = resetForm
                        , tension_patch = result
                      }
                    , Ports.bulma_driver ""
                    , send (UpdateSessionTensionHead (withMaybeData tension_h))
                    )

                _ ->
                    case result of
                        Failure _ ->
                            let
                                form =
                                    model.tension_form

                                resetForm =
                                    { form | status = Nothing }
                            in
                            ( { model | tension_patch = result, tension_form = resetForm }, Cmd.none, Cmd.none )

                        _ ->
                            ( { model | tension_patch = result }, Cmd.none, Cmd.none )

        DoUpdateComment c ->
            let
                form =
                    model.comment_form
            in
            ( { model | comment_form = { form | id = c.id } }, Cmd.batch [ Ports.focusOn "updateCommentInput", Ports.bulma_driver c.createdAt ], Cmd.none )

        CancelCommentPatch ->
            let
                form =
                    model.comment_form
            in
            ( { model | comment_form = { form | id = "" }, comment_result = NotAsked }, Cmd.none, Ports.bulma_driver "" )

        ChangeCommentPost field value ->
            let
                form =
                    model.comment_form
            in
            ( { model | comment_form = { form | post = Dict.insert field value form.post } }, Cmd.none, Cmd.none )

        SubmitCommentPatch time ->
            let
                form =
                    model.comment_form
            in
            ( { model | comment_form = { form | post = Dict.insert "updatedAt" (fromTime time) form.post }, comment_result = LoadingSlowly }, send PushCommentPatch, Cmd.none )

        CommentPatchAck result ->
            case parseErr result model.refresh_trial of
                Authenticate ->
                    ( { model | comment_result = NotAsked }, Ports.raiseAuthModal (uctxFromUser global.session.user), Cmd.none )

                RefreshToken i ->
                    ( { model | refresh_trial = i }, sendSleep PushCommentPatch 500, send UpdateUserToken )

                OkAuth comment ->
                    let
                        tension_c =
                            case model.tension_comments of
                                Success t ->
                                    let
                                        comments =
                                            withDefault [] t.comments

                                        n =
                                            comments
                                                |> LE.findIndex (\c -> c.id == comment.id)
                                                |> withDefault 0
                                    in
                                    Success { t | comments = Just (LE.setAt n comment comments) }

                                other ->
                                    other

                        resetForm =
                            initCommentPatchForm global.session.user
                    in
                    ( { model | tension_comments = tension_c, comment_form = resetForm, comment_result = result }, Cmd.none, Ports.bulma_driver "" )

                _ ->
                    ( { model | comment_result = result }, Cmd.none, Cmd.none )

        DoChangeTitle ->
            ( { model | isTitleEdit = True }, Ports.focusOn "titleInput", Cmd.none )

        CancelTitle ->
            ( { model | isTitleEdit = False, tension_form = initTensionForm model.tensionid global.session.user, title_result = NotAsked }, Cmd.none, Ports.bulma_driver "" )

        SubmitTitle time ->
            let
                form =
                    model.tension_form

                newForm =
                    { form
                        | post =
                            form.post
                                |> Dict.insert "createdAt" (fromTime time)
                        , events =
                            [ Ev TensionEvent.TitleUpdated
                                (model.tension_head |> withMaybeDataMap (\x -> x.title) |> withDefault "")
                                (Dict.get "title" form.post |> withDefault "")
                            ]
                    }
            in
            ( { model | tension_form = newForm, title_result = LoadingSlowly }, send PushTitle, Cmd.none )

        TitleAck result ->
            case parseErr result model.refresh_trial of
                Authenticate ->
                    ( { model | title_result = NotAsked }, Ports.raiseAuthModal (uctxFromUser global.session.user), Cmd.none )

                RefreshToken i ->
                    ( { model | refresh_trial = i }, sendSleep PushTitle 500, send UpdateUserToken )

                OkAuth _ ->
                    let
                        tension_h =
                            case model.tension_head of
                                Success t ->
                                    Success { t | title = Dict.get "title" model.tension_form.post |> withDefault "" }

                                other ->
                                    other

                        resetForm =
                            initTensionForm model.tensionid global.session.user
                    in
                    ( { model | tension_head = tension_h, tension_form = resetForm, title_result = result, isTitleEdit = False }
                    , Ports.bulma_driver ""
                    , send (UpdateSessionTensionHead (withMaybeData tension_h))
                    )

                _ ->
                    ( { model | title_result = result }, Cmd.none, Cmd.none )

        DoMove t ->
            ( model
            , Cmd.batch [ Cmd.map MoveTensionMsg (send (MoveTension.OnOpen t.id t.receiver.nameid (blobFromTensionHead t))) ]
            , Cmd.none
            )

        ChangeBlobEdit value ->
            ( { model | nodeDoc = NodeDoc.setNodeEdit (Just value) model.nodeDoc }, Cmd.none, Cmd.none )

        ChangeBlobPost field value ->
            ( { model | nodeDoc = NodeDoc.updatePost field value model.nodeDoc }, Cmd.none, Cmd.none )

        AddResponsabilities ->
            ( { model | nodeDoc = NodeDoc.addResponsabilities model.nodeDoc }, Cmd.none, Cmd.none )

        AddDomains ->
            ( { model | nodeDoc = NodeDoc.addDomains model.nodeDoc }, Cmd.none, Cmd.none )

        AddPolicies ->
            ( { model | nodeDoc = NodeDoc.addPolicies model.nodeDoc }, Cmd.none, Cmd.none )

        CommitBlob data time ->
            let
                newDoc =
                    data
                        |> NodeDoc.updatePost "createdAt" (fromTime time)
                        |> NodeDoc.setEvents [ Ev TensionEvent.BlobCommitted "" "" ]
                        |> NodeDoc.setResult LoadingSlowly
            in
            ( { model | nodeDoc = newDoc }, send (PushBlob_ newDoc.form), Cmd.none )

        BlobAck result ->
            let
                newDoc =
                    NodeDoc.setResult result model.nodeDoc
            in
            case parseErr result model.refresh_trial of
                Authenticate ->
                    ( { model | nodeDoc = NodeDoc.setResult NotAsked model.nodeDoc }, Ports.raiseAuthModal (uctxFromUser global.session.user), Cmd.none )

                RefreshToken i ->
                    ( { model | refresh_trial = i }, sendSleep (PushBlob_ newDoc.form) 500, send UpdateUserToken )

                OkAuth tp ->
                    let
                        th =
                            case model.tension_head of
                                Success t ->
                                    Success
                                        { t
                                            | blobs = ternary (tp.blobs == Nothing) t.blobs tp.blobs
                                            , history =
                                                withDefault [] t.history
                                                    ++ (model.tension_form.events
                                                            |> List.map (\e -> eventFromForm e model.tension_form)
                                                       )
                                                    |> Just
                                        }

                                other ->
                                    other

                        nd =
                            case th of
                                Success t ->
                                    NodeDoc.initBlob (nodeFromTension t) newDoc

                                _ ->
                                    newDoc
                    in
                    ( { model | tension_head = th, nodeDoc = nd |> NodeDoc.reset }
                    , Ports.bulma_driver ""
                    , send (UpdateSessionTensionHead (withMaybeData th))
                    )

                _ ->
                    ( { model | nodeDoc = newDoc }, Cmd.none, Cmd.none )

        CancelBlob ->
            ( { model | nodeDoc = NodeDoc.reset model.nodeDoc }
            , Cmd.none
            , Ports.bulma_driver ""
            )

        PushBlob bid time ->
            let
                form =
                    model.tension_form

                newForm =
                    { form
                        | events = [ Ev TensionEvent.BlobPushed "" bid ]
                        , post = Dict.fromList [ ( "createdAt", fromTime time ) ]
                    }
            in
            ( { model | tension_form = newForm, publish_result = LoadingSlowly }
            , send PublishBlob
            , Cmd.none
            )

        PushBlobAck result ->
            case parseErr result model.refresh_trial of
                Authenticate ->
                    ( { model | publish_result = NotAsked }, Ports.raiseAuthModal (uctxFromUser global.session.user), Cmd.none )

                RefreshToken i ->
                    ( { model | refresh_trial = i }, sendSleep PublishBlob 500, send UpdateUserToken )

                OkAuth r ->
                    case model.tension_head of
                        Success th ->
                            let
                                blobs =
                                    th.blobs
                                        |> Maybe.map
                                            (\bs ->
                                                bs
                                                    |> List.head
                                                    |> Maybe.map
                                                        (\b -> [ { b | pushedFlag = withDefault [] r.blobs |> List.head |> Maybe.map .pushedFlag |> withDefault b.pushedFlag } ])
                                            )
                                        |> withDefault Nothing

                                newTh =
                                    { th | blobs = blobs, title = r.title }

                                resetForm =
                                    initTensionForm model.tensionid global.session.user
                            in
                            ( { model
                                | publish_result = result
                                , tension_head = Success newTh
                                , tension_form = resetForm
                                , hasBeenPushed = True
                              }
                            , Cmd.none
                            , Cmd.batch [ send UpdateUserToken, send (UpdateSessionTensionHead (Just newTh)) ]
                            )

                        _ ->
                            ( { model | publish_result = result }, Cmd.none, Cmd.none )

                _ ->
                    ( { model | publish_result = result }, Cmd.none, Cmd.none )

        -- Assignees
        DoAssigneeEdit ->
            let
                targets =
                    model.path_data |> withMaybeDataMap (\x -> List.map (\y -> y.nameid) x.path) |> withDefault []
            in
            ( model, Cmd.map UserSearchPanelMsg (send (UserSearchPanel.OnOpen targets)), Cmd.none )

        UserSearchPanelMsg msg ->
            let
                ( panel, out ) =
                    UserSearchPanel.update apis msg model.assigneesPanel

                th =
                    Maybe.map
                        (\r ->
                            withMapData
                                (\x ->
                                    let
                                        assignees =
                                            if Tuple.first r == True then
                                                withDefault [] x.assignees ++ [ Tuple.second r ]

                                            else
                                                LE.remove (Tuple.second r) (withDefault [] x.assignees)
                                    in
                                    { x | assignees = Just assignees }
                                )
                                model.tension_head
                        )
                        out.result
                        |> withDefault model.tension_head

                isAssigneeOpen =
                    UserSearchPanel.isOpen_ panel

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds
            in
            ( { model | assigneesPanel = panel, tension_head = th, isAssigneeOpen = isAssigneeOpen }
            , out.cmds |> List.map (\m -> Cmd.map UserSearchPanelMsg m) |> List.append cmds |> Cmd.batch
            , Cmd.batch (gcmds ++ [ send (UpdateSessionTensionHead (withMaybeData th)) ])
            )

        -- Labels
        DoLabelEdit ->
            let
                targets =
                    getCircles model.path_data
            in
            ( model, Cmd.map LabelSearchPanelMsg (send (LabelSearchPanel.OnOpen targets False)), Cmd.none )

        LabelSearchPanelMsg msg ->
            let
                ( panel, out ) =
                    LabelSearchPanel.update apis msg model.labelsPanel

                th =
                    Maybe.map
                        (\r ->
                            withMapData
                                (\x ->
                                    let
                                        labels =
                                            if Tuple.first r == True then
                                                withDefault [] x.labels ++ [ Tuple.second r ]

                                            else
                                                LE.remove (Tuple.second r) (withDefault [] x.labels)
                                    in
                                    { x | labels = Just labels }
                                )
                                model.tension_head
                        )
                        out.result
                        |> withDefault model.tension_head

                isLabelOpen =
                    LabelSearchPanel.isOpen_ panel

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds
            in
            ( { model | labelsPanel = panel, tension_head = th, isLabelOpen = isLabelOpen }
            , out.cmds |> List.map (\m -> Cmd.map LabelSearchPanelMsg m) |> List.append cmds |> Cmd.batch
            , Cmd.batch (gcmds ++ [ send (UpdateSessionTensionHead (withMaybeData th)) ])
            )

        -- Node Action
        OpenActionPanel domid nameid pos ->
            ( model, Cmd.map ActionPanelMsg (send <| ActionPanel.OnOpen domid nameid (TreeMenu.getOrgaData_ model.treeMenu) pos), Cmd.none )

        NewTensionMsg msg ->
            let
                ( tf, out ) =
                    NTF.update apis msg model.tensionForm

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds
            in
            ( { model | tensionForm = tf }, out.cmds |> List.map (\m -> Cmd.map NewTensionMsg m) |> List.append cmds |> Cmd.batch, Cmd.batch gcmds )

        -- Common
        NoMsg ->
            ( model, Cmd.none, Cmd.none )

        LogErr err ->
            ( model, Ports.logErr err, Cmd.none )

        Navigate url ->
            ( model, Cmd.none, Nav.pushUrl global.key url )

        ChangeInputViewMode viewMode ->
            ( { model | inputViewMode = viewMode }, Cmd.none, Cmd.none )

        ChangeUpdateViewMode viewMode ->
            let
                form =
                    model.comment_form
            in
            ( { model | comment_form = { form | viewMode = viewMode } }, Cmd.none, Cmd.none )

        ExpandRoles ->
            ( { model | helperBar = HelperBar.expand model.helperBar }, Cmd.none, Cmd.none )

        CollapseRoles ->
            ( { model | helperBar = HelperBar.collapse model.helperBar }, Cmd.none, Cmd.none )

        ScrollToElement did ->
            ( model, Scroll.scrollToElement did NoMsg, Cmd.none )

        UpdateUctx uctx ->
            ( { model
                | isTensionAdmin = getTensionRights uctx model.tension_head model.path_data
                , nodeDoc = NodeDoc.setUctx uctx model.nodeDoc
              }
            , Cmd.none
            , Cmd.none
            )

        -- Components
        HelpMsg msg ->
            let
                ( help, out ) =
                    Help.update apis msg model.help

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds
            in
            ( { model | help = help }, out.cmds |> List.map (\m -> Cmd.map HelpMsg m) |> List.append cmds |> Cmd.batch, Cmd.batch gcmds )

        MoveTensionMsg msg ->
            let
                ( data, out ) =
                    MoveTension.update apis msg model.moveTension

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds
            in
            ( { model | moveTension = data }, out.cmds |> List.map (\m -> Cmd.map MoveTensionMsg m) |> List.append cmds |> Cmd.batch, Cmd.batch gcmds )

        ContractsPageMsg msg ->
            let
                ( data, out ) =
                    ContractsPage.update apis msg model.contractsPage

                th =
                    Maybe.map
                        (\r ->
                            --withMapData (\x -> { x | contracts = Just (Tuple.second r) }) model.tension_head
                            withMapData (\x -> { x | contracts = Just [ { id = x.id } ] }) model.tension_head
                        )
                        out.result
                        |> withDefault model.tension_head

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds
            in
            ( { model | contractsPage = data, tension_head = th }
            , out.cmds |> List.map (\m -> Cmd.map ContractsPageMsg m) |> List.append cmds |> Cmd.batch
            , Cmd.batch (gcmds ++ [ send (UpdateSessionTensionHead (withMaybeData th)) ])
            )

        SelectTypeMsg msg ->
            let
                ( data, out ) =
                    SelectType.update apis msg model.selectType

                th =
                    out.result
                        |> Maybe.map
                            (\( _, r ) ->
                                withMapData (\x -> { x | type_ = r }) model.tension_head
                            )
                        |> withDefault model.tension_head

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds
            in
            ( { model | selectType = data, tension_head = th }
            , out.cmds |> List.map (\m -> Cmd.map SelectTypeMsg m) |> List.append cmds |> Cmd.batch
            , Cmd.batch (gcmds ++ [ send (UpdateSessionTensionHead (withMaybeData th)) ])
            )

        ActionPanelMsg msg ->
            let
                ( data, out ) =
                    ActionPanel.update apis msg model.actionPanel

                -- Update NodeFragment locally
                th =
                    Maybe.map
                        (\r ->
                            withMapData
                                (\x ->
                                    let
                                        blobs =
                                            Maybe.map (\y -> List.map (\b -> { b | node = Just <| nodeFragmentUpdate b.node r }) y) x.blobs
                                    in
                                    { x | blobs = blobs }
                                )
                                model.tension_head
                        )
                        out.result
                        |> withDefault model.tension_head

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds
            in
            ( { model | actionPanel = data, tension_head = th }, out.cmds |> List.map (\m -> Cmd.map ActionPanelMsg m) |> List.append cmds |> Cmd.batch, Cmd.batch gcmds )

        JoinOrgaMsg msg ->
            let
                ( data, out ) =
                    JoinOrga.update apis msg model.joinOrga

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds
            in
            ( { model | joinOrga = data }, out.cmds |> List.map (\m -> Cmd.map JoinOrgaMsg m) |> List.append cmds |> Cmd.batch, Cmd.batch gcmds )

        AuthModalMsg msg ->
            let
                ( data, out ) =
                    AuthModal.update apis msg model.authModal

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds

                cmds_extra =
                    out.result
                        |> Maybe.map
                            (\o ->
                                if Tuple.first o == True then
                                    -- reload silently the page if needed
                                    [ Nav.replaceUrl global.key (Url.toString global.url) ]

                                else
                                    []
                            )
                        |> withDefault []
            in
            ( { model | authModal = data }, out.cmds |> List.map (\m -> Cmd.map AuthModalMsg m) |> List.append (cmds ++ cmds_extra) |> Cmd.batch, Cmd.batch gcmds )

        OrgaMenuMsg msg ->
            let
                ( data, out ) =
                    OrgaMenu.update apis msg model.orgaMenu

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds
            in
            ( { model | orgaMenu = data }, out.cmds |> List.map (\m -> Cmd.map OrgaMenuMsg m) |> List.append cmds |> Cmd.batch, Cmd.batch gcmds )

        TreeMenuMsg msg ->
            let
                ( data, out ) =
                    TreeMenu.update apis msg model.treeMenu

                ( cmds, gcmds ) =
                    mapGlobalOutcmds out.gcmds
            in
            ( { model | treeMenu = data }, out.cmds |> List.map (\m -> Cmd.map TreeMenuMsg m) |> List.append cmds |> Cmd.batch, Cmd.batch gcmds )


subscriptions : Global.Model -> Model -> Sub Msg
subscriptions _ model =
    [ Ports.uctxPD Ports.loadUserCtxFromJs LogErr UpdateUctx
    ]
        ++ (Help.subscriptions |> List.map (\s -> Sub.map HelpMsg s))
        ++ (NTF.subscriptions model.tensionForm |> List.map (\s -> Sub.map NewTensionMsg s))
        ++ (ActionPanel.subscriptions model.actionPanel |> List.map (\s -> Sub.map ActionPanelMsg s))
        ++ (JoinOrga.subscriptions model.joinOrga |> List.map (\s -> Sub.map JoinOrgaMsg s))
        ++ (AuthModal.subscriptions |> List.map (\s -> Sub.map AuthModalMsg s))
        ++ (OrgaMenu.subscriptions |> List.map (\s -> Sub.map OrgaMenuMsg s))
        ++ (UserSearchPanel.subscriptions model.assigneesPanel |> List.map (\s -> Sub.map UserSearchPanelMsg s))
        ++ (LabelSearchPanel.subscriptions model.labelsPanel |> List.map (\s -> Sub.map LabelSearchPanelMsg s))
        ++ (MoveTension.subscriptions |> List.map (\s -> Sub.map MoveTensionMsg s))
        ++ (ContractsPage.subscriptions |> List.map (\s -> Sub.map ContractsPageMsg s))
        ++ (SelectType.subscriptions |> List.map (\s -> Sub.map SelectTypeMsg s))
        ++ (TreeMenu.subscriptions |> List.map (\s -> Sub.map TreeMenuMsg s))
        |> Sub.batch



---- VIEW ----


view : Global.Model -> Model -> Document Msg
view global model =
    let
        helperData =
            { user = global.session.user
            , uriQuery = global.url.query
            , path_data = withMaybeData model.path_data
            , focus = model.node_focus
            , baseUri = model.baseUri
            , data = model.helperBar
            , onExpand = ExpandRoles
            , onCollapse = CollapseRoles
            , onToggleTreeMenu = TreeMenuMsg TreeMenu.OnToggle
            , onJoin = JoinOrgaMsg (JoinOrga.OnOpen model.node_focus.rootnameid JoinOrga.JoinOne)
            , onOpenPanel = ternary (ActionPanel.isOpen_ "actionPanelHelper" model.actionPanel) (\_ _ _ -> NoMsg) OpenActionPanel
            }

        panelData =
            { tc = { action = TensionAction.EditRole, action_type = EDIT, doc_type = NODE NodeType.Role }
            , isRight = True
            , domid = "actionPanelHelper"
            , tree_data = TreeMenu.getOrgaData_ model.treeMenu
            }
    in
    { title =
        case model.tension_head of
            Success t ->
                t.title

            _ ->
                "Loading..."
    , body =
        [ div [ class "orgPane" ]
            [ HelperBar.view helperData
            , div [ id "mainPane" ] [ view_ global model ]
            ]
        , Help.view model.empty model.help |> Html.map HelpMsg
        , NTF.view { tree_data = TreeMenu.getOrgaData_ model.treeMenu, path_data = model.path_data } model.tensionForm |> Html.map NewTensionMsg
        , MoveTension.view { tree_data = TreeMenu.getOrgaData_ model.treeMenu } model.moveTension |> Html.map MoveTensionMsg
        , SelectType.view model.empty model.selectType |> Html.map SelectTypeMsg
        , JoinOrga.view model.empty model.joinOrga |> Html.map JoinOrgaMsg
        , AuthModal.view model.empty model.authModal |> Html.map AuthModalMsg
        , OrgaMenu.view model.empty model.orgaMenu |> Html.map OrgaMenuMsg
        , TreeMenu.view model.empty model.treeMenu |> Html.map TreeMenuMsg
        , ActionPanel.view panelData model.actionPanel |> Html.map ActionPanelMsg
        ]
    }


view_ : Global.Model -> Model -> Html Msg
view_ global model =
    div [ class "columns is-centered" ]
        [ div [ class "column is-12 is-11-desktop is-9-fullhd" ]
            [ case model.tension_head of
                Success t ->
                    viewTension global.session.user t model

                Failure err ->
                    -- If user has only contract visibility right...
                    --if ContractsPage.hasCid model.contractsPage then
                    --    ContractsPage.view { emitterid = "", receiverid = "", isAdmin = model.isTensionAdmin, now = model.now } model.contractsPage
                    --        |> Html.map ContractsPageMsg
                    --else
                    viewGqlErrors err

                LoadingSlowly ->
                    div [ class "spinner" ] []

                other ->
                    text ""

            -- User notification
            , if isSuccess model.subscribe_result && model.unsubscribe /= "" then
                div [ class "f6-notification notification is-success-light" ]
                    [ button [ class "delete", onClick OnCloseUnsubscribe ] []
                    , text T.beenUnsubscribe
                    ]

              else
                text ""
            ]
        ]


viewTension : UserState -> TensionHead -> Model -> Html Msg
viewTension u t model =
    let
        uctx_m =
            case u of
                LoggedIn uctx ->
                    Just uctx

                LoggedOut ->
                    Nothing

        isAuthor =
            Maybe.map (\uctx -> t.createdBy.username == uctx.username) uctx_m |> withDefault False

        blob_m =
            t.blobs |> withDefault [] |> List.head
    in
    div []
        [ div [ class "columns is-marginless" ]
            -- @DEBUG: width corresponding to is-9 is hard-coded in modal-content (below) to
            -- avoid overflow with no scroll caude by <pre> tag
            [ div [ class "column is-9 px-0" ]
                [ h1 [ class "title tensionTitle" ] <|
                    if model.isTitleEdit then
                        let
                            title =
                                Dict.get "title" model.tension_form.post |> withDefault t.title

                            isLoading =
                                model.title_result == LoadingSlowly

                            isSendable =
                                title /= t.title

                            doSubmit =
                                ternary isSendable [ onClick (Submit isLoading <| SubmitTitle) ] []
                        in
                        [ div [ class "field is-grouped" ]
                            [ p [ class "control is-expanded" ]
                                [ input
                                    [ id "titleInput"
                                    , class "input is-human"
                                    , type_ "text"
                                    , placeholder "Title*"
                                    , spellcheck True
                                    , value title
                                    , onInput (ChangeTensionPost "title")
                                    ]
                                    []
                                ]
                            , p [ class "control buttons" ]
                                [ button
                                    ([ class "button is-success is-small"
                                     , classList [ ( "is-loading", isLoading ) ]
                                     , disabled (not isSendable)
                                     ]
                                        ++ doSubmit
                                    )
                                    [ text T.update ]
                                , button [ class "button is-small", onClick CancelTitle ] [ text T.cancel ]
                                ]
                            ]
                        , viewMaybeErrors model.title_result
                        ]

                    else
                        [ span [ class "is-human" ] [ text t.title ]
                        , if (model.isTensionAdmin || isAuthor) && blob_m == Nothing then
                            div
                                [ class "button has-text-weight-normal is-pulled-right is-small tooltip has-tooltip-arrow"
                                , attribute "data-tooltip" T.editTitle
                                , style "vertical-align" "middle" -- @needHelp do not work with pulled right.
                                , onClick DoChangeTitle
                                ]
                                [ A.icon "icon-edit-2" ]

                          else
                            text ""
                        ]
                , div [ class "tensionSubtitle" ]
                    [ span
                        [ class "tag is-rounded is-light"
                        , classList [ ( "is-w", model.isTensionAdmin || isAuthor ) ]
                        , ternary (model.isTensionAdmin || isAuthor) (onClick <| SelectTypeMsg (SelectType.OnOpen t.type_)) (onClick NoMsg)
                        ]
                        [ tensionIcon2 t.type_ ]
                    , if t.type_ /= TensionType.Governance || t.status == TensionStatus.Open then
                        -- As Governance tension get automatically closed when there are created,
                        -- there status is not relevant, I can cause confusion to user as the object exists.
                        span [ class ("is-w tag is-rounded is-" ++ statusColor t.status), onClick (ScrollToElement "tensionCommentInput") ]
                            [ t.status |> tensionStatus2String |> text ]

                      else
                        text ""
                    , viewTensionDateAndUser model.lang model.now "is-discrete" t.createdAt t.createdBy
                    , viewCircleTarget "is-pulled-right" t.receiver
                    ]
                ]
            ]
        , div [ class "columns is-centered is-variable is-4" ]
            [ div [ class "column is-9" ]
                [ div [ class "tabs is-md" ]
                    [ ul []
                        [ li [ classList [ ( "is-active", model.activeTab == Conversation ) ] ]
                            [ a [ href (Route.Tension_Dynamic_Dynamic { param1 = model.node_focus.rootnameid, param2 = t.id } |> toHref) ]
                                [ A.icon1 "icon-message-square" T.conversation ]
                            ]
                        , if t.blobs /= Nothing && t.blobs /= Just [] then
                            li [ classList [ ( "is-active", model.activeTab == Document ) ] ]
                                [ a [ href (Route.Tension_Dynamic_Dynamic_Action { param1 = model.node_focus.rootnameid, param2 = t.id } |> toHref) ]
                                    [ A.icon1 "icon-copy" T.document ]
                                ]

                          else
                            text ""
                        , if t.contracts /= Nothing && t.contracts /= Just [] then
                            li [ classList [ ( "is-active", model.activeTab == Contracts ) ] ]
                                [ a [ href (Route.Tension_Dynamic_Dynamic_Contract { param1 = model.node_focus.rootnameid, param2 = t.id } |> toHref) ]
                                    [ A.icon1 "icon-link-2" T.contracts ]
                                ]

                          else
                            text ""
                        ]
                    ]
                , case model.activeTab of
                    Conversation ->
                        viewConversation u t model

                    Document ->
                        case t.blobs |> withDefault [] of
                            [ b ] ->
                                viewDocument u t b model

                            _ ->
                                div [] [ text "No document yet..." ]

                    Contracts ->
                        case t.contracts |> withDefault [] of
                            [ c ] ->
                                ContractsPage.view { emitterid = t.emitter.nameid, receiverid = t.receiver.nameid, isAdmin = model.isTensionAdmin, now = model.now, lang = model.lang } model.contractsPage
                                    |> Html.map ContractsPageMsg

                            _ ->
                                div [] [ text "No contracts yet..." ]
                ]
            , div [ class "column is-3" ]
                [ viewSidePane u t model ]
            ]
        ]


viewConversation : UserState -> TensionHead -> Model -> Html Msg
viewConversation u t model =
    let
        userInput =
            case u of
                LoggedIn uctx ->
                    -- Author or member can comment tension.
                    if
                        -- is Author
                        uctx.username
                            == t.createdBy.username
                            || -- is Member
                               getOrgaRoles [ t.emitter.nameid, t.receiver.nameid ] uctx.roles
                            /= []
                    then
                        let
                            opNew =
                                { doChangeViewMode = ChangeInputViewMode
                                , doChangePost = ChangeTensionPost
                                , doSubmit = Submit
                                , doSubmitComment = SubmitComment
                                }
                        in
                        viewCommentInput opNew uctx t model.tension_form model.tension_patch model.inputViewMode

                    else
                        viewJoinNeeded model.node_focus

                LoggedOut ->
                    let
                        userCanJoin =
                            withMaybeData model.path_data
                                |> Maybe.map
                                    (\path ->
                                        path.root |> Maybe.map (\r -> r.userCanJoin == Just True) |> withDefault False
                                    )
                                |> withDefault False
                    in
                    if userCanJoin then
                        viewJoinNeeded model.node_focus

                    else
                        text ""
    in
    case model.tension_comments of
        Success comments ->
            div [ class "comments" ]
                [ Lazy.lazy8 viewComments model.lang model.now t.action t.history comments model.comment_form model.comment_result model.expandedEvents
                , hr [ class "has-background-border-light is-2" ] []
                , userInput
                ]

        Failure err ->
            viewGqlErrors err

        LoadingSlowly ->
            div [ class "spinner" ] []

        other ->
            text ""


viewComments :
    Lang.Lang
    -> Time.Posix
    -> Maybe TensionAction.TensionAction
    -> Maybe (List Event)
    -> TensionComments
    -> CommentPatchForm
    -> GqlData Comment
    -> List Int
    -> Html Msg
viewComments lang now action history_m comments_m comment_form comment_result expandedEvents =
    let
        comments =
            withDefault [] comments_m.comments

        history =
            withDefault [] history_m

        allEvts =
            -- When event and comment are created at the same time, show the comment first.
            List.indexedMap (\i c -> { type_ = Nothing, createdAt = c.createdAt, i = i, n = 0 }) comments
                ++ List.indexedMap (\i e -> { type_ = Just e.event_type, createdAt = e.createdAt, i = i, n = 0 }) history
                |> List.sortBy .createdAt

        viewCommentOrEvent : { type_ : Maybe TensionEvent.TensionEvent, createdAt : String, i : Int, n : Int } -> Html Msg
        viewCommentOrEvent e =
            case e.type_ of
                Just _ ->
                    case LE.getAt e.i history of
                        Just event ->
                            viewEvent lang now action event

                        Nothing ->
                            text ""

                Nothing ->
                    case LE.getAt e.i comments of
                        Just c ->
                            let
                                op =
                                    { doUpdate = DoUpdateComment
                                    , doCancelComment = CancelCommentPatch
                                    , doChangeViewMode = ChangeUpdateViewMode
                                    , doChangePost = ChangeCommentPost
                                    , doSubmit = Submit
                                    , doEditComment = SubmitCommentPatch
                                    , now = now
                                    }
                            in
                            viewComment op c comment_form comment_result

                        Nothing ->
                            text ""
    in
    allEvts
        -- Filter events if there a above a given number.
        -- If above, we keep track of the extra number of event
        -- until a non-event (i.e a comment) is met.
        |> LE.indexedFoldr
            (\i e d ->
                let
                    evts =
                        Tuple.first d

                    state =
                        Tuple.second d

                    isAbove =
                        (List.length evts > 6)
                            && (e.type_ /= Nothing)
                            && (evts
                                    |> List.take 6
                                    |> List.filter (\x -> x.type_ == Nothing)
                                    |> List.length
                               )
                            == 0

                    isClicked =
                        state.isClicked || List.member i expandedEvents
                in
                if e.type_ == Just TensionEvent.Created then
                    -- Ignore these type
                    ( evts, state )

                else if isAbove && state.nskip == 0 && isClicked == False then
                    ( evts, { state | nskip = 1, i = i } )

                else if isAbove && state.nskip > 0 && state.isClicked == False then
                    ( evts, { state | nskip = state.nskip + 1 } )

                else if state.nskip > 0 && e.type_ == Nothing && state.isClicked == False then
                    let
                        btn =
                            { type_ = Nothing, n = state.nskip, createdAt = "", i = state.i }
                    in
                    ( [ e ] ++ [ btn ] ++ evts, { state | nskip = 0, isClicked = False } )

                else if e.type_ == Nothing then
                    ( [ e ] ++ evts, { state | nskip = 0, isClicked = False } )

                else
                    ( [ e ] ++ evts, { state | isClicked = isClicked } )
            )
            -- The tuple.first: filterered list of events
            -- The tuple.second: state of the fold loop. We stored the skips when a new comment is
            -- encoutered in order to insert a button later at the current position.
            ( [], { nskip = 0, isCollapsed = True, isClicked = False, i = 0 } )
        |> Tuple.first
        |> List.map
            (\x ->
                if x.n > 0 then
                    div
                        [ class "button is-small actionComment m-4"
                        , attribute "style" "left:10%;"
                        , onClick (ExpandEvent x.i)
                        ]
                        [ text (T.showOlderEvents |> Format.value (String.fromInt x.n)) ]

                else
                    Lazy.lazy viewCommentOrEvent x
            )
        |> div []


viewEvent : Lang.Lang -> Time.Posix -> Maybe TensionAction.TensionAction -> Event -> Html Msg
viewEvent lang now action event =
    let
        eventView =
            case event.event_type of
                TensionEvent.Reopened ->
                    viewEventStatus lang now event TensionStatus.Open

                TensionEvent.Closed ->
                    viewEventStatus lang now event TensionStatus.Closed

                TensionEvent.TitleUpdated ->
                    viewEventTitle lang now event

                TensionEvent.TypeUpdated ->
                    viewEventType lang now event

                TensionEvent.Visibility ->
                    viewEventVisibility lang now event

                TensionEvent.Authority ->
                    viewEventAuthority lang now event action

                TensionEvent.AssigneeAdded ->
                    viewEventAssignee lang now event True

                TensionEvent.AssigneeRemoved ->
                    viewEventAssignee lang now event False

                TensionEvent.LabelAdded ->
                    viewEventLabel lang now event True

                TensionEvent.LabelRemoved ->
                    viewEventLabel lang now event False

                TensionEvent.BlobPushed ->
                    viewEventPushed lang now event action

                TensionEvent.BlobArchived ->
                    viewEventArchived lang now event action True

                TensionEvent.BlobUnarchived ->
                    viewEventArchived lang now event action False

                TensionEvent.MemberLinked ->
                    viewEventMemberLinked lang now event action

                TensionEvent.MemberUnlinked ->
                    viewEventMemberUnlinked lang now event action

                TensionEvent.UserJoined ->
                    viewEventUserJoined lang now event action

                TensionEvent.UserLeft ->
                    viewEventUserLeft lang now event action

                TensionEvent.Moved ->
                    viewEventMoved lang now event

                _ ->
                    []
    in
    if eventView == [] then
        text ""

    else
        div [ id event.createdAt, class "media is-paddingless actionComment" ] eventView


viewEventStatus : Lang.Lang -> Time.Posix -> Event -> TensionStatus.TensionStatus -> List (Html Msg)
viewEventStatus lang now event status =
    let
        ( actionIcon, actionText ) =
            case status of
                TensionStatus.Open ->
                    ( "icon-alert-circle", T.reopened2 )

                TensionStatus.Closed ->
                    ( "icon-alert-circle", T.closed2 )
    in
    [ span [ class "media-left", style "margin-left" "-4px" ] [ A.icon (actionIcon ++ " icon-1half has-text-" ++ statusColor status) ]
    , span [ class "media-content", attribute "style" "padding-top: 4px;margin-left: -4px" ]
        [ span [] <| List.intersperse (text " ") [ viewUsernameLink event.createdBy.username, strong [] [ text actionText ], text (formatDate lang now event.createdAt) ]
        ]
    ]


viewEventTitle : Lang.Lang -> Time.Posix -> Event -> List (Html Msg)
viewEventTitle lang now event =
    let
        icon =
            A.icon "icon-edit-2"
    in
    [ div [ class "media-left" ] [ icon ]
    , div [ class "media-content" ]
        [ span [] <| List.intersperse (text " ") [ viewUsernameLink event.createdBy.username, text T.updated2, span [ class "is-strong" ] [ text T.theSubject ], text (formatDate lang now event.createdAt) ]
        , span [ class "ml-3" ]
            [ span [ class "is-strong is-crossed" ] [ event.old |> withDefault "" |> text ]
            , span [ class "arrow-right" ] []
            , span [ class "is-strong" ] [ event.new |> withDefault "" |> text ]
            ]
        ]
    ]


viewEventType : Lang.Lang -> Time.Posix -> Event -> List (Html Msg)
viewEventType lang now event =
    let
        icon =
            A.icon "icon-edit-2"
    in
    [ div [ class "media-left" ] [ icon ]
    , div [ class "media-content" ]
        [ span [] <| List.intersperse (text " ") [ viewUsernameLink event.createdBy.username, text T.changed2, span [ class "is-strong" ] [ text T.theType_ ], text (formatDate lang now event.createdAt) ]
        , span [ class "ml-3" ]
            [ span [ class "is-strong" ] [ event.old |> withDefault "" |> TensionType.fromString |> withDefault TensionType.Operational |> tensionIcon2 ]
            , span [ class "arrow-right" ] []
            , span [ class "is-strong" ] [ event.new |> withDefault "" |> TensionType.fromString |> withDefault TensionType.Operational |> tensionIcon2 ]
            ]
        ]
    ]


viewEventVisibility : Lang.Lang -> Time.Posix -> Event -> List (Html Msg)
viewEventVisibility lang now event =
    let
        icon =
            A.icon "icon-eye"
    in
    [ div [ class "media-left" ] [ icon ]
    , div [ class "media-content" ]
        [ span [] <| List.intersperse (text " ") [ viewUsernameLink event.createdBy.username, text T.changed2, span [ class "is-strong" ] [ text T.theVisibility ], text (formatDate lang now event.createdAt) ]
        , span [ class "ml-3" ]
            [ span [ class "is-strong" ] [ event.old |> withDefault "" |> text ]
            , span [ class "arrow-right" ] []
            , span [ class "is-strong" ] [ event.new |> withDefault "" |> text ]
            ]
        ]
    ]


viewEventAuthority : Lang.Lang -> Time.Posix -> Event -> Maybe TensionAction.TensionAction -> List (Html Msg)
viewEventAuthority lang now event action =
    let
        ( icon, eventText ) =
            case tensionAction2NodeType action of
                Just NodeType.Circle ->
                    ( A.icon "icon-key", T.theGovernance )

                Just NodeType.Role ->
                    ( A.icon "icon-key", T.theAuthority )

                _ ->
                    ( A.icon "icon-key", "unknown action" )
    in
    [ div [ class "media-left" ] [ icon ]
    , div [ class "media-content" ]
        [ span [] <| List.intersperse (text " ") [ viewUsernameLink event.createdBy.username, text T.changed2, span [ class "is-strong" ] [ text eventText ], text (formatDate lang now event.createdAt) ]
        , span [ class "ml-3" ]
            [ span [ class "is-strong" ] [ event.old |> withDefault "" |> text ]
            , span [ class "arrow-right" ] []
            , span [ class "is-strong" ] [ event.new |> withDefault "" |> text ]
            ]
        ]
    ]


viewEventAssignee : Lang.Lang -> Time.Posix -> Event -> Bool -> List (Html Msg)
viewEventAssignee lang now event isNew =
    let
        icon =
            A.icon "icon-user"

        ( actionText, value ) =
            if isNew then
                ( T.assigned2, withDefault "" event.new )

            else
                ( T.unassigned2, withDefault "" event.old )
    in
    [ div [ class "media-left" ] [ icon ]
    , div [ class "media-content" ]
        [ span [] <|
            List.intersperse (text " ")
                [ viewUsernameLink event.createdBy.username, strong [] [ text actionText ], viewUsernameLink value, text (formatDate lang now event.createdAt) ]
        ]
    ]


viewEventLabel : Lang.Lang -> Time.Posix -> Event -> Bool -> List (Html Msg)
viewEventLabel lang now event isNew =
    let
        icon =
            A.icon "icon-tag"

        ( actionText, value ) =
            if isNew then
                ( T.addedTheLabel, withDefault "unknown" event.new )

            else
                ( T.removedTheLabel, withDefault "unknown" event.old )

        label =
            Label "" (SE.leftOfBack "§" value) (SE.rightOfBack "§" value |> Just) []
    in
    [ div [ class "media-left" ] [ icon ]
    , div [ class "media-content" ]
        [ span [] <|
            List.intersperse (text " ")
                [ viewUsernameLink event.createdBy.username, strong [] [ text actionText ], viewLabel "" Nothing label, text (formatDate lang now event.createdAt) ]
        ]
    ]


viewEventPushed : Lang.Lang -> Time.Posix -> Event -> Maybe TensionAction.TensionAction -> List (Html Msg)
viewEventPushed lang now event action_m =
    let
        action =
            withDefault TensionAction.NewRole action_m
    in
    [ div [ class "media-left" ] [ A.icon "icon-share" ]
    , div [ class "media-content" ]
        [ span [] <| List.intersperse (text " ") [ viewUsernameLink event.createdBy.username, strong [] [ text T.published2 ], text T.this, textD (action2str action), text (formatDate lang now event.createdAt) ]
        ]
    ]


viewEventArchived : Lang.Lang -> Time.Posix -> Event -> Maybe TensionAction.TensionAction -> Bool -> List (Html Msg)
viewEventArchived lang now event action_m isArchived =
    let
        action =
            withDefault TensionAction.NewRole action_m

        ( icon, txt ) =
            if isArchived then
                ( A.icon "icon-archive", T.archived2 )

            else
                ( i [ class "icon-archive icon-is-slashed" ] [], T.unarchived2 )
    in
    [ div [ class "media-left" ] [ icon ]
    , div [ class "media-content" ]
        [ span [] <| List.intersperse (text " ") [ viewUsernameLink event.createdBy.username, strong [] [ text txt ], text T.this, textD (action2str action), text (formatDate lang now event.createdAt) ]
        ]
    ]


viewEventMemberLinked : Lang.Lang -> Time.Posix -> Event -> Maybe TensionAction.TensionAction -> List (Html Msg)
viewEventMemberLinked lang now event action_m =
    [ div [ class "media-left" ] [ A.icon "icon-user-check has-text-success" ]
    , div [ class "media-content" ]
        [ span [] <| List.intersperse (text " ") [ viewUsernameLink (withDefault "" event.new), strong [] [ text T.linked2 ], text T.toThisRole, text (formatDate lang now event.createdAt) ]
        ]
    ]


viewEventMemberUnlinked : Lang.Lang -> Time.Posix -> Event -> Maybe TensionAction.TensionAction -> List (Html Msg)
viewEventMemberUnlinked lang now event action_m =
    let
        action_txt =
            case (getTensionCharac (withDefault TensionAction.NewRole action_m)).doc_type of
                NODE NodeType.Circle ->
                    T.toThisOrganisation

                _ ->
                    T.toThisRole
    in
    [ div [ class "media-left" ] [ A.icon "icon-user has-text-danger" ]
    , div [ class "media-content" ]
        [ span [] <| List.intersperse (text " ") [ viewUsernameLink (withDefault "" event.old), strong [] [ text T.unlinked2 ], text action_txt, text (formatDate lang now event.createdAt) ]
        ]
    ]


viewEventUserJoined : Lang.Lang -> Time.Posix -> Event -> Maybe TensionAction.TensionAction -> List (Html Msg)
viewEventUserJoined lang now event action_m =
    let
        action_txt =
            T.theOrganisation
    in
    [ div [ class "media-left" ] [ A.icon "icon-log-in" ]
    , div [ class "media-content" ]
        [ span [] <| List.intersperse (text " ") [ viewUsernameLink (withDefault "" event.new), strong [] [ text T.joined2 ], text action_txt, text (formatDate lang now event.createdAt) ]
        ]
    ]


viewEventUserLeft : Lang.Lang -> Time.Posix -> Event -> Maybe TensionAction.TensionAction -> List (Html Msg)
viewEventUserLeft lang now event action_m =
    let
        action =
            withDefault TensionAction.NewRole action_m

        action_txt =
            case event.new of
                Just type_ ->
                    case RoleType.fromString type_ of
                        Just RoleType.Guest ->
                            T.theOrganisation

                        _ ->
                            T.this ++ " " ++ decap T.role

                Nothing ->
                    action2str action |> decap
    in
    [ div [ class "media-left" ] [ A.icon "icon-log-out" ]
    , div [ class "media-content" ]
        [ span [] <| List.intersperse (text " ") [ viewUsernameLink (withDefault "" event.old), strong [] [ text T.left2 ], text action_txt, text (formatDate lang now event.createdAt) ]
        ]
    ]


viewEventMoved : Lang.Lang -> Time.Posix -> Event -> List (Html Msg)
viewEventMoved lang now event =
    [ div [ class "media-left" ] [ span [ class "arrow-right2 pl-0 pr-0 mr-0" ] [] ]
    , div [ class "media-content" ]
        [ span [] <|
            List.intersperse (text " ")
                [ viewUsernameLink event.createdBy.username
                , strong [] [ text T.moved2 ]
                , text T.from
                , event.old |> Maybe.map (\nid -> viewNodeRefShort OverviewBaseUri nid) |> withDefault (text "unknown")
                , text T.to
                , event.new |> Maybe.map (\nid -> viewNodeRefShort OverviewBaseUri nid) |> withDefault (text "unknown")
                , text (formatDate lang now event.createdAt)
                ]
        ]
    ]



--
-- </ View Event>
--


viewDocument : UserState -> TensionHead -> Blob -> Model -> Html Msg
viewDocument u t b model =
    if b.md /= Nothing then
        -- Markdown Document
        div [] [ text "Markdown view not implemented" ]

    else
        -- Node Document
        let
            nodeData =
                { focus = model.node_focus
                , tid_r = Success t.id
                , node = b.node |> withDefault (initNodeFragment Nothing)
                , isLazy = False
                , source = model.baseUri
                , hasBeenPushed = model.hasBeenPushed
                , receiver = t.receiver.nameid
                , hasInnerToolbar = False
                }

            op =
                { data = model.nodeDoc
                , result = NotAsked
                , now = model.now
                , publish_result = model.publish_result
                , blob = b
                , isAdmin = model.isTensionAdmin
                , tension_blobs = model.tension_blobs
                , onSubmit = Submit
                , onSubmitBlob = CommitBlob
                , onCancelBlob = CancelBlob
                , onPushBlob = PushBlob
                , onChangeEdit = ChangeBlobEdit
                , onChangePost = ChangeBlobPost
                , onAddDomains = AddDomains
                , onAddPolicies = AddPolicies
                , onAddResponsabilities = AddResponsabilities
                }
        in
        NodeDoc.view nodeData (Just op)



--
-- Side Pane
--


viewSidePane : UserState -> TensionHead -> Model -> Html Msg
viewSidePane u t model =
    let
        tc_m =
            Maybe.map (\a -> getTensionCharac a) t.action

        assignees =
            t.assignees |> withDefault []

        labels =
            t.labels |> withDefault []

        blob_m =
            t.blobs |> withDefault [] |> List.head

        --
        uctx_m =
            case u of
                LoggedIn uctx ->
                    Just uctx

                LoggedOut ->
                    Nothing

        hasRole =
            Maybe.map
                (\b ->
                    let
                        fs =
                            b.node
                                |> Maybe.map (\n -> n.first_link)
                                |> withDefault Nothing
                    in
                    Maybe.map (\uctx -> Just uctx.username == fs) uctx_m |> withDefault False
                )
                blob_m
                |> withDefault False

        --
        isAdmin =
            model.isTensionAdmin

        isAuthor =
            Maybe.map (\uctx -> t.createdBy.username == uctx.username) uctx_m |> withDefault False

        hasAssigneeRight =
            isAdmin

        hasLabelRight =
            isAdmin || isAuthor

        hasBlobRight =
            isAdmin && model.hasBeenPushed && blob_m /= Nothing

        rid =
            nid2rootid t.receiver.nameid

        isRoot =
            t.emitter.nameid == rid && t.receiver.nameid == rid
    in
    div [ class "tensionSidePane" ] <|
        [ -- Assignees/User select
          div
            [ class "media"
            , classList [ ( "is-w", hasAssigneeRight ) ]
            , ternary hasAssigneeRight (onClick DoAssigneeEdit) (onClick NoMsg)
            ]
            [ div [ class "media-content" ] <|
                (case u of
                    LoggedIn _ ->
                        [ h2
                            [ class "subtitle", classList [ ( "is-h", hasAssigneeRight ) ] ]
                            [ text T.assignees
                            , if model.isAssigneeOpen then
                                A.icon "icon-x is-pulled-right"

                              else if hasAssigneeRight then
                                A.icon "icon-settings is-pulled-right"

                              else
                                text ""
                            ]
                        , UserSearchPanel.view
                            { selectedAssignees = t.assignees |> withDefault []
                            , targets = model.path_data |> withMaybeDataMap (\x -> List.map (\y -> y.nameid) x.path) |> withDefault []
                            , isRight = False
                            }
                            model.assigneesPanel
                            |> Html.map UserSearchPanelMsg
                        ]

                    LoggedOut ->
                        [ h2 [ class "subtitle" ] [ text T.assignees ] ]
                )
                    ++ [ div []
                            [ if List.length assignees > 0 then
                                viewUsers assignees

                              else
                                div [ class "help is-italic" ] [ text T.noneYet ]
                            ]
                       ]
            ]

        -- Label select
        , div
            [ class "media"
            , classList [ ( "is-w", hasLabelRight ) ]
            , ternary hasLabelRight (onClick DoLabelEdit) (onClick NoMsg)
            ]
            [ div [ class "media-content" ] <|
                (case u of
                    LoggedIn _ ->
                        [ h2 [ class "subtitle", classList [ ( "is-h", hasLabelRight ) ] ]
                            [ text T.labels
                            , if model.isLabelOpen then
                                A.icon "icon-x is-pulled-right"

                              else if hasLabelRight then
                                A.icon "icon-settings is-pulled-right"

                              else
                                text ""
                            ]
                        , LabelSearchPanel.view
                            { selectedLabels = t.labels |> withDefault []
                            , targets = model.path_data |> withMaybeDataMap (\x -> [ shrinkNode x.focus ]) |> withDefault []
                            , isRight = False
                            }
                            model.labelsPanel
                            |> Html.map LabelSearchPanelMsg
                        ]

                    LoggedOut ->
                        [ h2 [ class "subtitle" ] [ text T.labels ] ]
                )
                    ++ [ div [ class "tension-labelsList" ]
                            [ if List.length labels > 0 then
                                viewLabels labels

                              else
                                div [ class "help is-italic" ] [ text T.noneYet ]
                            ]
                       ]
            ]

        -- Document
        , Maybe.map2
            (\blob tc ->
                -- Hide if there is no document
                let
                    domid =
                        "actionPanelContent"

                    isOpen =
                        ActionPanel.isOpen_ domid model.actionPanel && (hasBlobRight || hasRole)

                    node =
                        blob.node |> withDefault (initNodeFragment Nothing) |> nodeFromFragment t.receiver.nameid
                in
                div [ class "media" ]
                    [ div [ class "media-content wrapped-container" ]
                        [ div
                            [ class "media-content"
                            , classList [ ( "is-w", hasBlobRight || hasRole ) ]
                            , if not isOpen then
                                onClick (OpenActionPanel domid node.nameid Nothing)

                              else
                                onClick (ActionPanelMsg ActionPanel.OnClose)
                            ]
                          <|
                            (case u of
                                LoggedIn _ ->
                                    [ div [ id domid ]
                                        [ h2
                                            [ class "subtitle", classList [ ( "is-h", hasBlobRight || hasRole ) ] ]
                                            [ text T.document
                                            , if isOpen then
                                                A.icon "icon-x is-pulled-right"

                                              else if hasBlobRight || hasRole then
                                                A.icon "icon-settings is-pulled-right"

                                              else
                                                text ""
                                            ]
                                        , if hasBlobRight || hasRole then
                                            let
                                                panelData =
                                                    { tc = tc
                                                    , isRight = False
                                                    , domid = domid
                                                    , tree_data = TreeMenu.getOrgaData_ model.treeMenu
                                                    }
                                            in
                                            ActionPanel.view panelData model.actionPanel |> Html.map ActionPanelMsg

                                          else
                                            text ""
                                        ]
                                    ]

                                LoggedOut ->
                                    [ h2 [ class "subtitle" ] [ text T.document ] ]
                            )
                                ++ [ div [] <|
                                        case tc.doc_type of
                                            NODE NodeType.Circle ->
                                                [ div [ class "level is-mobile mb-3" ] <|
                                                    [ span [ class "level-left" ] [ A.icon1 (action2icon tc) (SE.humanize (action2str tc.action)) ]
                                                    , span [ class "level-item" ] [ A.icon1 (auth2icon tc) (auth2val node tc) ]
                                                    , span [ class "level-right" ] [ A.icon1 (visibility2icon node.visibility) (NodeVisibility.toString node.visibility) ]
                                                    ]
                                                , viewCircleTarget "mb-3 is-medium" { name = node.name, nameid = node.nameid, role_type = node.role_type, color = node.color }
                                                ]

                                            NODE NodeType.Role ->
                                                [ div [ class "level is-mobile mb-3" ] <|
                                                    [ span [ class "level-left" ] [ A.icon1 (action2icon tc) (SE.humanize (action2str tc.action)) ]
                                                    , span [ class "level-item" ] [ A.icon1 (auth2icon tc) (auth2val node tc) ]
                                                    ]
                                                , if model.hasBeenPushed then
                                                    viewRole "is-small" Nothing (Just <| uriFromNameid OverviewBaseUri node.nameid []) (eor2ur node)

                                                  else
                                                    viewRoleExt "is-small mb-3" Nothing { name = node.name, color = node.color, role_type = withDefault RoleType.Pending node.role_type }
                                                ]

                                            MD ->
                                                [ div [ class "help is-italic" ] [ text T.notImplemented ] ]
                                   ]
                                ++ [ Maybe.map
                                        (\fs ->
                                            div [ class "mt-2" ] [ span [ class "is-highlight" ] [ text T.firstLink, text ": " ], viewUserFull 0 True False fs ]
                                        )
                                        node.first_link
                                        |> withDefault (text "")
                                   ]
                                ++ [ if tc.action_type == ARCHIVE then
                                        div [ class "mt-2 has-text-warning" ] [ A.icon1 "icon-archive" T.archived ]

                                     else
                                        text ""
                                   ]
                        , if model.activeTab == Document then
                            text ""

                          else
                            let
                                op2 =
                                    { data = model.nodeDoc
                                    , result = NotAsked
                                    , now = model.now
                                    , publish_result = model.publish_result
                                    , blob = blob
                                    , isAdmin = model.isTensionAdmin
                                    , tension_blobs = model.tension_blobs
                                    , onSubmit = Submit
                                    , onSubmitBlob = CommitBlob
                                    , onCancelBlob = CancelBlob
                                    , onPushBlob = PushBlob
                                    , onChangeEdit = ChangeBlobEdit
                                    , onChangePost = ChangeBlobPost
                                    , onAddDomains = AddDomains
                                    , onAddPolicies = AddPolicies
                                    , onAddResponsabilities = AddResponsabilities
                                    }
                            in
                            NodeDoc.viewNodeStatus op2
                        ]
                    ]
            )
            blob_m
            tc_m
            |> withDefault (text "")
        , -- Subscriptions
          case u of
            LoggedIn uctx ->
                let
                    ( iconElt, subscribe_txt ) =
                        case model.tension_head |> withMaybeData |> Maybe.map (\x -> x.isSubscribed) |> withDefault Nothing of
                            Just True ->
                                ( A.icon1 "icon-bell-off icon-1x" T.unsubscribe, T.tensionSubscribeText )

                            Just False ->
                                ( A.icon1 "icon-bell icon-1x" T.subscribe, T.tensionUnsubscribeText )

                            Nothing ->
                                ( text "", "" )
                in
                div [ class "media pb-0" ]
                    [ div [ class "media-content" ]
                        [ h2 [ class "subtitle" ]
                            [ text T.notifications ]
                        , p
                            [ class "button is-fullwidth has-background-evidence is-small "
                            , style "border-radius" "5px"
                            , onClick (ToggleSubscription uctx.username)
                            ]
                            [ iconElt, loadingSpin (model.subscribe_result == LoadingSlowly) ]
                        , p [ class "help" ] [ text subscribe_txt ]
                        , case model.subscribe_result of
                            Failure err ->
                                viewGqlErrors err

                            _ ->
                                text ""
                        ]
                    ]

            LoggedOut ->
                text ""
        ]
            -- Extra action (Move, Lock, ...)
            ++ (if not isRoot && (isAdmin || isAuthor) then
                    let
                        hasNode =
                            Maybe.map .doc_type tc_m
                                |> (\x ->
                                        case x of
                                            Just (NODE _) ->
                                                True

                                            _ ->
                                                False
                                   )
                    in
                    [ hr [ class "has-background-border-light" ] [] ]
                        ++ (if not hasNode then
                                [ div
                                    [ class "is-smaller2 has-text-weight-semibold button-light is-link mb-4"
                                    , onClick (DoMove t)
                                    ]
                                    [ span [ class "arrow-right2 pl-0 pr-2" ] [], text T.moveTension ]
                                ]

                            else
                                []
                           )
                        ++ (if isAdmin && not hasNode then
                                [ div
                                    [ class "is-smaller2 has-text-weight-semibold button-light is-link mb-4"
                                    , onClick <| SelectTypeMsg (SelectType.OnOpen t.type_)
                                    ]
                                    [ A.icon "icon-disc mr-1", text "Change type" ]
                                ]

                            else
                                []
                           )
                        ++ (if isAdmin then
                                [--, div [ class "is-smaller2 has-text-weight-semibold button-light is-link mb-4" ] [ A.icon "icon-lock icon-sm mr-1", text "Lock tension" ]
                                ]

                            else
                                []
                           )

                else
                    []
               )



---- Utils


url2tid : Url -> String
url2tid url =
    url.path |> String.split "/" |> LE.getAt 3 |> withDefault url.path


tensionChanged : Maybe Url -> Url -> Bool
tensionChanged from_m to =
    let
        tid1 =
            from_m
                |> Maybe.map url2tid
                |> withDefault ""

        tid2 =
            url2tid to
    in
    tid1 /= tid2


tensionChanged2 : TensionHead -> Url -> Bool
tensionChanged2 th to =
    let
        tid1 =
            th.id

        tid2 =
            url2tid to
    in
    tid1 /= tid2


eventFromForm : Ev -> TensionForm -> Event
eventFromForm event form =
    { id = ""
    , createdAt = Dict.get "createdAt" form.post |> withDefault ""
    , createdBy = Username form.uctx.username
    , event_type = event.event_type
    , old = Just event.old
    , new = Just event.new
    }
