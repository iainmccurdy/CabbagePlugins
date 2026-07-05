
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; OstinatorFile
; Written by Iain McCurdy, 2025

; OstinatorFile uses streaming phase vocoding to play back selected fragments of a sound file - ostinati - in various ways.

; Buttons
; OPEN FILE     -   browse for a sound file
; PLAY          -   play buffered audio in a loop

; FFT Size      -   FFT size used by phase vocoding analysis and replay.
;                   Use larger sizes for better frequency resolution, use smaller sizes for better time resolution.

; Decimation    -   number of window overlaps
; Phase Lock    -   lock phases in phase vocoded output

; Loop Shape    -   shape of the pointer used in looping.
;                   shape chosen is revealed in the graph below
;                   choose between: Ramp, Tri (triangle), Half Sine, Gauss or Pinch

; Port          -   lag (portamento) time applied to changes made pitch
; Out Gain      -   Gain control applied all audio exiting the Ostinator

; Speed         -   speed of playback as a ratio of normal playback speed
; Pitch         -   pitch as a ratio of original pitch

; Buffer (in the silver box)
; Above and below the buffer audio waveform display are sliders which will control the loop start and end points.
;  Start and end loop points can be inverted to reverse playback speed.
; The section of the audio buffer that will be looped is shown by a box overlaid on the waveform. 
; This section can be shifted across the waveform by clicking and dragging on it.

; Y TO PITCH    -   If this is active, the vertical position of the mouse over the file viewer (while left click is held)
;                   over the waveform viewer controls pitch.
; Y TO FILTERS  -   If this is active, the vertical position of the mouse over the file viewer 
;                   controls the cutoff frequencies of lowpass and highpass filters
; Y TO SPEED    -   If this is active, the vertical position of the mouse over the file viewer 
;                   controls the speed of playback of the loop

;--- MIDI TO PITCH -   MIDI notes played will be mapped to playback pitch about UNISON PITCH
;--- MIDI TO SPEED -   MIDI notes played will be mapped to playback speed as a ratio to original speed with UNISON PITCH defining normal playback speed 

; UNISON NOTE   -   MIDI note that will produce unison playback

;--- STRETCH       -   intervallic stretch for MIDI-activated notes
; ATTACK        -   amplitude envelope attack time for event both from the PLAY button and MIDI notes
; RELEASE       -   amplitude envelope release time for event both from the PLAY button and MIDI notes
; TUNING        -   tuning system used for MIDI-activated notes

<Cabbage>
form caption("Ostinator") size(870,660), pluginId("Osti") colour(30,30,30), guiMode("queue")

#define DIAL_STYLE       markerStart(0), markerEnd(1.05), markerThickness(0.8), trackerInsideRadius(0.8), trackerColour(0,0,0,0), valueTextBox(1)
#define DIAL_STYLE_SMALL markerStart(0), markerEnd(1.05), markerThickness(0.8), trackerInsideRadius(0.7), trackerColour(0,0,0,0)
#define SLIDER_STYLE     trackerColour("Silver"), valueTextBox(1)
#define SLIDER_STYLE2    trackerColour("Silver"), valueTextBox(0)


image      bounds(  5,  5,140,100), colour(0,0,0,0), outlineThickness(1), corners(7), outlineColour("silver")
{
filebutton bounds( 10, 10,120, 35), text("OPEN FILE","OPEN FILE"), fontColour("white"), channel("filename"), shape("ellipse"), corners(5)
button     bounds( 10, 55,120, 35), text("PLAY","PLAY"), channel("Play"), fontColour:0("white"), fontColour:1("white"), colour:0(20,55,20), colour:1(100,255,100), latched(1), corners(5)
}

groupbox bounds(150,  5,310,100), text("FFT Attributes")
{
label    bounds(  5, 35, 90, 14), text("FFT Size"), fontColour("white")
combobox bounds(  5, 50, 90, 25), channel("FFTsize"), items("128","256","512","1024","2048","4096") value(4)
label    bounds(105, 35, 90, 14), text("Decimation"), fontColour("white")
combobox bounds(105, 50, 90, 25), channel("decim"), text("1", "2", "4", "8", "16"), value(3), fontColour("white")
checkbox bounds(205, 52, 90, 18), channel("PhaseLock"), text("Phase Lock"), value(0), fontColour:0("white"), fontColour:1("white")
}

