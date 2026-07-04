
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; WavetablePulser
; Written by Iain McCurdy, 2026.

; This instrument is intended to be used with a single cycle of a waveform (wavetable) but experimentation with other short 
;   but non-single-cycle sound file inputs are possible.
; The wavetable can be altered using phase pointer distortion and phase pointer clipping.

; With the default settings and using the On/Off button, the wavetable will be played at unison pitch and looped.
; If 'Pitch Ratio' is increased, the speed of playback of the wavetable will increase but the rate of repetition remains the same.
; This means that there will be gaps between repetitions.
; The audible result is of the spectral envelope shifting upwards and this is an effect familiar from synchronous granular synthesis.
; Conversely if 'Pitch Ratio' is reduced below 1, the speed of playback of the wavetable will decrease
;  and because the rate of repetition remains the same, repetitions will overlap.

; From the default settings if 'Rate Ratio' is increased, the rate of repetitions of the wavetable will increase 
;  such that repetitions will overlap.
; If 'Rate Ratio' is decreased, there will be gaps between repetitions.

; The 'Pitch/Rate' dial scales both 'Pitch Ratio' and 'Rate Ratio' simultaneously.

; Three pairs of controls can be controlled using XY pads.

; Open File      -   browse for a sound file (mono or stereo) and ideally a single-cycles of a waveform
; Play/Stop      -   play/stop the oscillator. It can also be played from the MIDI keyboard.
; Window         -   checkbox optionally applies an amplitude window to the wavetable. 
;                     This can be useful if there is a discontinuity between the beginning and ending of the wavetable.
; Window Shape   -   The shape of the window can be tuned. If the the main 'Window' checkbox is activated, 
;                     a graphical representation of the window will be overlaid onto the wavetable graph.
; Env. Rise      -   a simple envelope (amplitude and low-pass filter) is applied to complete notes: togglings of Play/Stop or MIDI notes
;                     This defines the rise time of this envelope
; Env. Fall      -   Release time of the same envelope.
; File Viewers
;                -   the upper waveform viewer shows the input sound file; 
;                     the lower shows the output after phase distortion, phase clipping and the window have been applied.
;                    The action of the global low-pass filter (LPF) and high-pass filter (HPF) are not included in this display 
;                     - as they would also shift phase making the display less useful.
; LPF            -   A global low-pass filter. If 'LPF Res.' is raised above zero, a resonant filter is swapped in.
; HPF            -   A global high-pass filter.
;                    The cutoff frequencies of the low-pass and high-pass filters can also be controlled using the adjacent XY pad.
;                    Its influence on these dials can be toggled using the small checkboxes beside their labels.
; LPF Res        -   Resonance of the low-pass filter
; Pitch Ratio    -   As described above, scales the speed of playback of the wavetable.
; Rate Ratio     -   As described above, scales the rate of wavetable repetition.
; Phase Dist.    -   Distortion above its half-way point of the phase pointer used to read the wavetable (pdhalf)
; Phase Clip     -   Bipolar hard-clipping of the phase pointer used to read the wavetable (pdclip)
;                     Extreme settings of these distortions can produce aliasing as frequency information 
;                     - contained within the wavetable is shifted upwards and beyond the Nyquist. 
;                    The extent of these controls can be limited using the two number boxes in the same panel.
;                    This is primarily useful when using the XY pad to remote control the dials.
; Dist. Scale    -   Amount of phase pointer distortion. Range -1 to 1. 0 means no distortion.
;                    As the value is reduced below zero, the first half of the waveform is increasingly compressed (sped up) and the second half is stretched (slowed down).
;                    As the value is increased above zero, the first half of the waveform is increasingly stretched (slowed down) and the second half is compressed (sped up).
; Clip Scale     -   The amount of bipolar clipping applied to the phase pointer. This is similar to the playback of the wavetable being sped up 
;                     without the rate of repetition being affected.
; Pitch/Rate     -   As described above, scales both speed of playback of the wavetable and rate of repetition.
; Quality        -   Interpolation quality used in playback of the wavetable. 
;                     This can improve results, particularly if playback speed is very low. Has a CPU cost.
; Anti-Alias     -   Aliasing resulting from high wavetable playback speeds and phase distortions can be attenuated by increasing this
;                     Has a CPU cost.
; Pan            -   Left/right panning control
; Level          -   Output level control.

