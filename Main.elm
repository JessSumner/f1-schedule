module Schedule exposing (..)

import Html exposing (..)
import Http
import Json.Decode as JD exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.Attributes exposing (placeholder)
import Date exposing (..)
import Task exposing (perform)

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = always Sub.none
        }

type alias Model =
    { schedule : List Race
    , year : String
    , test : List String
    , currentDate : Maybe Date
    }

type alias Race =
    { name : String
    , date : String
    }


type Msg
    = GetF1Schedule
    | GotF1Schedule ( Result Http.Error (List Race ))
    | ChangeYear String
    | GetCurrentDate Date
    | NoOp

init : ( Model, Cmd Msg )
init =
    ({ schedule = []
    , year = "2018"
    , test = ["Race 1", "Race 2", "Race 3", "Race 4"] 
    , currentDate = Nothing}
    , getCurrentDate )


getCurrentDate : Cmd Msg
getCurrentDate =
    Task.perform GetCurrentDate Date.now


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        GetF1Schedule ->
            ( model, Http.send GotF1Schedule ( getF1Schedule model.year ) )

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

        ChangeYear newYear ->
                    ({ model | year = newYear }, Cmd.none)

        GetCurrentDate date -> ({ model | currentDate = Just date }, Cmd.none)

api : String
api =
    "http://ergast.com/api/f1/2017.json"


composeApiString : String -> String
composeApiString year =
    "http://ergast.com/api/f1/" ++ year ++ ".json"


getF1Schedule : String -> Http.Request (List Race)
getF1Schedule year =
    Http.get (composeApiString year) decodeResult
    -- Http.get api decodeResult


decodeResult : Decoder (List Race)
decodeResult =
    at ["MRData", "RaceTable", "Races"] decodeListOfRaces

decodeListOfRaces : Decoder (List Race )
decodeListOfRaces =
    list decodeOneRace

nameToRace : String -> String -> Race
nameToRace name date =
  { name = name
  , date = date
  }

decodeOneRace : Decoder Race
decodeOneRace =
  JD.map2 nameToRace decodeOneRaceName decodeOneRaceDate

decodeOneRaceName : Decoder String
decodeOneRaceName =
    at ["raceName"] string

decodeOneRaceDate : Decoder String
decodeOneRaceDate =
    at ["date"] string

convertRaceDate : String -> Result String Date
convertRaceDate dateString = 
    let
       rDate = fromString dateString
    in case rDate of
            Err s -> Debug.log ( "Error converting the date from a string " ++ s) rDate

            _ -> rDate

generateList : List Race -> List (Html Msg)
generateList races =
    List.map generateLi races


generateLi : Race -> Html a
generateLi race =
    li [] [text (race.name ++ " " ++ race.date)]



view : Model -> Html.Html Msg
view model =
    div
      []
      [
        div
          []
          [ text <| "Today's date is: " ++ ( toString model.currentDate) ]
       , label
          []
          [ text "Year to retrieve:"
          , input
              [placeholder "YYYY", onInput ChangeYear ]
              []
          ]
       , button
          [ onClick <| GetF1Schedule ]
          [text "Get Schedule"]
        ,ul 
          []
          (generateList model.schedule)
      ]

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
