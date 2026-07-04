
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; FormantFilter.csd
; Iain McCurdy 2012

; INPUT
; Input Source; choose audio input from the three options:
; 1. Live
; 2. Noise
; 3. Buzz

; Gain                 -  gain control of all audio input options 
; Depth (Live option)  -  depth of amplitude modulation
; Freq. (Live option)  -  frequency of amplitude modulation
; Shape (Live option)  -  steepness of the shape of the amplitude modulation 

; HARMONIC RESONATOR
; A harmonic resonance can be applied to any of the input sound choices
; Mode: Manual/MIDI - Note/Freq controls can either be controlled by GUI dials or a MIDI keyboard
; Note     - note number of the harmonic resonance  
; Freq.    - version of Note in hertz. Either control can be used.
; Res.     - strength of the resonance 
; Attack   - attack time (ideally when MIDI notes are used to activate the sound)
; Release  - release time (ideally when MIDI notes are used to activate the sound)
; Damping  - damping of high frequencies as the fundamental resonates

; FORMANT FILTER
; reson 1 uses reson with scaling method 1.
; reson 2 uses reson with scaling method 2.
; 'gain' controls the gain the the bandpass filtered sound only.
; 'BW.Mult' is a factor which all five bandwidth values are multiplied by.
; 'Freq.Mult.' is a factor by which all cutoff frequencies are multiplied by.


<Cabbage>
form caption("Formant Filter"), colour("SlateGrey"), size(1430, 385), pluginId("form") , guiMode("queue") 

; input
image bounds(  5,  5,140,285), colour(0,0,0,0), outlineColour("white"), corners(5), outlineThickness(2)
{
label    bounds(  0,  5,140, 15), text("I N P U T"), fontColour("White")
label    bounds( 20,  37,100, 12), text("Input Source"), fontColour("white")
combobox bounds( 20,  50,100, 20), channel("input"), value(1), text("Live", "Noise", "Buzz")
rslider bounds(  0, 90, 80, 80), text("Gain"),       channel("gain"),     range(0, 5.00, 0.0, 0.5),         textColour("white"), valueTextBox(1), fontColour("white")
rslider bounds( 60, 90, 80, 80), text("Depth"),     channel("pulsDep"),     range(0, 1, 1),         textColour("white"), valueTextBox(1), fontColour("white")
rslider bounds(  0,190, 80, 80), text("Freq."), channel("pulsFreq"), range(0, 2000,  0, 0.5,0.01), textColour("white"), valueTextBox(1), fontColour("white"), visible(1)
rslider bounds(  0,190, 80, 80), text("Buzz Freq."), channel("buzzFreq"), range(10, 2000, 130, 0.5,0.01), textColour("white"), valueTextBox(1), fontColour("white"), visible(0)
rslider bounds( 60,190, 80, 80), text("Power"), channel("buzzPow"), range(0, 0.99, 0.95), textColour("white"), valueTextBox(1), fontColour("white"), visible(0)
rslider bounds( 60,190, 80, 80), text("Shape"), channel("pulsShap"), range(0, 48,  4, 1,1), textColour("white"), valueTextBox(1), fontColour("white"), visible(1)
}


; harmonic filter
image bounds(155,  5,190,285), colour(0,0,0,0), outlineColour("white"), corners(5), outlineThickness(2)
{
label    bounds(  0,  5,190, 11), text("H A R M O N I C    R E S O N A T O R"), fontColour("White")
checkbox bounds( 10, 50, 80, 20), channel("FundOnOff"), text("On/Off"), value(0), fontColour:0("White"), fontColour:1("White")
label    bounds(100, 35, 80, 14), text("Mode"), fontColour("White")
combobox bounds(100, 50, 80, 20), channel("FundMode"), items("Manual", "MIDI"), value(1)
rslider  bounds(  0, 95, 70, 80), text("Note"),   channel("FundNote"),  range(0,127,48,1,0.01), textColour("white"), fontColour("white"), valueTextBox(1)
rslider  bounds( 60, 95, 70, 80), text("Freq."),  channel("FundFreq"),  range(8.176,12543.854,130.813,0.23,0.01), textColour("white"), fontColour("white"), valueTextBox(1)
rslider  bounds(120, 95, 70, 80), text("Res."),   channel("FundRes"),  range(0,0.95,0.3,0.5), textColour("white"), fontColour("white"), valueTextBox(1)
rslider  bounds(  0,185, 70, 80), text("Attack"),   channel("FundAtt"),  range(0.01,5,0.1,0.5), textColour("white"), fontColour("white"), valueTextBox(1)
rslider  bounds( 60,185, 70, 80), text("Release"),   channel("FundRel"),  range(0.01,5,0.1,0.5), textColour("white"), fontColour("white"), valueTextBox(1)
rslider  bounds(120,185, 70, 80), text("Damping"),   channel("FundDamp"),  range(50,18000,12000,0.5,1), textColour("white"), fontColour("white"), valueTextBox(1)
}

