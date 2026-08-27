
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; QuadExpander.csd
; Written by Iain McCurdy, 2024

; Expands a stereo recording into four channels	

; Input sound file should be a 2-channel interleaved file

; Speaker locations are indicated as numbered blue squares
; The four spokes indicate the direction in which the original four channels are directed
; The numbered white circles on the spokes indicate the channel number of the sound file to which that spoke relates.

;  The azimuth angle for each speaker can adjusted.
;  The entire speaker arrangement can be rotated using the arrowed buttons
  
; Spread - bleeds the signal from each channel into neighbouring outputs. 
;           Increasing this will weaken the sense of localisation of sounds in the original recording but can also prevent holes in the 
;           multi-speaker image.

; Rotate Stereo - rotates the orientation of the stereo array.
; Width         - angle of separation for how the stereo source is projected into the multi-channel array

; Preset       - for convenience, a range of common speaker set ups can be dialed in using selected presets.
;                Presets affect speaker azimuths, on/off status and LFE channel

; Open File    - browse for input sound file (must be 4-channel interleaved wav)
; PLAY         - play/stop sound file
; M,M,M,M      - mute individual tracks in the source file
; In-Skip      - location within the source sound file from which to begin playback

; Output angles of the four channels of the source sound file in the expanded output. These will correspond to angles of the four spokes.

<Cabbage>
form caption("Quad Expander") size(945,640), pluginId("QuEx"), guiMode("queue"), colour(50,50,50)

image bounds( 15, 15,400,400), colour(0,0,0,0)
{
; XY panel
image bounds(  0, 0,400,400), colour(40,40,40), channel("panel"), outlineThickness(1), outlineColour("DarkGrey"), corners(200) ; xy panel

; LABEL
label bounds(  -100,-150,600,600), text("∞"), fontColour("white"), alpha(0.04), colour(0,0,0,0)

; axes
image    bounds( 200,  0,  1,200), channel("AxisL"), rotate(-0.785,  0,200), colour("DarkGrey")
image    bounds( 200,  0,  1,200), channel("AxisR"), rotate( 0.785,  0,200), colour("DarkGrey")

; speakers
label    bounds(-100,192, 16, 16), channel("Spk1"), alpha(0.5), text("1"), fontColour("white"), colour("Blue")
label    bounds(-100,192, 16, 16), channel("Spk2"), alpha(0.5), text("2"), fontColour("white"), colour("Blue")
label    bounds(-100,192, 16, 16), channel("Spk3"), alpha(0.5), text("3"), fontColour("white"), colour("Blue")
label    bounds(-100,192, 16, 16), channel("Spk4"), alpha(0.5), text("4"), fontColour("white"), colour("Blue")

; rotate
label    bounds(345,  0, 51, 13), text("ROTATE"), align("centre")
button   bounds(345, 15, 25, 25), channel("DecrAz"), text("<"), latched(0), corners(12)
button   bounds(372, 15, 25, 25), channel("IncrAz"), text(">"), latched(0), corners(12)

; audio outputs
label    bounds(120,120, 20, 20), channel("Aud1"), alpha(0.5), text("L"), fontColour("white"), colour(255,255,255,100), corners(10)
label    bounds(260,120, 20, 20), channel("Aud2"), alpha(0.5), text("R"), fontColour("white"), colour(255,255,255,100), corners(10)
}


image    bounds(450, 10,510,100), colour(0,0,0,0)
{
; speakers set-up
image    bounds(  0,  0,100,100), colour(0,0,0,0), outlineThickness(1), corners(5)
{
label    bounds(  0,  5,100, 25), text("1")
checkbox bounds( 15, 40, 70, 12), channel("OnOff1"), text("On/Off"), value(1), shape("ellipse")
nslider  bounds( 15, 60, 70, 30), channel("azim1"), text("Azim.1"), range(-360,360,-45)
}
image    bounds(110,  0,100,100), colour(0,0,0,0), outlineThickness(1), corners(5)
{
label    bounds(  0,  5,100, 25), text("2")
checkbox bounds( 15, 40, 70, 12), channel("OnOff2"), text("On/Off"), value(1), shape("ellipse")
nslider  bounds( 15, 60, 70, 30), channel("azim2"), text("Azim.2"), range(-360,360,45)
}
image    bounds(220,  0,100,100), colour(0,0,0,0), outlineThickness(1), corners(5)
{
label    bounds(  0,  5,100, 25), text("3")
checkbox bounds( 15, 40, 70, 12), channel("OnOff3"), text("On/Off"), value(1), shape("ellipse")
nslider  bounds( 15, 60, 70, 30), channel("azim3"), text("Azim.3"), range(-360,360,-135)
}
image    bounds(330,  0,100,100), colour(0,0,0,0), outlineThickness(1), corners(5)
{
label    bounds(  0,  5,100, 25), text("4")
checkbox bounds( 15, 40, 70, 12), channel("OnOff4"), text("On/Off"), value(1), shape("ellipse")
nslider  bounds( 15, 60, 70, 30), channel("azim4"), text("Azim.4"), range(-360,360,135)
}
}

