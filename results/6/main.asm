section .data
    msg_s    db "SIGNED: ", 0
    msg_u    db "UNSIGNED: ", 0
    msg_lt   db "a < b", 10, 0
    msg_gt   db "a > b", 10, 0
    msg_eq   db "a = b", 10, 0
    newline  db 10

section .bss
    ; memory
    buf      resb 32
    num_a    resd 1
    num_b    resd 1
    input    resb 64

section .text
    global _start

_start:
    ; I/O
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 64
    int 0x80
    call _atoi
    mov [num_a], eax

    ; I/O
    mov eax, 3
    mov ebx, 0
    mov ecx, input
    mov edx, 64
    int 0x80
    call _atoi
    mov [num_b], eax

    ; logic
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_s
    mov edx, 8
    int 0x80
    
    mov eax, [num_a]
    mov ebx, [num_b]
    call _cmp_signed

    ; logic
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_u
    mov edx, 10
    int 0x80
    
    mov eax, [num_a]
    mov ebx, [num_b]
    call _cmp_unsigned

    ; math
    mov eax, [num_a]
    mov ebx, [num_b]
    cmp eax, ebx
    jg .print_max_s
    mov eax, ebx
.print_max_s:
    call _itoa

    ; math
    mov eax, [num_a]
    mov ebx, [num_b]
    cmp eax, ebx
    ja .print_max_u
    mov eax, ebx
.print_max_u:
    call _itoa

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

_cmp_signed:
    ; logic
    cmp eax, ebx
    je .eq
    jl .lt
    mov ecx, msg_gt
    mov edx, 6
    jmp .print
.lt:
    mov ecx, msg_lt
    mov edx, 6
    jmp .print
.eq:
    mov ecx, msg_eq
    mov edx, 6
.print:
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

_cmp_unsigned:
    ; logic
    cmp eax, ebx
    je .eq
    jb .lt
    mov ecx, msg_gt
    mov edx, 6
    jmp .print
.lt:
    mov ecx, msg_lt
    mov edx, 6
    jmp .print
.eq:
    mov ecx, msg_eq
    mov edx, 6
.print:
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

_atoi:
    ; parse / loops
    push ebx
    push esi
    mov esi, ecx
    xor eax, eax
    mov ebx, 10
    xor edi, edi
    
    mov al, [esi]
    cmp al, '-'
    jne .loop
    inc esi
    mov edi, 1

.loop:
    movzx ecx, byte [esi]
    cmp cl, 10
    je .done
    cmp cl, 0
    je .done
    sub cl, '0'
    imul eax, ebx
    add eax, ecx
    inc esi
    jmp .loop
.done:
    test edi, edi
    jz .exit
    neg eax
.exit:
    pop esi
    pop ebx
    ret

_itoa:
    ; math / memory
    pusha
    mov ebx, 10
    mov edi, buf + 31
    mov byte [edi], 10
    mov ecx, 1
    
    test eax, eax
    jnz .process
    dec edi
    mov byte [edi], '0'
    inc ecx
    jmp .print_itoa

.process:
    ; loops
    xor edx, edx
.loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    inc ecx
    test eax, eax
    jnz .loop
    
.print_itoa:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov edx, ecx
    mov ecx, edi
    int 0x80
    popa
    ret
