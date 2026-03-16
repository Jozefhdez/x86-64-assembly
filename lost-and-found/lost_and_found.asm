default rel

section .rodata
    example_string db "This is a string", 0
    string_length equ $ - example_string

section .text

global create_item_entry
create_item_entry:
    ; This function may take any number of parameters, of which the first 6 are:
    ;
    ; 1. The address for a location in memory where the item should be stored (rdi)
    ; 2. The ID for the item, as a 64-bit unsigned integer (rsi)
    ; 3. The address for a string with the item's description (rdx)
    ; 4. The day it was found, as a 64-bit unsigned integer (rcx)
    ; 5. The month it was found, as a 64-bit unsigned integer (r8)
    ; 6. The number of categories for the item, as a 64-bit unsigned integer (r9)
    ; Each subsequent parameter is the address for a string with one of the categories.
    ;
    ; Values should be stored in the provided memory location in the same order of the arguments:
    ; ID, description, day, month, number of categories, and each category in order.
    ;
    ; This function has no return value.

    mov [rdi], rsi              ; store item id at offset 0
    mov [rdi + 8], rdx          ; store item description address at offset 8
    mov [rdi + 16], rcx         ; store day found at offset 16
    mov [rdi + 24], r8          ; store month found at offset 24
    mov [rdi + 32], r9          ; store number of categories at offset 32

    add rdi, 40                 ; advance destination pointer to accept extra stack args
    mov rcx, r9                 ; set loop counter to number of categories
    lea rsi, [rsp + 8]          ; set source pointer to where extra args start on stack
    rep movsq                   ; copy category pointers from stack to memory

    ret

global create_monthly_list
create_monthly_list:
    ; This function takes as parameters:
    ;
    ; 1. The capacity of the array in bytes, as a 64-bit unsigned integer (rdi)
    ; 2. An allocator function (rsi, even if its a function, just call it using `call rsi`)
    ;
    ; The allocator function should be called with the capacity as argument.
    ; It returns the address of the allocated space.
    ; This space has undefined value and should be cleared.
    ;
    ; The 'create_month_list' function should return the address for the space allocated with the allocator function.
    
    push rdi                    ; push  total_capacity to stack
    call rsi                    ; rax now has the allocated memory pointer
    pop rcx                     ; pop total_capacity into rcx (to use rep)
    
    push rax                    ; store address before cleaning memory
    mov rdi, rax                ; move allocated memory to pointer to rdi (to use stosb)
    xor rax, rax                ; we want to clean up the memory, so we do a xor and the rax register
    rep stosb                   ; rep to clean all bytes (using total_capacity)

    pop rax                     ; pop address
    ret

global insert_found_item
insert_found_item:
    ; This function takes as parameters:
    ;
    ; 1. The address for a space in memory where the monthly list is located (rdi)
    ; 2. The current number of entries already stored in the list, as a 64-bit unsigned integer (rsi)
    ; 3. A new entry to be added to the list (rdx)
    ;
    ; You may consider that the new entry always fits into the list.
    ; All entries in the list take up 120 bytes in space.
    ; This function has no return value.

    imul rsi, 120           ; calculate where the new item sould go in memory (rsi * 120 bytes)
    add rdi, rsi            ; destination pointer of new item
    
    lea rsi, [rsp + 8]      ; load memory address into register
    mov rcx, 120            ; put 120 into rcx (is the amount of bytes we are gonna write, we put it in rcx because of the rep instruction)
    rep movsb               ; read from rsi memory address to rdi (space in memory of the monthly list), we do this for 120 bytes

    ret

global print_item
print_item:
    ; This function takes as parameters:
    ; 1. The address for a buffer where an introductory ASCII NUL-terminated string may be stored (rdi)
    ; 2. The address for a space in memory where the monthly list is located (rsi)
    ; 3. The index of the entry in the array for the item that should be printed, as a 64-bit unsigned integer (rdx)
    ; 4. A printing function (rcx)
    ;
    ; This function must call the printing function with the following arguments:
    ;
    ; 1. The address to a memory location where the introductory string is stored; or `0` (as a 64-bit integer) if no string is passed.
    ; 2. The index of the entry in the array for the item that should be printed, as a 64-bit unsigned integer.
    ; 3. The ID for the item, as a 64-bit unsigned integer.
    ; 4. The address for a string with the item's description.
    ; 5. The day the item was found, as a 64-bit unsigned integer.
    ; 6. The month the item was found, as a 64-bit unsigned integer.
    ; 7. The number of categories for the item, as a 64-bit unsigned integer.
    ; 8. The address of the first category string.
    ;
    ; The introductory string is optional.
    ; If it is used in the printing function, this string must be NUL-terminated (ending in `0`) and have at most 50 characters, already considering the NUL terminator.
    ; Otherwise, the value `0` should be passed to the printing function instead.
    ;
    ; This function has no return value.

    ; prologue
    push rbp
    mov rbp, rsp
    
    push rcx                    ; save printing function address to stack
    push rdi                    ; save introductory string buffer address to stack
    imul r10, rdx, 120          ; calculate offset for current item (index * 120 bytes)
    lea r10, [rsi + r10]        ; calculate absolute memory address of the item

    lea rsi, [example_string]   ; load address of hardcoded example string
    mov rcx, string_length      ; set loop counter to length of example string
    rep movsb                   ; write example string into buffer at rdi

    mov rdi, qword [rsp]        ; retrieve introductory string buffer as arg 1
    mov rsi, rdx                ; set item index as arg 2
    mov rdx, qword [r10]        ; load item id into arg 3
    mov rcx, qword [r10 + 8]    ; load description address into arg 4
    mov r8, qword [r10 + 16]    ; load day into arg 5
    mov r9, qword [r10 + 24]    ; load month into arg 6
    
    lea rax, [r10 + 40]         ; get address pointing to the first category string
    push rax                    ; push category address as arg 8 (stack)
    push qword [r10 + 32]       ; push number of categories as arg 7 (stack)
    
    call qword [rbp - 8]        ; call the saved printing function

    ; epilogue
    mov rsp, rbp
    pop rbp

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