; Tuning         -   tuning of the MIDI keyboard can be chosen from a range of presets

<Cabbage>
form caption("Wavetable Pulser"), size(1140,595), colour(80,100,100), pluginId("WaPu"), guiMode("queue")

#define SLIDER_DESIGN1 colour(235,235,250), markerColour("black"), trackerColour(110,130,130), fontColour("white"), textColour("white"), valueTextBox(1)
#define CHECKBOX_DESIGN fontColour:0("white"), fontColour:1("white")

image    bounds(  5,  5,460,245), colour(0,0,0,0), outlineThickness(1), corners(5)
{
filebutton bounds( 12, 10, 80, 25), text("Open File","Open File"), fontColour("White") channel("filename"), shape("ellipse"), corners(5)
checkbox   bounds( 12, 40, 80, 20), channel("OnOff"), value(0), text("Play/Stop"), $CHECKBOX_DESIGN
soundfiler bounds(105,  5,350,115), channel("filer"), colour(0, 255, 255, 255), fontColour(160, 160, 160, 255)
label      bounds(108,  7,200, 14), text(""), align("left"), channel("FileName"), fontColour("White")
gentable   bounds(105,125,350,115), tableNumber(101), channel("OutputTable")
gentable   bounds(105,125,350,115), tableNumber(201), channel("WindowTable"), fill(0), alpha(0.5), tableColour("LightBlue"), visible(0), tableBackgroundColour(0,0,0,0), tableGridColour(0,0,0,0);, ampRange(201,-1,1)

checkbox   bounds( 15, 80, 80, 15), channel("WindOnOff"), value(0), text("Window"), $CHECKBOX_DESIGN
nslider    bounds( 15, 95, 70, 35), channel("WindShp"), range(0,32,16,1,1), text("Wind. Shape"), textColour("white")

nslider    bounds( 20,150, 60, 35), channel("Ris"), range(0.01,30,0.1), text("Env. Rise"), textColour("white")
nslider    bounds( 20,190, 60, 35), channel("Fal"), range(0.01,30,0.1), text("Env. Fall"), textColour("white")
;image      bounds(105,125,  1,115), channel("ClipWiperL"), alpha(0.5)
;image      bounds(455,125,  1,115), channel("ClipWiperR"), alpha(0.5)
image      bounds(280,125,  1,115), channel("HalfWiper"), alpha(0.5)
}

image    bounds( 470,  5,560,245), colour(0,0,0,0), outlineThickness(1), corners(5)
{
rslider    bounds( 25,  5, 70,110), channel("LPF"), text("LPF"), range(4,14,14), $SLIDER_DESIGN1
rslider    bounds( 25,125, 70,110), channel("HPF"), text("HPF"), range(4,14, 4), $SLIDER_DESIGN1
checkbox   bounds( 10,  9, 15, 15), channel("LPFOn"), value(1)
checkbox   bounds( 10,129, 15, 15), channel("HPFOn"), value(1)
xypad      bounds(110,  5,345,235), channel("x1","y1")
rslider    bounds(470,  5, 70,110), channel("LPFRes"), text("LPF Res"), range(0,0.95,0), $SLIDER_DESIGN1
}

image    bounds( 5,255,460,245), colour(0,0,0,0), outlineThickness(1), corners(5)
{
rslider    bounds( 25,  5, 70,110), channel("PitchRatio"), text("Pitch Ratio"), range(0.001,8,1,0.5), $SLIDER_DESIGN1
rslider    bounds( 25,125, 70,110), channel("RateRatio"), text("Rate Ratio"), range(0.001,8,1,0.5), $SLIDER_DESIGN1
checkbox   bounds( 10,  9, 15, 15), channel("PitchRatioOn"), value(1)
checkbox   bounds( 10,129, 15, 15), channel("RateRatioOn"), value(1)
xypad      bounds(110,  5,345,235), channel("x2","y2")
}

