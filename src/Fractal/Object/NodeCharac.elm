-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.NodeCharac exposing (..)

import Fractal.Enum.NodeMode
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


id : SelectionSet Fractal.ScalarCodecs.Id Fractal.Object.NodeCharac
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecId |> .decoder)


userCanJoin : SelectionSet Bool Fractal.Object.NodeCharac
userCanJoin =
    Object.selectionForField "Bool" "userCanJoin" [] Decode.bool


mode : SelectionSet Fractal.Enum.NodeMode.NodeMode Fractal.Object.NodeCharac
mode =
    Object.selectionForField "Enum.NodeMode.NodeMode" "mode" [] Fractal.Enum.NodeMode.decoder
