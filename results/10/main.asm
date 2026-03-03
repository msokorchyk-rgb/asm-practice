section .data
    msg_bin     db "Binary: ", 0
    msg_pop     db "Popcount: ", 0
    msg_mod     db "Modified: ", 0
    space       db " ", 0
    newline     db 10
    ; позиції для модифікації: set 0, 7; clear 3
    pos_p       equ 0
    pos_q       equ 7
    pos_r       equ 3

section .bss
    ; memory
    num_x       resd 1
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
.atoi:
    movzx ecx, byte [esi]
    cmp cl, 10
    je .atoi_done
    sub cl, '0'
    imul eax, 10
    add eax, ecx
    inc esi
    jmp .atoi
.atoi_done:
    mov [num_x], eax

    ; logic: Вивід Binary
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_bin
    mov edx, 8
    int 0x80

    mov ebp, [num_x]
    mov ecx, 32
.bin_loop:
    ; loops / logic
    rol ebp, 1
    mov eax, ebp
    and eax, 1
    add al, '0'
    mov [output_buf], al
    
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, output_buf
    mov edx, 1
    int 0x80
    pop ecx

    ; logic: групування по 4 біти
    test cl, 3
    jnz .no_space
    cmp cl, 1
    je .no_space
    push ecx
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    pop ecx
.no_space:
    loop .bin_loop
    call _print_nl

    ; math: popcount
    mov eax, [num_x]
    xor edi, edi
    mov ecx, 32
.pop_loop:
    ; loops / logic
    test eax, eax
    jz .pop_done
    mov edx, eax
    and edx, 1
    add edi, edx
    shr eax, 1
    loop .pop_loop
.pop_done:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pop
    mov edx, 10
    int 0x80
    mov eax, edi
    call _itoa
    call _print_nl

    ; logic: modify bits (set p,q; clear r)
    mov eax, [num_x]
    ; set bit p (1 << 0)
    or eax, (1 << pos_p)
    ; set bit q (1 << 7)
    or eax, (1 << pos_q)
    ; clear bit r (~(1 << 3))
    and eax, ~(1 << pos_r)
    
    ; I/O
    push eax
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_mod
    mov edx, 10
    int 0x80
    pop eax
    call _itoa
    call _print_nl

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80

_itoa:
    ; math / memory
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

_print_nl:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret
