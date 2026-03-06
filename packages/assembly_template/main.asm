section .data
red     db 0x1B, '[31mFizzBuzz', 0x1B, '[0m', 0xA, 0
green   db 0x1B, '[32mFizz', 0x1B, '[0m', 0xA, 0
blue    db 0x1B, '[34mBuzz', 0x1B, '[0m', 0xA, 0
ok_msg  db 'test ... ok', 0xA, 0
debug_key db 'DEBUG=1', 0
section .bss
num_str resb 12
section .text
global  _start
_start:
	mov rdi, [rsp]; argc
	lea rsi, [rsp + rdi*8 + 16]; envp[0]
.find_debug:
	mov  rdx, [rsi]
	test rdx, rdx
	jz   .not_found
	mov  rax, debug_key
	mov  r8, rdx
.compare:
	mov  cl, [rax]
	mov  dl, [r8]
	test cl, cl
	jz   .check_end
	cmp  cl, dl
	jne  .next_env
	inc  rax
	inc  r8
	jmp  .compare
.check_end:
	test dl, dl
	jz   .found
.next_env:
	add rsi, 8
	jmp .find_debug
.found:
	mov  rsi, ok_msg
	call print_str
	jmp  .exit
.not_found:
	mov rcx, 1
.fizzbuzz_loop:
	cmp  rcx, 101
	je   .exit
	push rcx
	;    Check FizzBuzz (15)
	mov  rax, rcx
	xor  rdx, rdx
	mov  rbx, 15
	div  rbx
	test rdx, rdx
	jz   .is_fizzbuzz
	;    Check Fizz (3)
	mov  rax, rcx
	xor  rdx, rdx
	mov  rbx, 3
	div  rbx
	test rdx, rdx
	jz   .is_fizz
	;    Check Buzz (5)
	mov  rax, rcx
	xor  rdx, rdx
	mov  rbx, 5
	div  rbx
	test rdx, rdx
	jz   .is_buzz
	;    Print Number
	mov  rax, rcx
	call itoa
	mov  rsi, num_str
	call print_str
	jmp  .next_iter
.is_fizzbuzz:
	mov  rsi, red
	call print_str
	jmp  .next_iter
.is_fizz:
	mov  rsi, green
	call print_str
	jmp  .next_iter
.is_buzz:
	mov  rsi, blue
	call print_str
	jmp  .next_iter
.next_iter:
	pop rcx
	inc rcx
	jmp .fizzbuzz_loop
.exit:
	mov rax, 60
	xor rdi, rdi
	syscall
print_str:
	push rsi
	xor  rdx, rdx
.count:
	cmp byte [rsi + rdx], 0
	je  .do_write
	inc rdx
	jmp .count
.do_write:
	mov rax, 1
	mov rdi, 1
	pop rsi
	syscall
	ret
itoa:
	mov rbx, 10
	mov rdi, num_str + 11
	mov byte [rdi], 0xA
	dec rdi
.itoa_loop:
	xor  rdx, rdx
	div  rbx
	add  dl, '0'
	mov  [rdi], dl
	dec  rdi
	test rax, rax
	jnz  .itoa_loop
	inc  rdi
	mov  rsi, rdi
	ret
