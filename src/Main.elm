-- A simple Pomodoro timer written in Elm


module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Time exposing (..)


---- MODEL ----


type alias Model =
    { running : Bool
    , elapsed : Int
    }


init : ( Model, Cmd Msg )
init =
    ( { running = False, elapsed = 0 }, Cmd.none )


pomodoroDuration =
    -- 25 * 60
    10



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

                newRunning =
                    (newElapsed < pomodoroDuration)
            in
                ( { model | elapsed = model.elapsed + 1, running = newRunning }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ renderTimer model
        , playSound model
        , div []
            [ button [ onClick StartTimer, disabled (model.running) ] [ text "Start" ]
            , button [ onClick StopTimer, disabled (not model.running) ] [ text "Stop" ]
            ]
        ]


playSound : Model -> Html Msg
playSound model =
    if (model.elapsed >= pomodoroDuration) then
        audio [ src "%PUBLIC_URL%/alert.wav", autoplay True, type_ "audio/wav" ] []
    else
        text ""


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
