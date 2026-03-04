#!/usr/bin/env ruby
# frozen_string_literal: true
def run_tests
  raise "test math failed" if 1 + 1 != 2
  puts "test math ... ok"
end

if ENV["DEBUG"] == "1"
  run_tests
else
  puts "Hello, world!"
end
