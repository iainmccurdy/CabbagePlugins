
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; FDN Octophonic Reverb
; Author: Iain McCurdy. 2026.

; An octophonic reverb based on a feedback delay network (FDN) design.
; Feedback is via a matrix which feeds the output of all reverb channels back into all channel, minus itself,
;  which produces a realistic diffusion between channels.
; This means that even when an input signal is fed into a specific channel, as it reverberates, 
;  it gradually bleeds into all other channels.
; Additionally, the delay times within the algorithm can be slowly randomly modulated, which, as well as
;  producing changing echo times, also produces modulating pitch variation effects.

; I N P U T
; MONO/STEREO/OCTOPHONIC - mono selects left channel and sends it to both channels of the stereo effect
; Input Gain  - input into the effect

; R E V E R B
; Pre Delay   - a delay applied to the signal before it enters the FDN reverb
; Smear       - amount of scattering of the signal entering the FDN reverb (this is carried out by a series of allpass filters)
; Reverb Time - the reverb time of the FDN reverb
; Damping     - the cutoff frequency of a lowpass filter (6dB/oct) applied to the signal in the feedback loop of the FDN reverb
; Mod.Rate    - rate of modulation of internal delays within the FDN reverb. This is heard in the blurring of frequencies as they are sustained within the reverb.
; Mod.Depth   - depth of modulation of internal delays within the FDN reverb. This is heard in the blurring of frequencies as they are sustained within the reverb.

; M I X
; Dry/Wet     - mix between the wet (reverb) and dry signal

<Cabbage>
form caption("Octophonic FDN Reverb") size(1015,308), colour(20,20,20) pluginId("ShRv"), guiMode("queue") 

#define DIAL_STYLE  trackerInsideRadius(0.8),  trackerColour(200,200,150), colour(160,160,170), textColour(200,200,150), fontColour(200,200,150), valueTextBox(1)
#define SLIDER_STYLE  trackerInsideRadius(0.8),  trackerColour(200,200,150), colour(160,160,170), textColour(200,200,150), fontColour(200,200,150), valueTextBox(0)

; left channel input
image bounds( 5,  5,210,285), colour(0,0,0,0), outlineColour("white"), outlineThickness(1)
label bounds( 5, 10,210, 15), text("I N P U T  1"), fontColour(200,200,150)
image bounds(10, 30,200,340), colour(0,0,0,0) ; binder
{
; speakers
image    bounds(3,3,194,194), colour(0,0,0,0), outlineThickness(1), outlineColour(255,255,255,50), shape("ellipse") ; circle
image    bounds(100,  0, 1,200), colour(255,255,255,50), rotate(-0.3925,0,100) ; spokes
image    bounds(100,  0, 1,200), colour(255,255,255,50), rotate(0.3925,0,100)
image    bounds(100,  0, 1,200), colour(255,255,255,50), rotate(1.1775,0,100)
image    bounds(100,  0, 1,200), colour(255,255,255,50), rotate(1.9625,0,100)
label    bounds(  56,  4, 16, 16), alpha(1), text("1"), fontColour("Black"), colour("White"), corners(8), channel("SpkrL1")
label    bounds( 129,  4, 16, 16), alpha(1), text("2"), fontColour("Black"), colour("White"), corners(8), channel("SpkrL2")
label    bounds( 180, 56, 16, 16), alpha(1), text("3"), fontColour("Black"), colour("White"), corners(8), channel("SpkrL3")
label    bounds( 180,129, 16, 16), alpha(1), text("4"), fontColour("Black"), colour("White"), corners(8), channel("SpkrL4")
label    bounds(  56,180, 16, 16), alpha(1), text("5"), fontColour("Black"), colour("White"), corners(8), channel("SpkrL5")
label    bounds( 129,180, 16, 16), alpha(1), text("6"), fontColour("Black"), colour("White"), corners(8), channel("SpkrL6")
label    bounds(   4,129, 16, 16), alpha(1), text("7"), fontColour("Black"), colour("White"), corners(8), channel("SpkrL7")
label    bounds(   4, 56, 16, 16), alpha(1), text("8"), fontColour("Black"), colour("White"), corners(8), channel("SpkrL8")
xypad    bounds(  0,  0,200,230), channel("XL","YL"), rangeX(-1,1,0), rangeY(-1,1,0), alpha(0.5)
hslider  bounds(  0,235,200, 20), text("Amp Falloff"),  channel("AmpFalloffL"),  range(0,60,0), $SLIDER_STYLE
}

