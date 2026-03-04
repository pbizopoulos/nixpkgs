#!/usr/bin/env lua
local function run_tests()
	if 1 + 1 ~= 2 then
		error("test math failed")
	end
	print("test math ... ok")
end
local debug = os.getenv("DEBUG")
if debug == "1" then
	run_tests()
else
	print("Hello Lua!")
end
