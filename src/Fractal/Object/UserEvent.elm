-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.UserEvent exposing (..)

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


createdAt : SelectionSet Fractal.ScalarCodecs.DateTime Fractal.Object.UserEvent
createdAt =
    Object.selectionForField "ScalarCodecs.DateTime" "createdAt" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder)


isRead : SelectionSet Bool Fractal.Object.UserEvent
isRead =
    Object.selectionForField "Bool" "isRead" [] Decode.bool


type alias UserOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.UserFilter }


user :
    (UserOptionalArguments -> UserOptionalArguments)
    -> SelectionSet decodesTo Fractal.Object.User
    -> SelectionSet decodesTo Fractal.Object.UserEvent
user fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeUserFilter ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "user" optionalArgs____ object____ Basics.identity


type alias EventOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.EventKindFilter }


event :
    (EventOptionalArguments -> EventOptionalArguments)
    -> SelectionSet decodesTo Fractal.Union.EventKind
    -> SelectionSet decodesTo Fractal.Object.UserEvent
event fillInOptionals____ object____ =
    let
        filledInOptionals____ =
            fillInOptionals____ { filter = Absent }

        optionalArgs____ =
            [ Argument.optional "filter" filledInOptionals____.filter Fractal.InputObject.encodeEventKindFilter ]
                |> List.filterMap Basics.identity
    in
    Object.selectionForCompositeField "event" optionalArgs____ object____ Basics.identity