; right channel input
image bounds(220,  5,210,285), colour(0,0,0,0), outlineColour("white"), outlineThickness(1)
label bounds(220, 10,210, 15), text("I N P U T  2"), fontColour(200,200,150)
image bounds(225, 25,200,340), colour(0,0,0,0)
{
; speakers
image    bounds(100,  0, 1,200), colour(255,255,255,100), rotate(-0.3925,0,100) ; spokes
image    bounds(100,  0, 1,200), colour(255,255,255,100), rotate(0.3925,0,100)
image    bounds(100,  0, 1,200), colour(255,255,255,100), rotate(1.1775,0,100)
image    bounds(100,  0, 1,200), colour(255,255,255,100), rotate(1.9625,0,100)
label    bounds(  56,  4, 16, 16), alpha(1), text("1"), fontColour("Black"), colour("White"), corners(8), channel("SpkrR1")
label    bounds( 129,  4, 16, 16), alpha(1), text("2"), fontColour("Black"), colour("White"), corners(8), channel("SpkrR2")
label    bounds( 180, 56, 16, 16), alpha(1), text("3"), fontColour("Black"), colour("White"), corners(8), channel("SpkrR3")
label    bounds( 180,129, 16, 16), alpha(1), text("4"), fontColour("Black"), colour("White"), corners(8), channel("SpkrR4")
label    bounds(  56,180, 16, 16), alpha(1), text("5"), fontColour("Black"), colour("White"), corners(8), channel("SpkrR5")
label    bounds( 129,180, 16, 16), alpha(1), text("6"), fontColour("Black"), colour("White"), corners(8), channel("SpkrR6")
label    bounds(   4,129, 16, 16), alpha(1), text("7"), fontColour("Black"), colour("White"), corners(8), channel("SpkrR7")
label    bounds(   4, 56, 16, 16), alpha(1), text("8"), fontColour("Black"), colour("White"), corners(8), channel("SpkrR8")
xypad    bounds(  0,  0,200,230), channel("XR","YR"), rangeX(-1,1,0), rangeY(-1,1,0), alpha(0.5)
hslider  bounds(  0,235,200, 20), text("Amp Falloff"),  channel("AmpFalloffR"),  range(0,60,0), $SLIDER_STYLE
}

image    bounds(435,  5,300,140), colour(0,0,0,0), outlineThickness(1) 
{
label    bounds(  0,  5,300, 15), text("I N P U T"), fontColour(200,200,150)
label    bounds(120, 30, 60, 14), text("Array"), fontColour(200,200,150)
combobox bounds(120, 55, 60, 20), channel("SpkrArray"), items("Ring","Pairs"), value(1), fontColour(200,200,150)
}

image    bounds(740,  5,270,140), colour(0,0,0,0), outlineThickness(1) 
{
label    bounds(  0,  5,270, 15), text("O U T P U T"), fontColour(200,200,150)
rslider  bounds( 40, 25, 70, 90), text("Dry/Wet"),  channel("DryWet"),  range(0,1,0.5), $DIAL_STYLE
rslider  bounds(160, 25, 70, 90), text("Level"),  channel("Level"),  range(0,4,1.5,0.5), $DIAL_STYLE
}

image    bounds(435,150,575,140), colour(0,0,0,0), outlineThickness(1) 
{
label    bounds(  0,  5,590, 15), text("R E V E R B"), fontColour(200,200,150)
rslider  bounds( 10, 30, 70, 90), text("Pre Delay"),  channel("PreDelay"),  range(0.01,1,0.01,0.5), $DIAL_STYLE
rslider  bounds( 90, 30, 70, 90), text("Smear"),  channel("Smear"),  range(0.01,3,1,0.5), $DIAL_STYLE
rslider  bounds(170, 30, 70, 90), text("Reverb Time"),  channel("RvbTime"),  range(0.1,18,7,0.5), $DIAL_STYLE
rslider  bounds(250, 30, 70, 90), text("Damping"),  channel("Damping"),  range(200,21000,18000,0.5,1), $DIAL_STYLE
rslider  bounds(330, 30, 70, 90), text("Mod.Rate"),  channel("ModRate"),  range(0.1,6,1,0.5), $DIAL_STYLE
rslider  bounds(410, 30, 70, 90), text("Mod.Depth"),  channel("ModDep"),  range(0,10,1,0.5), $DIAL_STYLE
rslider  bounds(490, 30, 70, 90), text("Size"),  channel("Size"),  range(0.1,10,1,0.5), $DIAL_STYLE
}

