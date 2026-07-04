
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; StringSection.csd
; Written by Iain McCurdy, 2024

; String ensemble sound comprised of two elements: the sustain sound and the bow-attack.

; DESIGN
; Mod. Depth  -  the interval of random modulation depth
; Number      -  number of voices in the section
; Movement    -  speed of random modulation
; Tone        -  a simple 6dB/octave lowpass filter applied to the strings sound
;                also controlled by the envelope

; REVERB
; Send        -  amount of signal sent to the reverb
; Size        -  duration of the reverb effect
; Damp        -  lowpass filtering within the reverb algorithm

; ENVELOPE
; Attack      -  attack time. Affects build of sustained strings component. 
;                 Also controlled by key velocity. 
;                 Keyboard scaled: lower notes will have slower attacks.
; Decay       -  time to decay to the sustain level
;                 Keyboard scaled: lower notes will have slower attacks.
; Sustain     -  Sustain level
; Release     -  envelope release time after key is released.
;                 Keyboard scaled: lower notes will have slower attacks.

; MIXER
; Sustain     -  sustain component level
; Bow         -  bow contact noise component level
; Level       -  level of the sustain part of the sound

; The modulation wheel scales Mod. Depth and Tone thereby functioning as a kind of 'expression' control.
; Pitch bend wheel slides the pitch up or down by a maximum of 2 semitones.

<Cabbage>
#define SliderDesign1 colour(255,100,100), trackerColour("white"), markerColour("black"), textColour("black"), fontColour("black"), valueTextBox(1)
#define SliderDesign2 colour(255,255,100), trackerColour("white"), markerColour("black"), textColour("black"), fontColour("black"),valueTextBox(1)
#define SliderDesign3 colour(100,100,255), trackerColour("white"), markerColour("black"), textColour("black"), fontColour("black"),valueTextBox(1)
#define SliderDesign4 colour(100,255,100), trackerColour("white"), markerColour("black"), textColour("black"), fontColour("black"),valueTextBox(1)

form caption("String Section") size(1185,235), guiMode("queue"), pluginId("Strs"), colour(220,220,220)

image    bounds(  5,  5,330,130), colour(0,0,0,0), outlineThickness(2), outlineColour("black"), corners(10)
{
label    bounds(  0,  6,330, 13), text("D  E  S  I  G  N"), fontColour("black")
rslider  bounds(  5, 20, 80,100), channel("Depth"), range(0.3,10, 0.4), text("Mod. Depth"), $SliderDesign4
rslider  bounds( 85, 20, 80,100), channel("NVoice"), range(1,100,50,1,1), text("Number"), $SliderDesign4
rslider  bounds(165, 20, 80,100), channel("Movement"), range(0.1,20,0.5), text("Movement"), $SliderDesign4
rslider  bounds(245, 20, 80,100), channel("Brightness"), range(3,12,8), text("Tone"), $SliderDesign4
}

image    bounds(340,  5,330,130), colour(0,0,0,0), outlineThickness(2), outlineColour("black"), corners(10)
{
label    bounds(  0,  6,330, 13), text("E  N  V  E  L  O  P  E"), fontColour("black")
rslider  bounds(  5, 20, 80,100), channel("Att"), range(0.01,4,1,0.5), text("Attack"), $SliderDesign2
rslider  bounds( 85, 20, 80,100), channel("Dec"), range(0.01,2,0.3,0.5), text("Decay"), $SliderDesign2
rslider  bounds(165, 20, 80,100), channel("Sus"), range(0,1,0.9), text("Sustain"), $SliderDesign2
rslider  bounds(245, 20, 80,100), channel("Rel"), range(0.01,2,0.2,0.5), text("Release"), $SliderDesign2
}


image    bounds(675,  5,250,130), colour(0,0,0,0), outlineThickness(2), outlineColour("black"), corners(10)
{
label    bounds(  0,  6,250, 13), text("R  E  V  E  R  B"), fontColour("black")
rslider  bounds(  5, 20, 80,100), channel("Send"), range(0,1,0.4), text("Send"), $SliderDesign1
rslider  bounds( 85, 20, 80,100), channel("Size"), range(0.3,0.999,0.8,3), text("Size"), $SliderDesign1
rslider  bounds(165, 20, 80,100), channel("Damp"), range(400,16000,8000,0.5,1), text("Damp"), $SliderDesign1
}

