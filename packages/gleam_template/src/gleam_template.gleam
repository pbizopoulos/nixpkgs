@external(erlang, "io", "format")
fn erl_format(fmt: String, args: List(String)) -> Nil

pub fn main() {
  erl_format("Hello World\n", [])
}