;image    bounds( 10, 10, 90,125), colour(0,0,0,0), outlineThickness(1) 
label   bounds(  5,292,120, 13), text("Iain McCurdy |2026|"), align("left"), fontColour("Silver")

</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-dm0 -n -+rtmidi=NULL -M0 --displays
</CsOptions>

<CsInstruments>

; sr set by host
ksmps  = 16
nchnls = 8
0dbfs  = 1

; speaker array presets (azimuths then coordinates)
;                                      1     2      3     4      5       6        7      8       X1  X2   X3   X4   X5   X6   X7   X8  Y1  Y2   Y3   Y4   Y5   Y6   Y7   Y8
giRing             ftgen               1,0,24,-2, -22.5, 22.5,  67.5, 112.5, 157.5, -157.5, -112.5, -67.5,  56, 129, 180, 180, 129, 56,  4,    4, 4,  4,   56,  129, 180, 180, 129, 56
giPairs            ftgen               2,0,24,-2, -22.5, 22.5, -67.5, 67.5,  -112.5, 112.5, -157.5, 157.5,  56, 129, 4,   180, 4,   180, 56, 129, 4,  4,   56,  56,  129, 129, 180, 180
                   seed                0
;                                      1     2     3     4      5      6      7      8
;iSpkrs[]          fillarray           -22.5, 22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5
iSpkrs[]           fillarray           -22.5, 22.5, -67.5, 67.5,  -112.5, 112.5, -157.5, 157.5 ; pairs
gidim = 2
                   vbaplsinit          gidim, lenarray:i(iSpkrs), iSpkrs

