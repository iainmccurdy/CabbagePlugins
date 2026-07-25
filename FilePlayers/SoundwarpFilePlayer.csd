
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; SoundwarpFilePlayer.csd
; Written by Iain McCurdy, 2014, 2026

; Player can also be activated by using right-click and drag upon the waveform display panel.
;  In this mode, X position equates to pointer position and Y position equates to amplitude (level) and transposition.
;   (Transposition range when using mouse clicking-and-dragging is controlled using the 'Transposition' knob. Therefore if 'Transposition' = zero, no transposition occurs.)

; Open File                   -    browse for a sound file
; Play/Stop                   -    play/stop in non-MIDI mode
; Freeze                      -    freeze playback pointer (Speed mode)

; GRAINS
;  Overlaps                   -    number overlapping grains permitted (a density control). i-rate.
;  Size                       -    grain size in sample frames. i-rate. Expressed in sample frames.
;  Size OS                    -    random offset of window sizes (as a multiple of 'Size'), irate. Expressed in sample frames.
;  Transpose                  -    transposition of the contents of each grain (in semitones)
;  Mode                       -    pointer mode
;                                  1. Speed control - use of timestretching etc
;                                  2. Pointer - manual movement of the play position
;                                  3. Select a region (using the horizontal sliders) from within which grains will be randomly selected
;  Shape                      -    window/envelope applied to all grain
;                                  1. Hanning
;                                  2. Half Sine
;                                  3. Attack-Decay (Ctrl. 1 for x-location of breakpoint, ctrl. 2 for shape of segments)
;                                  4. Gate - sharp on-off envelope shape  (Ctrl. 1 for width of flat part of window, ctrl. 2 for shape of segments)
;                                  5. Impulse - a short impulse-like window 9 (Ctrl. 1 for width of impulse)
;  Pointer                    -    manual locating a static grain reading pointer (conditionallty available on 'mode' 2 or 3 selection)
;  Ptr.OS                     -    random offsetting of the manual grain pointer control
;  Port                       -    portamento control applied to movements made to Pointer and Transpose

; ENVELOPE
;  Att.Tim                    -    attack time of an amplitude envelope applied to activations of the granular synthesiser (either the GUI button or MIDI)
;  Rel.Tim                    -    release time of an amplitude envelope applied to activations of the granular synthesiser (either the GUI button or MIDI)

; OUTPUT
; LPF Res.                    -    resonance of the low-pass filter, 
;         the cutoff frequency of which can be controlled by y-axis movements of the mouse over the waveform viewer.
; HPF Res.                    -    resonance of the high-pass filter, 
;         the cutoff frequency of which can be controlled by y-axis movements of the mouse over the waveform viewer.
;  Level                      -    output amplitude control

; MIDI
;  MIDI Ref.                  -    reference note for unison (no transposition) when activated by MIDI notes
;  Detect                     -    automatically detect the pitch of the sample chosen and apply this value to MIDI Ref. to ensure that MIDI notes played sound the correct pitch.
;                                   a sample is taken 0.3 seconds into the sound file so it is assumed that the sample of a single notes with a noisy attack but reaching the sustain part by 0.3 seconds.
;  Stretch                    -    warps (compresses or expands) the MIDI-triggered synth's response to MIDI keys played, about the MIDI ref. point.
;                                   For accurate tuning according to TUNING chosen, this should be set to '1'.
;  Pch.Bend                   -    pitch bend range
; TUNING                      -     Tuning system used by the keyboard.

<Cabbage>
form caption("Soundwarp File Player") size(1290,485), colour( 30, 90, 60), pluginId("SWPl"), guiMode("queue")

soundfiler bounds(  5, 15,1280,200), channel("beg","len"), colour(0, 255, 255, 255), fontColour(160, 160, 160, 255)
image      bounds(  5, 15,1280,200), channel("RegionDisplay"), alpha(0.2)
label      bounds(  7, 20, 560, 14), text(""), align("left"), colour(0,0,0,0), fontColour(200,200,200), channel("stringbox")
hslider    bounds(  0,  0,1290, 20), channel("start"), range(0,1.00, 0,1,0.001), colour("white"), trackerColour(150,210,180), visible(1), markerColour("white")
hslider    bounds(  0,210,1290, 20), channel("ptr"), range(0,1.00, 0.5,1,0.001), colour("white"), trackerColour(150,210,180), visible(1), markerColour("white")
image      bounds(  5, 15,  1,200), channel("wiper")

