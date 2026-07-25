
/* Attribution-NonCommercial-ShareAlike 4.0 International
Attribution - You must give appropriate credit, provide a link to the license, and indicate if changes were made. You may do so in any reasonable manner, but not in any way that suggests the licensor endorses you or your use.
NonCommercial - You may not use the material for commercial purposes.
ShareAlike - If you remix, transform, or build upon the material, you must distribute your contributions under the same license as the original.
https://creativecommons.org/licenses/by-nc-sa/4.0/legalcode */

; ChorusEnsemble.csd
; Written by Iain McCurdy, 2026.

; Creates a cluster of randomly modulating voices from a single voice. 
; The number of voices (layers) in the output cluster is user definable.
; The parameters that can be modulated are:
; Chorus (short moving delays)
; Time offset (long static delays)
; Amplitude
; Tone (low-pass filter)
; Panning (width

; Input      -  choose input from 1) Mono, 2) Stereo, 3)Test Tone (sawtooth)
; In Gain    -  gain control on the input signal
; Rate       -  rate of the modulating LFO in hertz
; Depth      -  depth of LFO modulation
; Voices     -  number of voices
; Offset     -  random delay offset calculated on a voice-by-voice basis
; Width      -  width of LFO modulation
; Amp. Mod.  -  random amplitude modulation calculated on a voice-by-voice basis. Rate according to the main 'Rate' control.
; Tone. Mod. -  random tone (low-pass filter) modulation calculated on a voice-by-voice basis. Rate according to the main 'Rate' control.
; Mix        -  dry/wet mix
; Level      -  amplitude of the output 

<Cabbage>
form caption("Chorus Ensemble") size(870, 110), pluginId("scho"), guiMode("queue")
image                   bounds(0, 0, 870, 110), colour(90,80,80), shape("rounded"), outlineColour("white"), outlineThickness(6)

#define SLIDER_STYLE  textColour("white"), fontColour("white"), colour(60,50,50), trackerColour("Silver"), valueTextBox(1)

label    bounds( 10, 15, 85, 16), text("I N P U T"), align("centre"), fontColour("lightGrey")
combobox bounds( 10, 32, 85, 23), channel("input"), items("MONO","STEREO","TEST"), value(2), align("centre"), fontColour("white")

rslider  bounds(100, 10, 80, 90), text("In Gain"), channel("InGain"), range(0, 1, 1,0.5), $SLIDER_STYLE
rslider  bounds(175, 10, 80, 90), text("Rate"), channel("rate"), range(0.001, 50, 1,0.5), $SLIDER_STYLE
rslider  bounds(250, 10, 80, 90), text("Depth"), channel("depth"), range(0, 1, 0.2), $SLIDER_STYLE
rslider  bounds(325, 10, 80, 90), text("Voices"), channel("NVoices"), range(1, 100, 8,1,1), $SLIDER_STYLE
rslider  bounds(400, 10, 80, 90), text("Offset"), channel("offset"), range(0,10,0.8,0.5), $SLIDER_STYLE
rslider  bounds(475, 10, 80, 90), text("Width"), channel("width"), range(0, 1.00, 1), $SLIDER_STYLE
rslider  bounds(550, 10, 80, 90), text("Amp. Mod."), channel("AmpMod"), range(0, 1.00, 0.5), $SLIDER_STYLE
rslider  bounds(625, 10, 80, 90), text("Tone. Mod."), channel("ToneMod"), range(0, 8.00, 2), $SLIDER_STYLE
rslider  bounds(700, 10, 80, 90), text("Mix"), channel("mix"), range(0, 1.00, 0.76), $SLIDER_STYLE
rslider  bounds(775, 10, 80, 90), text("Level"), channel("level"), range(0, 2.00, 0.3,0.5), $SLIDER_STYLE
label    bounds(  5, 95,120, 11), text("Iain McCurdy |2026|"), align("left"), fontColour("Silver")

</Cabbage>

<CsoundSynthesizer>

<CsOptions>
-d -n
</CsOptions>

<CsInstruments>
;sr set by host
ksmps  = 32
nchnls = 2
0dbfs  = 1

       seed 0
