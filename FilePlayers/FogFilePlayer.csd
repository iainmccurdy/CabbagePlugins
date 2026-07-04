/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; FogFilePlayer.csd
; Written by Iain McCurdy, 2015, 2025

; 2025 modification in that always processed in stereo (mono source copies single channel to both channels of the required stereo source)
; stereophonic effects on mono sources are introduced through any of the randomisation features

; NOTE THAT TRANSPOSITION CHANGES WITH INCREASING QUANTISATION IF INPUT SOUND FILE SIZE IT VERY LARGE. SUGGEST RESTRICTING SOUND FILES TO A DURATION OF JUST A FEW SECONDS TO AVOID THIS.

; File player based around the granular synthesis opcode, 'fog'.
; A second voice can be activated (basically another parallel granular synthesiser) with parameter ariations of density, transposition, pointer location (Phs) and delay.
; Two modes of playback are available: manual pointer and speed
; The pointer and grain density can also be modulated by clicking and dragging on the waeform iew.
;  * This will also start and stop the grain producing instrument.
;  * In click-and-drag mode mouse X position equates to pointer position and mouse Y position equates to grain density. 
; If played from the MIDI keyboard, note number translates to 'Transposition' and key elocity translates to amplitude for the grain stream for that note.

; In 'Pointer' mode pointer position is controlled by the long 'Manual' slider with an optional amount of randomisation determined ny the 'Phs.Mod' slider.  

; Selecting 'Speed' pointer mode bring up some additional controls:
; Speed              -    speed ratio
; Freeze             -    freezes the pointer at its present locations 
; Range              -    ratio of the full sound file duration that will be played back. 1=the_entire_file, 0.5=half_the_file, etc. 
; Shape              -    shape of playback function:     'Phasor' looping in a single direction
;                                                'Tri' back and forth looping
;                                                'Sine' back and forth looping using a sinudoidal shape - i.e. slowing at the extremes of the oscillation
; The 'Manual' control functions as an pointer offset when using 'Speed' pointer mode
                                                          
; Density            -    grains per second
; Oct.Div            -    thinning the density in oerlapping octave steps. I.e. density is halved and then halved again etc. 
; Transpose          -    transposition as a ratio. Negative values result in grains playing in reverse.
; Transposition Mode -    timing of transposition changes: 'Grain by Grain'    - grains always maintain the transposition with which they began
;                                                          'Continuous'        - even grains in progress can be altered by changes made to 'Transpose' 
; Rate               -    when 'Continuous' is chosen, the 'Rate' slider that pops up controls the rate of random wobble if 'Tranms.Mod' is used

; --Randomisation--                                                   
; Trans.Mod.         -    randomisation of transposition (in octaves)
; Ptr.Mod.           -    randomisation of pointer position
; Dens Mod.          -    randomisation of grain density
; Amp.Mod.           -    randomisation of grain amplitude. Note that this is done on a grain by grain basis, grains retain the amplitude with which they start.

; --Density LFO--
; Depth              -    depth of LFO modulation of grain density (negative values inverts the LFO waveform)
; Amplitude          -    depth of LFO modulation of amplitude (negative values inverts the LFO waveform)
; Filter             -    depth of LFO modulation of the cutoff frequency of a low-pass filter (negative values inverts the LFO waveform)
; Res.               -    resonance of the low-pass filter
; Rate               -    rate of LFO modulation
; Shape              -    shape of the envelope; sine or random (random splines) 

; --Voice 2--
; Dens.Ratio         -    ratio of grain density of voice 2 with respect to the main oice (also adjustable using the adjacent number box for precise vvalue input)
; Ptr.Diff.          -    pointer position offset of voice 2 with respect to the main oice (also adjustable using the adjacent number box for precise vvalue input)
; Trans.Diff.        -    transposition offset of voice 2 with respect to the main oice (also adjustable using the adjacent number box for precise vvalue input)
; Delay              -    a delay applied to voice 2 which is defined as a ratio of the gap between grains (therefore delay time will be inversely proportional to grain density)
;                         This is a little like a phase offset for oice 2 with respect to that of the main oice.
;                         When using this control 'Dens.Ratio' should be '1' otherwise continuous temporally shifting between the grains of voice 2 and the main oice will be occurring anyway.

; --Enelope--
; Attack             -    amplitude envelope attack time for the envelope applied to complete notes
; Release            -    amplitude envelope release time for the envelope applied to complete notes

; --Control--
; MIDI Ref.          -    MIDI note that represent unison (no transposition) for when using the MIDI keyboard
; Level              -    output amplitude control

; --Tuning--
;                    -    choose from a range of tuning systems for the MIDI keyboard. 
;                         There is some quantisations of pitch within the fog opcode so the accuracy of these tunings will be limited, particularly for high notes.

<Cabbage>
form caption("fog File Player") size(1260,510), colour(0,0,0), pluginId("FgFP"), guiMode("queue")

#define RSliderStyle trackerColour(130,135,170), textColour("white"), outlineColour( 10, 15, 50), colour( 50, 45, 90), valueTextBox(1)
#define RSliderStyle2 trackerColour(130,135,170), textColour("white"), outlineColour( 10, 15, 50), colour( 50, 45, 90), valueTextBox(0)
#define CheckboxStyle fontColour:0(255,255,255), fontColour:1(255,255,255)

