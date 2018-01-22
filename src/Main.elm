-- A simple Pomodoro timer written in Elm


port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time exposing (..)


--- PORTS ---
{- Load a sample by giving it a name and the URL of the audio file (for example .wav or .mp3) to decode. -}


port loadSample : ( String, String ) -> Cmd msg



{- Play a given sample at given point in time in the future -}


port playSample : ( String, Float ) -> Cmd msg


loadInstrument : Cmd msg
loadInstrument =
    loadSample ( "samples/" ++ "alert.wav", "alert" )



---- MODEL ----


type alias Model =
    { running : Bool
    , elapsed : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { running = False, elapsed = 0 }, loadInstrument )


pomodoroDuration =
    25 * 60



---- UPDATE ----


type Msg
    = StartTimer
    | StopTimer
    | Tick Time


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        StartTimer ->
            ( { model | running = True, elapsed = 0 }, Cmd.none )

        StopTimer ->
            ( { model | running = False }, Cmd.none )

        Tick time ->
            let
                newElapsed =
                    model.elapsed + 1

                timeIsUp =
                    (newElapsed >= pomodoroDuration)

                action =
                    if (timeIsUp) then
                        playSample ( "alert", 0 )
                    else
                        Cmd.none
            in
                ( { model | elapsed = model.elapsed + 1, running = not timeIsUp }, action )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ renderTimer model
        , div []
            [ button [ onClick StartTimer, disabled (model.running) ] [ text "Start" ]
            , button [ onClick StopTimer, disabled (not model.running) ] [ text "Stop" ]
            ]
        ]


renderTimer : Model -> Html Msg
renderTimer model =
    let
        left =
            pomodoroDuration - model.elapsed

        nbMinutes =
            left // 60

        nbSeconds =
            left - (nbMinutes * 60)

        paddedNbMinutes =
            String.pad 2 '0' (toString nbMinutes)

        paddedNbSeconds =
            String.pad 2 '0' (toString nbSeconds)
    in
        h1 [] [ text (paddedNbMinutes ++ ":" ++ paddedNbSeconds) ]


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.running of
        False ->
            Sub.none

        True ->
            Time.every second Tick



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
