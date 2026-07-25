
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; Flooper2FilePlayer.csd
; Written by Iain McCurdy, 2014

; Load a user selected sound file into a GEN 01 function table and plays it back using flooper2. 
; This file player is best suited for polyphonic playback and is less well suited for the playback of very long sound files .
; A sound file can be loaded either via the Open File button and browsing or by simply dropping a file onto the GUI window.
 
; The sound file can be played back using the Play/Stop button (and the 'Transpose' / 'Speed' buttons to implement pitch/speed change)
;  or it can be played back using the MIDI keyboard.
; 
; The loop points can be set either by using the loop 'Start' and 'End' sliders or by clicking and dragging on the waveform view -
;  - flooper2 will take the values from the last control input moved.

<Cabbage>
form caption("Flooper2 File Player") size(1245,470), colour( 35, 45, 45) pluginId("FlFP"), guiMode("queue")
#define SLIDER_STYLE colour(35, 45, 45), textColour("white"), trackerColour(175,130,110), valueTextBox(1), fontColour("white")
#define VSLIDER_STYLE colour(235, 245, 245), textColour("white"), trackerColour(175,130,110), valueTextBox(1), fontColour("white")

soundfiler bounds(  5, 15,1235,175), channel("beg","len"),  colour(0, 255, 255, 255), fontColour(160, 160, 160, 255), 
label      bounds(  6, 16, 560, 14), text(""), align("left"), colour(0,0,0,0), fontColour(200,200,200), channel("stringbox")
image      bounds(  5, 15,1235,175), alpha(0.25), channel("LoopRegion"), colour(200,200,255)
image      bounds(  5, 15,   1,175), alpha(0.5), channel("InSkipWiper"), colour("lime")
hslider    bounds(  0,  5,1235, 15), channel("LoopStart"), range(0, 1, 0,1,0.001), popupText(0), trackerColour(210,210,250)
hslider    bounds(  0,185,1235, 15), channel("LoopEnd"),   range(0, 1, 1,1,0.001), popupText(0), trackerColour(210,210,250)
hslider    bounds(  0,200,1235, 15), channel("inskip"),    range(0, 1.00, 0),      popupText(0), trackerColour(210,210,250), colour("lime")

image    bounds(  5,220, 220,115), colour(0,0,0,0), outlineColour("silver"), outlineThickness(2), corners(5)
{
filebutton bounds( 10, 25, 80, 25), text("Open File","Open File"), fontColour("white") channel("filename"), shape("ellipse")
checkbox   bounds( 10, 60, 95, 25), channel("PlayStop"), text("Play/Stop"), colour("yellow"), fontColour:0("white"), fontColour:1("white")

label      bounds(115, 22, 80, 12), text("Looping Mode"), fontColour("white"), align("centre")
combobox   bounds(115, 35, 80, 20), channel("mode"), items("Forward", "Backward", "Fwd./Bwd."), value(1), fontColour("white")
checkbox   bounds(115, 65,110, 14), channel("Y2Trans"), text("Y to Trans."), value(0), fontColour:0("white"), fontColour:1("white")
checkbox   bounds(115, 85,110, 14), channel("Y2Filt"), text("Y to Filts."), value(0), fontColour:0("white"), fontColour:1("white")
}

image      bounds(230,220, 250,115), colour(0,0,0,0), outlineColour("silver"), outlineThickness(2), corners(5)
{
rslider    bounds(  0, 18, 90, 90), channel("crossfade"), range(0, 1.00, 0.01,0.5), text("Fade"), $SLIDER_STYLE
rslider    bounds( 80, 18, 90, 90), channel("LoopPort"), range(0, 1.00, 0.02, 0.5), text("Loop Port."), $SLIDER_STYLE
rslider    bounds(160, 18, 90, 90), channel("TransPort"), range(0, 1.00, 0.05, 0.5), text("Trans. Port."), $SLIDER_STYLE
}

image      bounds(485,220,170,115), colour(0,0,0,0), outlineColour("silver"), outlineThickness(2), corners(5)
{
label      bounds(  0,  4,170, 11), text("S   P   E   E   D"), fontColour("white"), align("centre")
rslider    bounds(  0, 18, 90, 90), channel("transpose"), range(-36, 36, 0,1,1),   text("Transpose"), $SLIDER_STYLE
rslider    bounds( 80, 18, 90, 90), channel("speed"),     range(0.125, 8, 1, 0.5), text("Speed"), $SLIDER_STYLE
}

