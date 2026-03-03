section .data
    msg_pos     db "First pos: ", 0
    msg_cnt     db "Count: ", 0
    msg_none    db "-1", 10, 0
    newline     db 10, 0

section .bss
    ; memory
    text_buf    resb 201
    pat_buf     resb 51
    text_len    resd 1
    pat_len     resd 1
    out_buf     resb 16
    first_idx   resd 1

section .text
    global _start

_start:
    ; I/O
    mov eax, 3
    mov ebx, 0
    mov ecx, text_buf
    mov edx, 200
    int 0x80
    
    mov edi, text_buf
    call _strlen
    mov [text_len], eax

    mov eax, 3
    mov ebx, 0
    mov ecx, pat_buf
    mov edx, 50
    int 0x80
    
    mov edi, pat_buf
    call _strlen
    mov [pat_len], eax

    ; logic
    mov dword [first_idx], -1
    xor ebp, ebp
    
    mov eax, [pat_len]
    test eax, eax
    jz .print_results

    xor esi, esi
.main_loop:
    mov eax, esi
    add eax, [pat_len]
    cmp eax, [text_len]
    ja .print_results

    ; loops
    xor ecx, ecx
.compare_loop:
    mov edx, [pat_len]
    cmp ecx, edx
    je .match_found
    
    mov al, [text_buf + esi + ecx]
    mov bl, [pat_buf + ecx]
    cmp al, bl
    jne .no_match
    
    inc ecx
    jmp .compare_loop

.match_found:
    inc ebp
    cmp dword [first_idx], -1
    jne .skip_first
    mov [first_idx], esi
.skip_first:
    add esi, [pat_len]
    jmp .main_loop

.no_match:
    inc esi
    jmp .main_loop

.print_results:
    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_pos
    mov edx, 11
    int 0x80

    mov eax, [first_idx]
    cmp eax, -1
    je .not_found_msg
    call _itoa
    call _print_nl
    jmp .print_count

.not_found_msg:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_none
    mov edx, 3
    int 0x80

.print_count:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_cnt
    mov edx, 7
    int 0x80
    
    mov eax, ebp
    call _itoa
    call _print_nl

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80

_strlen:
    ; math / loops
    xor eax, eax
.len_loop:
    mov bl, [edi + eax]
    cmp bl, 10
    je .len_done
    cmp bl, 0
    je .len_done
    inc eax
    jmp .len_loop
.len_done:
    mov byte [edi + eax], 0
    ret

_itoa:
    ; math / memory
    pusha
    mov ebx, 10
    mov edi, out_buf + 15
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
