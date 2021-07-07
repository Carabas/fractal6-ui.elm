-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.ContractAggregateResult exposing (..)

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


count : SelectionSet (Maybe Int) Fractal.Object.ContractAggregateResult
count =
    Object.selectionForField "(Maybe Int)" "count" [] (Decode.int |> Decode.nullable)


createdAtMin : SelectionSet (Maybe Fractal.ScalarCodecs.DateTime) Fractal.Object.ContractAggregateResult
createdAtMin =
    Object.selectionForField "(Maybe ScalarCodecs.DateTime)" "createdAtMin" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder |> Decode.nullable)


createdAtMax : SelectionSet (Maybe Fractal.ScalarCodecs.DateTime) Fractal.Object.ContractAggregateResult
createdAtMax =
    Object.selectionForField "(Maybe ScalarCodecs.DateTime)" "createdAtMax" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder |> Decode.nullable)


updatedAtMin : SelectionSet (Maybe Fractal.ScalarCodecs.DateTime) Fractal.Object.ContractAggregateResult
updatedAtMin =
    Object.selectionForField "(Maybe ScalarCodecs.DateTime)" "updatedAtMin" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder |> Decode.nullable)


updatedAtMax : SelectionSet (Maybe Fractal.ScalarCodecs.DateTime) Fractal.Object.ContractAggregateResult
updatedAtMax =
    Object.selectionForField "(Maybe ScalarCodecs.DateTime)" "updatedAtMax" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder |> Decode.nullable)


messageMin : SelectionSet (Maybe String) Fractal.Object.ContractAggregateResult
messageMin =
    Object.selectionForField "(Maybe String)" "messageMin" [] (Decode.string |> Decode.nullable)


messageMax : SelectionSet (Maybe String) Fractal.Object.ContractAggregateResult
messageMax =
    Object.selectionForField "(Maybe String)" "messageMax" [] (Decode.string |> Decode.nullable)


contractidMin : SelectionSet (Maybe String) Fractal.Object.ContractAggregateResult
contractidMin =
    Object.selectionForField "(Maybe String)" "contractidMin" [] (Decode.string |> Decode.nullable)


contractidMax : SelectionSet (Maybe String) Fractal.Object.ContractAggregateResult
contractidMax =
    Object.selectionForField "(Maybe String)" "contractidMax" [] (Decode.string |> Decode.nullable)


closedAtMin : SelectionSet (Maybe Fractal.ScalarCodecs.DateTime) Fractal.Object.ContractAggregateResult
closedAtMin =
    Object.selectionForField "(Maybe ScalarCodecs.DateTime)" "closedAtMin" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder |> Decode.nullable)


closedAtMax : SelectionSet (Maybe Fractal.ScalarCodecs.DateTime) Fractal.Object.ContractAggregateResult
closedAtMax =
    Object.selectionForField "(Maybe ScalarCodecs.DateTime)" "closedAtMax" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder |> Decode.nullable)
