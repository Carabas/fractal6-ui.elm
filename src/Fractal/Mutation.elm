-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Fractal.Mutation exposing (..)

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
import Json.Decode as Decode exposing (Decoder)


type alias AddNodeRequiredArguments =
    { input : List Fractal.InputObject.AddNodeInput }


addNode : AddNodeRequiredArguments -> SelectionSet decodesTo Fractal.Object.AddNodePayload -> SelectionSet (Maybe decodesTo) RootMutation
addNode requiredArgs object_ =
    Object.selectionForCompositeField "addNode" [ Argument.required "input" requiredArgs.input (Fractal.InputObject.encodeAddNodeInput |> Encode.list) ] object_ (identity >> Decode.nullable)


type alias UpdateNodeRequiredArguments =
    { input : Fractal.InputObject.UpdateNodeInput }


updateNode : UpdateNodeRequiredArguments -> SelectionSet decodesTo Fractal.Object.UpdateNodePayload -> SelectionSet (Maybe decodesTo) RootMutation
updateNode requiredArgs object_ =
    Object.selectionForCompositeField "updateNode" [ Argument.required "input" requiredArgs.input Fractal.InputObject.encodeUpdateNodeInput ] object_ (identity >> Decode.nullable)


type alias DeleteNodeRequiredArguments =
    { filter : Fractal.InputObject.NodeFilter }


deleteNode : DeleteNodeRequiredArguments -> SelectionSet decodesTo Fractal.Object.DeleteNodePayload -> SelectionSet (Maybe decodesTo) RootMutation
deleteNode requiredArgs object_ =
    Object.selectionForCompositeField "deleteNode" [ Argument.required "filter" requiredArgs.filter Fractal.InputObject.encodeNodeFilter ] object_ (identity >> Decode.nullable)


type alias UpdatePostRequiredArguments =
    { input : Fractal.InputObject.UpdatePostInput }


updatePost : UpdatePostRequiredArguments -> SelectionSet decodesTo Fractal.Object.UpdatePostPayload -> SelectionSet (Maybe decodesTo) RootMutation
updatePost requiredArgs object_ =
    Object.selectionForCompositeField "updatePost" [ Argument.required "input" requiredArgs.input Fractal.InputObject.encodeUpdatePostInput ] object_ (identity >> Decode.nullable)


type alias DeletePostRequiredArguments =
    { filter : Fractal.InputObject.PostFilter }


deletePost : DeletePostRequiredArguments -> SelectionSet decodesTo Fractal.Object.DeletePostPayload -> SelectionSet (Maybe decodesTo) RootMutation
deletePost requiredArgs object_ =
    Object.selectionForCompositeField "deletePost" [ Argument.required "filter" requiredArgs.filter Fractal.InputObject.encodePostFilter ] object_ (identity >> Decode.nullable)


type alias AddTensionRequiredArguments =
    { input : List Fractal.InputObject.AddTensionInput }


addTension : AddTensionRequiredArguments -> SelectionSet decodesTo Fractal.Object.AddTensionPayload -> SelectionSet (Maybe decodesTo) RootMutation
addTension requiredArgs object_ =
    Object.selectionForCompositeField "addTension" [ Argument.required "input" requiredArgs.input (Fractal.InputObject.encodeAddTensionInput |> Encode.list) ] object_ (identity >> Decode.nullable)


type alias UpdateTensionRequiredArguments =
    { input : Fractal.InputObject.UpdateTensionInput }


updateTension : UpdateTensionRequiredArguments -> SelectionSet decodesTo Fractal.Object.UpdateTensionPayload -> SelectionSet (Maybe decodesTo) RootMutation
updateTension requiredArgs object_ =
    Object.selectionForCompositeField "updateTension" [ Argument.required "input" requiredArgs.input Fractal.InputObject.encodeUpdateTensionInput ] object_ (identity >> Decode.nullable)


type alias DeleteTensionRequiredArguments =
    { filter : Fractal.InputObject.TensionFilter }


deleteTension : DeleteTensionRequiredArguments -> SelectionSet decodesTo Fractal.Object.DeleteTensionPayload -> SelectionSet (Maybe decodesTo) RootMutation
deleteTension requiredArgs object_ =
    Object.selectionForCompositeField "deleteTension" [ Argument.required "filter" requiredArgs.filter Fractal.InputObject.encodeTensionFilter ] object_ (identity >> Decode.nullable)


type alias AddCommentRequiredArguments =
    { input : List Fractal.InputObject.AddCommentInput }


addComment : AddCommentRequiredArguments -> SelectionSet decodesTo Fractal.Object.AddCommentPayload -> SelectionSet (Maybe decodesTo) RootMutation
addComment requiredArgs object_ =
    Object.selectionForCompositeField "addComment" [ Argument.required "input" requiredArgs.input (Fractal.InputObject.encodeAddCommentInput |> Encode.list) ] object_ (identity >> Decode.nullable)


type alias UpdateCommentRequiredArguments =
    { input : Fractal.InputObject.UpdateCommentInput }


updateComment : UpdateCommentRequiredArguments -> SelectionSet decodesTo Fractal.Object.UpdateCommentPayload -> SelectionSet (Maybe decodesTo) RootMutation
updateComment requiredArgs object_ =
    Object.selectionForCompositeField "updateComment" [ Argument.required "input" requiredArgs.input Fractal.InputObject.encodeUpdateCommentInput ] object_ (identity >> Decode.nullable)


type alias DeleteCommentRequiredArguments =
    { filter : Fractal.InputObject.CommentFilter }


