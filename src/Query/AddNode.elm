module Query.AddNode exposing (addOneCircle)

import Components.NodeDoc exposing (getFirstLinks)
import Dict exposing (Dict)
import Fractal.Enum.NodeMode as NodeMode
import Fractal.Enum.NodeType as NodeType
import Fractal.Enum.RoleType as RoleType
import Fractal.InputObject as Input
import Fractal.Mutation as Mutation
import Fractal.Object
import Fractal.Object.AddNodePayload
import Fractal.Object.Node
import Fractal.Object.NodeCharac
import Fractal.Object.Tension
import Fractal.Object.User
import Fractal.Scalar
import GqlClient exposing (..)
import Graphql.OptionalArgument as OptionalArgument exposing (OptionalArgument(..), fromMaybe)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, with)
import Maybe exposing (withDefault)
import ModelCommon exposing (ActionForm, TensionForm)
import ModelCommon.Codecs exposing (memberIdCodec, nid2rootid, nodeIdCodec)
import ModelSchema exposing (..)
import Query.AddTension exposing (buildMandate, tensionFromForm)
import Query.QueryNode exposing (blobIdPayload, nodeIdPayload, nodeOrgaPayload, userPayload)
import RemoteData exposing (RemoteData)



{-
   Add a new Circle/Role
-}


type alias Circle =
    { createdAt : String
    , name : String
    , nameid : String
    , rootnameid : String
    , parent : Maybe NodeId -- see issue with recursive structure
    , children : Maybe (List Node)
    , type_ : NodeType.NodeType
    , role_type : Maybe RoleType.RoleType
    , first_link : Maybe User
    , charac : NodeCharac
    , isPrivate : Bool
    , source : Maybe BlobId
    }


type alias AddCirclePayload =
    { node : Maybe (List (Maybe Circle)) }



--- Response Decoder


circleDecoder : Maybe AddCirclePayload -> Maybe (List Node)
circleDecoder a =
    case a of
        Just b ->
            b.node
                |> Maybe.map
                    (\x ->
                        case List.head x of
                            Just (Just n) ->
                                let
                                    children =
                                        n.children |> withDefault []

                                    node =
                                        { createdAt = .createdAt n
                                        , name = .name n
                                        , nameid = .nameid n
                                        , rootnameid = .rootnameid n
                                        , parent = .parent n
                                        , type_ = .type_ n
                                        , role_type = .role_type n
                                        , first_link = .first_link n
                                        , charac = .charac n
                                        , isPrivate = .isPrivate n
                                        , source = .source n
                                        }
                                in
                                [ node ]
                                    ++ children
                                    |> Just

                            _ ->
                                Nothing
                    )
                |> Maybe.withDefault Nothing

        Nothing ->
            Nothing



--- Query


addOneCircle url form msg =
    --@DEBUG: Infered type...
    makeGQLMutation url
        (Mutation.addNode
            (\q -> { q | upsert = Absent })
            (addCircleInputEncoder form)
            (SelectionSet.map AddCirclePayload <|
                Fractal.Object.AddNodePayload.node identity addOneCirclePayload
            )
        )
        (RemoteData.fromResult >> decodeResponse circleDecoder >> msg)


addOneCirclePayload : SelectionSet Circle Fractal.Object.Node
addOneCirclePayload =
    SelectionSet.succeed Circle
        |> with (Fractal.Object.Node.createdAt |> SelectionSet.map decodedTime)
        |> with Fractal.Object.Node.name
        |> with Fractal.Object.Node.nameid
        |> with Fractal.Object.Node.rootnameid
        |> with (Fractal.Object.Node.parent identity nodeIdPayload)
        |> with (Fractal.Object.Node.children identity nodeOrgaPayload)
        |> with Fractal.Object.Node.type_
        |> with Fractal.Object.Node.role_type
        |> with (Fractal.Object.Node.first_link identity userPayload)
        |> with
            (Fractal.Object.Node.charac identity <|
                SelectionSet.map2 NodeCharac
                    Fractal.Object.NodeCharac.userCanJoin
                    Fractal.Object.NodeCharac.mode
            )
        |> with Fractal.Object.Node.isPrivate
        |> with (Fractal.Object.Node.source identity blobIdPayload)



