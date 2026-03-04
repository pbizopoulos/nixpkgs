section .data
    hello db 'Hello Assembly!', 0xA
    hello_len equ $ - hello
    ok_msg db 'test math ... ok', 0xA
    ok_len equ $ - ok_msg
    debug_key db 'DEBUG=1', 0
section .text
    global _start
_start:
    ; At entry, [rsp] is argc, [rsp+8] is argv[0], ...
    mov rdi, [rsp]      ; rdi = argc
    lea rsi, [rsp + rdi*8 + 16] ; rsi = address of envp[0]
.find_debug:
    mov rdx, [rsi]      ; rdx = envp[i]
    test rdx, rdx       ; check if NULL
    jz .not_found
    ; Compare string in rdx with 'DEBUG=1'
    mov rax, debug_key
    mov r8, rdx
.compare:
    mov cl, [rax]
    mov dl, [r8]
    test cl, cl
    jz .check_end       ; reached end of 'DEBUG=1'
    cmp cl, dl
    jne .next_env
    inc rax
    inc r8
    jmp .compare
.check_end:
    ; If we matched 'DEBUG=1', we also need to ensure the env var string ends there
    test dl, dl
    jz .found           ; matched exactly 'DEBUG=1'
    ; Actually, env vars are 'KEY=VALUE'. So 'DEBUG=1' is the whole string we expect if DEBUG is 1.
    ; Wait, getenv("DEBUG") == "1" means the env var string is "DEBUG=1".
    ; So if we matched 'DEBUG=1' and we are at the end of the env var string (dl == 0), then it's a match.
    jmp .next_env
.next_env:
    add rsi, 8
    jmp .find_debug
.found:
    mov rsi, ok_msg
    mov rdx, ok_len
    jmp .print
.not_found:
    mov rsi, hello
    mov rdx, hello_len
.print:
    mov rax, 1          ; sys_write
    mov rdi, 1          ; stdout
    syscall
    mov rax, 60         ; sys_exit
    xor rdi, rdi
    syscall
