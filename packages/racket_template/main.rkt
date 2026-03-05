#lang racket/base
(define debug (environment-variables-ref (current-environment-variables) #"DEBUG"))
(if (and debug (bytes=? debug #"1"))
    (displayln "test ... ok")
    (displayln "Hello Racket!"))
