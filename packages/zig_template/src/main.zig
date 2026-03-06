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
        const RED = "\x1b[31m";
        const GREEN = "\x1b[32m";
        const BLUE = "\x1b[34m";
        const RESET = "\x1b[0m";
        var i: u32 = 1;
        while (i <= 100) : (i += 1) {
            if (i % 15 == 0) {
                std.debug.print("{s}FizzBuzz{s}\n", .{ RED, RESET });
            } else if (i % 3 == 0) {
                std.debug.print("{s}Fizz{s}\n", .{ GREEN, RESET });
            } else if (i % 5 == 0) {
                std.debug.print("{s}Buzz{s}\n", .{ BLUE, RESET });
            } else {
                std.debug.print("{d}\n", .{i});
            }
        }
    }
}
