module Generated.Pages exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Generated.Route as Route exposing (Route)
import Global
import Page exposing (Bundle, Document)
import Pages.Top
import Pages.Explore
import Pages.Login
import Pages.Logout
import Pages.NotFound
import Pages.Signup
import Pages.Dynamic
import Pages.New.Orga
import Pages.M.Dynamic
import Pages.O.Dynamic
import Pages.S.Dynamic
import Pages.T.Dynamic
import Pages.User.Dynamic
import Pages.M.Dynamic.Dynamic
import Pages.O.Dynamic.Dynamic
import Pages.S.Dynamic.Dynamic
import Pages.T.Dynamic.Dynamic
import Pages.Tension.Dynamic.Dynamic
import Pages.Tension.Dynamic.Dynamic.Action
import Pages.Tension.Dynamic.Dynamic.Contract
import Pages.M.Dynamic.Dynamic.Dynamic
import Pages.O.Dynamic.Dynamic.Dynamic
import Pages.S.Dynamic.Dynamic.Dynamic
import Pages.T.Dynamic.Dynamic.Dynamic



-- TYPES


type Model
    = Top_Model Pages.Top.Model
    | Explore_Model Pages.Explore.Model
    | Login_Model Pages.Login.Model
    | Logout_Model Pages.Logout.Model
    | NotFound_Model Pages.NotFound.Model
    | Signup_Model Pages.Signup.Model
    | Dynamic_Model Pages.Dynamic.Model
    | New_Orga_Model Pages.New.Orga.Model
    | M_Dynamic_Model Pages.M.Dynamic.Model
    | O_Dynamic_Model Pages.O.Dynamic.Model
    | S_Dynamic_Model Pages.S.Dynamic.Model
    | T_Dynamic_Model Pages.T.Dynamic.Model
    | User_Dynamic_Model Pages.User.Dynamic.Model
    | M_Dynamic_Dynamic_Model Pages.M.Dynamic.Dynamic.Model
    | O_Dynamic_Dynamic_Model Pages.O.Dynamic.Dynamic.Model
    | S_Dynamic_Dynamic_Model Pages.S.Dynamic.Dynamic.Model
    | T_Dynamic_Dynamic_Model Pages.T.Dynamic.Dynamic.Model
    | Tension_Dynamic_Dynamic_Model Pages.Tension.Dynamic.Dynamic.Model
    | Tension_Dynamic_Dynamic_Action_Model Pages.Tension.Dynamic.Dynamic.Action.Model
    | Tension_Dynamic_Dynamic_Contract_Model Pages.Tension.Dynamic.Dynamic.Contract.Model
    | M_Dynamic_Dynamic_Dynamic_Model Pages.M.Dynamic.Dynamic.Dynamic.Model
    | O_Dynamic_Dynamic_Dynamic_Model Pages.O.Dynamic.Dynamic.Dynamic.Model
    | S_Dynamic_Dynamic_Dynamic_Model Pages.S.Dynamic.Dynamic.Dynamic.Model
    | T_Dynamic_Dynamic_Dynamic_Model Pages.T.Dynamic.Dynamic.Dynamic.Model


type Msg
    = Top_Msg Pages.Top.Msg
    | Explore_Msg Pages.Explore.Msg
    | Login_Msg Pages.Login.Msg
    | Logout_Msg Pages.Logout.Msg
    | NotFound_Msg Pages.NotFound.Msg
    | Signup_Msg Pages.Signup.Msg
    | Dynamic_Msg Pages.Dynamic.Msg
    | New_Orga_Msg Pages.New.Orga.Msg
    | M_Dynamic_Msg Pages.M.Dynamic.Msg
    | O_Dynamic_Msg Pages.O.Dynamic.Msg
    | S_Dynamic_Msg Pages.S.Dynamic.Msg
    | T_Dynamic_Msg Pages.T.Dynamic.Msg
    | User_Dynamic_Msg Pages.User.Dynamic.Msg
    | M_Dynamic_Dynamic_Msg Pages.M.Dynamic.Dynamic.Msg
    | O_Dynamic_Dynamic_Msg Pages.O.Dynamic.Dynamic.Msg
    | S_Dynamic_Dynamic_Msg Pages.S.Dynamic.Dynamic.Msg
    | T_Dynamic_Dynamic_Msg Pages.T.Dynamic.Dynamic.Msg
    | Tension_Dynamic_Dynamic_Msg Pages.Tension.Dynamic.Dynamic.Msg
    | Tension_Dynamic_Dynamic_Action_Msg Pages.Tension.Dynamic.Dynamic.Action.Msg
    | Tension_Dynamic_Dynamic_Contract_Msg Pages.Tension.Dynamic.Dynamic.Contract.Msg
    | M_Dynamic_Dynamic_Dynamic_Msg Pages.M.Dynamic.Dynamic.Dynamic.Msg
    | O_Dynamic_Dynamic_Dynamic_Msg Pages.O.Dynamic.Dynamic.Dynamic.Msg
    | S_Dynamic_Dynamic_Dynamic_Msg Pages.S.Dynamic.Dynamic.Dynamic.Msg
    | T_Dynamic_Dynamic_Dynamic_Msg Pages.T.Dynamic.Dynamic.Dynamic.Msg



