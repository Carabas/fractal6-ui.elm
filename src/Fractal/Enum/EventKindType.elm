-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Enum.EventKindType exposing (..)

import Json.Decode as Decode exposing (Decoder)


type EventKindType
    = Event
    | Contract
    | Notif


list : List EventKindType
list =
    [ Event, Contract, Notif ]


decoder : Decoder EventKindType
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "Event" ->
                        Decode.succeed Event

                    "Contract" ->
                        Decode.succeed Contract

                    "Notif" ->
                        Decode.succeed Notif

                    _ ->
                        Decode.fail ("Invalid EventKindType type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representing the Enum to a string that the GraphQL server will recognize.
-}
toString : EventKindType -> String
toString enum____ =
    case enum____ of
        Event ->
            "Event"

        Contract ->
            "Contract"

        Notif ->
            "Notif"


{-| Convert from a String representation to an elm representation enum.
This is the inverse of the Enum `toString` function. So you can call `toString` and then convert back `fromString` safely.

    Swapi.Enum.Episode.NewHope
        |> Swapi.Enum.Episode.toString
        |> Swapi.Enum.Episode.fromString
        == Just NewHope

This can be useful for generating Strings to use for <select> menus to check which item was selected.

-}
fromString : String -> Maybe EventKindType
fromString enumString____ =
    case enumString____ of
        "Event" ->
            Just Event

        "Contract" ->
            Just Contract

        "Notif" ->
            Just Notif

        _ ->
            Nothing