image      bounds(  5,235,840,120), colour(0,0,0,0), outlineThickness(1), corners(5), outlineColour(200,200,200)
{
label      bounds(  0,  3,530, 11), text("G  R  A  I  N  S"), fontColour("white"), align("centre"), fontColour("GoldenRod")
filebutton bounds( 10, 10, 80, 22), text("Open File","Open File"), fontColour("white") channel("filename"), shape("ellipse")
checkbox   bounds( 10, 35, 95, 20), channel("PlayStop"), text("Play/Stop"), fontColour:0("white"), fontColour:1("white")
label      bounds( 10, 58,115, 10), text("[or right-click-and-drag]"), fontColour("white")
checkbox   bounds( 10, 73,100, 20), channel("freeze"), text("Freeze"), colour("LightBlue"), fontColour:0("white"), fontColour:1("white")

rslider    bounds(115, 17, 90, 90), channel("overlap"),     range( 1, 500, 100, 1,1),      colour( 50,110, 80), text("Overlaps"),     textColour("white"), trackerColour(150,210,180), valueTextBox(1), fontColour("white")
rslider    bounds(185, 17, 90, 90), channel("grsize"),      range( 1, 40000, 1600, 0.5,1), colour( 50,110, 80), text("Size"),         textColour("white"), trackerColour(150,210,180), valueTextBox(1), fontColour("white")
rslider    bounds(255, 17, 90, 90), channel("grsizeOS"),    range( 0, 5.00,   1,  0.5),    colour( 50,110, 80), text("Size OS"),      textColour("white"), trackerColour(150,210,180), valueTextBox(1), fontColour("white")
rslider    bounds(325, 17, 90, 90), channel("transpose"),   range(-48, 48, 0,1,0.001),     colour( 50,110, 80), text("Transpose"),    textColour("white"), trackerColour(150,210,180), valueTextBox(1), fontColour("white")

label      bounds(420,  8,100, 12), text("S h a p e"), fontColour("white"), align("centre")
combobox   bounds(420, 21,100, 22), channel("shape"), items("Hanning", "Half Sine", "Attack-Decay", "Gate", "Impulse"), value(1), fontColour("white")
gentable   bounds(420, 46,100, 32), tableNumber(1001), channel("WindowTab"), ampRange(0,1,1001), fill(0)
hslider    bounds(420, 80,100, 12), channel("WindParmX"), range(0,1,0.1), popupText(0), visible(0)
hslider    bounds(420, 96,100, 12), channel("WindParmY"), range(0,1,0.5), popupText(0), visible(0)

label      bounds(530,  8, 84, 12), text("Pointer Mode"), fontColour("white"), align("centre")
combobox   bounds(530, 21, 84, 25), channel("mode"), items("Speed", "Pointer", "Region"), value(1), fontColour("white")
checkbox   bounds(530, 70,110, 15), channel("Y2Filt"), text("Y Filters"), value(0), fontColour:0("white"), fontColour:1("white")
checkbox   bounds(530, 90,110, 15), channel("Y2Trans"), text("Y Transpose"), value(0), fontColour:0("white"), fontColour:1("white")

rslider    bounds(620, 17, 90, 90), channel("speed"),  range(0, 5.00, 1,0.5,0.001),               colour( 50,110, 80), text("Speed"),   textColour("white"), trackerColour(150,210,180), visible(1), valueTextBox(1), fontColour("white")
rslider    bounds(690, 17, 90, 90), channel("inskip"), range(     0, 1.00, 0),                    colour( 50,110, 80), text("Inskip"),  textColour("white"), trackerColour(150,210,180), visible(1), valueTextBox(1), fontColour("white")

rslider    bounds(620, 17, 90, 90), channel("ptrOS"),       range(0, 1.000, 0, 0.5, 0.001),       colour( 50,110, 80), text("Ptr.OS"),  textColour("white"), trackerColour(150,210,180), valueTextBox(1), fontColour("white")
rslider    bounds(760, 17, 90, 90), channel("port"),        range(0,1,0.01, 0.5,0.001),      colour( 50,110, 80), text("Port."),   textColour("white"), trackerColour(150,210,180), valueTextBox(1), fontColour("white")
}

image      bounds(850,235,160,120), colour(0,0,0,0), outlineThickness(1), corners(5), outlineColour(200,200,200)
{
label      bounds(  0,  3,160, 11), text("E   N   V   E   L   O   P   E"), fontColour("white"), align("centre"), fontColour("GoldenRod")
rslider    bounds(  0, 17, 90, 90), channel("AttTim"),    range(0, 5.00, 0.01, 0.5, 0.001),  colour( 50,110, 80), text("Att.Tim"), textColour("white"), trackerColour(150,210,180), valueTextBox(1), fontColour("white")
rslider    bounds( 70, 17, 90, 90), channel("RelTim"),    range(0.01, 5, 0.05, 0.5, 0.001),  colour( 50,110, 80), text("Rel.Tim"), textColour("white"), trackerColour(150,210,180), valueTextBox(1), fontColour("white")
}

