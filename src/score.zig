const std = @import("std");
const tinymath = @import("tinymath.zig");

fn phaseStepFromMidi(a: f32) f32 {
    // Convert midi note to phasor velocity
    const log2_midi_note_0_pitch = 0x3.080734; // log2(8.1758)
    const midi_note_to_octave = 0x0.1555556; // 1.0/12.0
    return tinymath.exp2(log2_midi_note_0_pitch + midi_note_to_octave * a);
}

test "MIDI pitch mapping" {
    // Midi pitch 0 = B-2 = 8.1758Hz
    try std.testing.expectApproxEqRel(phaseStepFromMidi(0), 8.1758 * 65536, 0.01);

    // Midi pitch 69 = A4 (A above middle C) = 440Hz
    try std.testing.expectApproxEqRel(phaseStepFromMidi(69), 440 * 65536, 0.01);

    // Midi pitch 127 = G9 = 12543.85Hz
    try std.testing.expectApproxEqRel(phaseStepFromMidi(127), 12543.85 * 65536, 0.01);
}