image       bounds(  0,  0,1260,510), file("darkBrushedMetal.jpeg"), colour( 30, 35, 70), outlineColour("White"), shape("sharp"), line(3)
soundfiler  bounds(  5,  5,1250,175), channel("filer"),  colour(0, 255, 255, 255), fontColour(160, 160, 160, 255), 
label       bounds(  7,  5, 560, 14), text(""), align(left), colour(0,0,0,0), fontColour(200,200,200), channel("stringbox")
image       bounds(  5,  5,   1,175), channel("indicator"), visible(0)

hslider     bounds(  0,180,1260, 15), channel("phs"),   range( 0,1,0,1,0.0001), $RSliderStyle2
label       bounds(  0,195,1260, 13), text("Manual"), fontColour("white")

filebutton  bounds(  5,210,  80, 25), text("Open File","Open File"), fontColour("white") channel("filename"), shape("ellipse")
checkbox    bounds(  5,240,  95, 20), channel("PlayStop"), text("Play/Stop"), $CheckboxStyle
label       bounds(  5,263, 145, 12), text("[or right-click and drag]"), fontColour("white"), align("left")
checkbox    bounds(  5,280,  95, 11), channel("YFilters"), text("Y-Filters"), fontColour:0("white"), fontColour:1("white"), colour:0( 85, 85,0), colour:1(255,255,0), value(1)
checkbox    bounds(  5,293,  95, 11), channel("YDensity"), text("Y-Density"), fontColour:0("white"), fontColour:1("white"), colour:0( 85, 85,0), colour:1(255,255,0), value(1)

label       bounds( 90,215, 75, 13), text("Ptr.Mode"), fontColour("white")
combobox    bounds( 90,230, 75, 20), channel("PhsMode"), items("Manual", "Speed"), value(2),fontColour("white")

rslider     bounds(160,215, 90, 80), channel("port"),     range( 0, 30.00, 0.01,0.5,0.01), text("Port."), visible(0), $RSliderStyle

rslider     bounds(160,215, 90, 80), channel("spd"),     range( -20, 20, 1), text("Speed"), visible(1), $RSliderStyle
button      bounds(240,230, 60, 20), channel("freeze"),  colour:0( 20, 20,40), colour:1(50,55,150), text("Freeze","Freeze"), fontColour:0(70,70,70), fontColour:1(200,200,255), visible(1)
rslider     bounds(290,215, 90, 80), channel("range"),   range(0.01,  1,  1),              text("Range"), visible(1), $RSliderStyle
label       bounds(370,215, 65, 13), text("Shape"), fontColour("white"), channel("shapelabel")
combobox    bounds(370,230, 65, 20), channel("shape"), items("phasor","tri","sine"), value(1), fontColour("white")

rslider     bounds(430, 214, 90, 80), channel("dens"),    range(0.2,4000, 50, 0.333,0.001),  text("Density"), $RSliderStyle colour(50, 45, 90, 255) outlineColour(10, 15, 50, 255) textColour(255, 255, 255, 255) trackerColour(130, 135, 170, 255)
rslider     bounds(500, 215, 90, 80), channel("OctDiv"),  range(  0,  8,    0, 0.5),  text("Oct.Div."), $RSliderStyle
rslider     bounds(570, 214, 90, 80), channel("pch"),     range(-8, 8, 1, 1, 0.001), text("Transpose"), $RSliderStyle colour(50, 45, 90, 255) outlineColour(10, 15, 50, 255) textColour(255, 255, 255, 255) trackerColour(130, 135, 170, 255)
label       bounds(655,210,120, 13), text("Transposition Mode"), fontColour("white")
combobox    bounds(655,225,120, 20), channel("TransMode"), items("Grain by Grain","Continuous"), value(1), fontColour("white")
hslider     bounds(655,250,120, 20), channel("TransRate"),     range(0, 10, 1,0.5), text("Rate"), visible(0), $RSliderStyle2

image       bounds(790,202,300,100), colour(0,0,0,0), outlineColour("grey"), outlineThickness(1), shape("sharp"), plant("GrainEn"), { 
label       bounds(  0,  2,300, 10), text("G  R  A  I  N     E  N  V  E  L  O  P  E"), fontColour("white")
rslider     bounds(  0, 13, 90, 80), channel("dur"),     range(0.01, 2,    0.2, 0.5,0.0001),                    text("Duration"),  $RSliderStyle
rslider     bounds( 70, 13, 90, 80), channel("ris"),     range(0.001,0.2,  0.01,0.5,0.0001),  text("Rise"),      $RSliderStyle
rslider     bounds(140, 13, 90, 80), channel("dec"),     range(0.001,0.2,  0.01,0.5,0.0001),                    text("Decay"),     $RSliderStyle
rslider     bounds(210, 13, 90, 80), channel("band"),    range(0,    100,  3,  0.5,0.0001),                    text("Bandwidth"), $RSliderStyle
}

image       bounds(1095,202,160,100), colour(0,0,0,0), outlineColour("grey"), outlineThickness(1), shape("sharp"), plant("enelope"), { 
label       bounds(  0,   2,160, 10), text("E   N   V   E   L   O   P   E"), fontColour("white")
rslider     bounds(  0,  13, 90, 80), channel("AttTim"),    range(0, 5, 0, 0.5, 0.001),       text("Attack"), $RSliderStyle
rslider     bounds( 70,  13, 90, 80), channel("RelTim"),    range(0.01, 5, 0.05, 0.5, 0.001), text("Release"), $RSliderStyle
}

