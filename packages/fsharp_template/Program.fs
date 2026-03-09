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
    if debug = "1" then runTests () else printfn "Hello World"
    0
