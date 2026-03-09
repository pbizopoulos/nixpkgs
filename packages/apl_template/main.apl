R ← ⎕UCS 27 ⋄ RED ← R,'[31m' ⋄ GREEN ← R,'[32m' ⋄ BLUE ← R,'[34m' ⋄ RESET ← R,'[0m'
∇Z←FizzBuzz n
 Z←⍕n
 →(0≠15|n)/L1 ⋄ Z←RED,'FizzBuzz',RESET ⋄ →0
 L1:→(0≠3|n)/L2 ⋄ Z←GREEN,'Fizz',RESET ⋄ →0
 L2:→(0≠5|n)/0 ⋄ Z←BLUE,'Buzz',RESET
∇
⎕ ← FizzBuzz ¨ ⍳ 100
)OFF
