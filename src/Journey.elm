module Journey exposing (Journey, fetch, render)

import Dict
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Pipeline
import Round


type alias Journey =
    { date : String
    , startTime : Time
    , endTime : Time
    , from : String
    , to : String
    , cost : Float
    , notes : String
    , capped : Bool
    }


type alias Time =
    { hour : Int
    , minute : Int
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
        |> Pipeline.required "start_time" timeDecoder
        |> Pipeline.required "end_time" timeDecoder
        |> Pipeline.required "from" Decode.string
        |> Pipeline.required "to" Decode.string
        |> Pipeline.required "cost" Decode.float
        |> Pipeline.required "notes" Decode.string
        |> Pipeline.required "capped" Decode.bool


timeDecoder : Decode.Decoder Time
timeDecoder =
    let
        timeDecode string =
            case String.split ":" string of
                hour :: minute :: [] ->
                    Decode.succeed
                        { hour = hour |> String.toInt |> Maybe.withDefault 0
                        , minute = minute |> String.toInt |> Maybe.withDefault 0
                        }

                _ ->
                    Decode.fail string
    in
    Decode.string |> Decode.andThen timeDecode


render : List Journey -> Html msg
render journeys =
    statBuilders
        |> List.map (\x -> x journeys)
        |> List.map renderTile
        |> div [ class "row" ]


renderTile : { title : String, value : String } -> Html msg
renderTile { title, value } =
    div
        [ class "card small col s6 cyan" ]
        [ h1 [ class "white-text center-align flow-text" ] [ text value ]
        , h5 [ class "white-text center-align" ] [ text title ]
        ]


statBuilders : List (List Journey -> { title : String, value : String })
statBuilders =
    [ totalJourneys
    , totalCost
    , totalMinutes
    , averageTripMinutes
    , costPerMinute
    , averageTripCost
    , mostPopularDestination
    , mostPopularJourney
    ]


totalJourneys journeys =
    { title = "Journeys"
    , value = List.length journeys |> String.fromInt
    }


totalCost journeys =
    { title = "Total Cost"
    , value = calcTotalCost journeys |> Round.round 2 |> (++) "£"
    }


totalMinutes journeys =
    { title = "Minutes Travelled"
    , value = calcTotalMinutes journeys |> String.fromInt
    }


costPerMinute journeys =
    { title = "Cost per Minute"
    , value = "£12.45"
    }


averageTripMinutes journeys =
    { title = "Avg. Journey Time (minutes)"
    , value = calcTotalMinutes journeys // List.length journeys |> String.fromInt
    }


averageTripCost journeys =
    { title = "Avg. Journey Cost"
    , value = calcTotalCost journeys / toFloat (List.length journeys) |> Round.round 2 |> (++) "£"
    }


mostPopularDestination journeys =
    let
        calc j =
            j
                |> List.concatMap (\x -> [ x.to, x.from ])
                |> tally identity
                |> List.sortBy Tuple.second
                |> List.reverse
                |> List.head
                |> Maybe.map Tuple.first
                |> Maybe.withDefault "No Station"
    in
    { title = "Most Visited Station"
    , value = calc journeys
    }


mostPopularJourney journeys =
    let
        sortedJourney journey =
            [ journey.to, journey.from ]
                |> List.sortBy identity
                |> String.join " <> "

        calc j =
            j
                |> List.map sortedJourney
                |> tally identity
                |> List.sortBy Tuple.second
                |> List.reverse
                |> List.head
                |> Maybe.map Tuple.first
                |> Maybe.withDefault "No Station"
    in
    { title = "Most Popular Route"
    , value = calc journeys
    }


calcTotalCost journeys =
    journeys
        |> List.map .cost
        |> List.foldl (+) 0.0
        |> abs


calcTotalMinutes journeys =
    journeys
        |> List.map journeyTimeMinutes
        |> List.foldl (+) 0


journeyTimeMinutes { startTime, endTime } =
    let
        startMinutes =
            (startTime.hour * 60) + startTime.minute

        endMinutes =
            (endTime.hour * 60) + endTime.minute
    in
    endMinutes - startMinutes


tally accessor list =
    let
        counter current dict =
            Dict.update
                (accessor current)
                (Maybe.withDefault 0 >> (+) 1 >> Just)
                dict
    in
    list
        |> List.foldl counter Dict.empty
        |> Dict.toList
