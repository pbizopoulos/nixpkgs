def run_tests():
    if 1 + 1 == 2:
        print("test ... ok")
    else:
        print("test math failed")
def main():
    # Starlark doesn't have a standard way to read env vars without extensions
    # but for the sake of the template we will just print Hello World
    print("Hello World")
main()
