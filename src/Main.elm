module Main exposing (main)

import Browser
import Html


type alias Flags =
    {}


type alias Model =
    {}


type Msg
    = NoOp


view : Model -> Browser.Document Msg
view _ =
    { title = "tfl-journeys"
    , body = [ Html.text "Hello, world!" ]
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update _ model =
    ( model, Cmd.none )


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( {}, Cmd.none )



-- main


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