instr       1
; PORTAMENTO FUNCTION (A RAMP THAT RISES QUICKLY FROM 0 TO 0.1
kPortTime           linseg             0, 0.001, 0.1

; Speaker Array Presets
kSpkrArray         cabbageGetValue     "SpkrArray"
kSpkrArray         init                1
if changed:k(kSpkrArray)==1 then
                   reinit              NEW_ARRAY
endif
NEW_ARRAY:
iCount             =                   0
while iCount<=(nchnls-1) do

iX                 =                   table(iCount+8,i(kSpkrArray))
iY                 =                   table(iCount+16,i(kSpkrArray))
SChan              sprintf             "SpkrL%d",iCount+1              ; left chan
                   cabbageSet          SChan, "bounds", iX, iY, 16, 16

SChan              sprintfk            "SpkrR%d",iCount+1             ; right chan
                   cabbageSet          SChan, "bounds", iX, iY, 16, 16

iCount             +=                  1
od

iSpkrs[]           fillarray           table:i(0,i(kSpkrArray)), table:i(1,i(kSpkrArray)), table:i(2,i(kSpkrArray)), table:i(3,i(kSpkrArray)), table:i(4,i(kSpkrArray)), table:i(5,i(kSpkrArray)), table:i(6,i(kSpkrArray)), table:i(7,i(kSpkrArray))
                   vbaplsinit          gidim, lenarray:i(iSpkrs), iSpkrs




; READ IN WIDGETS
kInput             cabbageGetValue     "Input"

; INPUT
aL                 inch                1
if kInput==2 then
 aR                inch                2
else
 aR                =                   aL
endif 

;aL,aR             diskin2             "/Volumes/X10\ Pro\ 2/iainmccurdy.org/CsoundRealtimeExamples/SourceMaterials/DrumsMix.wav",1,0,1
aL,aR             diskin2             "/Volumes/X10\ Pro\ 2/Sabbatical2024-25/Cuneo/Audio/CuneoAudioConv4s.wav",1,0,1
;aL,aR              diskin2             "/Volumes/X10\ Pro\ 2/Sabbatical2024-25/Cuneo/Audio/CuneoAudio.wav",1,0,1
            
aL inch 1
aR = aL

;aIn[]             init                nchnls
;aIn[0]            =                   aL
;aIn[1]            =                   aR

; convert polar coordinates to azimuth
kX                 cabbageGetValue     "XL"
kY                 cabbageGetValue     "YL"
;printk2 kX - 0.02381
;printk2 kY + 0.03909
if kX<0 then ; q3 or q4
 kaz               =                   (180 + (taninv2:k(kX, kY) * (180/$M_PI))) + 180
else ; q1 or q2
 kaz               =                   taninv2:k(kX, kY) * (180/$M_PI)
endif
kel                =                   0
kspread            =                   0
kDist              mirror              sqrt(abs(kX)^2 + abs(kY)^2), 0, 0.42
printk2 kDist
kDist              /=                  0.42
kAmpFalloff        cabbageGetValue     "AmpFalloffL"
kdB                =                   (1-kDist) * (-kAmpFalloff)
aIn[]              vbap                aL*ampdbfs(kdB), kaz , kel, kspread


kX                 cabbageGetValue     "XR"
kY                 cabbageGetValue     "YR"
if kX<0 then ; q3 or q4
 kaz               =                   (180 + (taninv2:k(kX, kY) * (180/$M_PI))) + 180
else ; q1 or q2
 kaz               =                   taninv2:k(kX, kY) * (180/$M_PI)
endif
kel                =                   0
kspread            =                   0
kAmpFalloff        cabbageGetValue     "AmpFalloffR"
kdB                =                   (1-kDist) * (-kAmpFalloff)
aInR[]             vbap                aR*ampdbfs(kdB), kaz , kel, kspread


kCount             =                   0
while kCount<lenarray:i(aIn) do
aIn[kCount] = aIn[kCount] + aInR[kCount]
kCount             +=                  1
od

; DEFINE THE NUMBER OF DELAYS IN THE FDN, BUT IF THIS IS CHANGED, OTHER CODE RELATING TO THE NUMBER OF DELAYS WILL ALSO NEED CHANGED
iNumberOfDelays    =                   32
; INITIALISE AUDIO VARIABLES USED IN FEEDBACK (NEEDED FOR FIRST ITERATION)
afil[] init iNumberOfDelays

; CREATE MIXED FEEDBACK SIGNAL
aGFB                =                  (sumarray:a(afil)) * 2 / iNumberOfDelays   ; global feedback

; READ IN WIDGETS
kInputGain          cabbageGetValue    "InputGain"
kRvbTime            cabbageGetValue    "RvbTime"
kInterval           cabbageGetValue    "Interval"
kDelTime            cabbageGetValue    "DelTime"
kPitchMix           cabbageGetValue    "PitchMix"
kDamping            cabbageGetValue    "Damping"
kDryWet             cabbageGetValue    "DryWet"
kPreDelay           cabbageGetValue    "PreDelay"
kSmear              cabbageGetValue    "Smear"
kModRate            cabbageGetValue    "ModRate"
kModDep             cabbageGetValue    "ModDep"
kSize               cabbageGetValue    "Size"

; SMOOTH CHANGES IN SELECTED VARIABLES
kInterval           portk              kInterval, kPortTime
kDelTime            portk              kDelTime, kPortTime
kSize               portk              kSize, kPortTime

; ONLY APPLY 'TIME SMEARING' USING ALLPASS FILTERS TO THE INPUT SIGNAL IF smear time IS GREATER THAN 0.1
if kSmear>0.01 then
kRvt                =                  0.5 * kSmear ; feedback ratio for the allpass filters
kLptMlt             =                  10 * kSmear  ; delay time within the allpass filters
; ALLPASS FILTERS ARE IN SERIES FOR EACH CHANNEL
; aInL -> ALLPASS1 -> ALLPASS2 -> ALLPASS3 -> ALLPASS4 -> FDN_IN_L
; aInR -> ALLPASS1 -> ALLPASS2 -> ALLPASS3 -> ALLPASS4 -> FDN_IN_R
aOut[]              init               nchnls
aOut[0]             valpass            aIn[0], kRvt, 0.005 * kLptMlt, 1
aOut[0]             valpass            aOut[0], kRvt, 0.0017 * kLptMlt, 1
aOut[0]             valpass            aOut[0], kRvt, 0.0037 * kLptMlt, 1
aOut[0]             valpass            aOut[0], kRvt, 0.0047 * kLptMlt, 1
aOut[1]             valpass            aIn[1], kRvt, 0.005 * kLptMlt, 1
aOut[1]             valpass            aOut[1], kRvt, 0.0017 * kLptMlt, 1
aOut[1]             valpass            aOut[1], kRvt, 0.0037 * kLptMlt, 1
aOut[1]             valpass            aOut[1], kRvt, 0.0047 * kLptMlt, 1
aOut[2]             valpass            aIn[2], kRvt, 0.007 * kLptMlt, 1
aOut[2]             valpass            aOut[2], kRvt, 0.0014 * kLptMlt, 1
aOut[2]             valpass            aOut[2], kRvt, 0.0039 * kLptMlt, 1
aOut[2]             valpass            aOut[2], kRvt, 0.0043 * kLptMlt, 1
aOut[3]             valpass            aIn[3], kRvt, 0.004 * kLptMlt, 1
aOut[3]             valpass            aOut[3], kRvt, 0.0019 * kLptMlt, 1
aOut[3]             valpass            aOut[3], kRvt, 0.0033 * kLptMlt, 1
aOut[3]             valpass            aOut[3], kRvt, 0.0049 * kLptMlt, 1
aOut[4]             valpass            aIn[4], kRvt, 0.003 * kLptMlt, 1
aOut[4]             valpass            aOut[4], kRvt, 0.0021 * kLptMlt, 1
aOut[4]             valpass            aOut[4], kRvt, 0.0038 * kLptMlt, 1
aOut[4]             valpass            aOut[4], kRvt, 0.0051 * kLptMlt, 1
aOut[5]             valpass            aIn[5], kRvt, 0.006 * kLptMlt, 1
aOut[5]             valpass            aOut[5], kRvt, 0.0016 * kLptMlt, 1
aOut[5]             valpass            aOut[5], kRvt, 0.0033 * kLptMlt, 1
aOut[5]             valpass            aOut[5], kRvt, 0.0045 * kLptMlt, 1
aOut[6]             valpass            aIn[6], kRvt, 0.007 * kLptMlt, 1
aOut[6]             valpass            aOut[6], kRvt, 0.0019 * kLptMlt, 1
aOut[6]             valpass            aOut[6], kRvt, 0.0034 * kLptMlt, 1
aOut[6]             valpass            aOut[6], kRvt, 0.0053 * kLptMlt, 1
aOut[7]             valpass            aIn[7], kRvt, 0.009 * kLptMlt, 1
aOut[7]             valpass            aOut[7], kRvt, 0.0011 * kLptMlt, 1
aOut[7]             valpass            aOut[7], kRvt, 0.0043 * kLptMlt, 1
aOut[7]             valpass            aOut[7], kRvt, 0.0046 * kLptMlt, 1
endif    


; CREATE THE DELAY TIME VALUES FOR EACH DELAY
; THESE ARE MODULATED BY SLOWLY SHIFTING RANDOM FUNCTIONS BUT ARE ALSO OFFSET WITH RESPECT TO EACH OTHER
; rspline IS USED TO CREATE A COMPLEX MOVEMENT
kLRSize            =                   1
klpt1              =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate)
klpt2              =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.9137
klpt3              =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.81678
klpt4              =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.72190
klpt5              =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.627189
klpt6              =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.526177
klpt7              =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.321567
klpt8              =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.1372891
klpt9              =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate)
klpt10             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.9137
klpt11             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.81678
klpt12             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.72190
klpt13             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.627189
klpt14             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.526177
klpt15             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.321567
klpt16             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.1372891
klpt17             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate)
klpt18             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.9137
klpt19             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.81678
klpt20             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.72190
klpt21             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.627189
klpt22             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.526177
klpt23             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.321567
klpt24             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.1372891
klpt25             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate)
klpt26             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.9137
klpt27             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.81678
klpt28             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.72190
klpt29             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.627189
klpt30             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.526177
klpt31             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.321567
klpt32             =                   rspline:k(0.08*kLRSize, (0.08 + (0.0006*kModDep))*kLRSize, 5*kModRate, 8*kModRate) * 0.1372891

