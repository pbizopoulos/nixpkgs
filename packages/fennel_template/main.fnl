(local RED "\027[31m")
(local GREEN "\027[32m")
(local BLUE "\027[34m")
(local RESET "\027[0m")
(fn run-tests []
  (if (= (+ 1 1) 2)
      (print "test ... ok")
      (do
        (print "test math failed")
        (os.exit 1))))
(fn fizzbuzz [i]
  (if (= (% i 15) 0) (print (.. RED :FizzBuzz RESET))
      (= (% i 3) 0) (print (.. GREEN :Fizz RESET))
      (= (% i 5) 0) (print (.. BLUE :Buzz RESET))
      (print i)))
(if (= (os.getenv :DEBUG) :1)
    (run-tests)
    (for [i 1 100]
      (fizzbuzz i)))
