
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; Written by Iain McCurdy, 2026

; Stereo input, octo out sound spatialisation

; Diffuses a stereo file to eight channel, maintaining diametric positions of the two channels.
; User-controlled movement of the stereo input is in two dimensions: front to back and tilt.
; These two parameters can be controlled easily using the XY pad which will then also illustrate the speakers 
;  to which the two stereo signals will be directed.
 
;  (In the code, the XY pad drives the sliders but the values used are ultimately taken from the sliders.)

<Cabbage>
form caption("Stereo to Octophonic") size(820,490), guiMode("queue"), pluginId("StOc"), colour(40,40,40)


; xy pad
xypad bounds( -10, -10,420,484), colour(0,0,0,0), ballColour("White"), channel("X","Y"), rangeX(-1,1,0), rangeY(-1,1,0), alpha(0.7)

; direction
image    bounds(0,200,400,2), alpha(0.5), channel("direction"), rotate(0,200,1), colour("yellow")

; blanking panel
;image    bounds(0,400,400,200), colour(40,40,40)


; xy sliders
hslider  bounds( 420,105,400, 10), channel("FrontBack"), range(-1,1,0), valueTextBox(1), text("Front/Back")
hslider  bounds( 420,135,400, 10), channel("Tilt"), range(-1,1,0), valueTextBox(1), text("Tilt")
hslider  bounds( 420,170,400, 10), channel("Gain"), range(0,20,1,0.5,0.001), valueTextBox(1), text("Gain")

; speakers
label    bounds(-100,192, 16, 16), channel("Spk1"), alpha(0.1), text("1"), fontColour("white"), colour("Blue")
label    bounds(-100,192, 16, 16), channel("Spk2"), alpha(0.1), text("2"), fontColour("white"), colour("Blue")
label    bounds(-100,192, 16, 16), channel("Spk3"), alpha(0.1), text("3"), fontColour("white"), colour("Blue")
label    bounds(-100,192, 16, 16), channel("Spk4"), alpha(0.1), text("4"), fontColour("white"), colour("Blue")
label    bounds(-100,192, 16, 16), channel("Spk5"), alpha(0.1), text("5"), fontColour("white"), colour("Blue")
label    bounds(-100,192, 16, 16), channel("Spk6"), alpha(0.1), text("6"), fontColour("white"), colour("Blue")
label    bounds(-100,192, 16, 16), channel("Spk7"), alpha(0.1), text("7"), fontColour("white"), colour("Blue")
label    bounds(-100,192, 16, 16), channel("Spk8"), alpha(0.1), text("8"), fontColour("white"), colour("Blue")

nslider bounds(425, 10, 70, 30), channel("azim1"), text("Azim.1"), range(-360,360,0.001)
nslider bounds(500, 10, 70, 30), channel("azim2"), text("Azim.2"), range(-360,360,45)
nslider bounds(575, 10, 70, 30), channel("azim3"), text("Azim.3"), range(-360,360,90)
nslider bounds(650, 10, 70, 30), channel("azim4"), text("Azim.4"), range(-360,360,135)
nslider bounds(425, 50, 70, 30), channel("azim5"), text("Azim.5"), range(-360,360,180)
nslider bounds(500, 50, 70, 30), channel("azim6"), text("Azim.6"), range(-360,360,225)
nslider bounds(575, 50, 70, 30), channel("azim7"), text("Azim.7"), range(-360,360,270)
nslider bounds(650, 50, 70, 30), channel("azim8"), text("Azim.8"), range(-360,360,315)

label   bounds(740,  5, 51, 13), text("ROTATE"), align("centre")
button  bounds(740, 20, 25, 20), channel("DecrAz"), text("<"), latched(0)
button  bounds(767, 20, 25, 20), channel("IncrAz"), text(">"), latched(0)

; presets
label    bounds(725, 50, 80, 14), text("PRESET:"), align("centre")
combobox bounds(725, 65, 80, 22), channel("Preset"), items("Ring 1","Ring 2","St. Pairs 1","St. Pairs 2"), value(1)


