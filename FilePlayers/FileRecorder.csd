
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; FileRecorder.csd
; Written by Iain McCurdy, 2014, 2024
; 
; Records audio to a file on disk in the user's home directory. 
; This file may not appear until the csd is stopped and Cabbage is quit.
; 
; This is intended to be used within the Cabbage patcher in the Cabbage standalone application 
; - to facilitate capturing audio in real-time.
;
; The audio file name includes the date and time. (This idea comes courtesy of Rory Walsh.)
; The date and time in the file name will be prefixed by FileRecorder, 
;  unless a User File Name is typed into the text box in the GUI in which case this will be used, 
;  appended by the date and time.
; Note that you will need to hit return after typing in a name in order for it to be registered.

; Toggling record off and on will append the new recording onto the end of the previously recorded audio.
; To start a new file, click 'New File'.

; It may be necessary to stop and exit Cabbage in order for the file to be unlocked and usable in other software.

; Sample rate will be as set in Cabbage's settings or within the DAW host.

; Bit-depth is chosen from the options in the 'Format' drop-down menu.

; Number of channels can be selected from the 'Channels' drop-down menu. If 'Mono' is selected, only the left channels from any stereo input is used.

; Monitor dial controls the level of the live signal entering FileRecorder
; Playback dial controls the level of the play back of the most recently recorded file.



<Cabbage>
form caption("File Recorder") size(450,128), colour(0,0,0) pluginId("FRec"), guiMode("queue")
image               bounds(  0,  0,450,128), colour(100,100,100), outlineColour("Silver"), outlineThickness(3)

button   bounds( 10,  8, 75, 25), channel("record"), text("Record"), colour:0(50,10,10), colour:1(255,50,50), latched(1), fontColour:0("white"), fontColour:1("white"), corners(5)
button   bounds( 90,  8, 75, 25), channel("play"), text("Play"), colour:0(10,50,10), colour:1(50,255,50), latched(1), fontColour:0("white"), fontColour:1("white"), corners(5)
button   bounds(170,  8, 75, 25), channel("reset"), text("New File","New File"), colour:0(50,50,10), colour:1(250,250,100), latched(0), corners(5)

checkbox bounds( 10, 40, 65, 15), text("CLIP"), channel("red"), shape("ellipse"), value(1), fontColour:0("white"), fontColour:1("white") ;, active(0)
checkbox bounds( 10, 60, 65, 15), text("SIGNAL"), channel("green"), shape("ellipse"), value(1), fontColour:0("white"), fontColour:1("white");, active(0)

label    bounds( 80, 40, 130, 13), text("Format"), align("centre"), fontColour("white")
combobox bounds( 80, 55, 130, 20), channel("format"), items("16-bit ints", "32-bit ints", "32-bit floats", "8-bit unsigned ints", "24-bit ints", "64-bit floats", "ogg-vorbis"), value(3)


label    bounds(220, 40, 70, 13), text("Channels"), align("centre"), fontColour("white")
combobox bounds(220, 55, 70, 20), channel("channels"), items("Mono", "Stereo"), value(2)

rslider  bounds(290,  5, 80, 70), channel("MonitorLev"), text("Monitor"), range(0,1,1,0.5), trackerColour(200,200,200), textColour("white")
rslider  bounds(360,  5, 80, 70), channel("PlayLev"), text("Playback"), range(0,1,1,0.5), trackerColour(200,200,200), textColour("white")

label      bounds(  5, 95, 95,14), text("User File Name:"), fontColour("white")
texteditor bounds(105, 90,330,22) fontSize(16), channel("UserFileName"), scrollbars(0), wrap(0),  fontColour(0, 0, 0), colour(200,200,200)

label    bounds(  5,115,120, 10), text("Iain McCurdy |2014|"), align("left"), fontColour("Silver")

</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-n -dm0
</CsOptions>

<CsInstruments>

; sr set by host
ksmps  = 64
nchnls = 2
0dbfs  = 1

gkRecordingActiveFlag init       0
gkFileRecorded        init       0

giFormats[]  fillarray  4, 5, 6, 7, 8, 9, 50

instr    1
 gkformat    =                   giFormats[cabbageGetValue:k("format") - 1]
 gkchannels  cabbageGetValue     "channels"
 gaL         inch                1
 gaR         inch                2
 kMonitorLev cabbageGetValue     "MonitorLev"
             outs                gaL * kMonitorLev, gaR * kMonitorLev
             
 kRMS        rms                 (gaL+gaR)* 0.714
 
 gSUserFileName cabbageGetValue  "UserFileName"
 
 kTrig       metro               32
 kR          =                   kRMS > 0.05 ? 100 : 0
 kG          =                   kRMS > 0.05 ? 255 : 0
             cabbageSet          kTrig, "green", "colour:1", kR, kG, 0
 kR          =                   kRMS > 0.90 ? 255 : 0
             cabbageSet          kTrig, "red", "colour:1", kR, 0, 0
 
 gkrecord    cabbageGetValue     "record"
 gkreset     cabbageGetValue     "reset"
 gkplay      cabbageGetValue     "play"
 kRecStart   trigger             gkrecord,0.5,0

 if kRecStart==1 && gkRecordingActiveFlag==0 then
             event               "i",9000,0,-1
  gkRecordingActiveFlag =        1
 endif
 
 kPlayStart  trigger             gkplay,0.5,0
 if kPlayStart==1 && gkFileRecorded==1 then
             event               "i",9001,ksmps/sr,3600
 endif

 kResetTrig  trigger             gkreset,0.5,1
 if kResetTrig==1 && gkRecordingActiveFlag==1 then
             event               "i",9000,0,-1
 endif  
endin


instr 9000    ; record file
 if gkplay==1 then
             cabbageSetValue     "record",k(0),k(1)
             turnoff
 endif
 gkFileRecorded init             1
 
 SDir           cabbageGetValue    "USER_HOME_DIRECTORY"
 itim           date
 Stim           dates            itim
 itim           date
 Stim           dates            itim
 Syear          strsub           Stim, 20, 24
 Smonth         strsub           Stim, 4, 7
 Sday           strsub           Stim, 8, 10
 iday           strtod           Sday
 Shor           strsub           Stim, 11, 13
 Smin           strsub           Stim, 14, 16
 Ssec           strsub           Stim, 17, 19
 if strlen:i(gSUserFileName)==0 then
  gSname         sprintf   "%s/FileRecorder_%s_%s_%02d_%s_%s_%s.wav", SDir, Syear, Smonth, iday, Shor,Smin, Ssec
 else
  gSname         sprintf   "%s/%s_%s_%s_%02d_%s_%s_%s.wav", SDir, gSUserFileName, Syear, Smonth, iday, Shor,Smin, Ssec
 endif
                 prints           gSname
 if gkrecord==1 then ; record
  if i(gkchannels)==1 then ;(mono)
                fout      gSname, i(gkformat), gaL
  elseif i(gkchannels)==2 then ;(stereo)
                fout      gSname, i(gkformat), gaL, gaR
  endif
 endif
 gkRecordingActiveFlag =    1 - release()
endin



instr    9001     ; play file
 if gkplay==0 then
                turnoff
 endif 
   aL,aR        diskin2          gSname,1
 kPlayLev       cabbageGetValue  "PlayLev"

                outs             aL * kPlayLev, aR * kPlayLev
 iFileLen       filelen          gSname
 p3             =                iFileLen
                xtratim          0.1
                krelease         release
                cabbageSetValue  "play",1-krelease,k(1)
endin

</CsInstruments>  

<CsScore>
i 1 0 z
</CsScore>

</CsoundSynthesizer>