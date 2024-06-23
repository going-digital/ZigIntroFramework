const std = @import("std");
const getProcAddress = @import("win32").graphics.open_gl.wglGetProcAddress;

// Implement OpenGL calls as a wrapped glGetProcAddress

// From https://registry.khronos.org/OpenGL/api/GL/glcorearb.h
pub const TEXTURE_2D = 0x0DE1;
pub const LINEAR = 0x2601;
pub const LINEAR_MIPMAP_LINEAR = 0x2703;
pub const TEXTURE_MIN_FILTER = 0x2801;
pub const RGBA8 = 0x8058;
pub const FRAGMENT_SHADER = 0x8B30;

pub fn activeTexture(texture: c_int) void {
    @as(*const fn (texture: c_int) callconv(std.os.windows.WINAPI) void, @ptrCast(getProcAddress("glActiveTexture")))(texture);
}

pub fn createShaderProgramv(@"type": c_int, count: c_int, strings: [*]const []const u8) c_uint {
    return @as(*const fn (@"type": c_int, count: c_int, strings: [*]const []const u8) callconv(std.os.windows.WINAPI) c_uint, @ptrCast(getProcAddress("glCreateShaderProgramv")))(@"type", count, strings);
}

pub fn generateMipmap(target: c_int) void {
    @as(*const fn (target: c_int) callconv(std.os.windows.WINAPI) void, @ptrCast(getProcAddress("glGenerateMipmap")))(target);
}

pub fn uniform1i(location: c_int, v0: i32) void {
    @as(*const fn (location: c_int, v0: i32) callconv(std.os.windows.WINAPI) void, @ptrCast(getProcAddress("glUniform1i")))(location, v0);
}

pub fn useProgram(program: c_uint) void {
    @as(*const fn (program: c_uint) callconv(std.os.windows.WINAPI) void, @ptrCast(getProcAddress("glUseProgram")))(program);
}
