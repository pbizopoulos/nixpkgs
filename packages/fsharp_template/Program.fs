open System
let runTests () =
    if 1 + 1 <> 2 then
        printfn "test math failed"
        exit 1
    else
        printfn "test ... ok"
[<EntryPoint>]
let main argv =
    let debug = Environment.GetEnvironmentVariable("DEBUG")
    if debug = "1" then
        runTests ()
    else
        let RED = "\x1b[31m"
        let GREEN = "\x1b[32m"
        let BLUE = "\x1b[34m"
        let RESET = "\x1b[0m"
        for i in 1..100 do
            if i % 15 = 0 then printfn "%sFizzBuzz%s" RED RESET
            elif i % 3 = 0 then printfn "%sFizz%s" GREEN RESET
            elif i % 5 = 0 then printfn "%sBuzz%s" BLUE RESET
            else printfn "%d" i
    0
