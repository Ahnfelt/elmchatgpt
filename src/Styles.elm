module Styles exposing (..)

import Html.Styled exposing (..)
import Css exposing (..)
import Html.Styled.Attributes exposing (css)
import Css.Transitions exposing (transition)
import Css.Transitions exposing (Transition)
import Html.Styled.Attributes exposing (placeholder)
import Svg
import Svg.Attributes

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
    , lineHeight (px (54 - 2 * 15))
    , backgroundColor (hex "#40414f")
    , color (hex "#f0f0f0")
    , boxShadow4 (px 0) (px 0) (px 15) (rgba 0 0 0 0.15)
    , property "appearance" "none"
    , property "border" "none"
    , boxSizing borderBox
    , paddingLeft (px 17) 
    , paddingRight (px 50)
    , transition [ Css.Transitions.height 100 ]
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

messageInputSmallCss : Attribute msg
messageInputSmallCss = css 
    [ paddingTop (px 15)
    , paddingBottom (px 15)
    , height (px 54)
    ]

messageInputBigCss : Attribute msg
messageInputBigCss = css 
    [ paddingTop (px 17)
    , paddingBottom (px 17)
    , height (px 150)
    ]

messageButtonCss : Attribute msg
messageButtonCss = css 
    [ backgroundColor (rgba 25 195 125 1.0)
    , opacity (num 1.0)
    , transition 
        [ Css.Transitions.backgroundColor 200 
        , Css.Transitions.opacity 200
        ]
    , cursor pointer
    , property "appearance" "none"
    , property "border" "none"
    , borderRadius (px 6)
    , boxSizing borderBox
    , padding4 (px 4) (px 4) (px 3) (px 5)
    , position absolute
    , bottom (px 61)
    , property "left" "calc(50% + min(100% - 80px, 750px)/2 - 43px)"
    , focus
        [ outline none
        ]
    , disabled
        [ backgroundColor transparent
        , opacity (num 0.3) 
        , cursor default 
        ]
    ]

userMessageContainerCss : Attribute msg
userMessageContainerCss = css
    [ displayFlex
    , justifyContent center
    , paddingTop (px 50)
    , paddingBottom (px 50)
    , fontSize (px 16)
    , fontFamilies [ "sans-serif" ]
    , color (rgb 209 213 219)
    ]

assistantMessageContainerCss : Attribute msg
assistantMessageContainerCss = css
    [ backgroundColor (hex "#444654")
    , displayFlex
    , justifyContent center
    , paddingTop (px 50)
    , paddingBottom (px 50)
    , fontSize (px 16)
    , fontFamilies [ "sans-serif" ]
    , color (rgb 209 213 219)
    ]

userMessageCss : Attribute msg
userMessageCss = css
    [ width (calc (pct 100) minus (px 80))
    , maxWidth (px 750)
    , whiteSpace preLine
    ]

assistantMessageCss : Attribute msg
assistantMessageCss = css
    [ width (calc (pct 100) minus (px 80))
    , maxWidth (px 750)
    , whiteSpace preLine
    ]

-- https://fonts.google.com/icons?selected=Material%20Symbols%20Outlined%3Asend%3AFILL%401%3Bwght%40400%3BGRAD%400%3Bopsz%4024
sendSvg : Html msg
sendSvg = fromUnstyled <| Svg.svg
    [ Svg.Attributes.height "24"
    , Svg.Attributes.width "24"
    , Svg.Attributes.viewBox "0 -960 960 960"
    ]
    [ Svg.path
        [ Svg.Attributes.d "M120-160v-240l320-80-320-80v-240l760 320-760 320Z"
        , Svg.Attributes.fill "#f0f0f0"
        ]
        []
    ]
