import Browser
import Html exposing (Html, text)

import Game.TwoD as Game
import Game.TwoD.Camera as Camera
import Game.TwoD.Render as Render
import Color exposing (Color)
import Game.Resources as Resources exposing (Resources)

import WebGL exposing (Shader)
import WebGL.Texture exposing (Texture)
import Game.TwoD.Shapes exposing (Vertex, unitSquare)
import Game.TwoD.Shaders as Shaders
import Math.Matrix4 as M4 exposing (Mat4)
import Math.Vector2 as V2 exposing (Vec2)
import Math.Vector3 as V3 exposing (Vec3, vec3)
import Math.Vector4 exposing (Vec4, vec4)

main : Program () Model Msg
main = Browser.element
    { init = always init
    , view = view
    , update = update
    , subscriptions = subs
    }

type alias Model =
    { time : Float
    , resources : Resources
    }

init : (Model, Cmd Msg)
init = ({time = 0, resources = Resources.init}, Cmd.none)

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
    [ background model
    ]

background model = Render.veryCustom
        (\{ camera, screenSize, time } ->
            case Resources.getTexture "ass/test.png" model.resources of
                Nothing -> Debug.todo "Couldn't find it :("
                Just texture ->
                    WebGL.entity vertCurvedBG
                    fragTexturedOffset
                    unitSquare
                    { cameraProj = Camera.view camera screenSize 
                    , transform = Shaders.makeTransform ( 0, 0, 0 ) 0 ( 1, 1 ) ( 0, 0 )
                    , u_bgTexture =  texture
                    }
        )

vertCurvedBG : Shader Vertex { u | transform : Mat4, cameraProj : Mat4 } { vcoord : Vec2  }
vertCurvedBG =
    [glsl|
attribute vec2 position;
uniform mat4 transform;
uniform mat4 cameraProj;
varying vec2 vcoord;
void main () {
    vec4 pos = cameraProj*transform*vec4(position, 0, 1);
    gl_Position = pos;
    vcoord = position.xy;
}
|]

fragTexturedOffset : Shader {} { u | u_bgTexture : Texture } { vcoord : Vec2 }
fragTexturedOffset =
    [glsl|
precision mediump float;
uniform sampler2D u_bgTexture;
varying vec2 vcoord;
void main () {
    gl_FragColor = texture2D(u_bgTexture, vcoord);
}
|]

        {-Render.shape
    Render.rectangle
        { color = Color.black
        , position = (0,0)
        , size = (800,600)
        }   


        -}