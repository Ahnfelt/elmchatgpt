module Main exposing (main)

import Task
import Browser
import Browser.Dom as Dom
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (placeholder, value, autofocus, src, type_, disabled)
import Html.Styled.Events exposing (..)
import Http
import Json.Encode as E
import Json.Decode as Json exposing (Decoder)
import Json.Decode exposing (Error(..))
import Markdown.Parser as Markdown
import Markdown.Renderer

import Styles
import Secrets


type alias Flags = () 


main : Program Flags Model Msg
main = Browser.document
    { init = init
    , view = view
    , update = update
    , subscriptions = \model -> Sub.none
    }


type alias Model =
    { chat : List ChatEntry
    , message : String
    }


type alias ChatEntry = 
    { question : String
    , answer : Maybe String
    }


init : Flags -> ( Model, Cmd Msg )
init () =
    ( { chat = [], message = "" }, Cmd.none )


type Msg
    = MessageChanged String
    | Submitted Bool
    | Answered String (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
    
        MessageChanged message ->
            ( { model | message = message }, Cmd.none )
            
        Submitted False ->
            ( model, Cmd.none )

        Submitted True ->
            let chat = model.chat ++ [ ChatEntry model.message Nothing ] in 
            ( { model | message = "", chat = chat }
            , Cmd.batch [ scrollToBottom, fetchAnswer model.message chat ] 
            )

        Answered question answer ->
            let setAnswer entry = 
                    if entry.question == question && entry.answer == Nothing
                    then {entry | answer = Just (Result.withDefault "Error." answer)}
                    else entry
            in
            ( { model | chat = List.map setAnswer model.chat }
            , Cmd.none 
            )


scrollToBottom : Cmd Msg
scrollToBottom = Dom.getViewport 
    |> Task.andThen (\viewport -> Dom.setViewport 0 viewport.scene.height) 
    |> Task.perform (\_ -> Submitted False)


fetchAnswer : String -> List ChatEntry -> Cmd Msg
fetchAnswer message chat = 
    Http.request
        { method = "POST" 
        , headers = [ Http.header "Authorization" ("Bearer " ++ Secrets.key)] 
        , url = "https://api.openai.com/v1/chat/completions" 
        , body = Http.jsonBody (encodeChat chat)
        , expect = Http.expectJson (Answered message) answerDecoder
        , timeout = Nothing
        , tracker = Nothing                    
        }


encodeChat : List ChatEntry -> E.Value
encodeChat chat =
    let
        encodeMessage role content = 
            E.object  [ ("role", E.string role), ("content", E.string content) ]
        encodeEntry question maybeAnswer = case maybeAnswer of
            Nothing -> [ encodeMessage "user" question ]
            Just answer -> [ encodeMessage "user" question, encodeMessage "assistant" answer ]
        encodedMessages = encodeMessage "system" "You are a helpful assistant."
            :: List.concatMap (\entry -> encodeEntry entry.question entry.answer) chat
    in E.object 
        [ ("model", E.string "gpt-3.5-turbo")
        , ("messages", E.list (\x -> x) encodedMessages)
        ]


answerDecoder : Decoder String
answerDecoder =
    Json.field "choices" (Json.index 0 (Json.field "message" (Json.field "content" Json.string)))


view : Model -> Browser.Document Msg
view model =
    { title = "Elm ChatGPT client"
    , body = List.map toUnstyled
        [ main_ [ Styles.mainCss ] 
            [ div [] (List.map renderChatEntry model.chat)
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
    let answer = case entry.answer of
            Nothing -> "Typing..."
            Just answerText -> answerText
    in div [] 
        [ div [ Styles.userMessageCss ] 
            [ div [ Styles.avatarCss ] 
                [ img 
                    [ src "https://avatars.githubusercontent.com/u/20698192?s=200&v=4" 
                    , Styles.avatarImageCss
                    ] 
                    []
                ]
            , div [ Styles.messageCss ] [ renderMarkdown entry.question ]
            ]
        , div [ Styles.assistantMessageCss ] 
            [ div [ Styles.avatarCss ]
                [ img 
                    [ src "https://chat.openai.com/apple-touch-icon.png" 
                    , Styles.avatarImageCss
                    ] 
                    []
                ]
            , div [ Styles.messageCss ] [ renderMarkdown answer ]
            ]
        ]


renderMarkdown : String -> Html Msg
renderMarkdown markdown =
    let result = Markdown.parse markdown
            |> Result.mapError (List.map Markdown.deadEndToString >> String.join "\n")
            |> Result.andThen (\ast -> Markdown.Renderer.render Markdown.Renderer.defaultHtmlRenderer ast)
    in case result of
        Ok rendered -> div [] (List.map fromUnstyled rendered)
        Err _ -> text markdown
