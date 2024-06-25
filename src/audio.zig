const std = @import("std");
const win32 = @import("win32");
const media = win32.media;
const audio = media.audio;
const threading = win32.system.threading;
const tinymath = @import("tinymath.zig");

const sampleType = i16; // Could be i16 or f32
const SAMPLE_RATE = 44100;
pub const MAX_SAMPLES = SAMPLE_RATE * 5; // 5 seconds
const CHANNELS = 2; // Stereo

var hWaveOut: ?audio.HWAVEOUT = undefined;

var lpSoundBuffer: [MAX_SAMPLES * CHANNELS]sampleType = undefined;

var waveHdr: audio.WAVEHDR = .{
    .lpData = @as(?[*]u8, @ptrCast(&lpSoundBuffer)),
    .dwBufferLength = MAX_SAMPLES * @sizeOf(sampleType) * CHANNELS,
    .dwBytesRecorded = 0,
    .dwUser = 0,
    .dwFlags = 0,
    .dwLoops = 0,
    .lpNext = null,
    .reserved = 0,
};

pub fn init() void {
    _ = threading.CreateThread(
        null,
        0,
        @as(threading.LPTHREAD_START_ROUTINE, @ptrCast(&audio_render)),
        @as(?*anyopaque, @ptrCast(&lpSoundBuffer)),
        .{},
        null,
    );
    var wavefmt = audio.WAVEFORMATEX{
        .wFormatTag = switch (sampleType) {
            i16 => audio.WAVE_FORMAT_PCM,
            f32 => media.WAVE_FORMAT_IEEE_FLOAT,
            else => unreachable, // sampleType must be i16 or f32
        },
        .nChannels = CHANNELS,
        .nSamplesPerSec = SAMPLE_RATE,
        .nAvgBytesPerSec = SAMPLE_RATE * @sizeOf(sampleType) * CHANNELS,
        .nBlockAlign = @sizeOf(sampleType) * CHANNELS,
        .wBitsPerSample = @sizeOf(sampleType) * 8,
        .cbSize = 0,
    };
    _ = audio.waveOutOpen(
        &hWaveOut,
        audio.WAVE_MAPPER,
        &wavefmt,
        0,
        0,
        .{},
    );
    _ = audio.waveOutPrepareHeader(
        hWaveOut,
        &waveHdr,
        @sizeOf(audio.WAVEHDR),
    );
    _ = audio.waveOutWrite(
        hWaveOut,
        &waveHdr,
        @sizeOf(audio.WAVEHDR),
    );
}

var mmTime: media.MMTIME = undefined;

pub fn get_position() u32 {
    mmTime.wType = media.TIME_SAMPLES;
    _ = audio.waveOutGetPosition(
        hWaveOut,
        &mmTime,
        @sizeOf(media.MMTIME),
    );
    return mmTime.u.sample;
}

fn audio_render() callconv(std.os.windows.WINAPI) void {
    const twopi = tinymath.twopi;
    const tone_freq = 1000;
    // Placeholder soundroutine - render a tone
    for (0..MAX_SAMPLES) |i| {
        const value: i16 = @intFromFloat(4095 *
            tinymath.sin(@as(f32, @floatFromInt(i)) * twopi * tone_freq / SAMPLE_RATE));
        lpSoundBuffer[CHANNELS * i] = value;
        lpSoundBuffer[CHANNELS * i + 1] = value;
    }
}