image       bounds(  5,310,300,100), colour(0,0,0,0), outlineColour("grey"), outlineThickness(1), shape("sharp"), plant("randomise"), { 
label       bounds(  0,  2,300, 10), text("R  A  N  D  O  M  I  S  E"), fontColour("white")
rslider     bounds(  0, 13, 90, 80), channel("fmd"),     range(    0, 1,    0), text("Trans.Mod."), $RSliderStyle
rslider     bounds( 70, 13, 90, 80), channel("pmd"),     range(    0, 1,    0.2,0.5,0.001),  text("Ptr.Mod."), $RSliderStyle
rslider     bounds(140, 13, 90, 80), channel("DensRnd"), range(    0, 2,    0), text("Dens.Mod."), $RSliderStyle
rslider     bounds(210, 13, 90, 80), channel("AmpRnd"),  range(    0, 1,    0), text("Amp.Mod."), $RSliderStyle
}

image       bounds(310,310,405,100), colour(0,0,0,0), outlineColour("grey"), outlineThickness(1), shape("sharp"), plant("LFO"), { 
label       bounds(  0,  2,405, 10), text("L  F  O"), fontColour("white")
rslider     bounds(  0, 13, 90, 80), channel("DensLFODep"), range(-2, 2, 0, 1, 0.001),       text("Density"), $RSliderStyle
rslider     bounds( 65, 13, 90, 80), channel("AmpLFODep"),  range(-1, 1, 0, 1, 0.001),  text("Amplitude"),  $RSliderStyle
rslider     bounds(130, 13, 90, 80), channel("FiltLFODep"),  range(-4, 4, 0, 1, 0.001),  text("Filter"),  $RSliderStyle
rslider     bounds(195, 13, 90, 80), channel("FiltRes"),  range(0, 1, 0, 0.5),  text("Res."),  $RSliderStyle
rslider     bounds(260, 13, 90, 80), channel("LFORte"),     range(0.01, 8, 0.1, 0.5, 0.001),  text("Rate"),  $RSliderStyle
label       bounds(335, 15, 60, 13), text("Shape"), fontColour("white")
combobox    bounds(335, 30, 60, 20), channel("LFOShape"), items("Sine","Rand."), value(1)
}
                              
image       bounds(720,310,370,100), colour(0, 0, 0, 0), outlineColour(128, 128, 128, 255), outlineThickness(1), , plant("dual"), { channel("image125")
label       bounds(  0,  2,370,10), text("V  O  I  C  E     2"), fontColour(255, 255, 255, 255) channel("label126")
checkbox    bounds( 10, 10, 70, 15), channel("DualOnOff"), text("On/Off"), $CheckboxStyle fontColour:0(255, 255, 255, 255) fontColour:1(255, 255, 255, 255)
rslider     bounds( 70, 13, 90, 80), channel("DensRatio"),   range(0.5, 2, 1, 0.64, 1e-05), text("Dens.Ratio"), $RSliderStyle colour(50, 45, 90, 255) outlineColour(10, 15, 50, 255) textColour(255, 255, 255, 255) trackerColour(130, 135, 170, 255)
rslider     bounds(140, 13, 90, 80), channel("PtrDiff"),   range(-1, 1, 0, 1, 1e-05), text("Ptr.Diff."), $RSliderStyle colour(50, 45, 90, 255) outlineColour(10, 15, 50, 255) textColour(255, 255, 255, 255) trackerColour(130, 135, 170, 255)
rslider     bounds(210, 13, 90, 80), channel("TransDiff"),   range(-2, 2, 0, 1, 1e-05), text("Trans.Diff."), $RSliderStyle colour(50, 45, 90, 255) outlineColour(10, 15, 50, 255) textColour(255, 255, 255, 255) trackerColour(130, 135, 170, 255)
rslider     bounds(280, 13, 90, 80), channel("Delay"),       range(0, 1, 0, 1, 1e-05), text("Delay"), $RSliderStyle colour(50, 45, 90, 255) outlineColour(10, 15, 50, 255) textColour(255, 255, 255, 255) trackerColour(130, 135, 170, 255)
}

image       bounds(1095,310,160,100), colour(0,0,0,0), outlineColour("grey"), outlineThickness(1), shape("sharp"), plant("control"), 
{ 
label       bounds(  0,  2,160, 10), text("C   O   N   T   R   O   L"), fontColour("white")
rslider     bounds(  0, 13, 90, 80), channel("MidiRef"),   range(0,127,60, 1, 1),   text("MIDI Ref."), $RSliderStyle
rslider     bounds( 70, 13, 90, 80), channel("level"),     range(  0,  3.00, 0.7, 0.5, 0.001), text("Level"), $RSliderStyle
}


button      bounds(1140,420,110,75), text("REC","REC"), channel("RecOut"), value(0), latched(1), fontColour:0(170,170,170), fontColour:1(255,205,205), colour:0(80,40,40), colour:1(150,0,0), corners(5)

label       bounds( 10,433,110, 13), text("Tuning"), fontColour("White")
combobox    bounds( 10,450,110, 22), channel("Tuning"), items("12-TET", "24-TET", "12-TET rev.", "24-TET rev.", "10-TET", "36-TET", "Just C", "Just C#", "Just D", "Just D#", "Just E", "Just F", "Just F#", "Just G", "Just G#", "Just A", "Just A#", "Just B","Pythagorean C","19 TET","31 TET","Bohlen-Pierce C"), value(1),fontColour("white")

keyboard    bounds(130,420,1000, 75)

label       bounds(  5,497,120, 11), text("Iain McCurdy |2015|"), align("left"), fontColour("silver")

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

                   massign             0,3
gichans            init                0
giReady            init                0
gSfilepath         init                ""
giTriangle         ftgen               0, 0, 4097,  20, 3