image      bounds(1015,235,270,120), colour(0,0,0,0), outlineThickness(1), corners(5), outlineColour(200,200,200)
{
label      bounds(  0,  3,270, 11), text("O  U  T  P  U  T"), fontColour("white"), align("centre"), fontColour("GoldenRod")
rslider    bounds(  10, 17, 90, 90), channel("LPFRes"), range(  0.5,  25, 0.5, 0.5), colour( 50,110, 80), text("LPF Res."),     textColour("white"), trackerColour(150,210,180), valueTextBox(1), fontColour("white")
rslider    bounds(  90, 17, 90, 90), channel("HPFRes"), range(  0.5,  25, 0.5, 0.5), colour( 50,110, 80), text("HPF Res."),     textColour("white"), trackerColour(150,210,180), valueTextBox(1), fontColour("white")
rslider    bounds( 170, 17, 90, 90), channel("level"),   range(  0,  1.00, 0.4, 0.5), colour( 50,110, 80), text("Level"),     textColour("white"), trackerColour(150,210,180), valueTextBox(1), fontColour("white")
}

image      bounds(850,360,435,120), colour(0,0,0,0), outlineThickness(1), corners(5), outlineColour(200,200,200)
{
label      bounds(  0,  3,430, 11), text("M   I   D   I"), fontColour("white"), align("centre"), fontColour("GoldenRod")
rslider    bounds(  0, 17, 90, 90), channel("MidiRef"),   range(0,127,60, 1, 0.01),            colour( 50,110, 80), text("MIDI Ref."), textColour("white"), trackerColour(150,210,180), valueTextBox(1), fontColour("white")
button     bounds( 95, 50, 60, 25), channel("Detect"), text("Detect","Detect"), corners(5), colour:0(100,100,130), colour:1(100,100,130), latched(0)
rslider    bounds(160, 17, 90, 90), channel("Stretch"),   range( -2,   2, 1),      colour( 50,110, 80), text("Stretch"),     textColour("white"), trackerColour(150,210,180), valueTextBox(1), fontColour("white")
rslider    bounds(230, 17, 90, 90), channel("PchBnd"),    range(  0,  24, 2,1,.1),      colour( 50,110, 80), text("Pch.Bend"),     textColour("white"), trackerColour(150,210,180), valueTextBox(1), fontColour("white")
label      bounds(320, 34,110, 13), text("TUNING"), align("centre"), fontColour("white")
combobox   bounds(320, 49,110, 22), channel("Tuning"), text("12-TET", "24-TET", "12-TET rev.", "24-TET rev.", "10-TET", "36-TET", "Just C", "Just C#", "Just D", "Just D#", "Just E", "Just F", "Just F#", "Just G", "Just G#", "Just A", "Just A#", "Just B","Pythagorean C","19 TET","31 TET","Bohlen-Pierce C"), value(1)
}

image      bounds(  5,360,840,120), colour(0,0,0,0), outlineThickness(1), corners(5), outlineColour(200,200,200)
{
keyboard   bounds( 10, 15, 820, 90)
}

label    bounds(  15,466,120, 12), text("Iain McCurdy |2014|"), align("left"), fontColour("LightGrey")
</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-n -+rtmidi=NULL -M0 -dm0
</CsOptions>

<CsInstruments>

ksmps  = 64
nchnls = 2
0dbfs  = 1

                   massign             0,2
gichans            init                0
gisr               init                44100
giFileLen          init                0
giReady            init                0
gSfilepath         init                ""


; WINDOWING FUNCTIONS USED TO DYNAMICALLY SHAPE THE GRAINS
; NUM | INIT_TIME | SIZE | GEN_ROUTINE | PARTIAL_NUM | STRENGTH | PHASE
; GRAIN ENVELOPE WINDOW FUNCTION TABLES:
iTabSize           =                   131072
giwfn1             ftgen               101,  0, iTabSize,  20,   2, 1                                                      ; HANNING
giwfn2             ftgen               102,  0, iTabSize,  9,    0.5, 1, 0                                                 ; HALF SINE
giwfn3             ftgen               103,  0, iTabSize,  7,    0, iTabSize*0.03,   1, iTabSize*0.97,    0                ; ATTACK-DECAY
giwfn4             ftgen               104,  0, iTabSize,  7,    0, iTabSize*0.03,   1, iTabSize*0.94, 1, iTabSize*0.03, 0 ; GATE - WITH DE-CLICKING RAMP UP AND RAMP DOWN SEGMENTS
giImpulse          ftgen               105,  0, iTabSize, 20, 6, 1, 0.5                                                    ; IMPULSE

;giwfn              ftgen              1000,  0, iTabSize,  10, 0                     ; window function used

