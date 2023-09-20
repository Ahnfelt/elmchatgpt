module Styles exposing (..)

import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (css)

messageInputCss : Attribute msg
messageInputCss = css 
    [ color (rgb 255 0 0)
    , fontWeight bold
    ]
