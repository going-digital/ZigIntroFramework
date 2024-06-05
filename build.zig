// Useful resource: https://ikrima.dev/dev-notes/zig/zig-build/

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86,
        .os_tag = .windows,
        .cpu_model = .{ .explicit = std.Target.x86.cpu.x86_64_v3 },
    });

    // Pack shader
    const pack_shader = b.addSystemCommand(&.{ "tools\\shader_minifier", "-o src\\packed.frag", "-v", "--format text", "src\\fragment.frag" });

    // Build zig
    const build_obj = b.addObject(.{
        .name = "test",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .single_threaded = true,
        .optimize = .ReleaseSmall,
    });
    build_obj.step.dependOn(pack_shader);
    // Link
    const link = b.addSystemCommand(&.{ "tools\\crinkler", "/out:bin\\test.exe", "/subsystem:windows", "/print:imports", "/print:labels", "/range:opengl32", "/compmode:slow", "/ordertries:1000", "tmp\\main.obj", "kernel32.lib", "user32.lib", "gdi32.lib", "opengl32.lib", "winmm.lib", "/report:bin\\test.html" });
    link.step.dependOn(build_obj);

    b.getInstallStep().dependOn(link.step);

    // Clean up build files
    const run_cmd = b.addSystemCommand(&.{"bin\\test.exe"});
    const run_step = b.step("run", "Run the intro");
    run_step.dependOn(&run_cmd.step);
}
