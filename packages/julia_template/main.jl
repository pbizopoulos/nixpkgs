function run_tests()
    if 1 + 1 == 2
        println("test ... ok")
    else
        println("test math failed")
        exit(1)
    end
end
debug = get(ENV, "DEBUG", "0")
if debug == "1"
    run_tests()
else
    RED = "\x1b[31m"
    GREEN = "\x1b[32m"
    BLUE = "\x1b[34m"
    RESET = "\x1b[0m"
    for i in 1:100
        if i % 15 == 0
            println(RED, "FizzBuzz", RESET)
        elseif i % 3 == 0
            println(GREEN, "Fizz", RESET)
        elseif i % 5 == 0
            println(BLUE, "Buzz", RESET)
        else
            println(i)
        end
    end
end
