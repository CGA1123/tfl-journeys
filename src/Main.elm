module Main exposing (main)

import Browser
import Html exposing (Html)
import Http
import Journey exposing (Journey)


type alias Flags =
    {}


type alias Model =
    { journeys : List Journey }


type Msg
    = ReceivedJourneys (Result Http.Error (List Journey))


view : Model -> Browser.Document Msg
view model =
    { title = "tfl-journeys"
    , body = body model
    }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ReceivedJourneys result ->
            handleJourneyResponse result model


body : Model -> List (Html Msg)
body model =
    List.map Journey.render model.journeys


init : Flags -> ( Model, Cmd Msg )
init _ =
    ( { journeys = [] }, Journey.fetch ReceivedJourneys )


handleJourneyResponse result model =
    case result of
        Ok journeys ->
            ( { journeys = journeys }, Cmd.none )

        Err err ->
            let
                _ =
                    Debug.log "error: " err
            in
            ( model, Cmd.none )



-- main


main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