; formant filter
image bounds(350,  0,1080,295), colour(0,0,0,0)
{
label bounds( 15,  3,100, 50), text("A"), align("left"), active(0), fontColour("white")
label bounds(130,  3,100, 50), text("E"), align("centre"), active(0), fontColour("white")
label bounds(245,  3,100, 50), text("I"), align("right"), active(0), fontColour("white")
label bounds( 12,207,100, 50), text("U"), align("left"), active(0), fontColour("white")
label bounds(245,207,100, 50), text("O"), align("right"), active(0), fontColour("white")
xypad bounds(  5,  5,350,285), channel("x", "y"), rangeX(0, 1, 0), rangeY(0, 1, 0), text("upper edge:A E I | lower :U O"), fontColour("white"), alpha(0.5)
vslider bounds(360, 10, 30,190), text("f1"), channel("f1Gain"), range(0, 1.00, 1), textColour("white")
vslider bounds(380, 10, 30,190), text("f2"), channel("f2Gain"), range(0, 1.00, 1), textColour("white")
vslider bounds(400, 10, 30,190), text("f3"), channel("f3Gain"), range(0, 1.00, 1), textColour("white")
vslider bounds(420, 10, 30,190), text("f4"), channel("f4Gain"), range(0, 1.00, 1), textColour("white")
vslider bounds(440, 10, 30,190), text("f5"), channel("f5Gain"), range(0, 1.00, 1), textColour("white")
combobox bounds(365, 210,100, 20), channel("voice"), value(1), text("bass", "tenor", "countertenor", "alto", "soprano")
combobox bounds(365, 240,100, 20), channel("filter"), value(1), text("reson 1", "reson 2", "butterworth")
checkbox bounds(365, 270,100, 15), colour("yellow"), channel("balance"),  value(0), text("Balance"), fontColour:0("white"), fontColour:1("white")
rslider bounds(490, 10, 50, 70), text("BW.Mult"),   channel("BWMlt"),  range(0.01, 4, 1, 0.4), textColour("white")
rslider bounds(490, 80, 50, 70), text("Freq.Mult"), channel("FrqMlt"), range(0.25, 4, 1, 0.4), textColour("white")
rslider bounds(490,150, 50, 70), text("Mix"),       channel("mix"),    range(0, 1.00, 1),      textColour("white")
rslider bounds(490,220, 50, 70), text("Level"),     channel("level"),  range(0, 1.00, 1),      textColour("white")

image bounds(550,  0,600,295), colour(0,0,0,0)
{
nslider  bounds( 10, 10, 60, 30), text("Freq.1"), channel("f1"), range(0, 20000, 0, 1,1), active(0), textColour("white")
nslider  bounds( 10, 50, 60, 30), text("dB.1"), channel("dB1"), range(-120, 0, 0, 1,1), active(0), textColour("white")
nslider  bounds( 10, 90, 60, 30), text("BW.1"), channel("BW1"), range(0, 1000, 0, 1,1), active(0), textColour("white")

nslider  bounds( 80, 10, 60, 30), text("Freq.2"), channel("f2"), range(0, 20000, 0, 1,1), active(0), textColour("white")
nslider  bounds( 80, 50, 60, 30), text("dB.2"), channel("dB2"), range(-120, 0, 0, 1,1), active(0), textColour("white")
nslider  bounds( 80, 90, 60, 30), text("BW.2"), channel("BW2"), range(0, 1000, 0, 1,1), active(0), textColour("white")

nslider  bounds(150, 10, 60, 30), text("Freq.3"), channel("f3"), range(0, 20000, 0, 1,1), active(0), textColour("white")
nslider  bounds(150, 50, 60, 30), text("dB.3"), channel("dB3"), range(-120, 0, 0, 1,1), active(0), textColour("white")
nslider  bounds(150, 90, 60, 30), text("BW.3"), channel("BW3"), range(0, 1000, 0, 1,1), active(0), textColour("white")

nslider  bounds( 50,150, 60, 30), text("Freq.4"), channel("f4"), range(0, 20000, 0, 1,1), active(0), textColour("white")
nslider  bounds( 50,190, 60, 30), text("dB.4"), channel("dB4"), range(-120, 0, 0, 1,1), active(0), textColour("white")
nslider  bounds( 50,230, 60, 30), text("BW.4"), channel("BW4"), range(0, 1000, 0, 1,1), active(0), textColour("white")

nslider  bounds(120,150, 60, 30), text("Freq.5"), channel("f5"), range(0, 20000, 0, 1,1), active(0), textColour("white")
nslider  bounds(120,190, 60, 30), text("dB.5"), channel("dB5"), range(-120, 0, 0, 1,1), active(0), textColour("white")
nslider  bounds(120,230, 60, 30), text("BW.5"), channel("BW5"), range(0, 1000, 0, 1,1), active(0), textColour("white")

xypad bounds(220,  5,300,285), channel("x2", "y2"), rangeX(0, 1, 0), rangeY(0, 1, 0), text("X - Bandwidth | Y - Mix"), fontColour("white"), alpha(0.5)

}

}