iDispTabSize       =                   4096
giDwfn1            ftgen               201,  0, iDispTabSize,  20,   2, 1                                                                  ; HANNING
giDwfn2            ftgen               202,  0, iDispTabSize,  9,    0.5, 1, 0                                                             ; HALF SINE
giDwfn3            ftgen               203,  0, iDispTabSize,  7,    0, iDispTabSize*0.03,   1, iDispTabSize*0.97,    0                    ; ATTACK-DECAY
giDwfn4            ftgen               204,  0, iDispTabSize,  7,    0, iDispTabSize*0.03,   1, iDispTabSize*0.92, 1, iDispTabSize*0.03, 0 ; GATE - WITH DE-CLICKING RAMP UP AND RAMP DOWN SEGMENTS
giDImpulse         ftgen               205,  0, iDispTabSize, 20, 6, 1, 0.5                                                                ; IMPULSE

giDispTab          ftgen               1001,  0, iDispTabSize,  20,   2, 1                     ; display table


; tuning tables for MIDI notes
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

instr    1
 kramp             linseg              0, 0.01, 0.005    
 gkloop            cabbageGetValue     "loop"
 gkPlayStop        cabbageGetValue     "PlayStop"
 gkfreeze          cabbageGetValue     "freeze"
 gkfreeze          =                   1 - gkfreeze
 gktranspose       cabbageGetValue     "transpose"
 gkoverlap         cabbageGetValue     "overlap"
 gkgrsize          cabbageGetValue     "grsize"
 gkgrsizeOS        cabbageGetValue     "grsizeOS"
 
 gkmode            cabbageGetValue     "mode"
 gkmode            init                1
 gkspeed           cabbageGetValue     "speed"
 gkptrOS           cabbageGetValue     "ptrOS"
 gkstart           cabbageGetValue     "start"
 gkporttime        cabbageGetValue     "port"
 gkinskip          cabbageGetValue     "inskip"
 gklevel           cabbageGetValue     "level"
 gkPchBndRng       cabbageGetValue     "PchBnd"
 gkSclWarp         cabbageGetValue     "SclWarp"
 gkSclWarp         portk               gkSclWarp, 0.05
 gkY2Filt          cabbageGetValue     "Y2Filt"

 ; SHOW OR HIDE WIDGETS -------------------------------------
 if changed:k(gkmode)==1 then
    if gkmode==1 then ; speed
                   cabbageSet          k(1), "speed","visible", 1
                   cabbageSet          k(1), "inskip","visible", 1
                   cabbageSet          k(1), "ptrOS","visible", 0
    endif
    if gkmode==2 then ; pointer
                   cabbageSet          k(1), "speed","visible", 0
                   cabbageSet          k(1), "inskip","visible", 0
                   cabbageSet          k(1), "ptrOS","visible", 1
    endif
    if gkmode==3 then ; region
                   cabbageSet          k(1), "speed","visible", 0
                   cabbageSet          k(1), "inskip","visible", 0
                   cabbageSet          k(1), "ptrOS","visible", 0
    endif
 endif
; -----------------------------------------------------------

 ; load sound file via OPEN FILE button
 gSfilepath        cabbageGetValue     "filename"
 kNewFileTrg       changed             gSfilepath    ; if a new file is loaded generate a trigger
 if kNewFileTrg==1 then                              ; if a new file has been loaded...
                   event               "i",99,0,0    ; call instrument to update sample storage function table 
 endif  

 ; load sound via drop
 gSDropFile        cabbageGet          "LAST_FILE_DROPPED" ; file dropped onto GUI
 if (changed(gSDropFile) == 1) then
                   event               "i",100,0,0         ; load dropped file
 endif

 ktrig             trigger             gkPlayStop,0.5,0
                   schedkwhen          ktrig,0,0,2,0,-1

 ; right-click mouse scrubbing
 kMOUSE_X           cabbageGetValue    "MOUSE_X"
 kMOUSE_Y           cabbageGetValue    "MOUSE_Y"
 gkMOUSE_DOWN_LEFT  cabbageGetValue    "MOUSE_DOWN_LEFT"
 gkMOUSE_DOWN_RIGHT cabbageGetValue    "MOUSE_DOWN_RIGHT"    ; Read in mouse left click status
 
 kStartScrub        trigger            gkMOUSE_DOWN_RIGHT, 0.5, 0
 if gkMOUSE_DOWN_RIGHT==1 then ; mouse scrubbing mode
  gkmode            =                  2
  if kStartScrub==1 then 
                   reinit              RAMP_FUNC
  endif
  RAMP_FUNC:
  krampup          linseg              0,0.001,1
  rireturn
  iBounds[]        cabbageGet          "beg", "bounds"
  kMOUSE_X         =                   (kMOUSE_X - iBounds[0]) / iBounds[2]            ; normalise position value over waveform (0 to 1)
  kMOUSE_Y         portk               1 - ((kMOUSE_Y - 5) / 175), krampup*0.05        ; SOME SMOOTHING OF DENSITY CHANGES VIA THE MOUSE ENHANCES PERFORMANCE RESULTS. MAKE ANY ADJUSTMENTS WITH ADDITIONAL CONSIDERATION OF guiRefresh VALUE 
  gkptr            limit               kMOUSE_X, 0, 1
                   cabbageSetValue     "ptr", gkptr
  gklevel          limit               kMOUSE_Y^2, 0, 1
  gktranspose      =                   ((kMOUSE_Y*2)-1)*gktranspose    ;, -gktranspose, gktranspose
                   schedkwhen          kStartScrub,0,0,2,0,-1
 else ; pointer mode
  gkptr            cabbageGetValue     "ptr"
  gklevel          cabbageGetValue     "level"
 endif 
