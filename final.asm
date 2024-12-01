%macro    print     2               
        mov     rax, 1              ;SYS_write
        mov     rdi, 1              ;standard output device
        mov     rsi, %1             ;output string address
        mov     rdx, %2             ;number of character
        syscall                     ;calling system services
%endmacro

%macro    input     2
        mov     rax, 0              ;SYS_read
        mov     rdi, 0              ;standard input device
        mov     rsi, %1             ;input buffer address
        mov     rdx, %2             ;number of character
        syscall                     ;calling system services
%endmacro

section .bss
buffer          resb    256             ;input expression
total           resq    1               ;final total int
output          resb    16              ;final total as ascii ; 16 digits

section .data
LF              equ    10
NULL            equ    0
SYS_exit        equ    60
EXIT_SUCCESS    equ    0
msg1            db     "Input a math expression: ", NULL

section .text
                global _start
_start:
        print msg1, 25
        input buffer, 256
        mov rsi, 0              ; Set index to 0 (first character)

    ; Convert first character from ASCII to integer and store it as the current total
    mov rcx, qword[buffer + rsi] 
    and rcx, 0fh                 
    mov qword[total], rcx
    xor rcx, rcx
    inc rsi
    mov rbx, 5

checkOperator:
        cmp rbx, 0
        jbe ToAscii

        cmp byte[buffer + rsi], "+"
        je add_operator
        cmp byte[buffer + rsi], "-"
        je sub_operator
        cmp byte[buffer + rsi], "*"
        je mul_operator
        cmp byte[buffer + rsi], "/"
        je div_operator

add_operator:
        inc rsi
        mov rcx, qword[buffer + rsi]
        and rcx, 0fh
        add qword[total], rcx
        xor rcx, rcx
        inc rsi
        dec rbx
        jmp checkOperator

sub_operator:
        inc rsi
        mov rcx, qword[buffer + rsi]
        and rcx, 0fh
        sub qword[total], rcx
        xor rcx, rcx
        inc rsi
        dec rbx
        jmp checkOperator

mul_operator:
        inc rsi
        mov rcx, qword[buffer + rsi]
        and rcx, 0fh
        mov rax, qword[total]
        mul rcx
        xor rcx, rcx
        mov qword[total], rax
        xor rax, rax
        inc rsi
        dec rbx
        jmp checkOperator

div_operator:
        inc rsi
        mov rcx, qword[buffer + rsi]
        and rcx, 0fh
        mov rax, qword[total]
        div rcx
        xor rcx, rcx
        mov qword[total], rax
        xor rax, rax
        inc rsi
        dec rbx
        jmp checkOperator

ToAscii:                     
    ; Convert total to ASCII and store in output
	; Part A - Successive division
	mov 	rax, qword[total] 		;get sum
	mov 	rcx, 0 					;digitCount = 0
	mov 	rbx, 10 				;set for dividing by 10
divideLoop:
	mov 	rdx, 0					;edx = 0 
	div 	rbx 					;divide number by 10
        push 	rdx 					;push remainder
	inc 	rcx 					;increment digitCount
	cmp 	rax, 0 					;if (result > 0)
	jg 	divideLoop 				;goto divideLoop

	; Part B - Convert remainders and store
	mov 	rbx, output 				;get addr of ascii
	mov 	rdi, 0 					;rdi = 0
popLoop:
	pop 	rax 					;pop intDigit
	add 	al, "0" 				;al = al + 0x30
	mov 	byte[rbx+rdi], al 		;string[rdi] = al
	inc 	rdi 					;increment rdi
	loop 	popLoop 				;if (digitCount > 0) goto popLoop
	mov 	byte[rbx+rdi], LF 		;string[rdi] = newline

    print output, 256


    mov     rax, SYS_exit            ;terminate excuting process
    mov     rdi, EXIT_SUCCESS        ;exit status
    syscall
