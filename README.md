# Assembly_LR_SingleDigit_Calculator

# Contraints 
- Expression must have at least 2 operands and 1 operator
- Operands must be single digits
- Expression must follow the strucutre `<operand><operator><operand>`

```assembly
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
buffer          resb    256             ; input expression
total           resq    1               ; final total int
output          resb    16              ; final total as ASCII; 16 digits

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
    mov rsi, 0                      ; Set index to 0 (first character)
    xor rcx, rcx

    ; Initialize the first operand as the current total
    mov rcx, qword [buffer + rsi]   ; Read the first character
    and rcx, 0fh                    ; Convert ASCII to integer
    mov qword [total], rcx          ; Store as initial total
    xor rcx, rcx                    ; Clear rcx
    inc rsi                         ; Move to the next character

processExpression:
    cmp byte [buffer + rsi], NULL   ; Check if end of input
    je ToAscii                      ; Exit loop if null terminator

    ; Check for operators
    cmp byte [buffer + rsi], "+"
    je add_operator
    cmp byte [buffer + rsi], "-"
    je sub_operator
    cmp byte [buffer + rsi], "*"
    je mul_operator
    cmp byte [buffer + rsi], "/"
    je div_operator

    ; If no valid operator, increment index and continue
    inc rsi
    jmp processExpression

add_operator:
    xor rcx, rcx                    ; Clear rcx

    inc rsi
    mov rcx, qword [buffer + rsi]    ; Read next character
    and rcx, 0fh                    ; Convert ASCII to integer
    add qword [total], rcx          ; Perform addition

    inc rsi                         ; Move to next character
    jmp processExpression

sub_operator:
    xor rcx, rcx

    inc rsi
    mov rcx, qword [buffer + rsi]
    and rcx, 0fh
    sub qword [total], rcx

    inc rsi
    jmp processExpression

mul_operator:
    xor rax, rax
    xor rcx, rcx

    inc rsi
    mov rcx, qword [buffer + rsi]
    and rcx, 0fh
    mov rax, qword [total]
    mul rcx
    mov qword [total], rax

    inc rsi
    jmp processExpression

div_operator:
    xor rax, rax
    xor rcx, rcx
    xor rdx, rdx
    
    inc rsi
    mov rcx, qword [buffer + rsi]
    and rcx, 0fh
    mov rax, qword [total]
    div rcx
    mov qword [total], rax

    inc rsi
    jmp processExpression

ToAscii:
    ; Convert total to ASCII and store in output
    ; Part A - Successive division
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

    print output, 16

    mov rax, SYS_exit               ; Exit program
    mov rdi, EXIT_SUCCESS
    syscall
```
