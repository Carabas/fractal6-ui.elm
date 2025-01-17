-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.ProjectAggregateResult exposing (..)

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


count : SelectionSet (Maybe Int) Fractal.Object.ProjectAggregateResult
count =
    Object.selectionForField "(Maybe Int)" "count" [] (Decode.int |> Decode.nullable)


rootnameidMin : SelectionSet (Maybe String) Fractal.Object.ProjectAggregateResult
rootnameidMin =
    Object.selectionForField "(Maybe String)" "rootnameidMin" [] (Decode.string |> Decode.nullable)


rootnameidMax : SelectionSet (Maybe String) Fractal.Object.ProjectAggregateResult
rootnameidMax =
    Object.selectionForField "(Maybe String)" "rootnameidMax" [] (Decode.string |> Decode.nullable)


parentnameidMin : SelectionSet (Maybe String) Fractal.Object.ProjectAggregateResult
parentnameidMin =
    Object.selectionForField "(Maybe String)" "parentnameidMin" [] (Decode.string |> Decode.nullable)


parentnameidMax : SelectionSet (Maybe String) Fractal.Object.ProjectAggregateResult
parentnameidMax =
    Object.selectionForField "(Maybe String)" "parentnameidMax" [] (Decode.string |> Decode.nullable)


nameidMin : SelectionSet (Maybe String) Fractal.Object.ProjectAggregateResult
nameidMin =
    Object.selectionForField "(Maybe String)" "nameidMin" [] (Decode.string |> Decode.nullable)


nameidMax : SelectionSet (Maybe String) Fractal.Object.ProjectAggregateResult
nameidMax =
    Object.selectionForField "(Maybe String)" "nameidMax" [] (Decode.string |> Decode.nullable)


nameMin : SelectionSet (Maybe String) Fractal.Object.ProjectAggregateResult
nameMin =
    Object.selectionForField "(Maybe String)" "nameMin" [] (Decode.string |> Decode.nullable)


nameMax : SelectionSet (Maybe String) Fractal.Object.ProjectAggregateResult
nameMax =
    Object.selectionForField "(Maybe String)" "nameMax" [] (Decode.string |> Decode.nullable)


descriptionMin : SelectionSet (Maybe String) Fractal.Object.ProjectAggregateResult
descriptionMin =
    Object.selectionForField "(Maybe String)" "descriptionMin" [] (Decode.string |> Decode.nullable)


descriptionMax : SelectionSet (Maybe String) Fractal.Object.ProjectAggregateResult
descriptionMax =
    Object.selectionForField "(Maybe String)" "descriptionMax" [] (Decode.string |> Decode.nullable)
