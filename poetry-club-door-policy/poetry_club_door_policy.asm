default rel

section .text

global front_door_response
front_door_response:
    ; This function takes the address in memory for a line of the poem as an argument.
    ; It returns the first letter of that line, as a ASCII-encoded character.
    ret

global front_door_password
front_door_password:
    ; This function takes as argument the address in memory for a string containing the combined letters you found in task 1.
    ; It must modify this string in-place, making it correctly capitalized.
    ; The function has no return value.
    ret

global back_door_response
back_door_response:
    ; This function takes as argument the address in memory for a line of the poem.
    ; It returns the last letter of that line that is not a whitespace character, as a ASCII-encoded character.
    ret

global back_door_password
back_door_password:
    ; This function takes as arguments, in this order:
    ; 1. The address in memory for a buffer where the resulting string will be stored.
    ; 2. The address in memory for a string containing the combined letters you found in task 3.
    ; It should store the polite version of the capitalized password in the buffer.
    ; A polite version is correctly capitalized and has ", please." added at the end.
    ; The function has no return value.
    
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
