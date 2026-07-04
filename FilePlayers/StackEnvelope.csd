/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; StackEnvelope.csd
; Iain McCurdy, 2026

; Open File         - 
; Play/Stop         - 
; Interpolation     - 
; Phase             - 
; N.Layers          - 
; Global Pitch      - 
; Range             - 
; Gap Semis         - 
; HPF               - 
; LPF               - 
; Level             - 
; Env. Peak         - location of the envelope peakin relation to the Phase control
; Gliss Depth       - 
; Env. Scale        - not yet used
; Jit. Depth        - 
; Jit. Rate         - 
; Amp. Shape        - shape spectral envelope biasing higher layers or lower layers
; Rvb. Send         - 
; Rvb. Size         - 
; Range/Glob. Pitch - 
; HPF/LPF           -

<Cabbage>
form caption("Risset Glissando") size(835,735), pluginId("RiGl"), colour(10, 20, 20), guiMode("queue")

soundfiler bounds(  5,  5, 825,140), channel("beg","len"), channel("filer1"),  colour(0, 255, 255, 255), fontColour(160, 160, 160, 255)
label      bounds( 10,  8, 560, 14), text(""), align("left"), colour(0,0,0,0), fontColour(200,200,200), channel("FileName")


image bounds(0,150,835,220), colour(0,0,0,0), plant("controls")
{
image      bounds(  4, 79, 202,115), colour("silver")
gentable   bounds(  5, 80, 200,113), tableNumber(1), channel("envTable"), ampRange(1,0,1), fill(0), tableColour(200,200,255), tableGridColour(0,0,0,0), tableBackgroundColour(50,50,50)
image      bounds(  5, 80,   1,113), colour(255,200,200), channel("wiper")
filebutton bounds(  5,  5, 80, 25), text("Open File","Open File"), fontColour("white") channel("filename"), shape("ellipse")
checkbox   bounds(  5, 40, 95, 25), channel("PlayStop"), text("Play/Stop"), colour("lime"), fontColour:0("white"), fontColour:1("white"), colour:0( 90, 90,0), colour:1(255,255,0), corners(3)
label      bounds(110, 12,100, 14), text("Interpolation"), fontColour("white")
combobox   bounds(110, 28,100, 20), channel("interp"), items("No interp.", "Linear", "Cubic", "Point Sinc"), value(3), fontColour("white")

rslider    bounds(215,  5, 90, 90), channel("Phs"), text("Phase"), range(0, 1, 0), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(290,  5, 90, 90), channel("NLayers"), text("N.Layers"), range(1, 32, 4,1,1), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(365,  5, 90, 90), channel("GlobPitch"), text("Global Pitch"), range(.1, 4, 1,0.5), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(440,  5, 90, 90), channel("Range"), text("Range"), range(.1, 8, 1.2,0.5), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(515,  5, 90, 90), channel("GapSemis"), text("Gap Semis"), range(0.03750, 48, 1), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)

rslider    bounds(590,  5, 90, 90), channel("HPF"), text("HPF"), range(4, 14, 4, 4), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(665,  5, 90, 90), channel("LPF"), text("LPF"), range(4, 14, 14), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(740,  5, 90, 90), channel("Level"), text("Level"), range(  0,  1.00, 0.3, 0.5), colour( 50, 60, 60), trackerColour("silver"),  textColour("white"), valueTextBox(1)

rslider    bounds(215,105, 90, 90), channel("EnvPeak"), text("Env.Peak"), range(-1, 1, 0), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(290,105, 90, 90), channel("GlissDep"), text("Gliss Depth"), range(-12, 12, 1), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(365,105, 90, 90), channel("EnvScale"), text("Env. Scale"), range(0, 1, 1), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(440,105, 90, 90), channel("JitDep"), text("Jit. Depth"), range(0, 100, 7,1,0.1), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(515,105, 90, 90), channel("JitRate"), text("Jit. Rate"), range(0.1, 20, 0.1, 1), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(590,105, 90, 90), channel("AmpShape"), text("Amp. Shape"), range(0.01, 2, 1.1, 1), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(665,105, 90, 90), channel("RvbSnd"), text("Rvb. Send"), range(0, 1, 0.1), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)
rslider    bounds(740,105, 90, 90), channel("RvbSize"), text("Rvb. Size"), range(0.2, 0.99, 0.8,2), colour(50, 60, 60), trackerColour("silver"), textColour("white"), valueTextBox(1)

}

xypad      bounds(  5,365,410,250), channel("X1","Y1"), text("X - Range | Y - Glob.Pitch"), fontColour(0,0,0,0), textColour(200,200,200), ballColour("silver")
xypad      bounds(420,365,410,250), channel("X2","Y2"), text("X - HPF | Y - LPF"), fontColour(0,0,0,0), textColour(200,200,200), ballColour("silver")

keyboard bounds(  5,625, 825, 90)
label    bounds(  5,718, 140, 15), text("Iain McCurdy |2026|"), align("left"), fontColour("silver")

</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-n -+rtmidi=NULL -M0 -dm0
</CsOptions>

