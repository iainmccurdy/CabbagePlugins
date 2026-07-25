
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; Ostinator
; Written by Iain McCurdy, 2012, 2025

; The Ostinator uses streaming phase vocoding to capture a buffer of audio and play back selected fragments - ostinati - in various ways.

; Buttons
; Record      -   press to start recording a new buffer, press a second time to stop recording. 
;                 The waveform is drawn on the GUI when recording is stopped.
; Pause       -   pause recording
; Play Loop   -   play buffered audio in a loop
; Play Once   -   play buffered audio once

; Mono/Stereo -   selects whether a mono or stereo buffer will be recorded

; FFT Size    -   FFT size used by phase vocoding analysis and replay.
;                 Use larger sizes for better frequency resolution, use smaller sizes for better time resolution.

; In Gain     -   Gain control applied to audio entering the Ostinator
; Out Gain    -   Gain control applied all audio exiting the Ostinator
; Dry Out     -   Amount of dry signal sent to the output

; Loop Shape  -   shape of the pointer used in looping.
;                 shape chosen is revealed in the graph to the right
; Phase Lock  -   lock phases in phase vocoded output

; Speed       -   speed of playback as a ratio of normal playback speed
; Pitch       -   pitch as a ratio of original pitch

; Buffer (in the silver box)
; Above and below the buffer audio waveform display are sliders which will control the loop start and end points.
;  Start and end loop points can be inverted to reverse playback speed.
; The section of the audio buffer that will be looped is shown by a box overlaid on the waveform. 
; This section can be shifted across the waveform by clicking and dragging on it.

; MIDI TO PITCH - MIDI notes played will be mapped to playback pitch about UNISON PITCH
; MIDI TO SPEED - MIDI notes played will be mapped to playback speed as a ratio to original speed with UNISON PITCH defining normal playback speed 

; STRETCH - intervallic stretch for MIDI-activated notes
; ATT     - amplitude attack time for MIDI-activated notes
; REL     - amplitude release time for MIDI-activated notes
; TUNING  - tuning system used for MIDI-activated notes

<Cabbage>
form caption("Ostinator") size(870,660), pluginId("Osti") colour(30,30,30), guiMode("queue")

#define DIAL_STYLE       markerStart(0), markerEnd(1.05), markerThickness(0.8), trackerInsideRadius(0.8), trackerColour(0,0,0,0), valueTextBox(1)
#define DIAL_STYLE_SMALL markerStart(0), markerEnd(1.05), markerThickness(0.8), trackerInsideRadius(0.7), trackerColour(0,0,0,0)
#define SLIDER_STYLE     trackerColour("Silver"), valueTextBox(1)
#define SLIDER_STYLE2    trackerColour("Silver"), valueTextBox(0)

groupbox bounds(  5,  5,300,100), text("Transport")
{
label    bounds( 15, 79, 60, 13), text("Record"), align("centre")
label    bounds( 85, 79, 60, 13), text("Pause"), align("centre")
label    bounds(155, 79, 60, 13), text("Play Loop"), align("centre")
label    bounds(225, 79, 60, 13), text("Play Once"), align("centre")
checkbox bounds( 15, 25, 60, 50), channel("Record"), value(0), shape("square"), colour:1("red"), colour:0(40,0,0)
checkbox bounds( 85, 25, 60, 50), channel("Pause"), value(0), shape("square"), colour:1(100,100,255), colour:0(0,0,40)
checkbox bounds(155, 25, 60, 50), channel("PlayLoop"), value(0), shape("square"), colour:1("Lime"), colour:0(0,40,0)
checkbox bounds(225, 25, 60, 50), channel("PlayOnce"), value(0), shape("square"), colour:1("yellow"), colour:0(40,40,0)
}

;image bounds(  5,  5,300,100), channel("Transport"), colour(0,0,0,0), outlineThickness(2)
;{
;button bounds(15,25,60,60), channel("Record"), text("Record") corners(5)
;}

; mono/stereo toggle
groupbox bounds(310,  5,100,100), text("Mono/Stereo")
image    bounds(320, 37, 30, 50), corners(15), colour(90,90,90), outlineThickness(1), outlineColour("Black"), channel("SwFrame") ; frame
image    bounds(321, 38, 28, 28), channel("toggle"), corners(14), colour(250,250,250), outlineThickness(1), outlineColour("Grey") ; toggle
label    bounds(355, 44, 50, 11), text("• MONO"), align("left")
label    bounds(355, 67, 50, 11), text("• STEREO"), align("left")

groupbox bounds(415,  5,100,100), text("Quality")
{
combobox bounds(  5, 30, 90, 25), channel("FFTsize"), items("128","256","512","1024","2048","4096") value(5)
;combobox bounds(  5, 30, 90, 25), channel("FFToverlap"), items("2","4","8","16") value(3)
checkbox bounds(  5, 60, 90, 15), channel("PhaseLock"), text("Phase Lock"), value(0)
}

