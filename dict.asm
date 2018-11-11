section .text
global find_word
extern string_equals

; rdi points to string we try to find
; rsi points to last value of list
find_word:
.loop:
    test rsi, rsi
    jz .no_match
    push rdi
    push rsi
    add rsi, 8
    call string_equals
    pop rsi
    pop rdi
    test rax, rax
    jnz .match
    mov rsi, [rsi]
    jmp .loop

.no_match:
    xor rax, rax
    jmp .end

.match:
    mov rax, rsi
    add rax, 8

.end:
    ret