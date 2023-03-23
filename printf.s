section .rodata
jump_table:             ; starts with %b with binary
    dq Binary           ; %b - bin 
    dq Char             ; %c - Char
    dq Decimal          ; %d - decimal 
    times ('o' - 'd' + 1) dq Error ; nothing here
    dq Oct              ; %o - octal
    times ('s' - 'o' + 1) dq Error  ; nothing here
    dq String 
    times ('x' - 's' + 1) dq Error
    dq Hex

hex: db 30h

section .data
to_print_or_not_to_print: db 0
Message: times 34 db 0
hui: db 'hui%b'


section .text

global _start

_start:
        mov rdi, hui
        mov rsi, 5
        pop r15             ; I don't know how many parametrs I have, but in the top of stack we have ret adr, save it
        ; 7 - ? args already in stack 
        push r9 
        push r8 
        push rcx
        push rdx 
        push rsi 
        push rdi ; 6 - 1 args to stack

        push rbp ; to save rbp
        mov rbp, rsp    ; use rbp for reg access 
        add rbp, 16      ; above rbp and main string

        mov rsi, rdi    ; just because it's more comfortable to see it in "source index"
                        ; and easier syscalls
        call Main

        pop rbp
        push rdi
        push rsi
        push rdx
        push rcx
        push r8
        push r9

        push r15            ; push and return
        ret


;--------------------------------------------------
; Goes through a main string and cals functions 
; of processing of certain args
;--------------------------------------------------
; Enter: rsi - source (first arg)
;--------------------------------------------------
Main:
    .next:
        mov al, [rsi]
        cmp al, 0
        je .stop_it     ; checks str end

        cmp al, '%'  
        jne .just_a_symb
        call Arg 
        jmp .increase

    .just_a_symb:
        call Symb 
        
    .increase:
        inc rsi
        jmp .next

    .stop_it:              
        ret

;--------------------------------------------------

;--------------------------------------------------
; Prints one symbol
;--------------------------------------------------
; Enter: rsi - pointer to string byte
;--------------------------------------------------
Symb:
        push rdi
        push rdx    ; use rdi rdx in syscall 

        mov rdi, 1      ; stdout 
        mov rdx, 1      ; lendth
        mov rax, 1      ; write 
        syscall
        
        pop rdx
        pop rdi
        ret
;--------------------------------------------------

;--------------------------------------------------
; %args processing
;--------------------------------------------------
; Enter: rsi - pointer to string byte
;--------------------------------------------------
Arg:
        push rax 
        inc rsi         ; next symb after %

        xor rax, rax 
        mov al, [rsi]
        cmp al, '%'
        jne .really_arg
        call Symb
        jmp .stop_it

    .really_arg:
        call [jump_table + 8 * (rax - 'b')]

    .stop_it:
        pop rax
        ret
;--------------------------------------------------

Clean_Msg:
        push rcx
        push rsi
        mov byte [to_print_or_not_to_print], 0
        mov rsi, Message
        mov rcx, 34
    .zaloopa:
        mov byte [rsi], 0
        inc rsi
        loop .zaloopa

        pop rsi
        pop rcx
        ret



;--------------------------------------------------
; prints num in binary
;--------------------------------------------------
; 
;--------------------------------------------------
Binary:
        push rax    
        push rbx    
        push rcx    
        push rsi
        push rdx
        push rdi

        mov rax, [rbp]
        add rbp, 8      ; next argument to rax, inc rbp

        mov rsi, Message

        mov rcx, 64d
        xor rdx, rdx ; use rdx as byte counter
        xor rbx, rbx ; use rbx as reg to save 0 or zero

    .zaloopa:
        push rax
        xor al, al
        rol rax, 1
        mov bl, al
        pop rax
        rol rax, 1
        ;shl bx, 1
        cmp bl, 0
        jne .skip_skip1  

        cmp byte [to_print_or_not_to_print], 0
        je .skip_write_1

    .skip_skip1:
        add bl, byte [hex]
        ;push rbx
        ;push rax
        ;xor bl, bl
        mov byte [rsi], bl
        ;pop rax
        ;pop rbx
        inc rsi
        inc rdx
        ;xor bh, bh
        mov byte [to_print_or_not_to_print], 1

    .skip_write_1:
    ;    shl bx, 1
    ;    cmp bh, 0
    ;    jne .skip_skip2  

    ;    cmp byte [to_print_or_not_to_print], 0
    ;    je .skip_write_2

    ;.skip_skip2:
    ;    add bh, byte [hex]
    ;    push rbx
    ;    push rax
    ;    xor bl, bl
    ;    mov al, byte [rsi]
    ;    mov byte [rsi], al
    ;    pop rax
    ;    pop rbx
    ;    inc rsi
    ;    inc rdx
    ;    xor bh, bh
    ;    mov byte [to_print_or_not_to_print], 1
    ;.skip_write_2:
        loop .zaloopa

        mov rsi, Message
        cmp rdx, 0
        jne .skip_zero
        inc rdx

    .skip_zero:
        mov rdi, 1
        mov rax, 1
        syscall

        call Clean_Msg

        pop rdi
        pop rdx
        pop rsi
        pop rcx
        pop rbx
        pop rax
        ret

Char:
Decimal:
Error:
Oct:
String:
Hex: