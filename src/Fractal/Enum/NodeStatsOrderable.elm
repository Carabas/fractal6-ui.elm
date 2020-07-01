-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Enum.NodeStatsOrderable exposing (..)

import Json.Decode as Decode exposing (Decoder)


type NodeStatsOrderable
    = N_member
    | N_guest
    | N_circle
    | N_role


list : List NodeStatsOrderable
list =
    [ N_member, N_guest, N_circle, N_role ]


decoder : Decoder NodeStatsOrderable
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "n_member" ->
                        Decode.succeed N_member

                    "n_guest" ->
                        Decode.succeed N_guest

                    "n_circle" ->
                        Decode.succeed N_circle

                    "n_role" ->
                        Decode.succeed N_role

                    _ ->
                        Decode.fail ("Invalid NodeStatsOrderable type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representating the Enum to a string that the GraphQL server will recognize.
-}
toString : NodeStatsOrderable -> String
toString enum =
    case enum of
        N_member ->
            "n_member"

        N_guest ->
            "n_guest"

        N_circle ->
            "n_circle"

        N_role ->
            "n_role"


{-| Convert from a String representation to an elm representation enum.
This is the inverse of the Enum `toString` function. So you can call `toString` and then convert back `fromString` safely.

    Swapi.Enum.Episode.NewHope
        |> Swapi.Enum.Episode.toString
        |> Swapi.Enum.Episode.fromString
        == Just NewHope

This can be useful for generating Strings to use for <select> menus to check which item was selected.

-}
fromString : String -> Maybe NodeStatsOrderable
fromString enumString =
    case enumString of
        "n_member" ->
            Just N_member

        "n_guest" ->
            Just N_guest

        "n_circle" ->
            Just N_circle

        "n_role" ->
            Just N_role

        _ ->
            Nothing