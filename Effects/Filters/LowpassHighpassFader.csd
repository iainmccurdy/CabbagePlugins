
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; LowpassHighpassFader.csd
; Written by Iain McCurdy, 2026.

; Vertical location on the XY pad controls the cutoff frequencies of first a low-pass filter and then a high-pass filter.
; The first half of the Y-axis travel lifts the cutoff frequency of the low-pass filter 
;  and then the second half lifts the cutoff frequency of the high-pass filter.
; The specific mappings are shown in the graph (yellow=low-pass filter; blue=high-pass filter) 
;  and they can be fine tuned using the sliders:
; - LPF Min
; - LPF Max
; - HPF Min
; - HPF Max

; Horizontal location on the XP pad controls amplitude. 
; The mapping is not linear but instead is scaled according to an s-curve, shown in purple on the graph
;  in order to provide more useful gestural response.

; Values for the filters and amplitude are printed out to number boxes

; 'Lag' controls the amount of smoothing lag that is applied to both filter cutoff frequencies and amplitude value.

; INPUT -> LOW-PASS FILTER -> HIGH-PASS FILTER -> AMPLITUDE CONTROL -> OUTPUT



; More features may be added in the future.

<Cabbage>
form caption("Lowpass-Highpass Fader"), colour(53,50,50), size(1065,370), pluginId("LHFa"), guiMode("queue") 
xypad bounds(5, 5, 350, 350), channel("X", "Y"), rangeX(0, 1, 0.5), rangeY(0, 1, 0.5), text("x: amplitude | y: filters"), colour(40,40,50), ballColour("white"), fontColour("white"), textColour("white")
nslider bounds(360, 10, 80, 40), channel("LPF"), range(20,20000,20,1,1), text("LPF Cutoff"), active(0), fontColour(255,255,100), textColour(255,255,100)
nslider bounds(360, 60, 80, 40), channel("HPF"), range(20,20000,20,1,1), text("HPF Cutoff"), active(0), fontColour(100,255,255), textColour(100,255,255)
nslider bounds(360,110, 80, 40), channel("Amp"), range(0,1,1,1,0.001), text("Amplitude"), active(0), fontColour(255,100,255), textColour(255,100,255)
rslider bounds(360,160, 80,100), channel("Lag"), range(0,1,0.05,0.6,0.001), text("Lag"), fontColour("white"), textColour("white"), valueTextBox(1), trackerColour("white")
vslider bounds(450,  5, 50,350), channel("LPFMin"), range(4,14,4,1,0.1), text("LPF Min"), fontColour("white"), textColour("white"), valueTextBox(0), trackerColour(255,255,100)
vslider bounds(500,  5, 50,350), channel("LPFMax"), range(4,14,14,1,0.1), text("LPF Max"), fontColour("white"), textColour("white"), valueTextBox(0), trackerColour(255,255,100)
vslider bounds(550,  5, 50,350), channel("HPFMin"), range(4,14,4,1,0.1), text("HPF Min"), fontColour("white"), textColour("white"), valueTextBox(0), trackerColour(100,255,255)
vslider bounds(600,  5, 50,350), channel("HPFMax"), range(4,14,14,1,0.1), text("HPF Max"), fontColour("white"), textColour("white"), valueTextBox(0), trackerColour(100,255,255)
vslider bounds(650,  5, 50,350), channel("AmpCurve"), range(-8,8,2,1,0.1), text("Curve"), fontColour("white"), textColour("white"), valueTextBox(0), trackerColour(255,100,255)
gentable bounds(715, 10, 340,340), channel("tables"), tableNumber(1,2,3), fill(0), ampRange(0,4,14), tableColour:0(255,255,100), tableColour:1(100,255,255), tableColour:2(255,100,255);, rotate(1.57,100,100)
image   bounds(706,346,8,8), channel("LPFWidg"), colour(255,255,100), shape("ellipse")
image   bounds(706,346,8,8), channel("HPFWidg"), colour(100,255,255), shape("ellipse")
image   bounds(706,346,8,8), channel("AmpWidg"), colour(255,100,255), shape("ellipse")
label   bounds( 10,356,150,12), text("Iain McCurdy |2026|"), align("left");, fontColour("white")
</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-dm0 -n -+rtmidi=NULL -M0
; --displays
</CsOptions>

