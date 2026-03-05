#!/usr/bin/env ruby
# frozen_string_literal: true
require "json"

def run_tests
  raise "test math failed" if 1 + 1 != 2
  puts "test ... ok"
end

if ENV["DEBUG"] == "1"
  run_tests
else
  puts "Hello, world!"
  data = { message: "Hello, world!", language: "Ruby" }
  puts JSON.dump(data)
end
