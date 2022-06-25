-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Enum.Lang exposing (..)

import Json.Decode as Decode exposing (Decoder)


type Lang
    = En
    | Fr
    | It


list : List Lang
list =
    [ En, Fr, It ]


decoder : Decoder Lang
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "EN" ->
                        Decode.succeed En

                    "FR" ->
                        Decode.succeed Fr

                    "IT" ->
                        Decode.succeed It

                    _ ->
                        Decode.fail ("Invalid Lang type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representing the Enum to a string that the GraphQL server will recognize.
-}
toString : Lang -> String
toString enum____ =
    case enum____ of
        En ->
            "EN"

        Fr ->
            "FR"

        It ->
            "IT"


{-| Convert from a String representation to an elm representation enum.
This is the inverse of the Enum `toString` function. So you can call `toString` and then convert back `fromString` safely.

    Swapi.Enum.Episode.NewHope
        |> Swapi.Enum.Episode.toString
        |> Swapi.Enum.Episode.fromString
        == Just NewHope

This can be useful for generating Strings to use for <select> menus to check which item was selected.

-}
fromString : String -> Maybe Lang
fromString enumString____ =
    case enumString____ of
        "EN" ->
            Just En

        "FR" ->
            Just Fr

        "IT" ->
            Just It

        _ ->
            Nothing