image    bounds(520,  5, 90,100) colour(0,0,0,0), outlineThickness(1), corners(5), outlineColour("silver")
{
label    bounds(  5,  2, 80, 13), text("Loop Shape")
combobox bounds(  5, 15, 80, 25), channel("LoopShape"), items("Ramp","Tri","Half Sine","Gauss","Pinch") value(1)
gentable bounds(  5, 45, 80, 50), channel("LoopShapeTab"), tableNumber(99), ampRange(0,1,-1), fill(0)
}


image    bounds(615,  5,250,100) colour(0,0,0,0), outlineThickness(1), corners(5), outlineColour("silver")
{
rslider  bounds(  0,  4, 90, 90), channel("InGain"), range(0, 1, 1, 0.5), text("In Gain"), $DIAL_STYLE
rslider  bounds( 82,  4, 90, 90), channel("OutGain"), range(0, 1, 1, 0.5), text("Out Gain"), $DIAL_STYLE
rslider  bounds(165,  4, 90, 90), channel("DryOut"), range(0, 1, 0, 0.5), text("Dry Out"), $DIAL_STYLE
}

hslider bounds( 10,130,680,20), channel("Speed"), text("Speed"), range(-8.00, 8.00, 1), popupText(0), $SLIDER_STYLE
hslider bounds( 10,170,680,20), channel("Pitch"), text("Pitch"), range(0.125, 8.00, 1, 0.33,0.00001), $SLIDER_STYLE
button  bounds(700,135,150,50), channel("Freeze"), text("FREEZE"), corners(5), colour:0(20,20, 30), colour:1(100,100,250), latched(1), fontColour:0(50,50,100), fontColour:1(225,225,255)

; overlay
image      bounds(  0,210,870,225), colour(0,0,0,0), outlineColour("silver"), outlineThickness(4), corners(5)
hslider    bounds( 10,215,850, 20), channel("LoopBeg"), range(0, 1, 0), popupText(0), $SLIDER_STYLE2
gentable   bounds( 14,235,842,178), channel("Display"), tableNumber(2), alpha(0.85)
image      bounds( 14,235,842,178), channel("LoopDisplay"), alpha(0.2) ; overlay , colour(255,255,255,50);
image      bounds( 14,235,  1,178), channel("Wiper")
hslider    bounds( 10,410,850, 20), channel("LoopEnd"), range(0, 1, 1), popupText(0), $SLIDER_STYLE2

; keyboard control
image bounds(0,450,870,500), colour(0,0,0,0)
{
checkbox bounds( 20,  5,120, 12), channel("Y2Pitch"), text("Y TO PITCH"), colour:0(0,50,0), value(0)
checkbox bounds( 20, 25,120, 12), channel("Y2Filt"), text("Y TO FILTERS"), colour:0(0,50,0), value(0)
checkbox bounds( 20, 45,120, 12), channel("Y2Speed"), text("Y TO SPEED"), colour:0(0,50,0), value(0)
checkbox bounds( 20, 65, 95, 12), channel("MouseGate"), text("MOUSE GATE"), colour:0(0,50,0), value(0)

rslider  bounds(130,  5, 90, 90), channel("LPFRes"), range(0.5,25,0.5,0.5), text("LPF. RES."), visible(0), $DIAL_STYLE
rslider  bounds(210,  5, 90, 90), channel("HPFRes"), range(0.5,25,0.5,0.5), text("HPF. RES."), visible(0), $DIAL_STYLE

checkbox bounds(310, 10,120, 12), channel("MIDI2Pitch"), text("MIDI TO PITCH"), colour:0(0,50,0), value(1)
checkbox bounds(310, 30,120, 12), channel("MIDI2Speed"), text("MIDI TO SPEED"), colour:0(0,50,0)
nslider  bounds(430,  7, 80, 35), channel("Unison"), text("UNISON NOTE"), range(0,127,60,1,1)
rslider  bounds(510,  0, 90, 90), channel("Stretch"), range(-2,2,1), text("STRETCH"), $DIAL_STYLE
rslider  bounds(590,  0, 90, 90), channel("AttTim"), range(0.01,25, 0.01, 0.5), text("ATTACK"), $DIAL_STYLE
rslider  bounds(670,  0, 90, 90), channel("RelTim"), range(0.01,25, 0.01, 0.5), text("RELEASE"), $DIAL_STYLE
label    bounds(755,  3,100, 13), text("TUNING")
combobox bounds(755, 17,100, 22), channel("Tuning"), text("12-TET", "24-TET", "12-TET rev.", "24-TET rev.", "10-TET", "36-TET", "Just C", "Just C#", "Just D", "Just D#", "Just E", "Just F", "Just F#", "Just G", "Just G#", "Just A", "Just A#", "Just B","Pythagorean C","19 TET","31 TET","Bohlen-Pierce C"), value(1)

keyboard bounds( 10,105,850, 85)
}

label    bounds( 10,643,110, 12), text("Iain McCurdy |2025|"), align("left"), fontColour("LightGrey")
</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-dm0 -n -+rtmidi=NULL -M0
</CsOptions>

<CsInstruments>

; sr set by host
ksmps              =                   32
nchnls             =                   2
0dbfs              =                   1

                   massign             0, nstrnum:i("PlayLoop")

