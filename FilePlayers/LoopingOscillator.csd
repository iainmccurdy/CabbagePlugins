
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; LoopingOscillator.csd
; Written by Iain McCurdy, 2014, 2026
; 
; Loads a user selected sound file (mono or stereo) into a GEN01 function table (RAM) and plays it back using loscilx. 
; This file player is suited well for polyphonic playback with many overlapping notes.
;  It is less well suited for the playback of very long sound files for which diskin2 is recommended.
; 
; The sound file can be played back using the Play/Stop button (and the 'Transpose' / 'Speed' buttons to implement pitch/speed change)
;  or it can be played back using the MIDI keyboard.
; 
; The loop points are set using the white sliders above and below the waveform viewer. The upper slider is the loop start
;  point and the lower one is the loop end point.
; The loop start point should always be before the end point otherwise the loop will not play.
; The light green slider controls the start point before looping begins. It should be before both loop points otherwise, 
; again, the loop will not play. All three of these controls operate at i-rate 
; so moving them will cause any currently sounding notes to restart.
; If you require real-time control of loop points upon sounding notes, try 'DynamicLooper'.

; The loscilx opcode is used which offers superior quality for interpolation when extremely low playback speeds are used.
;  Additionally, it can reduce aliasing artefacts when samples are played much fast than normal speed.
; The extent to which these improvements will be applied is set using the 'Quality' control (the 'Window' number box
;   indicates the actual window size used by the opcode). Increasing 'Quality' comes at a CPU cost so should be 
;   balanced against the extent of transposition desired and polyphony required).

; The xypad can be used to control Speed (X direction) and filters (Y direction).
; The filters are in-series low-pass and high-pass filters - 
;  the first half of the y-axis travel shifts the cutoff frequency of the lowpass filter
;  and the second half shifts the cutoff frequency of the high-pass filter.

; S P E E D
; Pitch transposition is achieved by playing the sound source faster or slower.
; Therefore it can be controlled with sliders for Transpose or Speed and adjusting one of these will also move the other.

; E N V E L O P E
; Att. Time  -  envelope attack time, triggered by MIDI notes and the GUI Play button.
; Rel. Time  -  envelope release time, triggered when a MIDI note is released or theGUI Play button is deactivated.

; C O N T R O L
; MIDI Ref.  -  MIDI note that will trigger unison playback of the sound file
; Detect     -  this will detect the pitch of the sound file chosen and set 'MIDI Ref.' appropriately.
;                For this to work a sound file with a steady, monophonic pitch should be used.
;                The pitch is detected 0.3 second from the beginning to avoid the noisy attack stage 
;                and detect the resonant steady state.
; Level      -  output level.
<Cabbage>
form caption("Looping Oscillator") size(1260,440), colour( 70, 75, 70) pluginId("Losc"), guiMode("queue")

#define SLIDER_STYLE colour( 50, 70, 50), textColour("white"), valueTextBox(1), fontColour("white")
#define SLIDER_STYLE2 colour( 50, 70, 50), textColour("white"), valueTextBox(0), fontColour("white"), colour("white")
#define SLIDER_STYLE3 colour( 50, 70, 50), textColour("white"), valueTextBox(0), fontColour("white"), colour("lime")

soundfiler bounds(  5, 15,850,175), channel("beg","len"),  colour(0, 255, 255, 255), fontColour(160, 160, 160, 255), 
hslider    bounds(  0,  0,860, 20), channel("LoopStart"), range(0, 1, 0), popupText(0), $SLIDER_STYLE2
hslider    bounds(  0,190,860, 20), channel("LoopEnd"), range(0, 1, 1), popupText(0), $SLIDER_STYLE2
hslider    bounds(  0,210,860, 20), channel("Start"), range(0, 1, 0), popupText(0), $SLIDER_STYLE3
image      bounds(  5, 15,  1,175), alpha(0.5), channel("LoopRegion"), colour(200,200,255)
image      bounds(  5, 15,  1,175), alpha(0.5), channel("StartWiper"), colour("lime")

