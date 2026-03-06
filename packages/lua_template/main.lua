#!/usr/bin/env lua
local function run_tests()
	if 1 + 1 ~= 2 then
		error("test math failed")
	end
	print("test ... ok")
end
local debug = os.getenv("DEBUG")
if debug == "1" then
	run_tests()
else
	local RED = "\x1b[31m"
	local GREEN = "\x1b[32m"
	local BLUE = "\x1b[34m"
	local RESET = "\x1b[0m"
	for i = 1, 100 do
		if i % 15 == 0 then
			print(RED .. "FizzBuzz" .. RESET)
		elseif i % 3 == 0 then
			print(GREEN .. "Fizz" .. RESET)
		elseif i % 5 == 0 then
			print(BLUE .. "Buzz" .. RESET)
		else
			print(i)
		end
	end
end