giBuffer           ftgen               1, 0, 2^20, 7, 0 ; a buffer that is used purely for display purposes (storage before rescaling)
giDisplay          ftgen               2, 0, 2^20, 7, 0 ; a buffer that is used purely for display purposes (display)
giDisplayZero      ftgen               3, 0, 2^20, 7, 0 ; zero table

prints "Maximum Buffer Duration %f\n", ftlen(giBuffer)/sr

; Loop Shapes
iFTLen             =                   2^8
giRamp             ftgen               11, 0, iFTLen, 7, 0, iFTLen, 1 
giTri              ftgen               12, 0, iFTLen, 7, 0, iFTLen/2, 1, iFTLen/2, 0
giHalfSine         ftgen               13, 0, iFTLen, 9, 0.5, 1, 0
giGauss            ftgen               14, 0, iFTLen, 19, 1, 0.5, 270, 0.5
giPinch            ftgen               15, 0, iFTLen, 16, 0, iFTLen/2, 4, 1, iFTLen/2, -4, 0

; loop shape display table
giLoopShapeTab     ftgen               99, 0, 2^8, 10, 1

; tuning tables for MIDI notes
;                                      FN_NUM | INIT_TIME | SIZE | GEN_ROUTINE | NUM_GRADES | REPEAT |  BASE_FREQ  | BASE_KEY_MIDI | TUNING_RATIOS:-0-|----1----|---2----|----3----|----4----|----5----|----6----|----7----|----8----|----9----|----10-----|---11----|---12---|---13----|----14---|----15---|---16----|----17---|---18----|---19---|----20----|---21----|---22----|---23---|----24----|----25----|----26----|----27----|----28----|----29----|----30----|----31----|----32----|----33----|----34----|----35----|----36----|
giTTable1          ftgen               0,         0,       64,       -2,          12,          2,   cpsmidinn(60),      60,                       1, 1.059463,1.1224619,1.1892069,1.2599207,1.33483924,1.414213,1.4983063,1.5874001,1.6817917,1.7817962, 1.8877471,     2 ;STANDARD
giTTable2          ftgen               0,         0,       64,       -2,          24,          2,   cpsmidinn(60),      60,                       1, 1.0293022,1.059463,1.0905076,1.1224619,1.1553525,1.1892069,1.2240532,1.2599207,1.2968391,1.33483924,1.3739531,1.414213,1.4556525,1.4983063, 1.54221, 1.5874001, 1.6339145,1.6817917,1.73107,  1.7817962,1.8340067,1.8877471,1.9430623,    2 ;QUARTER TONES
giTTable3          ftgen               0,         0,       64,       -2,          12,        0.5,   cpsmidinn(60),      60,                       2, 1.8877471,1.7817962,1.6817917,1.5874001,1.4983063,1.414213,1.33483924,1.2599207,1.1892069,1.1224619,1.059463,      1 ;STANDARD REVERSED
giTTable4          ftgen               0,         0,       64,       -2,          24,        0.5,   cpsmidinn(60),      60,                       2, 1.9430623,1.8877471,1.8340067,1.7817962,1.73107, 1.6817917,1.6339145,1.5874001,1.54221,  1.4983063, 1.4556525,1.414213,1.3739531,1.33483924,1.2968391,1.2599207,1.2240532,1.1892069,1.1553525,1.1224619,1.0905076,1.059463, 1.0293022,    1 ;QUARTER TONES REVERSED
giTTable5          ftgen               0,         0,       64,       -2,          10,          2,   cpsmidinn(60),      60,                       1, 1.0717734,1.148698,1.2311444,1.3195079, 1.4142135,1.5157165,1.6245047,1.7411011,1.8660659,     2 ;DECATONIC
giTTable6          ftgen               0,         0,       64,       -2,          36,          2,   cpsmidinn(60),      60,                       1, 1.0194406,1.0392591,1.059463,1.0800596, 1.1010566,1.1224618,1.1442831,1.1665286,1.1892067,1.2123255,1.2358939,1.2599204,1.284414,1.3093838, 1.334839, 1.3607891,1.3872436,1.4142125,1.4417056,1.4697332,1.4983057,1.5274337,1.5571279,1.5873994, 1.6182594,1.6497193, 1.6817909, 1.7144859, 1.7478165, 1.7817951, 1.8164343, 1.8517469, 1.8877459, 1.9244448, 1.9618572,      2 ;THIRD TONES
giTTable7          ftgen               0,         0,       64,       -2,          12,          2,   cpsmidinn(60),      60,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable8          ftgen               0,         0,       64,       -2,          12,          2,   cpsmidinn(61),      61,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable9          ftgen               0,         0,       64,       -2,          12,          2,   cpsmidinn(62),      62,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable10         ftgen               0,         0,       64,       -2,          12,          2,   cpsmidinn(63),      63,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable11         ftgen               0,         0,       64,       -2,          12,          2,   cpsmidinn(64),      64,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable12         ftgen               0,         0,       64,       -2,          12,          2,   cpsmidinn(65),      65,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable13         ftgen               0,         0,       64,       -2,          12,          2,   cpsmidinn(66),      66,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable14         ftgen               0,         0,       64,       -2,          12,          2,   cpsmidinn(67),      67,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable15         ftgen               0,         0,       64,       -2,          12,          2,   cpsmidinn(68),      68,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable16         ftgen               0,         0,       64,       -2,          12,          2,   cpsmidinn(69),      69,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable17         ftgen               0,         0,       64,       -2,          12,          2,   cpsmidinn(70),      70,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable18         ftgen               0,         0,       64,       -2,          12,          2,   cpsmidinn(71),      71,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
gipyth             ftgen               0,         0,       64,       -2,          12,          2,   cpsmidinn(60),      60,                       1,  256/243,   9/8,    32/27,    81/64,      4/3,    729/512,    3/2,    128/81,   27/16,     16/9,     243/128,  2     ;RATIOS FOR PYTHAGOREAN TUNING
gi19TET            ftgen               0,         0,       64,       -2,          19,          2,   cpsmidinn(60),      60,                       1,2^(1/19),2^(2/19),2^(3/19),2^(4/19),2^(5/19),2^(6/19),2^(7/19),2^(8/19),2^(9/19),2^(10/19),2^(11/19),2^(12/19),2^(13/19),2^(14/19),2^(15/19),2^(16/19),2^(17/19),2^(18/19),2^(19/19)
gi31TET            ftgen               0,         0,       64,       -2,          31,          2,   cpsmidinn(60),      60,                       1,2^(1/31),2^(2/31),2^(3/31),2^(4/31),2^(5/31),2^(6/31),2^(7/31),2^(8/31),2^(9/31),2^(10/31),2^(11/31),2^(12/31),2^(13/31),2^(14/31),2^(15/31),2^(16/31),2^(17/31),2^(18/31),2^(19/31),2^(20/31),2^(21/31),2^(22/31),2^(23/31),2^(24/31),2^(25/31),2^(26/31),2^(27/31),2^(28/31),2^(29/31),2^(30/31),2^(31/31)
giBP               ftgen               0,         0,       64,       -2,          13,          3,   cpsmidinn(60),      60,                       1,3^(1/13),3^(2/13),3^(3/13),3^(4/13),3^(5/13),3^(6/13),3^(7/13),3^(8/13),3^(9/13),3^(10/13),3^(11/13),3^(12/13),3^(13/13)

