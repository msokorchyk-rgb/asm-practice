section .bss
    ; memory
    input_buf  resb 16
    output_buf resb 16

section .data
    newline db 10

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
    mov esi, input_buf
    xor eax, eax
    mov ebx, 10

.atoi_loop:
    ; logic / loops
    movzx ecx, byte [esi]
    cmp cl, 10
    je .calc_init
    cmp cl, 0
    je .calc_init
    sub cl, '0'
    
    ; math
    mul ebx
    add eax, ecx
    inc esi
    jmp .atoi_loop

.calc_init:
    ; logic
    xor ebp, ebp
    xor edi, edi
    mov ebx, 10

.calc_loop:
    ; math / loops
    test eax, eax
    jz .output_results
    
    xor edx, edx
    div ebx
    
    add ebp, edx
    inc edi
    jmp .calc_loop

.output_results:
    ; logic / memory
    mov eax, ebp
    call _print_number
    
    mov eax, edi
    call _print_number

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

_print_number:
    ; memory
    push eax
    push ebx
    push ecx
    push edx
    push edi

    mov ebx, 10
    xor ecx, ecx
    mov edi, output_buf + 15

.itoa_loop:
    ; math / loops
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    inc ecx
    test eax, eax
    jnz .itoa_loop

    ; I/O
    inc edi
    mov edx, ecx
    mov ecx, edi
    mov eax, 4
    mov ebx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