image    bounds(930,  5,250,130), colour(0,0,0,0), outlineThickness(2), outlineColour("black"), corners(10)
{
label    bounds(  0,  6,250, 13), text("M  I  X  E  R"), fontColour("black")
rslider  bounds(  5, 20, 80,100), channel("SusLev"), range(0,2,1,0.5), text("Sustain"), $SliderDesign3
rslider  bounds( 85, 20, 80,100), channel("BowLev"), range(0,2,0.085,0.5), text("Bow"), $SliderDesign3
rslider  bounds(165, 20, 80,100), channel("Level"), range(0,4,1,0.5), text("Level"), $SliderDesign3
}

keyboard bounds(  5,140,1175, 80)

label    bounds(  5,221,250, 14), text("Iain McCurdy |2024|"), fontColour("black"), align("left")
</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-n -dm0 -+rtmidi=NULL -M0 --midi-key-cps=4 --midi-velocity-amp=5
</CsOptions>

<CsInstruments>

; Initialize the global variables. 
ksmps  =  32
0dbfs  =  1

; wavetables; numbers in names refer to note numbers ideal for that wavetable
giStringSection24  ftgen  24, 0, 65536, 10, 3.746322, 91.724758, 61.298615, 43.139915, 40.876462, 6.225791, 13.260244, 9.918685, 6.363784, 15.566170, 2.663664, 12.922825, 4.989285, 16.660161, 5.821331, 2.892206, 7.388986, 0.584380, 1.572057, 2.912511, 2.486327, 8.145287, 2.178471, 1.567583, 0.649624, 0.834124, 2.349593, 1.559772, 1.160042, 0.756645, 1.626196, 1.419375, 0.659115, 1.160509, 2.005509, 2.033993, 1.987116, 2.198858, 1.162727, 1.035449, 1.648237, 0.926863, 0.534633, 0.746235, 0.385671, 0.354845, 0.465677, 0.296828, 0.261405, 0.172861, 0.198423, 0.232442, 0.232061, 0.120797, 0.079891, 0.097139, 0.105636, 0.080342, 0.074947, 0.064248, 0.070863, 0.090766, 0.078374, 0.057943, 0.069701, 0.048674, 0.030284, 0.033010, 0.032897, 0.038854, 0.071617, 0.105228, 0.080177, 0.041671, 0.032274, 0.036560, 0.031471, 0.029518, 0.029176, 0.030262, 0.034998, 0.038209, 0.032997, 0.028222, 0.024611, 0.016877, 0.012460, 0.012487, 0.013386, 0.013902, 0.016282, 0.021409, 0.029504, 0.033580, 0.031708, 0.027035, 0.024271, 0.025654, 0.026790, 0.023244, 0.019463, 0.021940, 0.027298, 0.029475, 0.032620, 0.041921, 0.052696, 0.053492, 0.049163, 0.049001, 0.048397, 0.047466, 0.045861, 0.042406, 0.041149, 0.039811, 0.037197, 0.033405, 0.029257, 0.027116, 0.025372, 0.023040, 0.022071, 0.025189, 0.028623, 0.028381, 0.026235, 0.025127, 0.025354, 0.027079, 0.031572, 0.036588, 0.038896, 0.038511, 0.038102, 0.037709, 0.033745, 0.027170, 0.022840, 0.022810, 0.024107, 0.023690, 0.021529, 0.019451, 0.018486, 0.018337, 0.018228, 0.017611, 0.017202, 0.018561, 0.022066, 0.026513, 0.029658, 0.029410, 0.026359, 0.023319, 0.022340, 0.022892, 0.022868, 0.021719, 0.020578, 0.020618, 0.021725, 0.022636, 0.022749, 0.022592, 0.022575, 0.022186, 0.021267, 0.020620, 0.020893, 0.021782, 0.022638, 0.023193, 0.023413, 0.023386, 0.023124, 0.022537, 0.021679, 0.020597, 0.019287, 0.017958, 0.017199, 0.017556, 0.019003, 0.021053, 0.023124, 0.024827, 0.025988, 0.026765, 0.027903, 0.030041, 0.032873, 0.035923, 0.039503, 0.044027, 0.048942, 0.052975, 0.055059, 0.054721, 0.051996, 0.047718, 0.043648, 0.041314, 0.040424, 0.039148, 0.036240, 0.032148, 0.028102, 0.025012, 0.023270, 0.022834, 0.023155, 0.023444, 0.023257, 0.022694, 0.022080, 0.021729, 0.021980, 0.022981, 0.024315, 0.025269, 0.025455, 0.024952, 0.023993, 0.022789, 0.021600, 0.020711, 0.020265, 0.020235, 0.020642, 0.021702, 0.023566, 0.025998, 0.028492, 0.030635, 0.032205, 0.033039, 0.033016, 0.032184, 0.030828, 0.029352, 0.028022, 0.026905, 0.026078, 0.025710, 0.025792, 0.025953, 0.025746, 0.025060, 0.024133, 0.023217, 0.022355, 0.021494, 0.020710, 0.020259, 0.020466, 0.021523, 0.023356, 0.025646, 0.027946, 0.029850, 0.031128, 0.031768, 0.031892, 0.031665, 0.031259, 0.030794, 0.030271, 0.029566, 0.028515, 0.027058, 0.025343, 0.023698, 0.022477, 0.021892, 0.021936, 0.022406, 0.023009, 0.023470, 0.023621, 0.023417, 0.022902, 0.022168, 0.021327, 0.020511, 0.019855, 0.019462, 0.019372, 0.019563, 0.019966, 0.020484, 0.021005, 0.021428, 0.021709, 0.021885, 0.022041, 0.022255, 0.022568, 0.022988, 0.023494, 0.024027, 0.024476, 0.024697, 0.024579, 0.024103, 0.023357, 0.022488, 0.021650, 0.020956, 0.020443, 0.020064, 0.019742, 0.019441, 0.019189, 0.019029, 0.018962, 0.018949, 0.018951, 0.018967, 0.019039, 0.019205, 0.019460, 0.019749, 0.019991, 0.020116, 0.020078, 0.019869, 0.019524, 0.019105, 0.018673, 0.018270, 0.017916, 0.017626, 0.017431, 0.017372, 0.017492, 0.017812, 0.018321, 0.018985, 0.019755, 0.020574, 0.021375, 0.022092, 0.022662, 0.023046, 0.023226, 0.023208, 0.023017, 0.022695, 0.022294, 0.021885, 0.021557, 0.021414, 0.021545, 0.021985, 0.022685, 0.023506, 0.024261, 0.024779, 0.024960, 0.024811, 0.024429, 0.023965, 0.023561, 0.023304, 0.023198, 0.023183, 0.023171, 0.023091, 0.022907, 0.022621, 0.022254, 0.021841, 0.021415, 0.021015, 0.020683, 0.020457, 0.020364, 0.020405, 0.020546, 0.020720, 0.020842, 0.020832, 0.020635, 0.020238, 0.019670, 0.018997, 0.018303, 0.017677, 0.017193, 0.016898, 0.016805, 0.016900, 0.017140, 0.017472, 0.017845, 0.018222, 0.018584, 0.018923, 0.019240, 0.019532, 0.019794, 0.020015, 0.020185, 0.020302, 0.020378, 0.020444, 0.020536, 0.020683, 0.020896, 0.021156, 0.021429, 0.021669, 0.021830, 0.021873, 0.021777, 0.021541, 0.021200, 0.020818, 0.020481, 0.020270, 0.020245, 0.020425, 0.020791, 0.021296, 0.021881, 0.022489, 0.023071, 0.023590, 0.024017, 0.024333, 0.024527, 0.024607, 0.024597, 0.024538, 0.024467, 0.024405, 0.024351, 0.024287, 0.024194, 0.024066, 0.023911, 0.023746, 0.023588, 0.023441, 0.023300, 0.023149, 0.022973, 0.022758, 0.022502, 0.022216, 0.021924, 0.021661, 0.021467, 0.021371, 0.021385, 0.021499, 0.021680, 0.021886, 0.022073, 0.022209, 0.022284, 0.022312, 0.022330, 0.022393, 0.022559, 0.022872, 0.023350, 0.023981, 0.024721, 0.025512, 0.026291, 0.026999, 0.027596, 0.028057, 0.028374, 0.028556, 0.028625, 0.028613, 0.028558, 0.028504, 0.028491, 0.028555, 0.028718, 0.028990, 0.029356, 0.029788, 0.030241, 0.030664, 0.031009, 0.031237, 0.031328, 0.031283, 0.031124, 0.030885, 0.030605, 0.030315, 0.030034, 0.029763, 0.029488, 0.029189, 0.028853, 0.028476, 0.028067, 0.027648, 0.027242, 0.026874, 0.026561, 0.026316, 0.026141, 0.026031, 0.025975, 0.025959, 0.025966, 0.025980, 0.025988, 0.025982, 0.025959, 0.025919, 0.025863, 0.025794, 0.025713, 0.025621, 0.025521, 0.025421, 0.025332, 0.025272, 0.025260, 0.025313, 0.025441, 0.025648, 0.025927, 0.026267, 0.026647, 0.027050, 0.027457, 0.027857, 0.028241, 0.028612, 0.028972, 0.029330, 0.029691, 0.030054, 0.030414, 0.030754, 0.031049, 0.031268, 0.031377, 0.031349, 0.031172, 0.030848, 0.030400, 0.029863, 0.029278, 0.028686, 0.028118, 0.027600, 0.027150, 0.026781, 0.026504, 0.026328, 0.026258, 0.026294, 0.026426, 0.026635, 0.026896, 0.027179, 0.027456, 0.027705, 0.027913, 0.028073, 0.028188, 0.028269, 0.028331, 0.028392, 0.028472, 0.028592, 0.028768, 0.029011, 0.029326, 0.029708, 0.030137, 0.030586, 0.031017, 0.031394, 0.031687, 0.031876, 0.031955, 0.031929, 0.031809, 0.031611, 0.031346, 0.031024, 0.030653, 0.030235, 0.029778, 0.029289, 0.028780, 0.028267, 0.027767, 0.027299, 0.026876, 0.026507, 0.026195, 0.025938, 0.025726, 0.025550, 0.025398, 0.025260, 0.025131, 0.025007, 0.024886, 0.024771, 0.024664, 0.024565, 0.024474, 0.024387, 0.024300, 0.024208, 0.024108, 0.023999, 0.023884, 0.023772, 0.023672, 0.023596, 0.023557, 0.023572, 0.023653, 0.023811, 0.024053, 0.024381, 0.024794, 0.025284, 0.025842, 0.026454, 0.027104, 0.027774, 0.028446, 0.029101, 0.029715, 0.030267, 0.030731, 0.031080, 0.031297, 0.031371, 0.031311, 0.031135, 0.030874, 0.030558, 0.030219, 0.029880, 0.029558, 0.029267, 0.029016, 0.028811, 0.028653, 0.028537, 0.028453, 0.028383, 0.028315, 0.028250, 0.028202, 0.028179, 0.028164, 0.028110, 0.027977, 0.027754, 0.027469, 0.027226, 0.027500, 0.027975, 0.027598, 0.027900
giStringSection36  ftgen  36, 0, 65536, 10, 30.961395, 102.698338, 45.688959, 45.478722, 7.256527, 7.219426, 11.878700, 8.942159, 16.950407, 6.132646, 4.020980, 0.819794, 1.980547, 2.980526, 2.303822, 1.493541, 1.203877, 1.565681, 2.443512, 4.321747, 2.023644, 1.571091, 2.647572, 1.849689, 1.863407, 0.854497, 0.771123, 0.618948, 0.803295, 0.495398, 0.711193, 0.453206, 0.630792, 0.473193, 0.311823, 0.914926, 0.368165, 0.264324, 0.402124, 0.506301, 0.288957, 0.395673, 0.304786, 0.122058, 0.140921, 0.201846, 0.128602, 0.103381, 0.130677, 0.089225, 0.089605, 0.080072, 0.096045, 0.098167, 0.115992, 0.082616, 0.095002, 0.108275, 0.074244, 0.061554, 0.058491, 0.052217, 0.054535, 0.069399, 0.076284, 0.061380, 0.062609, 0.063652, 0.070393, 0.108138, 0.153959, 0.131981, 0.083302, 0.068525, 0.054349, 0.040342, 0.035003, 0.036747, 0.037355, 0.032970, 0.031058, 0.032978, 0.036186, 0.042472, 0.054631, 0.050394, 0.044070, 0.046872, 0.043771, 0.035218, 0.032737, 0.035648, 0.042572, 0.043433, 0.035478, 0.031350, 0.037011, 0.043975, 0.046287, 0.045343, 0.041574, 0.042941, 0.050049, 0.052037, 0.048347, 0.045650, 0.041151, 0.039553, 0.042062, 0.043239, 0.046980, 0.050478, 0.048318, 0.044538, 0.041842, 0.039270, 0.038508, 0.039023, 0.038915, 0.038090, 0.037250, 0.036740, 0.037769, 0.041402, 0.044891, 0.046249, 0.047719, 0.047485, 0.043868, 0.041208, 0.040258, 0.038203, 0.036854, 0.038590, 0.042345, 0.046704, 0.051018, 0.054225, 0.056011, 0.055306, 0.051765, 0.048889, 0.047639, 0.045265, 0.041982, 0.039766, 0.039164, 0.040329, 0.041646, 0.040601, 0.038421, 0.038041, 0.040099, 0.043416, 0.045624, 0.045587, 0.044217, 0.041518, 0.037814, 0.034922, 0.034040, 0.035192, 0.037202, 0.037839, 0.036428, 0.034623, 0.033542, 0.033180, 0.033813, 0.035048, 0.035774, 0.035686, 0.035161, 0.035151, 0.036544, 0.038946, 0.041656, 0.044016, 0.044741, 0.043257, 0.040598, 0.037629, 0.034247, 0.030704, 0.027901, 0.026428, 0.026118, 0.026268, 0.026432, 0.026935, 0.028031, 0.029181, 0.029916, 0.030606, 0.031808, 0.033413, 0.034719, 0.035323, 0.035667, 0.036555, 0.038358, 0.040499, 0.041665, 0.040964, 0.038814, 0.036577, 0.035413, 0.035401, 0.035781, 0.035906, 0.035728, 0.035419, 0.035018, 0.034777, 0.035290, 0.036867, 0.039104, 0.041035, 0.041728, 0.040942, 0.039131, 0.036866, 0.034574, 0.032641, 0.031322, 0.030656, 0.030638, 0.031269, 0.032280, 0.033015, 0.032851, 0.031747, 0.030199, 0.028686, 0.027369, 0.026277, 0.025466, 0.024976, 0.024784, 0.024819, 0.025066, 0.025567, 0.026282, 0.027044, 0.027693, 0.028190, 0.028643, 0.029209, 0.029924, 0.030624, 0.031062, 0.031074, 0.030641, 0.029891, 0.029068, 0.028405, 0.027971, 0.027679, 0.027449, 0.027290, 0.027220, 0.027269, 0.027572, 0.028321, 0.029558, 0.031019, 0.032250, 0.032907, 0.032965, 0.032650, 0.032238, 0.031929, 0.031827, 0.031974, 0.032328, 0.032739, 0.033040, 0.033203, 0.033335, 0.033535, 0.033771, 0.033903, 0.033839, 0.033647, 0.033511, 0.033544, 0.033672, 0.033704, 0.033482, 0.032924, 0.032004, 0.030756, 0.029312, 0.027889, 0.026712, 0.025899, 0.025435, 0.025238, 0.025219, 0.025316, 0.025513, 0.025834, 0.026287, 0.026815, 0.027330, 0.027770, 0.028116, 0.028386, 0.028615, 0.028858, 0.029205, 0.029761, 0.030569, 0.031521, 0.032384, 0.032973, 0.033294, 0.033495, 0.033678, 0.033795, 0.033721, 0.033415, 0.032985, 0.032645, 0.032588, 0.032901, 0.033573, 0.034425, 0.035049, 0.035113, 0.034639, 0.033805, 0.032828, 0.032025, 0.031637, 0.031592, 0.031997
giStringSection48  ftgen  48, 0, 65536, 10, 14.112935, 11.294751, 26.417093, 5.755745, 19.553836, 15.327083, 7.934223, 4.325277, 7.948897, 7.251436, 5.541975, 4.570479, 2.388294, 2.865898, 0.949495, 0.826816, 1.261260, 1.546291, 1.122400, 1.273343, 0.935073, 1.081579, 1.245707, 0.529773, 0.883728, 0.291597, 0.657067, 0.412778, 0.428501, 0.343339, 0.323448, 0.285896, 0.166765, 0.121543, 0.197050, 0.142014, 0.117723, 0.126806, 0.131817, 0.136595, 0.191827, 0.172796, 0.130837, 0.118656, 0.098596, 0.074893, 0.066748, 0.076265, 0.067978, 0.058319, 0.054924, 0.064300, 0.078633, 0.092705, 0.094609, 0.094255, 0.105720, 0.114809, 0.091596, 0.070714, 0.070934, 0.060388, 0.044726, 0.044032, 0.039182, 0.041731, 0.049125, 0.045857, 0.038863, 0.039664, 0.042954, 0.049135, 0.053464, 0.050359, 0.048066, 0.042325, 0.037394, 0.042337, 0.051550, 0.044955, 0.036027, 0.034756, 0.038531, 0.039533, 0.035626, 0.033773, 0.030716, 0.029078, 0.027329, 0.025863, 0.025299, 0.026704, 0.034732, 0.041772, 0.039615, 0.036013, 0.035797, 0.033666, 0.030549, 0.028660, 0.029482, 0.030377, 0.030031, 0.029423, 0.029364, 0.029983, 0.032074, 0.032719, 0.030422, 0.027983, 0.024912, 0.022224, 0.021293, 0.021419, 0.021118, 0.020210, 0.019046, 0.018481, 0.019569, 0.020993, 0.021222, 0.020428, 0.019192, 0.018602, 0.018290, 0.017571, 0.016692, 0.016166, 0.016091, 0.016377, 0.016948, 0.017415, 0.017891, 0.018591, 0.019396, 0.019471, 0.019147, 0.019489, 0.019670, 0.018782, 0.017525, 0.016742, 0.015950, 0.015039, 0.014546, 0.014348, 0.014310, 0.014539, 0.014666, 0.014241, 0.013354, 0.012572, 0.012533, 0.013080, 0.013381, 0.013198, 0.013138, 0.013552, 0.014326, 0.015176, 0.015670, 0.015442, 0.014684, 0.014289, 0.014660, 0.015089, 0.015396, 0.015039
giStringSection60  ftgen  60, 0, 65536, 10, 207.142340, 1329.937681, 641.069207, 98.795060, 147.439154, 256.929750, 212.764754, 147.051325, 61.572042, 52.694461, 59.564573, 27.829335, 37.305480, 12.027510, 16.384227, 11.756278, 11.579963, 10.914767, 11.900922, 7.859484, 5.722406, 4.164328, 4.547687, 4.027512, 2.095750, 2.500462, 2.950312, 2.191272, 2.377904, 2.175046, 1.688686, 1.562402, 1.452011, 1.351652, 1.541214, 1.508621, 1.501072, 1.277432, 1.261024, 0.925851, 0.937407, 1.041417, 1.018895, 1.136376, 1.045808, 1.028317, 0.794736, 0.806356, 0.782066, 0.751306, 0.860972, 1.109061, 0.789907, 0.787447, 0.872666, 0.900172, 0.972758, 0.850144, 0.740224, 0.698245, 0.661610, 0.550993, 0.468677, 0.406357, 0.383261, 0.387746, 0.363662, 0.366338, 0.325886, 0.285383, 0.278626, 0.260574, 0.248863, 0.230159, 0.199282, 0.199478, 0.199792, 0.188532, 0.168679, 0.190065, 0.203526, 0.196295, 0.188554, 0.188501
giStringSection72  ftgen  72, 0, 65536, 10, 1108.035097, 380.506416, 162.288046, 378.473154, 243.330505, 206.851671, 95.355147, 49.194360, 49.827507, 38.553534, 22.000828, 20.521920, 12.695001, 13.073174, 17.747011, 12.769786, 7.858297, 19.676281, 12.703065, 7.171544, 5.276932, 5.460653, 5.390493, 3.095977, 3.215899, 2.389136, 2.296697, 1.289567, 1.253008, 1.337134, 1.264146, 1.209476, 1.118222, 1.090838, 0.659161, 0.626055, 0.639987, 0.593445, 0.473549, 0.367482, 0.331189, 0.309206
giStringSection84  ftgen  84, 0, 65536, 10, 513.297009, 802.352297, 1134.859056, 180.498678, 113.116284, 74.812644, 97.690462, 79.295265, 44.061914, 33.048600, 37.771618, 26.071948, 32.080673, 37.826529, 14.753414, 11.479540, 10.067027, 15.973492, 6.665999, 2.181464, 1.375999
giStringSection96  ftgen  96, 0, 65536, 10, 1231.456645, 751.589062, 474.040974, 631.975459, 211.071946, 99.866869, 31.400679, 39.346458, 8.703317, 4.921958