; meters
image   bounds(415,200,395,167), colour(0,0,0,0), outlineThickness(1)
{
label   bounds(  0,  3,395, 14), text("OUTPUT METERS")
vmeter  bounds( 20, 23, 40,130) channel("VUMeter1") value(0) overlayColour(0, 0, 0, 255) meterColour:0(255, 255, 0) meterColour:1(255, 103, 171) meterColour:2(250,250, 0) outlineThickness(0)
vmeter  bounds( 65, 23, 40,130) channel("VUMeter2") value(0) overlayColour(0, 0, 0, 255) meterColour:0(255, 255, 0) meterColour:1(255, 103, 171) meterColour:2(250,250, 0) outlineThickness(0)
vmeter  bounds(110, 23, 40,130) channel("VUMeter3") value(0) overlayColour(0, 0, 0, 255) meterColour:0(255, 255, 0) meterColour:1(255, 103, 171) meterColour:2(250,250, 0) outlineThickness(0)
vmeter  bounds(155, 23, 40,130) channel("VUMeter4") value(0) overlayColour(0, 0, 0, 255) meterColour:0(255, 255, 0) meterColour:1(255, 103, 171) meterColour:2(250,250, 0) outlineThickness(0)
vmeter  bounds(200, 23, 40,130) channel("VUMeter5") value(0) overlayColour(0, 0, 0, 255) meterColour:0(255, 255, 0) meterColour:1(255, 103, 171) meterColour:2(250,250, 0) outlineThickness(0)
vmeter  bounds(245, 23, 40,130) channel("VUMeter6") value(0) overlayColour(0, 0, 0, 255) meterColour:0(255, 255, 0) meterColour:1(255, 103, 171) meterColour:2(250,250, 0) outlineThickness(0)
vmeter  bounds(290, 23, 40,130) channel("VUMeter7") value(0) overlayColour(0, 0, 0, 255) meterColour:0(255, 255, 0) meterColour:1(255, 103, 171) meterColour:2(250,250, 0) outlineThickness(0)
vmeter  bounds(335, 23, 40,130) channel("VUMeter8") value(0) overlayColour(0, 0, 0, 255) meterColour:0(255, 255, 0) meterColour:1(255, 103, 171) meterColour:2(250,250, 0) outlineThickness(0)
label   bounds( 20,153, 40, 12), text("1")
label   bounds( 65,153, 40, 12), text("2")
label   bounds(110,153, 40, 12), text("3")
label   bounds(155,153, 40, 12), text("4")
label   bounds(200,153, 40, 12), text("5")
label   bounds(245,153, 40, 12), text("6")
label   bounds(290,153, 40, 12), text("7")
label   bounds(335,153, 40, 12), text("8")
}

; test
button   bounds(415,395, 70, 20), channel("test"), latched(1), text("TEST"), colour:0(0,0,0), colour:1(100,200,100)

; file player
image bounds(415,420,400,200) colour(0,0,0,0)
{
filebutton bounds(  0,  0, 70, 20), text("OPEN FILE","OPEN FILE"), fontColour("white") channel("filename")
button     bounds(  0, 30, 70, 20), text("PLAY","PLAY"), fontColour("white") channel("Play"), latched(1), colour:0(10,55,10), colour:1(70,200,70)
soundfiler bounds( 80,  0,330, 50), channel("beg","len"), channel("filer1"),  colour(0, 255, 255, 255), fontColour(160, 160, 160, 255)
label      bounds( 80,  3,290, 14), text(""), align(left), colour(0,0,0,0), fontColour(200,200,200), channel("FileName")
}

label      bounds( 5,476,110, 12), text("Iain McCurdy |2026|"), align("left")

</Cabbage>

<CsoundSynthesizer>
<CsOptions>
-n -dm0
</CsOptions>
<CsInstruments>

; Initialize the global variables. 
ksmps  = 32
nchnls = 8
0dbfs  = 1