-- Input Encoder


addCircleInputEncoder : TensionForm -> Mutation.AddNodeRequiredArguments
addCircleInputEncoder f =
    let
        createdAt =
            Dict.get "createdAt" f.post |> withDefault ""

        type_ =
            f.node.type_ |> withDefault NodeType.Role

        nameid =
            f.node.nameid |> Maybe.map (\nid -> nodeIdCodec f.target.nameid nid type_) |> withDefault ""

        name =
            f.node.name |> withDefault ""

        charac =
            f.node.charac |> withDefault (NodeCharac False NodeMode.Coordinated)

        nodeRequired =
            { createdAt = createdAt |> Fractal.Scalar.DateTime
            , createdBy =
                Input.buildUserRef
                    (\u -> { u | username = Present f.uctx.username })
            , isRoot = False
            , type_ = type_
            , name = name
            , nameid = nameid
            , rootnameid = nid2rootid f.target.nameid
            , isArchived = False
            , charac = { userCanJoin = Present charac.userCanJoin, mode = Present charac.mode, id = Absent }

            -- default
            , rights = 0
            , isPrivate = True
            }

        nodeOptional =
            getAddCircleOptionals f
    in
    { input =
        [ Input.buildAddNodeInput nodeRequired nodeOptional ]
    }


getAddCircleOptionals : TensionForm -> (Input.AddNodeInputOptionalFields -> Input.AddNodeInputOptionalFields)
getAddCircleOptionals f =
    let
        createdAt =
            Dict.get "createdAt" f.post |> withDefault ""

        type_ =
            f.node.type_ |> withDefault NodeType.Role

        nameid =
            f.node.nameid |> Maybe.map (\nid -> nodeIdCodec f.target.nameid nid type_) |> withDefault ""
    in
    \n ->
        let
            commonFields =
                { n
                    | parent =
                        Input.buildNodeRef
                            (\p -> { p | nameid = Present f.target.nameid })
                            |> Present
                    , about = fromMaybe f.node.about
                    , mandate = buildMandate f.node.mandate
                    , tensions_in =
                        [ Input.buildTensionRef (tensionFromForm f) ] |> Present
                }
        in
        case type_ of
            NodeType.Role ->
                -- Role
                { commonFields
                    | role_type = f.node.role_type |> fromMaybe
                    , first_link =
                        f.users
                            |> List.head
                            |> Maybe.map
                                (\us ->
                                    Input.buildUserRef
                                        (\u -> { u | username = us.username |> Present })
                                )
                            |> fromMaybe
                }

            NodeType.Circle ->
                -- Circle
                { commonFields
                    | children =
                        f.users
                            |> List.indexedMap
                                (\i us ->
                                    Input.buildNodeRef
                                        (\c ->
                                            { c
                                                | createdAt = createdAt |> Fractal.Scalar.DateTime |> Present
                                                , createdBy =
                                                    Input.buildUserRef (\u -> { u | username = Present f.uctx.username }) |> Present
                                                , first_link =
                                                    Input.buildUserRef (\u -> { u | username = us.username |> Present }) |> Present
                                                , isRoot = False |> Present
                                                , type_ = NodeType.Role |> Present
                                                , role_type = us.role_type |> Present
                                                , name = "NOT IMPLEMENTED !" |> Present
                                                , nameid = (nameid ++ "#" ++ "coordo" ++ String.fromInt i) |> Present
                                                , rootnameid = nid2rootid f.target.nameid |> Present
                                                , charac = f.node.charac |> Maybe.map (\ch -> { userCanJoin = Present ch.userCanJoin, mode = Present ch.mode, id = Absent }) |> fromMaybe
                                            }
                                        )
                                )
                            |> Present
                }
