default rel

section .data
    juice_times dd 1, 3, 3, 4, 5, 4, 7, 10

section .text

global time_to_make_juice
time_to_make_juice:
    ; This function has one argument, the ID for a juice as a 32-bit number (rdi)
    ; It returns the time to prepare this juice, as a 32-bit number
    
    lea rax, [juice_times]          ; load base address of the juice_times array into rax
    sub rdi, 1                      ; convert juice id to zero-based index
    mov eax, dword [rax + rdi*4]    ; read the 32-bit value at index rdi (each element is 4 bytes)
    ret

global time_to_prepare
time_to_prepare:
    ; This function has two arguments:
    ; - An array with the IDs for ordered juices, each ID a 32-bit number (rdi)
    ; - The number of ordered juices, also a 32-bit number (rsi)
    ; It returns the total time to prepare all ordered juices, as a 32-bit number
    
    mov rcx, rsi                    ; load size of array
    mov r8, rdi                     ; load base address of the array
    xor rdx, rdx                    ; total_time = 0
    xor r9, r9                      ; index = 0
    
    .for:
        cmp r9, rcx
        je .done

        mov edi, dword [r8 + r9*4]  ; load juice id
        inc r9

        call time_to_make_juice
        
        add rdx, rax                ; accumulate time
        jmp .for
    
    
    .done:
    mov rax, rdx
    ret

    ret

global limes_to_cut
limes_to_cut:
    ; This function takes three arguments:
    ; - The number of wedges needed, as a 32-bit number (rdi)
    ; - An array with the current supply of limes, each represented by a 8-bit number (rsi)
    ; - The number of limes in the supply, as a 32-bit number (rdx, this represents the size of the array)
    ; It returns the number of limes that need to be cut, as a 32-bit number
    
    mov rcx, rdx                    ; load size of array
    mov r8, rsi                     ; load base address of the array
    xor r9, r9                      ; index = 0
    xor r10, r10                    ; num_limes = 0

    .for:
        cmp rdi, 0                  ; if (wedges_needed <= 0)
        jle .done

        mov dl, byte [r8 + r9]      ; load current char in array
        inc r9                      ; next element in array
        inc r10                     ; num_limes += 1

        cmp dl, 'S'                 ; array[index] == 'S'
        je .s_char
        
        cmp dl, 'M'                 ; array[index] == 'M'
        je .m_char
        
        cmp dl, 'L'                 ; array[index] == 'L'
        je .l_char

        jmp .for

    .s_char:
        sub rdi, 6
        jmp .for

    .m_char:
        sub rdi, 8
        jmp .for

    .l_char:
        sub rdi, 10
        jmp .for

    .done:
        mov rax, r10                ; rax = num_limes

    ret

global remaining_orders
remaining_orders:
    ; This function takes two arguments:
    ; - The time left in the shift, as a 32-bit number (rdi)
    ; - An array with the IDs for ordered juices still not prepared, each ID a 32-bit number (rsi)
    ; It returns the number of juices made before the shift ends, as a 32-bit number

    mov r8, rsi                     ; load base address of the array
    xor r9, r9                      ; index = 0
    xor r10, r10                    ; counter = 0
    mov r11, rdi                    ; time_left

    .for:
        cmp r11, 0                  ; if (time_left <= 0)
        jle .done

        mov edi, dword [r8 + r9*4]  ; load current ID in array
        inc r9                      ; next element in array
        inc r10                     ; counter += 1

        call time_to_make_juice
        sub r11, rax                ; time_left -= time_to_make_juice

        jmp .for

    .done:
        mov rax, r10                ; rax = counter

    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
