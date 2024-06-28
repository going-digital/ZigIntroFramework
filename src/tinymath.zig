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

test "sin" {
    try std.testing.expectApproxEqRel(sin(0), @as(f32, @sin(@as(f32, 0))), 0.0001);
    try std.testing.expectApproxEqRel(sin(1), @as(f32, @sin(@as(f32, 1))), 0.0001);
    try std.testing.expectApproxEqRel(sin(2), @as(f32, @sin(@as(f32, 2))), 0.0001);
    try std.testing.expectApproxEqRel(sin(3), @as(f32, @sin(@as(f32, 3))), 0.0001);
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
            \\fld %st           // a, a
            \\frndint           // floor(a), a
            \\fxch              // a, floor(a)
            \\fsub %st(1),%st   // frac(a), floor(a)
            \\f2xm1             // exp2(frac(a))-1, floor(a)
            \\fld1              // 1, exp2(frac(a))-1, floor(a)
            \\faddp             // exp2(frac(a)), floor(a)
            \\fscale            // exp2(frac(a)) * exp2(floor(a)) = exp2(a), floor(a)
            \\fstp %st(1)       // exp2(a)
            : [ret] "={st}" (result),
            : [a] "{st}" (a),
        );
        return result;
    } else {
        // Revert to standard library
        return @exp2(a);
    }
}

test "exp2" {
    try std.testing.expectApproxEqRel(@exp2(@as(f32, 0)), exp2(0), 1e-6);
    try std.testing.expectApproxEqRel(@exp2(@as(f32, 123)), exp2(123), 1e-6);
    try std.testing.expectApproxEqRel(@exp2(@as(f32, 0.123)), exp2(0.123), 1e-6);
}
