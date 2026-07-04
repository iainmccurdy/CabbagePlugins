
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; Linear Predictive Coding (LPC) Cross-Synthesis.csd
; Written by Iain McCurdy, 2026

; Performs cross-synthesis between two sound files using Linear Predictive Coding

; A sound file (FILE 1) is analysed using linear predictive coding 
; and the derived coefficients are used in an allpole filter that is applied to a second sound file (FILE 2).

; The playback speed of each source sound file can be varied

; The cross-synthesised output is passed through a low-shelving filter and then a high-shelving filter.

; The three vertical sliders at the bottom mix between FILE 1, FILE 2 and the cross-synthesised output.

<Cabbage>
#define COLOUR 235,235,215

form caption("LPC Cross-Synthesis"), size(541, 425), pluginId("LpCm"), colour($COLOUR), guiMode("queue")


label      bounds( 10,  5, 80, 16), text("FILE 1"), fontColour("black")
filebutton bounds( 10, 25, 80, 18), text("Open File","Open File"), fontColour("white") channel("filename1"), shape("ellipse"), colour:0(50,50,100)
button     bounds( 10, 50, 80, 18), text("PLAY","PLAY"), channel("Play1"), value(0), latched(1), fontColour:0(70,120,70), fontColour:1(205,255,205), colour:0(20,40,20), colour:1(0,150,0)
rslider    bounds( 20, 72, 60, 70), channel("speed1"), range(-1, 2, 1,0.50.1), text("Speed"), valueTextBox(1), textColour("Black"), fontColour("Black"), colour(150,150,170), colour(200,200,220), trackerColour(110,110,120)
soundfiler bounds(100,  1,440,148), channel("filer1"),  colour(0, 255, 255, 255), fontColour(160, 160, 160, 255)

line       bounds(  0,150,540,   1), colour("DarkSlateGrey")

label      bounds( 10,155, 80, 16), text("FILE 2"), fontColour("black")
filebutton bounds( 10,175, 80, 18), text("Open File","Open File"), fontColour("white") channel("filename2"), shape("ellipse"), colour:0(50,50,100)
button     bounds( 10,200, 80, 18), text("PLAY","PLAY"), channel("Play2"), value(0), latched(1), fontColour:0(70,120,70), fontColour:1(205,255,205), colour:0(20,40,20), colour:1(0,150,0)
rslider    bounds( 20,222, 60, 70), channel("speed2"), range(-1, 2, 1,0.50.1), text("Speed"), valueTextBox(1), textColour("Black"), fontColour("Black"), colour(150,150,170), colour(200,200,220), trackerColour(110,110,120)
soundfiler bounds(100,151,440,148), channel("filer2"),  colour(0, 255, 255, 255), fontColour(160, 160, 160, 255)

label      bounds( 82,  4,448,  9), text(""), align("left"), colour(0,0,0,0), fontColour(200,200,200), channel("stringbox1")
label      bounds( 82,154,448,  9), text(""), align("left"), colour(0,0,0,0), fontColour(200,200,200), channel("stringbox2")

line       bounds(  0,300,540,   1), colour("DarkSlateGrey")

image bounds(0,305,540,300) colour(0,0,0,0) 
{
image      bounds( 20,  6, 95,  1), colour("black")
label      bounds( 35,  0, 65, 12), text("Low Shelf"), fontColour("black"), colour($COLOUR)
checkbox   bounds( 20, 15, 80, 12), channel("LSOnOff"), text("On/Off"), fontColour:0("black"), fontColour:1("black"), value(0)
rslider    bounds( 10, 30, 60, 75), channel("cl"), range(100, 15000, 1000,0.5,1), text("Freq."), valueTextBox(1), textColour("Black"), fontColour("Black"), colour(150,150,170), colour(200,200,220), trackerColour(110,110,120)
rslider    bounds( 65, 30, 60, 75), channel("vl"), range(-24, 24, 0, 1, 0.01), text("Gain (dB)"), valueTextBox(1), textColour("Black"), fontColour("Black"), colour(150,150,170), colour(200,200,220), trackerColour(110,110,120)

image      bounds(140,  6, 95,  1), colour("black")
label      bounds(155,  0, 65, 12), text("High Shelf"), fontColour("black"), colour($COLOUR)
checkbox   bounds(140, 15, 80, 12), channel("HSOnOff"), text("On/Off"), fontColour:0("black"), fontColour:1("black"), value(1)
rslider    bounds(130, 30, 60, 75), channel("ch"), range(100, 15000, 1000,0.5,1), text("Freq."), valueTextBox(1), textColour("Black"), fontColour("Black"), colour(150,150,170), colour(200,200,220), trackerColour(110,110,120)
rslider    bounds(185, 30, 60, 75), channel("vh"), range(-24, 24, 0, 1, 0.01), text("Gain (dB)"), valueTextBox(1), textColour("Black"), fontColour("Black"), colour(150,150,170), colour(200,200,220), trackerColour(110,110,120)


vslider    bounds(245, 10, 30,120), channel("F1Amp"), range(0, 1, 0, 0.5), text("1"), valueTextBox(1), textColour("Black"), fontColour("Black"), colour(150,150,170), colour(200,200,220), trackerColour(110,110,120)
vslider    bounds(275, 10, 30,120), channel("F2Amp"), range(0, 1, 0, 0.5), text("2"), valueTextBox(1), textColour("Black"), fontColour("Black"), colour(150,150,170), colour(200,200,220), trackerColour(110,110,120)
vslider    bounds(305, 10, 30,120), channel("CSAmp"), range(0, 1, 1, 0.5), text("C.S."), valueTextBox(1), textColour("Black"), fontColour("Black"), colour(150,150,170), colour(200,200,220), trackerColour(110,110,120)


rslider    bounds(340, 30, 60, 75), channel("level"), range(0, 10, 1, 0.5), text("Level"), valueTextBox(1), textColour("Black"), fontColour("Black"), colour(150,150,170), colour(200,200,220), trackerColour(110,110,120)
button     bounds(420, 20,100, 25), channel("Swap"), text("SWAP FILES"), latched(1), colour:1("yellow"), fontColour:1("Black")
checkbox   bounds(420, 60, 75, 25), channel("record"), text("Record"), colour("red"), fontColour:0("Black"), fontColour:1("Black")

}

