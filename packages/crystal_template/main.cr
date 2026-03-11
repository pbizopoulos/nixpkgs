def run_tests
  if 1 + 1 == 2
    puts "test ... ok"
  else
    puts "test ... failed"
    exit 1
  end
end

if ENV["DEBUG"]? == "1"
  run_tests
else
  puts "Hello World"
end