; Author: Iain McCurdy (2012)

gkRecDur           init                0                   ; DURATION OF THE MOST RECENTLY RECORDED BUFFER
gibuflen           init                60                  ; PVS BUFFER LENGTH


; i-rate-only opcode
opcode CreateDisplayTable,0,iii
iDstFn,iSrcFn,iRecDur   xin
i_                 ftgen               iDstFn, 0, ftlen(iDstFn), 2, 0
iCount             =                   0
iMax               =                   0
iLen               =                   ftlen(iDstFn)
; create table (un-normalised)
while              iCount<iRecDur      do
iVal               tablei              iCount, iSrcFn                       ; read value (interpolated) from source function table
iMax               =                   abs(iVal) > iMax ? abs(iVal) : iMax  ; scan for absolute maximum value (for normalisation of display table)
                   tablew              iVal,iCount/iRecDur, iDstFn, 1       ; write value into display table
iCount             +=                  1
od
; create normalised table
iCount             =                   0
while   iCount<iLen do
iVal               table               iCount, iDstFn
                   tablew              iVal * (1/iMax), iCount, iDstFn
iCount             +=                  1
od
endop



; Performance
; kin     -- Input signal.
; kUpPort -- Portamento time when the input signal is rising.
; kDnPort -- Portamento time when the input signal is falling.
opcode  SwitchPort, k, kkk
kin,kUpPort,kDnPort xin
kold               init                0
kporttime		   =                   (kin < kold ? kDnPort : kUpPort)
kout               portk               kin, kporttime
kold               =                   kout
xout               kout
endop




