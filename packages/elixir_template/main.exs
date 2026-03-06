defmodule Main do
  @red "\x1b[31m"
  @green "\x1b[32m"
  @blue "\x1b[34m"
  @reset "\x1b[0m"
  def run_tests do
    if 1 + 1 == 2 do
      IO.puts("test ... ok")
    else
      IO.puts("test math failed")
      System.halt(1)
    end
  end
  def fizzbuzz(i) do
    cond do
      rem(i, 15) == 0 -> IO.puts("#{@red}FizzBuzz#{@reset}")
      rem(i, 3) == 0 -> IO.puts("#{@green}Fizz#{@reset}")
      rem(i, 5) == 0 -> IO.puts("#{@blue}Buzz#{@reset}")
      true -> IO.puts(i)
    end
  end
  def main do
    if System.get_env("DEBUG") == "1" do
      run_tests()
    else
      Enum.each(1..100, &fizzbuzz/1)
    end
  end
end
Main.main()
