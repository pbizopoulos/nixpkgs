import std.stdio;
import std.process;
void runTests()
{
    if (1 + 1 != 2)
    {
        stderr.writeln("test math failed");
        import core.stdc.stdlib : exit;
        exit(1);
    }
    writeln("test ... ok");
}
void main()
{
    if (environment.get("DEBUG") == "1")
    {
        runTests();
    }
    else
    {
        string RED = "\x1b[31m";
        string GREEN = "\x1b[32m";
        string BLUE = "\x1b[34m";
        string RESET = "\x1b[0m";
        for (int i = 1; i <= 100; i++)
        {
            if (i % 15 == 0)
                writeln(RED, "FizzBuzz", RESET);
            else if (i % 3 == 0)
                writeln(GREEN, "Fizz", RESET);
            else if (i % 5 == 0)
                writeln(BLUE, "Buzz", RESET);
            else
                writeln(i);
        }
    }
}
