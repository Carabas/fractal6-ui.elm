-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Object.Post exposing (..)

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


{-| -}
id : SelectionSet Fractal.ScalarCodecs.Id Fractal.Object.Post
id =
    Object.selectionForField "ScalarCodecs.Id" "id" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecId |> .decoder)


{-| -}
createdAt : SelectionSet Fractal.ScalarCodecs.DateTime Fractal.Object.Post
createdAt =
    Object.selectionForField "ScalarCodecs.DateTime" "createdAt" [] (Fractal.ScalarCodecs.codecs |> Fractal.Scalar.unwrapCodecs |> .codecDateTime |> .decoder)


type alias CreatedByOptionalArguments =
    { filter : OptionalArgument Fractal.InputObject.UserFilter }


{-|

  - filter -

-}
createdBy : (CreatedByOptionalArguments -> CreatedByOptionalArguments) -> SelectionSet decodesTo Fractal.Object.User -> SelectionSet decodesTo Fractal.Object.Post
createdBy fillInOptionals object_ =
    let
        filledInOptionals =
            fillInOptionals { filter = Absent }

        optionalArgs =
            [ Argument.optional "filter" filledInOptionals.filter Fractal.InputObject.encodeUserFilter ]
                |> List.filterMap identity
    in
    Object.selectionForCompositeField "createdBy" optionalArgs object_ identity


{-| -}
message : SelectionSet (Maybe String) Fractal.Object.Post
message =
    Object.selectionForField "(Maybe String)" "message" [] (Decode.string |> Decode.nullable)