; connection matrix
image   bounds(420,120,250,145), colour(0,0,0,0) 
{
label    bounds( 70,  4,150, 15), text("SPEAKER"), align("centre")
label    bounds(  0, 74, 80, 15), text("OUTPUT"), align("centre"), rotate(1.57,40,7.5)
gentable bounds( 70, 40,160, 20), tableNumber(1), ampRange(0,1,1), active(1), tableBackgroundColour(0, 0, 0, 0), tableColour(147, 210, 0) zoom(-1), ampRange(0, 1, -1, 1)
gentable bounds( 70, 60,160, 20), tableNumber(2), ampRange(0,1,1), active(1), tableBackgroundColour(0, 0, 0, 0), tableColour(147, 210, 0) zoom(-1), ampRange(0, 1, -1, 1)
gentable bounds( 70, 80,160, 20), tableNumber(3), ampRange(0,1,1), active(1), tableBackgroundColour(0, 0, 0, 0), tableColour(147, 210, 0) zoom(-1), ampRange(0, 1, -1, 1)
gentable bounds( 70,100,160, 20), tableNumber(4), ampRange(0,1,1), active(1), tableBackgroundColour(0, 0, 0, 0), tableColour(147, 210, 0) zoom(-1), ampRange(0, 1, -1, 1)
label    bounds( 50, 42, 20, 16), text("1")
label    bounds( 50, 62, 20, 16), text("2")
label    bounds( 50, 82, 20, 16), text("3")
label    bounds( 50,102, 20, 16), text("4")
label    bounds( 70, 20, 20, 16), text("1")
label    bounds( 90, 20, 20, 16), text("2")
label    bounds(110, 20, 20, 16), text("3")
label    bounds(130, 20, 20, 16), text("4")
label    bounds(150, 20, 20, 16), text("5")
label    bounds(170, 20, 20, 16), text("6")
label    bounds(190, 20, 20, 16), text("7")
label    bounds(210, 20, 20, 16), text("8")
}

; meters
image   bounds(670,120,420,132), colour(0,0,0,0)
{
vmeter  bounds(  0, 25, 20, 85) channel("VUMeter1") value(0) overlayColour(0, 0, 0, 255) meterColour:0(255, 255, 0) meterColour:1(255, 103, 171) meterColour:2(250,250, 0) outlineThickness(0)
vmeter  bounds( 30, 25, 20, 85) channel("VUMeter2") value(0) overlayColour(0, 0, 0, 255) meterColour:0(255, 255, 0) meterColour:1(255, 103, 171) meterColour:2(250,250, 0) outlineThickness(0)
vmeter  bounds( 60, 25, 20, 85) channel("VUMeter3") value(0) overlayColour(0, 0, 0, 255) meterColour:0(255, 255, 0) meterColour:1(255, 103, 171) meterColour:2(250,250, 0) outlineThickness(0)
vmeter  bounds( 90, 25, 20, 85) channel("VUMeter4") value(0) overlayColour(0, 0, 0, 255) meterColour:0(255, 255, 0) meterColour:1(255, 103, 171) meterColour:2(250,250, 0) outlineThickness(0)
label   bounds(  0,110, 20, 12), text("1")
label   bounds( 30,110, 20, 12), text("2")
label   bounds( 60,110, 20, 12), text("3")
label   bounds( 90,110, 20, 12), text("4")
vslider bounds(120, 20, 65,103), channel("MeterGain"), text("Mtr.Gain"), range(1,20,1,0.5)
vslider bounds(180, 20, 65,103), channel("OutGain"), text("Out Gain"), range(0,4,1,0.5)
}

