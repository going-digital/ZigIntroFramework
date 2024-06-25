const std = @import("std");
const builtin = @import("builtin");

pub const twopi = std.math.pi * 2;
pub const halfpi = std.math.pi / 2;

/// Sine trigonometric function on a floating point number in radians.
///
/// Size optimised version available for x87 fpu on x86 systems.
///
/// Supports floats only, not vectors.
pub fn sin(a: f32) f32 {
    if (std.Target.x86.featureSetHas(builtin.cpu.features, .x87)) {
        var result: f32 = undefined;
        asm volatile (
            \\fsin
            : [ret] "={st}" (result),
            : [a] "{st}" (a),
        );
        return result;
    } else {
        // Revert to standard libary
        return @sin(a);
    }
}

/// Calculate cosine of angle in radians.
///
/// Piggybacked from sin function.
pub fn cos(a: f32) f32 {
    return sin(a + halfpi);
}

/// Base-2 exponential function on a floating point number.
///
/// Size optimised version available for x87 fpu on x86 systems.
///
/// Supports floats only.
pub fn exp2(a: f32) f32 {
    if (std.Target.x86.featureSetHas(builtin.cpu.features, .x87)) {
        var result: f32 = undefined;
        asm volatile (
            \\fld st         ; a, a
            \\frndint        ; int(a), a
            \\fsub st(1),st  ; int(a), frac(a)
            \\fxch st(1)     ; frac(a), int(a)
            \\f2xm1          ; pow(2, frac(a))-1, int(a)
            \\fld1           ; 1, pow(2, frac(a))-1, int(a)
            \\fadd           ; pow(2, frac(a)), int(a)
            \\fscale         ; pow(2, a), int(a)
            \\fstp st(1)     ; pow(2, a)
            : [ret] "={st}" (result),
            : [a] "{st}" (a),
        );
        return result;
    } else {
        // Revert to standard libary
        return @exp2(a);
    }
}
