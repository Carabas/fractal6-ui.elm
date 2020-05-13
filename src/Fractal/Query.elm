-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Query exposing (..)

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
import Json.Decode as Decode exposing (Decoder)


type alias GetNodeOptionalArguments =
    { id : OptionalArgument Fractal.ScalarCodecs.Id
    , nameid : OptionalArgument String
    }


getNode : (GetNodeOptionalArguments -> GetNodeOptionalArguments) -> SelectionSet decodesTo Fractal.Object.Node -> SelectionSet (Maybe decodesTo) RootQuery
getNode fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { id = Absent, nameid = Absent }

        optionalArgs =
            [ Argument.optional "id" filledInOptionals.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId), Argument.optional "nameid" filledInOptionals.nameid Encode.string ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "getNode" optionalArgs object_ (identity >> Decode.nullable)


type alias QueryNodeOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.NodeFilter
    , order : OptionalArgument Fractal.InputObject.NodeOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryNode : (QueryNodeOptionalArguments -> QueryNodeOptionalArguments) -> SelectionSet decodesTo Fractal.Object.Node -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryNode fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeNodeFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeNodeOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryNode" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias GetPostRequiredArguments =
    { id : Fractal.ScalarCodecs.Id }


getPost : GetPostRequiredArguments -> SelectionSet decodesTo Fractal.Object.Post -> SelectionSet (Maybe decodesTo) RootQuery
getPost requiredArgs object_ =
    Object.selectionForCompositeField "getPost" [ Argument.required "id" requiredArgs.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias QueryPostOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.PostFilter
    , order : OptionalArgument Fractal.InputObject.PostOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryPost : (QueryPostOptionalArguments -> QueryPostOptionalArguments) -> SelectionSet decodesTo Fractal.Object.Post -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryPost fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodePostFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodePostOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryPost" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias GetTensionRequiredArguments =
    { id : Fractal.ScalarCodecs.Id }


getTension : GetTensionRequiredArguments -> SelectionSet decodesTo Fractal.Object.Tension -> SelectionSet (Maybe decodesTo) RootQuery
getTension requiredArgs object_ =
    Object.selectionForCompositeField "getTension" [ Argument.required "id" requiredArgs.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias QueryTensionOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.TensionFilter
    , order : OptionalArgument Fractal.InputObject.TensionOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryTension : (QueryTensionOptionalArguments -> QueryTensionOptionalArguments) -> SelectionSet decodesTo Fractal.Object.Tension -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryTension fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeTensionFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeTensionOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryTension" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias GetCommentRequiredArguments =
    { id : Fractal.ScalarCodecs.Id }


getComment : GetCommentRequiredArguments -> SelectionSet decodesTo Fractal.Object.Comment -> SelectionSet (Maybe decodesTo) RootQuery
getComment requiredArgs object_ =
    Object.selectionForCompositeField "getComment" [ Argument.required "id" requiredArgs.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias QueryCommentOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.CommentFilter
    , order : OptionalArgument Fractal.InputObject.CommentOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryComment : (QueryCommentOptionalArguments -> QueryCommentOptionalArguments) -> SelectionSet decodesTo Fractal.Object.Comment -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryComment fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeCommentFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeCommentOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryComment" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias GetMandateRequiredArguments =
    { id : Fractal.ScalarCodecs.Id }


getMandate : GetMandateRequiredArguments -> SelectionSet decodesTo Fractal.Object.Mandate -> SelectionSet (Maybe decodesTo) RootQuery
getMandate requiredArgs object_ =
    Object.selectionForCompositeField "getMandate" [ Argument.required "id" requiredArgs.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId) ] object_ (identity >> Decode.nullable)


type alias QueryMandateOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.MandateFilter
    , order : OptionalArgument Fractal.InputObject.MandateOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryMandate : (QueryMandateOptionalArguments -> QueryMandateOptionalArguments) -> SelectionSet decodesTo Fractal.Object.Mandate -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryMandate fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeMandateFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeMandateOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryMandate" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias GetUserOptionalArguments =
    { id : OptionalArgument Fractal.ScalarCodecs.Id
    , username : OptionalArgument String
    }


getUser : (GetUserOptionalArguments -> GetUserOptionalArguments) -> SelectionSet decodesTo Fractal.Object.User -> SelectionSet (Maybe decodesTo) RootQuery
getUser fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { id = Absent, username = Absent }

        optionalArgs =
            [ Argument.optional "id" filledInOptionals.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId), Argument.optional "username" filledInOptionals.username Encode.string ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "getUser" optionalArgs object_ (identity >> Decode.nullable)


type alias QueryUserOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.UserFilter
    , order : OptionalArgument Fractal.InputObject.UserOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryUser : (QueryUserOptionalArguments -> QueryUserOptionalArguments) -> SelectionSet decodesTo Fractal.Object.User -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryUser fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeUserFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeUserOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryUser" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias QueryUserRightsOptionalArguments =
    { first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryUserRights : (QueryUserRightsOptionalArguments -> QueryUserRightsOptionalArguments) -> SelectionSet decodesTo Fractal.Object.UserRights -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryUserRights fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryUserRights" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)


type alias GetLabelOptionalArguments =
    { id : OptionalArgument Fractal.ScalarCodecs.Id
    , name : OptionalArgument String
    }


getLabel : (GetLabelOptionalArguments -> GetLabelOptionalArguments) -> SelectionSet decodesTo Fractal.Object.Label -> SelectionSet (Maybe decodesTo) RootQuery
getLabel fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { id = Absent, name = Absent }

        optionalArgs =
            [ Argument.optional "id" filledInOptionals.id (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapEncoder .codecId), Argument.optional "name" filledInOptionals.name Encode.string ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "getLabel" optionalArgs object_ (identity >> Decode.nullable)


type alias QueryLabelOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.LabelFilter
    , order : OptionalArgument Fractal.InputObject.LabelOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


queryLabel : (QueryLabelOptionalArguments -> QueryLabelOptionalArguments) -> SelectionSet decodesTo Fractal.Object.Label -> SelectionSet (Maybe (List (Maybe decodesTo))) RootQuery
queryLabel fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeLabelFilter, Argument.optional "order" filledInOptionals.order Fractal.InputObject.encodeLabelOrder, Argument.optional "first" filledInOptionals.first Encode.int, Argument.optional "offset" filledInOptionals.offset Encode.int ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "queryLabel" optionalArgs object_ (identity >> Decode.nullable >> Decode.list >> Decode.nullable)
