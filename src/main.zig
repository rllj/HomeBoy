extern fn wait_microseconds(microseconds: u32) void;
extern fn toggle_led() void;

export fn main() callconv(.{ .riscv32_ilp32 = .{} }) void {
    while (true) {
        wait_microseconds(500 * 1000);
        toggle_led();
    }
}
