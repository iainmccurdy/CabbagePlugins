; DMS Decoder 
; Iain McCurdy 2023

; This plug-in decodes a DMS (double-mid-side) signal for an arbitrary number of speakers at user-defined angles from the central listening point.
; A recorded DMS source will utilise a front-facing cardioid, a coincident figure-of-8 pointing left and right and a rear facing coincident cardioid.
; The plugin expects those three signal in that order.   
; It can be seen that the first two channels are equivalent to an MS (mid-side) signal so DMS is simply a elaboration of that technique.
; MS and DMS also bear similarities to ambisonics so DMS can be thought of as a 360 degree, 2D-version of ambisonics.
; The advantages of DMS over ambisonics are that it only needs 3 channels in the source, 
;  width can be controlled easily by adjusting the level of the 'side' signal, it is easier to set up, a variety of microphones can be used 
;  and those microphones are more likely to be on axis to the source.
; 
; AZIMUTH
; The 8 dials set the azimuth angles of the 8 possible outputs
; Rotate shifts all output azimuths simultaneously thereby opening up the possibility of rotating the output image
; Preset provides the option of setting the 8 Azimuth controls to common preset arrangements.

; LEVEL
; The 8 dials sets the output levels of the 8 output signals. Normally these should be set to the same level unless there is uneveness in the speaker array.
; Additionally MUTE and SOLO buttons are provided which might be useful in testing and troubleshooting.
; Master - control the output level of all output signals

; The output matrix array of buttons allows selecting how output signals are routed to hardware outputs (speakers).

; The SOURCE MIXER provides control of the levels of the three input signals (in dBFS). 
; This is useful if the sensitivities of the three microphones used are different. 
; At least the figure-of-8 microphone is likely to have a different sensitivity to the two cardioids 
;  - and it is advised to refer to the microphones' documentation to make an appropriate adjustment.

; The locations of the speakers are illustrated in the circular scope and the horizontal scope at the top. 
; The red green and blue graphsover laid on the horizontal scope shows the scaling that is apllied to each input signal to derive the signal 
;  with respect azimuth.

; LFE (subwoofer) signal is outputted on hardware channel 9. This is an omnidirectional signal derived from the three inputs.

/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

<Cabbage>
#define COLOUR1 "Magenta"
#define COLOUR2 "SkyBlue"
#define COLOUR3 "Tomato"
#define COLOUR4 "DarkCyan"
#define COLOUR5 "DarkOrange"
#define COLOUR6 "DarkSalmon"
#define COLOUR7 "GoldenRod"
#define COLOUR8 "LawnGreen"
#define COLOUR9 "Yellow"
#define COLOUR_BG "30,30,30"

form caption("DMS Decoder") size(900, 780), colour($COLOUR_BG), pluginId("DMSD") guiMode("queue")
image bounds(  0, 0,900,230) colour(0,0,0,0) outlineThickness(1)
{
image    bounds( 29, 9,802,202) colour(40,40,40,0) outlineThickness(1) ; outline
gentable bounds( 30, 10,800,200) channel("DisplayTable") tableNumber(1,2,3), fill(0),  tableGridColour(0, 0, 0, 0) tableColour:0("red") tableColour:1("green") tableColour:2("blue")  outlineThickness(1)
image    bounds( 30,110,800,  1) colour(80,80,80,100) ; x-axis
image    bounds(430, 10,  1,200) colour(80,80,80,100) ; y halfway
image    bounds(230, 10,  1,200) colour(80,80,80,100) ; y quarter
image    bounds(630, 10,  1,200) colour(80,80,80,100) ; y 3/4
label    bounds(  5,  2, 20, 15) align("right") text("1")
label    bounds(  5,102, 20, 15) align("right") text("0")
label    bounds(  5,200, 20, 15) align("right") text("-1")
label    bounds(212,211, 30, 15) align("centre") text("-90")
label    bounds(416,211, 30, 15) align("centre") text("  0")
label    bounds(617,211, 30, 15) align("centre") text(" 90")
label    bounds(815,211, 30, 15) align("centre") text("180")
image    bounds(0, 0,  0,0) channel("indic1") colour($COLOUR1)
image    bounds(0, 0,  0,0) channel("indic2") colour($COLOUR2)
image    bounds(0, 0,  0,0) channel("indic3") colour($COLOUR3)
image    bounds(0, 0,  0,0) channel("indic4") colour($COLOUR4)
image    bounds(0, 0,  0,0) channel("indic5") colour($COLOUR5)
image    bounds(0, 0,  0,0) channel("indic6") colour($COLOUR6)
image    bounds(0, 0,  0,0) channel("indic7") colour($COLOUR7)
image    bounds(0, 0,  0,0) channel("indic8") colour($COLOUR8)
checkbox bounds(838, 10,55,12) colour("red") shape("ellipse") text("FRONT") value(1) channel("Front"), active(0)
checkbox bounds(838, 30,55,12) colour("green") shape("ellipse") text("SIDES") value(1) channel("Sides"), active(0)
checkbox bounds(838, 50,55,12) colour("blue") shape("ellipse") text("REAR") value(1) channel("Rear"), active(0)
}

