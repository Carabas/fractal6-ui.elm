module Components.Navbar exposing (view)

import Components.Fa as Fa
import Components.Logo as Logo
import Generated.Route as Route exposing (Route, toHref)
import Html exposing (Html, a, div, header, hr, i, nav, span, text)
import Html.Attributes as Attr exposing (attribute, class, href, id, style)
import ModelCommon exposing (UserState(..))


view : UserState -> Html msg
view user =
    header [ id "navbarTop", class "has-navbar-fixed-top" ]
        [ nav
            [ class "navbar has-shadow is-fixed-top"
            , attribute "role" "navigation"
            , attribute "aria-label" "main navigation"
            ]
            [ div [ class "navbar-brand" ]
                [ a [ class "navbar-item", href "/" ]
                    --[ img [ alt "Fractal", attribute "height" "28", attribute "width" "112", src "https://bulma.io/images/bulma-logo.png" ] [] ]
                    [ Logo.logo_fractal
                    , span [ class "is-subtitle is-size-7 has-text-warning", attribute "style" "padding-top: 15px; margin-left: -5px;" ] [ text "Alpha" ]

                    --, span [ class "is-size-5" ] [ text "Fractal6" ]
                    ]
                , div
                    [ class "navbar-burger burger"
                    , attribute "data-target" "navMenu"
                    , attribute "aria-expanded" "false"
                    , attribute "aria-label" "menu"
                    , attribute "role" "button"
                    ]
                    [ span [ attribute "aria-hidden" "true" ] []
                    , span [ attribute "aria-hidden" "true" ] []
                    , span [ attribute "aria-hidden" "true" ] []
                    ]
                ]
            , div [ id "navMenu", class "navbar-menu" ]
                [ div [ class "navbar-start" ]
                    [ --a [ class "navbar-item", href (toHref Route.Top) ] [ text "Help" ]
                      a [ class "navbar-item", href (toHref Route.Explore) ] [ text "Explore" ]
                    ]
                , div [ class "navbar-end" ]
                    [ userButton user ]
                ]
            ]
        ]


userButton : UserState -> Html msg
userButton user =
    case user of
        LoggedIn uctx ->
            div [ class "navbar-item has-dropdown" ]
                [ div [ class "navbar-link" ] [ text uctx.username ]
                , div [ class "navbar-dropdown is-right" ]
                    [ a [ class "navbar-item", href (toHref <| Route.User_Dynamic { param1 = uctx.username }) ]
                        [ Fa.icon "fas fa-user" "Profile" ]
                    , a [ class "navbar-item", href "#" ]
                        [ Fa.icon "fas fa-cog" "Settings" ]

                    --, hr [ class "navbar-divider" ] []
                    --, a [ id "themeButton_port", class "navbar-item", href "#" ] [ i [ class "fas fa-adjust fa-fw" ] [], text "\u{00A0} Toggle dark theme" ]
                    , hr [ class "navbar-divider" ] []
                    , a [ class "navbar-item", href "/logout" ]
                        --[ Fa.icon "fas fa-sign-out-alt" "Sign Out" ]
                        [ text "Sign Out" ]
                    ]
                ]

        LoggedOut ->
            div [ class "navbar-item" ]
                [ a [ class "button is-small is-primary has-text-weight-bold", href (toHref Route.Login) ]
                    [ text "Login" ]
                ]
