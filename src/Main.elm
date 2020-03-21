port module Main exposing (..)

import Html exposing (..)
import Browser
import Time
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)

port playNotification : Bool -> Cmd msg

-- MAIN


main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias Model =
  { secondsLeft: Int,
    totalMinutes: String,
    animationState: AnimationState
  }


init : () -> (Model, Cmd Msg)
init _ =
  ( { secondsLeft = 0, totalMinutes = "", animationState = Idle }
  , Cmd.none
  )



-- UPDATE


type Msg
  = Tick Time.Posix
  | SetMinutes Int
  | None

type AnimationState = Idle | Play | Done


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick _ ->
      case (model.secondsLeft, model.totalMinutes) of
       (0, "") -> ( model, Cmd.none )
       (0, _) -> ( { model | totalMinutes = "", animationState = Done }, playNotification True )
       _ -> ( { model | secondsLeft = model.secondsLeft - 1, animationState = Play }
        , Cmd.none
        )
    SetMinutes m -> ( {model | secondsLeft = 60 * m, totalMinutes = String.fromInt m }, Cmd.none)
    None -> (model, Cmd.none)


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Time.every 1000 Tick



-- VIEW


view : Model -> Html Msg
view model =
  let
    second = formatSeconds(modBy 60 model.secondsLeft)
    minutes = formatSeconds(modBy 60 (model.secondsLeft // 60))
  in
  div [ class "container" ] [
      div [ class "circle-container" ] [
        div [ class (classFromModel model) ] [
          h1 [] [ text (minutes ++ ":" ++ second) ]
        ]
      ],
      input [ placeholder "Minutes", onInput setMinutes, id "input" ] []
  ]

classFromModel : Model -> String
classFromModel model = case model.animationState of
       Idle -> "init"
       Done -> "done"
       Play -> "play"
        
formatSeconds : Int -> String
formatSeconds i = if i > 9 then String.fromInt i else "0" ++ String.fromInt i

setMinutes : String -> Msg
setMinutes s = case String.toInt s of 
                Just i -> SetMinutes i
                Nothing -> SetMinutes 0