image    bounds( 470,255,560,245), colour(0,0,0,0), outlineThickness(1), corners(5)
{
rslider    bounds( 25,  5, 70,110), channel("PhaseDist"), text("Phase Dist."), range(-1,1,0), $SLIDER_DESIGN1
rslider    bounds( 25,125, 70,110), channel("PhaseClip"), text("Phase Clip"), range(0,1,0), $SLIDER_DESIGN1
checkbox   bounds( 10,  9, 15, 15), channel("PhaseDistOn"), value(1)
checkbox   bounds( 10,129, 15, 15), channel("PhaseClipOn"), value(1)
xypad      bounds(110,  5,345,235), channel("x3","y3")
nslider    bounds(475, 35, 60, 35), channel("DistScal"), range(0.1,1,1), text("Dist. Scale"), textColour("white")
nslider    bounds(475,155, 60, 35), channel("ClipScal"), range(0.1,1,1), text("Clip Scale"), textColour("white")
}

image     bounds(1035,  5,100,495), colour(0,0,0,0), outlineThickness(1), corners(5)
{
rslider    bounds( 15,  5, 70,110), channel("PitchRateRatio"), text("Pitch/Rate"), range(0.001,1,1,0.5), $SLIDER_DESIGN1
nslider    bounds( 20,130, 60, 35), channel("Qual"), range(0,32,4,1,1), text("Quality"), textColour("white")
nslider    bounds( 20,180, 60, 35), channel("AAlias"), range(1,32,1,1,0.01), text("Anti-Alias"), textColour("white")

rslider    bounds( 15,245, 70,110), channel("Pan"), text("Pan"), range(0,1,0.5), $SLIDER_DESIGN1
rslider    bounds( 15,365, 70,110), channel("Gain"), text("Level"), range(0,2,0.2,0.5), $SLIDER_DESIGN1
}

label      bounds( 10,513,110, 13), text("Tuning"), fontColour("White")
combobox   bounds( 10,530,110, 22), channel("Tuning"), items("12-TET", "24-TET", "12-TET rev.", "24-TET rev.", "10-TET", "36-TET", "Just C", "Just C#", "Just D", "Just D#", "Just E", "Just F", "Just F#", "Just G", "Just G#", "Just A", "Just A#", "Just B","Pythagorean C","19 TET","31 TET","Bohlen-Pierce C"), value(1),fontColour("white")

keyboard   bounds(135,510,1000,80)

label    bounds( 10,578,120, 12), text("Iain McCurdy |2026|"), align("left"), fontColour("white")
</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-dm0 -n -+rtmidi=NULL -M0
</CsOptions>

<CsInstruments>
;sr is set by host
ksmps   =   1
nchnls  =   2
0dbfs   =   1

; Author: Iain McCurdy (2026)

gaSend1,gaSend2    init                0
giOutputTable      ftgen               101, 0, 512, -10, 0 ; empty to begin with
;giWind             ftgen               201,0,4096,9,0.5,1,0 ; half sine
giWind             ftgen               201, 0, 4096, 16, 0, 2048, -16, 1, 2048, 16, 0
                   massign             0, 2
