module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Css exposing (..)
import Url
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (placeholder, value, css, href, src)
import Html.Styled.Events exposing (onClick, onInput, onSubmit)
import Html.Styled.Attributes exposing (autofocus)

type alias Flags = ()

main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = UrlRequested
        , onUrlChange = UrlChanged
        }


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , property : String
    , message : String
    }


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model key url "modelInitialValue" "", Cmd.none )


type Msg
    = MessageChanged String
    | Submitted
    | UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
    
        MessageChanged message ->
            ( { model | message = message }, Cmd.none )

        Submitted ->
            ( { model | message = "" }, Cmd.none )

        UrlRequested urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Browser.Document Msg
view model =
    { title = "Elm ChatGPT client"
    , body = List.map toUnstyled
        [ div []
            [ text "Chat" ]
        , form [onSubmit Submitted] 
            [ input 
                [ placeholder "Just ask"
                , autofocus True
                , value model.message
                , onInput MessageChanged
                , css 
                    [ color (rgb 255 0 0)
                    ]
                ]
                []
            ]
        ]
    }
