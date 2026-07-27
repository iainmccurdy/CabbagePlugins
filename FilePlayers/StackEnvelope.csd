/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; StackEnvelope.csd
; Iain McCurdy, 2026


; Intended to be used with a sound file that is a loop of some kind.
; Forms a stack spaced transpositions of that sound file parameters of which are then shaped uniquely 
;  according to the on an envelope (phase).
; Parameters that can be controlled by the envelope phase are:
; - amplitude
; - panning
; - pitch/speed
; - a low-pass filter
; - a high-pass filter

; Open File         -    browse for a sound file
; Play/Stop         -    start/stop playback of the sound file
; Interpolation     -    interpolation mode used in sound file playback. Higher qualities incur a CPU cost.

; N.Layers          -    number of layers (parallel iterations of sound file playback) in the stack.
; Gliss Depth       -    amount of glissando applied by envelope control
; Env. Shape        -    curvature of envelope slopes
; Amp. Bias         -    shape spectral envelope biasing higher layers or lower layers
; Env. LPF          -    amount of LPF fall-off according to the envelope tails
; Env. HPF          -    amount of HPF rise according to the envelope tails

; Jit. Depth        -    pitch/speed jitter depth (random spline)
; Jit. Rate         -    pitch/speed jitter rate (random spline)

; Rvb. Send         -    amount of signal sent to a (late reflection) reverb effect
; Rvb. Size         -    size/duration of the reverb

; Panning           -    amount of panning applied as the envelope phase is adjusted 
; Level             -    output level

; [envelope display]
; Env. Peak         -    (small slider above the envelope display) location of the envelope peakin relation to the Phase control
; Phase             -    envelope phase is simply controlled by clicking and dragging on the envelope display

; Global Pitch      -    global pitch/speed control of all layers
; Gap Semis         -    gap between consecutive layers in semitones
; These are also controllable using the adjacent xy pad
; Geometric/Arithmetic - law which governs the pitch/speed spacing between layers.
;                        Geometric, each subsequent layer is pitch-spaced fromt he previous according 'Gap Semis'.
;                        Arithmetic, each layer is pitch-spaced according to the cycles-per-second determined by first 'Gap Semis' spacing.
;                         i.e. if 'Gap Semis' is 12, layers will form a harmonic series.

; HPF               -    cutoff frequency of a high-pass filter
; LPF               -    cutoff frequency of a low-pass filter
; The filters are also controllable using the y-axis of the adjacent xy pad
; The x-axis can also control the envelope phase.


; Notes can also be triggered using the MIDI keyboard in which case the behaviour is slightly different.
; Global pitch is controlled by the MIDI note number played.
; Env. Dur.         -    duration of passage through the envelope 
; Release           -    release time; continuation time of passage through the envelope after the MIDI key is released  
; Complete Env.     -    (check box) if activated, Release is ignore and the envelope is simply allowed to complete when a key is released
; Kybd. Scale       -    (check box) if activated, durations of Env. Dur and Release are scaled according to the note played
;                         notes above middle C, passage through the envelope is increasingly rapid
;                         notes below middle C, passage through the envelope is increasingly gradual


<Cabbage>
form caption("Stack Envelope") size(1020,735), pluginId("RiGl"), colour(50, 55, 55), guiMode("queue")

filebutton bounds( 10, 10,100, 25), text("Open File","Open File"), fontColour("white") channel("filename"), corners(5)
checkbox   bounds( 10, 45, 95, 25), channel("PlayStop"), text("Play/Stop"), colour("lime"), fontColour:0("white"), fontColour:1("white"), colour:0( 90, 90,0), colour:1(255,255,0), corners(3)
label      bounds( 10, 78,100, 14), text("Interpolation"), fontColour("white")
combobox   bounds( 10, 93,100, 25), channel("interp"), items("No interp.", "Linear", "Cubic", "Point Sinc"), value(3), fontColour("white")
soundfiler bounds(120,  5,890,115), channel("filer1"),  colour(0, 255, 255, 255), fontColour(160, 160, 160, 255)
label      bounds(125,  8,560, 14), text(""), align("left"), colour(0,0,0,0), fontColour(200,200,200), channel("FileName")


