let run_tests () =
    if 1 + 1 = 2 then
        print_endline "test ... ok"
    else
        (print_endline "test math failed";
         exit 1)
let () =
    match Sys.getenv_opt "DEBUG" with
    | Some "1" -> run_tests ()
    | _ -> print_endline "Hello OCaml!"
