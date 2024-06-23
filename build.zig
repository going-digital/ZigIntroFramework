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
    const zigwin32_module = b.dependency("win32", .{}).module("zigwin32");

    if (b.release_mode == .small) {
        // Build --release=small
        //
        // This links with Crinkler

        const build_obj = b.addObject(.{
            .name = "main",
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .single_threaded = true,
            .optimize = .ReleaseSmall,
        });
        build_obj.root_module.addImport("win32", zigwin32_module);
        build_obj.step.dependOn(&minify.step);

        // Link
        // FIXME: This doesn't appear to execute with a
        // zig build --release=small
        const link = b.addSystemCommand(&.{"tools\\crinkler"});
        const exe = link.addPrefixedOutputFileArg("/out:", "test.exe");
        link.addArgs(&.{
            "/subsystem:windows",
            "/print:imports",
            "/print:labels",
            "/range:opengl32",
            "/compmode:slow",
            "/ordertries:1000",
        });
        link.addPrefixedDirectoryArg("/libpath:", b.path("lib"));
        link.addArtifactArg(build_obj);
        link.addArgs(&.{
            "kernel32.lib",
            "user32.lib",
            "gdi32.lib",
            "opengl32.lib",
            "winmm.lib",
        });
        const log = link.addPrefixedOutputFileArg("/report:", "test.html");
        const exe_install = b.addInstallFile(exe, "release.exe");
        const log_install = b.addInstallFile(log, "release_report.html");
        b.getInstallStep().dependOn(&exe_install.step);
        b.getInstallStep().dependOn(&log_install.step);
        // FIXME: Generate paths for crinkler output
        // FIXME: Copy output to install location
    } else {
        // Build debug
        const build_exe = b.addExecutable(.{
            .name = "main",
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .single_threaded = true,
            .optimize = optimize,
        });
        build_exe.root_module.addImport("win32", zigwin32_module);
        build_exe.step.dependOn(&minify.step);
        b.installArtifact(build_exe);
    }

    // Build clean
    const clean_step = b.step("clean", "Clean up");
    clean_step.dependOn(&b.addRemoveDirTree(b.install_path).step);
    if (@import("builtin").os.tag != .windows) {
        clean_step.dependOn(&b.addRemoveDirTree(b.pathFromRoot("zig-cache")).step);
    }

    // Build run
    const run_cmd = b.addSystemCommand(&.{"bin\\test.exe"});
    const run_step = b.step("run", "Run the intro");
    run_step.dependOn(&run_cmd.step);
}
