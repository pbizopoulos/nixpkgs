import os
fn run_tests() {
	assert 1 + 1 == 2
	println('test ... ok')
}
fn main() {
	if os.getenv('DEBUG') == '1' {
		run_tests()
	} else {
		println('Hello World')
	}
}
