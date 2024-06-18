// Useful resource: https://ikrima.dev/dev-notes/zig/zig-build/

const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86,
        .os_tag = .windows,
        .cpu_model = .{ .explicit = &std.Target.x86.cpu.x86_64_v3 },
    });

    const optimize = b.standardOptimizeOption(.{});

    // Pack shader
    const minify = b.addSystemCommand(&.{"tools\\shader_minifier"});
    minify.addArgs(&.{ "-v", "--format", "text", "-o" });
    // TODO: Writing to the src directory it nasty. Find a way to move packed.frag to the cache directory, but still allow main.zig to include it.
    minify.addFileArg(b.path("src/packed.frag"));
    minify.addFileArg(b.path("src/fragment.frag"));

    // Build zig
    if (optimize == .ReleaseSmall) {
        // Use Crinkler for the small build

        const build_obj = b.addObject(.{
            .name = "main",
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .single_threaded = true,
            .optimize = .ReleaseSmall,
        });
        build_obj.step.dependOn(&minify.step);
        // Link
        const link = b.addSystemCommand(&.{"tools\\crinkler"});
        _ = link.addPrefixedOutputFileArg("/out:", "test.exe");
        link.addArg("/subsystem:windows");
        link.addArg("/print:imports");
        link.addArg("/print:labels");
        link.addArg("/range:opengl32");
        link.addArg("/compmode:slow");
        link.addArg("/ordertries:1000");
        link.addPrefixedDirectoryArg("/libpath:", b.path("lib"));
        link.addArtifactArg(build_obj);
        link.addArg("kernel32.lib");
        link.addArg("user32.lib");
        link.addArg("gdi32.lib");
        link.addArg("opengl32.lib");
        link.addArg("winmm.lib");
        _ = link.addPrefixedOutputFileArg("/report:", "test.html");
        b.getInstallStep().dependOn(&link.step);
    } else {
        const build_exe = b.addExecutable(.{
            .name = "main",
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .single_threaded = true,
            .optimize = optimize,
        });
        build_exe.step.dependOn(&minify.step);
        b.installArtifact(build_exe);
    }

    const run_cmd = b.addSystemCommand(&.{"bin\\test.exe"});
    const run_step = b.step("run", "Run the intro");
    run_step.dependOn(&run_cmd.step);
}
