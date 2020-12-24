-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.SharedNode exposing (..)

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


n_labels : SelectionSet (Maybe Int) Fractal.Object.SharedNode
n_labels =
    Object.selectionForField "(Maybe Int)" "n_labels" [] (Decode.int |> Decode.nullable)


n_tensions : SelectionSet (Maybe Int) Fractal.Object.SharedNode
n_tensions =
    Object.selectionForField "(Maybe Int)" "n_tensions" [] (Decode.int |> Decode.nullable)


n_closed_tensions : SelectionSet (Maybe Int) Fractal.Object.SharedNode
n_closed_tensions =
    Object.selectionForField "(Maybe Int)" "n_closed_tensions" [] (Decode.int |> Decode.nullable)