image      bounds(660,220,170,115), colour(0,0,0,0), outlineColour("silver"), outlineThickness(2), corners(5)
{
label      bounds(  0,  4,170, 11), text("E  N  V  E  L  O  P  E"), fontColour("white"), align("centre")
rslider    bounds(  0, 18, 90, 90), channel("AttTim"),    range(0, 5, 0, 0.5, 0.001),       text("Att.Tim"), $SLIDER_STYLE
rslider    bounds( 80, 18, 90, 90), channel("RelTim"),    range(0.01, 5, 0.05, 0.5, 0.001), text("Rel.Tim"), $SLIDER_STYLE
}

image      bounds(835,220,330,115), colour(0,0,0,0), outlineColour("silver"), outlineThickness(2), corners(5)
{
label      bounds(  0,  4,330, 11), text("F  I  L  T  E  R  S"), fontColour("white"), align("centre")
rslider    bounds(  0, 18, 90, 90), channel("LPF_CF"),  range(  4,  14, 4), text("LPF CF."), $SLIDER_STYLE
rslider    bounds( 80, 18, 90, 90), channel("LPFRes"), range(0.5, 25, 0.5), text("LPF Res."), $SLIDER_STYLE
rslider    bounds(160, 18, 90, 90), channel("HPF_CF"),  range(  4,  14, 4), text("LPF"), $SLIDER_STYLE
rslider    bounds(240, 18, 90, 90), channel("HPFRes"), range(0.5, 25, 0.5), text("HPF Res."), $SLIDER_STYLE
}

image      bounds(1170,220, 70,235), colour(0,0,0,0), outlineColour("silver"), outlineThickness(2), corners(5)
{
vslider    bounds(0,  5, 70, 220), channel("level"),     range(  0,  3.00, 1, 0.5),     text("Level"), $VSLIDER_STYLE
}

image      bounds(835,340,330,115), colour(0,0,0,0), outlineColour("silver"), outlineThickness(2), corners(5)
{
label      bounds(  0,  4,330, 11), text("C   O   N   T   R   O   L"), fontColour("white"), align("centre")
rslider    bounds(  0, 18, 90, 90), channel("MidiRef"),   range(0,127,60, 1, .01),         text("MIDI Ref."), $SLIDER_STYLE
rslider    bounds( 80, 18, 90, 90), channel("PchBnd"),     range(  0,  24.00, 2, 1.0.1), text("Bend Range"), $SLIDER_STYLE

label      bounds( 160, 23, 83, 13), text("Tuning"), fontColour("White")
combobox   bounds( 160, 40, 83, 22), channel("Tuning"), items("12-TET", "24-TET", "12-TET rev.", "24-TET rev.", "10-TET", "36-TET", "Just C", "Just C#", "Just D", "Just D#", "Just E", "Just F", "Just F#", "Just G", "Just G#", "Just A", "Just A#", "Just B"), value(1),fontColour("white")
checkbox   bounds( 160, 70,100, 15), channel("Legato"), text("Legato"), colour("yellow"), fontColour:0("white"), fontColour:1("white"), colour:0( 90, 90,0), colour:1(255,255,0), corners(3)
rslider    bounds( 240, 15, 90, 90), channel("LegTime"),  range(  0.01,2.00,1, 0.5), text("Legato Time"), valueTextBox(1), $SLIDER_STYLE, active(0), alpha(0.3)
}


image      bounds(  5,340,825,115), colour(0,0,0,0), outlineColour("silver"), outlineThickness(2), corners(5)
{
keyboard   bounds( 10, 15,805, 85)
}

label    bounds(  5,456,120, 12), text("Iain McCurdy |2014|"), align("left"), fontColour("silver")

</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-n -+rtmidi=NULL -M0 -dm0
</CsOptions>

<CsInstruments>

; sr set by host
ksmps              =                   64
nchnls             =                   2
0dbfs              =                   1

                   massign             0,3
gichans            init                0
giReady            init                0
gSfilepath         init                ""

gitableL           ftgen               1,0,2,2,0
gkTabLen           init                ftlen(gitableL)

; tuning tables
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


opcode    sspline,k,Kiii
    kdur,istart,iend,icurve xin                                                                ; READ IN INPUT ARGUMENTS
    imid     =                         istart+((iend-istart)/2)                                ; SPLINE MID POINT VALUE
    isspline ftgentmp                  0,0,4096,-16,istart,4096*0.5,icurve,imid,(4096/2)-1,-icurve,iend ; GENERATE 'S' SPLINE
    kspd           =                   i(kdur)/kdur                                            ; POINTER SPEED AS A RATIO (WITH REFERENCE TO THE ORIGINAL DURATION)
    kptr           init                0                                                       ; POINTER INITIAL VALUE    
    kout           tablei              kptr,isspline                                           ; READ VALUE FROM TABLE
    kptr           limit               kptr+((ftlen(isspline)/(i(kdur)*kr))*kspd), 0, ftlen(isspline)-1 ; INCREMENT THE POINTER BY THE REQUIRED NUMBER OF TABLE POINTS IN ONE CONTROL CYCLE AND LIMIT IT BETWEEN FIRST AND LAST TABLE POINT - FINAL VALUE WILL BE HELD IF POINTER ATTEMPTS TO EXCEED TABLE DURATION
                   xout                kout                                                    ; SEND VALUE BACK TO CALLER INSTRUMENT
endop




instr    1 ; always on
 gkmode            cabbageGetValue     "mode"
 kLoopPort         cabbageGetValue     "LoopPort" 
 kTransPort        cabbageGetValue     "TransPort"
 gkLoopStart       cabbageGetValue     "LoopStart"
 gkLoopEnd         cabbageGetValue     "LoopEnd"
 gkinskip          cabbageGetValue     "inskip"
 gkY2Filt          cabbageGetValue     "Y2Filt"
 
 
 ; read soundfiler bounds
 iBounds[]         cabbageGet          "beg", "bounds"
 iOLX              =                   iBounds[0]
 iOLY              =                   iBounds[1]
 iOLWidth          =                   iBounds[2]
 iOLHeight         =                   iBounds[3]
 
 ; Adjust graphical loop overlay according to start/end settings
 if gkLoopEnd>gkLoopStart then
  kOLX             limit               iOLX + (gkLoopStart * iOLWidth), iOLX, iOLX + iOLWidth 
  kOLWid           limit               iOLWidth-(gkLoopStart*iOLWidth)-((1-gkLoopEnd)*iOLWidth), 0, iOLX + iOLWidth - kOLX 
                   cabbageSet          changed:k(gkLoopStart,gkLoopEnd), "LoopRegion", "bounds", kOLX, iOLY, kOLWid, iOLHeight
 else
  kOLX             limit               iOLX + (gkLoopEnd * iOLWidth), iOLX, iOLX + iOLWidth 
  kOLWid           limit               iOLWidth-(gkLoopEnd*iOLWidth)-((1-gkLoopStart)*iOLWidth), 0, iOLX + iOLWidth - kOLX 
                   cabbageSet          changed:k(gkLoopStart,gkLoopEnd), "LoopRegion", "bounds", kOLX, iOLY, kOLWid, iOLHeight
 endif

 ; Adjust inskip wiper
                   cabbageSet          changed:k(gkinskip), "InSkipWiper", "bounds", iBounds[0] + (gkinskip * iBounds[2]), iBounds[1], 1, iBounds[3]

; Mouse-Move start/end
 kMOUSE_DOWN_LEFT  cabbageGetValue     "MOUSE_DOWN_LEFT"
 kMouseMoveFlag    init                0
 kMouseX           cabbageGetValue     "MOUSE_X"
 kMouseXPrev       init                i(kMouseX)
 kMouseY           cabbageGetValue     "MOUSE_Y"
 if trigger:k(kMOUSE_DOWN_LEFT,0.5,0)==1 then
  kMouseMoveFlag   =                   (kMOUSE_DOWN_LEFT==1 && kMouseX>kOLX && kMouseX<(kOLX+kOLWid) && kMouseY>iOLY  && kMouseY<(iOLY+iOLHeight)) ? 1 : 0
 elseif trigger:k(kMOUSE_DOWN_LEFT,0.5,1)==1 then
  kMouseMoveFlag   =                   0
 endif
 if kMouseMoveFlag==1 && changed:k(kMouseX - kMouseXPrev)==1 then
                   cabbageSetValue     "LoopStart", limit:k(gkLoopStart + (kMouseX-kMouseXPrev)/iOLWidth, 0, 1)
                   cabbageSetValue     "LoopEnd", limit:k(gkLoopEnd + (kMouseX-kMouseXPrev)/iOLWidth, 0, 1)
 endif
 kMouseXPrev       =                   kMouseX

; mouse to transpose
kYNorm             limit               1 - ((kMouseY-iBounds[1]) / iBounds[3]), 0, 1
if kMOUSE_DOWN_LEFT==1 && cabbageGetValue:k("Y2Trans")==1 then
                   cabbageSetValue     "transpose", scale:k(kYNorm,36,-36), changed:k(kYNorm)
endif

  ; filter parameters (right-click mouse click-and-drag Y axis over file panel)
  kLPF_CF          scale               (kYNorm * 2), 14, 4
  kLPF_CF          limit               kLPF_CF, 4, 14
  kHPF_CF          scale               (kYNorm * 2) - 1, 14, 4
  kHPF_CF          limit               kHPF_CF, 4, 14
                   cabbageSetValue     "LPF_CF", kLPF_CF, changed:k(kLPF_CF) * gkY2Filt
                   cabbageSetValue     "HPF_CF", kHPF_CF, changed:k(kHPF_CF) * gkY2Filt
  gkLPF_CF         port                kLPF_CF, 0.05
  gkHPF_CF         port                kHPF_CF, 0.05

  
 gkLoopEnd         limit               gkLoopEnd,gkLoopStart+0.01,1    ; limit loop end to prevent crashes
 gkcrossfade       cabbageGetValue     "crossfade"
 gkPlayStop        cabbageGetValue     "PlayStop"
 gktranspose       cabbageGetValue     "transpose"
 gkspeed           cabbageGetValue     "speed"
 gkPchBndRng       cabbageGetValue      "PchBnd"
 gklevel           cabbageGetValue     "level"

 ; load file from browse
 gSfilepath        cabbageGetValue     "filename"  ; read in file path string from filebutton widget
 if changed:k(gSfilepath)==1 then                  ; call instrument to update waveform viewer  
  event "i",99,0,0
 endif

 ; load file from dropped file
 gSDropFile        cabbageGet          "LAST_FILE_DROPPED" ; file dropped onto GUI
 if (changed(gSDropFile) == 1) then
                   event               "i",100,0,0         ; load dropped file
 endif
 
 ktrig             trigger             gkPlayStop,0.5,0  ; if play button changes to 'play', generate a trigger
                   schedkwhen          ktrig,0,0,2,0,-1  ; start instr 2 playing a held note

 ktrig1            changed             gktranspose       ; if 'transpose' button is changed generate a '1' trigger
 ktrig2            changed             gkspeed           ; if 'speed' button is changed generate a '1' trigger
 
 if ktrig1==1 then                                   ; if transpose control has been changed...
                   cabbageSetValue     "speed",semitone(gktranspose),k(1)    ; set speed according to transpose value
 elseif ktrig2==1 then                               ; if speed control has been changed...
                   cabbageSetValue     "transpose",log2(gkspeed)*12,k(1)    ; set transpose control according to speed value
 endif

 ; activate legato time control
 kLegato           cabbageGetValue     "Legato"
                   cabbageSet          changed:k(kLegato), "LegTime", "active", kLegato
                   cabbageSet          changed:k(kLegato), "LegTime", "alpha", 0.5 + kLegato*0.5

 ; portamento
 gkLoopStart       portk               gkLoopStart, kLoopPort
 gkLoopEnd         portk               gkLoopEnd, kLoopPort
 gkspeed           portk               gkspeed, kTransPort

endin



instr    99    ; load sound file
 gichans           filenchnls          gSfilepath               ; derive the number of channels (mono=1,stereo=2) in the sound file
 gitableL          ftgen               1,0,0,1,gSfilepath,0,0,1
 giFileLen         filelen             gSfilepath               ; derive the file duration
 gkTabLen          init                ftlen(gitableL)          ; table length in sample frames
 if gichans==2 then
  gitableR         ftgen               2,0,0,1,gSfilepath,0,0,2
 endif
 giReady           =                   1                        ; if no string has yet been loaded giReady will be zero

                   cabbageSet          "beg", "file", gSfilepath

 /* write file name to GUI */
 SFileNoExtension  cabbageGetFileNoExtension gSfilepath
                   cabbageSet          "stringbox","text",SFileNoExtension

endin

instr    100 ; LOAD DROPPED SOUND FILE
 gichans           filenchnls          gSDropFile                 ; derive the number of channels (mono=1,stereo=2) in the sound file
 gitableL          ftgen               1,0,0,1,gSDropFile,0,0,1
 giFileLen         filelen             gSDropFile                 ; derive the file duration in seconds
 gkTabLen          init                ftlen(gitableL)            ; table length in sample frames
 if gichans==2 then
  gitableR         ftgen               2,0,0,1,gSDropFile,0,0,2
 endif
 giReady           =                   1                          ; if no string has yet been loaded giReady will be zero
                   cabbageSet          "beg","file",gSDropFile

 ; write file name to GUI
 SFileNoExtension  cabbageGetFileNoExtension gSDropFile
                   cabbageSet          "stringbox", "text", SFileNoExtension
endin


instr    2    ; sample triggered by 'play/stop' button
 if gkPlayStop==0 then
  turnoff
 endif
 ktrig             changed             gkmode
 if ktrig==1 then
  reinit RESTART
 endif
 RESTART:
 if giReady = 1 then                                      ; i.e. if a file has been loaded
  iAttTim           cabbageGetValue    "AttTim"               ; read in widgets
  iRelTim           cabbageGetValue    "RelTim"
  if iAttTim>0 then                                       ; is amplitude envelope attack time is greater than zero...
   kenv            linsegr             0,iAttTim,1,iRelTim,0  ; create an amplitude envelope with an attack, a sustain and a release segment (senses realtime release)
  else
   kenv            linsegr             1,iRelTim,0            ; create an amplitude envelope with a sustain and a release segment (senses realtime release)
  endif
  kenv             expcurve            kenv,8                 ; remap amplitude value with a more natural curve
  aenv             interp              kenv                   ; interpolate and create a-rate envelope
  kporttime        linseg              0,0.001,0.05           ; portamento time function. (Rises quickly from zero to a held value.)
  kspeed           portk               gkspeed,kporttime      ; apply portamento smoothing to changes in speed
  klevel           portk               gklevel,kporttime      ; apply portamento smoothing to changes in level
  kcrossfade       =                   0.01
  istart           =                   0
  ifenv            =                   0
  iskip            =                   0
  if gichans==1 then                                      ; if mono...
   a1              flooper2            klevel,kspeed, gkLoopStart*giFileLen, gkLoopEnd*giFileLen, gkcrossfade, gitableL, i(gkinskip)*giFileLen, i(gkmode)-1, ifenv, iskip
   a2              =                   a1
  elseif gichans==2 then                                  ; otherwise, if stereo...
   a1              flooper2            klevel,kspeed, gkLoopStart*giFileLen, gkLoopEnd*giFileLen, gkcrossfade, gitableL, i(gkinskip)*giFileLen, i(gkmode)-1, ifenv, iskip
   a2              flooper2            klevel,kspeed, gkLoopStart*giFileLen, gkLoopEnd*giFileLen, gkcrossfade, gitableR, i(gkinskip)*giFileLen, i(gkmode)-1, ifenv, iskip
  endif               
   if gkY2Filt==1 then
    kLPFRes        cabbageGetValue     "LPFRes"
    kHPFRes        cabbageGetValue     "HPFRes"
    a1             zdf_2pole           a1, a(cpsoct(gkLPF_CF)), kLPFRes    ; lowpass
    a2             zdf_2pole           a2, a(cpsoct(gkLPF_CF)), kLPFRes
    a1             zdf_2pole           a1, a(cpsoct(gkHPF_CF)), kHPFRes, 1 ; highpass
    a2             zdf_2pole           a2, a(cpsoct(gkHPF_CF)), kHPFRes, 1
   endif
                   outs                a1 * aenv, a2 * aenv   ; send mono audio to both outputs     ; Y Filters
 endif
