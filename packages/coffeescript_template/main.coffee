runTests = ->
  if 1 + 1 is 2
    console.log "test ... ok"
  else
    console.log "test math failed"
    process.exit 1
debug = process.env.DEBUG
if debug is "1"
  runTests()
else
  console.log "Hello World"