image      bounds( 10,130,475,120), colour(0,0,0,0), outlineThickness(1), outlineColour("silver"), corners(5)
{
label      bounds(  0,  3,475, 15), text("S H A P E")
rslider    bounds(  5, 20, 90, 90), channel("NLayers"), text("N.Layers"), range(1, 32, 4,1,1), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds( 80, 20, 90, 90), channel("GlissDep"), text("Gliss Depth"), range(-12, 12, 1), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(155, 20, 90, 90), channel("EnvShape"), text("Env. Shape"), range(-4, 4, 0), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(230, 20, 90, 90), channel("AmpBias"), text("Amp. Bias"), range(0.01, 2, 1.1, 1), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(305, 20, 90, 90), channel("EnvLPF"), text("Env. LPF"), range(0, 1, 1), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(380, 20, 90, 90), channel("EnvHPF"), text("Env. HPF"), range(0, 1, 0), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
}

image      bounds(490,130,170,120), colour(0,0,0,0), outlineThickness(1), outlineColour("silver"), corners(5)
{
label      bounds(  0,  3,170, 15), text("J I T T E R")
rslider    bounds(  0, 20, 90, 90), channel("JitDep"), text("Jit. Depth"), range(0, 100, 7,1,0.1), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds( 80, 20, 90, 90), channel("JitRate"), text("Jit. Rate"), range(0.1, 20, 0.1, 1), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
}

image      bounds(665,130,170,120), colour(0,0,0,0), outlineThickness(1), outlineColour("silver"), corners(5)
{
label      bounds(  0,  3,170, 15), text("R E V E R B")
rslider    bounds(  0, 20, 90, 90), channel("RvbSnd"), text("Rvb. Send"), range(0, 1, 0.1), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds( 80, 20, 90, 90), channel("RvbSize"), text("Rvb. Size"), range(0.2, 0.99, 0.8,2), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
}

image      bounds(840,130,170,120), colour(0,0,0,0), outlineThickness(1), outlineColour("silver"), corners(5)
{
label      bounds(  0,  3,170, 15), text("O U T P U T")
rslider    bounds(  0, 20, 90, 90), channel("Panning"), text("Panning"), range(  0,  1.00, 0), colour( 50, 60, 60), trackerColour("silver"),  textColour("white"), valueTextBox(1)
rslider    bounds( 80, 20, 90, 90), channel("Level"), text("Level"), range(  0,  1.00, 0.3, 0.5), colour( 50, 60, 60), trackerColour("silver"),  textColour("white"), valueTextBox(1)
}

image      bounds( 10,255,1000,100), colour(0,0,0,0), outlineThickness(1), outlineColour("silver"), corners(5)
{
hslider    bounds(  9,  3, 980, 15), channel("EnvPeak"), range(-0.99, 0.99, 0), colour(50, 60, 60), trackerColour("silver"), colour("white")
gentable   bounds( 10, 20, 980, 73), tableNumber(1), channel("envTable"), ampRange(1,0,1), fill(0), tableColour(200,200,255), tableGridColour(0,0,0,0), tableBackgroundColour(50,50,50)
image      bounds( 10, 20,   1, 73), colour("white"), channel("wiper")
hslider    bounds(  5, 20, 990, 73), channel("Phs"), range(0, 1, 0.1), colour(50, 60, 60), trackerColour("silver"), alpha(0), popupText(0)
}

rslider    bounds(  5,395, 90, 90), channel("GlobPitch"), text("Global Pitch"), range(.1, 4, 1,0.5), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(  5,495, 90, 90), channel("GapSemis"), text("Gap Semis"), range(-12, 12, 7), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
combobox   bounds( 10,590, 80, 22), channel("GapLaw"), items("Geometric", "Arithmetic"), value(1), fontColour("white")
xypad      bounds( 95,365,410,250), channel("X1","Y1"), text("X - Range | Y - Glob.Pitch"), fontColour(0,0,0,0), textColour(200,200,200), ballColour("silver")
checkbox   bounds(102,583,130, 13), channel("XtoGapSemis"), text("X to Gap Semis"), colour("Yellow"), fontColour:0("white"), fontColour:1("white"), value(1), corners(4)
checkbox   bounds(102,599,130, 13), channel("YtoPitch"), text("Y to Pitch"), colour("Yellow"), fontColour:0("white"), fontColour:1("white"), value(1), corners(4)