; read soundfiler bounds
iBounds[]          cabbageGet          "beg", "bounds"
iOLX               =                   iBounds[0]
iOLY               =                   iBounds[1]
iOLWidth           =                   iBounds[2]
iOLHeight          =                   iBounds[3]

; Adjust graphical loop overlay when start/ptr hsliders are moved
if gkptr>gkstart then
 kOLX              limit               iOLX + (gkstart * iOLWidth), iOLX, iOLX + iOLWidth 
 kOLWid            limit               iOLWidth-(gkstart*iOLWidth)-((1-gkptr)*iOLWidth), 0, iOLX + iOLWidth - kOLX 
                   cabbageSet          changed:k(gkstart,gkptr), "RegionDisplay", "bounds", kOLX, iOLY, kOLWid, iOLHeight
else
 kOLX              limit               iOLX + (gkptr * iOLWidth), iOLX, iOLX + iOLWidth 
 kOLWid            limit               iOLWidth-(gkptr*iOLWidth)-((1-gkstart)*iOLWidth), 0, iOLX + iOLWidth - kOLX 
                   cabbageSet          changed:k(gkstart,gkptr), "RegionDisplay", "bounds", kOLX, iOLY, kOLWid, iOLHeight
endif

; move wiper in pointer mode
  if gkmode==2 then                                                         ; pointer mode
   kwiper          =                   iBounds[0] + (gkptr * iBounds[2])
   iBounds[]       cabbageGet          "beg", "bounds"
                   cabbageSet          changed:k(kwiper), "wiper", "bounds", kwiper, iBounds[1], 1, iBounds[3]
 endif

 ; mouse move region
 kMouseMoveFlag    init                0
 kMouseXPrev       init                i(kMOUSE_X)
 if trigger:k(gkMOUSE_DOWN_LEFT,0.5,0)==1 then
  kMouseMoveFlag   =                   (gkMOUSE_DOWN_LEFT==1 && kMOUSE_X>kOLX && kMOUSE_X<(kOLX+kOLWid) && kMOUSE_Y>iOLY  && kMOUSE_Y<(iOLY+iOLHeight)) ? 1 : 0
 elseif trigger:k(gkMOUSE_DOWN_LEFT,0.5,1)==1 then
  kMouseMoveFlag   =                   0
 endif
 if kMouseMoveFlag==1 && changed:k(kMOUSE_X - kMouseXPrev)==1 then
                   cabbageSetValue    "start", limit:k(gkstart + (kMOUSE_X-kMouseXPrev)/iOLWidth, 0, 1)
                   cabbageSetValue    "ptr",   limit:k(gkptr   + (kMOUSE_X-kMouseXPrev)/iOLWidth, 0, 1)
 endif
 kMouseXPrev       =                  kMOUSE_X
 
 
 ; mouse to transpose
 kYNorm            limit               1 - ((kMOUSE_Y-iBounds[1]) / iBounds[3]), 0, 1
 if gkMOUSE_DOWN_LEFT==1 && cabbageGetValue:k("Y2Trans")==1 then
                   cabbageSetValue     "transpose", scale:k(kYNorm,48,-48), changed:k(kYNorm)
 endif

 ; filter parameters from mouse Y position over file viewer
 kLPF_CF           scale               (kYNorm * 2), 14, 4
 kLPF_CF           limit               kLPF_CF, 4, 14
 gkLPF_CF          port                kLPF_CF, 0.05
 kHPF_CF           scale               (kYNorm * 2) - 1, 14, 4
 kHPF_CF           limit               kHPF_CF, 4, 14
 gkHPF_CF          port                kHPF_CF, 0.05
 
 gkptr             portk               gkptr, gkporttime

 ; detect pitch
 kDetect           cabbageGetValue     "Detect"
 if trigger:k(kDetect,0.5,0)==1 then
                   event               "i", 200, 0, 30
 endif
 
 ; rebuild display table for window function
 gkshape           cabbageGetValue     "shape"
 gkshape           init                1
 gkWindParmX       cabbageGetValue     "WindParmX"
 gkWindParmY       cabbageGetValue     "WindParmY"
 if metro:k(16)==1 then
  if changed:k(gkshape,gkWindParmX,gkWindParmY)==1 then
                   reinit              REBUILD_WFN_DISP
  endif
 endif
 REBUILD_WFN_DISP:
  if i(gkshape)==3 || i(gkshape)==4  || i(gkshape)==5 then
                   cabbageSet          "WindParmX", "visible", 1
  else
                   cabbageSet          "WindParmX", "visible", 0
  endif
  if i(gkshape)==3 || i(gkshape)==4 then
                   cabbageSet          "WindParmY", "visible", 1
  else
                   cabbageSet          "WindParmY", "visible", 0
  endif
  
 ; attack-decay
 i_                ftgen               giwfn3,   0, ftlen(giwfn3),  16,    0, ftlen(giwfn3)*((i(gkWindParmX)*0.94)+0.03), i(gkWindParmY)*16 - 8,   1, ftlen(giwfn3)*(((1-i(gkWindParmX))*0.94)+0.03),  (1-i(gkWindParmY))*16 - 8, 0  ; ATTACK-DECAY
 i_                ftgen               giDwfn3,  0, ftlen(giDwfn3), 16,    0, ftlen(giDwfn3)*((i(gkWindParmX)*0.9)+0.03), i(gkWindParmY)*16 - 8,   1, ftlen(giDwfn3)*(((1-i(gkWindParmX))*0.94)+0.03), (1-i(gkWindParmY))*16 - 8, 0  ; ATTACK-DECAY
 ; gate
 i_                ftgen               giwfn4,   0, ftlen(giwfn4),  16,    0, ftlen(giwfn4)*(i(gkWindParmX)*0.45 + 0.05),   i(gkWindParmY)*32 - 16,   1, ftlen(giwfn4)*(0.9-(i(gkWindParmX)*0.9)),0, 1, ftlen(giwfn4)*(i(gkWindParmX)*0.45 + 0.05),    (1-i(gkWindParmY))*32 - 16, 0 ; GATE - WITH DE-CLICKING RAMP UP AND RAMP DOWN SEGMENTS
 i_                ftgen               giDwfn4,  0, ftlen(giDwfn4),  16,   0, ftlen(giDwfn4)*(i(gkWindParmX)*0.44 + 0.045), i(gkWindParmY)*32 - 16,   1, ftlen(giDwfn4)*(0.9-(i(gkWindParmX)*0.9)),0, 1, ftlen(giDwfn4)*(i(gkWindParmX)*0.44 + 0.045), (1-i(gkWindParmY))*32 - 16, 0 ; GATE - WITH DE-CLICKING RAMP UP AND RAMP DOWN SEGMENTS
 ; impulse
 i_                ftgen               giImpulse, 0, ftlen(giImpulse), 20, 6, 1, 0.1 + i(gkWindParmX)^2 * 2
 i_                ftgen               giDImpulse, 0, ftlen(giDImpulse), 20, 6, 1, 0.1 + i(gkWindParmX)^2 * 2
 
 ; update GUI display
 iDwfn             =                   i(gkshape) + giDwfn1 - 1 ; display table chosen
                   tableicopy          giDispTab, iDwfn                       ; copy to fixed table number display table used by widget
                   cabbageSet          "WindowTab", "tableNumber", giDispTab  ; update GUI widget
 rireturn
 
