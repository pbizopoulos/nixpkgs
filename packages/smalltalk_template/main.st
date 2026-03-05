| debug |
debug := (Smalltalk getenv: 'DEBUG').
(debug = '1')
    ifTrue: [ 'test ... ok' displayNl ]
    ifFalse: [ 'Hello Smalltalk!' displayNl ].