image      bounds(  0,230,860,220), colour(0,0,0,0), outlineColour("white"), line(2), shape("sharp"), plant("controls")
{
filebutton bounds( 10, 30, 80, 25), text("Open File","Open File"), fontColour("white") channel("filename"), corners(5)
image      bounds(  9, 69, 82, 27), colour("black"), corners(5)
button     bounds( 10, 70, 80, 25), channel("PlayStop"), text("Play","Play"), colour:0( 30,80,30), colour:1(150,255,150), fontColour:0("white"), fontColour:1(0,60,0), corners(5)

label      bounds(110, 40, 90, 13), text("Looping Mode"), fontColour("white"), align("centre")
combobox   bounds(110, 55, 90, 20), channel("loop"), items("None", "Forward", "Fwd./Bwd."), value(1), fontColour("white")
rslider    bounds(195, 20, 90, 90), channel("Quality"), range(0, 10, 4,1,1),   text("Quality"), $SLIDER_STYLE
nslider    bounds(275, 40, 60, 35), channel("Window"), range(1, 1024, 16,1,1),   text("Window"), $SLIDER_STYLE
image      bounds(274, 40, 60, 40), alpha(0.2), outlineThickness(1), corners(5), outlineColour("black")

line       bounds(340, 10,  2, 95), colour("Grey")

label      bounds(380,  4, 53, 8), text("S   P   E   E   D"), fontColour("white"), align("centre")
rslider    bounds(335, 20, 90, 90), channel("transpose"), range(-72, 72, 0,1,0.1),   text("Transpose"), $SLIDER_STYLE
rslider    bounds(400, 20, 90, 90), channel("speed"),     range( 0, 4.00, 1, 0.5), text("Speed"),     $SLIDER_STYLE

line       bounds(480, 10,  2, 95), colour("Grey")

label      bounds(515,  4, 90,  8), text("E   N   V   E   L   O   P   E"), fontColour("white"), align("centre")
rslider    bounds(475, 20, 90, 90), channel("AttTim"),    range(0, 5, 0, 0.5, 0.001),       text("Att.Tim"), $SLIDER_STYLE
rslider    bounds(545, 20, 90, 90), channel("RelTim"),    range(0.01, 5, 0.05, 0.5, 0.001), text("Rel.Tim"), $SLIDER_STYLE

line       bounds(630, 10,  2, 95), colour("Grey")

label      bounds(710,  4, 80,  8), text("C   O   N   T   R   O   L"), fontColour("white")
rslider    bounds(630, 20, 90, 90), channel("MidiRef"),   range(0,127,60, 1, 0.001),     text("MIDI Ref."), $SLIDER_STYLE
button     bounds(715, 50, 70, 25), channel("Detect"), text("Detect","Detect"), corners(5), colour:0(100,100,130), colour:1(100,100,130), latched(0)
rslider    bounds(780, 20, 90, 90), channel("level"),     range(  0,  3.00, 1, 0.5), text("Level"), $SLIDER_STYLE

keyboard bounds(5,120,850,75)
}

xypad      bounds(865,  5,390,425), channel("X","Y"), rangeX(0,1,0.5), rangeY(0,1,0.5)
checkbox   bounds( 880,400,100, 15), channel("X2Speed"), value(1), text("X to Speed"), fontColour:0("white"), fontColour:1("white")
checkbox   bounds(1080,400,100, 15), channel("Y2Filters"), value(1), text("Y to Filters"), fontColour:0("white"), fontColour:1("white")
label    bounds(  5,427,120, 12), text("Iain McCurdy |2014|"), align("left"), fontColour("Silver")
 
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

                   massign             0, 2
gichans            init                0
giReady            init                0
gSfilepath         init                ""
gkTabLen           init                2