label      bounds(  3,413,120, 11), text("Iain McCurdy |2026|"), align("left"), fontColour("DarkGrey")
</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-dm0 -n -+rtmidi=NULL -M0
</CsOptions>

<CsInstruments>

;sr is set by the host
ksmps       =        64
nchnls      =        2
0dbfs       =        1     ; MAXIMUM AMPLITUDE

gSfilepath1    init    ""
gSfilepath2    init    ""
gkFileChans1,gkFileChans2    init    0

opcode FileNameFromPath,S,S        ; Extract a file name (as a string) from a full path (also as a string)
 Ssrc    xin                       ; Read in the file path string
 icnt    strlen    Ssrc            ; Get the length of the file path string
 LOOP:                             ; Loop back to here when checking for a backslash
 iasc    strchar Ssrc, icnt        ; Read ascii value of current letter for checking
 if iasc==92 igoto ESCAPE          ; If it is a backslash, escape from loop
 loop_gt    icnt,1,0,LOOP          ; Loop back and decrement counter which is also used as an index into the string
 ESCAPE:                           ; Escape point once the backslash has been found
 Sname   strsub  Ssrc, icnt+1, -1  ; Create a new string of just the file name
         xout    Sname             ; Send it back to the caller instrument
endop

gkRecordingActiveFlag    init    0
gkFileRecorded           init    0

instr    1    ;READ IN WIDGETS
 gSfilepath1    cabbageGetValue    "filename1" ; read in file path string from filebutton widget
 gSfilepath2    cabbageGetValue    "filename2" ; read in file path string from filebutton widget 
 if changed:k(gSfilepath1)==1 then             ; call instrument to update waveform viewer  
  event "i",98,0,0
 elseif changed:k(gSfilepath2)==1 then         ; call instrument to update waveform viewer  
  event "i",99,0,0
 endif

 gkPlay1        cabbageGetValue    "Play1"
 gkPlay2        cabbageGetValue    "Play2"

 if trigger:k(gkPlay1,0.5,0)==1 then
  event "i",3,0,3600*24*7
 elseif trigger:k(gkPlay2,0.5,0)==1 then
  event "i",4,0,3600*24*7
 endif

 gkrecord    cabbageGetValue    "record"
 kRecStart   trigger    gkrecord,0.5,0
 if kRecStart==1 && gkRecordingActiveFlag==0 then
             event     "i",9000,0,-1
  gkRecordingActiveFlag =    1
 endif
endin


instr 3 ; Play File 1
  if gkPlay1==0 then
   turnoff
  endif
  kspeed1 cabbageGetValue "speed1"
  if changed:k(gSfilepath1)==1 || changed:k(gkFileChans1)==1 then
   reinit RESTART1
  endif
  RESTART1:
  if i(gkFileChans1)==1 then
   gaFile1L diskin2   gSfilepath1,kspeed1,0,1
   gaFile1R =         gaFile1L
  else
   gaFile1L, gaFile1R diskin2 gSfilepath1,kspeed1,0,1
  endif
endin

instr 4 ; Play File 2
  if gkPlay2==0 then
   turnoff
  endif
  kspeed2 cabbageGetValue "speed2"
  if changed:k(gSfilepath2)==1 || changed:k(gkFileChans2)==1 then
   reinit RESTART2
  endif
  RESTART2:
  if i(gkFileChans2)==1 then
   gaFile2L diskin2 gSfilepath2,kspeed2,0,1
   gaFile2R =       gaFile2L
  else
   gaFile2L, gaFile2R diskin2 gSfilepath2,kspeed2,0,1
  endif
endin



