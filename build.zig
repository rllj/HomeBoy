const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimise = b.standardOptimizeOption(.{});

    const target = b.standardTargetOptions(.{ .default_target = .{
        .cpu_arch = .riscv32,
        .cpu_model = .{ .explicit = &std.Target.riscv.cpu.rp2350_hazard3 },
        .os_tag = .freestanding,
        .abi = .none,
    } });

    const module = b.addModule("homeboy", .{
        .optimize = optimise,
        .target = target,
    });

    const elf = b.addExecutable(.{
        .name = "homeboy.elf",
        .root_module = module,
    });

    elf.setLinkerScript(b.path("./linker.ld"));
    elf.root_module.addCSourceFile(.{
        .file = b.path("./src/picobin_block.s"),
        .flags = &.{ "-march=rv32imac_zicsr_zba_zbb_zbc_zbs", "-mabi=ilp32" },
    });
    elf.root_module.addCSourceFile(.{
        .file = b.path("./src/blink.s"),
        .flags = &.{ "-march=rv32imac_zicsr_zba_zbb_zbc_zbs", "-mabi=ilp32" },
    });

    const artifact = b.addInstallArtifact(elf, .{});
    b.getInstallStep().dependOn(&artifact.step);

    // Convert the emitted ELF to UF2
    const rp2350_family = "0xe48bff5a";
    const elf_to_uf2_command = b.addSystemCommand(&.{
        "picotool",
        "uf2",
        "convert",
        "--family",
        rp2350_family,
    });
    elf_to_uf2_command.addArtifactArg(elf);

    const uf2_install_path = b.getInstallPath(.bin, "blink.uf2");
    elf_to_uf2_command.addArg(uf2_install_path);

    b.getInstallStep().dependOn(&elf_to_uf2_command.step);
}
