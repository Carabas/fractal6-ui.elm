-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Enum.UserHasFilter exposing (..)

import Json.Decode as Decode exposing (Decoder)


type UserHasFilter
    = CreatedAt
    | LastAck
    | Username
    | Name
    | Password
    | Email
    | EmailHash
    | EmailValidated
    | Bio
    | Utc
    | NotifyByEmail
    | Subscriptions
    | Rights
    | Roles
    | Backed_roles
    | Tensions_created
    | Tensions_assigned
    | Contracts
    | Events


list : List UserHasFilter
list =
    [ CreatedAt, LastAck, Username, Name, Password, Email, EmailHash, EmailValidated, Bio, Utc, NotifyByEmail, Subscriptions, Rights, Roles, Backed_roles, Tensions_created, Tensions_assigned, Contracts, Events ]


decoder : Decoder UserHasFilter
decoder =
    Decode.string
        |> Decode.andThen
            (\string ->
                case string of
                    "createdAt" ->
                        Decode.succeed CreatedAt

                    "lastAck" ->
                        Decode.succeed LastAck

                    "username" ->
                        Decode.succeed Username

                    "name" ->
                        Decode.succeed Name

                    "password" ->
                        Decode.succeed Password

                    "email" ->
                        Decode.succeed Email

                    "emailHash" ->
                        Decode.succeed EmailHash

                    "emailValidated" ->
                        Decode.succeed EmailValidated

                    "bio" ->
                        Decode.succeed Bio

                    "utc" ->
                        Decode.succeed Utc

                    "notifyByEmail" ->
                        Decode.succeed NotifyByEmail

                    "subscriptions" ->
                        Decode.succeed Subscriptions

                    "rights" ->
                        Decode.succeed Rights

                    "roles" ->
                        Decode.succeed Roles

                    "backed_roles" ->
                        Decode.succeed Backed_roles

                    "tensions_created" ->
                        Decode.succeed Tensions_created

                    "tensions_assigned" ->
                        Decode.succeed Tensions_assigned

                    "contracts" ->
                        Decode.succeed Contracts

                    "events" ->
                        Decode.succeed Events

                    _ ->
                        Decode.fail ("Invalid UserHasFilter type, " ++ string ++ " try re-running the @dillonkearns/elm-graphql CLI ")
            )


{-| Convert from the union type representing the Enum to a string that the GraphQL server will recognize.
-}
toString : UserHasFilter -> String
toString enum____ =
    case enum____ of
        CreatedAt ->
            "createdAt"

        LastAck ->
            "lastAck"

        Username ->
            "username"

        Name ->
            "name"

        Password ->
            "password"

        Email ->
            "email"

        EmailHash ->
            "emailHash"

        EmailValidated ->
            "emailValidated"

        Bio ->
            "bio"

        Utc ->
            "utc"

        NotifyByEmail ->
            "notifyByEmail"

        Subscriptions ->
            "subscriptions"

        Rights ->
            "rights"

        Roles ->
            "roles"

        Backed_roles ->
            "backed_roles"

        Tensions_created ->
            "tensions_created"

        Tensions_assigned ->
            "tensions_assigned"

        Contracts ->
            "contracts"

        Events ->
            "events"


{-| Convert from a String representation to an elm representation enum.
This is the inverse of the Enum `toString` function. So you can call `toString` and then convert back `fromString` safely.

    Swapi.Enum.Episode.NewHope
        |> Swapi.Enum.Episode.toString
        |> Swapi.Enum.Episode.fromString
        == Just NewHope

This can be useful for generating Strings to use for <select> menus to check which item was selected.

-}
fromString : String -> Maybe UserHasFilter
fromString enumString____ =
    case enumString____ of
        "createdAt" ->
            Just CreatedAt

        "lastAck" ->
            Just LastAck

        "username" ->
            Just Username

        "name" ->
            Just Name

        "password" ->
            Just Password

        "email" ->
            Just Email

        "emailHash" ->
            Just EmailHash

        "emailValidated" ->
            Just EmailValidated

        "bio" ->
            Just Bio

        "utc" ->
            Just Utc

        "notifyByEmail" ->
            Just NotifyByEmail

        "subscriptions" ->
            Just Subscriptions

        "rights" ->
            Just Rights

        "roles" ->
            Just Roles

        "backed_roles" ->
            Just Backed_roles

        "tensions_created" ->
            Just Tensions_created

        "tensions_assigned" ->
            Just Tensions_assigned

        "contracts" ->
            Just Contracts

        "events" ->
            Just Events

        _ ->
            Nothing
