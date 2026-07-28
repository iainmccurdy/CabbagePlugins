
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; FileStretcher.csd
; Written by Iain McCurdy, 2014/2021

; This can be used to create a time-stretched version of an input file.
; It focusses on the idea that attacks and releases of sound events should often be retained at normal speed 
;  in order preserve the identity of the sound and that it will be the sustained, steady-state 
;  of the sound that should be stretched.
; This example facilitates this technique by allowing the user to select the portion of sound to stretch by 
;  adjusting the stretch region beginning and ending locations using the hozizontal sliders above and below the file viewer.

; 'Duration' defines the duration of the time-stretched portion of the sound file.

; OPEN FILE - open a new file for stretching
; PLAY STR. - play the file with stretching
; RECORD    - render the stretched file OFFLINE
; PLAY NORM.- play the file normally without stretching (useful for auditioning the source file)
; Duration  - duration of the stretched segment in seconds (goes from 0.1 seconds to 1 hour)
; Semitones - transposition of the stretched file in semitones (1/8 tone resolution).
; Cents     - transposition in cents -100 to +100
; HARMONY (button) - engages a second stretched layer that will be unaffected by 'Semitones' and 'Cents'. 
;                    This is useful for beating/detuning/harmony effects.
; Att.      - attack time of the amplitude envelope
; Rel.      - release time of the amplitude envelope

; FFT Size  - larger values favour frequency resolution, smaller values favour time resolution.
; Phase lock- can prevent modulation artefacts during stretched segments.
; Level     - amplitude level during live performance (rendered file is unaffected by this)

; 'PLAY' auditions the file stretch. 
; 'RECORD' renders the time-stretched audio to disk offline.
; The console reports the name of the output file and a message: 'Done!' when the rendering is complete. 
;    The output file will be created in the same directory as the input file and with the same name but with the word '_stretched' and a unique number suffixed. 

