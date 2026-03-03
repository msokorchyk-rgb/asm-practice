section .data
    msg_prefix  db ": ", 0
    char_hash   db "#", 0
    char_open   db " (", 0
    char_close  db ")", 10, 0
    newline     db 10
    seed        dd 123456789

section .bss
    ; memory
    freq        resd 10
    n_val       resd 1
    input_buf   resb 16
    output_buf  resb 16

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
.atoi_loop:
    movzx ecx, byte [esi]
    cmp cl, 10
    je .gen_init
    cmp cl, 0
    je .gen_init
    sub cl, '0'
    imul eax, 10
    add eax, ecx
    inc esi
    jmp .atoi_loop

.gen_init:
    mov [n_val], eax
    xor esi, esi

.gen_loop:
    cmp esi, [n_val]
    je .print_init
    
    ; math
    mov eax, [seed]
    mov ebx, 1103515245
    mul ebx
    add eax, 12345
    and eax, 0x7FFFFFFF
    mov [seed], eax
    
    ; logic
    xor edx, edx
    mov ebx, 10
    div ebx
    
    ; memory
    inc dword [freq + edx * 4]
    
    inc esi
    jmp .gen_loop

.print_init:
    xor edi, edi

.hist_loop:
    cmp edi, 10
    je .exit

    ; I/O
    mov eax, edi
    call _itoa
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_prefix
    mov edx, 2
    int 0x80

    ; loops
    mov ecx, [freq + edi * 4]
    test ecx, ecx
    jz .print_count
    
.hash_loop:
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, char_hash
    mov edx, 1
    int 0x80
    pop ecx
    loop .hash_loop

.print_count:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, char_open
    mov edx, 2
    int 0x80
    
    mov eax, [freq + edi * 4]
    call _itoa
    
    mov eax, 4
    mov ebx, 1
    mov ecx, char_close
    mov edx, 3
    int 0x80

    inc edi
    jmp .hist_loop

.exit:
    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

_itoa:
    ; math / loops / memory
    pusha
    mov ebx, 10
    mov edi, output_buf + 15
    xor ecx, ecx
    test eax, eax
    jnz .conv
    mov byte [edi], '0'
    mov ecx, 1
    jmp .out
.conv:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    inc ecx
    test eax, eax
    jnz .conv
    inc edi
.out:
    mov eax, 4
    mov ebx, 1
    mov edx, ecx
    mov ecx, edi
    int 0x80
    popa
    ret