image    bounds(450,300,510,800), colour(0,0,0,0)
{
hslider  bounds(  0,  0,480, 15), channel("spread"), text("Spread"), range(0,100,0,1,1), valueTextBox(1)
hslider  bounds(  0, 30,480, 15), channel("RotateStereo"), text("Rotate Stereo"), range(-720,720,0,1,0.1), valueTextBox(1)
hslider  bounds(  0, 60,480, 15), channel("StereoWidth"), text("Stereo Width"), range(-720,720,90,1,1), valueTextBox(1)
}

}

; file player
image bounds( 10,430,930,210) colour(0,0,0,0)
{
filebutton bounds(  0,  5, 70, 70), text("OPEN FILE","OPEN FILE"), fontColour("white") channel("filename"), corners(35), fontColour:0("silver"), colour:0(50,50,100), colour:1(50,50,100)
button     bounds(  0, 85, 70, 70), text("PLAY","STOP"), fontColour("white") channel("Play"), latched(1), corners(35), fontColour:0("lime"), colour:0(10,55,10), colour:1(200,70,70)
soundfiler bounds(110,  0,750,160), channel("beg","len"), channel("filer1"),  colour(0, 255, 255, 255), fontColour(160, 160, 160, 255)
image      bounds(110,  0,  1,160), channel("wiper")
label      bounds(112,  3,750, 14), text(""), align("left"), colour(0,0,0,0), fontColour(200,200,200), channel("FileName")
hslider    bounds(105,165,760, 20), channel("inskip"), range(0,1,0)
label      bounds(105,185,760, 14), text("In-Skip")
button     bounds( 77, 31, 26, 26), text("M","M"), fontColour("white") channel("Mute1"), latched(1), corners(35), fontColour:0("white"), fontColour:1("black"), colour:0(70,70,0), colour:1(255,255,0)
button     bounds( 77, 97, 26, 26), text("M","M"), fontColour("white") channel("Mute2"), latched(1), corners(35), fontColour:0("white"), fontColour:1("black"), colour:0(70,70,0), colour:1(255,255,0)

nslider    bounds(865, 31, 70, 26), channel("ChnAz1"), range(-360,360,0,1,1)
nslider    bounds(865, 97, 70, 26), channel("ChnAz2"), range(-360,360,0,1,1)

label      bounds(115, 34, 20, 20), channel("Chn1"), alpha(0.5), text("L"), fontColour("black"), colour(255,255,255), corners(10)
label      bounds(115,100, 20, 20), channel("Chn2"), alpha(0.5), text("R"), fontColour("black"), colour(255,255,255), corners(10)
}

label      bounds(  5,625,690, 12), text("Iain McCurdy |2024|"), align("left")

</Cabbage>

<CsoundSynthesizer>
<CsOptions>
-n -dm0
</CsOptions>

<CsInstruments>
ksmps  = 64
nchnls = 8
0dbfs  = 1

gaFile1,gaFile2   init                0

giMatrix ftgen 1,0,8,-2,1,0,0,0,0,0,0,0
giMatrix ftgen 2,0,8,-2,0,1,0,0,0,0,0,0
giMatrix ftgen 3,0,8,-2,0,0,1,0,0,0,0,0
giMatrix ftgen 4,0,8,-2,0,0,0,1,0,0,0,0

instr 1

 ; load file from browse
 gSfilepath       cabbageGetValue     "filename"  ; read in file path string from filebutton widget
 if changed:k(gSfilepath)==1 then              ; call instrument to update waveform viewer  
                  event               "i",99,0,0
 endif 
  
 ; play sound file
 gkPlay           cabbageGetValue     "Play"
 if trigger:k(gkPlay,0.5,0) == 1 then
                  event               "i",101,0,3600
 endif

