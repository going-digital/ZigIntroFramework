const std = @import("std");
const builtin = @import("builtin");

pub const twopi = std.math.pi * 2;
pub const halfpi = std.math.pi / 2;

///**Calculate sine** of angle in radians.
///Size optimised version available for x87 fpu on x86 systems.
pub fn sinf(a: f32) f32 {
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

///**Calculate cosine** of angle in radians.
///Piggybacked from sin function.
pub fn cosf(a: f32) f32 {
    return sinf(a + halfpi);
}

///**Calculate 2 to power of x**
///Size optimised version available for x87 fpu on x86 systems.
pub fn pow2f(a: f32) f32 {
    if (std.Target.x86.featureSetHas(builtin.cpu.features, .x87)) {
        var result: f32 = undefined;
        asm volatile (
            \\fld st
            \\frndint
            \\fsub st(1),st
            \\fxch st(1)
            \\f2xm1
            \\fld1
            \\fadd
            \\fscale
            \\fstp st(1)
            : [ret] "={st}" (result),
            : [a] "{st}" (a),
        );
        return result;
    } else {
        // Revert to standard libary
        return std.math.exp2(a);
    }
}