-- PAGES


type alias UpgradedPage flags model msg =
    { init : flags -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
    , update : msg -> model -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
    , bundle : model -> Global.Model -> Bundle Msg
    }


type alias UpgradedPages =
    { top : UpgradedPage Pages.Top.Flags Pages.Top.Model Pages.Top.Msg
    , explore : UpgradedPage Pages.Explore.Flags Pages.Explore.Model Pages.Explore.Msg
    , login : UpgradedPage Pages.Login.Flags Pages.Login.Model Pages.Login.Msg
    , logout : UpgradedPage Pages.Logout.Flags Pages.Logout.Model Pages.Logout.Msg
    , notFound : UpgradedPage Pages.NotFound.Flags Pages.NotFound.Model Pages.NotFound.Msg
    , signup : UpgradedPage Pages.Signup.Flags Pages.Signup.Model Pages.Signup.Msg
    , dynamic : UpgradedPage Pages.Dynamic.Flags Pages.Dynamic.Model Pages.Dynamic.Msg
    , new_orga : UpgradedPage Pages.New.Orga.Flags Pages.New.Orga.Model Pages.New.Orga.Msg
    , m_dynamic : UpgradedPage Pages.M.Dynamic.Flags Pages.M.Dynamic.Model Pages.M.Dynamic.Msg
    , o_dynamic : UpgradedPage Pages.O.Dynamic.Flags Pages.O.Dynamic.Model Pages.O.Dynamic.Msg
    , s_dynamic : UpgradedPage Pages.S.Dynamic.Flags Pages.S.Dynamic.Model Pages.S.Dynamic.Msg
    , t_dynamic : UpgradedPage Pages.T.Dynamic.Flags Pages.T.Dynamic.Model Pages.T.Dynamic.Msg
    , user_dynamic : UpgradedPage Pages.User.Dynamic.Flags Pages.User.Dynamic.Model Pages.User.Dynamic.Msg
    , m_dynamic_dynamic : UpgradedPage Pages.M.Dynamic.Dynamic.Flags Pages.M.Dynamic.Dynamic.Model Pages.M.Dynamic.Dynamic.Msg
    , o_dynamic_dynamic : UpgradedPage Pages.O.Dynamic.Dynamic.Flags Pages.O.Dynamic.Dynamic.Model Pages.O.Dynamic.Dynamic.Msg
    , s_dynamic_dynamic : UpgradedPage Pages.S.Dynamic.Dynamic.Flags Pages.S.Dynamic.Dynamic.Model Pages.S.Dynamic.Dynamic.Msg
    , t_dynamic_dynamic : UpgradedPage Pages.T.Dynamic.Dynamic.Flags Pages.T.Dynamic.Dynamic.Model Pages.T.Dynamic.Dynamic.Msg
    , tension_dynamic_dynamic : UpgradedPage Pages.Tension.Dynamic.Dynamic.Flags Pages.Tension.Dynamic.Dynamic.Model Pages.Tension.Dynamic.Dynamic.Msg
    , tension_dynamic_dynamic_action : UpgradedPage Pages.Tension.Dynamic.Dynamic.Action.Flags Pages.Tension.Dynamic.Dynamic.Action.Model Pages.Tension.Dynamic.Dynamic.Action.Msg
    , tension_dynamic_dynamic_contract : UpgradedPage Pages.Tension.Dynamic.Dynamic.Contract.Flags Pages.Tension.Dynamic.Dynamic.Contract.Model Pages.Tension.Dynamic.Dynamic.Contract.Msg
    , m_dynamic_dynamic_dynamic : UpgradedPage Pages.M.Dynamic.Dynamic.Dynamic.Flags Pages.M.Dynamic.Dynamic.Dynamic.Model Pages.M.Dynamic.Dynamic.Dynamic.Msg
    , o_dynamic_dynamic_dynamic : UpgradedPage Pages.O.Dynamic.Dynamic.Dynamic.Flags Pages.O.Dynamic.Dynamic.Dynamic.Model Pages.O.Dynamic.Dynamic.Dynamic.Msg
    , s_dynamic_dynamic_dynamic : UpgradedPage Pages.S.Dynamic.Dynamic.Dynamic.Flags Pages.S.Dynamic.Dynamic.Dynamic.Model Pages.S.Dynamic.Dynamic.Dynamic.Msg
    , t_dynamic_dynamic_dynamic : UpgradedPage Pages.T.Dynamic.Dynamic.Dynamic.Flags Pages.T.Dynamic.Dynamic.Dynamic.Model Pages.T.Dynamic.Dynamic.Dynamic.Msg
    }


