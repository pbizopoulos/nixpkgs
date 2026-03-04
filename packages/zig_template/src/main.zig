const std = @import("std");
fn runTests() void {
    if (1 + 1 != 2) {
        @panic("test math failed");
    }
    std.debug.print("test math ... ok\n", .{});
}
pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const debug = std.process.getEnvVarOwned(allocator, "DEBUG") catch |err| {
        if (err == error.EnvironmentVariableNotFound) {
            std.debug.print("Hello Zig!\n", .{});
            return;
        }
        return err;
    };
    defer allocator.free(debug);
    if (std.mem.eql(u8, debug, "1")) {
        runTests();
    } else {
        std.debug.print("Hello Zig!\n", .{});
    }
}
