(fn run-tests []
  (if (= (+ 1 1) 2)
      (print "test ... ok")
      (do
        (print "test math failed")
        (os.exit 1))))
(if (= (os.getenv :DEBUG) :1)
    (run-tests)
    (print "Hello Fennel!"))
