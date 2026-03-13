module Main exposing (main)

import Platform
import Process
import Task


type alias Flags =
    { debug : String }


main : Program Flags () ()
main =
    Platform.worker
        { init =
            \flags ->
                let
                    _ =
                        if flags.debug == "1" then
                            Debug.log "test ... ok" ""

                        else
                            Debug.log "Hello World" ""
                in
                ( (), Task.perform (\_ -> ()) (Process.sleep 0) )
        , update = \_ model -> ( model, Cmd.none )
        , subscriptions = \_ -> Sub.none
        }