groupbox bounds(465,  5,100,100), text("Loop")
{
label    bounds( 10, 25, 80, 13), text("Loop Shape")
combobox bounds( 10, 40, 80, 25), channel("LoopShape"), items("Ramp","Tri","Half Sine","Gauss","Pinch") value(1)
gentable bounds( 10, 70, 80, 20), channel("LoopShapeTab"), tableNumber(99), ampRange(0,1,-1), fill(0)
}

groupbox bounds(570,  5,200,100), text("")
{
rslider  bounds( 10, 25, 70, 70), channel("PortTime"), range(0, 0.3, 0.01), text("Port"), $DIAL_STYLE
rslider  bounds(110, 25, 70, 70), channel("OutGain"), range(0, 1, 1, 0.5), text("Out Gain"), $DIAL_STYLE
}

hslider bounds( 10,130,680,20), channel("Speed"), text("Speed"), range(-8.00, 8.00, 1), popupText(0), $SLIDER_STYLE
hslider bounds( 10,170,680,20), channel("Pitch"), text("Pitch"), range(0.125, 8.00, 1, 0.33,0.00001), $SLIDER_STYLE
button  bounds(700,135,150,50), channel("Freeze"), text("FREEZE"), corners(5), colour:0(20,20, 30), colour:1(100,100,250), latched(1), fontColour:0(50,50,100), fontColour:1(225,225,255)

; overlay
image      bounds(  0,210,870,225), colour(0,0,0,0), outlineColour("silver"), outlineThickness(4), corners(5)
hslider    bounds( 10,215,850, 20), channel("LoopBeg"), range(0, 1, 0), popupText(0), $SLIDER_STYLE2
soundfiler bounds( 14,235,842,178), channel("Display"),  colour(0, 255, 255, 255), fontColour(160, 160, 160, 255), 
label      bounds( 16,237,842, 14), text(""), align("left"), colour(0,0,0,0), fontColour(200,200,200), channel("stringbox")

image      bounds( 14,235,842,178), channel("LoopDisplay"), alpha(0.2) ; overlay , colour(255,255,255,50);
image      bounds( 14,235,  1,178), channel("Wiper")
hslider    bounds( 10,410,850, 20), channel("LoopEnd"), range(0, 1, 1), popupText(0), $SLIDER_STYLE2

