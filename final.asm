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
buffer          resb    256         ; Input expression
total           resq    1           ; final total as integer
output          resb    10          ; final total as ASCII;
bufferLength    resb    256         ; length of the buffer not including the null terminator

section .data           
LF              equ    10           ; LF = 10
NULL            equ    0            ; NULL = 0
SYS_exit        equ    60           ; SYS_EXIT = 60
EXIT_SUCCESS    equ    0            ; EXIT_SUCCESS = 0
msg1            db     "Input a math expression: ", NULL ; msg1 = "Input a math expression: ",
equalSign       db     " = ", NULL

section .text
        global _start
_start:
    print msg1, 25                  ; print(msg1)

    input buffer, 256               ; cin > buffer
    mov rsi, 0                      ; Set index to 0 (first character)
    xor rcx, rcx                    ; clear rcx

    ; Initialize the first operand as the current total
    mov rcx, qword [buffer + rsi]   ; Read the first character
    and rcx, 0fh                    ; Convert ASCII to integer
    mov qword [total], rcx          ; Store integer as the initial total
    xor rcx, rcx                    ; Clear rcx
    inc rsi                         ; Move index pointer to next character in the input buffer

processExpression:
    cmp byte [buffer + rsi], NULL   ; Check if current character is null terminator
    je ToAscii                      ; Exit loop if null terminator

    cmp byte [buffer + rsi], "+"    ; if character == "+"
    je add_operator                 ; GOTO add_operator
    cmp byte [buffer + rsi], "-"    ; if character == "-"
    je sub_operator                 ; GOTO sub_operator
    cmp byte [buffer + rsi], "*"    ; if character == "*"
    je mul_operator                 ; GOTO mul_operator
    cmp byte [buffer + rsi], "/"    ; if character == "/"
    je div_operator                 ; GOTO div_operator

    inc rsi                         ; else index++
    jmp processExpression           ; loop

add_operator:
    xor rcx, rcx                    ; clear rcx to move and manipulate characters

    inc rsi                         ; index++
    mov rcx, qword [buffer + rsi]   ; rcx = buffer[index]
    and rcx, 0fh                    ; Convert ASCII to integer
    add qword [total], rcx          ; perform addition on total, total = total + rcx

    inc rsi                         ; index++
    jmp processExpression           ; check character

sub_operator:
    xor rcx, rcx                    ; clear rcx to move and manipulate characters

    inc rsi                         ; index++
    mov rcx, qword [buffer + rsi]   ; rcx = buffer[index]
    and rcx, 0fh                    ; Convert ASCII to integer
    sub qword [total], rcx          ; perform subtraction on total, total = total - rcx 

    inc rsi                         ; index++
    jmp processExpression           ; Check character

mul_operator:
    xor rax, rax                    ; clear rax to move and manipulate characters
    xor rcx, rcx                    ; clear rcx to move and manipulate characters

    inc rsi                         ; index++
    mov rcx, qword [buffer + rsi]   ; rcx = buffer[index]
    and rcx, 0fh                    ; Convert ASCII to integer
    mov rax, qword [total]          ; rax = total
    mul rcx                         ; rax = rax * rcx
    mov qword [total], rax          ; total = rax

    inc rsi                         ; index++
    jmp processExpression           ; Check character

div_operator:
    xor rax, rax                    ; Clear rax to move and manipulate characters
    xor rcx, rcx                    ; Clear rcx to move and manipulate characters
    xor rdx, rdx                    ; Clear rdx to move and manipulate characters

    inc rsi                         ; index++

    mov rcx, qword [buffer + rsi]   ; rcx = buffer[index]
    and rcx, 0fh                    ; Convert ASCII to integer

    mov rax, qword [total]          ; rax = total
    div rcx                         ; rdx:rax = rax / rcx, rax = quotient, rdx = remainder
    mov qword [total], rax          ; total = rax

    inc rsi                         ; index++
    jmp processExpression           ; Check character

ToAscii:
    mov qword[bufferLength], rsi    ; Get number of characters in the input buffer
    sub qword[bufferLength], 1      ; subtract 1 to not count the null terminator which is treated as a character

    ; Convert total to ASCII and store in output
    ; Part A - Successive division
    xor rax, rax
    xor rbx, rbx
    mov rax, qword [total]          ; Get total
    mov rcx, 0                      ; Digit count = 0
    mov rbx, 10                     ; Set for dividing by 10
divideLoop:
    mov rdx, 0                      ; Clear rdx
    div rbx                         ; Divide number by 10
    push rdx                        ; Push remainder
    inc rcx                         ; Increment digit count
    cmp rax, 0                      ; Check if result > 0
    jg divideLoop                   ; If yes, repeat loop

    ; Part B - Convert remainders and store
    mov rbx, output                 ; Get address of ASCII
    mov rdi, 0                      ; rdi = 0
popLoop:
    pop rax                         ; Pop intDigit
    add al, "0"                     ; Convert to ASCII
    mov byte [rbx + rdi], al        ; Store in output buffer
    inc rdi                         ; Increment index
    loop popLoop                    ; Repeat for all digits
    mov byte [rbx + rdi], LF        ; Add newline at the end

    print buffer, [bufferLength]    ; print(buffer)
    print equalSign, 3              ; print(equalSign)
    print output, 16                ; print(output)

    mov rax, SYS_exit               ; Exit program
    mov rdi, EXIT_SUCCESS           ; Exit success
    syscall                         ; Call system services