; CURVE USED TO FORM ATTACK AND DECAY PORTIONS OF EACH GRAIN
;                                      NUM | INIT_TIME | SIZE | GEN_ROUTINE |  PARTIAL_NUMBER_1 | STRENGTH_1 | PHASE_1 | DC_OFFSET_1
giattdec           ftgen               0,        0,     524288,     19,             0.5,             0.5,        270,         0.5    ; I.E. A RISING SIGMOID

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
gipyth             ftgen               0,         0,       64,       -2,          12,          2,   cpsmidinn(60),      60,                       1,  256/243,   9/8,    32/27,    81/64,      4/3,    729/512,    3/2,    128/81,   27/16,     16/9,     243/128,  2     ;RATIOS FOR PYTHAGOREAN TUNING
gi19TET            ftgen               0,         0,       64,       -2,          19,          2,   cpsmidinn(60),      60,                       1,2^(1/19),2^(2/19),2^(3/19),2^(4/19),2^(5/19),2^(6/19),2^(7/19),2^(8/19),2^(9/19),2^(10/19),2^(11/19),2^(12/19),2^(13/19),2^(14/19),2^(15/19),2^(16/19),2^(17/19),2^(18/19),2^(19/19)
gi31TET            ftgen               0,         0,       64,       -2,          31,          2,   cpsmidinn(60),      60,                       1,2^(1/31),2^(2/31),2^(3/31),2^(4/31),2^(5/31),2^(6/31),2^(7/31),2^(8/31),2^(9/31),2^(10/31),2^(11/31),2^(12/31),2^(13/31),2^(14/31),2^(15/31),2^(16/31),2^(17/31),2^(18/31),2^(19/31),2^(20/31),2^(21/31),2^(22/31),2^(23/31),2^(24/31),2^(25/31),2^(26/31),2^(27/31),2^(28/31),2^(29/31),2^(30/31),2^(31/31)
giBP               ftgen               0,         0,       64,       -2,          13,          3,   cpsmidinn(60),      60,                       1,3^(1/13),3^(2/13),3^(3/13),3^(4/13),3^(5/13),3^(6/13),3^(7/13),3^(8/13),3^(9/13),3^(10/13),3^(11/13),3^(12/13),3^(13/13)



                   opcode              NextPowerOf2i, i, i
 iInval            xin            
 icount            =                   1
 LOOP:
 if 2^icount>iInval then
  goto DONE
 else
  icount           =                   icount + 1
  goto LOOP
 endif
 DONE:
                   xout                2^icount
endop


