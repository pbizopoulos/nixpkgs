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
        writeln("Hello World");
    }
}
