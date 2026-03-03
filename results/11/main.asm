section .data
    char_star  db '*'
    char_space db ' '
    newline    db 10

section .bss
    ; memory
    input_buf  resb 16
    line_buf   resb 128
    h_val      resd 1

section .text
    global _start

_start:
    ; I/O
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 16
    int 0x80

    ; parse
    xor eax, eax
    mov esi, input_buf
.atoi:
    movzx ecx, byte [esi]
    cmp cl, 10
    je .atoi_done
    cmp cl, 0
    je .atoi_done
    sub cl, '0'
    imul eax, 10
    add eax, ecx
    inc esi
    jmp .atoi
.atoi_done:
    mov [h_val], eax

    ; logic / loops
    xor edi, edi

.row_loop:
    mov eax, [h_val]
    cmp edi, eax
    je .exit

    ; math
    mov ebx, eax
    sub ebx, edi
    dec ebx

    mov edx, edi
    shl edx, 1
    inc edx

    ; memory
    xor ecx, ecx
    
    test ebx, ebx
    jz .stars_fill
.spaces_fill:
    mov byte [line_buf + ecx], ' '
    inc ecx
    dec ebx
    jnz .spaces_fill

.stars_fill:
    ; loops
    mov byte [line_buf + ecx], '*'
    inc ecx
    dec edx
    jnz .stars_fill

    mov byte [line_buf + ecx], 10
    inc ecx

    ; I/O
    call _print_line

    inc edi
    jmp .row_loop

.exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80

_print_line:
    ; I/O
    pusha
    mov edx, ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, line_buf
    int 0x80
    popa
    ret
