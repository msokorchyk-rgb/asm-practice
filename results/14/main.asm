section .data
    msg_orig    db "Original: ", 0
    msg_sort    db "Sorted: ", 0
    msg_med     db "Median: ", 0
    space       db " ", 0
    newline     db 10, 0

section .bss
    ; memory
    array       resd 100
    n_val       resd 1
    input_buf   resb 16
    output_buf  resb 16

section .text
    global _start

_start:
    ; I/O
    call _read_num
    mov [n_val], eax

    ; loops / memory
    xor ecx, ecx
.fill_loop:
    cmp ecx, [n_val]
    je .print_original
    push ecx
    call _read_num
    pop ecx
    mov [array + ecx*4], eax
    inc ecx
    jmp .fill_loop

.print_original:
    ; I/O
    mov ecx, msg_orig
    mov edx, 10
    call _print_str
    call _print_array
    call _print_nl

    ; logic
    mov ecx, [n_val]
    dec ecx                 
    xor esi, esi            
.outer_loop:
    cmp esi, ecx
    je .find_median
    
    mov edi, esi            
    mov edx, esi
    inc edx                 

.inner_loop:
    cmp edx, [n_val]
    je .swap_elements
    
    mov eax, [array + edx*4]
    mov ebx, [array + edi*4]
    cmp eax, ebx
    jge .next_j
    mov edi, edx            
.next_j:
    inc edx
    jmp .inner_loop

.swap_elements:
    ; memory / logic
    mov eax, [array + esi*4]
    mov ebx, [array + edi*4]
    mov [array + esi*4], ebx
    mov [array + edi*4], eax
    
    inc esi
    jmp .outer_loop

.find_median:
    ; I/O
    mov ecx, msg_sort
    mov edx, 8
    call _print_str
    call _print_array
    call _print_nl

    ; math
    mov ecx, msg_med
    mov edx, 8
    call _print_str
    
    mov eax, [n_val]
    dec eax
    shr eax, 1              
    mov ebx, [array + eax*4]
    mov eax, ebx
    call _itoa
    call _print_nl

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80

_print_array:
    ; loops
    xor esi, esi
.p_loop:
    cmp esi, [n_val]
    je .p_done
    mov eax, [array + esi*4]
    call _itoa
    inc esi
    jmp .p_loop
.p_done:
    ret

_read_num:
    ; I/O / parse
    mov eax, 3
    mov ebx, 0
    mov ecx, input_buf
    mov edx, 16
    int 0x80
    xor eax, eax
    mov esi, input_buf
.atoi:
    movzx edx, byte [esi]
    cmp dl, 10
    je .atoi_done
    cmp dl, 0
    je .atoi_done
    cmp dl, '0'
    jb .next_c
    cmp dl, '9'
    ja .next_c
    sub dl, '0'
    imul eax, 10
    add eax, edx
.next_c:
    inc esi
    jmp .atoi
.atoi_done:
    ret

_itoa:
    ; math / memory / loops
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
