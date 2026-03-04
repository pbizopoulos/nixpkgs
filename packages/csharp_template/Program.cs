using System;
class Program
{
    static void RunTests()
    {
        if (1 + 1 == 2)
        {
            Console.WriteLine("test math ... ok");
        }
        else
        {
            Console.WriteLine("test math failed");
            Environment.Exit(1);
        }
    }
    static void Main()
    {
        string debug = Environment.GetEnvironmentVariable("DEBUG");
        if (debug == "1")
        {
            RunTests();
        }
        else
        {
            Console.WriteLine("Hello C#!");
        }
    }
}