; AZIMUTHS
image bounds(0,230,900,160) colour(40,40,40,0) outlineThickness(1)
{
label   bounds(  0,  5,900, 15) align("centre") text("A  Z  I  M  U  T  H")
rslider bounds(-10, 15,130,135) channel("Az1") popupText("0") value(-25) valueTextBox(1), text("1") range(-360,360,-25,1,0.1) trackerOutsideRadius(0.3) trackerColour(0,0,0,0) markerColour($COLOUR1)
rslider bounds( 75, 15,130,135) channel("Az2") popupText("0") value(-25) valueTextBox(1), text("2") range(-360,360, 25,1,0.1) trackerOutsideRadius(0.3) trackerColour(0,0,0,0) markerColour($COLOUR2)
rslider bounds(160, 15,130,135) channel("Az3") popupText("0") value(-25) valueTextBox(1), text("3") range(-360,360,-50,1,0.1) trackerOutsideRadius(0.3) trackerColour(0,0,0,0) markerColour($COLOUR3)
rslider bounds(245, 15,130,135) channel("Az4") popupText("0") value(-25) valueTextBox(1), text("4") range(-360,360, 50,1,0.1) trackerOutsideRadius(0.3) trackerColour(0,0,0,0) markerColour($COLOUR4)
rslider bounds(330, 15,130,135) channel("Az5") popupText("0") value(-25) valueTextBox(1), text("5") range(-360,360,-90,1,0.1) trackerOutsideRadius(0.3) trackerColour(0,0,0,0) markerColour($COLOUR5)
rslider bounds(415, 15,130,135) channel("Az6") popupText("0") value(-25) valueTextBox(1), text("6") range(-360,360, 90,1,0.1) trackerOutsideRadius(0.3) trackerColour(0,0,0,0) markerColour($COLOUR6)
rslider bounds(500, 15,130,135) channel("Az7") popupText("0") value(-25) valueTextBox(1), text("7") range(-360,360,-140,1,0.1) trackerOutsideRadius(0.3) trackerColour(0,0,0,0) markerColour($COLOUR7)
rslider bounds(585, 15,130,135) channel("Az8") popupText("0") value(-25) valueTextBox(1), text("8") range(-360,360,140,1,0.1) trackerOutsideRadius(0.3) trackerColour(0,0,0,0) markerColour($COLOUR8)
;encoder bounds(-10, 20,130,110) channel("Az1") repeatInterval(360) popupText("0") value(-25) increment(0.5), text("1") valueTextBox(1) trackerColour($COLOUR1) colour(220, 220, 220)
;encoder bounds( 75, 20,130,110) channel("Az2") repeatInterval(360) popupText("0") value(25) increment(0.5), text("2") valueTextBox(1) trackerColour($COLOUR2) colour(220, 220, 220)
;encoder bounds(160, 20,130,110) channel("Az3") repeatInterval(360) popupText("0") value(-50) increment(0.5), text("3") valueTextBox(1) trackerColour($COLOUR3) colour(220, 220, 220)
;encoder bounds(245, 20,130,110) channel("Az4") repeatInterval(360) popupText("0") value(50) increment(0.5), text("4") valueTextBox(1) trackerColour($COLOUR4) colour(220, 220, 220)
;encoder bounds(330, 20,130,110) channel("Az5") repeatInterval(360) popupText("0") value(-90) increment(0.5), text("5") valueTextBox(1) trackerColour($COLOUR5) colour(220, 220, 220)
;encoder bounds(415, 20,130,110) channel("Az6") repeatInterval(360) popupText("0") value(90) increment(0.5), text("6") valueTextBox(1) trackerColour($COLOUR6) colour(220, 220, 220)
;encoder bounds(500, 20,130,110) channel("Az7") repeatInterval(360) popupText("0") value(-140) increment(0.5), text("7") valueTextBox(1) trackerColour($COLOUR7) colour(220, 220, 220)
;encoder bounds(585, 20,130,110) channel("Az8") repeatInterval(360) popupText("0") value(140) increment(0.5), text("8") valueTextBox(1) trackerColour($COLOUR8) colour(220, 220, 220)
encoder bounds(680, 20,130,130) channel("Rotate") repeatInterval(360) popupText("0") value(0) increment(1), text("ROTATE") valueTextBox(1) trackerColour(100,100,100) colour(220, 220, 220) range(-360,360)
label    bounds(800, 43, 80, 15) text("PRESET")
combobox bounds(800, 60, 80, 22), channel("Preset"), value(1), items("Acousm.","Ring 1", "Ring 2")
}