<CsInstruments>

; sr set by host
ksmps  = 64
nchnls = 2
0dbfs  = 1

massign 0, 2
giInterpArr[] array 1, 2, 4, 8
gSfilepath    init    ""
gSDropFile    init    ""

giSource      init    0 ; 0 = browser-opened file :: 1 = dropped file


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

giWind        ftgen               0, 0, 4097, -19, 1, 0.5, 270, 0.5  ; A HANNING-TYPE WINDOW






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





opcode StackEnvelopeLayer, aa, Saikikkkkkkkkip
Sfile,aPhs,iEnv,kAmpShape,iInterp, kRange,kGlobPitch,kGlissDep,kEnvPeak,kGlissDep,kEnvScale,kJitDep,kJitRate, iNLayers,iCount xin

aPhsL      pdhalf  aPhs, kEnvPeak  
;printk 0.5,kEnvScale
aEnv       tablei  aPhsL * (1 + (2 * (iCount - 1)) ) - (1 * (iCount - 1)), iEnv, 1

kSpdJit    jspline kJitDep, kJitRate, kJitRate * 2 ; slow speed/pitch jitter
kAmpScl    =       (1 / (iCount ^ kAmpShape)) ; calculate amplitude scaling value for this layer

kGliss     =        (-kGlissDep) * (1 - k(aEnv)) 

; calculate speed/pitch of individual layers
;kSpd       =       kRange^(iCount-1) * kGlobPitch * cent(kSpdJit) * semitone(kGliss) ; geometric
kSpd       =       (1 + (kRange+(iCount-1))) * kGlobPitch * cent(kSpdJit) ; arithmetric

if kSpd<=64 then ; excessive speeds, which will be inaudible anyway, cause massive CPU drain 
 if filenchnls:i(Sfile)==1 then ; mono
 ;left channel
 aL      diskin2 Sfile, kSpd, rnd(filelen:i(Sfile)), 1, 0, iInterp
 ; right channel
 aR      diskin2 Sfile, kSpd, rnd(filelen:i(Sfile)), 1, 0, iInterp
 
 elseif filenchnls:i(Sfile)==2 then ; stereo
 ;stereo
 aL,aR   diskin2 Sfile, kSpd, rnd(filelen:i(Sfile)), 1, 0, iInterp
 endif
endif

aL      *=      aEnv * kAmpScl
aR      *=      aEnv * kAmpScl
;aL      butlp    aL, cpsoct((10 * aEnv) + 4)
;aR      butlp    aR, cpsoct((10 * aEnv) + 4)
aL      buthp    aL, cpsoct((10 * (1-aEnv)) + 4)
aR      buthp    aR, cpsoct((10 * (1-aEnv)) + 4)

aMixL = 0
aMixR = 0
if iCount<iNLayers then
 aMixL, aMixR  StackEnvelopeLayer  Sfile, aPhs, iEnv, kAmpShape,iInterp, kRange, kGlobPitch, kGlissDep, kEnvPeak,kGlissDep,kEnvScale,kJitDep,kJitRate, iNLayers, iCount+1
endif

xout aMixL + aL, aMixL + aR
endop


instr    1 ; always on
 iporttime         =                   0.1
 gkPlayStop        cabbageGetValue     "PlayStop"       ; read in widgets
 gkinterp          cabbageGetValue     "interp"
 gkRate            cabbageGetValue     "Rate"
 gkNLayers         cabbageGetValue     "NLayers"
 gkGlobPitch       cabbageGetValue     "GlobPitch"
 gkGlobPitch       portk               gkGlobPitch, iporttime
 kRange           cabbageGetValue     "Range"
 kGapSemis        cabbageGetValue     "GapSemis"
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
 
 iCurve =  1 ; curve of amp/filter envelope
 kEnvPeak = cabbageGetValue:k("EnvPeak") * 0.5 + 0.5
 if changed:k(kEnvPeak)==1 then
  reinit REBUILD_TABLE
 endif
 REBUILD_TABLE:
 i_   ftgen  1, 0, 4096,16,0,4096*i(kEnvPeak),iCurve,1,4096*(1-i(kEnvPeak)),-iCurve,0 ; construct rise-fall curve
 rireturn
 cabbageSet changed:k(kEnvPeak),"envTable","tableNumber",1
 kPhs   cabbageGetValue   "Phs"
 iBounds[] cabbageGet "wiper", "bounds"
 iX = iBounds[0]
 iY = iBounds[1]
 iWid = iBounds[2]
 iHei = iBounds[3]
 kX   = iX + int(200*kPhs)
 
 cabbageSet changed:k(kX), "wiper", "bounds", kX, iY, iWid, iHei
 
 
 
 
 ; interoperability of 'Range' and 'Gap Semis' controls
 if changed:k(kRange)==1 then
                   cabbageSetValue     "GapSemis", (kRange/ gkNLayers) * 12
 elseif changed:k(kGapSemis,gkNLayers)==1 then
                   cabbageSetValue     "Range", (kGapSemis / 12) * gkNLayers
 endif






 ;  XY Pad 1, range/offset sync
 kX1               cabbageGetValue     "X1"
 kY1               cabbageGetValue     "Y1"
 if changed:k(kX1)==1 then
                   cabbageSetValue     "Range", scale:k(kX1^2,8,0.1)
 endif
 if changed:k(kY1)==1 then
                   cabbageSetValue     "GlobPitch", scale:k(kY1^2,4,0.1)
 endif

 gkRange           port                kRange, iporttime
 gkGapSemis        port                kGapSemis, iporttime

 ; XY Pad 2, HPF/LPF sync
 kX2               cabbageGetValue     "X2"
 kY2               cabbageGetValue     "Y2"
 if changed:k(kX2)==1 then
                   cabbageSetValue     "HPF", scale:k(kX2,14,4)
 endif
 if changed:k(kY2)==1 then
                   cabbageSetValue     "LPF", scale:k(kY2,14,4)
 endif


 
 ; load file from browse
 gSfilepath        cabbageGetValue     "filename"   ; read in file path string from filebutton widget
 if changed:k(gSfilepath)==1 then                   ; call instrument to update waveform viewer  
                   event               "i", 99, 0, 0
 endif
 gSfilepath = "/Volumes/X10\ Pro\ 2/Sabbatical2024-25/MistyMorningInLuzSaintSauveur/HumsAndVowels/01.wav"

 ; load file from dropped file
 gSDropFile        cabbageGet          "LAST_FILE_DROPPED" ; file dropped onto GUI
 if (changed(gSDropFile) == 1) then
                   event               "i", 100, 0, 0         ; load dropped file
 endif
 
 ktrig             trigger             gkPlayStop,0.5,0    ; if play/stop button toggles from low (0) to high (1) generate a '1' trigger
                   schedkwhen          ktrig,0,0,2,0,-1    ; start instrument 2
 

