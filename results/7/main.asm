section .data
    msg_min    db "min: ", 0
    msg_max    db "max: ", 0
    msg_idx    db " idx: ", 0
    space      db " ", 0
    newline    db 10, 0

section .bss
    ; memory
    array      resd 50
    n_val      resd 1
    input_buf  resb 16
    output_buf resb 16

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
    je .atoi_done
    sub cl, '0'
    imul eax, 10
    add eax, ecx
    inc esi
    jmp .atoi_loop
.atoi_done:
    mov [n_val], eax

    ; loops / math
    xor ecx, ecx
.fill_loop:
    cmp ecx, [n_val]
    je .find_extremes
    
    mov eax, ecx
    mov ebx, 7
    mul ebx
    add eax, 3
    mov ebx, 100
    xor edx, edx
    div ebx
    
    ; memory
    mov [array + ecx*4], edx
    inc ecx
    jmp .fill_loop

.find_extremes:
    ; logic
    mov eax, [array]
    mov ebx, [array]
    xor edi, edi
    xor ebp, ebp
    mov ecx, 1

.comp_loop:
    cmp ecx, [n_val]
    je .print_array
    
    mov edx, [array + ecx*4]
    
    cmp edx, eax
    jae .check_max
    mov eax, edx
    mov edi, ecx
    
.check_max:
    cmp edx, ebx
    jbe .next_iter
    mov ebx, edx
    mov ebp, ecx

.next_iter:
    inc ecx
    jmp .comp_loop

.print_array:
    ; I/O / loops
    xor esi, esi
.p_arr_loop:
    cmp esi, [n_val]
    je .print_results
    mov eax, [array + esi*4]
    call _itoa
    
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
    
    inc esi
    jmp .p_arr_loop

.print_results:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_min
    mov edx, 5
    int 0x80

    mov eax, [array + edi*4]
    call _itoa
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_idx
    mov edx, 6
    int 0x80
    
    mov eax, edi
    call _itoa

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_max
    mov edx, 5
    int 0x80

    mov eax, ebx
    call _itoa
    
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_idx
    mov edx, 6
    int 0x80
    
    mov eax, ebp
    call _itoa

    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80

    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

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
    popa
    ret
