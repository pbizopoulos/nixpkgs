#lang racket/base
(define debug (environment-variables-ref (current-environment-variables) #"DEBUG"))
(if (and debug (bytes=? debug #"1"))
    (displayln "test math ... ok")
    (displayln "Hello Racket!"))
