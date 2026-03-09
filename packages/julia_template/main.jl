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
    println("Hello World")
end
