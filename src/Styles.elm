module Styles exposing (..)

import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (css)

mainCss : Attribute msg
mainCss = css
    [ backgroundColor (hex "#343540")
    , width (vw 100)
    , minHeight (vh 100)
    , boxSizing borderBox
    , paddingBottom (px 150)
    ]

messageFormCss : Attribute msg
messageFormCss = css 
    [ backgroundImage <| linearGradient 
        (stop (rgba 52 53 64 0)) 
        (stop2 (rgba 52 53 64 255) (pct 50)) []
    , displayFlex
    , justifyContent center
    , paddingTop (px 50)
    , paddingBottom (px 50)
    , position fixed
    , left (px 0)
    , right (px 0)
    , bottom (px 0)
    ]

messageInputCss : Attribute msg
messageInputCss = css 
    [ color (rgb 255 0 0)
    , fontWeight bold
    ]

userMessageContainerCss : Attribute msg
userMessageContainerCss = css
    [ displayFlex
    , paddingTop (px 50)
    , paddingBottom (px 50)
    ]

assistantMessageContainerCss : Attribute msg
assistantMessageContainerCss = css
    [ backgroundColor (hex "#444654")
    , displayFlex
    , paddingTop (px 50)
    , paddingBottom (px 50)
    ]


