section .data
    msg_orig    db "Original: ", 0
    msg_rev     db "Reversed: ", 0
    msg_yes     db "PALINDROME: YES", 10, 0
    msg_no      db "PALINDROME: NO", 10, 0
    space       db " ", 0
    newline     db 10, 0

section .bss
    array_orig  resd 200
    array_rev   resd 200
    n_val       resd 1
    is_pal_flag resd 1
    input_buf   resb 16
    output_buf  resb 16

section .text
    global _start

_start:
    call _read_num
    mov [n_val], eax

    xor ecx, ecx
.fill_loop:
    cmp ecx, [n_val]
    je .process_arrays
    push ecx
    call _read_num
    pop ecx
    mov [array_orig + ecx*4], eax
    inc ecx
    jmp .fill_loop

.process_arrays:
    mov ecx, [n_val]
    xor esi, esi            
    mov edi, ecx
    dec edi                 
    
.rev_loop:
    test ecx, ecx
    jz .check_palindrome
    mov eax, [array_orig + esi*4]
    mov [array_rev + edi*4], eax
    inc esi
    dec edi
    dec ecx
    jmp .rev_loop

.check_palindrome:
    xor ecx, ecx
    mov edx, [n_val]
    mov dword [is_pal_flag], 1
.pal_loop:
    cmp ecx, [n_val]
    je .output_stage
    mov eax, [array_orig + ecx*4]
    mov ebx, [array_rev + ecx*4]
    cmp eax, ebx
    jne .set_no
    inc ecx
    jmp .pal_loop
.set_no:
    mov dword [is_pal_flag], 0

.output_stage:
    mov ecx, msg_orig
    mov edx, 10
    call _print_str
    xor esi, esi
.out_orig_loop:
    cmp esi, [n_val]
    je .out_rev_start
    mov eax, [array_orig + esi*4]
    call _itoa
    inc esi
    jmp .out_orig_loop

.out_rev_start:
    call _print_nl
    mov ecx, msg_rev
    mov edx, 10
    call _print_str
    xor esi, esi
.out_rev_loop:
    cmp esi, [n_val]
    je .out_final
    mov eax, [array_rev + esi*4]
    call _itoa
    inc esi
    jmp .out_rev_loop

.out_final:
    call _print_nl
    cmp dword [is_pal_flag], 1
    jne .print_no_label
    mov ecx, msg_yes
    mov edx, 16
    jmp .do_print_pal
.print_no_label:
    mov ecx, msg_no
    mov edx, 15
.do_print_pal:
    call _print_str

    mov eax, 1
    xor ebx, ebx
    int 0x80

_read_num:
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 16
    int 0x80
    xor eax, eax
    mov esi, input_buf
.atoi_start:
    movzx edx, byte [esi]
    cmp dl, 10
    je .atoi_done
    cmp dl, 0
    je .atoi_done
    cmp dl, '0'
    jb .next_char
    cmp dl, '9'
    ja .next_char
    sub dl, '0'
    imul eax, 10
    add eax, edx
.next_char:
    inc esi
    jmp .atoi_start
.atoi_done:
    ret

_itoa:
    pusha
    mov ebx, 10
    mov edi, output_buf + 15
    xor ecx, ecx
    test eax, eax
    jnz .conv
    mov byte [edi], '0'
    mov ecx, 1
    jmp .out_itoa
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
.out_itoa:
    mov eax, 4
    mov ebx, 1
    mov edx, ecx
    mov ecx, edi
    int 0x80
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    popa
    ret

_print_str:
    mov eax, 4
    mov ebx, 1
    int 0x80
    ret

_print_nl:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret
