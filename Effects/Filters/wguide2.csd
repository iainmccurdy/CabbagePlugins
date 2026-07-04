
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; wguide2.csd
; Written by Iain McCurdy, 2013.

; A double-waveguide filter.

; INPUT    - audio input: 
;   Mono     -  left channel input live audio
;   Stereo   -  stereo input live audio
;   Clicks   -  train of clicks (Rate dial appears)
;   Noise    -  pink noise

; Freq. 1  - frequency of the first waveguide
; Freq. 1  - frequency of the second waveguide
;  These two controls can also be driven by the xy-pad
; Lag      - a lag applied to the actual values used by the double waveguide
; Cutoff 1 - cutoff frequency (in hertz) of a low-pass filter within the first waveguide
; Cutoff 2 - cutoff frequency (in hertz) of a low-pass filter within the second waveguide
; F.back 1 - feedback (output back into input) ratio within the first waveguide
; F.back 2 - feedback (output back into input) ratio within the second waveguide
; Mix      - dry/wet mix
; Level    - output level

; Keyboard (check-box) - when activated, the effect is keyboard controlled, allowing polyphony
; Freq. 1 (check-box)  - when activated, the note played on the keyboard controls the frequency of waveguide 1, in conjunction with the Freq.1 dial
; Freq. 2 (check-box)  - when activated, the note played on the keyboard controls the frequency of waveguide 1, in conjunction with the Freq.2 dial

checkbox bounds(  5,225, 80, 15), text("Keyboard"), channel("Kybd"), value(0), fontColour:0("black"), fontColour:1("black")
checkbox bounds(  5,260, 80, 15), text("Freq. 1"), channel("Freq1Kybd"), value(1), fontColour:0("black"), fontColour:1("black")
checkbox bounds(  5,280, 80, 15), text("Freq. 2"), channel("Freq2Kybd"), value(0), fontColour:0("black"), fontColour:1("black")

<Cabbage>
form caption("wguide2") size(755,402), pluginId("WGu2"), guiMode("queue"), colour("silver")
#define SLIDERDESIGN trackerColour("white"), valueTextBox(1), fontColour("black"), textColour("black"), markerColour("white")
label    bounds(  5, 45, 60, 14), text("INPUT"), fontColour("black")
combobox bounds(  5, 60, 60, 20), items("Mono", "Stereo", "Clicks", "Noise", "File"), value(1), channel("Input")
rslider bounds(  0, 90, 75, 90), text("Rate"),   channel("rate"),     range(0.5, 32, 2, 0.5), colour(100,100,100), visible(0) $SLIDERDESIGN
image    bounds( 75,  0,  2,210), colour("grey")
rslider bounds( 80, 10, 80, 90), text("Freq. 1"),   channel("freq1"),     range(20, 8000, 160, 0.25), colour(100,100,100) $SLIDERDESIGN
rslider bounds( 80,110, 80, 90), text("Freq. 2"),   channel("freq2"),     range(20, 8000, 160, 0.25), colour(100,100,100) $SLIDERDESIGN
xypad   bounds(160, 10,190,190), channel("freq1oct", "freq2oct"), rangeX(4.291, 12.934, 6.1), rangeY(4.291, 12.934, 6), colour(40,40,50) ;, text("x:freq.1 | y:freq.2")
rslider bounds(350, 50, 80, 90), text("Lag"),   channel("lag"),     range(0.01, 3, 0.05, 0.5), colour(100,110,100) $SLIDERDESIGN

rslider bounds(420, 10, 80, 90), text("Cutoff 1"), channel("cutoff1"),   range(20,20000,8000,0.25),   colour(110, 90, 90) $SLIDERDESIGN
rslider bounds(420,110, 80, 90), text("Cutoff 1"), channel("cutoff2"),   range(20,20000,8000,0.25),   colour(110, 90, 90) $SLIDERDESIGN
rslider bounds(490, 10, 80, 90), text("F.back 1"), channel("feedback1"), range(-0.999, 0.999, 0.2),   colour( 90,110, 90) $SLIDERDESIGN
rslider bounds(490,110, 80, 90), text("F.back 2"), channel("feedback2"), range(-0.999, 0.999, 0.2),   colour( 90,110, 90) $SLIDERDESIGN
image   bounds(575,  0,  2,210), colour("grey")
rslider bounds(580, 50, 90,100), text("Mix"),      channel("mix"),       range(0, 1.00, 1),         colour(100,120,120) $SLIDERDESIGN
rslider bounds(660, 50, 90,100), text("Level"),    channel("level"),     range(0, 1.00, 0.7),         colour(100,120,120) $SLIDERDESIGN
image   bounds(  0,210,755,  2), colour("grey")

checkbox bounds(  5,225, 80, 15), text("Keyboard"), channel("Kybd"), value(0), fontColour:0("black"), fontColour:1("black")
checkbox bounds(  5,260, 80, 15), text("Freq. 1"), channel("Freq1Kybd"), value(1), fontColour:0("black"), fontColour:1("black")
checkbox bounds(  5,280, 80, 15), text("Freq. 2"), channel("Freq2Kybd"), value(0), fontColour:0("black"), fontColour:1("black")
rslider  bounds( 70,215, 90, 90), text("Attack"),      channel("att"),       range(0.01,4,0.01,0.5),         colour(100,120,120) $SLIDERDESIGN
rslider  bounds(140,215, 90, 90), text("Release"),      channel("rel"),       range(0.1,10, 3,0.5),         colour(100,120,120) $SLIDERDESIGN
keyboard bounds(235,220,515,85)

; file player
image bounds( 10,315,800, 70) colour(0,0,0,0)
{
filebutton bounds(  0,  0, 70, 30), text("Open File","Open File"), fontColour("white") channel("filename"), corners(5)
button     bounds(  0, 40, 70, 30), text("PLAY","PLAY"), fontColour("white") channel("Play"), latched(1), colour:0(10,55,10), colour:1(70,200,70), corners(5)
soundfiler bounds( 80,  0,660, 70), channel("beg","len"), channel("filer1"),  colour(0, 255, 255, 255), fontColour(160, 160, 160, 255)
label      bounds( 80,  3,690, 14), text(""), align("left"), colour(0,0,0,0), fontColour(200,200,200), channel("FileName")
}

label   bounds( 10,387,130, 14), text("Iain McCurdy |2013|"), align("left"), fontColour("black")
</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-dm0 -n -+rtmidi=NULL -M0
</CsOptions>

<CsInstruments>

;sr is set by the host
ksmps              =                   32    ;NUMBER OF AUDIO SAMPLES IN EACH CONTROL CYCLE
nchnls             =                   2     ;NUMBER OF CHANNELS (2=STEREO)
0dbfs              =                   1
massign 0,11
;Author: Iain McCurdy (2012)

gaFileL,gaFileR    init                0


instr 2 ; instr 11 on/off control (always on)

 ; load file from browse
 gSfilepath        cabbageGetValue     "filename"    ; read in file path string from filebutton widget
 if changed:k(gSfilepath)==1 then                    ; call instrument to update waveform viewer  
                   event               "i",99,0,0
 endif 
 
 ; play file
 gkPlay            cabbageGetValue     "Play"
 if trigger:k(gkPlay,0.5,0) == 1 then
                   event               "i",101,0,3600
 endif

kKybd cabbageGetValue "Kybd"

if trigger:k(kKybd,0.5,1)==1 then
 event "i",11,0,-1
endif

if trigger:k(kKybd,0.5,0)==1 then
 turnoff2 11,0,0
endif

endin




instr 11
 klag              cabbageGetValue     "lag"
 kporttime         =                   linseg:k(0,0.001,1) * klag
 kfreq1oct,kT      cabbageGetValue     "freq1oct"
                   cabbageSetValue     "freq1", cpsoct(kfreq1oct), kT
 kfreq2oct         cabbageGetValue     "freq2oct"
                   cabbageSetValue     "freq2", cpsoct(kfreq2oct), kT
 gkfreq1           cabbageGetValue     "freq1"                          ; READ WIDGETS...
 gkfreq1           portk               gkfreq1,kporttime
 gkfreq2           cabbageGetValue     "freq2"
 gkfreq2           portk               gkfreq2,kporttime
 gkcutoff1         cabbageGetValue     "cutoff1"
 gkcutoff2         cabbageGetValue     "cutoff2"
 gkfeedback1       cabbageGetValue     "feedback1"
 gkfeedback2       cabbageGetValue     "feedback2"
 gkmix             cabbageGetValue     "mix"
 gklevel           cabbageGetValue     "level"
 kInput            cabbageGetValue     "Input"
                   cabbageSet          changed:k(kInput), "rate", "visible", kInput==3?1:0
 krate             cabbageGetValue     "rate"
 if kInput==1 then
  asigL       inch   1
  asigR       =      asigL
 elseif kInput==2 then
  asigL,asigR ins
 elseif kInput==3 then
  asigL       mpulse  1, 1/krate
  asigR       mpulse -1, 1/krate
 elseif kInput==4 then
  asigL       =      pinker:a()*0.5
  asigR       =      pinker:a()*0.5
 else  
  asigL       =      gaFileL
  asigR       =      gaFileR
  gaFileL     =      0        ; clear audio variables
  gaFileR     =      0        ; clear audio variables

 endif 

 kFBtot            =                   gkfeedback1 + gkfeedback2        ; protect against combined feedbacks greater than 0.5
 if kFBtot>0.5 then
  gkfeedback1      =                   gkfeedback1 / (kFBtot*2)
  gkfeedback2      =                   gkfeedback2 / (kFBtot*2)
 else
  gkfeedback1      =                   gkfeedback1
  gkfeedback2      =                   gkfeedback2
 endif
 
 aplk              init                0
 kpluck            =                   trigger:k(cabbageGetValue:k("pluck"),0.5,0)                    ; pluck button
 aplk              interp              kpluck           
 if changed(kpluck)==1 then
  aplk             =                   1
  asigL            +=                  aplk
  asigR            +=                  aplk
 endif
 
 kFreq1Kybd cabbageGetValue "Freq1Kybd"
 kFreq2Kybd cabbageGetValue "Freq2Kybd"
 
 ; MIDI interoperability
 idefault       =           1
 ivalue         =           0
                mididefault idefault, ivalue ; ivalue overwritten by idefault if MIDI driven
 iIntervalMode  cabbageGetValue "IntervalMode"
 if ivalue==1 then ; MIDI
  iatt   cabbageGetValue "att"
  irel   cabbageGetValue "rel"
  ivel   ampmidi 1
  kfreq1 = (kFreq1Kybd == 1 ? cpsmidi() * gkfreq1/cpsmidinn(60) : gkfreq1)
  kfreq2 = (kFreq2Kybd == 1 ? cpsmidi() * gkfreq2/cpsmidinn(60) : gkfreq2)
  aEnvIn        =        transegr:a(0,iatt,4,1,0.02,0,0) * ivel
  aEnv          linsegr  0,0.05,1,irel,0
 else              ; non-MIDI
  kfreq1 =  gkfreq1
  kfreq2 =  gkfreq2
  aEnvIn        = 1
  aEnv = 1
 endif

 afreq1            interp              kfreq1
 afreq2            interp              kfreq2
 
 kEnv              downsamp            aEnv
 aresL             wguide2             asigL*aEnvIn, afreq1, afreq2, gkcutoff1*kEnv, gkcutoff2*kEnv, gkfeedback1, gkfeedback2
 aresR             wguide2             asigR*aEnvIn, afreq1, afreq2, gkcutoff1*kEnv, gkcutoff2*kEnv, gkfeedback1, gkfeedback2
 aresL             dcblock2            aresL    ; BLOCK DC OFFSET
 aresR             dcblock2            aresR    ; BLOCK DC OFFSET           
 amixL             ntrpol              asigL,aresL,gkmix
 amixR             ntrpol              asigR,aresR,gkmix
                   outs                amixL*gklevel*aEnv, amixR*gklevel*aEnv       ; åWGUIDE1 OUTPUTS ARE SENT OUT
endin





; LOAD SOUND FILE
instr    99
 giSource          =                   0
                   cabbageSet          "filer1", "file", gSfilepath
 gkNChans          init                filenchnls:i(gSfilepath)
 /* write file name to GUI */
 SFileNoExtension  cabbageGetFileNoExtension gSfilepath
                   cabbageSet          "FileName","text",SFileNoExtension
endin

; play sound file
instr 101
if gkPlay==0 then
 turnoff
endif
if i(gkNChans)==1 then
 gaFileL           diskin2             gSfilepath,1,0,1
else
 gaFileL,gaFileR   diskin2             gSfilepath,1,0,1
endif
endin


</CsInstruments>

<CsScore>
i  2 0 z
i 11 0 z
</CsScore>

</CsoundSynthesizer>