; APPLY PRE-DELAY TO THE INPUT SIGNAL
aDel[]             init                nchnls
kCount             =                   0
while kCount<lenarray:i(aIn) do
aDel[kCount]       vdelay              aOut[kCount], a(kPreDelay)*1000, (1+(1/kr))*1000
kCount             +=                  1
od

; THE 8 DELAYS THAT COMPRISE THE FDN
adel1              vdelay              aDel[0] + aGFB - afil[0], a(klpt1*1000*kSize), 2*1000
adel2              vdelay              aDel[0] + aGFB - afil[1], a(klpt2*1000*kSize), 2*1000
adel3              vdelay              aDel[0] + aGFB - afil[2], a(klpt3*1000*kSize), 2*1000
adel4              vdelay              aDel[0] + aGFB - afil[3], a(klpt4*1000*kSize), 2*1000
adel5              vdelay              aDel[1] + aGFB - afil[4], a(klpt5*1000*kSize), 2*1000
adel6              vdelay              aDel[1] + aGFB - afil[5], a(klpt6*1000*kSize), 2*1000
adel7              vdelay              aDel[1] + aGFB - afil[6], a(klpt7*1000*kSize), 2*1000
adel8              vdelay              aDel[1] + aGFB - afil[7], a(klpt8*1000*kSize), 2*1000
adel9              vdelay              aDel[2] + aGFB - afil[8], a(klpt9*1000*kSize), 2*1000
adel10             vdelay              aDel[2] + aGFB - afil[9], a(klpt10*1000*kSize), 2*1000
adel11             vdelay              aDel[2] + aGFB - afil[10], a(klpt11*1000*kSize), 2*1000
adel12             vdelay              aDel[2] + aGFB - afil[11], a(klpt12*1000*kSize), 2*1000
adel13             vdelay              aDel[3] + aGFB - afil[12], a(klpt13*1000*kSize), 2*1000
adel14             vdelay              aDel[3] + aGFB - afil[13], a(klpt14*1000*kSize), 2*1000
adel15             vdelay              aDel[3] + aGFB - afil[14], a(klpt15*1000*kSize), 2*1000
adel16             vdelay              aDel[3] + aGFB - afil[15], a(klpt16*1000*kSize), 2*1000
adel17             vdelay              aDel[4] + aGFB - afil[16], a(klpt17*1000*kSize), 2*1000
adel18             vdelay              aDel[4] + aGFB - afil[17], a(klpt18*1000*kSize), 2*1000
adel19             vdelay              aDel[4] + aGFB - afil[18], a(klpt19*1000*kSize), 2*1000
adel20             vdelay              aDel[4] + aGFB - afil[19], a(klpt20*1000*kSize), 2*1000
adel21             vdelay              aDel[5] + aGFB - afil[20], a(klpt21*1000*kSize), 2*1000
adel22             vdelay              aDel[5] + aGFB - afil[21], a(klpt22*1000*kSize), 2*1000
adel23             vdelay              aDel[5] + aGFB - afil[22], a(klpt23*1000*kSize), 2*1000
adel24             vdelay              aDel[5] + aGFB - afil[23], a(klpt24*1000*kSize), 2*1000
adel25             vdelay              aDel[6] + aGFB - afil[24], a(klpt25*1000*kSize), 2*1000
adel26             vdelay              aDel[6] + aGFB - afil[25], a(klpt26*1000*kSize), 2*1000
adel27             vdelay              aDel[6] + aGFB - afil[26], a(klpt27*1000*kSize), 2*1000
adel28             vdelay              aDel[6] + aGFB - afil[27], a(klpt28*1000*kSize), 2*1000
adel29             vdelay              aDel[7] + aGFB - afil[28], a(klpt29*1000*kSize), 2*1000
adel30             vdelay              aDel[7] + aGFB - afil[29], a(klpt30*1000*kSize), 2*1000
adel31             vdelay              aDel[7] + aGFB - afil[30], a(klpt31*1000*kSize), 2*1000
adel32             vdelay              aDel[7] + aGFB - afil[31], a(klpt32*1000*kSize), 2*1000

