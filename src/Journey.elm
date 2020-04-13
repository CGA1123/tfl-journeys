module Journey exposing (Journey, fetch, render)

import Html exposing (Html)
import Html.Attributes as Att
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline


type alias Journey =
    { date : String
    , startTime : String
    , endTime : String
    , from : String
    , to : String
    , cost : Float
    , notes : String
    , capped : Bool
    }


fetch : (Result Http.Error (List Journey) -> msg) -> Cmd msg
fetch msg =
    Http.get
        { url = "https://raw.githubusercontent.com/CGA1123/tfl-journeys/master/data/tube.json"
        , expect = Http.expectJson msg (Decode.list decoder)
        }


decoder : Decode.Decoder Journey
decoder =
    Decode.succeed Journey
        |> Pipeline.required "date" Decode.string
        |> Pipeline.required "start_time" Decode.string
        |> Pipeline.required "end_time" Decode.string
        |> Pipeline.required "from" Decode.string
        |> Pipeline.required "to" Decode.string
        |> Pipeline.required "cost" Decode.float
        |> Pipeline.required "notes" Decode.string
        |> Pipeline.required "capped" Decode.bool


render : Journey -> Html msg
render journey =
    Html.div
        [ Att.class "journey" ]
        [ Html.text journey.date
        , Html.text journey.startTime
        , Html.text journey.endTime
        , Html.text journey.from
        , Html.text journey.to
        ]
