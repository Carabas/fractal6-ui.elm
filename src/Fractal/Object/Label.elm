-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.Label exposing (..)

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


id : SelectionSet Fractal.ScalarCodecs.Id Fractal.Object.Label
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecId |> .decoder)


nameid : SelectionSet String Fractal.Object.Label
nameid =
    Object.selectionForField "String" "nameid" [] Decode.string


name : SelectionSet String Fractal.Object.Label
name =
    Object.selectionForField "String" "name" [] Decode.string


description : SelectionSet (Maybe String) Fractal.Object.Label
description =
    Object.selectionForField "(Maybe String)" "description" [] (Decode.string |> Decode.nullable)


color : SelectionSet (Maybe String) Fractal.Object.Label
color =
    Object.selectionForField "(Maybe String)" "color" [] (Decode.string |> Decode.nullable)
