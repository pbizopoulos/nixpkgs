import os
fn run_tests() {
	assert 1 + 1 == 2
	println('test ... ok')
}
fn main() {
	if os.getenv('DEBUG') == '1' {
		run_tests()
	} else {
		red := '\x1b[31m'
		green := '\x1b[32m'
		blue := '\x1b[34m'
		reset := '\x1b[0m'
		for i in 1 .. 101 {
			if i % 15 == 0 {
				println('${red}FizzBuzz${reset}')
			} else if i % 3 == 0 {
				println('${green}Fizz${reset}')
			} else if i % 5 == 0 {
				println('${blue}Buzz${reset}')
			} else {
				println(i)
			}
		}
	}
}
