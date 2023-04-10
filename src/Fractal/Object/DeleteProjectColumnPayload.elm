-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.DeleteProjectColumnPayload exposing (..)

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


type alias ProjectColumnOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.ProjectColumnFilter
    , order : OptionalArgument Fractal.InputObject.ProjectColumnOrder
    , first : OptionalArgument Int
    , offset : OptionalArgument Int
    }


projectColumn :
    (ProjectColumnOptionalArguments -> ProjectColumnOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.ProjectColumn
    -> SelectionSet (Maybe (List (Maybe decodesTo))) Fractal.Object.DeleteProjectColumnPayload
projectColumn fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent, order = Absent, first = Absent, offset = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeProjectColumnFilter, Argument.optional "order" filledInOptionals____.order Fractal.InputObject.encodeProjectColumnOrder, Argument.optional "first" filledInOptionals____.first Encode.int, Argument.optional "offset" filledInOptionals____.offset Encode.int ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "projectColumn" optionalArgs____ object____ (Basics.identity >> Decode.nullable >> Decode.list >> Decode.nullable)


msg : SelectionSet (Maybe String) Fractal.Object.DeleteProjectColumnPayload
msg =
    Object.selectionForField "(Maybe String)" "msg" [] (Decode.string |> Decode.nullable)


numUids : SelectionSet (Maybe Int) Fractal.Object.DeleteProjectColumnPayload
numUids =
    Object.selectionForField "(Maybe Int)" "numUids" [] (Decode.int |> Decode.nullable)
