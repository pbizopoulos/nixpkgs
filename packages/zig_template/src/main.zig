const std = @import("std");
fn runTests() void {
    if (1 + 1 != 2) {
        @panic("test math failed");
    }
    std.debug.print("test ... ok\n", .{});
}
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    var debug_val: []const u8 = "";
    const debug_res = std.process.getEnvVarOwned(allocator, "DEBUG");
    if (debug_res) |val| {
        debug_val = val;
    } else |err| {
        if (err != error.EnvironmentVariableNotFound) return err;
    }
    defer if (debug_val.len > 0) allocator.free(debug_val);
    if (std.mem.eql(u8, debug_val, "1")) {
        runTests();
    } else {
        std.debug.print("Hello World\n", .{});
    }
}