instr    1 ; always on
 kRampUp           linseg              0, 0.001, 1
 gkport            cabbageGetValue     "port"
 gkloop            cabbageGetValue     "loop"
 gkPlayStop        cabbageGetValue     "PlayStop"
 gkPhsMode         cabbageGetValue     "PhsMode"
 gkPhsMode         init                1
 gklevel           cabbageGetValue     "level"
 gklevel           port                gklevel,0.05
 gkpch             cabbageGetValue     "pch" 
 gkpch             portk               gkpch,kRampUp * 1 ;0.1
 gkspd             cabbageGetValue     "spd"
 gkfreeze          cabbageGetValue     "freeze"
 gkrange           cabbageGetValue     "range"
 gkshape           cabbageGetValue     "shape"
 gkTransMode,kT    cabbageGetValue     "TransMode"
 gkTransMode       init                1
 gkTransRate       cabbageGetValue     "TransRate"
                   cabbageSet          kT, "TransRate", "visible", gkTransMode-1
 gkOctDiv          cabbageGetValue     "OctDiv"
 gkband            cabbageGetValue     "band"
 gkris             cabbageGetValue     "ris"
 gkdec             cabbageGetValue     "dec"
 gkdur             cabbageGetValue     "dur"   
 gkfmd             cabbageGetValue     "fmd"
 gkpmd             cabbageGetValue     "pmd"
 gkDensRnd         cabbageGetValue     "DensRnd"
 gkAmpRnd          cabbageGetValue     "AmpRnd"
 gkDensLFODep      cabbageGetValue     "DensLFODep"
 gkAmpLFODep       cabbageGetValue     "AmpLFODep"
 gkLFORte          cabbageGetValue     "LFORte"
 gkLFOShape        cabbageGetValue     "LFOShape"
 gkDualOnOff       cabbageGetValue     "DualOnOff"
 gkDensRatio       cabbageGetValue     "DensRatio"
 gkPtrDiff         cabbageGetValue     "PtrDiff"
 gkTransDiff       cabbageGetValue     "TransDiff"
 gkYFilters        cabbageGetValue     "YFilters"
 gkYDensity        cabbageGetValue     "YDensity"
 
 gkPtrDiff         port                gkPtrDiff,0.1
 gkDelay           cabbageGetValue     "Delay"
 gkDelay           port                gkDelay,0.1
      
 if changed(gkPhsMode)==1 then
  if gkPhsMode==1 then
                   cabbageSet          k(1), "spd", "visible", 0
                   cabbageSet          k(1), "freeze", "visible", 0
                   cabbageSet          k(1), "range", "visible", 0
                   cabbageSet          k(1), "shape", "visible", 0
                   cabbageSet          k(1), "shapelabel", "visible", 0
                   cabbageSet          k(1), "port", "visible", 1
  elseif gkPhsMode==2 then
                   cabbageSet          k(1), "spd", "visible", 1
                   cabbageSet          k(1), "freeze", "visible", 1
                   cabbageSet          k(1), "range", "visible", 1
                   cabbageSet          k(1), "shape", "visible", 1
                   cabbageSet          k(1), "shapelabel", "visible", 1
                   cabbageSet          k(1), "port", "visible", 0
  endif
 endif

 ; load sound file from browse
 gSfilepath        cabbageGetValue     "filename"
 if changed(gSfilepath)==1 then                            ; if a new file has been loaded...
                   event               "i",99,0,0  ; call instrument to update sample storage function table 
 endif  

 ; load file from dropped file
 gSDropFile        cabbageGet          "LAST_FILE_DROPPED" ; file dropped onto GUI
 if (changed(gSDropFile) == 1) then
                   event               "i",100,0,0         ; load dropped file
 endif
                                                                     
 /* START/STOP SOUNDING INSTRUMENT */
 ktrig             trigger             gkPlayStop, 0.5, 0
                   schedkwhen          ktrig, 0, 0, 2, 0, -1

 /* MOUSE SCRUBBING */
 gkMOUSE_DOWN_RIGHT cabbageGetValue    "MOUSE_DOWN_RIGHT"    ; Read in mouse left click status
 kStartScrub       trigger             gkMOUSE_DOWN_RIGHT, 0.5, 0
 if gkMOUSE_DOWN_RIGHT==1 then
  if kStartScrub==1 then 
                   reinit              RAMP_FUNC
  endif
  RAMP_FUNC:
  krampup          linseg              0,0.001,1
  rireturn
  iFilerBounds[] cabbageGet "filer",   "bounds"
  kMOUSE_X         cabbageGetValue     "MOUSE_X"
  kMOUSE_X         portk               kMOUSE_X,gkport*kRampUp
  kMOUSE_Y         cabbageGetValue     "MOUSE_Y"
  kMOUSE_X         =                   (kMOUSE_X - iFilerBounds[0]) / iFilerBounds[2]
  kMOUSE_Y         portk               1 - ((kMOUSE_Y - iFilerBounds[1]) / iFilerBounds[3]), krampup * 0.05        ; SOME SMOOTHING OF DENSITY CHANGES IA THE MOUSE ENHANCES PERFORMANCE RESULTS. MAKE ANY ADJUSTMENTS WITH ADDITIONAL CONSIDERATION OF guiRefresh VALUE 
  
  ; filter parameters (right-click mouse click-and-drag Y axis over file panel)
  kLPF_CF          scale               (kMOUSE_Y * 2), 14, 4
  kLPF_CF          limit               kLPF_CF, 4, 14
  gkLPF_CF         portk               kLPF_CF, kRampUp * 0.05
  kHPF_CF          scale               (kMOUSE_Y * 2) - 1, 14, 4
  kHPF_CF          limit               kHPF_CF, 4, 14
  gkHPF_CF         portk               kHPF_CF, kRampUp * 0.05


  kLPF_CF          scale               cabbageGetValue:k("Y")*2,14,4
  kLPF_CF          limit               kLPF_CF, 4, 14
  kHPF_CF          scale               cabbageGetValue:k("Y")*2-1,14,4
  kHPF_CF          limit               kHPF_CF, 4, 14

  gkMousePhs       limit               kMOUSE_X, 0, 1
  if gkYDensity==1 then
   gkMouseDens     limit               ((kMOUSE_Y^3) * 502) - 2, 0, 500
  endif
                   schedkwhen          kStartScrub, 0, 0, 2, 0, -1
 else
  gkphs            cabbageGetValue     "phs"
  gkphs            portk               gkphs,gkport*kRampUp
  gkdens           cabbageGetValue     "dens"
 endif


; Record
kRecOut            cabbageGetValue     "RecOut"
if changed:k(kRecOut)==1 then
 if kRecOut==1 then
                   event               "i", 1000, 0, -1
 else
                   turnoff2            1000, 0, 1
 endif
endif


endin






instr    99    ; load sound file (browse)
 gichans           filenchnls          gSfilepath                     ; derive the number of channels (mono=1,stereo=2) in the sound file
 iFtlen            NextPowerOf2i       filelen:i(gSfilepath) * sr
 iFtlen            limit               iFtlen, 2, 2^24                ; limit table size otherwise transposition behaves strangely
 gitableL          ftgen               1,0,iFtlen,-1,gSfilepath,0,0,1
 if gichans==2 then
  gitableR         ftgen               2,0,iFtlen,-1,gSfilepath,0,0,2
 else
  gitableR         ftgen               2,0,iFtlen,-1,gSfilepath,0,0,1
 endif
 giReady           =                   1                              ; if no string has yet been loaded giReady will be zero
                   cabbageSet          "filer", "file", gSfilepath

 ; write file name to GUI
 SFileNoExtension cabbageGetFileNoExtension gSfilepath
                  cabbageSet     "stringbox","text",SFileNoExtension
endin

instr    100 ; LOAD DROPPED SOUND FILE
 gSfilepath        =                   gSDropFile
 gichans           filenchnls          gSfilepath                 ; derive the number of channels (mono=1,stereo=2) in the sound file
 iFtlen            NextPowerOf2i       filelen:i(gSfilepath) * sr
 iFtlen            limit               iFtlen, 2, 2^24                ; limit table size otherwise transposition behaves strangely
 gitableL          ftgen               1,0,iFtlen,-1,gSfilepath,0,0,1
 if gichans==2 then
  gitableR         ftgen               2,0,iFtlen,-1,gSfilepath,0,0,2
 else
  gitableR         ftgen               2,0,iFtlen,-1,gSfilepath,0,0,1
 endif
 giReady           =                   1                              ; if no string has yet been loaded giReady will be zero
                   cabbageSet          "filer", "file", gSfilepath

 ; write file name to GUI
 SFileNoExtension cabbageGetFileNoExtension gSfilepath
                  cabbageSet     "stringbox","text",SFileNoExtension
