/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; Dynamic Tremelo
; Iain McCurdy 2026

<Cabbage>
form caption("Dynamic Tremelo") size(840,585), guiMode("queue") pluginId("Trml"), colour(50,50,60)

#define SLIDER_STYLE colour(200,200,210), textColour("white"), trackerColour(210,210,230), valueTextBox(1)
label    bounds(  5, 33, 70, 15), text("Input"), fontColour("white")

label    
combobox bounds( 10, 30, 65, 25), channel("InChns"), items("mono","stereo","test"), value(1)
rslider  bounds( 90, 10,100,100), channel("InGain"), range(0,1,0.5), text("In Gain"), $SLIDER_STYLE
rslider  bounds(175, 10,100,100), channel("OutGain"), range(0,1,0.5), text("Out Gain"), $SLIDER_STYLE

rslider  bounds(  5,120,100,100), channel("ModFreq"), range(0,100, 3, 0.25), text("Rate"), $SLIDER_STYLE
rslider  bounds( 90,120,100,100), channel("ModDep"), range(0, 1, 1), text("Depth"), $SLIDER_STYLE


rslider  bounds(  5,230,100,100), channel("Clip"), range(0.2,64,1,0.5), text("Power"), $SLIDER_STYLE
rslider  bounds( 90,230,100,100), channel("Skew"), range(-1,1,0), text("Skew"), $SLIDER_STYLE
rslider  bounds(175,230,100,100), channel("DS"), range(0.1,1,1,0.5), text("Duty Cycle"), $SLIDER_STYLE

gentable bounds( 20,350,240,100), tableNumber(1), ampRange(0,1.03,1), channel("Squinewave"), fill(0), alpha(0.5), tableGridColour(0,0,0,0), tableColour(0,0,0), tableBackgroundColour("white"), outlineThickness(3)

rslider  bounds(  5,460,100,100), channel("FiltMix"), range(0,1,0), text("Filt. Mix"), $SLIDER_STYLE
rslider  bounds( 90,460,100,100), channel("FiltMin"), range(0,1,0), text("Filt. Min"), $SLIDER_STYLE
rslider  bounds(175,460,100,100), channel("FiltMax"), range(0,1,1), text("Filt. Max"), $SLIDER_STYLE

xypad   bounds(280, 10,550,560), channel("X","Y"), rangeX(0,1,0.5), rangeY(0,1,0.5), text("X - Modulation Rate | Y - Modulation Depth")

label    bounds(  6,570,110, 12), text("Iain McCurdy |2026|"), align("left")
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

giSquinewave ftgen 1,0,1024,19,1,0.5,270,0.5
giSource     ftgen 2,0,1024,19,1,0.5,270,0.5
giClip       ftgen 3,0,1024,19,1,0.5,270,0.5
giSkew       ftgen 4,0,1024,19,1,0.5,270,0.5
giDS         ftgen 5,0,1024,19,1,0.5,270,0.5

instr 1

kInput             cabbageGetValue     "InChns"
if kInput==1 then
 a1                inch                1
 a2                =                   a1
elseif kInput==2 then
 a1,a2             ins
else ; test
 a1               poscil              0.1, 440
 a1               vco2                0.1, 110
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
kDS                cabbageGetValue     "DS"
kClip,kSkew,kDS init 1

kModFreq           portk               kModFreq, 0.2
kModDep            portk               kModDep, 0.2




;if metro:k(8)==1 then
 if changed:k(kClip,kSkew,kDS)==1 then
  reinit RESHAPE
 endif
;endif
RESHAPE:

; clip
iCount = 0
while iCount<ftlen(giSquinewave) do
iVal  table  iCount, giSource
      tablew iVal ^ i(kClip), iCount, giClip
iCount += 1
od

; skew
iCount = 0
while iCount<ftlen(giSquinewave) do
iNdx  pow    iCount/ftlen(giSquinewave), pow:i(3, i(kSkew))
iVal  tablei iNdx, giClip, 1
      tablew iVal, iCount, giSkew
iCount += 1
od
tableiw 0, ftlen(giSquinewave), giSkew

; duty cycle (shape)
iCount = 0
while iCount<ftlen(giSquinewave) do
iNdx  =      (iCount/i(kDS)) - (ftlen(giSquinewave) * (1/i(kDS) - 1) * 0.5)
iVal  table  iNdx, giSkew
      tablew iVal, iCount, giSquinewave
iCount += 1
od

rireturn

; redraw graphic
if metro:k(8)==1 then
 cabbageSet changed:k(kClip,kSkew,kDS), "Squinewave", "tableNumber", 1
endif

; create modulating waveform
aMod poscil kModDep, kModFreq, giSquinewave
aMod tone   aMod, 8000 ; smoothing

kOutGain           cabbageGetValue     "OutGain"

; apply filter modulation
kFiltMix           cabbageGetValue     "FiltMix"
kFiltMin           cabbageGetValue     "FiltMin"
kFiltMax           cabbageGetValue     "FiltMax"
aCF                =                   cpsoct( ( (aMod * (kFiltMax - kFiltMin) + kFiltMin) * 10) + 4)
aFilt1             butlp               a1, aCF
aFilt2             butlp               a2, aCF
a1                 ntrpol              a1, aFilt1, kFiltMix
a2                 ntrpol              a2, aFilt2, kFiltMix


; apply amplitude modulation
aMod1              =                   a1 * aMod * kOutGain
aMod2              =                   a2 * aMod * kOutGain

kDry = 0.3
aMod1              +=                  a1 * ((1 - kModDep)^2 * kDry)
aMod2              +=                  a2 * ((1 - kModDep)^2 * kDry)

                   outs                aMod1, aMod2
endin

</CsInstruments>

<CsScore>
i1 0 z
</CsScore>

</CsoundSynthesizer>
