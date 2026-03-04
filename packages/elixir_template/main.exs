defmodule Main do
  def run_tests do
    if 1 + 1 == 2 do
      IO.puts("test math ... ok")
    else
      IO.puts("test math failed")
      System.halt(1)
    end
  end
  def main do
    if System.get_env("DEBUG") == "1" do
      run_tests()
    else
      IO.puts("Hello Elixir!")
    end
  end
end
Main.main()
