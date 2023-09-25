module Main exposing (main)

import Browser
import Browser.Dom as Dom
import Browser.Navigation as Nav
import Url
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (placeholder, value, href, autofocus, src, style, type_, disabled)
import Html.Styled.Events exposing (..)
import Styles
import Json.Decode as Json exposing (Decoder)
import Http
import Json.Decode exposing (Error(..))
import Task
-- You must create the Secrets.elm yourself and fill in your own secrets. It's in .gitignore.
import Secrets
import Json.Encode as E
import Markdown.Parser as Markdown
import Markdown.Renderer

type alias Flags = () 

main : Program Flags Model Msg
main =
    Browser.document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

type alias ChatEntry = 
    { question : String
    , answer : Maybe String
    }

type alias Model =
    { property : String
    , chat : List ChatEntry
    , message : String
    }

init : Flags -> ( Model, Cmd Msg )
init flags =
    ( Model "modelInitialValue" [] "", Cmd.none )


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
            let scroll = Dom.getViewport 
                    |> Task.andThen (\viewport -> Dom.setViewport 0 viewport.scene.height) 
                    |> Task.perform (\_ -> Submitted False)
                message role content = 
                    E.object  [ ("role", E.string role), ("content", E.string content) ]
                messages = 
                        message "system" "You are a helpful assistant."
                        :: List.concatMap
                            (\entry ->
                                (case entry.answer of
                                    Just answer -> [ message "assistant" answer ]
                                    Nothing -> []
                                )
                                ++ [message "user" entry.question]
                            ) 
                            (List.reverse chat)
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
