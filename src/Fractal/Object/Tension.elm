-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.Tension exposing (..)

import Fractal.Enum.TensionAction
import Fractal.Enum.TensionStatus
import Fractal.Enum.TensionType
import Fractal.InputObject
import Fractal.Interface
import Fractal.Object
import Fractal.Scalar
import Fractal.ScalarCodecs
import Fractal.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


type alias CreatedByOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.UserFilter }


createdBy :
    (CreatedByOptionalArguments -> CreatedByOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.User
    -> SelectionSet decodesTo Fractal.Object.Tension
createdBy fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeUserFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "createdBy" optionalArgs object_ identity


nth : SelectionSet (Maybe String) Fractal.Object.Tension
nth =
    Object.selectionForField "(Maybe String)" "nth" [] (Decode.string |> Decode.nullable)


title : SelectionSet String Fractal.Object.Tension
title =
    Object.selectionForField "String" "title" [] Decode.string


type_ : SelectionSet Fractal.Enum.TensionType.TensionType Fractal.Object.Tension
type_ =
    Object.selectionForField "Enum.TensionType.TensionType" "type_" [] Fractal.Enum.TensionType.decoder


emitterid : SelectionSet String Fractal.Object.Tension
emitterid =
    Object.selectionForField "String" "emitterid" [] Decode.string


type alias EmitterOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.NodeFilter }


emitter :
    (EmitterOptionalArguments -> EmitterOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Node
    -> SelectionSet decodesTo Fractal.Object.Tension
emitter fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeNodeFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "emitter" optionalArgs object_ identity


receiverid : SelectionSet String Fractal.Object.Tension
receiverid =
    Object.selectionForField "String" "receiverid" [] Decode.string


type alias ReceiverOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.NodeFilter }


receiver :
    (ReceiverOptionalArguments -> ReceiverOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Node
    -> SelectionSet decodesTo Fractal.Object.Tension
receiver fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeNodeFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "receiver" optionalArgs object_ identity


status : SelectionSet Fractal.Enum.TensionStatus.TensionStatus Fractal.Object.Tension
status =
    Object.selectionForField "Enum.TensionStatus.TensionStatus" "status" [] Fractal.Enum.TensionStatus.decoder


type alias LabelsOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.LabelFilter
    , order : OptionalArgument Fractal.InputObject.LabelOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


labels :
    (LabelsOptionalArguments -> LabelsOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Label
    -> SelectionSet (Maybe (List decodesTo)) Fractal.Object.Tension
labels fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeLabelFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeLabelOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "labels" optionalArgs object_ (identity >> Decode.list >> Decode.nullable)


type alias AssigneesOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.UserFilter
    , order : OptionalArgument Fractal.InputObject.UserOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


assignees :
    (AssigneesOptionalArguments -> AssigneesOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.User
    -> SelectionSet (Maybe (List decodesTo)) Fractal.Object.Tension
assignees fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeUserFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeUserOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "assignees" optionalArgs object_ (identity >> Decode.list >> Decode.nullable)


action : SelectionSet (Maybe Fractal.Enum.TensionAction.TensionAction) Fractal.Object.Tension
action =
    Object.selectionForField "(Maybe Enum.TensionAction.TensionAction)" "action" [] (Fractal.Enum.TensionAction.decoder |> Decode.nullable)


type alias CommentsOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.CommentFilter
    , order : OptionalArgument Fractal.InputObject.CommentOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


comments :
    (CommentsOptionalArguments -> CommentsOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Comment
    -> SelectionSet (Maybe (List decodesTo)) Fractal.Object.Tension
comments fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeCommentFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeCommentOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "comments" optionalArgs object_ (identity >> Decode.list >> Decode.nullable)


type alias BlobsOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.BlobFilter
    , order : OptionalArgument Fractal.InputObject.BlobOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


blobs :
    (BlobsOptionalArguments -> BlobsOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Blob
    -> SelectionSet (Maybe (List decodesTo)) Fractal.Object.Tension
blobs fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeBlobFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeBlobOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "blobs" optionalArgs object_ (identity >> Decode.list >> Decode.nullable)


type alias HistoryOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.EventFilter
    , order : OptionalArgument Fractal.InputObject.EventOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


history :
    (HistoryOptionalArguments -> HistoryOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Event
    -> SelectionSet (List decodesTo) Fractal.Object.Tension
history fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeEventFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeEventOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "history" optionalArgs object_ (identity >> Decode.list)


n_comments : SelectionSet (Maybe Int) Fractal.Object.Tension
n_comments =
    Object.selectionForField "(Maybe Int)" "n_comments" [] (Decode.int |> Decode.nullable)


n_blobs : SelectionSet (Maybe Int) Fractal.Object.Tension
n_blobs =
    Object.selectionForField "(Maybe Int)" "n_blobs" [] (Decode.int |> Decode.nullable)


id : SelectionSet Fractal.ScalarCodecs.Id Fractal.Object.Tension
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecId |> .decoder)


createdAt : SelectionSet Fractal.ScalarCodecs.DateTime Fractal.Object.Tension
createdAt =
    Object.selectionForField "ScalarCodecs.DateTime" "createdAt" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder)


updatedAt : SelectionSet (Maybe Fractal.ScalarCodecs.DateTime) Fractal.Object.Tension
updatedAt =
    Object.selectionForField "(Maybe ScalarCodecs.DateTime)" "updatedAt" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder |> Decode.nullable)


message : SelectionSet (Maybe String) Fractal.Object.Tension
message =
    Object.selectionForField "(Maybe String)" "message" [] (Decode.string |> Decode.nullable)