endin






instr    2    ; triggered by 'play/stop' button or right-click and drag
 if gkPlayStop==0 && gkMOUSE_DOWN_RIGHT==0 then
                   turnoff
 endif
 
 if giReady!=1 goto SKIP                        ; i.e. if a file has been loaded
 
 if i(gkMOUSE_DOWN_RIGHT)==1 then
  kdens            =                   gkMouseDens
  kphs             =                   gkMousePhs 
 else
  kdens            =                   gkdens
  kphs             =                   gkphs   
 endif
 
 
 kporttime         linseg              0, 0.001, 0.05         ; portamento time function. (Rises quickly from zero to a held value.)
  
 ; AMPLITUDE ENELOPE
 iAttTim           cabbageGetValue     "AttTim"               ; read in widgets
 iRelTim           cabbageGetValue     "RelTim"
 aenv              transegr            0, iAttTim+0.01, -4, 1, iRelTim+0.01, -4, 0 ; interpolate and create a-rate enelope

 ; conditional reinitialisation
 if changed:k(gkTransMode)==1 then                      ; IF I-RATE ARIABLE CHANGE TRIGGER IS '1'...
                   reinit              RESTART                ; BEGIN A REINITIALISATION PASS FROM LABEL 'RESTART'
 endif
 RESTART:

 ; pointer randomisation
 kPmdRndL          gauss               gkpmd * (ftsr(1) / ftlen(1))
 kPmdRndR          gauss               gkpmd * (ftsr(1) / ftlen(1))
  
  if gkPhsMode==1 || gkMOUSE_DOWN_RIGHT == 1 then             ; manual or mouse pointer mode
   kptrL           portk               kphs + kPmdRndL, kporttime ; PORTAMENTO IS APPLIED TO SMOOTH VALUE CHANGES VIA THE GUI SLIDERS
   kptrR           portk               kphs + kPmdRndR, kporttime
  else ; speed
   if gkshape==1 then     ; ramp pointer
    kptr           phasor              (gkspd * sr * (1-gkfreeze))/(nsamp(1) * gkrange)
   elseif gkshape==2 then ; triangle pointer
    kptr           oscili              1,(gkspd * sr * (1-gkfreeze))/(nsamp(1) * gkrange),giTriangle
   elseif gkshape==3 then ; sinusoidal pointer
    kptr           oscili              0.5,(gkspd * sr * (1-gkfreeze))/(nsamp(1) * gkrange)
    kptr           +=                  0.5
   endif   
   kptrL           =                   kptr + kphs + kPmdRndL  ; random pointer
   kptrR           =                   kptr + kphs + kPmdRndR
  endif
  kptrL            limit               kptrL, 0, 1
  kptrR            limit               kptrR, 0, 1
  kptrL            *=                  (filelen:i(gSfilepath) * ftsr(1) ) / ftlen(1)
  kptrR            *=                  (filelen:i(gSfilepath) * ftsr(1) ) / ftlen(1)
  aptrL            interp              kptrL
  aptrR            interp              kptrR
  
  ; fog constants
  iNumOverLaps     =                   2000
  itotdur          =                   3600

  ; LFO - density and amplitude
  if gkLFOShape==1 then ; sine
   kLFO            oscil               1, gkLFORte  
  elseif gkLFOShape==2 then ;random
   kLFO            jspline             1, gkLFORte*0.5, gkLFORte*2
  endif
  kdens            =                   kdens * octave(kLFO*gkDensLFODep)
  klevel           =                   (1 - (((gkAmpLFODep * 0.5 * kLFO) + (abs(gkAmpLFODep) * 0.5)) ^ 2))
  
  ; density randomisation
  kDensRndL        gauss               gkDensRnd
  kdensL           =                   kdens * octave(kDensRndL)
  kDensRndR        gauss               gkDensRnd
  kdensR           =                   kdens * octave(kDensRndR)

  ; pitch randomisation
  if i(gkTransMode) == 1 then ; grain-by-grain
   kPchRndL        gauss               gkfmd
   kPchRndR        gauss               gkfmd
  else ; continuous
   kPchRndL        rspline             gkfmd, -gkfmd, (10*gkTransRate)/gkdur, (20*gkTransRate)/gkdur
   kPchRndR        rspline             gkfmd, -gkfmd, (10*gkTransRate)/gkdur, (20*gkTransRate)/gkdur
  endif
  kpchL            =                   gkpch * octave(kPchRndL) * ftsr(1)/sr
  kpchR            =                   gkpch * octave(kPchRndR) * ftsr(1)/sr


  ; amplitude random modulation
  kAmpRndL         random              0, gkAmpRnd
  klevelL          =                   klevel - sqrt(kAmpRndL)
  kAmpRndR         random              0, gkAmpRnd
  klevelR          =                   klevel - sqrt(kAmpRndR)
  
  a1               fog                 klevelL, kdensL, kpchL, aptrL, gkOctDiv, gkband, gkris, gkdur, gkdec, iNumOverLaps, 1, giattdec, itotdur, 0, i(gkTransMode)-1, 1
  a2               fog                 klevelR, kdensR, kpchR, aptrR, gkOctDiv, gkband, gkris, gkdur, gkdec, iNumOverLaps, 2, giattdec, itotdur, 0, i(gkTransMode)-1, 1
  if gkDualOnOff==1 then
   a1b             fog                 klevelL, kdensL * gkDensRatio, kpchL * octave(gkTransDiff), aptrL+(gkPtrDiff*nsamp(1)/ftlen(1)), gkOctDiv, gkband, gkris, gkdur, gkdec, iNumOverLaps, 1, giattdec, itotdur, 0, i(gkTransMode)-1, 1
   a2b             fog                 klevelR, kdensR * gkDensRatio, kpchR * octave(gkTransDiff), aptrR+(gkPtrDiff*nsamp(1)/ftlen(1)), gkOctDiv, gkband, gkris, gkdur, gkdec, iNumOverLaps, 2, giattdec, itotdur, 0, i(gkTransMode)-1, 1
   if gkDelay>0 then
    a1b            vdelay              a1b, (gkDelay*1000)/gkdens, 1000
    a2b            vdelay              a2b, (gkDelay*1000)/gkdens, 1000
   endif
   a1              +=                  a1b
   a2              +=                  a2b
  endif

 ; LFO filter 
 kFiltLFODep       cabbageGetValue "FiltLFODep"
 if kFiltLFODep!=0 then ; only filter if depth is anything other than 1
  kFiltRes         cabbageGetValue "FiltRes"
  kCF              =                   sr * 0.33 * (2^(-abs(kFiltLFODep))) * 2^(kLFO*kFiltLFODep)
  a1               zdf_2pole           a1, kCF, 0.5 + (kFiltRes*24.5)
  a2               zdf_2pole           a2, kCF, 0.5 + (kFiltRes*24.5)
 endif
 
   ; right-click filter (mono)
   if i(gkMOUSE_DOWN_RIGHT)==1 && i(gkYFilters)==1 then
    a1             zdf_2pole           a1, a(cpsoct(gkLPF_CF)), 0.5
    a2             zdf_2pole           a2, a(cpsoct(gkLPF_CF)), 0.5
    a1             zdf_2pole           a1, a(cpsoct(gkHPF_CF)), 0.5, 1
    a2             zdf_2pole           a2, a(cpsoct(gkHPF_CF)), 0.5, 1
   endif

                   outs                a1 * aenv * gklevel, a2 * aenv * gklevel           ; send stereo signal to outputs
  rireturn


 ; indicator
 iBounds[]         cabbageGet          "filer", "bounds"
 
 ; show/hide indicator in manual mode
                   cabbageSet          changed:k(gkPhsMode),"indicator","visible",gkPhsMode == 1 ? 1 : 0

 if gkPlayStop==1 && gkPhsMode==1 then
                  cabbageSet           k(1), "indicator","bounds", iBounds[0] + (iBounds[2]*gkphs), iBounds[1], 1, iBounds[3]
 endif 

 SKIP:

