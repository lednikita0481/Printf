section .rodata
jump_table:             ; starts with %b with binary
    dq Binary           ; %b - bin                               DONE
    dq Char             ; %c - Char                              DONE
    dq Decimal          ; %d - decimal                           DONE
    times ('o' - 'd' - 1) dq Error ; nothing here               
    dq Oct              ; %o - octal                             DONE
    times ('s' - 'o' - 1) dq Error  ; nothing here
    dq String           ; %s - string
    times ('x' - 's' - 1) dq Error
    dq Hex              ; %x - hex                               DONE

ascii: db 30h
numbers_end_9: db 39h
to_letters: db 7d

section .data
to_print_or_not_to_print: db 0
neg_: db 0
Message: times 34 db 0
help_buffer: times 34 db 0
user_durachok: db "USER_MADE_CRINGE.BIT_HIM"
user_durachok_len: dq 24d


section .text

extern strlen

global MyPrintf

MyPrintf:
        ;mov rdi, hui
        ;mov r9, -19
        ;mov r8, 'A'
        ;mov rsi, -100
        ;mov rdx, 16
        ;mov rcx, 16
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
        pop rdi
        pop rsi
        pop rdx
        pop rcx
        pop r8
        pop r9

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
; prints num in 2, 8, 16 count system
;--------------------------------------------------
; Entry: rdi - 1 if binary, 3 if oct, 8 if hex 
; Expects: rbp as a pointer to args
;--------------------------------------------------
Print_2_8_16:
        push rax    
        push rbx    
        push rcx    
        push rsi
        push rdx
        push rdi

        mov rax, [rbp]
        add rbp, 8      ; next argument to rax, inc rbp

        mov rsi, Message

        xor rdx, rdx ; use rdx as byte counter
        xor rbx, rbx ; use rbx as reg to save letter
        cmp rdi, 1
        jne .not_bin
        mov rcx, 64d
        jmp .zaloopa

    .not_bin:
        cmp rdi, 3
        jne .not_oct
        mov rcx, 21
        push rax
        xor al, al
        rol rax, 1
        mov bl, al
        pop rax
        rol rax, 1                              ;copypast of algorithm to make 64 dividable for 3
        cmp bl, 0
        jne .skip_skip0  
        cmp byte [to_print_or_not_to_print], 0
        je .zaloopa
    .skip_skip0:
        add bl, byte [ascii]
        mov byte [rsi], bl
        inc rsi
        inc rdx
        mov byte [to_print_or_not_to_print], 1
        jmp .zaloopa
    
    .not_oct:
        mov rcx, 16d

    .zaloopa:
        push rcx
        mov rcx, rdi
        push rax
        xor al, al
        rol rax, cl         ; clean al, roll bytes here, mov them to bl, repare rax and print dl in ascii
        mov bl, al
        pop rax
        rol rax, cl
        pop rcx
        ;shl bx, 1
        cmp bl, 0
        jne .skip_skip1  

        cmp byte [to_print_or_not_to_print], 0
        je .skip_write_1

    .skip_skip1:
        add bl, byte [ascii]
        cmp bl, byte [numbers_end_9]
        jbe .no_hex_problem
        add bl, byte [to_letters]
        ;push rbx
        ;push rax
        ;xor bl, bl
    .no_hex_problem:
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


Binary:
        push rdi
        mov rdi, 1
        call Print_2_8_16
        pop rdi
        ret


Char:
        push rax
        push rsi
        push rdi
        push rdx
        mov rax, [rbp]  ;argument
        add rbp, 8d
        mov rsi, Message
        mov byte [rsi], al
        mov rdi, 1
        mov rdx, 1
        mov rax, 1
        syscall
        mov byte [rsi], 0
        pop rdx
        pop rdi
        pop rsi
        pop rax
        ret


;--------------------------------------------------
; prints num in 10 count system
;--------------------------------------------------
; 
;--------------------------------------------------
Decimal:
        push rax
        push rdx
        push rcx
        push rsi

        mov rax, [rbp]
        add rbp, 8d

        xor rdx, rdx    
        xor rcx, rcx    ; it's a counter
        mov rsi, Message
        mov rbx, 10

        cmp rax, 0
        jge .set_pos
        mov byte [neg_], 1
        neg rax
        jmp .let_s_go
    .set_pos:
        mov byte [neg_], 0

    .let_s_go:
        xor rdx, rdx
        div rbx      ; divide. in rax result of dividing, rdx - ostatok
        
        mov [rsi], dl
        mov dh, [ascii]
        add byte [rsi], dh
        inc rsi
        inc rcx

        cmp rax, 0
        jne .let_s_go

        ;----------

        cmp byte [neg_], 0
        je .it_s_pos
        mov byte [rsi], '-'
        inc rsi
        inc rcx

    .it_s_pos:
        dec rsi
        call Reversation_Fault

        pop rsi
        pop rcx
        pop rdx
        pop rax
        ret

;--------------------------------------------------
; Reverses the string and prints it
;--------------------------------------------------
; Entry: rsi - the end of the string to reverse
;        rcx - amount of symbols in the string
;--------------------------------------------------
Reversation_Fault:
        push rdi
        push rdx
        push rax

        mov rdi, help_buffer
        push rcx

    .zaloopa:
        mov ah, byte [rsi]
        mov byte [rdi], ah
        inc rdi
        dec rsi
        loop .zaloopa

        pop rdx
        mov rax, 1
        mov rsi, help_buffer
        mov rdi, 1
        syscall
        

        pop rax
        pop rdx
        pop rdi
        ret

;--------------------------------------------------


Oct:
        push rdi
        mov rdi, 3
        call Print_2_8_16
        pop rdi
        ret

;--------------------------------------------------
; Prints a string
;--------------------------------------------------
String:
        push rdi
        push rsi
        push rax
        push rdx

        mov rdi, [rbp]
        add rbp, 8d
        call strlen     ; rax - strlen
        mov rsi, rdi
        mov rdi, 1
        mov rdx, rax
        mov rax, 1
        syscall

        pop rdx 
        pop rax
        pop rsi
        pop rdi
        ret

;--------------------------------------------------

;--------------------------------------------------
; Returns 


Hex:
        push rdi
        mov rdi, 4
        call Print_2_8_16
        pop rdi
        ret

Error:
        push rax
        push rdi
        push rsi
        push rdx

        mov rax, 1
        mov rdi, 1
        mov rsi, user_durachok
        mov rdx, [user_durachok_len]
        syscall

        pop rdx
        pop rsi
        pop rdi
        pop rax