instr    1 ; READ IN WIDGETS AND START AND STOP THE VARIOUS RECORDING AND PLAYBACK INSTRUMENTS
 
 ; mono/stereo toggle
 kMOUSE_DOWN_LEFT  cabbageGetValue     "MOUSE_DOWN_LEFT" ; read in mouse left click
 kMOUSE_X          cabbageGetValue     "MOUSE_X"         ; read in mouse X position
 kMOUSE_Y          cabbageGetValue     "MOUSE_Y"         ; read in mouse Y position
 gkMonoStereo      init                0                 ; mono/stereo toggle variable (0=mono, 1=stereo)
 
 ; trigger toggle if left click is pressed within area of switch
 iSwBounds[]       cabbageGet          "SwFrame", "bounds"
 iSwX   = iSwBounds[0]
 iSwY   = iSwBounds[1]
 iSwWid = iSwBounds[2]
 iSwHei = iSwBounds[3]
 if trigger:k(kMOUSE_DOWN_LEFT,0.5,0)==1 && kMOUSE_X>iSwX && kMOUSE_X<(iSwX+iSwWid) && kMOUSE_Y>iSwY && kMOUSE_Y<(iSwY+iSwWid) then
  gkMonoStereo     =                   abs(gkMonoStereo-1) ; variable toggling mechanism
 endif
                   schedkwhen          trigger:k(gkMonoStereo,0.5,0),0,0,999,0,0.002,2500
                   schedkwhen          trigger:k(gkMonoStereo,0.5,1),0,0,999,0,0.002,2000
 
 kTogPos           lineto              gkMonoStereo*20, 0.05                                            ; glide movement
                   cabbageSet          changed:k(kTogPos), "toggle", "bounds",iSwX+1, iSwY+1 + kTogPos, 28, 28 ; update toggle switch position
             
 ; dry out
 kDryOut           cabbageGetValue     "DryOut"
 aL                inch                1
 if gkMonoStereo==0 then
  aR               =                   aL
 else
  aR               inch                2
 endif
                   outs                aL * kDryOut, aR * kDryOut
             
 kFFTndx           cabbageGetValue     "FFTsize"             
 gkFFTsize         =                   2 ^ (kFFTndx + 6)
 
 gkRecord          cabbageGetValue     "Record"      ; READ IN CABBAGE WIDGET CHANNELS
 gkPause           cabbageGetValue     "Pause"
 gkPlayLoop        cabbageGetValue     "PlayLoop"
 ;if trigger:k(gkPlayLoop,0.5,0)==1 then
 ;                  event               "i", "DisplayTable", 0, 0
 ;                  turnoff2            "Record", 0, 0
 ;                  cabbageSetValue     "Record", k(0)
 ;endif
 gkPlayOnce        cabbageGetValue     "PlayOnce"
 gkPlayOnceTrig    changed             gkPlayOnce
 gkSpeed           cabbageGetValue     "Speed"
 gkDir             =                   gkSpeed > 0 ? 1 : -1
 gkSpeed           pow                 gkSpeed, 2
 gkPitch           cabbageGetValue     "Pitch"
 gkLoopBeg         cabbageGetValue     "LoopBeg"
 gkLoopEnd         cabbageGetValue     "LoopEnd"
 gkInGain          cabbageGetValue     "InGain"
 gkOutGain         cabbageGetValue     "OutGain"
 kStretch          cabbageGetValue     "Stretch"          ; intervallic stretch on MIDI instrument
 gkStretch         =                   2 ^ kStretch       ;, 0.05 ; create exponentially scaled ratio
 gkLoopShape       cabbageGetValue     "LoopShape"
 gkTuning          cabbageGetValue     "Tuning"
 gkPhaseLock       cabbageGetValue     "PhaseLock"
 gkFreeze          cabbageGetValue     "Freeze"
 
 if changed:k(gkLoopShape)==1 then
                   tablecopy           giLoopShapeTab, gkLoopShape + giRamp - 1
                   cabbageSet          1, "LoopShapeTab", "tableNumber", giLoopShapeTab
 endif

; read soundfiler bounds
iBounds[]          cabbageGet          "Display", "bounds"
iOLX               =                   iBounds[0]
iOLY               =                   iBounds[1]
iOLWidth           =                   iBounds[2]
iOLHeight          =                   iBounds[3]

; Adjust graphical loop overlay
if gkLoopEnd>gkLoopBeg then
 kOLX              limit               iOLX + (gkLoopBeg * iOLWidth), iOLX, iOLX + iOLWidth 
 kOLWid            limit               iOLWidth-(gkLoopBeg*iOLWidth)-((1-gkLoopEnd)*iOLWidth), 0, iOLX + iOLWidth - kOLX 
                   cabbageSet          changed:k(gkLoopBeg,gkLoopEnd), "LoopDisplay", "bounds", kOLX, iOLY, kOLWid, iOLHeight
else
 kOLX              limit               iOLX + (gkLoopEnd * iOLWidth), iOLX, iOLX + iOLWidth 
 kOLWid            limit               iOLWidth-(gkLoopEnd*iOLWidth)-((1-gkLoopBeg)*iOLWidth), 0, iOLX + iOLWidth - kOLX 
                   cabbageSet          changed:k(gkLoopBeg,gkLoopEnd), "LoopDisplay", "bounds", kOLX, iOLY, kOLWid, iOLHeight
endif

; Mouse-Move
gkMOUSE_DOWN_LEFT  cabbageGetValue     "MOUSE_DOWN_LEFT"
kMouseMoveFlag     init                0
kMouseX            cabbageGetValue     "MOUSE_X"
kMouseXPrev        init                i(kMouseX)
kMouseY            cabbageGetValue     "MOUSE_Y"
if trigger:k(gkMOUSE_DOWN_LEFT,0.5,0)==1 then
 kMouseMoveFlag    =                   (gkMOUSE_DOWN_LEFT==1 && kMouseX>kOLX && kMouseX<(kOLX+kOLWid) && kMouseY>iOLY  && kMouseY<(iOLY+iOLHeight)) ? 1 : 0
elseif trigger:k(gkMOUSE_DOWN_LEFT,0.5,1)==1 then
 kMouseMoveFlag    =                   0
