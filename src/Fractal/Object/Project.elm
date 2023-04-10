-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.Project exposing (..)

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


id : SelectionSet Fractal.ScalarCodecs.Id Fractal.Object.Project
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecId |> .decoder)


rootnameid : SelectionSet String Fractal.Object.Project
rootnameid =
    Object.selectionForField "String" "rootnameid" [] Decode.string


parentnameid : SelectionSet String Fractal.Object.Project
parentnameid =
    Object.selectionForField "String" "parentnameid" [] Decode.string


nameid : SelectionSet String Fractal.Object.Project
nameid =
    Object.selectionForField "String" "nameid" [] Decode.string


name : SelectionSet String Fractal.Object.Project
name =
    Object.selectionForField "String" "name" [] Decode.string


description : SelectionSet (Maybe String) Fractal.Object.Project
description =
    Object.selectionForField "(Maybe String)" "description" [] (Decode.string |> Decode.nullable)


type alias ColumnsOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.ProjectColumnFilter
    , order : OptionalArgument Fractal.InputObject.ProjectColumnOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


columns :
    (ColumnsOptionalArguments -> ColumnsOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.ProjectColumn
    -> SelectionSet (Maybe (List decodesTo)) Fractal.Object.Project
columns fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeProjectColumnFilter, Argument.optional "order" filledInOptionals____.order Fractal.InputObject.encodeProjectColumnOrder, Argument.optional "first" filledInOptionals____.first Encode.int, Argument.optional "offset" filledInOptionals____.offset Encode.int ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "columns" optionalArgs____ object____ (Basics.identity >> Decode.list >> Decode.nullable)


type alias LeadersOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.NodeFilter
    , order : OptionalArgument Fractal.InputObject.NodeOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


leaders :
    (LeadersOptionalArguments -> LeadersOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Node
    -> SelectionSet (Maybe (List decodesTo)) Fractal.Object.Project
leaders fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeNodeFilter, Argument.optional "order" filledInOptionals____.order Fractal.InputObject.encodeNodeOrder, Argument.optional "first" filledInOptionals____.first Encode.int, Argument.optional "offset" filledInOptionals____.offset Encode.int ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "leaders" optionalArgs____ object____ (Basics.identity >> Decode.list >> Decode.nullable)


type alias NodesOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.NodeFilter
    , order : OptionalArgument Fractal.InputObject.NodeOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


nodes :
    (NodesOptionalArguments -> NodesOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.Node
    -> SelectionSet (Maybe (List decodesTo)) Fractal.Object.Project
nodes fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeNodeFilter, Argument.optional "order" filledInOptionals____.order Fractal.InputObject.encodeNodeOrder, Argument.optional "first" filledInOptionals____.first Encode.int, Argument.optional "offset" filledInOptionals____.offset Encode.int ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "nodes" optionalArgs____ object____ (Basics.identity >> Decode.list >> Decode.nullable)


type alias ColumnsAggregateOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.ProjectColumnFilter }


columnsAggregate :
    (ColumnsAggregateOptionalArguments -> ColumnsAggregateOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.ProjectColumnAggregateResult
    -> SelectionSet (Maybe decodesTo) Fractal.Object.Project
columnsAggregate fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeProjectColumnFilter ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "columnsAggregate" optionalArgs____ object____ (Basics.identity >> Decode.nullable)


type alias LeadersAggregateOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.NodeFilter }


leadersAggregate :
    (LeadersAggregateOptionalArguments -> LeadersAggregateOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.NodeAggregateResult
    -> SelectionSet (Maybe decodesTo) Fractal.Object.Project
leadersAggregate fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeNodeFilter ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "leadersAggregate" optionalArgs____ object____ (Basics.identity >> Decode.nullable)


type alias NodesAggregateOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.NodeFilter }


nodesAggregate :
    (NodesAggregateOptionalArguments -> NodesAggregateOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.NodeAggregateResult
    -> SelectionSet (Maybe decodesTo) Fractal.Object.Project
nodesAggregate fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeNodeFilter ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "nodesAggregate" optionalArgs____ object____ (Basics.identity >> Decode.nullable)