;Author: Iain McCurdy (2026)
;http://iainmccurdy.org/csound.html


opcode EnsembleChorus, aa, kakkkiip
krate, adepth, kwidth, kAmpMod, kToneMod, ioffset, iNVoices, iCount xin
 aDlt              rspline            0.1, 0.9, 0.1*krate, 0.2*krate
 aDlt              *=                 adepth
 aT                deltap3            aDlt
 aT                delay              aT, 1/kr + random:i(0,ioffset)
 if kAmpMod>0 then
  aT               *=                 ampdbfs(rspline:k(kAmpMod*6, -24*kAmpMod, 0.1*krate, 0.2*krate))
 endif
 if kToneMod>0 then
  kCF              rspline            13, 13-kToneMod, 0.1*krate, 0.2*krate
  aT               butlp              aT, a(cpsoct(kCF))
 endif
 aPan              jspline            kwidth * 0.45, 0.1 * krate, 0.2 * krate
 aL,aR             pan2               aT, 0.5 +aPan
 
 aMixL             =                  0
 aMixR             =                  0
 if iCount<iNVoices then
  aMixL,aMixR      EnsembleChorus     krate, adepth, kwidth, kAmpMod, kToneMod, ioffset, iNVoices, iCount+1
 endif
 
                   xout               aL + aMixL, aR + aMixR
endop

instr 1
 kporttime         linseg              0, 0.001, 0.05                                                     
 krate             cabbageGetValue     "rate"
 kdepth            cabbageGetValue     "depth"
 kdepth            portk               kdepth, kporttime
 koffset           cabbageGetValue     "offset"
 kAmpMod           cabbageGetValue     "AmpMod"
 kToneMod          cabbageGetValue     "ToneMod"
 kwidth            cabbageGetValue     "width"
 klevel            cabbageGetValue     "level"
 kmix              cabbageGetValue     "mix"
 kmix              portk               kmix, kporttime
 klevel            portk               klevel, kporttime

 ; inputs
 kinput            cabbageGetValue     "input"
 kInGain           cabbageGetValue     "InGain"
 aL,aR             init                0
 if kinput==1 then     ; mono
  aL               inch                1
  aL               *=                  kInGain
 elseif kinput==2 then ; stereo
  aL,aR            ins
  aL               *=                  kInGain
  aR               *=                  kInGain
 else                  ; sawtooth wave
  aL               vco2                0.5,150
  aL               *=                  kInGain
 endif

 iMaxDel           =                   1
 kNVoices          cabbageGetValue     "NVoices"
 kNVoices          init                1
 koffset           cabbageGetValue     "offset"
 if changed:k(kNVoices,koffset,kinput)==1 then
  reinit RESTART
 endif
 RESTART:
 aRise             cosseg              0, 1, 1 ; soft attack at start-up and re-inits
 aL                *=                  aRise
 aBuf              delayr              iMaxDel
 aChL,aChR         EnsembleChorus      krate, a(kdepth), kwidth, kAmpMod, kToneMod, i(koffset), i(kNVoices)
                   delayw              aL
 if i(kinput)==2 then ; if stereo input
 aBuf              delayr              iMaxDel
  aR                *=                  aRise
  aCh2L,aCh2R      EnsembleChorus      krate, a(kdepth), kwidth, kAmpMod, kToneMod, i(koffset), i(kNVoices)
                   delayw              aR
  aChL             +=                  aCh2L
  aChR             +=                  aCh2R
 endif

 ; dry/wet mix
 if  i(kinput)==2 then ; if stereo input
  aMixL            ntrpol              aL, aChL / (i(kNVoices) ^ 0.667), kmix
  aMixR            ntrpol              aR, aChR / (i(kNVoices) ^ 0.667), kmix
 else                  ; otherwise mono input
  aMixL            ntrpol              aL, aChL / (i(kNVoices) ^ 0.667), kmix
  aMixR            ntrpol              aL, aChR / (i(kNVoices) ^ 0.667), kmix
 endif
 rireturn

 ; output
                   outs                aMixL * klevel, aMixR * klevel
endin

</CsInstruments>

<CsScore>                                              
i 1 0 z
</CsScore>

</CsoundSynthesizer>                                                  