endif
if kMouseMoveFlag==1 && changed:k(kMouseX - kMouseXPrev)==1 then
                   cabbageSetValue     "LoopBeg", limit:k(gkLoopBeg + (kMouseX-kMouseXPrev)/iOLWidth, 0, 1)
                   cabbageSetValue     "LoopEnd", limit:k(gkLoopEnd + (kMouseX-kMouseXPrev)/iOLWidth, 0, 1)
endif
kMouseXPrev        =                   kMouseX


kYNorm            =                   1 - (kMouseY-iOLY)/iOLHeight
; Mouse to pitch
kY2Pitch cabbageGetValue "Y2Pitch"
if kY2Pitch==1 && gkMOUSE_DOWN_LEFT==1 && kMouseX>=iOLX && kMouseX<=(iOLX+iOLWidth) && kMouseY>=iOLY && kMouseY<=(iOLY+iOLHeight) then
                   cabbageSetValue     "Pitch", scale:k(kYNorm^2, 8.00, 0.125)
endif

; Mouse to speed
kY2Speed cabbageGetValue "Y2Speed"
if kY2Speed==1 && gkMOUSE_DOWN_LEFT==1 && kMouseX>=iOLX && kMouseX<=(iOLX+iOLWidth) && kMouseY>=iOLY && kMouseY<=(iOLY+iOLHeight) then
                   cabbageSetValue     "Speed", scale:k(kYNorm, 8, -8)
endif

; mouse to filters
gkY2Filt           cabbageGetValue     "Y2Filt"
                   cabbageSet          changed:k(gkY2Filt), "LPFRes", "visible", gkY2Filt
                   cabbageSet          changed:k(gkY2Filt), "HPFRes", "visible", gkY2Filt
; filter parameters (right-click mouse click-and-drag Y axis over file panel)
kLPF_CF            scale               (kYNorm * 2), 14, 4
kLPF_CF            limit               kLPF_CF, 4, 14
gkLPF_CF           port                kLPF_CF, 0.05
kHPF_CF            scale               (kYNorm * 2) - 1, 14, 4
kHPF_CF            limit               kHPF_CF, 4, 14
gkHPF_CF           port                kHPF_CF, 0.05



#define    TURN_ON(NAME)
#
i$NAME             nstrnum             "$NAME"
kOnTrig$NAME       trigger             gk$NAME,0.5,0
if kOnTrig$NAME==1 then                                   ; IF BUTTON IS TURNED ON...
                   event               "i",i$NAME,0,3600
endif
#
$TURN_ON(Record)
$TURN_ON(PlayOnce)
$TURN_ON(PlayLoop)
endin




instr    Record
if gkPause=1 goto SKIP_RECORD                ; IF PAUSE BUTTON IS ACTIVATED TEMPORARILY SKIP RECORDING PROCESS
if gkMonoStereo==1 then
 ainL,ainR         ins                       ; READ AUDIO FROM LIVE INPUT CHANNEL 1
else
 ainL              inch                1     ; READ AUDIO FROM LIVE INPUT CHANNEL 1
 ainR              =                   ainL
endif
    