deleteComment : DeleteCommentRequiredArguments -> SelectionSet decodesTo Fractal.Object.DeleteCommentPayload -> SelectionSet (Maybe decodesTo) RootMutation
deleteComment requiredArgs object_ =
    Object.selectionForCompositeField "deleteComment" [ Argument.required "filter" requiredArgs.filter Fractal.InputObject.encodeCommentFilter ] object_ (identity >> Decode.nullable)


type alias AddMandateRequiredArguments =
    { input : List Fractal.InputObject.AddMandateInput }


addMandate : AddMandateRequiredArguments -> SelectionSet decodesTo Fractal.Object.AddMandatePayload -> SelectionSet (Maybe decodesTo) RootMutation
addMandate requiredArgs object_ =
    Object.selectionForCompositeField "addMandate" [ Argument.required "input" requiredArgs.input (Fractal.InputObject.encodeAddMandateInput |> Encode.list) ] object_ (identity >> Decode.nullable)


type alias UpdateMandateRequiredArguments =
    { input : Fractal.InputObject.UpdateMandateInput }


updateMandate : UpdateMandateRequiredArguments -> SelectionSet decodesTo Fractal.Object.UpdateMandatePayload -> SelectionSet (Maybe decodesTo) RootMutation
updateMandate requiredArgs object_ =
    Object.selectionForCompositeField "updateMandate" [ Argument.required "input" requiredArgs.input Fractal.InputObject.encodeUpdateMandateInput ] object_ (identity >> Decode.nullable)


type alias DeleteMandateRequiredArguments =
    { filter : Fractal.InputObject.MandateFilter }


deleteMandate : DeleteMandateRequiredArguments -> SelectionSet decodesTo Fractal.Object.DeleteMandatePayload -> SelectionSet (Maybe decodesTo) RootMutation
deleteMandate requiredArgs object_ =
    Object.selectionForCompositeField "deleteMandate" [ Argument.required "filter" requiredArgs.filter Fractal.InputObject.encodeMandateFilter ] object_ (identity >> Decode.nullable)


type alias AddUserRequiredArguments =
    { input : List Fractal.InputObject.AddUserInput }


addUser : AddUserRequiredArguments -> SelectionSet decodesTo Fractal.Object.AddUserPayload -> SelectionSet (Maybe decodesTo) RootMutation
addUser requiredArgs object_ =
    Object.selectionForCompositeField "addUser" [ Argument.required "input" requiredArgs.input (Fractal.InputObject.encodeAddUserInput |> Encode.list) ] object_ (identity >> Decode.nullable)


type alias UpdateUserRequiredArguments =
    { input : Fractal.InputObject.UpdateUserInput }


updateUser : UpdateUserRequiredArguments -> SelectionSet decodesTo Fractal.Object.UpdateUserPayload -> SelectionSet (Maybe decodesTo) RootMutation
updateUser requiredArgs object_ =
    Object.selectionForCompositeField "updateUser" [ Argument.required "input" requiredArgs.input Fractal.InputObject.encodeUpdateUserInput ] object_ (identity >> Decode.nullable)


type alias DeleteUserRequiredArguments =
    { filter : Fractal.InputObject.UserFilter }


deleteUser : DeleteUserRequiredArguments -> SelectionSet decodesTo Fractal.Object.DeleteUserPayload -> SelectionSet (Maybe decodesTo) RootMutation
deleteUser requiredArgs object_ =
    Object.selectionForCompositeField "deleteUser" [ Argument.required "filter" requiredArgs.filter Fractal.InputObject.encodeUserFilter ] object_ (identity >> Decode.nullable)


type alias AddUserRightsRequiredArguments =
    { input : List Fractal.InputObject.AddUserRightsInput }


addUserRights : AddUserRightsRequiredArguments -> SelectionSet decodesTo Fractal.Object.AddUserRightsPayload -> SelectionSet (Maybe decodesTo) RootMutation
addUserRights requiredArgs object_ =
    Object.selectionForCompositeField "addUserRights" [ Argument.required "input" requiredArgs.input (Fractal.InputObject.encodeAddUserRightsInput |> Encode.list) ] object_ (identity >> Decode.nullable)


type alias AddLabelRequiredArguments =
    { input : List Fractal.InputObject.AddLabelInput }


addLabel : AddLabelRequiredArguments -> SelectionSet decodesTo Fractal.Object.AddLabelPayload -> SelectionSet (Maybe decodesTo) RootMutation
addLabel requiredArgs object_ =
    Object.selectionForCompositeField "addLabel" [ Argument.required "input" requiredArgs.input (Fractal.InputObject.encodeAddLabelInput |> Encode.list) ] object_ (identity >> Decode.nullable)


type alias UpdateLabelRequiredArguments =
    { input : Fractal.InputObject.UpdateLabelInput }


updateLabel : UpdateLabelRequiredArguments -> SelectionSet decodesTo Fractal.Object.UpdateLabelPayload -> SelectionSet (Maybe decodesTo) RootMutation
updateLabel requiredArgs object_ =
    Object.selectionForCompositeField "updateLabel" [ Argument.required "input" requiredArgs.input Fractal.InputObject.encodeUpdateLabelInput ] object_ (identity >> Decode.nullable)


type alias DeleteLabelRequiredArguments =
    { filter : Fractal.InputObject.LabelFilter }


deleteLabel : DeleteLabelRequiredArguments -> SelectionSet decodesTo Fractal.Object.DeleteLabelPayload -> SelectionSet (Maybe decodesTo) RootMutation
deleteLabel requiredArgs object_ =
    Object.selectionForCompositeField "deleteLabel" [ Argument.required "filter" requiredArgs.filter Fractal.InputObject.encodeLabelFilter ] object_ (identity >> Decode.nullable)
