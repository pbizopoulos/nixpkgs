Object subclass: Tester [
    runTests [
        (1 + 1 = 2)
            ifTrue: [ 'test ... ok' displayNl ]
            ifFalse: [ 'test ... failed' displayNl. Object error: 'test failed' ]
    ]
]
| debug RED GREEN BLUE RESET |
RED := '\x1B[31m'.
GREEN := '\x1B[32m'.
BLUE := '\x1B[34m'.
RESET := '\x1B[0m'.
debug := (Smalltalk getenv: 'DEBUG').
(debug = '1')
    ifTrue: [ Tester new runTests ]
    ifFalse: [ 
        1 to: 100 do: [ :i |
            (i \\ 15 = 0) ifTrue: [ (RED, 'FizzBuzz', RESET) displayNl ]
            ifFalse: [ (i \\ 3 = 0) ifTrue: [ (GREEN, 'Fizz', RESET) displayNl ]
            ifFalse: [ (i \\ 5 = 0) ifTrue: [ (BLUE, 'Buzz', RESET) displayNl ]
            ifFalse: [ i displayNl ] ] ]
        ]
    ].