pages : UpgradedPages
pages =
    { top = Pages.Top.page |> Page.upgrade Top_Model Top_Msg
    , explore = Pages.Explore.page |> Page.upgrade Explore_Model Explore_Msg
    , login = Pages.Login.page |> Page.upgrade Login_Model Login_Msg
    , logout = Pages.Logout.page |> Page.upgrade Logout_Model Logout_Msg
    , notFound = Pages.NotFound.page |> Page.upgrade NotFound_Model NotFound_Msg
    , signup = Pages.Signup.page |> Page.upgrade Signup_Model Signup_Msg
    , dynamic = Pages.Dynamic.page |> Page.upgrade Dynamic_Model Dynamic_Msg
    , new_orga = Pages.New.Orga.page |> Page.upgrade New_Orga_Model New_Orga_Msg
    , m_dynamic = Pages.M.Dynamic.page |> Page.upgrade M_Dynamic_Model M_Dynamic_Msg
    , o_dynamic = Pages.O.Dynamic.page |> Page.upgrade O_Dynamic_Model O_Dynamic_Msg
    , s_dynamic = Pages.S.Dynamic.page |> Page.upgrade S_Dynamic_Model S_Dynamic_Msg
    , t_dynamic = Pages.T.Dynamic.page |> Page.upgrade T_Dynamic_Model T_Dynamic_Msg
    , user_dynamic = Pages.User.Dynamic.page |> Page.upgrade User_Dynamic_Model User_Dynamic_Msg
    , m_dynamic_dynamic = Pages.M.Dynamic.Dynamic.page |> Page.upgrade M_Dynamic_Dynamic_Model M_Dynamic_Dynamic_Msg
    , o_dynamic_dynamic = Pages.O.Dynamic.Dynamic.page |> Page.upgrade O_Dynamic_Dynamic_Model O_Dynamic_Dynamic_Msg
    , s_dynamic_dynamic = Pages.S.Dynamic.Dynamic.page |> Page.upgrade S_Dynamic_Dynamic_Model S_Dynamic_Dynamic_Msg
    , t_dynamic_dynamic = Pages.T.Dynamic.Dynamic.page |> Page.upgrade T_Dynamic_Dynamic_Model T_Dynamic_Dynamic_Msg
    , tension_dynamic_dynamic = Pages.Tension.Dynamic.Dynamic.page |> Page.upgrade Tension_Dynamic_Dynamic_Model Tension_Dynamic_Dynamic_Msg
    , tension_dynamic_dynamic_action = Pages.Tension.Dynamic.Dynamic.Action.page |> Page.upgrade Tension_Dynamic_Dynamic_Action_Model Tension_Dynamic_Dynamic_Action_Msg
    , tension_dynamic_dynamic_contract = Pages.Tension.Dynamic.Dynamic.Contract.page |> Page.upgrade Tension_Dynamic_Dynamic_Contract_Model Tension_Dynamic_Dynamic_Contract_Msg
    , m_dynamic_dynamic_dynamic = Pages.M.Dynamic.Dynamic.Dynamic.page |> Page.upgrade M_Dynamic_Dynamic_Dynamic_Model M_Dynamic_Dynamic_Dynamic_Msg
    , o_dynamic_dynamic_dynamic = Pages.O.Dynamic.Dynamic.Dynamic.page |> Page.upgrade O_Dynamic_Dynamic_Dynamic_Model O_Dynamic_Dynamic_Dynamic_Msg
    , s_dynamic_dynamic_dynamic = Pages.S.Dynamic.Dynamic.Dynamic.page |> Page.upgrade S_Dynamic_Dynamic_Dynamic_Model S_Dynamic_Dynamic_Dynamic_Msg
    , t_dynamic_dynamic_dynamic = Pages.T.Dynamic.Dynamic.Dynamic.page |> Page.upgrade T_Dynamic_Dynamic_Dynamic_Model T_Dynamic_Dynamic_Dynamic_Msg
    }



