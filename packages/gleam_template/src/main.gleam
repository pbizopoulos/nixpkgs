import gleam/io
import gleam/os
pub fn main() {
  case os.get_env("DEBUG") {
    Ok("1") -> {
      case 1 + 1 == 2 {
        True -> io.println("test math ... ok")
        False -> {
          io.println("test math failed")
          os.exit(1)
        }
      }
    }
    _ -> io.println("Hello Gleam!")
  }
}