gkNChnls init 0
gaFileL,gaFileR init 0




instr 1 ; always on
 ; speaker array presets
 kPreset cabbageGetValue "Preset"
 kPreset init 1 
 ;                             azim1   azim2  azim3  azim4  azim5  azim6   azim7  azim8
 giPreset1  ftgen  1,0,8,-2,   0,      45,    90,    135,   180,   225,    270,   315
 giPreset2  ftgen  2,0,8,-2,   -22.5,  22.5,  67.5,  112.5, 157.5, 202.5,  247.5, 292.5
 giPreset3  ftgen  3,0,8,-2,   -22.5,  22.5, -67.5,  67.5, -112.5, 112.5, -157.5, 157.5
 giPreset4  ftgen  4,0,8,-2,   -22.5,  22.5, -56.25, 56.25,   -90,    90,     -135,  135
 if changed:k(kPreset)==1 then
  reinit SendPreset
 endif
 SendPreset:
 iCount = 0
 while iCount<ftlen(i(kPreset)) do
 SChan sprintf "azim%d",iCount+1
    cabbageSetValue SChan, table:i(iCount,  i(kPreset) )
 iCount += 1
 od
 rireturn

 ; load file from browse
 gSfilepath        cabbageGetValue     "filename"        ; read in file path string from filebutton widget
 if changed:k(gSfilepath)==1 then        ; call instrument to update waveform viewer  
                   event               "i",99,0,0
 endif 
 
 gkPlay cabbageGetValue "Play"
 if trigger:k(gkPlay,0.5,0) == 1 then
                   event               "i",101,0,3600
 endif
kporttime          linseg              0, 0.001, 0.05


 ; audio source
 aL                inch                1 
 aR                inch                2
 ; sound file playback
 if gkPlay==1 then
   aL              =                   gaFileL
   aR              =                   gaFileR
   gaFileL         =                   0       ; clear audio variables
   gaFileR         =                   0       ; clear audio variables
 endif
 
 if cabbageGetValue:k("test")==1 then
  aL               pinkish             0.2
  aR               pinkish             0.2
 endif
 
 kGain             cabbageGetValue     "Gain"
 aGain             interp              kGain
 aL                *=                  aGain
 aR                *=                  aGain

;                   cabbageSetValue     "azim1", 0, k(1)
; move speakers
kazim1             cabbageGetValue     "azim1"
kazim2             cabbageGetValue     "azim2"
kazim3             cabbageGetValue     "azim3"
kazim4             cabbageGetValue     "azim4"
kazim5             cabbageGetValue     "azim5"
kazim6             cabbageGetValue     "azim6"
kazim7             cabbageGetValue     "azim7"
kazim8             cabbageGetValue     "azim8"
kazim1             init                0 ; set initial values for i-time pass
kazim2             init                45
kazim3             init                90
kazim4             init                135
kazim5             init                180
kazim6             init                225
kazim7             init                270
kazim8             init                315
              
                   cabbageSet          changed:k(kazim1), "Spk1", "bounds",  192 + (193*sin(kazim1*$M_PI/180)),192 - (193*cos(kazim1*$M_PI/180)), 16, 16
                   cabbageSet          changed:k(kazim2), "Spk2", "bounds",  192 + (193*sin(kazim2*$M_PI/180)),192 - (193*cos(kazim2*$M_PI/180)), 16, 16
                   cabbageSet          changed:k(kazim3), "Spk3", "bounds",  192 + (193*sin(kazim3*$M_PI/180)),192 - (193*cos(kazim3*$M_PI/180)), 16, 16
                   cabbageSet          changed:k(kazim4), "Spk4", "bounds",  192 + (193*sin(kazim4*$M_PI/180)),192 - (193*cos(kazim4*$M_PI/180)), 16, 16
                   cabbageSet          changed:k(kazim5), "Spk5", "bounds",  192 + (193*sin(kazim5*$M_PI/180)),192 - (193*cos(kazim5*$M_PI/180)), 16, 16
                   cabbageSet          changed:k(kazim6), "Spk6", "bounds",  192 + (193*sin(kazim6*$M_PI/180)),192 - (193*cos(kazim6*$M_PI/180)), 16, 16
                   cabbageSet          changed:k(kazim7), "Spk7", "bounds",  192 + (193*sin(kazim7*$M_PI/180)),192 - (193*cos(kazim7*$M_PI/180)), 16, 16
                   cabbageSet          changed:k(kazim8), "Spk8", "bounds",  192 + (193*sin(kazim8*$M_PI/180)),192 - (193*cos(kazim8*$M_PI/180)), 16, 16