label   bounds(1300, 292,120, 11), text("Iain McCurdy |2012|"), align("right"), fontColour("white")

keyboard bounds(105,300,1210,80)


</Cabbage>
<CsoundSynthesizer>
<CsOptions>
-dm0 -n -+rtmidi=NULL -M0
</CsOptions>
<CsInstruments>

; sr set by host
ksmps   =   32
nchnls  =   2
0dbfs   =   1
massign 0, 2

;Author: Iain McCurdy (2012)

;FUNCTION TABLES STORING DATA FOR VARIOUS VOICE FORMANTS
;THE FIRST VALUE OF EACH TABLE DEFINES THE NUMBER OF DATA ELEMENTS IN THE TABLE
; THIS IS NEEDED BECAUSE TABLES SIZES MUST BE POWERS OF 2 TO FACILITATE INTERPOLATED TABLE READING (tablei) 
;BASS
giBFA           ftgen       0,  0, 8, -2,   4, 600,     400,    250,    350 ;FREQ
giBFE           ftgen       0,  0, 8, -2,   4, 1040,    1620,   1750,   600 ;FREQ
giBFI           ftgen       0,  0, 8, -2,   4, 2250,    2400,   2600,   2400    ;FREQ
giBFO           ftgen       0,  0, 8, -2,   4, 2450,    2800,   3050,   2675    ;FREQ
giBFU           ftgen       0,  0, 8, -2,   4, 2750,    3100,   3340,   2950    ;FREQ

giBDbA          ftgen       0, 0, 8, -2,    4, 0,   0,  0,  0   ;dB
giBDbE          ftgen       0, 0, 8, -2,    4, -7,  -12,    -30,    -20 ;dB
giBDbI          ftgen       0, 0, 8, -2,    4, -9,  -9, -16,    -32 ;dB
giBDbO          ftgen       0, 0, 8, -2,    4, -9,  -12,    -22,    -28 ;dB
giBDbU          ftgen       0, 0, 8, -2,    4, -20, -18,    -28,    -36 ;dB

giBBWA          ftgen       0, 0, 8, -2,    4, 60,  40, 60, 40  ;BAND WIDTH
giBBWE          ftgen       0, 0, 8, -2,    4, 70,  80, 90, 80  ;BAND WIDTH
giBBWI          ftgen       0, 0, 8, -2,    4, 110, 100,    100,    100 ;BAND WIDTH
giBBWO          ftgen       0, 0, 8, -2,    4, 120, 120,    120,    120 ;BAND WIDTH
giBBWU          ftgen       0, 0, 8, -2,    4, 130, 120,    120,    120 ;BAND WIDTH
;TENOR
giTFA           ftgen       0, 0, 8, -2,    5, 650,     400,    290,    400,    350 ;FREQ
giTFE           ftgen       0, 0, 8, -2,    5, 1080,    1700,   1870,   800,    600 ;FREQ
giTFI           ftgen       0, 0, 8, -2,    5, 2650,    2600,   2800,   2600,   2700    ;FREQ
giTFO           ftgen       0, 0, 8, -2,    5, 2900,    3200,   3250,   2800,   2900    ;FREQ
giTFU           ftgen       0, 0, 8, -2,    5, 3250,    3580,   3540,   3000,   3300    ;FREQ