instr    1 ; always on
 krampup           linseg              0, 0.01, 1
 kX, kT            cabbageGetValue     "X"
                   cabbageSetValue     "speed", (kX ^ 2) * 4, kT * cabbageGetValue:k("X2Speed")     
 kY, kT            cabbageGetValue     "Y"

  ; filter parameters (right-click mouse click-and-drag Y axis over file panel)
  kLPF_CF          scale               (kY * 2), 14, 4
  kLPF_CF          limit               kLPF_CF, 4, 14
  kLPF_CF          portk               kLPF_CF, krampup * 0.05
  gkLPF_CF         =                   cpsoct(kLPF_CF)
  kHPF_CF          scale               (kY * 2) - 1, 14, 4
  kHPF_CF          limit               kHPF_CF, 4, 14
  kHPF_CF          portk               kHPF_CF, krampup * 0.05
  gkHPF_CF         =                   cpsoct(kHPF_CF)

 gkloop            cabbageGetValue     "loop"
 kLoopStart        cabbageGetValue     "LoopStart"
 kLoopEnd          cabbageGetValue     "LoopEnd"
 gkStart           cabbageGetValue     "Start"
 kbeg              cabbageGetValue     "beg"                      ; click and drag
 klen              cabbageGetValue     "len"
 
 ; loop region graphic
 iBounds[]         cabbageGet          "beg", "bounds"
                   cabbageSet          changed:k(kLoopStart, kLoopEnd), "LoopRegion", "bounds", iBounds[0] + (iBounds[2] * kLoopStart),   iBounds[1], (iBounds[2] * (kLoopEnd-kLoopStart)),   iBounds[3]
                   cabbageSet          changed:k(gkStart), "StartWiper", "bounds", iBounds[0] + gkStart*iBounds[2], iBounds[1], 1, iBounds[3] 
 kLoopEnd          limit               kLoopEnd,kLoopStart+0.01,1 ; limit loop end to prevent crashes
 
 ; loop points defined by sliders or click and drag...
 kTrigSlid         changed             kLoopStart, kLoopEnd    
 kTrigCAD          changed             kbeg, klen
 if kTrigSlid==1 then
  gkLoopStart      =                   kLoopStart
  gkLoopEnd        =                   kLoopEnd
 elseif kTrigCAD==1 then
                   cabbageSetValue     "LoopStart", kbeg / gkTabLen, k(1)
                   cabbageSetValue     "LoopEnd", (kbeg + klen) / gkTabLen, k(1)
 endif


 gkPlayStop        cabbageGetValue     "PlayStop"
 gktranspose       cabbageGetValue     "transpose"
 gkspeed           cabbageGetValue     "speed"
 gklevel           cabbageGetValue     "level"

 gSfilepath        cabbageGetValue     "filename"
 kNewFileTrg       changed             gSfilepath        ; if a new file is loaded generate a trigger
 if kNewFileTrg==1 then                                 ; if a new file has been loaded...
                   event               "i", 99, 0, 0    ; call instrument to update sample storage function table 
 endif  
 
 ktrig             trigger             gkPlayStop, 0.5, 0         ; if play button changes to 'play', generate a trigger
                   schedkwhen          ktrig, 0, 0, 2, 0, -1      ; start instr 2 playing a held note

 ktrig1            changed             gktranspose                ; if 'transpose' button is changed generate a '1' trigger
 ktrig2            changed             gkspeed                    ; if 'speed' button is changed generate a '1' trigger
 
 if ktrig1==1 then                                                            ; if transpose control has been changed...
                   cabbageSetValue     "speed", semitone(gktranspose), k(1)    ; set speed according to transpose value
 elseif ktrig2==1 then                                                        ; if speed control has been changed...
                   cabbageSetValue     "transpose", log2(gkspeed)*12, k(1)    ; set transpose control according to speed value
 endif

 ; detect pitch
 kDetect           cabbageGetValue     "Detect"
 if trigger:k(kDetect,0.5,0)==1 then
                   event               "i", 200, 0, 30
 endif

 kQuality          cabbageGetValue     "Quality"
                   cabbageSetValue     "Window", 2 ^ kQuality, changed:k(kQuality)

endin




instr    99    ; load sound file
 gitable           ftgen               1, 0, 0, 1, gSfilepath, 0, 0, 0  ; load sound file into a GEN 01 function table 
 gichans           filenchnls          gSfilepath                       ; derive the number of channels (mono=1,stereo=2) in the sound file
 giReady           =                   1                                ; if no string has yet been loaded giReady will be zero
 gkTabLen          init                ftlen(gitable) / gichans         ; table length in sample frames
                   cabbageSet          "beg", "file", gSfilepath
endin




instr    2    ; sound generating instrument (both GUI button-triggered and MIDI note-triggered)
kporttime          linseg              0, 0.001, 0.05             ; portamento time function. (Rises quickly from zero to a held value.)
idefault           =                   1
iMIDI              =                   0
                   mididefault         idefault, iMIDI ; ivalue overwritten by idefault if MIDI driven