; tuning tables
;                               FN_NUM | INIT_TIME | SIZE | GEN_ROUTINE | NUM_GRADES | REPEAT |  BASE_FREQ  | BASE_KEY_MIDI | TUNING_RATIOS:-0-|----1----|---2----|----3----|----4----|----5----|----6----|----7----|----8----|----9----|----10-----|---11----|---12---|---13----|----14---|----15---|---16----|----17---|---18----|---19---|----20----|---21----|---22----|---23---|----24----|----25----|----26----|----27----|----28----|----29----|----30----|----31----|----32----|----33----|----34----|----35----|----36----|
giTTable1     ftgen             0,         0,       64,       -2,          12,          2,   cpsmidinn(60),      60,                       1, 1.059463,1.1224619,1.1892069,1.2599207,1.33483924,1.414213,1.4983063,1.5874001,1.6817917,1.7817962, 1.8877471,     2 ;STANDARD
giTTable2     ftgen             0,         0,       64,       -2,          24,          2,   cpsmidinn(60),      60,                       1, 1.0293022,1.059463,1.0905076,1.1224619,1.1553525,1.1892069,1.2240532,1.2599207,1.2968391,1.33483924,1.3739531,1.414213,1.4556525,1.4983063, 1.54221, 1.5874001, 1.6339145,1.6817917,1.73107,  1.7817962,1.8340067,1.8877471,1.9430623,    2 ;QUARTER TONES
giTTable3     ftgen             0,         0,       64,       -2,          12,        0.5,   cpsmidinn(60),      60,                       2, 1.8877471,1.7817962,1.6817917,1.5874001,1.4983063,1.414213,1.33483924,1.2599207,1.1892069,1.1224619,1.059463,      1 ;STANDARD REVERSED
giTTable4     ftgen             0,         0,       64,       -2,          24,        0.5,   cpsmidinn(60),      60,                       2, 1.9430623,1.8877471,1.8340067,1.7817962,1.73107, 1.6817917,1.6339145,1.5874001,1.54221,  1.4983063, 1.4556525,1.414213,1.3739531,1.33483924,1.2968391,1.2599207,1.2240532,1.1892069,1.1553525,1.1224619,1.0905076,1.059463, 1.0293022,    1 ;QUARTER TONES REVERSED
giTTable5     ftgen             0,         0,       64,       -2,          10,          2,   cpsmidinn(60),      60,                       1, 1.0717734,1.148698,1.2311444,1.3195079, 1.4142135,1.5157165,1.6245047,1.7411011,1.8660659,     2 ;DECATONIC
giTTable6     ftgen             0,         0,       64,       -2,          36,          2,   cpsmidinn(60),      60,                       1, 1.0194406,1.0392591,1.059463,1.0800596, 1.1010566,1.1224618,1.1442831,1.1665286,1.1892067,1.2123255,1.2358939,1.2599204,1.284414,1.3093838, 1.334839, 1.3607891,1.3872436,1.4142125,1.4417056,1.4697332,1.4983057,1.5274337,1.5571279,1.5873994, 1.6182594,1.6497193, 1.6817909, 1.7144859, 1.7478165, 1.7817951, 1.8164343, 1.8517469, 1.8877459, 1.9244448, 1.9618572,      2 ;THIRD TONES
giTTable7     ftgen             0,         0,       64,       -2,          12,          2,   cpsmidinn(60),      60,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable8     ftgen             0,         0,       64,       -2,          12,          2,   cpsmidinn(61),      61,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable9     ftgen             0,         0,       64,       -2,          12,          2,   cpsmidinn(62),      62,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable10    ftgen             0,         0,       64,       -2,          12,          2,   cpsmidinn(63),      63,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable11    ftgen             0,         0,       64,       -2,          12,          2,   cpsmidinn(64),      64,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable12    ftgen             0,         0,       64,       -2,          12,          2,   cpsmidinn(65),      65,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable13    ftgen             0,         0,       64,       -2,          12,          2,   cpsmidinn(66),      66,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable14    ftgen             0,         0,       64,       -2,          12,          2,   cpsmidinn(67),      67,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable15    ftgen             0,         0,       64,       -2,          12,          2,   cpsmidinn(68),      68,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable16    ftgen             0,         0,       64,       -2,          12,          2,   cpsmidinn(69),      69,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable17    ftgen             0,         0,       64,       -2,          12,          2,   cpsmidinn(70),      70,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
giTTable18    ftgen             0,         0,       64,       -2,          12,          2,   cpsmidinn(71),      71,                       1,   16/15,     9/8,     6/5,      5/4,       4/3,     45/32,     3/2,     8/5,      5/3,      9/5,       15/8,    2 ;JUST INTONATION                                                                                                                                                                                                                                   
gipyth        ftgen             0,         0,       64,       -2,          12,          2,   cpsmidinn(60),      60,                       1,  256/243,   9/8,    32/27,    81/64,      4/3,    729/512,    3/2,    128/81,   27/16,     16/9,     243/128,  2     ;RATIOS FOR PYTHAGOREAN TUNING
gi19TET       ftgen             0,         0,       64,       -2,          19,          2,   cpsmidinn(60),      60,                       1,2^(1/19),2^(2/19),2^(3/19),2^(4/19),2^(5/19),2^(6/19),2^(7/19),2^(8/19),2^(9/19),2^(10/19),2^(11/19),2^(12/19),2^(13/19),2^(14/19),2^(15/19),2^(16/19),2^(17/19),2^(18/19),2^(19/19)
gi31TET       ftgen             0,         0,       64,       -2,          31,          2,   cpsmidinn(60),      60,                       1,2^(1/31),2^(2/31),2^(3/31),2^(4/31),2^(5/31),2^(6/31),2^(7/31),2^(8/31),2^(9/31),2^(10/31),2^(11/31),2^(12/31),2^(13/31),2^(14/31),2^(15/31),2^(16/31),2^(17/31),2^(18/31),2^(19/31),2^(20/31),2^(21/31),2^(22/31),2^(23/31),2^(24/31),2^(25/31),2^(26/31),2^(27/31),2^(28/31),2^(29/31),2^(30/31),2^(31/31)
giBP          ftgen             0,         0,       64,       -2,          13,          3,   cpsmidinn(60),      60,                       1,3^(1/13),3^(2/13),3^(3/13),3^(4/13),3^(5/13),3^(6/13),3^(7/13),3^(8/13),3^(9/13),3^(10/13),3^(11/13),3^(12/13),3^(13/13)

