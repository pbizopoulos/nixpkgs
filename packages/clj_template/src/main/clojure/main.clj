(ns main (:gen-class))
(defn run-tests
  []
  (if (= (+ 1 1) 2)
    (println "test ... ok")
    (do (println "test math failed") (System/exit 1))))
(defn -main
  [& args]
  (if (= (System/getenv "DEBUG") "1") (run-tests) (println "Hello Clojure!")))