; 'LEVEL' provides a amplitude level control (the rendered file is unaffected and always renders at full amplitude.

; Adding a small amount of jitter to the file reading pointer when time-stretching can reduce the sense of a frozen spectrum 
;  evident during long time stretches. Jitter depth and rate can be modified.

; MIDI notes will also trigger the time-stretching instrument with the note played controlling the transposition pitch.
; Velocity controls amplitude
; MIDI tuning system can be selected form the drop-down box.

<Cabbage>
form caption("File Stretcher") size(700,325), colour(0,0,0) pluginId("FiSt"), guiMode("queue") 
image                bounds(  0,  0,700,325), colour(50,50,60), outlineColour("White"), line(3), shape("sharp")

#define RSLIDER_DESIGN valueTextBox(1), colour(30,30,40), trackerColour("white"), fontColour("white"), textColour("white"), outlineColour(150,150,150)

soundfiler bounds(  5, 15,690,110), channel("filer"),  colour(0, 255, 255, 255), fontColour(160, 160, 160, 255)
label      bounds( 12, 15,450, 13), text(""), align("left"), colour(0,0,0,0), fontColour(200,200,200), channel("stringbox")
image      bounds(  5, 15,  1,110), colour(150,150,160), shape("sharp"), channel("Scrubber")
image      bounds(  5, 15,  1,110), colour(150,50,50,100), shape("sharp"), channel("Region")
hslider    bounds(  0,  5,700, 10), channel("beg"), range(0,1,1), trackerColour("red")
hslider    bounds(  0,125,700, 10), channel("end"), range(0,1,1), trackerColour("red")

;hrange    bounds(  5,145,690,15), text(""), channel("Strt","End"), range(0, 1, 0.2:0.4), colour(30,30,40), trackerColour("white"), fontColour("white"), outlineColour(150,150,150)

filebutton bounds(  7,150, 83, 20), text("OPEN FILE","OPEN FILE"), fontColour(255,255,100) channel("filename"), shape("ellipse")
button     bounds(  7,173, 83, 20), text("PLAY STR.","PLAY STR."), channel("PlayStr"), value(0), latched(1), fontColour:0(  0,105, 0), fontColour:1(100,255,100)
button     bounds(  7,196, 83, 20), text("RECORD","RECORD"), channel("Record"), value(0), latched(0), fontColour:0(105,  0,  0), fontColour:1(255,100,100)

combobox   bounds( 96,150, 83, 20), channel("Tuning"), items("12-TET", "24-TET", "12-TET rev.", "24-TET rev.", "10-TET", "36-TET", "Just C", "Just C#", "Just D", "Just D#", "Just E", "Just F", "Just F#", "Just G", "Just G#", "Just A", "Just A#", "Just B","Pythagorean C","19 TET","31 TET","Bohlen-Pierce C"), value(1),fontColour("white")
button     bounds( 96,173, 83, 20), text("PLAY NORM.","PLAY NORM."), channel("PlayNorm"), value(0), latched(1), fontColour:0(  50,  50,105), fontColour:1(150,150,255)
button     bounds( 96,196, 83, 20), text("STOP","STOP"), channel("Stop"), value(0), latched(0), fontColour:0( 50, 50, 55), fontColour:1(150,150,155)

rslider    bounds(190,140, 60, 80), text("Duration"), channel("Duration"), range(0.1, 3600.00, 3,0.25,0.001), $RSLIDER_DESIGN

button     bounds(260,140,120, 12), text("H A R M O N Y", "H A R M O N Y"), channel("Harmony"), fontColour:0(50,50,50), fontColour:1(205,255,205), colour:0(0,10,0), colour:1(0,150,0), value(0), latched(1)
rslider    bounds(255,160, 70, 60), text("Semitones"), channel("Semitones"), range(-48, 48.00, 0,1,0.25), $RSLIDER_DESIGN
rslider    bounds(315,160, 70, 60), text("Cents"), channel("Cents"), range(-100, 100.00, 0,1, 1), $RSLIDER_DESIGN

rslider    bounds(380,140, 60, 80), text("Att."), channel("Att"),  range(0, 8, 0, 0.5, 0.001), $RSLIDER_DESIGN
rslider    bounds(440,140, 60, 80), text("Rel."), channel("Rel"),  range(0, 8, 0, 0.5, 0.001), $RSLIDER_DESIGN

label      bounds(510,138, 90, 13), text("FFT Size"), fontColour("white")
combobox   bounds(510,152, 90, 20), channel("FFTSize"), items("32768", "16384", "8192", "4096", "2048", "1024", "512", "256", "128", "64", "32"), value(5), fontColour("white")
checkbox   bounds(510,175, 95, 15), channel("lock"), text("Phase Lock"), fontColour:0("white"), fontColour:1("white"), colour(255,0,0)
label      bounds(510,195, 90, 13), text("Stretch/Freeze"), fontColour("white")
combobox   bounds(510,209, 90, 20), channel("StrFr"), items("Stretch","Freeze"), value(1),fontColour("white")

rslider    bounds(620,140, 60, 80), text("Level"), channel("Level"), range(0, 1.00, 0.9), $RSLIDER_DESIGN

;csoundoutput bounds(  0,230,700,200), text("Csound Output")
keyboard     bounds(  5,235,690, 75)

label    bounds(  5,312,120, 12), text("Iain McCurdy |2014|"), align("left"), fontColour("Silver")

</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-dm0 -n -+rtmidi=NULL -M0
</CsOptions>

<CsInstruments>

; sr set by host
ksmps              =                   64
nchnls             =                   2
0dbfs              =                   1

                   massign             0, 2

gichans            init                0        ; 
giReady            init                0        ; flag to indicate function table readiness
gSfilepath         init                ""
giFFTSizes[]       array               32768, 16384, 8192, 4096, 2048, 1024, 512, 256, 128, 64, 32    ; an array is used to store FFT window sizes

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

instr    1
 ; beginning and end of region controls and region printing
 gkbeg             cabbageGetValue     "beg"
 gkend             cabbageGetValue     "end"
 ; protect against beg and end sliders crossing
 if gkend<gkbeg then
                   cabbageSetValue     "beg", gkend
 endif
 if gkbeg>gkend then
                   cabbageSetValue     "end", gkbeg
 endif
 ; move region
 giFilerBounds[]   cabbageGet          "filer", "bounds"
                   cabbageSet          changed:k(gkbeg,gkend), "Region", "bounds", giFilerBounds[0] + gkbeg * giFilerBounds[2], \
                                                                             giFilerBounds[1], \
                                                                             (gkend - gkbeg) * giFilerBounds[2], \
                                                                             giFilerBounds[3] 
 gSfilepath        cabbageGetValue     "filename"                       ; load file

 kNewFileTrg       changed             gSfilepath                       ; if a new file is loaded generate a trigger
 gkLevel           cabbageGetValue     "Level"
 gkSemitones       cabbageGetValue     "Semitones"
 gkCents           cabbageGetValue     "Cents"
 gkTranspose       =                   gkSemitones + (gkCents * 0.01)
 kporttime         linseg              0, 0.01, 0.05
 gkTranspose       portk               semitone(gkTranspose), kporttime
 gklock            cabbageGetValue     "lock"                           ; Phase locking in mincer opcode
 gkStrFr           cabbageGetValue     "StrFr"                          ; stretch or freeze
 
 gkAtt             cabbageGetValue     "Att" 
 gkRel             cabbageGetValue     "Rel" 
 gkHarmony         cabbageGetValue     "Harmony"                        ; harmony switch
 
 if kNewFileTrg==1 then                                                 ; if a new file has been loaded...
                   event               "i", 99, 0, 0.01                 ; call instrument to update sample storage function table 
 endif   
 
 gkPlayStr         cabbageGetValue     "PlayStr"                        ; play stretched
 ktrig             trigger             gkPlayStr, 0.5, 0                ; Generate an impulse if PLAY STRETCHED button is clicked
                   schedkwhen          ktrig, 0, 0, 2, 0, 0.01, 60
 gkPlayNorm        cabbageGetValue     "PlayNorm"                       ; play normally
 ktrig             trigger             gkPlayNorm, 0.5, 0               ; Generate an impulse if PLAY NORM. button is clicked
                   schedkwhen          ktrig, 0, 0, 3, 0, 0.01

 gkRecord          cabbageGetValue     "Record"                         ; record output
 ktrig             trigger             gkRecord, 0.5, 0                 ; Generate an impulse if RECORD button is clicked
                   schedkwhen          ktrig,0,0,4,0,0.1
endin



instr    99    ; load sound file
 gichans           filenchnls          gSfilepath                       ; derive the number of channels (mono=1,stereo=2) in the sound file
 gitableL          ftgen               1,0,0,1,gSfilepath,0,0,1
 if gichans==2 then
  gitableR         ftgen               2,0,0,1,gSfilepath,0,0,2
 endif
 giReady           =                   1                                ; if no string has yet been loaded giReady will be zero
                   cabbageSet          "filer","file",gSfilepath

 ; write file name to GUI
 SFileNoExtension cabbageGetFileNoExtension gSfilepath
                   cabbageSet          "stringbox", "text", SFileNoExtension


 if i(gkbeg)==0 then                                                    ; Reveal instruction when a file is opened for the first time
                   cabbageSet          k(1), "InstructionID", "visible", 1
 endif
endin




giVelScale ftgen 0,0,128,16,0,128,2,1

instr    2    ; play stretched
 if p3==-1 then ; MIDI
  iNum             notnum
  iTuning          cabbageGetValue     "Tuning"
  iCPS             cpstmid             giTTable1 + iTuning - 1    
  iMlt             =                   iCPS/cpsmidinn(60)
  iVel             ampmidi             1, giVelScale
 else           ; GUI
  iMlt             =                   1
  iVel             =                   1
 endif
 
 if giReady==1 then                                    ; i.e. if a file has been loaded
  kStop            cabbageGetValue     "Stop"
  if trigger:k(kStop,0.5,0)==1 then                    ; if stop button is pressed
                   cabbageSetValue     "PlayStr", k(0), k(1) ; deactivate Play putton
                   turnoff                                  ; turnoff this instrument
  endif

  iFileLen         =                   ftlen(gitableL)/ftsr(gitableL) ; File length in seconds
  iBeg             =                   i(gkbeg) * iFileLen   ; start of stretch region in seconds
  iEnd             =                   i(gkend) * iFileLen   ; end of stretch region in seconds
  
  iDuration        cabbageGetValue     "Duration"            ; duration of stretch region in seconds
    
  iFFTSize         cabbageGetValue     "FFTSize"
  iFFTSize         =                   giFFTSizes[iFFTSize-1]
  
  ; File reading pointer
  aptr             linseg              0, (1/kr) + iBeg, iBeg, iDuration, iEnd, iFileLen-iEnd, iFileLen
  kGate            linseg              1, (1/kr) + iBeg       +iDuration       +iFileLen-iEnd-(iFFTSize/sr), 1,1/kr,0  ; to prevent wraparound audio, a bit of a hack
  p3               =                   -1                    ; overwrite p3 with a held/infinite duration
  if k(aptr)>=iFileLen then                                  ; if we've reach the end of the sound file...
                   turnoff                                   ; turn off this instrument
  endif
  
  ; print scrubber 
                   cabbageSet          metro:k(16), "Scrubber", "bounds", ((k(aptr)/iFileLen) * giFilerBounds[2]) + giFilerBounds[0], giFilerBounds[1], 1, giFilerBounds[3]

  ; time stretching
  if gichans==1 then                        ; Mono
   a1              mincer              aptr, 1, gkTranspose*iMlt, gitableL, gklock, iFFTSize
   a1h             mincer              aptr, 1, iMlt, gitableL, gklock, iFFTSize
   if gkHarmony==1 then
    a1             +=                  a1h
   endif
   if i(gkAtt)>0 then
    aEnv           transegr             0, i(gkAtt)+1/kr, -3, 1, i(gkRel)+1/kr, -3, 0
    aCF            transegr             4, i(gkAtt)+1/kr, -3, 14, i(gkRel)+1/kr, -3, 4
    a1             tone                a1, cpsoct(aCF)
    a1             *=                  aEnv
   endif
                   outs                a1 * gkLevel * iVel * kGate, a1 * gkLevel * iVel * kGate

  elseif gichans=2 then          ; Stereo
   a1              mincer              aptr, 1, gkTranspose * iMlt, gitableL, gklock, iFFTSize
   a1h             mincer              aptr, 1, 1 * iMlt, gitableL, gklock, iFFTSize
   if gkHarmony==1 then
    a1             +=                  a1h
   endif
   a2              mincer              aptr, 1, gkTranspose * iMlt, gitableR, gklock, iFFTSize
   a2h             mincer              aptr, 1, 1 * iMlt, gitableR, gklock, iFFTSize
   if gkHarmony==1 then
    a2             +=                  a2h
   endif
   if i(gkAtt)>0 then
    aEnv           transegr             0, i(gkAtt)+1/kr, -3, 1, i(gkRel)+1/kr, -3, 0
    aCF            transegr             4, i(gkAtt)+1/kr, -3, 14, i(gkRel)+1/kr, -3, 4
    a1             tone                a1, cpsoct(aCF)
    a1             *=                  aEnv
    a2             tone                a2, cpsoct(aCF)
    a2             *=                  aEnv
   endif
                   outs                a1 * gkLevel * iVel * kGate, a2 * gkLevel * iVel * kGate
  endif
 endif

 ; if Play Stretched button is deactivated...
 if trigger:k(gkPlayStr,0.5,1)==1 then
                   turnoff
 endif
 ; if end of file has been reached...
 if release:k()==1 then
                   cabbageSetValue     "PlayStr", k(0), k(1)
 endif
endin




instr    3    ; normal speed playback
 iMlt              =                   1 ;ftsr(gitableL) / sr                         ; scale playback speed for mismatching Cabbage sr and file sample rate
 iFileLen          =                   ftlen(gitableL) / ftsr(gitableL)               ; File length in seconds
 p3                =                   iFileLen/iMlt
 aptr              line                0, p3, 1

 ; print scrubber
                   cabbageSet          metro:k(16), "Scrubber", "bounds", (k(aptr) * giFilerBounds[2]) + giFilerBounds[0], giFilerBounds[1], 1, giFilerBounds[3]
    
 aL                table3              aptr, gitableL, 1
 if gichans==1 then
                   outs                aL * gkLevel, aL * gkLevel
 else
 aR                table3              aptr, gitableR, 1
                   outs                aL * gkLevel, aR * gkLevel 
 endif 
 
 kStop             cabbageGetValue     "Stop"                  ; read Stop button
 if trigger:k(kStop,0.5,0)==1 then                       ; if Stop is pressed
                   cabbageSetValue     "PlayNorm", k(0), k(1)  ; turn off Play Normal button
                   turnoff                                    ; turn off this instrument
 endif

 ; if Play Normal button is deactivated...
 if trigger:k(gkPlayNorm, 0.5, 1)==1 then
                   turnoff
 endif
 ; if end of file has been reached...
 if k(aptr)>=1 then
                   cabbageSetValue     "PlayNorm", k(0), k(1)
 endif

endin




instr    4    ; record/render
 if giReady==1 then                                         ; i.e. if a file has been loaded
  iMlt             =                   1
  iFileLen         =                   ftlen(gitableL)/ftsr(gitableL) ; File length in seconds
  iBeg             =                   i(gkbeg) * iFileLen   ; start of stretch region in seconds
  iEnd             =                   i(gkend) * iFileLen   ; end of stretch region in seconds
  iDuration        cabbageGetValue     "Duration"            ; duration of stretch region in seconds    
  iFFTSize         cabbageGetValue     "FFTSize"
  iFFTSize         =                   giFFTSizes[iFFTSize-1]


  ; create output file name
  ilen             strlen              gSfilepath                 ; Derive string length.
  SOutputName      strsub              gSfilepath,0,ilen-4        ; Remove ".wav"
  SOutputName      strcat              SOutputName,"_stretched"   ; Add suffix
  iDate            date
  SDate            sprintf             "%i",iDate
  SOutputName      strcat              SOutputName,SDate          ; Add date
  SOutputName      strcat              SOutputName,".wav"         ; Add extension

  
  ; rendering loop start point
  loop:

  ; File reading pointer
  aptr             linseg              0, (1/kr) + iBeg, iBeg, iDuration, iEnd, iFileLen-iEnd, iFileLen
  p3               =                   -1                        ; overwrite p3 with a held/infinite duration
  if k(aptr)>=iFileLen then                                      ; if we've reach the end of the sound file...
                   kgoto               skip                      ; jump out of loop
  endif

  ; time stretching
  if gichans==1 then                        ; Mono
   a1              mincer              aptr, 1, gkTranspose*iMlt, gitableL, gklock, iFFTSize
   a1h             mincer              aptr, 1, iMlt, gitableL, gklock, iFFTSize
   if gkHarmony==1 then
    a1             +=                  a1h
   endif
   if i(gkAtt)>0 then
    aEnv           transegr             0, i(gkAtt)+1/kr, -3, 1, i(gkRel)+1/kr, -3, 0
    aCF            transegr             4, i(gkAtt)+1/kr, -3, 14, i(gkRel)+1/kr, -3, 4
    a1             tone                a1, cpsoct(aCF)
    a1             *=                  aEnv
   endif
                   fout                SOutputName, 8, a1 * gkLevel

  elseif gichans=2 then          ; Stereo
   a1              mincer              aptr, 1, gkTranspose * iMlt, gitableL, gklock, iFFTSize
   a1h             mincer              aptr, 1, 1 * iMlt, gitableL, gklock, iFFTSize
   if gkHarmony==1 then
    a1             +=                  a1h
   endif
   a2              mincer              aptr, 1, gkTranspose * iMlt, gitableR, gklock, iFFTSize
   a2h             mincer              aptr, 1, 1 * iMlt, gitableR, gklock, iFFTSize
   if gkHarmony==1 then
    a2             +=                  a2h
   endif
   if i(gkAtt)>0 then
    aEnv           transegr             0, i(gkAtt)+1/kr, -3, 1, i(gkRel)+1/kr, -3, 0
    aCF            transegr             4, i(gkAtt)+1/kr, -3, 14, i(gkRel)+1/kr, -3, 4
    a1             tone                a1, cpsoct(aCF)
    a1             *=                  aEnv
    a2             tone                a2, cpsoct(aCF)
    a2             *=                  aEnv
   endif
                   fout                SOutputName, 8, a1 * gkLevel, a2 * gkLevel
  endif

 ; rendering loop end
                   kgoto               loop                 ; loop back
  skip:
                   turnoff
  if release()==1 then
                   printks             SOutputName, 0              ; print output file name
                   printks             "\nDone!\n", 0              ; print when rendering finished
  endif    
 endif
endin


</CsInstruments>

<CsScore>
i 1 0 z
</CsScore>

</CsoundSynthesizer>