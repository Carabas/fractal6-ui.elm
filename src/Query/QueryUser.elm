module Query.QueryUser exposing (queryUctx)

import Dict exposing (Dict)
import Fractal.Enum.NodeType as NodeType
import Fractal.Enum.RoleType as RoleType
import Fractal.InputObject as Input
import Fractal.Object
import Fractal.Object.Node
import Fractal.Object.User
import Fractal.Object.UserRights
import Fractal.Query as Query
import Fractal.Scalar
import GqlClient exposing (..)
import Graphql.OptionalArgument as OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet, hardcoded, with)
import Maybe exposing (withDefault)
import ModelSchema exposing (..)
import RemoteData exposing (RemoteData)



{-
   Query UserCtx
-}


queryUctx url username msg =
    makeGQLQuery url
        (Query.getUser
            (uctxFilter username)
            uctxPayload
        )
        (RemoteData.fromResult >> decodeResponse identity >> msg)


uctxFilter : String -> Query.GetUserOptionalArguments -> Query.GetUserOptionalArguments
uctxFilter username a =
    { a | username = Present username }


uctxPayload : SelectionSet UserCtx Fractal.Object.User
uctxPayload =
    SelectionSet.succeed UserCtx
        |> with Fractal.Object.User.username
        |> with Fractal.Object.User.name
        |> with
            (Fractal.Object.User.rights identity <|
                SelectionSet.map3 UserRights
                    Fractal.Object.UserRights.canLogin
                    Fractal.Object.UserRights.canCreateRoot
                    Fractal.Object.UserRights.type_
            )
        |> with
            (Fractal.Object.User.roles identity
                (SelectionSet.map3 UserRole
                    Fractal.Object.Node.name
                    Fractal.Object.Node.nameid
                    (Fractal.Object.Node.role_type |> SelectionSet.map (\x -> withDefault RoleType.Peer x))
                )
                |> SelectionSet.map (\x -> withDefault [] x)
            )



-- Purpose: was here ebefore @auth directive to filter....
--pubFilter : Query.QueryNodeOptionalArguments -> Query.QueryNodeOptionalArguments
--pubFilter a =
--    { a
--        | filter =
--            Input.buildNodeFilter
--                (\b -> { b | isPrivate = Present False })
--                |> Present
--    }