image bounds(0,390,900,190) colour(40,40,40,0) outlineThickness(1)
{
label   bounds(  0,  5,900, 15) align("centre") text("L  E  V  E  L")
rslider bounds(-10, 15,130,120) channel("Gain1") popupText("0") value(0) valueTextBox(1), text("1") range(-60,0,0) trackerOutsideRadius(0.3) trackerColour(0,0,0,0) markerColour($COLOUR1)
rslider bounds( 75, 15,130,120) channel("Gain2") popupText("0") value(0) valueTextBox(1), text("2"), range(-60,0,0) trackerOutsideRadius(0.3) trackerColour(0,0,0,0) markerColour($COLOUR2)
rslider bounds(160, 15,130,120) channel("Gain3") popupText("0") value(0) valueTextBox(1), text("3"), range(-60,0,0) trackerOutsideRadius(0.3) trackerColour(0,0,0,0) markerColour($COLOUR3)
rslider bounds(245, 15,130,120) channel("Gain4") popupText("0") value(0) valueTextBox(1), text("4"), range(-60,0,0) trackerOutsideRadius(0.3) trackerColour(0,0,0,0) markerColour($COLOUR4)
rslider bounds(330, 15,130,120) channel("Gain5") popupText("0") value(0) valueTextBox(1), text("5"), range(-60,0,0) trackerOutsideRadius(0.3) trackerColour(0,0,0,0) markerColour($COLOUR5)
rslider bounds(415, 15,130,120) channel("Gain6") popupText("0") value(0) valueTextBox(1), text("6"), range(-60,0,0) trackerOutsideRadius(0.3) trackerColour(0,0,0,0) markerColour($COLOUR6)
rslider bounds(500, 15,130,120) channel("Gain7") popupText("0") value(0) valueTextBox(1), text("7"), range(-60,0,0) trackerOutsideRadius(0.3) trackerColour(0,0,0,0) markerColour($COLOUR7)
rslider bounds(585, 15,130,120) channel("Gain8") popupText("0") value(0) valueTextBox(1), text("8"), range(-60,0,0) trackerOutsideRadius(0.3) trackerColour(0,0,0,0) markerColour($COLOUR8)
rslider bounds(720,  5,130,170) channel("Master") popupText("0") value(0) valueTextBox(1), text("MASTER"), range(-60,0,0) trackerOutsideRadius(0.3) trackerColour(0,0,0,0)

button  bounds( 25,140, 60, 18) channel("Mute1") value(0) text("MUTE","MUTE") colour:0(20,0,0) colour:1(255,100,100)
button  bounds(110,140, 60, 18) channel("Mute2") value(0) text("MUTE","MUTE") colour:0(20,0,0) colour:1(255,100,100)
button  bounds(195,140, 60, 18) channel("Mute3") value(0) text("MUTE","MUTE") colour:0(20,0,0) colour:1(255,100,100)
button  bounds(280,140, 60, 18) channel("Mute4") value(0) text("MUTE","MUTE") colour:0(20,0,0) colour:1(255,100,100)
button  bounds(365,140, 60, 18) channel("Mute5") value(0) text("MUTE","MUTE") colour:0(20,0,0) colour:1(255,100,100)
button  bounds(450,140, 60, 18) channel("Mute6") value(0) text("MUTE","MUTE") colour:0(20,0,0) colour:1(255,100,100)
button  bounds(535,140, 60, 18) channel("Mute7") value(0) text("MUTE","MUTE") colour:0(20,0,0) colour:1(255,100,100)
button  bounds(620,140, 60, 18) channel("Mute8") value(0) text("MUTE","MUTE") colour:0(20,0,0) colour:1(255,100,100)

button  bounds( 25,160, 60, 18) channel("Solo1") value(0) text("SOLO","SOLO") colour:0(20,20,0) colour:1(200,200,0)
button  bounds(110,160, 60, 18) channel("Solo2") value(0) text("SOLO","SOLO") colour:0(20,20,0) colour:1(200,200,0)
button  bounds(195,160, 60, 18) channel("Solo3") value(0) text("SOLO","SOLO") colour:0(20,20,0) colour:1(200,200,0)
button  bounds(280,160, 60, 18) channel("Solo4") value(0) text("SOLO","SOLO") colour:0(20,20,0) colour:1(200,200,0)
button  bounds(365,160, 60, 18) channel("Solo5") value(0) text("SOLO","SOLO") colour:0(20,20,0) colour:1(200,200,0)
button  bounds(450,160, 60, 18) channel("Solo6") value(0) text("SOLO","SOLO") colour:0(20,20,0) colour:1(200,200,0)
button  bounds(535,160, 60, 18) channel("Solo7") value(0) text("SOLO","SOLO") colour:0(20,20,0) colour:1(200,200,0)
button  bounds(620,160, 60, 18) channel("Solo8") value(0) text("SOLO","SOLO") colour:0(20,20,0) colour:1(200,200,0)
}

