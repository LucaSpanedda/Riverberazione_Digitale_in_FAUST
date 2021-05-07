// FAUST standard library
import("stdfaust.lib");

//-LUCA-SPANEDDA-DIGITAL-REVERBS-LIBRARY----------------------------------------
//------------------------------------------------------------------------------


//-UTILITIES--------------------------------------------------------------------
//
//------------------------------------------------------------------------------
// CONVERSION MILLISECONDS TO SAMPLES
//------------------------------------------------------------------------------
// (t) = give time in milliseconds we want to know in samples
msasamps(t) = (ma.SR / 1000.) * t;
//
//
//------------------------------------------------------------------------------
// CONVERSION SAMPLES TO MILLISECONDS
//------------------------------------------------------------------------------
// (samps) = give tot. samples we want to know in milliseconds
sampsams(samps) = ((1000 / ma.SR) * samps);
//
//
//------------------------------------------------------------------------------
// T60 DECAY TIME
//------------------------------------------------------------------------------
// (samps,seconds) = give: samples of the filter, seconds we want for t60 decay
dect60(samps,seconds) = 1/(10^((3*(((1000 / 44100)*samps)/1000))/seconds));
//
//
//------------------------------------------------------------------------------
// DIRAC IMPULSE (1 SAMPLE IMPULSE)
//------------------------------------------------------------------------------
dirac = 1-(1:mem)
//
//
//------------------------------------------------------------------------------
// SOUND TO THE WALL AND BACK TIME
//------------------------------------------------------------------------------
// (meters) = give a distance in meters for samples of the filter
wall(meters) = ((ma.SR/1000.)*((1000*meters)/343.1)*2);
//
//


//-FILTERS----------------------------------------------------------------------
//
//------------------------------------------------------------------------------
// ONEZERO FILTER (FIR of I° Order)
//------------------------------------------------------------------------------
// (g) = give amplitude 0-1(open-close) to the delayed signal
ozf(g) = _<:(mem*g), _ :> +;
//
//
//------------------------------------------------------------------------------
// ONEPOLE FILTER (IIR of I° Order)
//------------------------------------------------------------------------------
// (g) = give amplitude 1-0(open-close) for the lowpass cut
opf(g) = _*g : +~(_ : *(1- g));
//
//
//------------------------------------------------------------------------------
// FEEDFORWARD COMB FILTER (FIR of N° Order)
//------------------------------------------------------------------------------
// (t,g) = delay time in samples, filter gain 0-1
ffcf(t,g) = _ <: ( _@(t-1) *g), _ :> _;
//
//
//------------------------------------------------------------------------------
// FEEDBACK COMB FILTER (IIR of N° Order)
//------------------------------------------------------------------------------
// (t,g) = give: delay time in samples, feedback gain 0-1
fbcf(t,g) = _ : (+  @(t-1)~ *(g)) : mem;
//
//
//------------------------------------------------------------------------------
// LOWPASS FEEDBACK COMB FILTER (IIR of N° Order)
//------------------------------------------------------------------------------
// (t,g,cut) = give: delay samps, feedback gain 0-1, lowpass cut 1-0(open-close)
lfbcf(t,g,cut) = (+ : @(t-1) : _*cut : +~(_ : *(1-cut)))~ *(g) : mem;
//
//
//------------------------------------------------------------------------------
// ALLPASS FILTER (FIR + IIR COMB FILTER)
//------------------------------------------------------------------------------
// (t,g) = give: delay in samples, feedback gain 0-1
apf(t,g) = (+: _<: @(t-1), *(g))~ *(-g) : mem, _ : + : _;
//
//


//-REVERBERATORS----------------------------------------------------------------
//
//------------------------------------------------------------------------------
// CHAMBERLIN REVERB
//
// High-quality stereo reverberator:
// Musical Applications of Microprocessor
//------------------------------------------------------------------------------
//
// allpass chamberlin
// (t,g) = give: delay in samples, feedback gain 0-1
apfch(t,g) = (+: _<: @(min(max(t-1,0),ma.SR)), *(-g))~ *(g) : mem, _ : + : _;
//
// chamberlin reverb
ap3ch = apfch(msasamps(49.6),0.75) : 
apfch(msasamps(34.75),0.72) : apfch(msasamps(24.18),0.691);
apout1ch = apfch(msasamps(17.85),0.649) : apfch(msasamps(10.98),0.662);
apout2ch = apfch(msasamps(18.01),0.646) : apfch(msasamps(10.82),0.666);
chamberlinverb = ap3ch <: apout1ch, apout2ch;
//
//