; move speakers
kwidth            cabbageGetValue     "width"
kazim1            cabbageGetValue     "azim1"
kazim2            cabbageGetValue     "azim2"
kazim3            cabbageGetValue     "azim3"
kazim4            cabbageGetValue     "azim4"
kazim1             init                -45 ; set initial values for i-time pass
kazim2             init                45
kazim3             init                -135
kazim4             init                135

                  cabbageSet          changed:k(kazim1), "Spk1", "bounds",  192 + (193*sin(kazim1*$M_PI/180)),192 - (193*cos(kazim1*$M_PI/180)), 16, 16
                  cabbageSet          changed:k(kazim2), "Spk2", "bounds",  192 + (193*sin(kazim2*$M_PI/180)),192 - (193*cos(kazim2*$M_PI/180)), 16, 16
                  cabbageSet          changed:k(kazim3), "Spk3", "bounds",  192 + (193*sin(kazim3*$M_PI/180)),192 - (193*cos(kazim3*$M_PI/180)), 16, 16
                  cabbageSet          changed:k(kazim4), "Spk4", "bounds",  192 + (193*sin(kazim4*$M_PI/180)),192 - (193*cos(kazim4*$M_PI/180)), 16, 16

; rotate speaker array buttons
kDecrAz           cabbageGetValue     "DecrAz"
kIncrAz           cabbageGetValue     "IncrAz"
kAzTimer          metro               16        ; speed of rotation of speaker array if buttons are used
iAzStep = 0.5                                   ; rotation increment (also impacts speed of rotation)
if kDecrAz==1 then                                                   ; anticlockwise rotate
                  cabbageSetValue     "azim1", kazim1-iAzStep, kAzTimer
                  cabbageSetValue     "azim2", kazim2-iAzStep, kAzTimer
                  cabbageSetValue     "azim3", kazim3-iAzStep, kAzTimer
                  cabbageSetValue     "azim4", kazim4-iAzStep, kAzTimer
elseif kIncrAz==1 then                                               ; clockwise rotate
                  cabbageSetValue     "azim1", kazim1+iAzStep, kAzTimer
                  cabbageSetValue     "azim2", kazim2+iAzStep, kAzTimer
                  cabbageSetValue     "azim3", kazim3+iAzStep, kAzTimer
                  cabbageSetValue     "azim4", kazim4+iAzStep, kAzTimer
endif


; rotate axes
kRotateStereo,kT1 cabbageGetValue     "RotateStereo"
kRotateStereo     port                kRotateStereo, 0.05
kStereoWidth,kT2  cabbageGetValue     "StereoWidth"
kaz1              =                   kRotateStereo - (kStereoWidth*0.5)
kaz2              =                   kRotateStereo + (kStereoWidth*0.5)
                  cabbageSet          kT1+kT2, "AxisL", "rotate", ((kaz1/360) * 2 * $M_PI),   0,200
                  cabbageSet          kT1+kT2, "AxisR", "rotate", ((kaz2/360) * 2 * $M_PI),   0,200

; rotate channel indicators on the spokes
                  cabbageSet          kT1+kT2, "Aud1", "bounds",  190 + (100*sin(kaz1*$M_PI/180)),190 - (100*cos(kaz1*$M_PI/180)), 20, 20
                  cabbageSet          kT1+kT2, "Aud2", "bounds",  190 + (100*sin(kaz2*$M_PI/180)),190 - (100*cos(kaz2*$M_PI/180)), 20, 20

idim               =                   2
if changed:k(kazim1,kazim2,kazim3,kazim4)==1 then
 reinit REBUILD_SPEAKER_DEF
endif
REBUILD_SPEAKER_DEF:
iSpkrs[]           fillarray           i(kazim1), i(kazim2), i(kazim3), i(kazim4)
                   vbaplsinit          idim, lenarray:i(iSpkrs), iSpkrs

; INPUT
if gkPlay==0 then
 gaFile1 inch 1
 gaFile2 inch 2
endif ; otherwise will be file playback


; CALCULATE OUTPUTS USING vbap
kel               =                   0
kspread           cabbageGetValue     "spread"        ; spill between speakers


; channel 1
a1_1,a1_2,a1_3,a1_4  vbap gaFile1, kaz1 , kel, kspread
;aOuts1[]            vbap                gaFile1, kaz1, kel, kspread
                  cabbageSetValue     "ChnAz1",kaz1

; channel 2
a2_1,a2_2,a2_3,a2_4  vbap gaFile2, kaz2 , kel, kspread
;aOuts2[]            vbap                gaFile2, kaz2, kel, kspread
                  cabbageSetValue     "ChnAz2",kaz2