endin


instr  3 ;  receive MIDI notes
 iTuning           cabbageGetValue     "Tuning"
 icps              cpstmid             giTTable1 + iTuning - 1    
    iamp           =                   1
    gkcps          =                   icps
    gkamp          init                iamp
    gilegato       cabbageGetValue     "Legato"
    if gilegato==0 then                                                  ; if we are *not* in legato mode...
     aL,aR         subinstr p1+1, icps, iamp
                   outs                aL, aR
    else                                                                 ; otherwise... (i.e. legato mode)
     if active:i(p1)==1 then                                             ; first note...
                   event_i             "i", p1 + 1, 0, 3600, icps, iamp  ; ...start a new held note
     endif
    endif
    
    gkPchBnd       pchbend             0, 1                   ; read in pitch bend

endin


instr    4    ; sample triggered by midi note
 ; poly/legato
 if gilegato==0 then ; polyphonic
  kcps             init                p4
  kamp             init                p5
  
 else                ; monophonic
  kcps  init  i(gkcps)
  if changed:k(active:k(p1-1))==1 then ; if held notes changes...
                   reinit              RESTART_GLISS
  endif
  RESTART_GLISS:
  iLegTime         cabbageGetValue     "LegTime"
  kcps             sspline             iLegTime, i(kcps), i(gkcps), 3
  rireturn
  kamp             init                p5
  if active:k(p1-1)==0 then
                   turnoff
  endif
 endif

 ;icps             cpsmidi                                      ; read in midi note data as cycles per second
 ;iamp             ampmidi             1                        ; read in midi velocity (as a value within the range 0 - 1)
 gkPchBnd          *=                  gkPchBndRng
 iMidiRef          cabbageGetValue     "MidiRef"

 if giReady = 1 then                                            ; i.e. if a file has been loaded
  iAttTim          cabbageGetValue     "AttTim"                 ; read in widgets
  iRelTim          cabbageGetValue     "RelTim"
  if iAttTim>0 then                                             ; is amplitude envelope attack time is greater than zero...
   kenv            linsegr             0,iAttTim,1,iRelTim,0    ; create an amplitude envelope with an attack, a sustain and a release segment (senses realtime release)
  else
   kenv            linsegr             1,iRelTim,0              ; create an amplitude envelope with a sustain and a release segment (senses realtime release)
  endif
  kenv             expcurve            kenv,8                   ; remap amplitude value with a more natural curve
  aenv             interp              kenv                     ; interpolate and create a-rate envelope
  kporttime        linseg              0,0.001,0.05             ; portamento time function. (Rises quickly from zero to a held value.)
  klevel           portk               gklevel,kporttime        ; apply portamento smoothing to changes in level
  kPchBnd          portk               gkPchBnd, kporttime
  kcrossfade       =                   0.01
  istart           =                   0
  ifenv            =                   0
  iskip            =                   0
  if gichans==1 then                                          ; if mono...
   a1              flooper2            klevel*kamp,(kcps*semitone:k(kPchBnd))/cpsmidinn(iMidiRef), gkLoopStart*giFileLen, gkLoopEnd*giFileLen, gkcrossfade, gitableL, i(gkinskip)*giFileLen, i(gkmode)-1, ifenv, iskip
                   outs                a1*aenv,a1*aenv            ; send mono audio to both outputs 
  elseif gichans==2 then                                      ; otherwise, if stereo...
   a1              flooper2            klevel*kamp,(kcps*semitone:k(kPchBnd))/cpsmidinn(iMidiRef), gkLoopStart*giFileLen, gkLoopEnd*giFileLen, gkcrossfade, gitableL, i(gkinskip)*giFileLen, i(gkmode)-1, ifenv, iskip
   a2              flooper2            klevel*kamp,(kcps*semitone:k(kPchBnd))/cpsmidinn(iMidiRef), gkLoopStart*giFileLen, gkLoopEnd*giFileLen, gkcrossfade, gitableR, i(gkinskip)*giFileLen, i(gkmode)-1, ifenv, iskip
                   outs                a1*aenv,a2*aenv            ; send stereo signal to outputs
  endif               
 endif

endin
 
</CsInstruments>  

<CsScore>
i 1 0 z
</CsScore>

</CsoundSynthesizer>
