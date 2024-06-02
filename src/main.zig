const std = @import("std");
const win32 = @import("zigwin32//win32.zig");
const audio = @import("audio.zig");
const threading = win32.system.threading;
const gdi = win32.graphics.gdi;
const wm = win32.ui.windows_and_messaging;
const wgl = win32.graphics.open_gl;
const km = win32.ui.input.keyboard_and_mouse;
const gl = @import("gl.zig");

const XRES = 1920;
const YRES = 1080;

const frag_prog: [*]const []const u8 linksection(".shader") = &.{
    @embedFile("packed.frag"),
};

export fn WinMainCRTStartup() callconv(std.os.windows.WINAPI) noreturn {
    @setAlignStack(16);
    // Set display mode
    var screenSettings: gdi.DEVMODEA = .{
        .dmDeviceName = [_]u8{0} ** 32,
        .dmSpecVersion = 0,
        .dmDriverVersion = 0,
        .dmSize = @sizeOf(gdi.DEVMODEA),
        .dmDriverExtra = 0,
        .dmFields = gdi.DM_PELSWIDTH | gdi.DM_PELSHEIGHT,
        .Anonymous1 = .{ .Anonymous2 = .{
            .dmPosition = .{ .x = 0, .y = 0 },
            .dmDisplayOrientation = 0,
            .dmDisplayFixedOutput = 0,
        } },
        .dmColor = 0,
        .dmDuplex = 0,
        .dmYResolution = 0,
        .dmTTOption = 0,
        .dmCollate = 0,
        .dmFormName = [_]u8{0} ** 32,
        .dmLogPixels = 0,
        .dmBitsPerPel = 0,
        .dmPelsWidth = XRES,
        .dmPelsHeight = YRES,
        .Anonymous2 = .{
            .dmDisplayFlags = 0,
        },
        .dmDisplayFrequency = 0,
        .dmICMMethod = 0,
        .dmICMIntent = 0,
        .dmMediaType = 0,
        .dmDitherType = 0,
        .dmReserved1 = 0,
        .dmReserved2 = 0,
        .dmPanningWidth = 0,
        .dmPanningHeight = 0,
    };
    _ = gdi.ChangeDisplaySettingsA(&screenSettings, .{ .FULLSCREEN = 1 });
    _ = wm.ShowCursor(0);
    const hdc = gdi.GetDC(wm.CreateWindowExA(
        .{},
        @ptrFromInt(0xc018),
        // https://learn.microsoft.com/en-us/windows/win32/winmsg/about-window-classes#system-classes
        null,
        .{ .POPUP = 1, .VISIBLE = 1, .MAXIMIZE = 1 },
        0,
        0,
        XRES,
        YRES,
        null,
        null,
        null,
        null,
    ));
    const pfd = wgl.PIXELFORMATDESCRIPTOR{
        .nSize = @sizeOf(wgl.PIXELFORMATDESCRIPTOR),
        .nVersion = 1,
        .dwFlags = .{ .DRAW_TO_WINDOW = 1, .SUPPORT_OPENGL = 1, .DOUBLEBUFFER = 1 },
        .iPixelType = .RGBA,
        .cColorBits = 32,
        .cRedBits = 0,
        .cRedShift = 0,
        .cGreenBits = 0,
        .cGreenShift = 0,
        .cBlueBits = 0,
        .cBlueShift = 0,
        .cAlphaBits = 8,
        .cAlphaShift = 0,
        .cAccumBits = 0,
        .cAccumRedBits = 0,
        .cAccumGreenBits = 0,
        .cAccumBlueBits = 0,
        .cAccumAlphaBits = 0,
        .cDepthBits = 32,
        .cStencilBits = 0,
        .cAuxBuffers = 0,
        .iLayerType = .MAIN_PLANE,
        .bReserved = 0,
        .dwLayerMask = 0,
        .dwVisibleMask = 0,
        .dwDamageMask = 0,
    };
    _ = wgl.SetPixelFormat(hdc, wgl.ChoosePixelFormat(hdc, &pfd), &pfd);
    _ = wgl.wglMakeCurrent(hdc, wgl.wglCreateContext(hdc));
    const pidMain = gl.createShaderProgramv(gl.FRAGMENT_SHADER, 1, frag_prog);
    audio.init();

    while (true) {
        const audio_position: i32 = @intCast(audio.get_position());
        _ = wm.PeekMessageA(null, null, 0, 0, wm.PM_REMOVE);
        gl.useProgram(pidMain);
        gl.uniform1i(0, audio_position);
        wgl.glRects(-1, -1, 1, 1);
        _ = wgl.SwapBuffers(hdc);
        if ((km.GetAsyncKeyState(@intFromEnum(km.VK_ESCAPE)) != 0) or (audio_position == audio.MAX_SAMPLES)) {
            break;
        }
    }

    threading.ExitProcess(0);
}
