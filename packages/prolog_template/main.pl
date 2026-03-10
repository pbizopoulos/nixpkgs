main: -getenv( 'DEBUG', '1' ),
  write('test ... ok'), nl, halt . main : -write('Hello World'), nl,
  halt
  . main(_) : - main
  .
