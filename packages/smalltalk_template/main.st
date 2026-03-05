Object subclass: Tester [
    runTests [
        (1 + 1 = 2)
            ifTrue: [ 'test ... ok' displayNl ]
            ifFalse: [ 'test ... failed' displayNl. Object error: 'test failed' ]
    ]
]
| debug |
debug := (Smalltalk getenv: 'DEBUG').
(debug = '1')
    ifTrue: [ Tester new runTests ]
    ifFalse: [ 'Hello Smalltalk!' displayNl ].
