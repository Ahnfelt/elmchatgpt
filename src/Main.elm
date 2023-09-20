module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Url
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (placeholder, value, href)
import Html.Styled.Events exposing (..)
import Html.Styled.Attributes exposing (autofocus)
import Styles

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

type alias ChatEntry = 
    { question : String
    , answer : Maybe String
    }

type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , property : String
    , chat : List ChatEntry
    , message : String
    }

init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model key url "modelInitialValue" [] "", Cmd.none )


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
            ( { model 
                | message = ""
                , chat = ChatEntry model.message Nothing :: model.chat
            }, Cmd.none )

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
        , div [] (List.reverse model.chat |> List.map renderChatEntry)
        , form [onSubmit Submitted] 
            [ input 
                [ placeholder "Just ask"
                , autofocus True
                , Styles.messageInputCss
                , value model.message
                , onInput MessageChanged
                ]
                []
            ]
        ]
    }

renderChatEntry : ChatEntry -> Html Msg
renderChatEntry entry = 
    let answerHtml = case entry.answer of
            Nothing -> [ text "Assistant is typing..." ]
            Just answer -> [ text ("Assistant: " ++ answer) ]
    in div [] 
        [ div [] [ text ("User: " ++ entry.question) ]
        , div [] answerHtml
        ]