rireturn

; OUTPUT MAIN SPEAKERS
; mix 4 outputs
a1                =                   sum:a(a1_1,a2_1)
a2                =                   sum:a(a1_2,a2_2)
a3                =                   sum:a(a1_3,a2_3)
a4                =                   sum:a(a1_4,a2_4)

; on/off switches
kOnOff1,kT1       cabbageGetValue     "OnOff1"
kOnOff2,kT2       cabbageGetValue     "OnOff2"
kOnOff3,kT3       cabbageGetValue     "OnOff3"
kOnOff4,kT4       cabbageGetValue     "OnOff4"
a1                *=                  kOnOff1
a2                *=                  kOnOff2
a3                *=                  kOnOff3
a4                *=                  kOnOff4


; send to speakers
kOutGain           cabbageGetValue    "OutGain"
ao1                sum                 a1 * tab:k(k(0), 1), a2 * tab:k(k(0), 2), a3 * tab:k(k(0), 3), a4 * tab:k(k(0), 4)
ao2                sum                 a1 * tab:k(k(1), 1), a2 * tab:k(k(1), 2), a3 * tab:k(k(1), 3), a4 * tab:k(k(1), 4)
ao3                sum                 a1 * tab:k(k(2), 1), a2 * tab:k(k(2), 2), a3 * tab:k(k(2), 3), a4 * tab:k(k(2), 4)
ao4                sum                 a1 * tab:k(k(3), 1), a2 * tab:k(k(3), 2), a3 * tab:k(k(3), 3), a4 * tab:k(k(3), 4)
ao5                sum                 a1 * tab:k(k(4), 1), a2 * tab:k(k(4), 2), a3 * tab:k(k(4), 3), a4 * tab:k(k(4), 4)
ao6                sum                 a1 * tab:k(k(5), 1), a2 * tab:k(k(5), 2), a3 * tab:k(k(5), 3), a4 * tab:k(k(5), 4)
ao7                sum                 a1 * tab:k(k(6), 1), a2 * tab:k(k(6), 2), a3 * tab:k(k(6), 3), a4 * tab:k(k(6), 4)
ao8                sum                 a1 * tab:k(k(7), 1), a2 * tab:k(k(7), 2), a3 * tab:k(k(7), 3), a4 * tab:k(k(7), 4)
                   outo                ao1, ao2, ao3, ao4, ao5, ao6, ao7, ao8


; METERS
kMeterGain        cabbageGetValue     "MeterGain"
kUpdate           metro               32                       ; rate up update of the VU meters
#define meter(N)
#
kres$N            init                0
kres$N            limit               kres$N-0.001,0,1         ; decay of peak reading, increase subtraction value to speed up decay
kres$N            peak                a$N
                  cabbageSetValue     "VUMeter$N",kres$N * kMeterGain, kUpdate
#
$meter(1)
$meter(2)
$meter(3)
$meter(4)

; clear global audio variable to prevent buzzing if play button is stopped
                  clear               gaFile1, gaFile2

endin






; LOAD SOUND FILE
instr    99
 cabbageSetValue  "Play",0
                  cabbageSet          "filer1", "file", gSfilepath
 ; write file name to GUI
 SFileNoExtension cabbageGetFileNoExtension gSfilepath
                  cabbageSet          "FileName", "text", SFileNoExtension
endin

; play sound file
instr 101
if gkPlay==0 then
 turnoff
endif
kinskip cabbageGetValue "inskip"
if changed:k(kinskip)==1 then
                  reinit              RESTART
endif
RESTART:
 gaFile1,gaFile2 diskin2 gSfilepath,1,i(kinskip)*filelen:i(gSfilepath),1
 kPtr            phasor  1/(filelen:i(gSfilepath)),i(kinskip)
 rireturn
                  cabbageSet          metro:k(16), "wiper", "bounds", 110 + kPtr*750, 0, 1, 160
 gaFile1          *=                  1 - cabbageGetValue:k("Mute1") ; apply mutes
 gaFile2          *=                  1 - cabbageGetValue:k("Mute2")
endin



</CsInstruments>

<CsScore>
i 1 0 z
</CsScore>

</CsoundSynthesizer>
