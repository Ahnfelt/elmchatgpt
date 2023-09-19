module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Url
import Html.Attributes exposing (placeholder)
import Html.Attributes exposing (value)
import Html.Events exposing (onInput)
import Html.Events exposing (onSubmit)

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
    = Msg1
    | Msg2
    | MessageChanged String
    | Submitted
    | UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg1 ->
            ( model, Cmd.none )

        Msg2 ->
            ( model, Cmd.none )

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
    { title = "Application Title"
    , body =
        [ div []
            [ text "Chat" ]
        , form [onSubmit Submitted] 
            [ input 
                [ placeholder "Just ask"
                , value model.message
                , onInput MessageChanged
                ]
                []
            ]
        ]
    }
