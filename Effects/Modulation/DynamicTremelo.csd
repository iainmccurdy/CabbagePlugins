/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; Tremelo
; Iain McCurdy 2026

<Cabbage>
form caption("Tremelo") size(550,620), guiMode("queue") pluginId("Trml"), colour(50,50,60)

#define SLIDER_STYLE colour(200,200,210), textColour("white"), trackerColour(210,210,230), valueTextBox(1)
label    bounds(  5, 33, 70, 15), text("Input"), fontColour("white")
combobox bounds(  5, 50, 70, 20), channel("InChns"), items("mono","stereo","test"), value(1)
rslider  bounds( 80, 10,100,100), channel("InGain"), range(0,1,0.5), text("In Gain"), $SLIDER_STYLE
rslider  bounds(155, 10,100,100), channel("ModFreq"), range(0,100, 3, 0.25), text("Rate"), $SLIDER_STYLE
rslider  bounds(230, 10,100,100), channel("ModDep"), range(0, 1, 1), text("Depth"), $SLIDER_STYLE
rslider  bounds(305, 10,100,100), channel("Skew"), range(-1, 1, 0), text("Skew"), $SLIDER_STYLE
rslider  bounds(380, 10,100,100), channel("Clip"), range(0, 1, 0), text("Clip"), $SLIDER_STYLE
rslider  bounds(455, 10,100,100), channel("OutGain"), range(0,1,0.5), text("Out Gain"), $SLIDER_STYLE

xypad   bounds(  0,120,550,500), channel("X","Y"), rangeX(0,1,0.5), rangeY(0,1,0.5), text("X - Modulation Rate | Y - Modulation Depth")
</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-n -d
</CsOptions>

<CsInstruments>
; Initialize the global variables. 
ksmps              =                   32
nchnls             =                   2
0dbfs              =                   1

instr 1

kInput             cabbageGetValue     "InChns"
if kInput==1 then
 a1                inch                1
 a2                =                   a1
elseif kInput==2 then
 a1,a2             ins
else
 a1               poscil              0.1, 440
 a2               =                   a1
endif

kInGain            cabbageGetValue     "InGain"
a1                *=                   kInGain
a2                *=                   kInGain

kX,kT              cabbageGetValue     "X"
                   cabbageSetValue     "ModFreq", scale:k(kX^3,100,0), kT
kY,kT              cabbageGetValue     "Y"
                   cabbageSetValue     "ModDep", scale:k(kY,1,0), kT

kModFreq           cabbageGetValue     "ModFreq"
kModDep            cabbageGetValue     "ModDep"
kSkew              cabbageGetValue     "Skew"
kClip              cabbageGetValue     "Clip"
aClip              =                   a(kClip)
aSkew              interp              kSkew * (-0.99)


kModFreq           portk               kModFreq, 0.2
kModDep            portk               kModDep, 0.2

aMod               squinewave          a(kModFreq), aClip, aSkew, a(0); [, iMinSweep] [, iphase] 
aMod               =                   (aMod * 0.5) + 0.5                     ; unipolar
aMod               =                   1 - (aMod * kModDep)                   ; depth control

kOutGain           cabbageGetValue     "OutGain"

a1                 *=                  aMod * kOutGain
a2                 *=                  aMod * kOutGain

                   outs                a1, a2
endin

</CsInstruments>

<CsScore>
i1 0 z
</CsScore>

</CsoundSynthesizer>
