#!/usr/bin/env ruby
# frozen_string_literal: true
def run_tests
  raise "test math failed" if 1 + 1 != 2
  puts "test ... ok"
end

if ENV["DEBUG"] == "1"
  run_tests
else
  RED = "\x1b[31m"
  GREEN = "\x1b[32m"
  BLUE = "\x1b[34m"
  RESET = "\x1b[0m"
  (1..100).each do |i|
    if i % 15 == 0 then puts "#{RED}FizzBuzz#{RESET}" elsif i % 3 == 0 then puts "#{GREEN}Fizz#{RESET}" elsif i % 5 == 0 then puts "#{BLUE}Buzz#{RESET}" else puts i end
  end
end