<CsInstruments>
;sr is set by host
ksmps              =                   32
nchnls             =                   2
0dbfs              =                   1

; Author: Iain McCurdy (2026)

instr   1
a1                 inch                1
a2                 inch                2

a1                 pinker
a2                 pinker
a1                 *=                  0.02
a2                 *=                  0.02

kX                 cabbageGetValue     "X"
kY                 cabbageGetValue     "Y"
kLag               cabbageGetValue     "Lag"


kLPFMax            cabbageGetValue     "LPFMax"
kLPFMax            init                14
kLPFMin            cabbageGetValue     "LPFMin"
kLPFMin            init                4
kHPFMax            cabbageGetValue     "HPFMax"
kHPFMax            init                14
kHPFMin            cabbageGetValue     "HPFMin"
kHPFMin            init                14
kAmpCurve          cabbageGetValue     "AmpCurve"


if changed:k(kLPFMax,kLPFMin,kHPFMax,kHPFMin,kAmpCurve)==1 then
                   reinit              REBUILD_TABLES
endif
REBUILD_TABLES:
iLPFTab            ftgen               1, 0, 1024, -7, i(kLPFMin), 512, i(kLPFMax), 512, 14
iHPFTab            ftgen               2, 0, 1024, -7, 4, 512, i(kHPFMin), 512, i(kHPFMax)
iAmpTab            ftgen               3, 0, 1024, -16, 0, 512, i(kAmpCurve), 0.5, 512, -i(kAmpCurve), 1
                   cabbageSet          1, "tables", "tableNumber", 1, 2, 3
rireturn

 ; filter parameters
 kLPF_CF           =                   table:k(kY,iLPFTab,1)
 iBounds[]         cabbageGet          "tables", "bounds"
                   cabbageSet          changed:k(kLPF_CF), "LPFWidg", "bounds", iBounds[0] + kY*iBounds[2]-4, iBounds[1] - 4 + (1 - (kLPF_CF-4)/10) * iBounds[2], 8, 8
 kLPF_CF           portk               kLPF_CF, kLag
 kLPF_CF           =                   cpsoct(kLPF_CF)
 
 kHPF_CF           =                   table:k(kY,iHPFTab,1)
                   cabbageSet          changed:k(kHPF_CF), "HPFWidg", "bounds", iBounds[0] + kY*iBounds[2]-4, iBounds[1] - 4 + (1 - (kHPF_CF-4)/10) * iBounds[2], 8, 8
 kHPF_CF           portk               kHPF_CF, kLag
 kHPF_CF           =                   cpsoct(kHPF_CF) 

 ; amplitude
 kAmp              =                   table:k(kX,iAmpTab,1)
                   cabbageSet          changed:k(kAmp), "AmpWidg", "bounds", iBounds[0] + kX*iBounds[2]-4, iBounds[1] - 4 + ((1-kAmp) * iBounds[2]), 8, 8
 kAmp              portk               kAmp, kLag
 
 ; print values
                   cabbageSetValue     "LPF", round(kLPF_CF), changed:k(round(kLPF_CF))
                   cabbageSetValue     "HPF", round(kHPF_CF), changed:k(round(kHPF_CF))
                   cabbageSetValue     "Amp", kAmp, changed:k(kAmp)
 
   kLPFRes         =                   0.5
   kHPFRes         =                   0.5
   a1              zdf_2pole           a1, a(kLPF_CF), kLPFRes    ; lowpass
   a2              zdf_2pole           a2, a(kLPF_CF), kLPFRes
   a1              zdf_2pole           a1, a(kHPF_CF), kHPFRes, 1 ; highpass
   a2              zdf_2pole           a2, a(kHPF_CF), kHPFRes, 1
 
  a1               *=                  a(kAmp)
  a2               *=                  a(kAmp)
  
  outs a1,a2
endin

</CsInstruments>

<CsScore>
i 1 0 z
</CsScore>

</CsoundSynthesizer>