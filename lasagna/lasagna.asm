; Assembler-time constants may be defined using 'equ'

time_oven equ 40
time_each_layer equ 2

section .text

global expected_minutes_in_oven
expected_minutes_in_oven:
    ; does not take any parameters
    ; returns how many minutes the lasagna should be in the oven

    mov rax, time_oven              ; return 40 (using rax register)
    ret

global remaining_minutes_in_oven
remaining_minutes_in_oven:
    ; takes the actual minutes the lasagna has been in the oven as a parameter
    ; returns how many minutes the lasagna still has to remain in the oven

    call expected_minutes_in_oven   ; get the expected into rax register
    sub rax, rdi                    ; substract minutes it has been in the oven (parameter is in rdi)
    ret

global preparation_time_in_minutes
preparation_time_in_minutes:
    ; takes the number of layers you added to the lasagna as a parameter
    ; returns how many minutes you spent preparing the lasagna

    mov rax, rdi                    ; put layers in rax
    imul rax, time_each_layer       ; multiply layers by time_each_layer (2)
    ret

global elapsed_time_in_minutes
elapsed_time_in_minutes:
    ; function that takes two parameters, in this order:
    ; Number of layers you added to the lasagna
    ; Number of minutes the lasagna has been in the oven

    call preparation_time_in_minutes ; num of layers is in rdi, call it and get the ans in rax
    add rax, rsi                    ; add the minutes (its in rsi)
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
