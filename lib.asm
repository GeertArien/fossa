section .data

newline_char: db 10

section .text
global string_length
global print_string
global print_error
global print_char
global print_newline
global print_uint
global print_int
global string_equals
global read_char
global read_word
global parse_uint
global parse_int
global string_copy



string_length:
    xor rax, rax

.loop:
    cmp byte [rdi+rax],0
    je .end

    inc rax
    jmp .loop

.end:
    ret


print_string:
    call string_length        ; rax contains string lenght
    mov rdx, rax              ; rdx -> how many bytes to write
    mov rax, 1                ; 'write' syscall identifier
    mov rsi, rdi              ; where to take data from
    mov rdi, 1                ; stdout file descriptor
    syscall

    ret

print_error:
    call string_length        ; rax contains string lenght
    mov rdx, rax              ; rdx -> how many bytes to write
    mov rax, 1                ; 'write' syscall identifier
    mov rsi, rdi              ; where to take data from
    mov rdi, 2                ; stderr file descriptor
    syscall

    ret


print_char:
    mov rax, 1
    push rdi
    mov rsi, rsp
    mov rdi, 1
    mov rdx, 1
    syscall
    pop rdi

    ret

print_newline:
    mov rdi, newline_char
    call print_char

    ret


print_uint:
    mov rax, rdi
    mov rsi, rsp
    mov rdi, 10
    cmp rdi, 0          ; reset zero flag

.loop:
    jz .print
    xor rdx, rdx
    div rdi
    push rdx
    test rax, rax
    jnz .loop

.print:
    cmp rsi, rsp
    je .end
    pop rdi
    add rdi, '0'
    push rsi
    call print_char
    pop rsi
    jmp .print

.end:
    ret


print_int:
    cmp rdi, 0
    jge .print_uint
    push rdi
    mov rdi, '-'
    call print_char
    pop rdi
    neg rdi

.print_uint:
    call print_uint

    ret

string_equals:
    call string_length
    mov rdx, rax
    push rdi
    mov rdi, rsi
    call string_length
    pop rdi

    cmp rdx, rax
    jne .return_zero
    xor rdx, rdx

.compare_char:
    cmp rdx, rax
    je .return_one
    mov r8b, [rdi + rdx]
    cmp r8b, [rsi + rdx]
    jne .return_zero
    inc rdx
    jmp .compare_char

.return_one:
    mov rax, 1
    jmp .end

.return_zero:
    mov rax, 0

.end:
    ret


read_char:
    push 0
    mov rsi, rsp              ; where to write data to
    mov rdx, 1                ; rdx -> how many bytes to write
    xor rax, rax              ; 'read' syscall identifier
    xor rdi, rdi              ; stdin file descriptor
    syscall

    pop rax
    ret


read_word:
    push rbx
    xor rbx, rbx

.loopA:
    push rdi
    push rsi
    call read_char
    pop rsi
    pop rdi
    cmp al, 0x20
    je .loopA
    cmp al, 0x9
    je .loopA
    cmp al, 0xa
    je .loopA

    cmp rbx, rsi
    jae .error
    cmp al, 0
    je .end
    mov byte [rdi + rbx], al
    inc rbx

.loopB:
    push rdi
    push rsi
    call read_char
    pop rsi
    pop rdi
    cmp rbx, rsi
    jae .error
    cmp al, 0x20
    je .end
    cmp al, 0x9
    je .end
    cmp al, 0xa
    je .end
    cmp al, 0
    je .end
    mov byte [rdi + rbx], al
    inc rbx
    jmp .loopB

.error:
    mov rax, 0
    pop rbx
    ret

.end:
    mov byte [rdi + rbx], 0
    mov rax, rdi
    pop rbx
    ret

; rdi points to a string
; returns rax: number, rdx : length
parse_uint:
    push rbx
    call string_length
    mov rdx, rax

    xor rsi, rsi            ; final value
    mov r11, 2              ; value for division
    mov r10, 10             ; value for multiplication
    mov r8, 0               ; char position

.next_char:
    xor rcx, rcx            ; bit position
    xor rbx, rbx              ; number

    mov r9b, [rdi + r8]
    sub r9b, '0'
    cmp r9b, 10
    ja .end
    mov rax, rsi
    push rdx
    mul r10                 ; multiply final value with 10
    pop rdx
    mov rsi, rax
    xor rax, rax
    mov al, r9b

.char_division:
    div r11b
    sal ah, cl
    or bl, ah
    cmp cl, 3
    je .add_value
    inc cl
    xor ah, ah
    jmp .char_division

.add_value:
    add rsi, rbx
    inc r8
    cmp r8, rdx
    je .end
    jmp .next_char

.end:
    mov rax, rsi
    mov rdx, r8
    pop rbx
    ret

; rdi points to a string
; returns rax: number, rdx : length
parse_int:
  cmp byte [rdi], '-'
  je .parse_neg
  call parse_uint
  jmp .end

.parse_neg:
  inc rdi
  call parse_uint
  neg rax
  inc rdx

.end:
  ret


string_copy:
    push rdi
    push rsi
    push rdx
    call string_length
    pop rdx
    pop rsi
    pop rdi
    cmp rax, rdx
    jae .return_zero

    mov rdx, 0

.loop:
    cmp rdx, rax
    je .null_terminate

    mov cl, [rdi + rdx]
    mov [rsi + rdx], cl
    inc rdx
    jmp .loop

.null_terminate:
    mov byte [rsi + rdx], 0
    mov rax, rsi
    jmp .end

.return_zero:
    mov rax, 0

.end:
    ret
