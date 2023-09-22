module Main exposing (main)

import Browser
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Url
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (placeholder, value, href)
import Html.Styled.Events exposing (..)
import Html.Styled.Attributes exposing (autofocus)
import Styles
import Json.Decode as Json exposing (Decoder)
import Html.Styled.Attributes exposing (style)
import Html.Styled.Attributes exposing (type_)
import Html.Styled.Attributes exposing (disabled)
import Http
import Json.Decode exposing (Error(..))
import Task
-- You must create this file yourself and fill in your own secrets. It's in .gitignore
import Secrets
import Json.Encode as E

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
    | Submitted Bool
    | Answered String (Result Http.Error String)
    | UrlRequested Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
    
        MessageChanged message ->
            ( { model | message = message }, Cmd.none )
            
        Submitted False ->
            ( model, Cmd.none )

        Submitted True ->
            let scroll = Dom.getViewport 
                    |> Task.andThen (\viewport -> Dom.setViewport 0 viewport.scene.height) 
                    |> Task.perform (\_ -> Submitted False)
                message role content = 
                    E.object  [ ("role", E.string role), ("content", E.string content) ]
                messages = 
                        message "system" "You are a helpful assistant."
                        :: List.concatMap
                            (\entry ->
                                message "user" entry.question ::
                                case entry.answer of
                                    Just answer -> [ message "assistant" answer ]
                                    Nothing -> []
                            ) 
                            chat
                body = E.object 
                    [ ("model", E.string "gpt-3.5-turbo")
                    , ("messages", E.list (\x -> x) messages)
                    ]
                fetch = Http.request
                    { method = "POST" 
                    , headers = [ Http.header "Authorization" ("Bearer " ++ Secrets.key)] 
                    , url = "https://api.openai.com/v1/chat/completions" 
                    , body = Http.jsonBody body
                    , expect = Http.expectJson (Answered model.message) answerDecoder
                    , timeout = Nothing
                    , tracker = Nothing                    
                    }
                chat = ChatEntry model.message Nothing :: model.chat
            in 
            ( { model | message = "", chat = chat }
            , Cmd.batch [ scroll, fetch ] 
            )

        Answered question answer ->
            let answerText = case answer of
                    Ok text -> text
                    Err _ -> "Error."
                applyAnswer entry = 
                    if entry.question == question && entry.answer == Nothing
                    then {entry | answer = Just answerText}
                    else entry
            in
            ( { model | chat = List.map applyAnswer model.chat }
            , Cmd.none 
            )

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

answerDecoder : Decoder String
answerDecoder =
    Json.field "choices" (Json.index 0 (Json.field "message" (Json.field "content" Json.string)))

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


view : Model -> Browser.Document Msg
view model =
    { title = "Elm ChatGPT client"
    , body = List.map toUnstyled
        [ main_ [ Styles.mainCss ] 
            [ div [] (List.reverse model.chat |> List.map renderChatEntry)
            , renderMessageForm model
            ]
        ]
    }

renderMessageForm : Model -> Html Msg
renderMessageForm model = form
    [ Styles.messageFormCss, onSubmit (Submitted True) ] 
    [ textarea 
        [ autofocus True
        , placeholder "Send a message"
        , if String.contains "\n" model.message 
            then Styles.messageInputBigCss
            else Styles.messageInputSmallCss
        , Styles.messageInputCss
        , value model.message
        , onInput MessageChanged
        , preventDefaultOn "keydown" (decodeKeyPress model.message)
        ]
        []
    , button
        [ type_ "submit"
        , Styles.messageButtonCss
        , disabled (String.trim model.message == "")
        ]
        [ Styles.sendSvg
        ]
    ]

decodeKeyPress : String -> Decoder (Msg, Bool)
decodeKeyPress message =
    Json.field "keyCode" Json.int |> Json.andThen (\keyCode ->
        Json.field "altKey" Json.bool |> Json.andThen (\altKey ->
            Json.field "ctrlKey" Json.bool |> Json.andThen (\ctrlKey ->
                Json.field "shiftKey" Json.bool |> Json.andThen (\shiftKey ->
                    let plainReturn = keyCode == 13 && not ctrlKey && not altKey && not shiftKey
                        submit = plainReturn && String.trim message /= ""
                    in Json.succeed (Submitted submit, plainReturn)
                )
            )
        )
    )


renderChatEntry : ChatEntry -> Html Msg
renderChatEntry entry = 
    let answerHtml = case entry.answer of
            Nothing -> text "Assistant is typing..."
            Just answer -> text ("Assistant: " ++ answer)
    in div [] 
        [ div [ Styles.userMessageContainerCss ] 
            [ div [ Styles.userMessageCss ] [ text ("User: " ++ entry.question) ]
            ]
        , div [ Styles.assistantMessageContainerCss ] 
            [ div [ Styles.assistantMessageCss ] [ answerHtml ]
            ]
        ]