; map MIDI notes to wavetables
giKeyMap           ftgen  0, 0, 128, -17, 0,24, 30,36, 42,48, 54,60, 66,72, 78,84, 90,96 

gicos              ftgen  0, 0, 4096, 11 ,1  ; cosine wave, used by the LFOs

gaSendL,gaSendR    init   0 ; reverb send variable

initc7 1,1,1 ; mod wheel initialisation (init to maximum)

instr   1
; MIDI input
iCPS        cpsmidi                                                            ; read in MIDI as a frequency in cycles per second
iNote       notnum                                                             ; read in MIDI note number
iVel        ampmidi 1                                                          ; read in MIDI key velocity
kModWhl     ctrl7   1,1,0,1 ; mod wheel
kPchBnd     pchbend 0, 2    ; pitch bend wheel (semitones)

; SUSTAIN TONE
iAtt        =                 (1-iVel) * cabbageGetValue:i("Att")              ; attack time is an inversion of key velocity
iNVoices    cabbageGetValue   "NVoice"                                         ; number of voices in the oscbnk cluster
kfmd        linseg            0.000001, iAtt*2, 0.01                           ; amount of frequency modulation in each 
kDepth      cabbageGetValue   "Depth" ;ctrl7   1, 1, 0.005, 1                  ; envelope that controls the depth of random frequency variations in the oscbnk oscillators
kfmd        *=                kDepth * kModWhl                                 ; random frequency variations in the oscbank oscillators is also controlled by the modulation wheel MIDI control 
kmvt        cabbageGetValue   "Movement"                                       ; rate of modulations
iFn         table             iNote, giKeyMap                                  ; choose an appropriate function table from the keygroup map 
aSusL       oscbnk            iCPS*semitone(kPchBnd), 0, kfmd * iCPS, 0, iNVoices, 0, kmvt, kmvt, 0, 0, 238, 0, 8000, 1, 1, 1, 1, -1, iFn, gicos, gicos, gicos, gicos, gicos
if iNVoices==1 then
 aSusR      =                 aSusL