; rotate speaker array
kDecrAz            cabbageGetValue     "DecrAz"
kIncrAz            cabbageGetValue     "IncrAz"
kAzTimer           metro               16
iAzStep            =                   0.5
if kDecrAz==1 then
                   cabbageSetValue     "azim1", kazim1-iAzStep, kAzTimer
                   cabbageSetValue     "azim2", kazim2-iAzStep, kAzTimer
                   cabbageSetValue     "azim3", kazim3-iAzStep, kAzTimer
                   cabbageSetValue     "azim4", kazim4-iAzStep, kAzTimer
                   cabbageSetValue     "azim5", kazim5-iAzStep, kAzTimer
                   cabbageSetValue     "azim6", kazim6-iAzStep, kAzTimer
                   cabbageSetValue     "azim7", kazim7-iAzStep, kAzTimer
                   cabbageSetValue     "azim8", kazim8-iAzStep, kAzTimer
elseif kIncrAz==1 then
                   cabbageSetValue     "azim1", kazim1+iAzStep, kAzTimer
                   cabbageSetValue     "azim2", kazim2+iAzStep, kAzTimer
                   cabbageSetValue     "azim3", kazim3+iAzStep, kAzTimer
                   cabbageSetValue     "azim4", kazim4+iAzStep, kAzTimer
                   cabbageSetValue     "azim5", kazim5+iAzStep, kAzTimer
                   cabbageSetValue     "azim6", kazim6+iAzStep, kAzTimer
                   cabbageSetValue     "azim7", kazim7+iAzStep, kAzTimer
                   cabbageSetValue     "azim8", kazim8+iAzStep, kAzTimer
endif

if changed:k(kazim1,kazim2,kazim3,kazim4,kazim5,kazim6,kazim7,kazim8)==1 then
 reinit REBUILD_SPEAKER_DEF
endif
REBUILD_SPEAKER_DEF:
iSpkrs[]           fillarray           i(kazim1), i(kazim2), i(kazim3), i(kazim4), i(kazim5), i(kazim6), i(kazim7), i(kazim8)
                   vbaplsinit          2, lenarray:i(iSpkrs), iSpkrs


kFrontBack         =                   (cabbageGetValue:k("FrontBack") * 45) + 45
kTilt              =                   cabbageGetValue:k("Tilt") * 180

kX                 cabbageGetValue     "X"
kY                 cabbageGetValue     "Y"

                   cabbageSetValue     "Tilt", kX, changed:k(kX)
                   cabbageSetValue     "FrontBack", kY, changed:k(kY)

; move direction indicator
cabbageSet changed:k(kFrontBack), "direction", "bounds", 0,200+(-(kFrontBack/45-1)*137),400,2
cabbageSet changed:k(kTilt), "direction", "rotate", (kTilt/360) * 2 * $M_PI, 200, 1


;; direction
;image    bounds(0,200,400,1), alpha(0.2), channel("direction"), rotate(0,200,1)

; LFO
;kLFO               phasor              .1
;                   cabbageSetValue     "Tilt", kLFO*2 - 1

kelev              =                   0
kbleed             =                   0
kFrontBack         portk               kFrontBack, kporttime
kTilt              portk               kTilt, kporttime
aOutsL[]           vbap                aL, 135 - kFrontBack + kTilt, kelev, kbleed
aOutsR[]           vbap                aR, 225 + kFrontBack + kTilt, kelev, kbleed