endin



instr    99    ; load sound file
 gichans           filenchnls          gSfilepath                ; derive the number of channels (mono=1,stereo=2) in the sound file
 giFileLen         filelen             gSfilepath
 gisr              filesr              gSfilepath
 gitableL          ftgen               1,0,0,1,gSfilepath,0,0,1
 if gichans==2     then
  gitableR         ftgen               2,0,0,1,gSfilepath,0,0,2
 endif
 giReady           =                   1                         ; if no string has yet been loaded giReady will be zero

                   cabbageSet          "beg", "file", gSfilepath

 ; write file name to GUI
 SFileNoExtension  cabbageGetFileNoExtension gSfilepath
                   cabbageSet          "stringbox","text",SFileNoExtension

endin


instr    100 ; LOAD DROPPED SOUND FILE
 gichans          filenchnls       gSDropFile                    ; derive the number of channels (mono=1,stereo=2) in the sound file
 giFileLen        filelen          gSDropFile                    ; derive the file duration in seconds
 gisr             filesr           gSDropFile
 gitableL         ftgen            1,0,0,1,gSDropFile,0,0,1
 gkTabLen         init             ftlen(gitableL)               ; table length in sample frames
 if gichans==2 then
  gitableR        ftgen            2,0,0,1,gSDropFile,0,0,2
 endif
 gkReady          init             1                             ; if no string has yet been loaded gkReady will be zero
                  cabbageSet       "beg", "file", gSDropFile

 ; write file name to GUI
 SFileNoExtension cabbageGetFileNoExtension gSDropFile
                  cabbageSet       "stringbox","text",SFileNoExtension
