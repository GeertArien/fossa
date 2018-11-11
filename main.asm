%include "colon.inc"

section .data
%include "words.inc"

error_msg: db "Error: key not found in dictionary.", 0 
target_str: db "second word", 0

section .text
global _start
extern find_word
extern print_string
extern print_error
extern string_equals
extern print_uint
extern read_word

_start:
    mov rbp, rsp
    sub rsp, 256
    mov rdi, rsp
    mov rsi, 256
    call read_word

    mov rdi, rsp
    mov rsp, rbp
    mov rsi, last_item
    call find_word
    test rax, rax
    jz .invalid
    mov rdi, rax
    call print_string
    jmp .end
    
.invalid:
    mov rdi, error_msg
    call print_error

.end:
    mov rax, 60         ; use exit system call to shut down correctly
    xor rdi, rdi
    syscall