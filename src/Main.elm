module Main exposing (main)

import Browser
import Browser.Navigation exposing (Key)
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Journey exposing (Journey)
import Url exposing (Url)


type alias Flags =
    {}


type alias Model =
    { journeys : List Journey }


type Msg
    = ReceivedJourneys (Result Http.Error (List Journey))
    | NoOp


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

        _ ->
            ( model, Cmd.none )


body : Model -> List (Html Msg)
body model =
    [ div [ class "container" ]
        [ Journey.render model.journeys ]
    ]


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init _ _ _ =
    ( { journeys = [] }, Journey.fetch ReceivedJourneys )


handleJourneyResponse result model =
    case result of
        Ok journeys ->
            ( { journeys = journeys }, Cmd.none )

        Err _ ->
            ( model, Cmd.none )


onUrlRequest : Browser.UrlRequest -> Msg
onUrlRequest _ =
    NoOp


onUrlChange : Url -> Msg
onUrlChange _ =
    NoOp



-- main


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = always Sub.none
        , onUrlRequest = onUrlRequest
        , onUrlChange = onUrlChange
        }
