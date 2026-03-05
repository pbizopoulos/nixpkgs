let run_tests () =
  if 1 + 1 = 2 then
    print_endline "test ... ok"
  else begin
    print_endline "test ... failed";
    exit 1
  end
let () =
  match Sys.getenv_opt "DEBUG" with
  | Some "1" -> run_tests ()
  | _ -> print_endline "Hello OCaml!"
