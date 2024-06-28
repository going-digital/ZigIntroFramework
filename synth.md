# Synth design

The synth concept is to execute a series of routines, with a series of
parameters. These will synthesise samples, add effects and build soundtrack
in memory.

Concept is that initially samples are constructed. These are built into
pattern loops. These are then built into a stereo soundtrack in memory.


## Phasor

* Input: frequency, in 16.16 midi pitch form
* Output: phase, in 0.32 pitch

This function performs logarithmic frequency mapping.

## Sine

* Input: phase, in 0.32 pitch
* Output: amplitude, in signed 24 bit form

## Saw

* Input: phase, in 0.32 form
* Output: amplitude, in signed 24 bit form

## Tri

* Input: phase, in 0.32 form
* Output: amplitude, in signed 24 bit form

## Noise

* Output: amplitude, in signed 24 bit form

## Add

* Input buffer pointer: source samples in 24 bit form
* Output: 