rslider    bounds(510,395, 90, 90), channel("HPF"), text("HPF"), range(4, 14, 4, 4), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(510,495, 90, 90), channel("LPF"), text("LPF"), range(4, 14, 14), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
xypad      bounds(605,365,410,250), channel("X2","Y2"), text("X - Phase | Y - Filters"), fontColour(0,0,0,0), textColour(200,200,200), ballColour("silver")
checkbox   bounds(612,583,130, 13), channel("XtoPhase"), text("X to Phase"), colour("Yellow"), fontColour:0("white"), fontColour:1("white"), value(1), corners(4)
checkbox   bounds(612,599,130, 13), channel("YtoFilters"), text("Y to Filters"), colour("Yellow"), fontColour:0("white"), fontColour:1("white"), value(1), corners(4)

rslider  bounds( 10,625, 90, 90), channel("EnvDur"), text("Env. Dur."), range(0.05, 16, 2, 0.5), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider  bounds( 85,625, 90, 90), channel("EnvRel"), text("Release"),   range(0.05, 16, 0.2, 0.5), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
checkbox bounds(170,652,130, 13), channel("CompleteEnv"), text("Complete Env."), colour("Yellow"), fontColour:0("white"), fontColour:1("white"), value(0), corners(4)
checkbox bounds(170,672,130, 13), channel("KybdScl"), text("Kybd. Scale"), colour("Yellow"), fontColour:0("white"), fontColour:1("white"), value(0), corners(4)
keyboard bounds(285,625,725, 90)
label    bounds( 10,718,140, 15), text("Iain McCurdy |2026|"), align("left"), fontColour("silver")

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
giInterpArr[]      array               1, 2, 4, 8
gSfilepath         init                ""
gSDropFile         init                ""
giSource           init                0 ; 0 = browser-opened file :: 1 = dropped file

; tuning tables
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
giWind             ftgen               0, 0, 4097, -19, 1, 0.5, 270, 0.5  ; A HANNING-TYPE WINDOW






; Smoother
; ----------------
; Smooths low resolution contiguous data with adaptive lag filtering.  
; Heavier filtering is applied when changes are smaller than when changes are large. 
; This often provides musically more succesful smoothing than can be achieved with portamento (port, portk) or the lineto opcode.
; This UDO might be useful in improving data received from 7-bit MIDI controllers while minimising sluggish response if the control is moved more quickly.

; kout  Smoother  kin,ktime

; Performance
; -----------
; kin   -  input signal
; ktime -  time taken to reach new value
; kout  -  output value


opcode Smoother, k, kk
 kinput, ktime     xin
 kPrevVal          init                0 
 kRamp             linseg              0, 0.01, 1
 ktime             =                   kRamp * divz:k(ktime, abs(kinput-kPrevVal), 0.000001)
 if changed:k(kinput, ktime)==1 then
                   reinit              RESTART
 endif
 RESTART:
 if i(ktime)==0 then
  koutput          =                   i(kinput)
 else
  koutput          linseg              i(koutput), i(ktime), i(kinput)
 endif
 rireturn
                   xout                koutput
 kPrevVal          =                   koutput
endop





opcode StackEnvelopeLayer, aa, Saikikkkkkkkkkkkkip
Sfile,aPhs,iEnv,kAmpBias,iInterp,kGapSemis,kGapLaw,kGlobPitch,kGlissDep,kEnvPeak,kGlissDep,kEnvShape,kJitDep,kJitRate,kPanning,kEnvLPF,kEnvHPF,iNLayers,iCount xin
aPhsL              pdhalf              aPhs, kEnvPeak  
aEnv               tablei              aPhsL * (1 + (2 * (iCount - 1)) ) - (1 * (iCount - 1)), iEnv, 1
aEnv               pow                 aEnv, kEnvShape

