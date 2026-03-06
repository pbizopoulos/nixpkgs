⍝ Check DEBUG environment variable
'1' ≡ ⎕ENV 'DEBUG' : 'test ... ok' ⋄ 
R ← ⎕UCS 27 ⋄ RED ← R,'[31m' ⋄ GREEN ← R,'[32m' ⋄ BLUE ← R,'[34m' ⋄ RESET ← R,'[0m'
{ (0 = 15 | ⍵) : RED,'FizzBuzz',RESET ⋄ (0 = 3 | ⍵) : GREEN,'Fizz',RESET ⋄ (0 = 5 | ⍵) : BLUE,'Buzz',RESET ⋄ ⍕ ⍵ } ¨ ⍳ 100
)OFF