aOutsMix[]         init                lenarray:i(iSpkrs) ; mix outputs of the two vbaps

kMtrScl            =                   5  ; VU meters scale
kAlpScl            =                   10 ; alpha scale on speakers

kRMS[]             init                lenarray:i(iSpkrs)

kCount             =                   0
while kCount<lenarray:i(iSpkrs) do
aOutsMix[kCount]   =                   aOutsL[kCount] + aOutsR[kCount]
                   outch kCount+1, aOutsMix[kCount]
kCount             +=                  1
od


;outo aOutsMix[0], aOutsMix[1], aOutsMix[2], aOutsMix[3], aOutsMix[4], aOutsMix[5], aOutsMix[6], aOutsMix[7]

; rms for each output channel
kRMS[0]            rms                 aOutsMix[0]
kRMS[1]            rms                 aOutsMix[1]
kRMS[2]            rms                 aOutsMix[2]
kRMS[3]            rms                 aOutsMix[3]
kRMS[4]            rms                 aOutsMix[4]
kRMS[5]            rms                 aOutsMix[5]
kRMS[6]            rms                 aOutsMix[6]
kRMS[7]            rms                 aOutsMix[7]

; update VU meters
                   cabbageSetValue     "VUMeter1", kRMS[0] * kMtrScl
                   cabbageSetValue     "VUMeter2", kRMS[1] * kMtrScl
                   cabbageSetValue     "VUMeter3", kRMS[2] * kMtrScl
                   cabbageSetValue     "VUMeter4", kRMS[3] * kMtrScl
                   cabbageSetValue     "VUMeter5", kRMS[4] * kMtrScl
                   cabbageSetValue     "VUMeter6", kRMS[5] * kMtrScl
                   cabbageSetValue     "VUMeter7", kRMS[6] * kMtrScl
                   cabbageSetValue     "VUMeter8", kRMS[7] * kMtrScl

; render rms outputs for each speaker as alpha values for each of those speakers
                   cabbageSet          changed:k(kRMS[0]), "Spk1", "alpha", kRMS[0]*kAlpScl + 0.1
                   cabbageSet          changed:k(kRMS[1]), "Spk2", "alpha", kRMS[1]*kAlpScl + 0.1
                   cabbageSet          changed:k(kRMS[2]), "Spk3", "alpha", kRMS[2]*kAlpScl + 0.1
                   cabbageSet          changed:k(kRMS[3]), "Spk4", "alpha", kRMS[3]*kAlpScl + 0.1
                   cabbageSet          changed:k(kRMS[4]), "Spk5", "alpha", kRMS[4]*kAlpScl + 0.1
                   cabbageSet          changed:k(kRMS[5]), "Spk6", "alpha", kRMS[5]*kAlpScl + 0.1
                   cabbageSet          changed:k(kRMS[6]), "Spk7", "alpha", kRMS[6]*kAlpScl + 0.1
                   cabbageSet          changed:k(kRMS[7]), "Spk8", "alpha", kRMS[7]*kAlpScl + 0.1
                                    
endin




; LOAD SOUND FILE
instr    99
 giSource       =                           0
                cabbageSet                  "filer1", "file", gSfilepath
 gkNChans       init                        filenchnls:i(gSfilepath)
 /* write file name to GUI */
 SFileNoExtension cabbageGetFileNoExtension gSfilepath
                  cabbageSet                "FileName","text",SFileNoExtension
endin

; play sound file
instr 101
if gkPlay==0 then
 turnoff
endif
if i(gkNChans)==1 then
 gaFileL         diskin2 gSfilepath,1,0,1
else
 gaFileL,gaFileR diskin2 gSfilepath,1,0,1
endif
endin




</CsInstruments>

<CsScore>
;causes Csound to run for about 7000 years...
i 1 0 z
</CsScore>

</CsoundSynthesizer>
