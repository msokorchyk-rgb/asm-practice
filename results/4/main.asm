section .bss
    ; memory
    input_buf  resb 12
    output_buf resb 12

section .text
    global _start

_start:
    ; I/O
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 12
    int 0x80

    ; parse
    mov esi, input_buf
    xor eax, eax
    mov ebx, 10

.input_loop:
    ; logic / loops
    movzx ecx, byte [esi]
    cmp cl, 10
    je .done_input
    cmp cl, 0
    je .done_input
    sub cl, '0'

    ; math
    mul ebx
    add eax, ecx
    inc esi
    jmp .input_loop

.done_input:
    ; logic
    and eax, 0xFFFF

    ; memory
    mov edi, output_buf + 11
    mov ebx, 10
    xor ecx, ecx

    ; logic
    test ax, ax
    jnz .convert_output
    mov byte [edi], '0'
    mov ecx, 1
    mov esi, edi
    jmp .print_result

.convert_output:
    ; math / loops
    xor dx, dx
    div bx
    add dl, '0'
    mov [edi], dl
    dec edi
    inc ecx
    test ax, ax
    jnz .convert_output

    ; logic
    inc edi
    mov esi, edi
    mov edx, ecx

.print_result:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, esi
    int 0x80

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80