gifw ftgen 0,0,1024,20,2,1
opcode lpc_module, a, aa
a_src, a_dst xin
kcfs[],krms,kerr,kcps lpcanal a_src, 1, 4,    1024,   64,     gifw
aresyn allpole a_dst * krms * kerr, kcfs
aresyn dcblock aresyn
       xout    aresyn
endop


instr    10 ; morpher

kampint = 0
kfrqint = 0

    kporttime     linseg             0,0.001,0.02
    klevel        cabbageGetValue    "level"
    klevel        portk              klevel, kporttime
    kSwap         cabbageGetValue    "Swap"

    aFile1L,aFile1r,aFile2L,aFile2R init 0
    if kSwap==0 then
     aFile1L      =                  gaFile1L
     aFile1R      =                  gaFile1R
     aFile2L      =                  gaFile2L
     aFile2R      =                  gaFile2R
    else
     aFile1L      =                  gaFile2L
     aFile1R      =                  gaFile2R
     aFile2L      =                  gaFile1L
     aFile2R      =                  gaFile1R
    endif

    aoutL          lpc_module         aFile1L, aFile2L
    aoutR          lpc_module         aFile1R, aFile2R
    
    ; EQ
    kq             =                  0.8

    if cabbageGetValue:k("LSOnOff")==1 then
     kcl            cabbageGetValue    "cl"
     kvl            =                  ampdbfs(cabbageGetValue:k("vl"))
     aoutL          pareq              aoutL, kcl, kvl, kq, 1 ; low-shelving
     aoutR          pareq              aoutR, kcl, kvl, kq, 1
    endif

    if cabbageGetValue:k("HSOnOff")==1 then
     kch            cabbageGetValue    "ch"
     kvh            =                  ampdbfs(cabbageGetValue:k("vh"))
     aoutL          pareq              aoutL, kch, kvh, kq, 2 ; high-shelving
     aoutR          pareq              aoutR, kch, kvh, kq, 2
    endif
    ;;
kF1Amp            cabbageGetValue     "F1Amp"
kF2Amp            cabbageGetValue     "F2Amp"
kCSAmp            cabbageGetValue     "CSAmp"
    
                  outs               ((aoutL*kCSAmp) + (gaFile1L*kF1Amp) + (gaFile2L*kF2Amp)) * a(klevel), ((aoutR*kCSAmp) + (gaFile1R*kF1Amp) + (gaFile2R*kF2Amp)) * a(klevel)
                  clear              gaFile1L, gaFile1R, gaFile2L, gaFile2R
endin





instr    98 ; load file 1
 Smessage sprintfk "file(%s)", gSfilepath1            ; print sound file image to fileplayer
 ;chnset Smessage, "filer1"
 cabbageSet "filer1",Smessage
 /* write file name to GUI */
 Sname FileNameFromPath    gSfilepath1                ; Call UDO to extract file name from the full path
 Smessage sprintfk "text(%s)",Sname                   ; create string to update text() identifier for label widget
 ;chnset Smessage, "stringbox1"                        ; send string to  widget
 cabbageSet "stringbox1",Smessage
 gkFileChans1 init  filenchnls:i(gSfilepath1)
 
 ;iFileChans1 =  filenchnls:i(gSfilepath1)
 ;if gkFileChans1==1 then    
endin

instr    99 ; load file 2
 Smessage sprintfk "file(%s)", gSfilepath2            ; print sound file image to fileplayer
 ;chnset Smessage, "filer2"
 cabbageSet "filer2",Smessage
 
 /* write file name to GUI */
 Sname FileNameFromPath    gSfilepath2                ; Call UDO to extract file name from the full path
 Smessage sprintfk "text(%s)",Sname                   ; create string to update text() identifier for label widget
 ;chnset Smessage, "stringbox2"                        ; send string to  widget
 cabbageSet "stringbox2",Smessage
 gkFileChans2 init  filenchnls:i(gSfilepath2)
endin



instr 9000    ; record file
 if gkrecord==0 then
             turnoff
 endif
 aL,aR monitor
 gkFileRecorded        init    1
 
 itim        date
 Stim        dates     itim
 itim        date
 Stim        dates     itim
 Syear       strsub    Stim, 20, 24
 Smonth      strsub    Stim, 4, 7
 Sday        strsub    Stim, 8, 10
 iday        strtod    Sday
 Shor        strsub    Stim, 11, 13
 Smin        strsub    Stim, 14, 16
 Ssec        strsub    Stim, 17, 19
 SDir        chnget    "USER_HOME_DIRECTORY"
 gSname      sprintf   "%s/CrossMorph_%s_%s_%02d_%s_%s_%s.wav", SDir, Syear, Smonth, iday, Shor,Smin, Ssec
 if gkrecord==1 then            ; record
             fout      gSname, 8, aL, aR
 endif
 gkRecordingActiveFlag =    1 - release()
endin

</CsInstruments>

<CsScore>
i 1    0 [60*60*24*7]    ;READ IN WIDGETS
i 10   0 [60*60*24*7]    ;MORPHER
</CsScore>

</CsoundSynthesizer>