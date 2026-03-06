(ns main (:gen-class))
(def red "\u001b[31m")
(def green "\u001b[32m")
(def blue "\u001b[34m")
(def reset "\u001b[0m")
(defn run-tests
  []
  (if (= (+ 1 1) 2)
    (println "test ... ok")
    (do (println "test math failed") (System/exit 1))))
(defn fizzbuzz [i]
  (cond
    (= 0 (mod i 15)) (println (str red "FizzBuzz" reset))
    (= 0 (mod i 3)) (println (str green "Fizz" reset))
    (= 0 (mod i 5)) (println (str blue "Buzz" reset))
    :else (println i)))
(defn -main
  [& args]
  (if (= (System/getenv "DEBUG") "1")
    (run-tests)
    (doseq [i (range 1 101)]
      (fizzbuzz i))))