instr   1
; SOUND FILE PLAYBACK
gkOnOff            cabbageGetValue     "OnOff"           ; play sound file
if trigger:k(gkOnOff, 0.5, 0) == 1 then
                   event               "i", 2, 0, 3600 * 24 * 7 * 365
elseif trigger:k(gkOnOff, 0.5, 1) == 1 then
                   turnoff2            2, 0, 1
endif

; load file from browse
gSfilepath         cabbageGetValue     "filename"        ; read in file path string from filebutton widget
if changed:k(gSfilepath)==1 then                         ; call instrument to update waveform viewer  
                   event               "i", 99, 0, 0
endif

; load file from dropped file
gSDropFile         cabbageGet      "LAST_FILE_DROPPED" ; file dropped onto GUI
if (changed(gSDropFile) == 1) then
                   event               "i", 100, 0, 0   ; load dropped file
endif

 kPitchRatioOn     cabbageGetValue     "PitchRatioOn"
 kRateRatioOn      cabbageGetValue     "RateRatioOn"
 kx2,kT            cabbageGetValue     "x2"
                   cabbageSetValue     "PitchRatio", scale(kx2^2,1,0.001), kT*kPitchRatioOn
 ky2,kT            cabbageGetValue     "y2"
                   cabbageSetValue     "RateRatio", scale(ky2^2,1,0.001), kT*kRateRatioOn

 kPhaseDistOn      cabbageGetValue     "PhaseDistOn"
 kPhaseClipOn      cabbageGetValue     "PhaseClipOn"
 kx3,kT            cabbageGetValue     "x3"
                   cabbageSetValue     "PhaseDist", scale(kx3,0.99,-0.99), kT*kPhaseDistOn
 ky3,kT            cabbageGetValue     "y3"
                   cabbageSetValue     "PhaseClip", scale(ky3,1,0), kT*kPhaseClipOn

 gkPhaseDist       =                   cabbageGetValue:k("PhaseDist") * cabbageGetValue:k("DistScal")
 gkPhaseClip       =                   cabbageGetValue:k("PhaseClip") * cabbageGetValue:k("ClipScal") 

 gkPitchRateRatio  cabbageGetValue     "PitchRateRatio"
 gkPitchRatio      cabbageGetValue     "PitchRatio"
 gkRateRatio       cabbageGetValue     "RateRatio"

 kPortTime         linseg              0, 0.01, 0.05
 gkPhaseDist       portk               gkPhaseDist, kPortTime
 gkPhaseClip       portk               gkPhaseClip, kPortTime
 
 
 kWindOnOff,kT     cabbageGetValue     "WindOnOff"
                   cabbageSet          kT, "WindowTable", "visible", kWindOnOff
 
 ; window shape
 kWindShp          cabbageGetValue     "WindShp"
 if changed:k(kWindShp)==1 then
  reinit REBUILD_WINDOW
 endif
 REBUILD_WINDOW:
 giWind             ftgen               201, 0, 4096, 16, 0, 2048, -i(kWindShp), 1, 2048, i(kWindShp), 0
                   cabbageSet           "WindowTable", "tableNumber", 201
endin








instr    99 ; LOAD SOUND FILE
giSource           =                   0
                   cabbageSet          "filer", "file", gSfilepath
giFileChans        filenchnls          gSfilepath
/* write file name to GUI */
SFileNoExtension   cabbageGetFileNoExtension   gSfilepath
                   cabbageSet          "FileName","text",SFileNoExtension
gi1                ftgen               1, 0, 0, -1, gSfilepath, 0, 0, 1

if filenchnls:i(gSfilepath)==2 then
gi2                ftgen               2, 0, 0, -1, gSfilepath, 0, 0, 2
else
gi2                =                   gi1
endif
endin

instr    100 ; LOAD DROPPED SOUND FILE
 giSource         =                    1
 giFileChans      filenchnls           gSfilepath
                  cabbageSet           "filer", "file", gSDropFile

 /* write file name to GUI */
 SFileNoExtension cabbageGetFileNoExtension   gSDropFile
                  cabbageSet           "FileName", "text", SFileNoExtension
gi1                ftgen               1, 0, 0, 1, gSfilepath, 0, 0, 1
if filenchnls:i(gSfilepath)==2 then
gi2                ftgen               2, 0, 0, 1, gSfilepath, 0, 0, 2
else
gi2                =                   gi1
endif
endin







instr 2 ; triggered by On/Off button or MIDI notes
if active:i(p1)==1 then
 event_i "i", 11, 0, 3600
endif

idefault           =                   1
ivalue             =                   0
         mididefault idefault, ivalue ; ivalue overwritten by idefault if MIDI driven
if ivalue==1 then ; MIDI
 iUniFrq           cpstmid             giTTable1 + cabbageGetValue:i("Tuning") - 1
 iVel              ampmidi   1
else              ; non-MIDI
 iUniFrq           =                   ftsr(gi1)/ftlen(gi1)
 iVel              =                   1
endif
 
 ; note-global envelope
 iRis              cabbageGetValue     "Ris"
 iFal              cabbageGetValue     "Fal"

 kEnv              transegr            0, iRis, -4, 1, iFal, -4, 0
 
kTrig              metro               iUniFrq * gkRateRatio * gkPitchRateRatio
;                                                   p1    p2 p3   p4
                   schedkwhen          kTrig, 0, 0, p1+1, 0, 0.1, kEnv*iVel

endin




instr 3 ; triggered pulses
iPitchRatio        cabbageGetValue     "PitchRatio"
iUniFrq            =                   ftsr(gi1)/ftlen(gi1)

p3                 =                   1 / (iUniFrq*i(gkPitchRatio)*i(gkPitchRateRatio))
aPtr               linseg              0, p3, 1
;aPtr               init                0
;if k(aPtr)>1 then
; turnoff
;endif

aPtrD              pdhalf              aPtr, gkPhaseDist

kPortTime          linseg              0,0.01,0.05
aPtrD              pdclip              aPtrD, gkPhaseClip, 0

; wavetable reading
iQual              =                   2 ^ cabbageGetValue:i("Qual")
iAAlias            cabbageGetValue     "AAlias"
a1                 tablexkt            aPtrD, gi1, iAAlias*(gkPhaseClip+gkPitchRatio), iQual, 1 ;] [, ixoff] [, iwrap] 
a2                 tablexkt            aPtrD, gi2, iAAlias*(gkPhaseClip+gkPitchRatio), iQual, 1 ;] [, ixoff] [, iwrap] 

if cabbageGetValue:i("WindOnOff")==1 then
 aWind             tablei              aPtr, giWind, 1
 a1                *=                  aWind
 a2                *=                  aWind