kSpdJit            jspline             kJitDep, kJitRate, kJitRate * 2 ; slow speed/pitch jitter
kAmpScl            =                   (1 / (iCount ^ kAmpBias)) ; calculate amplitude scaling value for this layer

kGliss             =                   (-kGlissDep) * (1 - k(aEnv)) 

; calculate speed/pitch of individual layers
if kGapLaw==1 then ; geometric
 kSpd              =                   octave((kGapSemis/12) * (iCount-1)) * kGlobPitch * cent(kSpdJit) * semitone(kGliss) ; geometric
else ; arithmetic
 kSpd              =                   (iCount ^ (kGapSemis/12) ) * kGlobPitch * cent(kSpdJit) * semitone(kGliss) ; geometric
endif

if kSpd<=64 then ; excessive speeds, which will be inaudible anyway, cause massive CPU drain 
 if filenchnls:i(Sfile)==1 then ; mono
 ; left channel
 aL                diskin2             Sfile, kSpd, rnd(filelen:i(Sfile)), 1, 0, iInterp
 ; right channel
 aR                diskin2             Sfile, kSpd, rnd(filelen:i(Sfile)), 1, 0, iInterp
 
 elseif filenchnls:i(Sfile)==2 then ; stereo
 ;stereo
 aL,aR             diskin2             Sfile, kSpd, rnd(filelen:i(Sfile)), 1, 0, iInterp
 endif
endif

aL                 *=                  aEnv * kAmpScl
aR                 *=                  aEnv * kAmpScl

; lowpass filter
aLPF_CF            ntrpol              a(cpsoct(14)), cpsoct((10 * aEnv) + 4), kEnvLPF
aL                 butlp               aL, aLPF_CF
aR                 butlp               aR, aLPF_CF

; highpass filter
aHPF_CF            ntrpol              a(cpsoct(4)), cpsoct((10 * (1-aEnv)) + 4), kEnvHPF
aL                 buthp               aL, aHPF_CF
aR                 buthp               aR, aHPF_CF

; panning
aL                 =                   aL * (0.5 + ((1 - aPhs) * kPanning))
aR                 =                   aR * (0.5 + (aPhs * kPanning))

aMixL              =                   0
aMixR              =                   0
if iCount<iNLayers then
 aMixL, aMixR      StackEnvelopeLayer  Sfile, aPhs,iEnv,kAmpBias,iInterp,kGapSemis,kGapLaw,kGlobPitch,kGlissDep,kEnvPeak,kGlissDep,kEnvShape,kJitDep,kJitRate,kPanning,kEnvLPF,kEnvHPF,iNLayers,iCount+1
endif

                   xout                aMixL + aL, aMixL + aR
endop