-- INIT


init : Route -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
init route =
    case route of
        Route.Top ->
            pages.top.init ()
        
        Route.Explore ->
            pages.explore.init ()
        
        Route.Login ->
            pages.login.init ()
        
        Route.Logout ->
            pages.logout.init ()
        
        Route.NotFound ->
            pages.notFound.init ()
        
        Route.Signup ->
            pages.signup.init ()
        
        Route.Dynamic params ->
            pages.dynamic.init params
        
        Route.New_Orga ->
            pages.new_orga.init ()
        
        Route.M_Dynamic params ->
            pages.m_dynamic.init params
        
        Route.O_Dynamic params ->
            pages.o_dynamic.init params
        
        Route.S_Dynamic params ->
            pages.s_dynamic.init params
        
        Route.T_Dynamic params ->
            pages.t_dynamic.init params
        
        Route.User_Dynamic params ->
            pages.user_dynamic.init params
        
        Route.M_Dynamic_Dynamic params ->
            pages.m_dynamic_dynamic.init params
        
        Route.O_Dynamic_Dynamic params ->
            pages.o_dynamic_dynamic.init params
        
        Route.S_Dynamic_Dynamic params ->
            pages.s_dynamic_dynamic.init params
        
        Route.T_Dynamic_Dynamic params ->
            pages.t_dynamic_dynamic.init params
        
        Route.Tension_Dynamic_Dynamic params ->
            pages.tension_dynamic_dynamic.init params
        
        Route.Tension_Dynamic_Dynamic_Action params ->
            pages.tension_dynamic_dynamic_action.init params
        
        Route.Tension_Dynamic_Dynamic_Contract params ->
            pages.tension_dynamic_dynamic_contract.init params
        
        Route.M_Dynamic_Dynamic_Dynamic params ->
            pages.m_dynamic_dynamic_dynamic.init params
        
        Route.O_Dynamic_Dynamic_Dynamic params ->
            pages.o_dynamic_dynamic_dynamic.init params
        
        Route.S_Dynamic_Dynamic_Dynamic params ->
            pages.s_dynamic_dynamic_dynamic.init params
        
        Route.T_Dynamic_Dynamic_Dynamic params ->
            pages.t_dynamic_dynamic_dynamic.init params



-- UPDATE


update : Msg -> Model -> Global.Model -> ( Model, Cmd Msg, Cmd Global.Msg )
update bigMsg bigModel =
    case ( bigMsg, bigModel ) of
        ( Top_Msg msg, Top_Model model ) ->
            pages.top.update msg model
        
        ( Explore_Msg msg, Explore_Model model ) ->
            pages.explore.update msg model
        
        ( Login_Msg msg, Login_Model model ) ->
            pages.login.update msg model
        
        ( Logout_Msg msg, Logout_Model model ) ->
            pages.logout.update msg model
        
        ( NotFound_Msg msg, NotFound_Model model ) ->
            pages.notFound.update msg model
        
        ( Signup_Msg msg, Signup_Model model ) ->
            pages.signup.update msg model
        
        ( Dynamic_Msg msg, Dynamic_Model model ) ->
            pages.dynamic.update msg model
        
        ( New_Orga_Msg msg, New_Orga_Model model ) ->
            pages.new_orga.update msg model
        
        ( M_Dynamic_Msg msg, M_Dynamic_Model model ) ->
            pages.m_dynamic.update msg model
        
        ( O_Dynamic_Msg msg, O_Dynamic_Model model ) ->
            pages.o_dynamic.update msg model
        
        ( S_Dynamic_Msg msg, S_Dynamic_Model model ) ->
            pages.s_dynamic.update msg model
        
        ( T_Dynamic_Msg msg, T_Dynamic_Model model ) ->
            pages.t_dynamic.update msg model
        
        ( User_Dynamic_Msg msg, User_Dynamic_Model model ) ->
            pages.user_dynamic.update msg model
        
        ( M_Dynamic_Dynamic_Msg msg, M_Dynamic_Dynamic_Model model ) ->
            pages.m_dynamic_dynamic.update msg model
        
        ( O_Dynamic_Dynamic_Msg msg, O_Dynamic_Dynamic_Model model ) ->
            pages.o_dynamic_dynamic.update msg model
        
        ( S_Dynamic_Dynamic_Msg msg, S_Dynamic_Dynamic_Model model ) ->
            pages.s_dynamic_dynamic.update msg model
        
        ( T_Dynamic_Dynamic_Msg msg, T_Dynamic_Dynamic_Model model ) ->
            pages.t_dynamic_dynamic.update msg model
        
        ( Tension_Dynamic_Dynamic_Msg msg, Tension_Dynamic_Dynamic_Model model ) ->
            pages.tension_dynamic_dynamic.update msg model
        
        ( Tension_Dynamic_Dynamic_Action_Msg msg, Tension_Dynamic_Dynamic_Action_Model model ) ->
            pages.tension_dynamic_dynamic_action.update msg model
        
        ( Tension_Dynamic_Dynamic_Contract_Msg msg, Tension_Dynamic_Dynamic_Contract_Model model ) ->
            pages.tension_dynamic_dynamic_contract.update msg model
        
        ( M_Dynamic_Dynamic_Dynamic_Msg msg, M_Dynamic_Dynamic_Dynamic_Model model ) ->
            pages.m_dynamic_dynamic_dynamic.update msg model
        
        ( O_Dynamic_Dynamic_Dynamic_Msg msg, O_Dynamic_Dynamic_Dynamic_Model model ) ->
            pages.o_dynamic_dynamic_dynamic.update msg model
        
        ( S_Dynamic_Dynamic_Dynamic_Msg msg, S_Dynamic_Dynamic_Dynamic_Model model ) ->
            pages.s_dynamic_dynamic_dynamic.update msg model
        
        ( T_Dynamic_Dynamic_Dynamic_Msg msg, T_Dynamic_Dynamic_Dynamic_Model model ) ->
            pages.t_dynamic_dynamic_dynamic.update msg model
        
        _ ->
            always ( bigModel, Cmd.none, Cmd.none )



