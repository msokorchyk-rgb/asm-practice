section .data
    msg_first   db "First index: ", 0
    msg_count   db "Count: ", 0
    msg_list    db "Indices: ", 0
    msg_none    db "-1", 10, 0
    space       db " ", 0
    newline     db 10, 0

section .bss
    ; memory
    array       resd 100
    n_val       resd 1
    target      resd 1
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
    je .read_target
    push ecx
    call _read_num
    pop ecx
    mov [array + ecx*4], eax
    inc ecx
    jmp .fill_loop

.read_target:
    ; I/O
    call _read_num
    mov [target], eax

    ; logic
    xor ecx, ecx
    mov ebx, -1         
    xor ebp, ebp        
    mov edi, [target]

.search_logic:
    cmp ecx, [n_val]
    je .print_results
    
    mov eax, [array + ecx*4]
    cmp eax, edi
    jne .next_search
    
    inc ebp
    cmp ebx, -1
    jne .next_search
    mov ebx, ecx        

.next_search:
    inc ecx
    jmp .search_logic

.print_results:
    ; I/O
    mov eax, 4
    push ebx            ; зберігаємо знайдений індекс
    mov ebx, 1
    mov ecx, msg_first
    mov edx, 13
    int 0x80
    pop ebx             ; повертаємо індекс
    
    cmp ebx, -1
    je .not_found
    
    mov eax, ebx
    call _itoa
    call _print_nl

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_count
    mov edx, 7
    int 0x80
    mov eax, ebp
    call _itoa
    call _print_nl

    mov eax, 4
    mov ebx, 1
    mov ecx, msg_list
    mov edx, 9
    int 0x80
    
    xor esi, esi
.list_loop:
    cmp esi, [n_val]
    je .final_nl
    mov eax, [array + esi*4]
    cmp eax, [target]
    jne .next_idx
    mov eax, esi
    call _itoa
    mov eax, 4
    mov ebx, 1
    mov ecx, space
    mov edx, 1
    int 0x80
.next_idx:
    inc esi
    jmp .list_loop

.not_found:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_none
    mov edx, 3
    int 0x80
    jmp .exit

.final_nl:
    call _print_nl

.exit:
    ; I/O
    mov eax, 1
    xor ebx, ebx
    int 0x80

_read_num:
    ; parse / I/O
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
    cmp dl, '0'
    jb .atoi_done
    sub dl, '0'
    imul eax, 10
    add eax, edx
    inc esi
    jmp .atoi
.atoi_done:
    ret

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
    mov edx, ecx
    mov ecx, edi
    mov ebx, 1
    int 0x80
    popa
    ret

_print_nl:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret
