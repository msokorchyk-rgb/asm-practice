section .bss
    buffer resb 12

section .text
    global _start

_start:
    ; logic
    mov eax, 123456

    ; math
    test eax, eax
    jnz .prepare_parse
    mov byte [buffer], '0'
    mov edx, 1
    mov edi, buffer
    jmp .print_result

.prepare_parse:
    ; memory
    mov edi, buffer + 11
    mov ebx, 10
    xor ecx, ecx

.parse_loop:
    ; math / loops
    xor edx, edx
    div ebx
    add dl, '0'
    mov [edi], dl
    dec edi
    inc ecx
    
    ; logic
    test eax, eax
    jnz .parse_loop

    inc edi
    mov edx, ecx

.print_result:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    int 0x80

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80