giTDbA          ftgen       0, 0, 8, -2,    5, 0,   0,  0,  0,  0   ;dB
giTDbE          ftgen       0, 0, 8, -2,    5, -6,  -14,    -15,    -10,    -20 ;dB
giTDbI          ftgen       0, 0, 8, -2,    5, -7,  -12,    -18,    -12,    -17 ;dB
giTDbO          ftgen       0, 0, 8, -2,    5, -8,  -14,    -20,    -12,    -14 ;dB
giTDbU          ftgen       0, 0, 8, -2,    5, -22, -20,    -30,    -26,    -26 ;dB

giTBWA          ftgen       0, 0, 8, -2,    5, 80,  70, 40, 40, 40  ;BAND WIDTH
giTBWE          ftgen       0, 0, 8, -2,    5, 90,  80, 90, 80, 60  ;BAND WIDTH
giTBWI          ftgen       0, 0, 8, -2,    5, 120, 100,    100,    100,    100 ;BAND WIDTH
giTBWO          ftgen       0, 0, 8, -2,    5, 130, 120,    120,    120,    120 ;BAND WIDTH                                         
giTBWU          ftgen       0, 0, 8, -2,    5, 140, 120,    120,    120,    120 ;BAND WIDTH
;COUNTER TENOR
giCTFA          ftgen       0, 0, 8, -2,    5, 660,     440,    270,    430,    370 ;FREQ
giCTFE          ftgen       0, 0, 8, -2,    5, 1120,    1800,   1850,   820,    630 ;FREQ
giCTFI          ftgen       0, 0, 8, -2,    5, 2750,    2700,   2900,   2700,   2750    ;FREQ
giCTFO          ftgen       0, 0, 8, -2,    5, 3000,    3000,   3350,   3000,   3000    ;FREQ
giCTFU          ftgen       0, 0, 8, -2,    5, 3350,    3300,   3590,   3300,   3400    ;FREQ

giTBDbA         ftgen       0, 0, 8, -2,    5, 0,   0,  0,  0,  0   ;dB
giTBDbE         ftgen       0, 0, 8, -2,    5, -6,  -14,    -24,    -10,    -20 ;dB
giTBDbI         ftgen       0, 0, 8, -2,    5, -23, -18,    -24,    -26,    -23 ;dB
giTBDbO         ftgen       0, 0, 8, -2,    5, -24, -20,    -36,    -22,    -30 ;dB
giTBDbU         ftgen       0, 0, 8, -2,    5, -38, -20,    -36,    -34,    -30 ;dB

giTBWA          ftgen       0, 0, 8, -2,    5, 80,  70, 40, 40, 40  ;BAND WIDTH
giTBWE          ftgen       0, 0, 8, -2,    5, 90,  80, 90, 80, 60  ;BAND WIDTH
giTBWI          ftgen       0, 0, 8, -2,    5, 120, 100,    100,    100,    100 ;BAND WIDTH
giTBWO          ftgen       0, 0, 8, -2,    5, 130, 120,    120,    120,    120 ;BAND WIDTH
giTBWU          ftgen       0, 0, 8, -2,    5, 140, 120,    120,    120,    120 ;BAND WIDTH
;ALTO
giAFA           ftgen       0, 0, 8, -2,    5, 800,     400,    350,    450,    325 ;FREQ
giAFE           ftgen       0, 0, 8, -2,    5, 1150,    1600,   1700,   800,    700 ;FREQ
giAFI           ftgen       0, 0, 8, -2,    5, 2800,    2700,   2700,   2830,   2530    ;FREQ
giAFO           ftgen       0, 0, 8, -2,    5, 3500,    3300,   3700,   3500,   2500    ;FREQ
giAFU           ftgen       0, 0, 8, -2,    5, 4950,    4950,   4950,   4950,   4950    ;FREQ

giADbA          ftgen       0, 0, 8, -2,    5, 0,   0,  0,  0,  0   ;dB
giADbE          ftgen       0, 0, 8, -2,    5, -4,  -24,    -20,    -9, -12 ;dB
giADbI          ftgen       0, 0, 8, -2,    5, -20, -30,    -30,    -16,    -30 ;dB
giADbO          ftgen       0, 0, 8, -2,    5, -36, -35,    -36,    -28,    -40 ;dB
giADbU          ftgen       0, 0, 8, -2,    5, -60, -60,    -60,    -55,    -64 ;dB

