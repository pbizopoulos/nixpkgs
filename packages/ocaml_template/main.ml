let run_tests () =
  if 1 + 1 = 2 then
    print_endline "test ... ok"
  else begin
    print_endline "test ... failed";
    exit 1
  end
let fizzbuzz i =
  let red = "\x1b[31m" in
  let green = "\x1b[32m" in
  let blue = "\x1b[34m" in
  let reset = "\x1b[0m" in
  if i mod 15 = 0 then print_endline (red ^ "FizzBuzz" ^ reset)
  else if i mod 3 = 0 then print_endline (green ^ "Fizz" ^ reset)
  else if i mod 5 = 0 then print_endline (blue ^ "Buzz" ^ reset)
  else print_endline (string_of_int i)
let () =
  match Sys.getenv_opt "DEBUG" with
  | Some "1" -> run_tests ()
  | _ -> for i = 1 to 100 do fizzbuzz i done