;MACRO THAT DEFINES THE CODE NEEDED TO RECORD A SINGLE CHANNEL PVS BUFFER
#define    REC_BUF(CHAN)
#
iFFTsize           =                   i(gkFFTsize)
ioverlap           =                   i(gkFFTsize)/8
iwinsize           =                   i(gkFFTsize)
iwintype           =                   1
;kPhOffset         =                   0
f_anal$CHAN        pvsanal             ain$CHAN, iFFTsize, ioverlap, iwinsize, iwintype ; ANALYSE THE LEFT CHANNEL AUDIO. OUTPUT AN F-SIGNAL.
ibuf$CHAN,ktime    pvsbuffer           f_anal$CHAN, gibuflen                            ; BUFFER FSIG
gkhandle$CHAN      init                ibuf$CHAN                                        ; INITIALISE HANDLE TO BUFFER
#
;EXPAND BUFFER TWICE, ONCE FOR EACH STEREO CHANNEL
$REC_BUF(L)
$REC_BUF(R)
gkRecDur           timeinsts           ; DURATION OF CURRENT RECORDING
if gkRecDur>=gibuflen then             ; IF BUFFER IS FULL (I.E. DO NOT OVERWRITE THE BEGINNING OF THE BUFFER
                   turnoff             ; TURN OFF THIS INSTRUMENT
endif                                  ; ENDO OF THIS CONDITIONAL BRANCH

; CREATE DISPLAY TABLE
                   tablew              ainL, a(ktime)*sr, giBuffer
; call instr 99 to set up display table
                   schedkwhen          release:k(), 0, 0, "DisplayTable", 0, 0, ktime*sr

if gkRecord==0 then                    ; IF BUTTON IS TURNED OFF...
                   turnoff
endif

SKIP_RECORD:                           ; JUMP TO HERE WHEN 'PAUSE' BUTTON IS ACTIVE
endin




instr DisplayTable ; create display 
iRecDur            =                   p4             ; duration of recording in sample frames
                   CreateDisplayTable  giDisplay, giBuffer, iRecDur
                   cabbageSet          "Display", "tableNumber", giDisplay
endin







instr    PlayLoop
idefault           =                   1
iMIDI              =                   0
                   mididefault         idefault, iMIDI ; ivalue overwritten by idefault if MIDI driven
if iMIDI==1 then ; MIDI
 iUnison           cabbageGetValue     "Unison"
 icps              cpstmid             giTTable1 + cabbageGetValue:i("Tuning") - 1
 iMidiNote         =                   ftom:i(icps)
 kStretch          cabbageGetValue     "Stretch"
 kMidiNote         =                   ((iMidiNote-iUnison) * kStretch) + iUnison
 kPitch            =                   cpsmidinn(kMidiNote)/cpsmidinn(iUnison)
 ivel              ampmidi             1       ; read in midi velocity (as a value within the range 0 - 1)
 
else              ; non-MIDI
 if gkPlayLoop==0 then
                   turnoff
 endif
 kPitch            =                   gkPitch
 ivel              =                   1 
endif

if gkPause=1 goto SKIP_PLAY_LOOP                                                    ; IF PAUSE BUTTON IS ACTIVATED SKIP PLAYBACK CODE

; AMPLITUDE ENELOPE
iAttTim            cabbageGetValue     "AttTim"                          ; read in widgets
iRelTim            cabbageGetValue     "RelTim"
aenv               transegr            0, iAttTim, -4, 1, iRelTim, -4, 0 ; interpolate and create a-rate enelope

kporttime          linseg              0,0.001,0.05                                 ; PORTAMENTO TIME RAMPS UP RAPIDLY TO A HELD VALUE
kLoopBeg           portk               gkLoopBeg, kporttime                         ; APPLY PORTAMENTO SMOOTHING TO CHANGES OF LOOP BEGIN SLIDER
kLoopEnd           portk               gkLoopEnd, kporttime                         ; APPLY PORTAMENTO SMOOTHING TO CHANGES OF LOOP END SLIDER
kLoopBeg           =                   kLoopBeg * gkRecDur                          ; RESCALE gkLoopBeg (RANGE 0-1) TO BE WITHIN THE RANGE 0-FILE_LENGTH.
kLoopEnd           =                   kLoopEnd * gkRecDur                          ; RESCALE gkLoopEnd (RANGE 0-1) TO BE WITHIN THE RANGE 0-FILE_LENGTH.
kLoopLen           =                   abs(kLoopEnd - kLoopBeg)                     ; DERIVE LOOP LENGTH FROM LOOP START AND END POINTS
kPlayPhasFrq       divz                gkSpeed * (1-gkFreeze), kLoopLen, 0          ; SAFELY DIVIDE, PROVIDING ALTERNATIVE VALUE IN CASE DENOMINATOR IS ZERO 
kPhasor            oscilikt            1, gkDir*kPlayPhasFrq * (gkLoopShape == 1 ? 1 : 0.5), gkLoopShape + giRamp - 1

kPlayNdx           =                   (kPhasor * kLoopLen) + kLoopBeg               ; RESCALE INDEX POINTER ACCORDING TO LOOP LENGTH AND LOOP BEGINING

; move wiper
iDTBounds[]        cabbageGet          "Display", "bounds"
iDTX               =                   iDTBounds[0]
iDTY               =                   iDTBounds[1]
iDTWid             =                   iDTBounds[2]
iDTHei             =                   iDTBounds[3]
kPhasor            =                   gkLoopEnd > gkLoopBeg ? kPhasor : (1 - kPhasor)
kPtr               =                   kPhasor * (gkLoopEnd - gkLoopBeg) + gkLoopBeg
                   cabbageSet          metro:k(32)*(1 - iMIDI), "Wiper", "bounds", iDTX + iDTWid * kPtr, iDTY, 1, iDTHei

f_bufL             pvsbufread          kPlayNdx , gkhandleL                         ; READ BUFFER
f_scaleL           pvscale             f_bufL, kPitch                               ; RESCALE FREQUENCIES
f_lockL            pvslock             f_scaleL, gkPhaseLock
a1                 pvsynth             f_lockL                                      ; RESYNTHESIZE THE f-SIGNAL AS AN AUDIO SIGNAL    

f_bufR             pvsbufread          kPlayNdx , gkhandleR                         ; READ BUFFER
f_scaleR           pvscale             f_bufR, kPitch                               ; RESCALE FREQUENCIES
f_lockR            pvslock             f_scaleR, gkPhaseLock
a2                 pvsynth             f_lockR                                      ; RESYNTHESIZE THE f-SIGNAL AS AN AUDIO SIGNAL    

; Y Filters
if gkY2Filt==1 then
 kLPFRes           cabbageGetValue     "LPFRes"
 kHPFRes           cabbageGetValue     "HPFRes"
 a1                zdf_2pole           a1, a(cpsoct(gkLPF_CF)), kLPFRes    ; lowpass
 a2                zdf_2pole           a2, a(cpsoct(gkLPF_CF)), kLPFRes
 a1                zdf_2pole           a1, a(cpsoct(gkHPF_CF)), kHPFRes, 1 ; highpass
 a2                zdf_2pole           a2, a(cpsoct(gkHPF_CF)), kHPFRes, 1
endif

; Mouse Gate
aMEnv              interp              SwitchPort:k(gkMOUSE_DOWN_LEFT,cabbageGetValue:k("AttTim"),cabbageGetValue:k("RelTim"))
if cabbageGetValue:k("MouseGate")==1 && iMIDI!=1 then
 a1                *=                  aMEnv
 a2                *=                  aMEnv
endif
                   outs                a1 * gkOutGain * ivel * aenv, a2 * gkOutGain * ivel * aenv ; SEND AUDIO TO OUTPUTS
SKIP_PLAY_LOOP:                                                                                   ; JUMP TO HERE WHEN 'PAUSE' BUTTON IS ACTIVE
endin









instr    PlayOnce
if gkPlayOnce==0 then                                                  ; IF BUTTON IS TURNED OFF...
                   turnoff
endif
if gkPause==1 goto SKIP_PLAY_ONCE                                      ; IF PAUSE BUTTON IS ACTIVATED SKIP PLAYBACK

; AMPLITUDE ENELOPE
iAttTim            cabbageGetValue     "AttTim"                          ; read in widgets
iRelTim            cabbageGetValue     "RelTim"
aenv               transegr            0, iAttTim, -4, 1, iRelTim, -4, 0 ; interpolate and create a-rate enelope

kPlayOnceNdx init 0                                                    ; INITIALISE PLAYBACK POINTER
if kPlayOnceNdx<=gkRecDur then                                         ; IF PLAYBACK IS NOT YET COMPLETED THEN CONTINUE PLAYBACK
 kLoopBeg          =                   gkLoopBeg * gkRecDur            ; RESCALE gkLoopBeg (RANGE 0-1) TO BE WITHIN THE RANGE 0-FILE_LENGTH.
 kLoopEnd          =                   gkLoopEnd * gkRecDur            ; RESCALE gkLoopEnd (RANGE 0-1) TO BE WITHIN THE RANGE 0-FILE_LENGTH.
 kPlayOnceNdx      line                0,1,1                           ; CREATE A MOVING POINTER
 if kLoopEnd>kLoopBeg then                                             ; IF LOOP END SLIDER IS AT A LATER POSITION TO LOOP BEGIN SLIDER...
  kPlayOnceNdx     =                   (kPlayOnceNdx*gkSpeed)+kLoopBeg ; RESCALE MOVING POINTER VALUE ACCORDING TO LOOP BEGIN POSITION AND SPEED SLIDER SETTING
  if kPlayOnceNdx>=kLoopEnd then                                       ; IF PLAY INDEX IS EQUAL TO OR GREATER THAN THE DURATION OF THE RECORDED BUFFER (STOP PLAYBACK)...
   turnoff                                                             ; TURN THIS INSTRUMENT OFF
  endif                                                                ; END OF CONDITIONAL BRANCH
 else                                                                  ; OTHERWISE (I.E. LOOP BEGIN SLIDER IS AT A LATER POSITION THAT LOOP END)
  kPlayOnceNdx     =                   kLoopBeg-(kPlayOnceNdx*gkSpeed) ; RESCALE MOVING POINTER VALUE ACCORDING TO LOOP BEGIN POSITION AND SPEED SLIDER SETTING
  if kPlayOnceNdx<=kLoopEnd then                                       ; IF PLAY POINTER HAS REACHED THE BEGINNING OF THE PRESCRIBED CHUNK BETWEEN LOOP BEGIN AND LOOP END (STOP PLAYBACK)...
                   turnoff                                             ; TURN THIS INSTRUMENT OFF
  endif                                                                ; END OF CONDITIONAL BRANCH
 endif                                                                 ; END OF CONDITIONAL BRANCH
endif
f_bufL             pvsbufread          kPlayOnceNdx , gkhandleL        ; READ BUFFER
f_scaleL           pvscale             f_bufL, gkPitch                 ; RESCALE FREQUENCIES
f_lockL            pvslock             f_scaleL, gkPhaseLock
aL                 pvsynth             f_lockL                         ; RESYNTHESIZE THE f-SIGNAL AS AN AUDIO SIGNAL    

f_bufR             pvsbufread          kPlayOnceNdx , gkhandleR        ; READ BUFFER
f_scaleR           pvscale             f_bufR, gkPitch                 ; RESCALE FREQUENCIES
f_lockR            pvslock             f_scaleR, gkPhaseLock
aR                 pvsynth             f_lockR                         ; RESYNTHESIZE THE f-SIGNAL AS AN AUDIO SIGNAL    

                   outs                aL * gkOutGain * aenv, aR * gkOutGain * aenv ; SEND AUDIO TO OUTPUT
SKIP_PLAY_ONCE:
                   cabbageSetValue     "PlayOnce", 1-release:k(), release:k()
endin



instr 999 ; click for buttons
 aEnv              linseg              0, p3*0.5, 1, p3*0.5, 0
 aCPS              expon               1, p3, 0.6
 aSig              poscil              aEnv*0.05, p4*aCPS
                   outall              aSig
endin

</CsInstruments>

<CsScore>
i 1 0 z
</CsScore>

</CsoundSynthesizer>