giABWA          ftgen       0, 0, 8, -2,    5, 50,  60, 50, 70, 50  ;BAND WIDTH
giABWE          ftgen       0, 0, 8, -2,    5, 60,  80, 100,    80, 60  ;BAND WIDTH
giABWI          ftgen       0, 0, 8, -2,    5, 170, 120,    120,    100,    170 ;BAND WIDTH
giABWO          ftgen       0, 0, 8, -2,    5, 180, 150,    150,    130,    180 ;BAND WIDTH
giABWU          ftgen       0, 0, 8, -2,    5, 200, 200,    200,    135,    200 ;BAND WIDTH
;SOPRANO
giSFA           ftgen       0, 0, 8, -2,    5, 800,     350,    270,    450,    325 ;FREQ
giSFE           ftgen       0, 0, 8, -2,    5, 1150,    2000,   2140,   800,    700 ;FREQ
giSFI           ftgen       0, 0, 8, -2,    5, 2900,    2800,   2950,   2830,   2700    ;FREQ
giSFO           ftgen       0, 0, 8, -2,    5, 3900,    3600,   3900,   3800,   3800    ;FREQ
giSFU           ftgen       0, 0, 8, -2,    5, 4950,    4950,   4950,   4950,   4950    ;FREQ

giSDbA          ftgen       0, 0, 8, -2,    5, 0,   0,  0,  0,  0   ;dB
giSDbE          ftgen       0, 0, 8, -2,    5, -6,  -20,    -12,    -11,    -16 ;dB
giSDbI          ftgen       0, 0, 8, -2,    5, -32, -15,    -26,    -22,    -35 ;dB
giSDbO          ftgen       0, 0, 8, -2,    5, -20, -40,    -26,    -22,    -40 ;dB
giSDbU          ftgen       0, 0, 8, -2,    5, -50, -56,    -44,    -50,    -60 ;dB

giSBWA          ftgen       0, 0, 8, -2,    5, 80,  60, 60, 70, 50  ;BAND WIDTH
giSBWE          ftgen       0, 0, 8, -2,    5, 90,  90, 90, 80, 60  ;BAND WIDTH
giSBWI          ftgen       0, 0, 8, -2,    5, 120, 100,    100,    100,    170 ;BAND WIDTH
giSBWO          ftgen       0, 0, 8, -2,    5, 130, 150,    120,    130,    180 ;BAND WIDTH
giSBWU          ftgen       0, 0, 8, -2,    5, 140, 200,    120,    135,    200 ;BAND WIDTH