image bounds(  0,580,200,200) colour(30,30,30) outlineThickness(1)
{
label    bounds( 90,  5, 60, 13) text("OUTPUT 1") align("right") rotate(1.57,0,0)
label    bounds(105,  5, 60, 13) text("OUTPUT 2") align("right") rotate(1.57,0,0)
label    bounds(120,  5, 60, 13) text("OUTPUT 3") align("right") rotate(1.57,0,0)
label    bounds(135,  5, 60, 13) text("OUTPUT 4") align("right") rotate(1.57,0,0)
label    bounds(150,  5, 60, 13) text("OUTPUT 5") align("right") rotate(1.57,0,0)
label    bounds(165,  5, 60, 13) text("OUTPUT 6") align("right") rotate(1.57,0,0)
label    bounds(180,  5, 60, 13) text("OUTPUT 7") align("right") rotate(1.57,0,0)
label    bounds(195,  5, 60, 13) text("OUTPUT 8") align("right") rotate(1.57,0,0)
label    bounds(  2, 71, 70, 13) text("CHANNEL 1") align("right")
label    bounds(  2, 86, 70, 13) text("CHANNEL 2") align("right")
label    bounds(  2,101, 70, 13) text("CHANNEL 3") align("right")
label    bounds(  2,116, 70, 13) text("CHANNEL 4") align("right")
label    bounds(  2,131, 70, 13) text("CHANNEL 5") align("right")
label    bounds(  2,146, 70, 13) text("CHANNEL 6") align("right")
label    bounds(  2,161, 70, 13) text("CHANNEL 7") align("right")
label    bounds(  2,176, 70, 13) text("CHANNEL 8") align("right")

; Chn Out
checkbox bounds( 75, 70, 15, 15) channel(1_1) radioGroup(1), value(1)
checkbox bounds( 90, 70, 15, 15) channel(1_2) radioGroup(1)
checkbox bounds(105, 70, 15, 15) channel(1_3) radioGroup(1)
checkbox bounds(120, 70, 15, 15) channel(1_4) radioGroup(1)
checkbox bounds(135, 70, 15, 15) channel(1_5) radioGroup(1)
checkbox bounds(150, 70, 15, 15) channel(1_6) radioGroup(1)
checkbox bounds(165, 70, 15, 15) channel(1_7) radioGroup(1)
checkbox bounds(180, 70, 15, 15) channel(1_8) radioGroup(1)

checkbox bounds( 75, 85, 15, 15) channel(2_1) radioGroup(2)
checkbox bounds( 90, 85, 15, 15) channel(2_2) radioGroup(2), value(1)
checkbox bounds(105, 85, 15, 15) channel(2_3) radioGroup(2)
checkbox bounds(120, 85, 15, 15) channel(2_4) radioGroup(2)
checkbox bounds(135, 85, 15, 15) channel(2_5) radioGroup(2)
checkbox bounds(150, 85, 15, 15) channel(2_6) radioGroup(2)
checkbox bounds(165, 85, 15, 15) channel(2_7) radioGroup(2)
checkbox bounds(180, 85, 15, 15) channel(2_8) radioGroup(2)

checkbox bounds( 75,100, 15, 15) channel(3_1) radioGroup(3)
checkbox bounds( 90,100, 15, 15) channel(3_2) radioGroup(3)
checkbox bounds(105,100, 15, 15) channel(3_3) radioGroup(3), value(1)
checkbox bounds(120,100, 15, 15) channel(3_4) radioGroup(3)
checkbox bounds(135,100, 15, 15) channel(3_5) radioGroup(3)
checkbox bounds(150,100, 15, 15) channel(3_6) radioGroup(3)
checkbox bounds(165,100, 15, 15) channel(3_7) radioGroup(3)
checkbox bounds(180,100, 15, 15) channel(3_8) radioGroup(3)

checkbox bounds( 75,115, 15, 15) channel(4_1) radioGroup(4)
checkbox bounds( 90,115, 15, 15) channel(4_2) radioGroup(4)
checkbox bounds(105,115, 15, 15) channel(4_3) radioGroup(4)
checkbox bounds(120,115, 15, 15) channel(4_4) radioGroup(4), value(1)
checkbox bounds(135,115, 15, 15) channel(4_5) radioGroup(4)
checkbox bounds(150,115, 15, 15) channel(4_6) radioGroup(4)
checkbox bounds(165,115, 15, 15) channel(4_7) radioGroup(4)
checkbox bounds(180,115, 15, 15) channel(4_8) radioGroup(4)

checkbox bounds( 75,130, 15, 15) channel(5_1) radioGroup(5)
checkbox bounds( 90,130, 15, 15) channel(5_2) radioGroup(5)
checkbox bounds(105,130, 15, 15) channel(5_3) radioGroup(5)
checkbox bounds(120,130, 15, 15) channel(5_4) radioGroup(5)
checkbox bounds(135,130, 15, 15) channel(5_5) radioGroup(5), value(1)
checkbox bounds(150,130, 15, 15) channel(5_6) radioGroup(5)
checkbox bounds(165,130, 15, 15) channel(5_7) radioGroup(5)
checkbox bounds(180,130, 15, 15) channel(5_8) radioGroup(5)

checkbox bounds( 75,145, 15, 15) channel(6_1) radioGroup(6)
checkbox bounds( 90,145, 15, 15) channel(6_2) radioGroup(6)
checkbox bounds(105,145, 15, 15) channel(6_3) radioGroup(6)
checkbox bounds(120,145, 15, 15) channel(6_4) radioGroup(6)
checkbox bounds(135,145, 15, 15) channel(6_5) radioGroup(6)
checkbox bounds(150,145, 15, 15) channel(6_6) radioGroup(6), value(1)
checkbox bounds(165,145, 15, 15) channel(6_7) radioGroup(6)
checkbox bounds(180,145, 15, 15) channel(6_8) radioGroup(6)

checkbox bounds( 75,160, 15, 15) channel(7_1) radioGroup(7)
checkbox bounds( 90,160, 15, 15) channel(7_2) radioGroup(7)
checkbox bounds(105,160, 15, 15) channel(7_3) radioGroup(7)
checkbox bounds(120,160, 15, 15) channel(7_4) radioGroup(7)
checkbox bounds(135,160, 15, 15) channel(7_5) radioGroup(7)
checkbox bounds(150,160, 15, 15) channel(7_6) radioGroup(7)
checkbox bounds(165,160, 15, 15) channel(7_7) radioGroup(7), value(1)
checkbox bounds(180,160, 15, 15) channel(7_8) radioGroup(7)

checkbox bounds( 75,175, 15, 15) channel(8_1) radioGroup(8)
checkbox bounds( 90,175, 15, 15) channel(8_2) radioGroup(8)
checkbox bounds(105,175, 15, 15) channel(8_3) radioGroup(8)
checkbox bounds(120,175, 15, 15) channel(8_4) radioGroup(8)
checkbox bounds(135,175, 15, 15) channel(8_5) radioGroup(8)
checkbox bounds(150,175, 15, 15) channel(8_6) radioGroup(8)
checkbox bounds(165,175, 15, 15) channel(8_7) radioGroup(8)
checkbox bounds(180,175, 15, 15) channel(8_8) radioGroup(8), value(1)
}

; SPOKES
image bounds(200,580,200,200) colour(0,0,0,0) outlineThickness(1)
{
image bounds(  0,  0,200,200) colour("Black") outlineThickness(1) shape("ellipse")
encoder bounds(0,  0,200,200) channel("RotateScope") repeatInterval(360) popupText("0") value(0) increment(1) alpha(0)
image bounds(100,100,100,1) colour($COLOUR1) rotate(0,0,0) channel("spoke1")
image bounds(100,100,100,1) colour($COLOUR2) rotate(0,0,0) channel("spoke2")
image bounds(100,100,100,1) colour($COLOUR3) rotate(0,0,0) channel("spoke3")
image bounds(100,100,100,1) colour($COLOUR4) rotate(0,0,0) channel("spoke4")
image bounds(100,100,100,1) colour($COLOUR5) rotate(0,0,0) channel("spoke5")
image bounds(100,100,100,1) colour($COLOUR6) rotate(0,0,0) channel("spoke6")
image bounds(100,100,100,1) colour($COLOUR7) rotate(0,0,0) channel("spoke7")
image bounds(100,100,100,1) colour($COLOUR8) rotate(0,0,0) channel("spoke8")
;image bounds( 92,  0,16,16) colour(0,0,0) rotate(0,0,0) channel("bob1") shape("ellipse"), outlineThickness(1) outlineColour($COLOUR1) rotate(0,-8,92)
}