; DAMPING FILTERS (1ST ORDER LOW-PASS FILTERS, -6dB per octave)
afil[0]            tone                adel1 * ampdbfs(-60/(kRvbTime/klpt1)), kDamping
afil[1]            tone                adel2 * ampdbfs(-60/(kRvbTime/klpt2)), kDamping
afil[2]            tone                adel3 * ampdbfs(-60/(kRvbTime/klpt3)), kDamping
afil[3]            tone                adel4 * ampdbfs(-60/(kRvbTime/klpt4)), kDamping   
afil[4]            tone                adel5 * ampdbfs(-60/(kRvbTime/klpt5)), kDamping
afil[5]            tone                adel6 * ampdbfs(-60/(kRvbTime/klpt6)), kDamping
afil[6]            tone                adel7 * ampdbfs(-60/(kRvbTime/klpt7)), kDamping
afil[7]            tone                adel8 * ampdbfs(-60/(kRvbTime/klpt8)), kDamping 
afil[8]            tone                adel9 * ampdbfs(-60/(kRvbTime/klpt9)), kDamping
afil[9]            tone                adel10 * ampdbfs(-60/(kRvbTime/klpt10)), kDamping
afil[10]           tone                adel11 * ampdbfs(-60/(kRvbTime/klpt11)), kDamping
afil[11]           tone                adel12 * ampdbfs(-60/(kRvbTime/klpt12)), kDamping   
afil[12]           tone                adel13 * ampdbfs(-60/(kRvbTime/klpt13)), kDamping
afil[13]           tone                adel14 * ampdbfs(-60/(kRvbTime/klpt14)), kDamping
afil[14]           tone                adel15 * ampdbfs(-60/(kRvbTime/klpt15)), kDamping
afil[15]           tone                adel16 * ampdbfs(-60/(kRvbTime/klpt16)), kDamping 
afil[16]           tone                adel17 * ampdbfs(-60/(kRvbTime/klpt17)), kDamping
afil[17]           tone                adel18 * ampdbfs(-60/(kRvbTime/klpt18)), kDamping
afil[18]           tone                adel19 * ampdbfs(-60/(kRvbTime/klpt19)), kDamping
afil[19]           tone                adel20 * ampdbfs(-60/(kRvbTime/klpt20)), kDamping   
afil[20]           tone                adel21 * ampdbfs(-60/(kRvbTime/klpt21)), kDamping
afil[21]           tone                adel22 * ampdbfs(-60/(kRvbTime/klpt22)), kDamping
afil[22]           tone                adel23 * ampdbfs(-60/(kRvbTime/klpt23)), kDamping
afil[23]           tone                adel24 * ampdbfs(-60/(kRvbTime/klpt24)), kDamping 
afil[24]           tone                adel25 * ampdbfs(-60/(kRvbTime/klpt25)), kDamping
afil[25]           tone                adel26 * ampdbfs(-60/(kRvbTime/klpt26)), kDamping
afil[26]           tone                adel27 * ampdbfs(-60/(kRvbTime/klpt27)), kDamping
afil[27]           tone                adel28 * ampdbfs(-60/(kRvbTime/klpt28)), kDamping   
afil[28]           tone                adel29 * ampdbfs(-60/(kRvbTime/klpt29)), kDamping
afil[29]           tone                adel30 * ampdbfs(-60/(kRvbTime/klpt30)), kDamping
afil[30]           tone                adel31 * ampdbfs(-60/(kRvbTime/klpt31)), kDamping
afil[31]           tone                adel32 * ampdbfs(-60/(kRvbTime/klpt32)), kDamping 