endif
 
 a1                butlp               a1, sr/2 * p4^3
 a2                butlp               a2, sr/2 * p4^3
 
gaSend1            +=                  a1 * p4
gaSend2            +=                  a2 * p4

;aPtr += (1 * gkPitchRatio)/sr
endin

instr 11 ; output; always on
 if active:k(2)==0 then
  turnoff
 endif

 kHPFOn            cabbageGetValue     "HPFOn"
 kLPFOn            cabbageGetValue     "LPFOn"
 kx1,kT            cabbageGetValue     "x1"
                   cabbageSetValue     "HPF", scale(kx1,14,4), kT*kHPFOn
 ky1,kT            cabbageGetValue     "y1"
                   cabbageSetValue     "LPF", scale(ky1,14,4), kT*kLPFOn
 kporttime         linseg              0, 0.01, 0.05
 kLPF              cabbageGetValue     "LPF"
 kLPF              portk               kLPF, kporttime
 kHPF              cabbageGetValue     "HPF"
 kHPF              portk               kHPF, kporttime
 kHPF              =                   cpsoct(kHPF)
 kLPF              =                   cpsoct(kLPF)*gkPitchRateRatio
 kLPF              limit               kLPF,20,sr/2
 kHPF              limit               kHPF,20, kLPF
 kLPFRes           cabbageGetValue     "LPFRes"
 aBut1             butlp               gaSend1, kLPF
 aBut2             butlp               gaSend2, kLPF
 ;aRes1             moogladder2         gaSend1, kLPF, kLPFRes
 ;aRes2             moogladder2         gaSend2, kLPF, kLPFRes
 aRes1             diode_ladder         gaSend1*5,kLPF,kLPFRes*17
 aRes2             diode_ladder         gaSend2*5,kLPF,kLPFRes*17
 kMix              =                   kLPFRes > 0 ? 1 : 0
 gaSend1           ntrpol              aBut1, aRes1, port:k(kMix,0.05)
 gaSend2           ntrpol              aBut2, aRes2, port:k(kMix,0.05)
 gaSend1           buthp               gaSend1, kHPF
 gaSend2           buthp               gaSend2, kHPF 
 kGain             cabbageGetValue     "Gain"
 kPan              cabbageGetValue     "Pan"
                   outs                gaSend1 * kGain * (1 - kPan)^2, gaSend2 * kGain * kPan^2
 gaSend1           =                   0
 gaSend2           =                   0

 ; display table
 aPtr              phasor              16
 aPtrD             pdhalf              aPtr, gkPhaseDist
 aPtrD             pdclip              aPtrD, gkPhaseClip, 0
 aOut              tablei              aPtrD, gi1, 1
 if cabbageGetValue:k("WindOnOff")==1 then
  aWind            tablei              aPtr, giWind, 1
  aOut             *=                  aWind
 endif
                   tablew              aOut, aPtr, 101, 1
                   cabbageSet          metro:k(16), "OutputTable", "tableNumber", 101

 ; move wipers
 iBounds[]         cabbageGet          "OutputTable", "bounds"
                   cabbageSet          changed:k(gkPhaseDist), "HalfWiper", "bounds", iBounds[0] + iBounds[2]*0.5 + iBounds[2]*0.5*gkPhaseDist, iBounds[1], 1, iBounds[2]
 ;kHalfWid          =                   iBounds[2]*0.5*(1-(gkPhaseClip*0.5)) ; half width of used wavetable
 ;kXL               =                   iBounds[0] + (iBounds[2] * gkPhaseClip * 0.5)
 ;kXR               =                   iBounds[0] + iBounds[2] - (iBounds[2] * gkPhaseClip * 0.5)
 ;                  cabbageSet          changed:k(gkPhaseClip,gkPhaseDist), "ClipWiperL", "bounds", kXL, iBounds[1], 1, iBounds[2]
 ;                  cabbageSet          changed:k(gkPhaseClip,gkPhaseDist), "ClipWiperR", "bounds", kXR, iBounds[1], 1, iBounds[2]
 
endin


</CsInstruments>

<CsScore>
i 1 0 z
</CsScore>

</CsoundSynthesizer>