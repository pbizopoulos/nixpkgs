RED = "\x1b[31m"
GREEN = "\x1b[32m"
BLUE = "\x1b[34m"
RESET = "\x1b[0m"
debug = process.env.DEBUG
if debug == '1'
  console.log "test ... ok"
else
  for i in [1..100]
    if i % 15 == 0
      console.log "#{RED}FizzBuzz#{RESET}"
    else if i % 3 == 0
      console.log "#{GREEN}Fizz#{RESET}"
    else if i % 5 == 0
      console.log "#{BLUE}Buzz#{RESET}"
    else
      console.log i