else
 aSusR      oscbnk            iCPS*semitone(kPchBnd), 0, kfmd * iCPS, 0, iNVoices, 0, kmvt, kmvt, 0, 0, 238, 0, 8000, 1, 1, 1, 1, -1, iFn, gicos, gicos, gicos, gicos, gicos
endif

; ENVELOPE
iKybdScl    =                 iNote/60                            ; keyboard scaling ratio (middle C is unison value) 
iDec        cabbageGetValue   "Dec"
iDec        /=                iKybdScl
iSus        cabbageGetValue   "Sus"
iRel        cabbageGetValue   "Rel"    
iRel        /=                iKybdScl
iAtt        /=                iKybdScl
aEnv        cossegr           0, iAtt, 1, iDec, iSus, iRel, 0                 ; amplitude envelope
kLevel      cabbageGetValue   "Level"
aSusL       *=                (aEnv * kLevel) / (iNVoices ^ 0.5)  ; the amplitude of the outputs of oscbnk need to be scaled down to prevert amps out of range (distortion)
aSusR       *=                (aEnv * kLevel) / (iNVoices ^ 0.5)                                             

; tone on sus
kCF         cabbageGetValue  "Brightness"
aSusL       tone             aSusL, a(cpsoct(kCF *  kModWhl * k(aEnv)))                                      ; lowpass filter both channels ('tone' is a subtle 6dB/oct filter)
aSusR       tone             aSusR, a(cpsoct(kCF *  kModWhl * k(aEnv)))
;aSusL       butlp             aSusL, a(cpsoct(kCF *  kModWhl * k(aEnv))))                                      ; lowpass filter both channels ('tone' is a subtle 6dB/oct filter)
;aSusR       butlp             aSusR, a(cpsoct(kCF *  kModWhl * k(aEnv))))

