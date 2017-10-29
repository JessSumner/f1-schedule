module Schedule exposing (..)

import Html exposing (text)

main =
  text "Here is your schedule"

type alias Model =
    { raceName : String
    }

decodeRaceName : Decoder String
decodeRaceName =
    at [ "RaceTable", "Races", "raceName" ] string
{-
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
-}
