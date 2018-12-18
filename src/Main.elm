import Util exposing (..)

import Browser
import Browser.Events as Events
import Browser.Dom as Dom
import Html exposing (Html, text)
import Html.Attributes as Attribute exposing (style)
import Task

import Game.TwoD as Game
import Game.TwoD.Camera as Camera
import Game.TwoD.Render as Render exposing (Renderable)
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
    , size : (Int,Int)
    }

init : (Model, Cmd Msg)
init =
    (   { time = 0
        , size = (800,600)
        }
    ,   Task.perform (\vp -> Resize (round vp.scene.width) (round vp.scene.height)) Dom.getViewport
    )

type Msg =
    Resize Int Int

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Resize w h -> noCmd {model|size = (w,h)}

subs : Model -> Sub Msg
subs model = Sub.batch
    [ Events.onResize Resize
    ]

view : Model -> Html Msg
view model = Game.renderWithOptions
    --attributes
    [ style "background-color" "black"
    , style "position" "fixed"
    , style "top" "0"
    , style "left" "0"
    ]
    --render options
    { time = model.time
    , size = model.size
    , camera = Camera.fixedWidth 10 <| both toFloat model.size
    }
    --List Renderable
    [ --background <| both toFloat model.size
    ]
    
{-
background : (Float, Float) -> Renderable
background size = Render.shape Render.rectangle
    { color = Color.black
    , position = (0,0)
    , size = size
    }
-}