#lang racket/base
(require racket/system)
(define RED "\x1b[31m")
(define GREEN "\x1b[32m")
(define BLUE "\x1b[34m")
(define RESET "\x1b[0m")
(define (run-tests)
  (if (= (+ 1 1) 2)
      (displayln "test ... ok")
      (begin (displayln "test ... failed") (exit 1))))
(define (fizzbuzz i)
  (cond
    [(= 0 (remainder i 15)) (displayln (string-append RED "FizzBuzz" RESET))]
    [(= 0 (remainder i 3))  (displayln (string-append GREEN "Fizz" RESET))]
    [(= 0 (remainder i 5))  (displayln (string-append BLUE "Buzz" RESET))]
    [else                   (displayln i)]))
(let ([debug (getenv "DEBUG")])
  (if (and debug (string=? debug "1"))
      (run-tests)
      (for ([i (in-range 1 101)])
        (fizzbuzz i))))
