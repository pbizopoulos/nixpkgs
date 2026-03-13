@_silgen_name("getenv")
func getenv(_ name: UnsafePointer<Int8>) -> UnsafeMutablePointer<Int8>?

func getEnvVar(_ name: String) -> String? {
    if let result = getenv(name) {
        return String(cString: result)
    }
    return nil
}

func runTests() {
    if 1 + 1 == 2 {
        print("test ... ok")
    } else {
        print("test math failed")
    }
}

if getEnvVar("DEBUG") == "1" {
    runTests()
} else {
    print("Hello World")
}
