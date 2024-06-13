// Useful resource: https://ikrima.dev/dev-notes/zig/zig-build/

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86,
        .os_tag = .windows,
        .cpu_model = .{ .explicit = &std.Target.x86.cpu.x86_64_v3 },
    });

    // Pack shader
    const minify = b.addSystemCommand(&.{"tools\\shader_minifier"});
    _ = minify.addArgs(&.{ "-v", "--format", "text", "-o" });
    // TODO: Writing to the src directory it nasty. Find a way to move packed.frag to the cache directory, but still allow main.zig to include it.
    _ = minify.addFileArg(b.path("src/packed.frag"));
    _ = minify.addFileArg(b.path("src/fragment.frag"));

    // Build zig
    const build_obj = b.addObject(.{
        .name = "test",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .single_threaded = true,
        .optimize = .ReleaseSmall,
    });
    build_obj.step.dependOn(&minify.step);

    // Link
    // TODO: This step fails. Plenty to fix.
    const link = b.addSystemCommand(&.{"tools\\crinkler"});
    _ = link.addArg("/out:");
    _ = link.addArg("/out:bin\\test.exe"); // TODO: Move to build directory correctly
    _ = link.addArg("/subsystem:windows");
    _ = link.addArg("/print:imports");
    _ = link.addArg("/print:labels");
    _ = link.addArg("/range:opengl32");
    _ = link.addArg("/compmode:slow");
    _ = link.addArg("/ordertries:1000");
    _ = link.addArg("tmp\\main.obj"); // TODO: Reference cache files correctly
    _ = link.addArg("kernel32.lib");
    _ = link.addArg("user32.lib");
    _ = link.addArg("gdi32.lib");
    _ = link.addArg("opengl32.lib");
    _ = link.addArg("winmm.lib");
    _ = link.addArg("/report:bin\\test.html"); // TODO: Reference output directory correctly
    link.step.dependOn(&build_obj.step);

    b.getInstallStep().dependOn(&link.step);

    const run_cmd = b.addSystemCommand(&.{"bin\\test.exe"}); // TODO: Reference output directory correctly
    const run_step = b.step("run", "Run the intro");
    run_step.dependOn(&run_cmd.step);
}