-- BUNDLE - (view + subscriptions)


bundle : Model -> Global.Model -> Bundle Msg
bundle bigModel =
    case bigModel of
        Top_Model model ->
            pages.top.bundle model
        
        Explore_Model model ->
            pages.explore.bundle model
        
        Login_Model model ->
            pages.login.bundle model
        
        Logout_Model model ->
            pages.logout.bundle model
        
        NotFound_Model model ->
            pages.notFound.bundle model
        
        Signup_Model model ->
            pages.signup.bundle model
        
        Dynamic_Model model ->
            pages.dynamic.bundle model
        
        New_Orga_Model model ->
            pages.new_orga.bundle model
        
        M_Dynamic_Model model ->
            pages.m_dynamic.bundle model
        
        O_Dynamic_Model model ->
            pages.o_dynamic.bundle model
        
        S_Dynamic_Model model ->
            pages.s_dynamic.bundle model
        
        T_Dynamic_Model model ->
            pages.t_dynamic.bundle model
        
        User_Dynamic_Model model ->
            pages.user_dynamic.bundle model
        
        M_Dynamic_Dynamic_Model model ->
            pages.m_dynamic_dynamic.bundle model
        
        O_Dynamic_Dynamic_Model model ->
            pages.o_dynamic_dynamic.bundle model
        
        S_Dynamic_Dynamic_Model model ->
            pages.s_dynamic_dynamic.bundle model
        
        T_Dynamic_Dynamic_Model model ->
            pages.t_dynamic_dynamic.bundle model
        
        Tension_Dynamic_Dynamic_Model model ->
            pages.tension_dynamic_dynamic.bundle model
        
        Tension_Dynamic_Dynamic_Action_Model model ->
            pages.tension_dynamic_dynamic_action.bundle model
        
        Tension_Dynamic_Dynamic_Contract_Model model ->
            pages.tension_dynamic_dynamic_contract.bundle model
        
        M_Dynamic_Dynamic_Dynamic_Model model ->
            pages.m_dynamic_dynamic_dynamic.bundle model
        
        O_Dynamic_Dynamic_Dynamic_Model model ->
            pages.o_dynamic_dynamic_dynamic.bundle model
        
        S_Dynamic_Dynamic_Dynamic_Model model ->
            pages.s_dynamic_dynamic_dynamic.bundle model
        
        T_Dynamic_Dynamic_Dynamic_Model model ->
            pages.t_dynamic_dynamic_dynamic.bundle model


view : Model -> Global.Model -> Document Msg
view model =
    bundle model >> .view


subscriptions : Model -> Global.Model -> Sub Msg
subscriptions model =
    bundle model >> .subscriptions