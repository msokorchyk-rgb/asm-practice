section .data
    msg_fact    db "Factorial: ", 0
    msg_calls   db "Calls: ", 0
    newline     db 10

section .bss
    ; memory
    n_val       resd 1
    calls_cnt   resd 1
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
    cmp cl, 0
    je .atoi_done
    sub cl, '0'
    imul eax, 10
    add eax, ecx
    inc esi
    jmp .atoi
.atoi_done:
    mov [n_val], eax

    ; logic
    mov dword [calls_cnt], 0
    mov eax, [n_val]
    
    ; math
    call fact
    push eax                

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_fact
    mov edx, 11
    int 0x80

    pop eax
    call _itoa
    call _print_nl

    ; I/O
    mov eax, 4
    mov ebx, 1
    mov ecx, msg_calls
    mov edx, 7
    int 0x80

    mov eax, [calls_cnt]
    call _itoa
    call _print_nl

    ; exit
    mov eax, 1
    xor ebx, ebx
    int 0x80

fact:
    ; logic / memory
    inc dword [calls_cnt]
    push ebp
    mov ebp, esp

    ; math
    cmp eax, 1
    jle .base_case

    push eax                
    dec eax                 
    call fact               
    pop ebx                 
    imul eax, ebx           
    jmp .epilogue

.base_case:
    mov eax, 1

.epilogue:
    ; memory
    mov esp, ebp
    pop ebp
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
    popa
    ret

_print_nl:
    mov eax, 4
    mov ebx, 1
    mov ecx, newline
    mov edx, 1
    int 0x80
    ret