endin









givel              ftgen               0, 0, 1024, 16, 0, 1024, 4, 1

instr    2
 kRamp             linseg              0, 0.001, 1                      ; portamento time function. (Rises quickly from zero to a held value.)
 kporttime         =                   kRamp * gkporttime
 ktranspose        portk               gktranspose, kporttime           ; smooth changes to transposition changes

 ; MIDI interoperability
 idefault          =                   1
 iMIDI             =                   0                  
                   mididefault         idefault, iMIDI ; ivalue overwritten by idefault if MIDI driven
 if iMIDI==1 then ; MIDI
  icps             cpstmid             giTTable1 + cabbageGetValue:i("Tuning") - 1
  iamp             ampmidi             1                        ; read in midi velocity (as a value within the range 0 - 1)
  kPchBnd          pchbend             0, 1                     ; read in pitch bend
  kPchBnd          *=                  gkPchBndRng
  iMidiRef         cabbageGetValue     "MidiRef"
  
  iMidiNote        =                   ftom:i(icps)
  kStretch         cabbageGetValue     "Stretch"
  kStretch         portk               kStretch, kporttime
  kMidiNote        =                   ((iMidiNote-iMidiRef) * kStretch) + iMidiRef
  kFrqRatio        =                   cpsmidinn(kMidiNote) / cpsmidinn(iMidiRef)
  apch             interp              kFrqRatio * semitone:k(kPchBnd)
  iamp             ampmidi             1, givel
 else              ; non-MIDI
  if gkPlayStop==0&&gkMOUSE_DOWN_RIGHT==0 then
                   turnoff
  endif
  apch             interp              semitone(ktranspose)
  kspeed           portk               gkspeed,kporttime              ; apply portamento smoothing to changes in speed
  iamp             =                   1 
 endif 
 
 if giReady==1 then                                                   ; if a file has been loaded...
  iAttTim          cabbageGetValue     "AttTim"                       ; read in widgets
  iRelTim          cabbageGetValue     "RelTim"
  if iAttTim>0 then                                                   ; is amplitude envelope attack time is greater than zero...
   kenv            linsegr             0,iAttTim,1,iRelTim,0          ; create an amplitude envelope with an attack, a sustain and a release segment (senses realtime release)
  else            
   kenv            linsegr             1,iRelTim,0                    ; create an amplitude envelope with a sustain and a release segment (senses realtime release)
  endif
  kenv             expcurve            kenv,8                         ; remap amplitude value with a more natural curve
  aenv             interp              kenv                           ; interpolate and create a-rate envelope

  kspeed           portk               gkspeed*ftsr(gitableL)/sr, kporttime
  kptr             portk               gkptr*ftsr(gitableL)/sr, kporttime ; rescale pointer location if there is a mismatch between sample rate of file and Cabbage sample rate 
  
  ktrig            changed             gkshape, gkoverlap, gkgrsize, gkgrsizeOS, gkmode, gkinskip
  if ktrig==1 then
                   reinit              UPDATE
  endif
  UPDATE:
  
  iwfn             =                   i(gkshape) + giwfn1 - 1
  imode            =                   i(gkmode) - 1

  ; calculate pointer position according to mode
  if imode==0 then                                                 ; timestretch (speed) mode
   iPMode          =                   0
   kwarpL          =                   1 / (kspeed * gkfreeze)
   kwarpR          =                   kwarpL
   ibeg            =                   i(gkinskip) * giFileLen
  elseif imode==1 then                                             ; pointer mode
   iPMode          =                   1
   kwarp           =                   giFileLen * kptr ; scale pointer according to file length (in seconds)
   ibeg            =                   0   
   kptrOS_L        gauss               (giFileLen - kwarp) * gkptrOS   
   kwarpL          =                   kwarp + kptrOS_L
   kptrOS_R        gauss               (giFileLen - kwarp) * gkptrOS   
   kwarpR          =                   kwarp + kptrOS_R
   kwarpL          limit               kwarpL, 0, giFileLen
   kwarpR          limit               kwarpR, 0, giFileLen
  elseif imode==2 then                                             ; region mode                                                             ; region mode
   iPMode          =                   1                               ; sndwarp mode used in region mode will be pointer mode
   kwarpL          random              gkstart * ftlen(gitableL)/sr, gkptr * ftlen(gitableL)/sr
   kwarpR          random              gkstart * ftlen(gitableL)/sr, gkptr * ftlen(gitableL)/sr
   ibeg            =                   0
  endif


  ; wiper options
  if imode==1 then                                                         ; pointer mode
   kwiper          =                   (kwarpL + kptrOS_L) * sr
   iBounds[]       cabbageGet          "beg", "bounds"
                   cabbageSet          changed:k(kwiper), "wiper", "bounds", iBounds[0] + iBounds[2]*kwiper/(ftlen(gitableL)), iBounds[1], 1, iBounds[3]
  elseif imode==2 && iMIDI==0 then                                             ; region mode                                                             ; region mode
   kwiper          =                   kwarpL * sr
   iBounds[]       cabbageGet          "beg", "bounds"
                   cabbageSet          changed:k(kwiper), "wiper", "bounds", iBounds[0] + iBounds[2]*kwiper/(ftlen(gitableL)), iBounds[1], 1, iBounds[3]
  endif  

  klevel           portk               gklevel/(i(gkoverlap)^0.25), kporttime    ; apply portamento smoothing to changes in level
  
  ;; note that:
  ;; 1. grain size offset is expressed as a factor of the grain size
  ;; 2. grain size offsets are *only* added, therefore compensation is made to the grain size so that the average grain size remains the same, regardless of the setting for grain size offset
  
  if gichans==1 then                                                         ; if mono...   
   a1              sndwarp             iamp, kwarpL, apch*gisr/sr, gitableL, ibeg, i(gkgrsize) - (i(gkgrsize) * i(gkgrsizeOS) * 0.5), i(gkgrsize) * i(gkgrsizeOS), i(gkoverlap), iwfn, iPMode
   a2              sndwarp             iamp, kwarpR, apch*gisr/sr, gitableL, ibeg, i(gkgrsize) - (i(gkgrsize) * i(gkgrsizeOS) * 0.5), i(gkgrsize) * i(gkgrsizeOS), i(gkoverlap), iwfn, iPMode
  elseif gichans==2 then                                                     ; otherwise, if stereo...
   a1              sndwarp             iamp, kwarpL, apch*gisr/sr, gitableL, ibeg, i(gkgrsize) - (i(gkgrsize) * i(gkgrsizeOS) * 0.5), i(gkgrsize) * i(gkgrsizeOS), i(gkoverlap), iwfn, iPMode
   a2              sndwarp             iamp, kwarpR, apch*gisr/sr, gitableR, ibeg, i(gkgrsize) - (i(gkgrsize) * i(gkgrsizeOS) * 0.5), i(gkgrsize) * i(gkgrsizeOS), i(gkoverlap), iwfn, iPMode
  endif
               rireturn  
  ; Y Filters
  if gkY2Filt==1 then
   kLPFRes         cabbageGetValue     "LPFRes"
   kHPFRes         cabbageGetValue     "HPFRes"
   a1              zdf_2pole           a1, a(cpsoct(gkLPF_CF)), kLPFRes    ; lowpass
   a2              zdf_2pole           a2, a(cpsoct(gkLPF_CF)), kLPFRes
   a1              zdf_2pole           a1, a(cpsoct(gkHPF_CF)), kHPFRes, 1 ; highpass
   a2              zdf_2pole           a2, a(cpsoct(gkHPF_CF)), kHPFRes, 1
   /*
   a1              butlp               a1, cpsoct(gkLPF_CF)    ; lowpass
   a2              butlp               a2, cpsoct(gkLPF_CF)
   a1              buthp               a1, cpsoct(gkHPF_CF)    ; highpass
   a2              buthp               a2, cpsoct(gkHPF_CF)
   */
  endif

                   outs                a1 * aenv * a(klevel), a2 * aenv * a(klevel)  ; send stereo signal to outputs
 endif


endin






 instr 200 ; detect pitch of sample and send to MIDI reference
  gitable          ftgen               1, 0, 0, 1, gSfilepath, 0, 0, 0  ; load sound file into a GEN 01 function table 
  gichans          filenchnls          gSfilepath                       ; derive the number of channels (mono=1,stereo=2) in the sound file
  giReady          =                   1                                ; if no string has yet been loaded giReady will be zero
  gkTabLen         init                ftlen(gitable)/gichans           ; table length in sample frames
                   cabbageSet          "beg", "file", gSfilepath
  if gichans==1 then
   aL              diskin2             gSfilepath, 1
  elseif  gichans==2 then
   aL,aR           diskin2             gSfilepath, 1
  endif  
  kcps, krms       pitchamdf           aL, 20, 5000
  if timeinsts:k() >= 0.3 then
   kNote           =                   ftom:k(kcps)
                   cabbageSetValue     "MidiRef", kNote
                   turnoff
  endif
 endin




</CsInstruments>  

<CsScore>
i 1 0 z
</CsScore>

</CsoundSynthesizer>