image bounds(400,580,220,200) colour(0,0,0,0) outlineThickness(1)
{
label   bounds(  0,  5,220, 15) align("centre") text("S  O  U  R  C  E     M  I  X  E  R")
vslider bounds( 35, 30, 50,160), range(-60,12,0,2,.1) channel("FrontdB") popupText("0") value(0) text("FRONT") valueTextBox(1) trackerThickness(0) ; tracker displays incorrectly with decibels
vslider bounds( 85, 30, 50,160), range(-60,12,0,2,.1) channel("SidesdB") popupText("0") value(0) text("SIDES") valueTextBox(1) trackerThickness(0) ; tracker displays incorrectly with decibels
vslider bounds(135, 30, 50,160), range(-60,12,0,2,.1) channel("ReardB") popupText("0") value(0) text("REAR") valueTextBox(1) trackerThickness(0) ; tracker displays incorrectly with decibels
}

image bounds(620,580,280,200) colour(0,0,0,0) outlineThickness(1)
{
label   bounds(  0,  5,280, 15) align("centre") text("C  H  A  N  N  E  L     M  E  T  E  R  S")
vmeter  bounds( 25, 30, 20,155) channel("VU1") value(0) outlineColour(0, 0, 0), overlayColour(0, 0, 0) meterColour:0(255, 0, 0) meterColour:1(255, 255, 0) meterColour:2(0, 255, 0) outlineThickness(1) 
vmeter  bounds( 55, 30, 20,155) channel("VU2") value(0) outlineColour(0, 0, 0), overlayColour(0, 0, 0) meterColour:0(255, 0, 0) meterColour:1(255, 255, 0) meterColour:2(0, 255, 0) outlineThickness(1) 
vmeter  bounds( 85, 30, 20,155) channel("VU3") value(0) outlineColour(0, 0, 0), overlayColour(0, 0, 0) meterColour:0(255, 0, 0) meterColour:1(255, 255, 0) meterColour:2(0, 255, 0) outlineThickness(1) 
vmeter  bounds(115, 30, 20,155) channel("VU4") value(0) outlineColour(0, 0, 0), overlayColour(0, 0, 0) meterColour:0(255, 0, 0) meterColour:1(255, 255, 0) meterColour:2(0, 255, 0) outlineThickness(1) 
vmeter  bounds(145, 30, 20,155) channel("VU5") value(0) outlineColour(0, 0, 0), overlayColour(0, 0, 0) meterColour:0(255, 0, 0) meterColour:1(255, 255, 0) meterColour:2(0, 255, 0) outlineThickness(1) 
vmeter  bounds(175, 30, 20,155) channel("VU6") value(0) outlineColour(0, 0, 0), overlayColour(0, 0, 0) meterColour:0(255, 0, 0) meterColour:1(255, 255, 0) meterColour:2(0, 255, 0) outlineThickness(1) 
vmeter  bounds(205, 30, 20,155) channel("VU7") value(0) outlineColour(0, 0, 0), overlayColour(0, 0, 0) meterColour:0(255, 0, 0) meterColour:1(255, 255, 0) meterColour:2(0, 255, 0) outlineThickness(1) 
vmeter  bounds(235, 30, 20,155) channel("VU8") value(0) outlineColour(0, 0, 0), overlayColour(0, 0, 0) meterColour:0(255, 0, 0) meterColour:1(255, 255, 0) meterColour:2(0, 255, 0) outlineThickness(1) 
{

</Cabbage>

<CsoundSynthesizer>
<CsOptions>
-n -d -+rtmidi=NULL -M0 --midi-key-cps=4 --midi-velocity-amp=5
</CsOptions>
<CsInstruments>
    
ksmps = 32
nchnls = 8
nchnls_i = 8
0dbfs = 1

 iMidF ftgen 1,0,2048,19,1,1,270,1
 iSide ftgen 2,0,2048,19,1,1,  0,0
 iMidR ftgen 3,0,2048,19,1,1, 90,1



opcode dmsDecoder, aaaaaaaa, aaakkkkkkkk
 aMidF,aSide,aMidR,kAz1,kAz2,kAz3,kAz4,kAz5,kAz6,kAz7,kAz8 xin
 #define dmsChan(N)
 #
 kMidF     =       cos((kAz$N/180) * $M_PI) * 0.5 + 0.5
 kSide     =       sin(((kAz$N+180)/180) * $M_PI)
 kMidR     =       cos(((kAz$N+180)/180) * $M_PI) * 0.5 + 0.5
 a$N       =       aMidF*kMidF + aSide*kSide + aMidR*kMidR
 # 
 $dmsChan(1)
 $dmsChan(2)
 $dmsChan(3)
 $dmsChan(4)
 $dmsChan(5)
 $dmsChan(6)
 $dmsChan(7)
 $dmsChan(8)
          xout     a1,a2,a3,a4,a5,a6,a7,a8
endop


instr 1
; speaker array presets
kPreset cabbageGetValue "Preset"
kPreset init 1
iP1     ftgen           0,0,8,-2, -25,   25,   -50,   50,   -90,    90,  -140,   140
iP2     ftgen           0,0,8,-2, 0,     45,   90,   135,   180,   225,   270,   315
iP3     ftgen           0,0,8,-2, -22.5, 22.5, 67.5, 112.5, 157.5, 202.5, 247.5, 292.5
if changed:k(kPreset)==1 then
reinit PRESET
endif
PRESET:
iCount = 0
while iCount<ftlen(iP1) do
 Schan sprintf "Az%d", iCount + 1
 cabbageSetValue Schan, table:i(iCount,iP1+i(kPreset)-1)
 iCount += 1
od

; read audio inputs
aMidF  inch 1
aSide  inch 2
aMidR  inch 3

; button on upper horizontal scope
kFront cabbageGetValue "Front"
kSides cabbageGetValue "Sides"
kRear  cabbageGetValue "Rear"

; turning scaling table viewers on/off. Not yet supported
;tableColour:0(250, 255, 0) tableColour:1(0, 100, 250) tableColour:2(100, 250, 100)
;cabbageSet changed:k(kFront), "DisplayTable", "tableNumber", kFront, 2*kSides, 3*kRear

;tableColour:0(250, 255, 0) tableColour:1(0, 100, 250) tableColour:2(100, 250, 100)
; VIEW/HIDE TABLES
cabbageSet changed:k(kFront), "DisplayTable", "tableColour:0", 250*kFront, 255*kFront,   0*kFront
cabbageSet changed:k(kSides), "DisplayTable", "tableColour:0",   0*kSides, 100*kSides, 250*kSides
cabbageSet changed:k(kRear),  "DisplayTable", "tableColour:0", 100*kRear,  250*kRear,  100*kRear

; level controls for the three input signals
kFrontdB cabbageGetValue "FrontdB"
kSidesdB cabbageGetValue "SidesdB"
kReardB  cabbageGetValue "ReardB"

; apply level controls
aMidF *= kFront * ampdbfs(kFrontdB)
aSide *= kSides * ampdbfs(kSidesdB)
aMidR *= kRear * ampdbfs(kReardB)

aOmni  sum aMidF, aSide, aMidR

; azimuth controls
kAz1 cabbageGetValue "Az1"
kAz2 cabbageGetValue "Az2"
kAz3 cabbageGetValue "Az3"
kAz4 cabbageGetValue "Az4"
kAz5 cabbageGetValue "Az5"
kAz6 cabbageGetValue "Az6"
kAz7 cabbageGetValue "Az7"
kAz8 cabbageGetValue "Az8"

; globals azimuth rotate
kRotate cabbageGetValue "Rotate"
kRotateScope cabbageGetValue "RotateScope"

cabbageSetValue "Rotate",kRotateScope,changed:k(kRotateScope)
cabbageSetValue "RotateScope",kRotate,changed:k(kRotate)

; MOVE VERTICAL BARS
cabbageSet changed:k(kAz1,kRotate), "indic1", "bounds", (wrap:k(((kAz1+kRotate+180)/360),0,1)*800) + 30,10, 1, 200
cabbageSet changed:k(kAz2,kRotate), "indic2", "bounds", (wrap:k(((kAz2+kRotate+180)/360),0,1)*800) + 30,10, 1, 200
cabbageSet changed:k(kAz3,kRotate), "indic3", "bounds", (wrap:k(((kAz3+kRotate+180)/360),0,1)*800) + 30,10, 1, 200
cabbageSet changed:k(kAz4,kRotate), "indic4", "bounds", (wrap:k(((kAz4+kRotate+180)/360),0,1)*800) + 30,10, 1, 200
cabbageSet changed:k(kAz5,kRotate), "indic5", "bounds", (wrap:k(((kAz5+kRotate+180)/360),0,1)*800) + 30,10, 1, 200
cabbageSet changed:k(kAz6,kRotate), "indic6", "bounds", (wrap:k(((kAz6+kRotate+180)/360),0,1)*800) + 30,10, 1, 200
cabbageSet changed:k(kAz7,kRotate), "indic7", "bounds", (wrap:k(((kAz7+kRotate+180)/360),0,1)*800) + 30,10, 1, 200
cabbageSet changed:k(kAz8,kRotate), "indic8", "bounds", (wrap:k(((kAz8+kRotate+180)/360),0,1)*800) + 30,10, 1, 200

; ROTATE SPOKES
cabbageSet changed:k(kAz1,kRotate), "spoke1", "rotate", wrap:k(((kAz1+kRotate+270)/360),0,1) * $M_PI * 2, 1, 0
cabbageSet changed:k(kAz2,kRotate), "spoke2", "rotate", wrap:k(((kAz2+kRotate+270)/360),0,1) * $M_PI * 2, 1, 0
cabbageSet changed:k(kAz3,kRotate), "spoke3", "rotate", wrap:k(((kAz3+kRotate+270)/360),0,1) * $M_PI * 2, 1, 0
cabbageSet changed:k(kAz4,kRotate), "spoke4", "rotate", wrap:k(((kAz4+kRotate+270)/360),0,1) * $M_PI * 2, 1, 0
cabbageSet changed:k(kAz5,kRotate), "spoke5", "rotate", wrap:k(((kAz5+kRotate+270)/360),0,1) * $M_PI * 2, 1, 0
cabbageSet changed:k(kAz6,kRotate), "spoke6", "rotate", wrap:k(((kAz6+kRotate+270)/360),0,1) * $M_PI * 2, 1, 0
cabbageSet changed:k(kAz7,kRotate), "spoke7", "rotate", wrap:k(((kAz7+kRotate+270)/360),0,1) * $M_PI * 2, 1, 0
cabbageSet changed:k(kAz8,kRotate), "spoke8", "rotate", wrap:k(((kAz8+kRotate+270)/360),0,1) * $M_PI * 2, 1, 0

; ROTATE BOBS
;cabbageSet changed:k(kAz1,kRotate), "bob1", "rotate", wrap:k(((kAz1+kRotate+0)/360),0,1) * $M_PI * 2, 0, 100


; GAIN, MUTE, SOLO WIDGETS
kGain1 cabbageGetValue "Gain1"
kGain2 cabbageGetValue "Gain2"
kGain3 cabbageGetValue "Gain3"
kGain4 cabbageGetValue "Gain4"
kGain5 cabbageGetValue "Gain5"
kGain6 cabbageGetValue "Gain6"
kGain7 cabbageGetValue "Gain7"
kGain8 cabbageGetValue "Gain8"
kMaster cabbageGetValue "Master"
kMute1 cabbageGetValue "Mute1"
kMute2 cabbageGetValue "Mute2"
kMute3 cabbageGetValue "Mute3"
kMute4 cabbageGetValue "Mute4"
kMute5 cabbageGetValue "Mute5"
kMute6 cabbageGetValue "Mute6"
kMute7 cabbageGetValue "Mute7"
kMute8 cabbageGetValue "Mute8"
kSolo1 cabbageGetValue "Solo1"
kSolo2 cabbageGetValue "Solo2"
kSolo3 cabbageGetValue "Solo3"
kSolo4 cabbageGetValue "Solo4"
kSolo5 cabbageGetValue "Solo5"
kSolo6 cabbageGetValue "Solo6"
kSolo7 cabbageGetValue "Solo7"
kSolo8 cabbageGetValue "Solo8"

; CLEAR MUTES IF SOLO PRESSED
if changed:k(kSolo1,kSolo2,kSolo3,kSolo4,kSolo5,kSolo6,kSolo7,kSolo8)==1 then
cabbageSetValue "Mute1", 0, k(1)
cabbageSetValue "Mute2", 0, k(1)
cabbageSetValue "Mute3", 0, k(1)
cabbageSetValue "Mute4", 0, k(1)
cabbageSetValue "Mute5", 0, k(1)
cabbageSetValue "Mute6", 0, k(1)
cabbageSetValue "Mute7", 0, k(1)
cabbageSetValue "Mute8", 0, k(1)
endif

; CREATE AMP VALUES FROM GAINS MASTER AND MUTES
kAmp1   =    ampdbfs(kGain1+kMaster)*(1-kMute1)
kAmp2   =    ampdbfs(kGain2+kMaster)*(1-kMute2)
kAmp3   =    ampdbfs(kGain3+kMaster)*(1-kMute3)
kAmp4   =    ampdbfs(kGain4+kMaster)*(1-kMute4)
kAmp5   =    ampdbfs(kGain5+kMaster)*(1-kMute5)
kAmp6   =    ampdbfs(kGain6+kMaster)*(1-kMute6)
kAmp7   =    ampdbfs(kGain7+kMaster)*(1-kMute7)
kAmp8   =    ampdbfs(kGain8+kMaster)*(1-kMute8)

; MODIFY AMP VALUE FROM SOLOS
kSoloSum = kSolo1+kSolo2+kSolo3+kSolo4+kSolo5+kSolo6+kSolo7+kSolo8
if kSoloSum>0 then
kAmp1 *= kSolo1
kAmp2 *= kSolo2
kAmp3 *= kSolo3
kAmp4 *= kSolo4
kAmp5 *= kSolo5
kAmp6 *= kSolo6
kAmp7 *= kSolo7
kAmp8 *= kSolo8
endif

; DRAW COLOUR WEIGHT (ALPHA) FOR VERTICAL INDICATORS (HORIZONTAL SCOPE) AND SPOKES (CIRCULAR SCOPE)
cabbageSet changed:k(kGain1,kMute1,kSoloSum,kMaster), "indic1", "alpha", kAmp1^0.5
cabbageSet changed:k(kGain2,kMute2,kSoloSum,kMaster), "indic2", "alpha", kAmp2^0.5
cabbageSet changed:k(kGain3,kMute3,kSoloSum,kMaster), "indic3", "alpha", kAmp3^0.5
cabbageSet changed:k(kGain4,kMute4,kSoloSum,kMaster), "indic4", "alpha", kAmp4^0.5
cabbageSet changed:k(kGain5,kMute5,kSoloSum,kMaster), "indic5", "alpha", kAmp5^0.5
cabbageSet changed:k(kGain6,kMute6,kSoloSum,kMaster), "indic6", "alpha", kAmp6^0.5
cabbageSet changed:k(kGain7,kMute7,kSoloSum,kMaster), "indic7", "alpha", kAmp7^0.5
cabbageSet changed:k(kGain8,kMute8,kSoloSum,kMaster), "indic8", "alpha", kAmp8^0.5

cabbageSet changed:k(kGain1,kMute1,kSoloSum,kMaster), "spoke1", "alpha", kAmp1^0.5
cabbageSet changed:k(kGain2,kMute2,kSoloSum,kMaster), "spoke2", "alpha", kAmp2^0.5
cabbageSet changed:k(kGain3,kMute3,kSoloSum,kMaster), "spoke3", "alpha", kAmp3^0.5
cabbageSet changed:k(kGain4,kMute4,kSoloSum,kMaster), "spoke4", "alpha", kAmp4^0.5
cabbageSet changed:k(kGain5,kMute5,kSoloSum,kMaster), "spoke5", "alpha", kAmp5^0.5
cabbageSet changed:k(kGain6,kMute6,kSoloSum,kMaster), "spoke6", "alpha", kAmp6^0.5
cabbageSet changed:k(kGain7,kMute7,kSoloSum,kMaster), "spoke7", "alpha", kAmp7^0.5
cabbageSet changed:k(kGain8,kMute8,kSoloSum,kMaster), "spoke8", "alpha", kAmp8^0.5

; CALL DECODER UDO
a1,a2,a3,a4,a5,a6,a7,a8  dmsDecoder aMidF, aSide, aMidR, kAz1+kRotate, kAz2+kRotate, kAz3+kRotate, kAz4+kRotate, kAz5+kRotate, kAz6+kRotate, kAz7+kRotate, kAz8+kRotate 

; SCALE OUTPUT AUDIO SIGNALS
a1 *= kAmp1
a2 *= kAmp2
a3 *= kAmp3
a4 *= kAmp4
a5 *= kAmp5
a6 *= kAmp6
a7 *= kAmp7
a8 *= kAmp8

; optional delays on 'surround' signals
;a7  vdelay  a7,a(20),20
;a8  vdelay  a8,a(20),20

; CHANNEL OUT MATRIX
k1_1 cabbageGetValue "1_1"
k1_2 cabbageGetValue "1_2"
k1_3 cabbageGetValue "1_3"
k1_4 cabbageGetValue "1_4"
k1_5 cabbageGetValue "1_5"
k1_6 cabbageGetValue "1_6"
k1_7 cabbageGetValue "1_7"
k1_8 cabbageGetValue "1_8"

k2_1 cabbageGetValue "2_1"
k2_2 cabbageGetValue "2_2"
k2_3 cabbageGetValue "2_3"
k2_4 cabbageGetValue "2_4"
k2_5 cabbageGetValue "2_5"
k2_6 cabbageGetValue "2_6"
k2_7 cabbageGetValue "2_7"
k2_8 cabbageGetValue "2_8"

k3_1 cabbageGetValue "3_1"
k3_2 cabbageGetValue "3_2"
k3_3 cabbageGetValue "3_3"
k3_4 cabbageGetValue "3_4"
k3_5 cabbageGetValue "3_5"
k3_6 cabbageGetValue "3_6"
k3_7 cabbageGetValue "3_7"
k3_8 cabbageGetValue "3_8"

k4_1 cabbageGetValue "4_1"
k4_2 cabbageGetValue "4_2"
k4_3 cabbageGetValue "4_3"
k4_4 cabbageGetValue "4_4"
k4_5 cabbageGetValue "4_5"
k4_6 cabbageGetValue "4_6"
k4_7 cabbageGetValue "4_7"
k4_8 cabbageGetValue "4_8"

k5_1 cabbageGetValue "5_1"
k5_2 cabbageGetValue "5_2"
k5_3 cabbageGetValue "5_3"
k5_4 cabbageGetValue "5_4"
k5_5 cabbageGetValue "5_5"
k5_6 cabbageGetValue "5_6"
k5_7 cabbageGetValue "5_7"
k5_8 cabbageGetValue "5_8"

k6_1 cabbageGetValue "6_1"
k6_2 cabbageGetValue "6_2"
k6_3 cabbageGetValue "6_3"
k6_4 cabbageGetValue "6_4"
k6_5 cabbageGetValue "6_5"
k6_6 cabbageGetValue "6_6"
k6_7 cabbageGetValue "6_7"
k6_8 cabbageGetValue "6_8"

k7_1 cabbageGetValue "7_1"
k7_2 cabbageGetValue "7_2"
k7_3 cabbageGetValue "7_3"
k7_4 cabbageGetValue "7_4"
k7_5 cabbageGetValue "7_5"
k7_6 cabbageGetValue "7_6"
k7_7 cabbageGetValue "7_7"
k7_8 cabbageGetValue "7_8"

k8_1 cabbageGetValue "8_1"
k8_2 cabbageGetValue "8_2"
k8_3 cabbageGetValue "8_3"
k8_4 cabbageGetValue "8_4"
k8_5 cabbageGetValue "8_5"
k8_6 cabbageGetValue "8_6"
k8_7 cabbageGetValue "8_7"
k8_8 cabbageGetValue "8_8"

kOut1 = (k1_1*1) + (k1_2*2) + (k1_3*3) + (k1_4*4) + (k1_5*5) + (k1_6*6) + (k1_7*7) + (k1_8*8)
kOut2 = (k2_1*1) + (k2_2*2) + (k2_3*3) + (k2_4*4) + (k2_5*5) + (k2_6*6) + (k2_7*7) + (k2_8*8)
kOut3 = (k3_1*1) + (k3_2*2) + (k3_3*3) + (k3_4*4) + (k3_5*5) + (k3_6*6) + (k3_7*7) + (k3_8*8)
kOut4 = (k4_1*1) + (k4_2*2) + (k4_3*3) + (k4_4*4) + (k4_5*5) + (k4_6*6) + (k4_7*7) + (k4_8*8)
kOut5 = (k5_1*1) + (k5_2*2) + (k5_3*3) + (k5_4*4) + (k5_5*5) + (k5_6*6) + (k5_7*7) + (k5_8*8)
kOut6 = (k6_1*1) + (k6_2*2) + (k6_3*3) + (k6_4*4) + (k6_5*5) + (k6_6*6) + (k6_7*7) + (k6_8*8)
kOut7 = (k7_1*1) + (k7_2*2) + (k7_3*3) + (k7_4*4) + (k7_5*5) + (k7_6*6) + (k7_7*7) + (k7_8*8)
kOut8 = (k8_1*1) + (k8_2*2) + (k8_3*3) + (k8_4*4) + (k8_5*5) + (k8_6*6) + (k8_7*7) + (k8_8*8)



                  outch      kOut1,a1,kOut2,a2,kOut3,a3,kOut4,a4,kOut5,a5,kOut6,a6,kOut7,a7,kOut8,a8 ;, 9,aOmni
endin


instr 2
a1,a2,a3,a4,a5,a6,a7,a8 monitor
; METERS
cabbageSetValue "VU1", rms:k(a1)
cabbageSetValue "VU2", rms:k(a2)
cabbageSetValue "VU3", rms:k(a3)
cabbageSetValue "VU4", rms:k(a4)
cabbageSetValue "VU5", rms:k(a5)
cabbageSetValue "VU6", rms:k(a6)
cabbageSetValue "VU7", rms:k(a7)
cabbageSetValue "VU8", rms:k(a8)

endin

</CsInstruments>
<CsScore>
i 1 0 z
i 2 0 z
</CsScore>
</CsoundSynthesizer>
