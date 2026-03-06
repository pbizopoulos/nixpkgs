main :-
    getenv('DEBUG', '1'),
    write('test ... ok'), nl, halt.
main :-
    RED = '\x1b[31m', GREEN = '\x1b[32m', BLUE = '\x1b[34m', RESET = '\x1b[0m',
    forall(between(1, 100, I), (
        (0 is I mod 15 -> format('~wFizzBuzz~w~n', [RED, RESET]);
         0 is I mod 3  -> format('~wFizz~w~n', [GREEN, RESET]);
         0 is I mod 5  -> format('~wBuzz~w~n', [BLUE, RESET]);
         format('~w~n', [I]))
    )),
    halt.
main(_) :-
    main.