; keyboard control
image bounds(0,445,870,500), colour(0,0,0,0)
{
checkbox bounds( 10,  5,120, 12), channel("Y2Pitch"), text("Y TO PITCH"), colour:0(0,50,0), value(0)
checkbox bounds( 10, 25,120, 12), channel("Y2Filt"), text("Y TO FILTERS"), colour:0(0,50,0), value(0)
checkbox bounds( 10, 45,120, 12), channel("Y2Speed"), text("Y TO SPEED"), colour:0(0,50,0), value(0)
checkbox bounds( 10, 65, 95, 12), channel("MouseGate"), text("MOUSE GATE"), colour:0(0,50,0), value(0)

rslider  bounds(130,  5, 90, 90), channel("LPFRes"), range(0.5,25,0.5,0.5), text("LPF. RES."), visible(0), $DIAL_STYLE
rslider  bounds(210,  5, 90, 90), channel("HPFRes"), range(0.5,25,0.5,0.5), text("LPF. RES."), visible(0), $DIAL_STYLE

;checkbox bounds(310,  5,120, 12), channel("MIDI2Pitch"), text("MIDI TO PITCH"), colour:0(0,50,0), value(1)
;checkbox bounds(310, 25,120, 12), channel("MIDI2Speed"), text("MIDI TO SPEED"), colour:0(0,50,0)

nslider  bounds(430,  7, 80, 35), channel("Unison"), text("UNISON NOTE"), range(0,127,60,1,.01)

rslider  bounds(510,  5, 90, 90), channel("Stretch"), range(-5,5,0), text("STRETCH"), $DIAL_STYLE
rslider  bounds(590,  5, 90, 90), channel("AttTim"), range(0.01,25, 0.01, 0.5), text("ATTACK"), $DIAL_STYLE
rslider  bounds(670,  5, 90, 90), channel("RelTim"), range(0.01,25, 0.01, 0.5), text("RELEASE"), $DIAL_STYLE

label    bounds(755,  3,110, 13), text("TUNING"), align("centre")
combobox bounds(755, 17,110, 22), channel("Tuning"), text("12-TET", "24-TET", "12-TET rev.", "24-TET rev.", "10-TET", "36-TET", "Just C", "Just C#", "Just D", "Just D#", "Just E", "Just F", "Just F#", "Just G", "Just G#", "Just A", "Just A#", "Just B","Pythagorean C","19 TET","31 TET","Bohlen-Pierce C"), value(1)

keyboard bounds( 10,110,850, 85)
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

                   massign             0, 2

gichans            init                0        ; 
giReady            init                0        ; flag to indicate function table readiness

; Loop Shapes
iFTLen             =                   2 ^ 8
giRamp             ftgen               3, 0, iFTLen, 7, 0, iFTLen, 1 
giTri              ftgen               4, 0, iFTLen, 7, 0, iFTLen/2, 1, iFTLen/2, 0
giHalfSine         ftgen               5, 0, iFTLen, 9, 0.5, 1, 0
giGauss            ftgen               6, 0, iFTLen, 19, 1, 0.5, 270, 0.5
giPinch            ftgen               7, 0, iFTLen, 16, 0, iFTLen/2, 4, 1, iFTLen/2, -4, 0

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

; Author: Iain McCurdy (2025)



gkReady            init                0        ; flag to indicate function table readiness



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
 ; open file
 gSfilepath        cabbageGetValue     "filename"
 kNewFileTrg       changed             gSfilepath    ; if a new file is loaded generate a trigger
 if kNewFileTrg==1 then                              ; if a new file has been loaded...
                   event               "i",99,0,0    ; call instrument to update sample storage function table 
 endif  

 ; trigger play loop instrument 
 gkPlay            cabbageGetValue     "Play"
 if trigger:k(gkPlay,0.5,0)==1 && gkReady==1 then
                   event               "i", 2, 0, -1
 endif

 ; FFT Attributes             
 kFFTndx           cabbageGetValue     "FFTsize"             
 gkFFTsize         =                   2 ^ (kFFTndx + 6)

 gkdecimArr[]      fillarray           1, 2, 4, 8, 16
 gkdecim           =                   gkdecimArr[cabbageGetValue:k("decim") - 1]
 gkdecim           init                4
 
 gkPortTime        cabbageGetValue     "PortTime"
 gkRecord          cabbageGetValue     "Record"      ; READ IN CABBAGE WIDGET CHANNELS
 gkPause           cabbageGetValue     "Pause"
 gkPlayLoop        cabbageGetValue     "PlayLoop"
 gkPlayOnce        cabbageGetValue     "PlayOnce"
 gkPlayOnceTrig    changed             gkPlayOnce
 gkSpeed           cabbageGetValue     "Speed"
 gkSpeed           pow                 gkSpeed, 2
 gkPitch           cabbageGetValue     "Pitch"
 gkPitch           portk               gkPitch, gkPortTime
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
 
 ; loop shape table
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


endin




instr    99    ; load sound file
 gichans           filenchnls          gSfilepath               ; derive the number of channels (mono=1,stereo=2) in the sound file
 gitableL          ftgen               1,0,0,1,gSfilepath,0,0,1
 if gichans==2 then
  gitableR         ftgen               2,0,0,1,gSfilepath,0,0,2
 else
  gitableR         ftgen               2,0,0,1,gSfilepath,0,0,1 ; if input is mono, right table is simply a copy of the mono input file  
 endif
 gkReady           init                1                        ; if no string has yet been loaded giReady will be zero
 gkFileLen         init                ftlen(1)
 
                   cabbageSet          "Display", "file", gSfilepath

  /* write file name to GUI */
 SFileNoExtension  cabbageGetFileNoExtension gSfilepath
                   cabbageSet          "stringbox","text",SFileNoExtension

endin





instr    2
idefault           =                   1
iMIDI              =                   0
                   mididefault         idefault, iMIDI ; ivalue overwritten by idefault if MIDI driven
if iMIDI==1 then ; MIDI
 iUnison           cabbageGetValue     "Unison"
 icps              cpstmid             giTTable1 + cabbageGetValue:i("Tuning") - 1
 iPchRto           =                   icps/cpsmidinn(iUnison)
 kStretch          cabbageGetValue     "Stretch"
 kPitch            =                   iPchRto ^ (2^kStretch)
 ivel              ampmidi             1       ; read in midi velocity (as a value within the range 0 - 1)
 
else              ; non-MIDI
if gkPlay==0 then                              ; IF 'PLAY LOOPED' BUTTON IS INACTIVE...
                   turnoff                     ; TURN THIS INSTRUMENT OFF
endif                                          ; END OF THIS CONDITIONAL BRANCH
 kPitch            =                   gkPitch
 ivel              =                   1
endif



; AMPLITUDE ENELOPE
iAttTim            cabbageGetValue     "AttTim"               ; read in widgets
iRelTim            cabbageGetValue     "RelTim"
aenv               transegr            0, iAttTim, -4, 1, iRelTim, -4, 0 ; interpolate and create a-rate enelope


iFileLen           =                   ftlen(gitableL) / ftsr(gitableL)             ; file length in seconds

kRamp              linseg              0, 0.01, 1
kPortTime          =                   kRamp * gkPortTime

kLoopBeg           portk               gkLoopBeg, kPortTime                         ; APPLY PORTAMENTO SMOOTHING TO CHANGES OF LOOP BEGIN SLIDER
kLoopEnd           portk               gkLoopEnd, kPortTime                         ; APPLY PORTAMENTO SMOOTHING TO CHANGES OF LOOP END SLIDER
kLoopBeg           =                   kLoopBeg * iFileLen                          ; RESCALE gkLoopBeg (RANGE 0-1) TO BE WITHIN THE RANGE 0-FILE_LENGTH.
kLoopEnd           =                   kLoopEnd * iFileLen                          ; RESCALE gkLoopEnd (RANGE 0-1) TO BE WITHIN THE RANGE 0-FILE_LENGTH.
kLoopLen           =                   abs(kLoopEnd - kLoopBeg)                     ; DERIVE LOOP LENGTH FROM LOOP START AND END POINTS
kPlayPhasFrq       divz                gkSpeed * (1-gkFreeze), kLoopLen, 0          ; SAFELY DIVIDE, PROVIDING ALTERNATIVE VALUE IN CASE DENOMINATOR IS ZERO 
kDir               =                   gkLoopEnd > gkLoopBeg ? 1 : -1
kPhasor            oscilikt            1, kPlayPhasFrq * (gkLoopShape == 1 ? 1 : 0.5) * kDir, gkLoopShape + giRamp - 1
kPlayNdx           =                   (kPhasor * kLoopLen) + kLoopBeg               ; RESCALE INDEX POINTER ACCORDING TO LOOP LENGTH AND LOOP BEGINING

; move wiper
iDTBounds[]        cabbageGet          "Display", "bounds"
iDTX               =                   iDTBounds[0]
iDTY               =                   iDTBounds[1]
iDTWid             =                   iDTBounds[2]
iDTHei             =                   iDTBounds[3]
kPtr               =                   gkLoopEnd > gkLoopBeg ? (kPhasor * (gkLoopEnd - gkLoopBeg) + gkLoopBeg) : kPhasor * (gkLoopBeg - gkLoopEnd) + gkLoopEnd
                   cabbageSet          metro:k(32)*(1-iMIDI), "Wiper", "bounds", iDTX + iDTWid * kPtr, iDTY, 1, iDTHei

kOutGain           portk               gkOutGain, kPortTime
if changed:k(gkFFTsize,gkdecim)==1 then
                   reinit              RESTART
endif
RESTART:
a1                 mincer              a(kPlayNdx), kOutGain, kPitch,  gitableL, gkPhaseLock, i(gkFFTsize), i(gkdecim)
a2                 mincer              a(kPlayNdx), kOutGain, kPitch,  gitableR, gkPhaseLock, i(gkFFTsize), i(gkdecim)
rireturn

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

                   outs                a1 * aenv * ivel, a2 * aenv * ivel
endin


</CsInstruments>

<CsScore>
i 1 0 z
</CsScore>

</CsoundSynthesizer>