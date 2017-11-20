module Schedule exposing (..)

import Html exposing (text)
import Http
import Json.Decode exposing (..)

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }
type alias Model =
    { schedule : String
    }


type Msg
    = GetF1Schedule
    | GotF1Schedule ( Result Http.Error String )
    | NoOp

init : ( Model, Cmd Msg )
init =
    update GetF1Schedule { schedule = "none" }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GetF1Schedule ->
            ( model, Http.send GotF1Schedule getF1Schedule )

        GotF1Schedule result ->
            case result of
                Err httpError ->
                    let
                        _ =
                            Debug.log "http error getting the schedule" httpError
                    in
                        ( model, Cmd.none )

                Ok schedule ->
                    ( { model | schedule = schedule }, Cmd.none)

api : String
api = 
    "http://ergast.com/api/f1/2017.json"

getF1Schedule : Http.Request String
getF1Schedule =
    Http.get api decodeResult


decodeResult : Decoder String
decodeResult =
    at [ "RaceTable", "Races", "raceName" ] string


view : Model -> Html.Html Msg
view model =
    Html.text "Here is your schedule"

{--
Example of the json data
{
"MRData": {
    "xmlns": "http:\/\/ergast.com\/mrd\/1.0",
    "series": "f1",
    "limit": "30",
    "offset": "0",
    "total": "18",
    "RaceTable": {
      "season": "2008",
      "Races": [
        {
          "season": "2008",
          "round": "1",
          "url": "http:\/\/en.wikipedia.org\/wiki\/2008_Australian_Grand_Prix",
          "raceName": "Australian Grand Prix",
          "Circuit": {
            "circuitId": "albert_park",
            "url":
"http:\/\/en.wikipedia.org\/wiki\/Melbourne_Grand_Prix_Circuit",
            "circuitName": "Albert Park Grand Prix Circuit",
            "Location": {
              "lat": "-37.8497",
              "long": "144.968",
              "locality": "Melbourne",
              "country": "Australia"
            }
          },
          "date": "2008-03-16",
          "time": "04:30:00Z"
        },
        .
        .
        .
      ]
    }
  }
}
--}