endin




instr    2 ; sound-producing instrument
 idefault          =                   1
 ivalue            =                   0
                   mididefault         idefault, ivalue ; ivalue overwritten by idefault if MIDI driven
 if ivalue==1 then ; MIDI
  kGlobPitch       =                   cpsmidi()/cpsoct(8)
  iVel             =                   ampmidi:i(0.7) ^ 2
 else              ; non-MIDI
  kGlobPitch       =                   gkGlobPitch
  iVel             =                   1
 endif

 Sfile             =                   giSource == 0 ? gSfilepath : gSDropFile ; choose source file (opened or dropped)
 if gkPlayStop==0 && ivalue!=1 then                                                         ; if play/stop is off (stop)...
  turnoff                                                                      ; turn off this instrument
 endif                        
 iStrLen           strlen              Sfile             ; derive string length
 if iStrLen > 0 then                                     ; if string length is greater than zero (i.e. a file has been selected) then...
 
 
 

if changed:k(gkNLayers,gkinterp)==1 then
 reinit RESTART
endif
RESTART:
 iInterp           =                   giInterpArr[i(gkinterp)-1]

;;;
iCurve =  1 ; curve of amp/filter envelope
iEnv ftgen 0,0,4097,16,0,2048,iCurve,1,2048,-iCurve,0 ; construct rise-fall curve

kPhs cabbageGetValue "Phs"
kPhs port kPhs,0.05
kEnvPeak cabbageGetValue "EnvPeak"
;kX = 0 ;invalue "X"
;kY = 0 ;invalue "Y"

kPhs portk kPhs, 0.05
aPhs interp kPhs 


;if changed:k(kX)==1 then
;outvalue "Phs", kX 
;endif

aMixL = 0
aMixR = 0

; for geometric should be >= 1; 2 = octaves
; for arithetic should be >= 0; 1 = harmonic series

kRange cabbageGetValue "Range"
;kPchGap = 1 + kY
kGlissDep       cabbageGetValue     "GlissDep"
kEnvScale       cabbageGetValue     "EnvScale"
kJitDep         cabbageGetValue     "JitDep"
kJitRate         cabbageGetValue     "JitRate"


iGlobAmp = 0.5 ; global amplitude
kAmpShape cabbageGetValue     "AmpShape" ; scaling of upper layers; >1 = steeper shape; <1 = shallower shape

aL,aR StackEnvelopeLayer Sfile,aPhs,iEnv,kAmpShape,iInterp, kRange,kGlobPitch,kGlissDep,kEnvPeak,kGlissDep,kEnvScale,kJitDep,kJitRate,i(gkNLayers)
rireturn

 aL             buthp               aL, gaHPF
 aR             buthp               aR, gaHPF
 aL             butlp               aL, gaLPF
 aR             butlp               aR, gaLPF

; reverb
kRvbSnd         cabbageGetValue     "RvbSnd"
kRvbSize        cabbageGetValue     "RvbSize"

aRvbL,aRvbR reverbsc aL * kRvbSnd, aR * kRvbSnd, kRvbSize, 12000


outs (aL + aRvbL) * gaLevel, (aR + aRvbR) * gaLevel


;;;
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