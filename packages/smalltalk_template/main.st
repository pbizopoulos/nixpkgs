| debug |
debug := (Smalltalk getenv: 'DEBUG').
(debug = '1')
    ifTrue: [ 'test math ... ok' displayNl ]
    ifFalse: [ 'Hello Smalltalk!' displayNl ].
