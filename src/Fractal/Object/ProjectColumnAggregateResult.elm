-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.ProjectColumnAggregateResult exposing (..)

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


count : SelectionSet (Maybe Int) Fractal.Object.ProjectColumnAggregateResult
count =
    Object.selectionForField "(Maybe Int)" "count" [] (Decode.int |> Decode.nullable)


nameMin : SelectionSet (Maybe String) Fractal.Object.ProjectColumnAggregateResult
nameMin =
    Object.selectionForField "(Maybe String)" "nameMin" [] (Decode.string |> Decode.nullable)


nameMax : SelectionSet (Maybe String) Fractal.Object.ProjectColumnAggregateResult
nameMax =
    Object.selectionForField "(Maybe String)" "nameMax" [] (Decode.string |> Decode.nullable)


aboutMin : SelectionSet (Maybe String) Fractal.Object.ProjectColumnAggregateResult
aboutMin =
    Object.selectionForField "(Maybe String)" "aboutMin" [] (Decode.string |> Decode.nullable)


aboutMax : SelectionSet (Maybe String) Fractal.Object.ProjectColumnAggregateResult
aboutMax =
    Object.selectionForField "(Maybe String)" "aboutMax" [] (Decode.string |> Decode.nullable)


posMin : SelectionSet (Maybe Int) Fractal.Object.ProjectColumnAggregateResult
posMin =
    Object.selectionForField "(Maybe Int)" "posMin" [] (Decode.int |> Decode.nullable)


posMax : SelectionSet (Maybe Int) Fractal.Object.ProjectColumnAggregateResult
posMax =
    Object.selectionForField "(Maybe Int)" "posMax" [] (Decode.int |> Decode.nullable)


posSum : SelectionSet (Maybe Int) Fractal.Object.ProjectColumnAggregateResult
posSum =
    Object.selectionForField "(Maybe Int)" "posSum" [] (Decode.int |> Decode.nullable)


posAvg : SelectionSet (Maybe Float) Fractal.Object.ProjectColumnAggregateResult
posAvg =
    Object.selectionForField "(Maybe Float)" "posAvg" [] (Decode.float |> Decode.nullable)
