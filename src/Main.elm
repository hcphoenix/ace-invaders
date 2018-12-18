import Browser
import Html exposing (Html, text)

import Game.TwoD as Game
import Game.TwoD.Camera as Camera
import Game.TwoD.Render as Render
import Color exposing (Color)

main : Program () Model Msg
main = Browser.element
    { init = always init
    , view = view
    , update = update
    , subscriptions = subs
    }

type alias Model =
    { time : Float
    }

init : (Model, Cmd Msg)
init = ({time = 0}, Cmd.none)

type Msg = NoOp

update : Msg -> Model -> (Model, Cmd Msg)
update msg model = (model, Cmd.none)

subs : Model -> Sub Msg
subs model = Sub.none

view : Model -> Html Msg
view model = Game.renderCentered
    { time = model.time
    , size = (800,600)
    , camera = Camera.fixedWidth 10 (800,600)
    }
    [ background
    ]

background = Render.shape
    Render.rectangle
        { color = Color.black
        , position = (0,0)
        , size = (800,600)
        }