if iMIDI==1 then ; MIDI
 iMidiRef          cabbageGetValue     "MidiRef"
 icps              cpsmidi                                        ; read in midi note data as cycles per second
 kspeed            =                   icps/cpsmidinn(iMidiRef)
 iamp              ampmidi             1       ; read in midi velocity (as a value within the range 0 - 1)
 
else              ; non-MIDI
 if gkPlayStop==0 then
  turnoff
 endif
 kspeed            portk               gkspeed, kporttime          ; apply portamento smoothing to changes in speed
 iamp              =                   1 
endif

 ; amplitude envelope
 iAttTim           cabbageGetValue     "AttTim"                    ; read in widgets
 iRelTim           cabbageGetValue     "RelTim"
 if iAttTim>0 then                                                 ; is amplitude envelope attack time is greater than zero...
  kenv             linsegr             0, iAttTim, 1, iRelTim, 0   ; create an amplitude envelope with an attack, a sustain and a release segment (senses realtime release)
 else
  kenv             linsegr             1, iRelTim, 0               ; create an amplitude envelope with a sustain and a release segment (senses realtime release)
 endif
 kenv              expcurve            kenv, 8                     ; remap amplitude value with a more natural curve
 aenv              interp              kenv                        ; interpolate and create a-rate envelope
 
 kQuality          cabbageGetValue     "Quality"
 if changed:k(gkloop,gkLoopStart,gkLoopEnd,kQuality)==1 then
  reinit RESTART
 endif
 RESTART:
 iWindow           =                   2 ^ i(kQuality)
 if giReady==1 then                                             ; i.e. if a file has been loaded
  iAttTim          cabbageGetValue     "AttTim"                 ; read in widgets
  iRelTim          cabbageGetValue     "RelTim"
  klevel           portk               gklevel,kporttime        ; apply portamento smoothing to changes in level
  
  if gichans==1 then                                            ; if mono...
    a1             loscilx             klevel*aenv * iamp, kspeed, gitable, iWindow, 1, nsamp(gitable) * i(gkStart), i(gkloop) - 1, nsamp(gitable) * i(gkLoopStart), nsamp(gitable) * i(gkLoopEnd)
    a2             =                   a1
  elseif gichans==2 then                                        ; otherwise, if stereo...
    a1,a2          loscilx             klevel * aenv * iamp, kspeed, gitable, iWindow, 1, nsamp(gitable) * i(gkStart), i(gkloop) - 1, nsamp(gitable) * i(gkLoopStart), nsamp(gitable) * i(gkLoopEnd)
  endif
  
  ; xy pad filters
  if cabbageGetValue:k("Y2Filters")==1 then
   a1              zdf_2pole           a1, a(gkLPF_CF), 0.5
   a2              zdf_2pole           a2, a(gkLPF_CF), 0.5
   a1              zdf_2pole           a1, a(gkHPF_CF), 0.5, 1
   a2              zdf_2pole           a2, a(gkHPF_CF), 0.5, 1
  endif

                   outs                a1 * aenv, a2 * aenv         ; send stereo signal to outputs
               
 endif
endin


  
 instr 200 ; detect pitch of sample and send to MIDI reference
  gitable          ftgen               1, 0, 0, 1, gSfilepath, 0, 0, 0  ; load sound file into a GEN 01 function table 
  gichans          filenchnls          gSfilepath                       ; derive the number of channels (mono=1,stereo=2) in the sound file
  giReady          =                   1                                ; if no string has yet been loaded giReady will be zero
  gkTabLen         init                ftlen(gitable) / gichans         ; table length in sample frames
                   cabbageSet          "beg", "file", gSfilepath
  if gichans==1 then
   aL              diskin2             gSfilepath, 1
  elseif gichans==2 then
   aL,aR           diskin2             gSfilepath, 1
  endif  
  kcps, krms       pitchamdf           aL, 20, 5000
  if timeinsts:k() >= 0.3 then
   kNote           =                   ftom:k(kcps)
                   cabbageSetValue     "MidiRef",kNote
                   turnoff
  endif
 endin

 
</CsInstruments>  

<CsScore>
i 1 0 z
</CsScore>

</CsoundSynthesizer>
