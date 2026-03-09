section .data
hello   db 'Hello World', 0xA, 0
ok_msg  db 'test ... ok', 0xA, 0
debug_key db 'DEBUG=1', 0
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
	mov  rsi, hello
	call print_str
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
