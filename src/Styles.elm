module Styles exposing (..)

import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (css)
import Css.Transitions exposing (transition)
import Css.Transitions exposing (Transition)
import Html.Styled.Attributes exposing (placeholder)

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
    [ fontSize (px 16)
    , fontFamilies [ "sans-serif" ]
    , backgroundColor (hex "#40414f")
    , color (hex "#f0f0f0")
    , boxShadow4 (px 0) (px 0) (px 15) (rgba 0 0 0 0.15)
    , property "appearance" "none"
    , property "border" "none"
    , boxSizing borderBox
    , padding4 (px 17) (px 60) (px 17) (px 17)
    , transition [ Css.Transitions.height 100 ]
    , height (px 54)
    , borderRadius (px 12)
    , width (calc (pct 100) minus (px 80))
    , maxWidth (px 750)
    , resize none
    , Css.pseudoElement "placeholder" 
        [ color (hex "#8e8ea0")
        , opacity (num 1.0)
        ]
    , focus
        [ outline none
        , boxShadow4 (px 0) (px 0) (px 15) (rgba 0 0 0 0.25)
        ]
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