instr    1 ; always on
 iporttime         =                   0.1
 gkPlayStop        cabbageGetValue     "PlayStop"       ; read in widgets
 gkinterp          cabbageGetValue     "interp"
 gkRate            cabbageGetValue     "Rate"
 gkNLayers         cabbageGetValue     "NLayers"
 gkGlobPitch       cabbageGetValue     "GlobPitch"
 gkGlobPitch       portk               gkGlobPitch, iporttime
 kGapSemis         cabbageGetValue     "GapSemis"
 gkHPF             cabbageGetValue     "HPF"
 gkLPF             cabbageGetValue     "LPF"
 gkHPF             =                   cpsoct(gkHPF)
 gkLPF             =                   cpsoct(gkLPF)
 gkHPF             port                gkHPF, iporttime
 gkLPF             port                gkLPF, iporttime
 gaHPF             interp              gkHPF
 gaLPF             interp              gkLPF
 gkLevel           cabbageGetValue     "Level"
 gaLevel           interp              gkLevel
 gkEnvShape        cabbageGetValue     "EnvShape"

 kEnvPeak          =                   cabbageGetValue:k("EnvPeak") * 0.5 + 0.5
 if changed:k(kEnvPeak,gkEnvShape)==1 then
  reinit REBUILD_TABLE
 endif
 REBUILD_TABLE:
 iCurve            =                   i(gkEnvShape)                                      ; curve of amp/filter envelope
 giEnv             ftgen               1, 0, 4096,16,0,4096*i(kEnvPeak),iCurve,1,4096*(1-i(kEnvPeak)),-iCurve,0 ; construct rise-fall curve
 rireturn
                   cabbageSet          changed:k(kEnvPeak,gkEnvShape), "envTable", "tableNumber", 1
 kPhs              cabbageGetValue     "Phs"
 iTableBounds[]    cabbageGet          "envTable", "bounds"
 kX                =                   iTableBounds[0] + int(kPhs*iTableBounds[2])
                   cabbageSet          changed:k(kX), "wiper", "bounds", kX, iTableBounds[1], 1, iTableBounds[3]
   
 ;  XY Pad 1, range/offset sync
 kX1, kT           cabbageGetValue     "X1"
                   cabbageSetValue     "GapSemis", scale:k(kX1,24,-24), kT * cabbageGetValue:k("XtoGapSemis")
 kY1, kT           cabbageGetValue     "Y1"
                   cabbageSetValue     "GlobPitch", scale:k(kY1^2,4,0.1), kT * cabbageGetValue:k("YtoPitch")

 ;gkRange           port                kRange, iporttime
 gkGapSemis        port                kGapSemis, iporttime

 ; XY Pad 2,  Phs / LPF-HPF
 kX2,kT            cabbageGetValue     "X2"
                   cabbageSetValue     "Phs", kX2, kT * cabbageGetValue:k("XtoPhase")
 
 kY2,kT            cabbageGetValue     "Y2"                   
 ; filter parameters from xypad 2 y-axis
                   cabbageSetValue     "LPF", limit:k(scale:k((kY2 * 2), 14, 4),4,14), kT * cabbageGetValue:k("YtoFilters")
                   cabbageSetValue     "HPF", limit:k(scale:k((kY2 * 2) - 1, 14, 4),4,14), kT * cabbageGetValue:k("YtoFilters")

 
 ; load file from browse
 gSfilepath        cabbageGetValue     "filename"   ; read in file path string from filebutton widget
 if changed:k(gSfilepath)==1 then                   ; call instrument to update waveform viewer  
                   event               "i", 99, 0, 0
 endif

 ; load file from dropped file
 gSDropFile        cabbageGet          "LAST_FILE_DROPPED" ; file dropped onto GUI
 if (changed(gSDropFile) == 1) then
                   event               "i", 100, 0, 0         ; load dropped file
 endif
 
 ktrig             trigger             gkPlayStop,0.5,0    ; if play/stop button toggles from low (0) to high (1) generate a '1' trigger
                   schedkwhen          ktrig,0,0,2,0,-1    ; start instrument 2

endin




instr    2 ; sound-producing instrument - MIDI and GUI
 idefault          =                   1
 ivalue            =                   0
                   mididefault         idefault, ivalue ; ivalue overwritten by idefault if MIDI driven
 if ivalue==1 then ; MIDI
  kGlobPitch       =                   cpsmidi()/cpsoct(8)
  iVel             =                   ampmidi:i(0.7) ^ 2
  iCompleteEnv     cabbageGetValue     "CompleteEnv"
  iKybdScl         cabbageGetValue     "KybdScl"  
  iEnvDur          cabbageGetValue     "EnvDur"
  iEnvRel          =                   iCompleteEnv == 1 ? iEnvDur : cabbageGetValue:i("EnvRel")
  if iKybdScl==1 then
   iScl            =                   cpsmidi() / cpsmidinn(8)
   iEnvDur         /=                  iScl
   iEnvRel         /=                  iScl
  endif
  kPhs             linseg              0, iEnvDur, 1
                   xtratim             iEnvRel
                   cabbageSetValue     "Phs", kPhs
  ;aAmpEnv          =                   iCompleteEnv == 1 ? 1 : expsegr:a(1,iEnvRel,0.001)
  aAmpEnv          expsegr             1, iEnvRel, 0.001
  if iCompleteEnv==1 then
   aAmpEnv          =                  1
  endif
 else              ; non-MIDI
  kGlobPitch       =                   gkGlobPitch
  iVel             =                   1
  aAmpEnv          expsegr             1, 0.1, 0.001
 endif

 Sfile             =                   giSource == 0 ? gSfilepath : gSDropFile ; choose source file (opened or dropped)
 if gkPlayStop==0 && ivalue!=1 then                                                         ; if play/stop is off (stop)...
  turnoff                                                                      ; turn off this instrument
 endif                        
 iStrLen           strlen              Sfile             ; derive string length
 if iStrLen>0 then                                       ; if string length is greater than zero (i.e. a file has been selected) then...
 

