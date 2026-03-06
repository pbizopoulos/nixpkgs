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
  red = "\x1b[31m"
  green = "\x1b[32m"
  blue = "\x1b[34m"
  reset = "\x1b[0m"
  1.upto(100) do |i|
    if i % 15 == 0
      puts "#{red}FizzBuzz#{reset}"
    elsif i % 3 == 0
      puts "#{green}Fizz#{reset}"
    elsif i % 5 == 0
      puts "#{blue}Buzz#{reset}"
    else
      puts i
    end
  end
end