; BOW NOISE
iBAmp       limit             (1 - iAtt) ^ 3, 0, 1
kBEnv       expseg            0.01,0.02,1,0.1,0.01
aBowL       dust              kBEnv * iBAmp,400
aBowR       dust              kBEnv * iBAmp,400
aBowL       buthp             aBowL,iCPS
aBowR       buthp             aBowR,iCPS
aBowL       reson             aBowL,iCPS*2,iCPS*4,1
aBowR       reson             aBowR,iCPS*2,iCPS*4,1
kFB         expseg            0.5,0.05,0.85,1,0.85
aBowL       streson           aBowL*20,iCPS,kFB
aBowR       streson           aBowR*20,iCPS,kFB
aBowL       reson             aBowL,iCPS*2,iCPS*4,1
aBowR       reson             aBowR,iCPS*2,iCPS*4,1
aRel        expsegr           1, cabbageGetValue:i("Rel"), 0.001
aBowL       *=                aRel
aBowR       *=                aRel

; tone on bow noise
kCF         cabbageGetValue  "Brightness"
aBowL       tone             aBowL, a(cpsoct(kCF *  kModWhl))                ; lowpass filter both channels ('tone' is a subtle 6dB/oct filter)
aBowR       tone             aBowR, a(cpsoct(kCF *  kModWhl))
;aBowL       butlp            aBowL, a(cpsoct(kCF *  kModWhl))                ; lowpass filter both channels ('tone' is a subtle 6dB/oct filter)
;aBowR       butlp            aBowR, a(cpsoct(kCF *  kModWhl))


; mixer
kSusLev     cabbageGetValue   "SusLev"
kBowLev     cabbageGetValue   "BowLev"
aSigL       =                 (aSusL * kSusLev) + (aBowL * kBowLev)
aSigR       =                 (aSusR * kSusLev) + (aBowR * kBowLev)
            outs             aSigL , aSigR


; reverb
kSend       cabbageGetValue  "Send"
gaSendL     +=               aSigL * kSend
gaSendR     +=               aSigR * kSend

endin


instr 99 ; reverb (always on)
aRvbL,aRvbR reverbsc       gaSendL,gaSendR, cabbageGetValue:k("Size"), cabbageGetValue:k("Damp")
            outs           aRvbL,aRvbR
            clear          gaSendL,gaSendR
endin


</CsInstruments>

<CsScore>
;causes Csound to run for about 7000 years...
f 0 z
i 99 0 3600
</CsScore>

</CsoundSynthesizer>
