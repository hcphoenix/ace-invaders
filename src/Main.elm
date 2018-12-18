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
    , size : (Int,Int)
    }

init : (Model, Cmd Msg)
init =
    (   { time = 0
        , resources = Resources.init
        , size = (800,600)
        }
        , Cmd.batch 
            [ Cmd.map Resources (Resources.loadTextures [ "ass/test.png" ])
            , Task.perform (\vp -> Resize (round vp.scene.width) (round vp.scene.height)) Dom.getViewport
            ]
    
    )

type Msg =
    Resize Int Int
    | Resources Resources.Msg

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        Resize w h -> noCmd {model|size = (w,h)}
        
        Resources rMsg ->
            ( { model | resources = Resources.update rMsg model.resources }
            , Cmd.none )

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
    , camera = Camera.fixedHeight 100 <| both toFloat model.size
    }
    [ 
        blankBackground <| both toFloat model.size
        , background model
    ]

background model = 
 case Resources.getTexture "ass/test.png" model.resources of
    Nothing ->
        Render.shapeZ Render.rectangle { position = (10,10,1), size = ( 1000, 1000), color = Color.blue }
    Just texture -> 
        Render.veryCustom (\{ time, screenSize, camera } ->
            WebGL.entity vertCurvedBG
            fragTexturedOffset
            unitSquare
            { transform = Shaders.makeTransform ( -0.5, -0.5, -1 ) 0 (1, 1) ( 0.1, 0.1 )   --both toFloat model.size
            , cameraProj = M4.mul (M4.makePerspective 45 1.777 0.01 100) (M4.makeLookAt (vec3 0 0 1) (vec3 0 0 -1)  (vec3 0 1 0) ) --Camera.view camera screenSize   
            , u_bgTexture =  texture
            }
        )
        
--vec4 pos = cameraProj*transform*vec4(position,0, 1);
--vec4 pos = cameraProj*transform*vec4(position.x,abs(position.y), abs(position.x) * abs(position.x),1);
vertCurvedBG : Shader Vertex { u | transform : Mat4, cameraProj : Mat4 } { vcoord : Vec2  }
vertCurvedBG =
    [glsl|
attribute vec2 position;
uniform mat4 transform;
uniform mat4 cameraProj;
varying vec2 vcoord;
void main () {
   
    vec4 pos = cameraProj*transform*vec4(position.x,abs(position.y), abs(position.x) * abs(position.x),1);
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


        
    --List Renderable
    [ --background <| both toFloat model.size
    ]
    -}

blankBackground : (Float, Float) -> Renderable
blankBackground size = Render.shape Render.rectangle
    { color = Color.black
    , position = (0,0)
    , size = size
    }