kEnvShape          =                   gkEnvShape

if changed:k(kEnvShape)==1 then
 reinit UPDATE_TABLE
endif
UPDATE_TABLE:

;;;
iCurve =  i(kEnvShape) ; curve of amp/filter envelope
iEnv               ftgen               2,0,4097,16,0,2048,iCurve,1,2048,-iCurve,0 ; construct rise-fall curve without peak modulation
rireturn

if changed:k(gkNLayers,gkinterp)==1 then
 reinit RESTART_STACK
endif
RESTART_STACK:
 iInterp           =                   giInterpArr[i(gkinterp)-1]

kPhs               cabbageGetValue     "Phs"
kPhs               port                kPhs,0.05
kEnvPeak           cabbageGetValue     "EnvPeak"

kPhs               portk               kPhs, 0.05
aPhs               interp              kPhs

aMixL              =                   0
aMixR              =                   0

kGlissDep          cabbageGetValue     "GlissDep"
kJitDep            cabbageGetValue     "JitDep"
kJitRate           cabbageGetValue     "JitRate"
kPanning           cabbageGetValue     "Panning"
kEnvLPF            cabbageGetValue     "EnvLPF"
kEnvHPF            cabbageGetValue     "EnvHPF"
kEnvShape          =                   2 ^ kEnvShape
kGapLaw            cabbageGetValue     "GapLaw"
iGlobAmp           =                   0.5 ; global amplitude
kAmpBias           cabbageGetValue     "AmpBias" ; scaling of upper layers; >1 = steeper shape; <1 = shallower shape

aL,aR              StackEnvelopeLayer  Sfile,aPhs,iEnv,kAmpBias,iInterp,gkGapSemis,kGapLaw,kGlobPitch,kGlissDep,kEnvPeak,kGlissDep,kEnvShape,kJitDep,kJitRate,kPanning,kEnvLPF,kEnvHPF,i(gkNLayers)
rireturn

if cabbageGetValue:k("YtoFilters")==1 then
 aL                buthp               aL, gaHPF
 aR                buthp               aR, gaHPF
 aL                butlp               aL, gaLPF
 aR                butlp               aR, gaLPF
endif

; reverb
kRvbSnd            cabbageGetValue     "RvbSnd"
kRvbSize           cabbageGetValue     "RvbSize"

aRvbL,aRvbR        reverbsc            aL * kRvbSnd, aR * kRvbSnd, kRvbSize, 12000

                   outs                (aL + aRvbL) * gaLevel * aAmpEnv, (aR + aRvbR) * gaLevel * aAmpEnv
 endif
endin



instr    99 ; LOAD SOUND FILE
 giSource          =                   0
                   cabbageSet          "filer1", "file", gSfilepath

 /* write file name to GUI */
 SFileNoExtension  cabbageGetFileNoExtension gSfilepath
                   cabbageSet          "FileName","text",SFileNoExtension

endin

instr    100 ; LOAD DROPPED SOUND FILE
 giSource          =                   1
                   cabbageSet          "filer1", "file", gSDropFile

 /* write file name to GUI */
 SFileNoExtension  cabbageGetFileNoExtension gSDropFile
                   cabbageSet          "FileName","text",SFileNoExtension

endin

</CsInstruments>  

<CsScore>
i 1 0 z
</CsScore>

</CsoundSynthesizer>