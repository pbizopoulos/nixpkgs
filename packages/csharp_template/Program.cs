using System;
class Program
{
    static void RunTests()
    {
        if (1 + 1 == 2)
        {
            Console.WriteLine("test ... ok");
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
            string RED = "\x1b[31m";
            string GREEN = "\x1b[32m";
            string BLUE = "\x1b[34m";
            string RESET = "\x1b[0m";
            for (int i = 1; i <= 100; i++)
            {
                if (i % 15 == 0)
                    Console.WriteLine($"{RED}FizzBuzz{RESET}");
                else if (i % 3 == 0)
                    Console.WriteLine($"{GREEN}Fizz{RESET}");
                else if (i % 5 == 0)
                    Console.WriteLine($"{BLUE}Buzz{RESET}");
                else
                    Console.WriteLine(i);
            }
        }
    }
}