instr   1
 kx2,kT            cabbageGetValue     "x2"
                   cabbageSetValue     "BWMlt", scale:k(kx2,4,0.01), kT
 ky2,kT            cabbageGetValue     "y2"
                   cabbageSetValue     "mix", scale:k(ky2,1,0), kT

 gkx               cabbageGetValue     "x"
 gky               cabbageGetValue     "y"
 gkf1              cabbageGetValue     "f1Gain"
 gkf2              cabbageGetValue     "f2Gain"
 gkf3              cabbageGetValue     "f3Gain"
 gkf4              cabbageGetValue     "f4Gain"
 gkf5              cabbageGetValue     "f5Gain"
 gkvoice           cabbageGetValue     "voice"
 gkvoice           init                1
 gkBWMlt           cabbageGetValue     "BWMlt"
 gkFrqMlt          cabbageGetValue     "FrqMlt"
 gkmix             cabbageGetValue     "mix"
 gklevel           cabbageGetValue     "level"
 gkgain            cabbageGetValue     "gain"
 gkfilter          cabbageGetValue     "filter"
 gkbalance         cabbageGetValue     "balance"
 gkinput           cabbageGetValue     "input"
 gkinput           init                1

                   cabbageSet          changed:k(gkinput), "buzzFreq", "visible", gkinput==3?1:0
                   cabbageSet          changed:k(gkinput), "buzzPow", "visible", gkinput==3?1:0

 kpulsFreq         cabbageGetValue     "pulsFreq"
 kpulsDep          cabbageGetValue     "pulsDep"
 kpulsShap         cabbageGetValue     "pulsShap"
                   cabbageSet          changed:k(gkinput), "pulsFreq", "visible", gkinput==1?1:0
                   cabbageSet          changed:k(gkinput), "pulsDep", "visible", gkinput==1?1:0
                   cabbageSet          changed:k(gkinput), "pulsShap", "visible", gkinput==1?1:0
    
 if gkinput==1 then  ; live input
  asigL,asigR      ins
 ; pulsing on live input
 iShpLen           =                   4096 ; table length
 if changed:k(kpulsShap)==1 then
                   reinit              UPDATE_SHAPE
 endif
 UPDATE_SHAPE:
 iShp              ftgen               0, 0, iShpLen, 16, 0, iShpLen * 0.1, i(kpulsShap), 1, iShpLen * 0.9, -i(kpulsShap), 0
 if kpulsFreq>0 then
  aGrainEnv        tablei              phasor(kpulsFreq),iShp,1 ; envelope
  aGrainEnv        ntrpol              a(1), aGrainEnv, kpulsDep
  asigL            *=                  aGrainEnv
  asigR            *=                  aGrainEnv
 endif
 rireturn
 elseif gkinput==2 then ; noise
  asigL            pinker
  asigR            pinker
 else                   ; buzz
  kbuzzFreq        cabbageGetValue     "buzzFreq"
  kbuzzPow         cabbageGetValue     "buzzPow"
  icos             ftgen               0,0,131072,11,1
  asigL            gbuzz               1, kbuzzFreq, (sr*0.5)/kbuzzFreq, 1, kbuzzPow, icos
  asigR            =                   asigL
 endif
    

    
 gkFundOnOff       chnget              "FundOnOff"
 gkFundMode        chnget              "FundMode"
 gkFundNote        chnget              "FundNote"
 gkFundFreq        chnget              "FundFreq"
 if changed:k(gkFundNote)==1 then
                   cabbageSetValue     "FundFreq",cpsmidinn(gkFundNote)
 elseif changed:k(gkFundFreq)==1 then
                   cabbageSetValue     "FundNote", ftom:k(gkFundFreq)     
 endif
     
 gkFundRes         chnget              "FundRes"
 gkFundDamp        chnget              "FundDamp"
 gkFundAtt         chnget              "FundAtt"
 gkFundRel         chnget              "FundRel"
 if gkFundOnOff==1 && gkFundMode==1 then ; Manual fundamental mode
  asigL            wguide1             asigL, cpsmidinn(gkFundNote), gkFundDamp, gkFundRes
  asigR            wguide1             asigR, cpsmidinn(gkFundNote), gkFundDamp, gkFundRes
 endif
     
 gasigL            =                   asigL
 gasigR            =                   asigR
endin





instr   2 ; MIDI fundamental filter
 iNote             notnum
 aEnv              cossegr             0, i(gkFundAtt), 1, i(gkFundRel), 0
 if gkFundOnOff==1 && gkFundMode==2 then
  asigL            wguide1             gasigL, cpsmidinn(iNote), gkFundDamp, gkFundRes
  asigR            wguide1             gasigR, cpsmidinn(iNote), gkFundDamp, gkFundRes
 endif

 gasigL            +=                  asigL * aEnv
 gasigR            +=                  asigR * aEnv
 asigL             =                   0
 asigR             =                   0
endin






instr   3
 if gkFundOnOff==1 && gkFundMode==2 then ; if MIDI notes fundamental mode...
  kEnv             =                   active:k(2)>0 ? 1 : 0
  aEnv             interp              kEnv
  gasigL           *=                  aEnv
  gasigR           *=                  aEnv
 endif
    
 kporttime         linseg              0, 0.001, 0.1                                                     
    
        
 kx                portk               gkx, kporttime
 ky                portk               gky, kporttime   
    
 kSwitch           changed             gkvoice                                                                                  ; GENERATE A MOMENTARY '1' PULSE IN OUTPUT 'kSwitch' IF ANY OF THE SCANNED INPUT VARIABLES CHANGE. (OUTPUT 'kSwitch' IS NORMALLY ZERO)
 if kSwitch==1 then                                                                                             ; IF I-RATE VARIABLE CHANGE TRIGGER IS '1'...
                   reinit              START                                                                                                ; BEGIN A REINITIALISATION PASS FROM LABEL 'START'
 endif
 START:      
 ;A TEXT MACRO IS DEFINED THAT WILL BE THE CODE FOR DERIVING DATA FOR EACH FORMANT. A MACRO IS USED TO AVOID HAVING TO USING CODE REPETITION AND TO EASIER FACICLITATE CODE MODIFICATION
