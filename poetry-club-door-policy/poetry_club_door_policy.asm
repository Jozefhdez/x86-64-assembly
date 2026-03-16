default rel

section .rodata
    polite_str db ", please.", 0
    polite_str_len equ $ - polite_str

section .text

global front_door_response
front_door_response:
    ; This function takes the address in memory for a line of the poem as an argument (rdi)
    ; It returns the first letter of that line, as a ASCII-encoded character.

    lea rdx, [rdi]
    mov al, byte [rdx]
    ret

global front_door_password
front_door_password:
    ; This function takes as argument the address in memory for a string containing the combined letters you found in task 1 (rdi)
    ; It must modify this string in-place, making it correctly capitalized.
    ; The function has no return value.

    mov rsi, rdi                    ; copy rdi, to rsi, to write to the same string

    lodsb                           ; load the byte at rsi into AL and move rsi pointer by 1
    cmp al, 'a'                     ; check if character is >= 'a' (lowercase)
    jge .make_capital               ; capitalize first letter
    stosb                           ; store change in AL to rdi

    .for:
        lodsb                       ; load next byte into AL and move rsi pointer by 1
        cmp al, 0                   ; check for null terminator
        je .done

        cmp al, 'Z'                 ; check if the character is <= 'Z' (uppercase)
        jle .make_lower_case

        stosb                       ; if it is already lowercase, write it back to keep rdi moving forward
        jmp .for

    .make_capital:
        sub al, 32
        stosb                       ; write the updated AL back to rdi, increment rdi
        jmp .for
    
    .make_lower_case:
        add al, 32
        stosb                       ; write the updated AL back to rdi, increment rdi
        jmp .for

    .done:
    ret

global back_door_response
back_door_response:
    ; This function takes as argument the address in memory for a line of the poem.
    ; It returns the last letter of that line that is not a whitespace character, as a ASCII-encoded character.

    mov rsi, rdi          ; copy rdi, to rsi, to write to the same string

    .continue:
        lodsb             ; load next byte into AL and move rsi pointer by 1
        cmp al, 0         ; check for null terminator
        je .done

        cmp al, 'A'       ; compare character with 'A'
        jl .continue      ; if it is less than 'A', jump to continue (not a letter)
        
        cmp al, 'Z'       ; compare character with 'Z'
        jle .save_letter  ; if it is less or equal, it is an uppercase letter, save it

        cmp al, 'a'       ; compare character with 'a'
        jl .continue      ; if it is less than 'a', jump to continue (not a letter)
        
        cmp al, 'z'       ; compare character with 'z'
        jle .save_letter  ; if it is less or equal, it is an lower letter, save it

        jmp .continue

    .save_letter:
        mov dl, al         ; save the valid letter into dl
        jmp .continue      ; go read the next character

    .done:
        mov al, dl         ; last letter into rax register to return result
        ret

global back_door_password
back_door_password:
    ; This function takes as arguments, in this order:
    ; 1. The address in memory for a buffer where the resulting string will be stored (rdi)
    ; 2. The address in memory for a string containing the combined letters you found in task 3 (rsi)
    ; It should store the polite version of the capitalized password in the buffer.
    ; A polite version is correctly capitalized and has ", please." added at the end.
    ; The function has no return value.

    push rdi                  ; rdi and rsi to the stack (needed because the function expects the word to be in rdi)
    push rsi                  ; and the functions modifies rsi inside of it

    mov rdi, rsi              ; move word to capitalize to rdi (to make call)
    call front_door_password

    pop rsi                   ; restore values
    pop rdi

    ; copy string loop
    .copy:
        lodsb         ; load a byte from capitalized string (into AL register)
        cmp al, 0     ; is it the end?
        je .append    ; if yes, we are ready to append ", please."

        stosb         ; otherwise, store it in the new buffer (rdi)
        jmp .copy     ; repeat

    .append:
        lea rsi, [polite_str]       ; point rsi to the polite string
        mov rcx, polite_str_len     ; set loop counter to the length of the polite string
        rep movsb                   ; copy rcx bytes from rsi to rdi
        
        ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
