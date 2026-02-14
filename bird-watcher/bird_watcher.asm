default rel

section .data
    last_week db 0, 2, 5, 3, 7, 8, 4, 0

section .bss
    current_week resb 8  ; current week storage (8 bytes for 7 days + padding)
    current_count resq 1 ; track how many days have been recorded in the current week (0-7)

section .text

global last_week_counts
last_week_counts:
    ; This function takes no parameter
    ; It returns a copy of last week's counts as a 8-byte number
    ; At the start of the program, last week's counts are 0, 2, 5, 3, 7, 8 and 4
    ; The last byte of the return value is always zero
    
    mov rax, qword [last_week]
    ret

global current_week_counts
current_week_counts:
    ; This function takes no parameter
    ; It returns two values:
    ; - A copy of current week's counts as a 8-byte number, rax
    ; - The number of days already filled in the current week, as a 8-byte number, rbx
    ; All days after the most recent one should have its corresponding byte zeroed-out in the output
    ; At the start of the program, there is no count for the current week
    
    mov rax, qword [current_week]
    mov rdx, qword [current_count]
    ret

global save_count
save_count:
    ; This function takes as parameter the most recent count, as a 1-byte number, 
    ; It must save this value in a new entry for the current week
    ; If there is already 7 entries in the current week before the function is called, then:
    ; - The current week becomes the last week.
    ; - A new entry is added with the passed value in a new current week.
    ; The function has no return value

    cmp qword [current_count], 7
    jne .save_value

    mov rax, [current_week]             ; current week into rax
    mov qword [last_week], rax          ; rax into last week, current week becomes the last week
    mov qword [current_week], 0         ; reset current week to 0
    mov byte [current_count], 0         ; restart current_count to 0

    .save_value:
    lea rax, [current_week]             ; read address
    mov rbx, qword [current_count]      ; load current count into rbx register
    mov byte [rax + rbx], dil           ; store the parameter into the address
    inc qword [current_count]
    ret

global today_count
today_count:
    ; This function has no parameter
    ; It returns the most recent entry for the current week, as a 1-byte number
    
    lea r8, [current_week]             ; read address
    mov r9, qword [current_count]      ; load current_count into r9
    dec r9                             ; substract 1 because current_count is one ahead
    mov al, byte [r8 + r9]             ; store the value in AL register

    ret

global update_today_count
update_today_count:
    ; This function takes as parameter a 1-byte number, dil
    ; It adds this number to the most recent entry for the current week
    ; This function has no return value
    
    lea r8, [current_week]             ; read address
    mov r9, qword [current_count]      ; load current_count into r9
    dec r9                             ; substract 1 because current_count is one ahead
    add byte [r8 + r9], dil            ; add the value to AL register

    ret

global update_week_counts
update_week_counts:
    ; This function takes as parameter a 8-byte number, rdi
    ; Each byte in the input parameter, but the last, represents a day's count in the current week
    ; The last byte in the input parameter has no meaning and must be zeroed-out
    ; This function makes the following changes:
    ; - The current week becomes the last week.
    ; - The counts in the input parameter are fully inserted in the current week.
    
    mov rax, [current_week]             ; current week into rax
    mov qword [last_week], rax          ; rax into last week, current_week becomes the last week
    mov qword [current_week], rdi       ; move input param into current_week
    mov qword [current_count], 7        ; we inserted a full week, so index = 7
    
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