; MIX DRY AND WET SIGNALS ACCORDING TO GUI WIDGET. 
; NOTE THAT DELAY OUTPUTS ARE SENT TO ALTERNATE OUTPUTS BUT WILL STILL EXPERIENCE CROSS-CHANNEL MIXING VIA THE FDN
aMix[]             init                nchnls
aMix[0]            ntrpol              aIn[0], (adel1 + adel2 + adel3 + adel4) * 0.3, kDryWet
aMix[1]            ntrpol              aIn[1], (adel5 + adel6 + adel7 + adel8) * 0.3, kDryWet
aMix[2]            ntrpol              aIn[2], (adel9 + adel10 + adel11 + adel12) * 0.3, kDryWet
aMix[3]            ntrpol              aIn[3], (adel13 + adel14 + adel15 + adel16) * 0.3, kDryWet
aMix[4]            ntrpol              aIn[4], (adel17 + adel18 + adel19 + adel20) * 0.3, kDryWet
aMix[5]            ntrpol              aIn[5], (adel21 + adel22 + adel23 + adel24) * 0.3, kDryWet
aMix[6]            ntrpol              aIn[6], (adel25 + adel26 + adel27 + adel28) * 0.3, kDryWet
aMix[7]            ntrpol              aIn[7], (adel29 + adel30 + adel31 + adel32) * 0.3, kDryWet

; OUTPUT
kLevel cabbageGetValue "Level"
kCount             =                   0
while kCount<lenarray(aMix) do
                   outch               kCount+1, aMix[kCount] * kLevel
kCount             +=                  1
od

endin



</CsInstruments>

<CsScore>
i 1 0 z
</CsScore>

</CsoundSynthesizer>