endin












instr    3 ; MIDI triggered fog file player
 icps              cpstmid             giTTable1 + cabbageGetValue:i("Tuning") - 1
 iamp              ampmidi             1                        ; read in midi elocity (as a value within the range 0 - 1)
 kBend             pchbend             0, 12
 iAttTim           cabbageGetValue     "AttTim"                 ; read in widgets
 iRelTim           cabbageGetValue     "RelTim"
 iMidiRef          cabbageGetValue     "MidiRef"
 iFrqRatio         =                   icps/cpsmidinn(iMidiRef) ; derive playback speed from note played in relation to a reference note (MIDI note 60 / middle C)

 if giReady==1 then                                        ; i.e. if a file has been loaded
 ; AMPLITUDE ENELOPE
 iAttTim           cabbageGetValue     "AttTim"               ; read in widgets
 iRelTim           cabbageGetValue     "RelTim"
 aenv              transegr            0, iAttTim+0.01, 4, 1, iRelTim + 0.01, -4, 0 ; interpolate and create a-rate enelope

  kporttime        linseg              0, 0.001, 0.05           ; portamento time function. (Rises quickly from zero to a held value.)

  kBend            portk               kBend, kporttime

  ; conditional reinitialisation
  if changed:k(gkTransMode)==1 then                          ; IF I-RATE ARIABLE CHANGE TRIGGER IS '1'...
                   reinit              RESTART                ; BEGIN A REINITIALISATION PASS FROM LABEL 'RESTART'
  endif
  RESTART:

  
  ; pointer randomisation
  kPmdRndL         gauss               gkpmd * (ftsr(1) / ftlen(1))
  kPmdRndR         gauss               gkpmd * (ftsr(1) / ftlen(1))
  
  if gkPhsMode==1 || gkMOUSE_DOWN_RIGHT == 1 then             ; manual or mouse pointer mode
   kptrL           portk               gkphs + kPmdRndL, kporttime ; PORTAMENTO IS APPLIED TO SMOOTH VALUE CHANGES VIA THE GUI SLIDERS
   kptrR           portk               gkphs + kPmdRndR, kporttime
  else ; speed mode
   if gkshape==1 then ; ramp pointer
    kptr           phasor              (gkspd * sr * (1-gkfreeze))/(nsamp(1) * gkrange)
   elseif gkshape==2 then ; triangle pointer
    kptr           oscili              1,(gkspd * sr * (1-gkfreeze))/(nsamp(1) * gkrange), giTriangle
   elseif gkshape==3 then ; sinusoidal pointer
    kptr           oscili              0.5,(gkspd * sr * (1-gkfreeze))/(nsamp(1) * gkrange)
    kptr           +=                  0.5
   endif   
   kptr            =                   kptr * gkrange      ; rescale
   kptrL           =                   kptr + gkphs + kPmdRndL  ; random pointer
   kptrR           =                   kptr + gkphs + kPmdRndR
  endif
  kptrL            limit               kptrL, 0, 1
  kptrR            limit               kptrR, 0, 1
  kptrL            *=                  (filelen:i(gSfilepath) * ftsr(1) ) / ftlen(1)
  kptrR            *=                  (filelen:i(gSfilepath) * ftsr(1) ) / ftlen(1)
  aptrL            interp              kptrL
  aptrR            interp              kptrR
  
  ; fog constants
  iNumOverLaps     =                   2000
  itotdur          =                   3600
  
  ; LFO - density and amplitude
  if gkLFOShape==1 then ; sine
   kLFO            oscil               1, gkLFORte  
  elseif gkLFOShape==2 then ;random
   kLFO            jspline             1, gkLFORte*0.5, gkLFORte*2
  endif
  kdens            =                   gkdens * octave(kLFO*gkDensLFODep)
  klevel           =                   (1 - (((gkAmpLFODep * 0.5 * kLFO) + (abs(gkAmpLFODep) * 0.5)) ^ 2))
  
  ; density randomisation
  kDensRndL        gauss               gkDensRnd
  kdensL           =                   kdens * octave(kDensRndL)
  kDensRndR        gauss               gkDensRnd
  kdensR           =                   kdens * octave(kDensRndR)

  ; pitch randomisation
  if i(gkTransMode) == 1 then ; grain-by-grain
   kPchRndL        gauss               gkfmd
   kPchRndR        gauss               gkfmd
  else ; continuous
   kPchRndL        rspline             gkfmd, -gkfmd, (10*gkTransRate)/gkdur, (20*gkTransRate)/gkdur
   kPchRndR        rspline             gkfmd, -gkfmd, (10*gkTransRate)/gkdur, (20*gkTransRate)/gkdur
  endif
  kpchL            =                   iFrqRatio * octave(kPchRndL) * ftsr(1)/sr
  kpchR            =                   iFrqRatio * octave(kPchRndR) * ftsr(1)/sr
  
  ; amplitude random modulation
  kAmpRndL         random              0, gkAmpRnd
  klevelL          =                   klevel - sqrt(kAmpRndL)
  kAmpRndR         random              0, gkAmpRnd
  klevelR          =                   klevel - sqrt(kAmpRndR)
    
  a1               fog                 klevelL, kdensL, kpchL * semitone(kBend)*ftsr(1)/sr, aptrL, gkOctDiv, gkband, gkris, gkdur, gkdec, iNumOverLaps, 1, giattdec, itotdur, 0, i(gkTransMode)-1, 1
  a2               fog                 klevelR, kdensR, kpchR * semitone(kBend)*ftsr(1)/sr, aptrR, gkOctDiv, gkband, gkris, gkdur, gkdec, iNumOverLaps, 2, giattdec, itotdur, 0, i(gkTransMode)-1, 1
  if gkDualOnOff==1 then                                           
   a1b             fog                 klevelL, kdensL*gkDensRatio, kpchL*octave(gkTransDiff) * semitone(kBend)*ftsr(1)/sr, aptrL+(gkPtrDiff*nsamp(1)/ftlen(1)), gkOctDiv, gkband, gkris, gkdur, gkdec, iNumOverLaps, 1, giattdec, itotdur, 0, i(gkTransMode)-1, 1
   a2b             fog                 klevelR, kdensR*gkDensRatio, kpchR*octave(gkTransDiff) * semitone(kBend)*ftsr(1)/sr, aptrR+(gkPtrDiff*nsamp(1)/ftlen(1)), gkOctDiv, gkband, gkris, gkdur, gkdec, iNumOverLaps, 2, giattdec, itotdur, 0, i(gkTransMode)-1, 1
   if gkDelay>0 then
    a1b            vdelay              a1b,(gkDelay*1000)/gkdens,1000
    a2b            vdelay              a2b,(gkDelay*1000)/gkdens,1000
   endif
   a1              +=                  a1b
   a2              +=                  a2b
  endif
  
  ; LFO filter 
  kFiltLFODep      cabbageGetValue     "FiltLFODep"
  if kFiltLFODep!=0 then ; only filter if depth is anything other than 1
   kFiltRes        cabbageGetValue "FiltRes"
   kCF             =                   sr * 0.33 * (2^(-abs(kFiltLFODep))) * 2^(kLFO*kFiltLFODep)
   a1              zdf_2pole           a1, kCF, 0.5 + (kFiltRes*24.5)
   a2              zdf_2pole           a2, kCF, 0.5 + (kFiltRes*24.5)
  endif

                   outs                a1 * aenv * gklevel, a2 * aenv * gklevel     ; send stereo signal to outputs
                   rireturn

 endif

endin




; record
instr 1000
  a1, a2           monitor
  ilen             strlen              gSfilepath                     ; Derive string length.
  SOutputName      strsub              gSfilepath,0,ilen-4            ; Remove ".wav"
  SOutputName      strcat              SOutputName,"_Fog_"            ; Add suffix
  iDate            date
  SDate            sprintf             "%i",iDate
  SOutputName      strcat              SOutputName,SDate              ; Add date
  SOutputName      strcat              SOutputName,".wav"             ; Add extension
                   fout                SOutputName, 8, a1, a2

endin


</CsInstruments>  

<CsScore>
i 1 0 z
</CsScore>

</CsoundSynthesizer>