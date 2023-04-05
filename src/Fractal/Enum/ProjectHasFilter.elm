-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Enum.ProjectHasFilter exposing (..)

import Json.Decode as Decode exposing (Decoder)


type ProjectHasFilter
    = Rootnameid
    | Parentnameid
    | Nameid
    | Name
    | About
    | Columns
    | Leaders
    | Nodes


list : List ProjectHasFilter
list =
    [ Rootnameid, Parentnameid, Nameid, Name, About, Columns, Leaders, Nodes ]


decoder : Decoder ProjectHasFilter
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "rootnameid" ->
                        Decode.succeed Rootnameid

                    "parentnameid" ->
                        Decode.succeed Parentnameid

                    "nameid" ->
                        Decode.succeed Nameid

                    "name" ->
                        Decode.succeed Name

                    "about" ->
                        Decode.succeed About

                    "columns" ->
                        Decode.succeed Columns

                    "leaders" ->
                        Decode.succeed Leaders

                    "nodes" ->
                        Decode.succeed Nodes

                    _ ->
                        Decode.fail ("Invalid ProjectHasFilter type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representing the Enum to a string that the GraphQL server will recognize.
-}
toString : ProjectHasFilter -> String
toString enum____ =
    case enum____ of
        Rootnameid ->
            "rootnameid"

        Parentnameid ->
            "parentnameid"

        Nameid ->
            "nameid"

        Name ->
            "name"

        About ->
            "about"

        Columns ->
            "columns"

        Leaders ->
            "leaders"

        Nodes ->
            "nodes"


{-| Convert from a String representation to an elm representation enum.
This is the inverse of the Enum `toString` function. So you can call `toString` and then convert back `fromString` safely.

    Swapi.Enum.Episode.NewHope
        |> Swapi.Enum.Episode.toString
        |> Swapi.Enum.Episode.fromString
        == Just NewHope

This can be useful for generating Strings to use for <select> menus to check which item was selected.

-}
fromString : String -> Maybe ProjectHasFilter
fromString enumString____ =
    case enumString____ of
        "rootnameid" ->
            Just Rootnameid

        "parentnameid" ->
            Just Parentnameid

        "nameid" ->
            Just Nameid

        "name" ->
            Just Name

        "about" ->
            Just About

        "columns" ->
            Just Columns

        "leaders" ->
            Just Leaders

        "nodes" ->
            Just Nodes

        _ ->
            Nothing
