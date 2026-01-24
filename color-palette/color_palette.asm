default rel

extern combining_function

; Constants 'RED', 'GREEN' and 'BLUE'
; Accessible from other source files
section .rodata
global RED, GREEN, BLUE

RED dd 0xFF000000
GREEN dd 0x00FF0000
BLUE dd 0x0000FF00

; 'base_color' with the default value of 0xFFFFFF00
; Accessible from other source files
section .data
global base_color
base_color dd 0xFFFFFF00

section .text

global get_color_value
get_color_value:
    ; This function takes the address for a color as parameter
    ; It must return the 32-bit value associated with the color

    mov eax, dword [rdi]
    ret

global add_base_color
add_base_color:
    ; TODO: define the 'add_base_color' function
    ; This function takes the address for a color as parameter
    ; It saves the 32-bit value associated with this color in the variable 'base_color'
    ; This variable must be accessible from other source files
    ; This function has no return value
    call get_color_value
    
    mov dword [base_color], eax
    ret

global make_color_combination
make_color_combination:
    ; TODO: define the 'make_color_combination' function
    ; This function takes the following parameters:
    ; - The address where the 32-bit value for the combined color should be stored, rdi
    ; - The address of a secondary color in the color table
    ; It should call 'combining_function' with the 32-bit value for base and secondary colors and store the result in the passed address
    ; This function has no return value

    push rbx              ; Save rbx (callee-saved)
    mov rbx, rdi          ; Use rbx to hold the output address
    mov edi, dword [base_color]
    mov esi, dword [rsi]
    call combining_function
    mov dword [rbx], eax  ; Safe, since rbx is preserved
    pop rbx               ; Restore rbx
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