#define FORMANT_DATA(N) 
#
invals             table               0, giBFA+((i(gkvoice)-1)*15)+$N-1                                                        ; NUMBER OF DATA ELEMENTS IN EACH TABLE
invals             =                   invals - 1                                    ;
kfreq$N._U         tablei              1 + (kx * (3 / 5) * invals), giBFA + ((i(gkvoice) - 1) * 15) + $N - 1                    ; READ DATA FOR FREQUENCY (UPPER EDGE OF PANEL)
kfreq$N._L         tablei              1 + (((1 - kx) * (1 / 5)) + (4 / 5) * invals), giBFA + ((i(gkvoice) - 1) * 15) + $N - 1  ; READ DATA FOR FREQUENCY (LOWER EDGE OF PANEL)
kfreq$N            ntrpol              kfreq$N._L, kfreq$N._U, ky                                                               ; INTERPOLATE BETWEEN UPPER VALUE AND LOWER VALUE (DETERMINED BY Y-LOCATION ON PANEL)                          
kfreq$N            =                   kfreq$N * gkFrqMlt                                                                       ; MULTIPLY FREQUENCY VALUE BY VALUE FROM 'Frequency Multiply' SLIDER
                   cabbageSetValue     "f$N", kfreq$N
kdbamp$N._U        tablei              1 + (kx * (3 / 5) * invals), giBDbA + ((i(gkvoice) - 1) * 15) + $N - 1                   ; READ DATA FOR INTENSITY (UPPER EDGE OF PANEL)                                      
kdbamp$N._L        tablei              1 + (((1 - kx) * (1 / 5)) + (4 / 5) * invals), giBDbA + ((i(gkvoice) - 1) * 15) + $N - 1 ; READ DATA FOR INTENSITY (LOWER EDGE OF PANEL)                                      
kdbamp$N           ntrpol              kdbamp$N._L, kdbamp$N._U, ky                                                             ; INTERPOLATE BETWEEN UPPER VALUE AND LOWER VALUE (DETERMINED BY Y-LOCATION ON PANEL)
                   cabbageSetValue     "dB$N", kdbamp$N
kbw$N._U           tablei              1 + (kx * (3 / 5) * invals), giBBWA + ((i(gkvoice) - 1) * 15) + $N - 1                   ; READ DATA FOR BANDWIDTH (UPPER EDGE OF PANEL)                                      
kbw$N._L           tablei              1 + (((1 - kx) * (1 / 5)) + (4 / 5) * invals), giBBWA + ((i(gkvoice) -1 ) * 15) + $N - 1 ; READ DATA FOR BANDWIDTH (LOWER EDGE OF PANEL)                                      
kbw$N              ntrpol              kbw$N._L, kbw$N._U, ky                                                                   ; INTERPOLATE BETWEEN UPPER VALUE AND LOWER VALUE (DETERMINED BY Y-LOCATION ON PANEL)
kbw$N              =                   kbw$N * gkBWMlt                                                                          ; MULTIPLY BANDWIDTH VALUE BY VALUE FROM 'Bandwidth Multiply' SLIDER
                   cabbageSetValue     "BW$N", kbw$N
#                                                                                                                ; END OF MACRO!

;READING DATA FOR FORMANTS (MACROS IMPLEMENTED)
$FORMANT_DATA(1)
$FORMANT_DATA(2)
$FORMANT_DATA(3)
$FORMANT_DATA(4)
$FORMANT_DATA(5)

                   rireturn    ;RETURN FROM REINITIALISATION PASS TO PERFORMANCE TIME PASSES
    
 if gkfilter==1 then
  aBPF1L           reson               gasigL, kfreq1, kbw1, 1          ; FORMANT 1
  aBPF1R           reson               gasigR, kfreq1, kbw1, 1          ; FORMANT 1
  ;                                                        
  aBPF2L           reson               gasigL, kfreq2, kbw2, 1          ; FORMANT 2
  aBPF2R           reson               gasigR, kfreq2, kbw2, 1          ; FORMANT 2
  ;                                                       
  aBPF3L           reson               gasigL, kfreq3, kbw3, 1          ; FORMANT 3
  aBPF3R           reson               gasigR, kfreq3, kbw3, 1          ; FORMANT 3
  ;                                                        
  aBPF4L           reson               gasigL, kfreq4, kbw4, 1          ; FORMANT 4
  aBPF4R           reson               gasigR, kfreq4, kbw4, 1          ; FORMANT 4
  ;                                                       
  aBPF5L           reson               gasigL, kfreq5, kbw5, 1          ; FORMANT 5
  aBPF5R           reson               gasigR, kfreq5, kbw5, 1          ; FORMANT 5  
 elseif gkfilter==2 then
  aBPF1L           reson               gasigL, kfreq1, kbw1, 2          ; FORMANT 1
  aBPF1R           reson               gasigR, kfreq1, kbw1, 2          ; FORMANT 1
  ;                                                        
  aBPF2L           reson               gasigL, kfreq2, kbw2, 2          ; FORMANT 2
  aBPF2R           reson               gasigR, kfreq2, kbw2, 2          ; FORMANT 2
  ;                                                       
  aBPF3L           reson               gasigL, kfreq3, kbw3, 2          ; FORMANT 3
  aBPF3R           reson               gasigR, kfreq3, kbw3, 2          ; FORMANT 3
  ;                                                        
  aBPF4L           reson               gasigL, kfreq4, kbw4, 2          ; FORMANT 4
  aBPF4R           reson               gasigR, kfreq4, kbw4, 2          ; FORMANT 4
  ;                                                       
  aBPF5L           reson               gasigL, kfreq5, kbw5, 2          ; FORMANT 5
  aBPF5R           reson               gasigR, kfreq5, kbw5, 2          ; FORMANT 5
 else
  aBPF1L           butbp               gasigL, kfreq1, kbw1             ; FORMANT 1
  aBPF1R           butbp               gasigR, kfreq1, kbw1             ; FORMANT 1
  ;                                                        
  aBPF2L           butbp               gasigL, kfreq2, kbw2             ; FORMANT 2
  aBPF2R           butbp               gasigR, kfreq2, kbw2             ; FORMANT 2
  ;                                                       
  aBPF3L           butbp               gasigL, kfreq3, kbw3             ; FORMANT 3
  aBPF3R           butbp               gasigR, kfreq3, kbw3             ; FORMANT 3
  ;                                                        
  aBPF4L           butbp               gasigL, kfreq4, kbw4             ; FORMANT 4
  aBPF4R           butbp               gasigR, kfreq4, kbw4             ; FORMANT 4
  ;                                                       
  aBPF5L           butbp               gasigL, kfreq5, kbw5             ; FORMANT 5
  aBPF5R           butbp               gasigR, kfreq5, kbw5             ; FORMANT 5
 endif   
    
 if gkbalance==1 then
  aBPF1L           balance             aBPF1L, gasigL, 0.1
  aBPF1R           balance             aBPF1R, gasigR, 0.1
  aBPF2L           balance             aBPF2L, gasigL, 0.1
  aBPF2R           balance             aBPF2R, gasigR, 0.1
  aBPF3L           balance             aBPF3L, gasigL, 0.1
  aBPF3R           balance             aBPF3R, gasigR, 0.1
  aBPF4L           balance             aBPF4L, gasigL, 0.1
  aBPF4R           balance             aBPF4R, gasigR, 0.1
  aBPF5L           balance             aBPF5L, gasigL, 0.1
  aBPF5R           balance             aBPF5R, gasigR, 0.1
    endif

 ;FORMANTS ARE MIXED AND MULTIPLIED BOTH BY INTENSITY VALUES DERIVED FROM TABLES AND BY THE ON-SCREEN GAIN CONTROLS FOR EACH FORMANT 
 aMixL             sum                 aBPF1L * (ampdbfs(kdbamp1)) * gkf1, aBPF2L * (ampdbfs(kdbamp2)) * gkf2, aBPF3L * (ampdbfs(kdbamp3)) * gkf3, aBPF4L * (ampdbfs(kdbamp4)) * gkf4, aBPF5L * (ampdbfs(kdbamp5)) * gkf5
 aMixR             sum                 aBPF1R * (ampdbfs(kdbamp1)) * gkf1, aBPF2R * (ampdbfs(kdbamp2)) * gkf2, aBPF3R * (ampdbfs(kdbamp3)) * gkf3, aBPF4R * (ampdbfs(kdbamp4)) * gkf4, aBPF5R * (ampdbfs(kdbamp5)) * gkf5

 aOutMixL          ntrpol              gasigL * 0.3 * gkgain, aMixL * gkgain, gkmix        ; MIX BETWEEN DRY AND WET SIGNALS
 aOutMixR          ntrpol              gasigR * 0.3 * gkgain, aMixR * gkgain, gkmix        ; MIX BETWEEN DRY AND WET SIGNALS

                   outs                aOutMixL * 20 * gklevel, aOutMixR * 20 * gklevel    ; SEND AUDIO TO OUTPUTS
endin

</CsInstruments>

<CsScore>
i 1 0 z
i 3 0 z
</CsScore>

</CsoundSynthesizer>