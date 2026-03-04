module Main exposing (main)
import Browser
import Html exposing (Html, h1, text)
main : Program () () ()
main =
    Browser.element
        { init = \_ -> ( (), Cmd.none )
        , view = \_ -> h1 [] [ text "Hello Elm!" ]
        , update = \_ _ -> ( (), Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
