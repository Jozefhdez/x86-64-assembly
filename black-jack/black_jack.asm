C2 equ 2
C3 equ 3
C4 equ 4
C5 equ 5
C6 equ 6
C7 equ 7
C8 equ 8
C9 equ 9
C10 equ 10
CJ equ 11
CQ equ 12
CK equ 13
CA equ 14

TRUE equ 1
FALSE equ 0

section .text

; rdi, rsi, rdx, rcx, r8, and r9.

global value_of_card
value_of_card:
    ; This function takes as parameter a number representing a card
    ; If the value passed in the rdi register is equal to:
    ; CJ, CQ, and CK return 10
    ; CA return 1
    ; Any other card return its value
    ; The function should return the numerical value of the passed-in card


    cmp rdi, CJ             ; compare rdi and CJ
    jl .numeric_card        ; if rdi < CJ jump to .numeric_card

    cmp rdi, CA             ; compare rdi and CA
    je .ace_card            ; if rdi and CA are equal, jump to .ace_card

    jmp .ten_value_card     ; case where value is not CA but rdi >= CK
    
    .numeric_card:
    mov rax, rdi            ; return value
    ret

    .ten_value_card:
    mov rax, 10             ; return 10
    ret

    .ace_card:
    mov rax, 1              ; return 1
    ret

global higher_card
higher_card:
    ; This function takes as parameters two numbers each representing a card. (rdi, rsi)
    ; The function should return which card has the higher value
    ; If both have the same value, both should be returned
    ; If one is higher, the second one should be 0


    mov r8, rdi                 ; store card value
    mov r9, rsi

    call value_of_card          ; get value of card
    mov r12, rax                ; r12 contains the value of card r8
    
    mov rdi, rsi                ; move second card to rdi to make the function call
    call value_of_card          ; get value of card
    mov r13, rax                ; r13 contains the value of card r9

    cmp r12, r13                ; compare
    je .equal_value             ; if r12 == r13
    jl .second_card             ; if r12 < r13, second card is greater
    jmp .first_card             ; else, first card is greater

    .equal_value:
    mov rax, r8
    mov rdx, r9
    ret

    .first_card:
    mov rax, r8
    mov rdx, 0
    ret
    
    .second_card:
    mov rax, r9
    mov rdx, 0
    ret

global value_of_ace
value_of_ace:
    ; This function takes as parameters two numbers each representing a card (rdi, rsi)
    ; The function should return the value of an upcoming ace


    ; check if we have and ace
    cmp rdi, CA
    je .one
    cmp rsi, CA
    je .one

    ; get the value of each card before calculating the sum
    call value_of_card
    mov r8, rax
    mov rdi, rsi
    call value_of_card

    ; sum
    add rax, r8
    add rax, 11

    ; if sum <= 21 use 11; else use 1
    cmp rax, 21
    jle .eleven
    ja .one
    
    .eleven:
    mov rax, 11
    ret
    
    .one:
    mov rax, 1
    ret

global is_blackjack
is_blackjack:
    ; This function takes as parameters two numbers each representing a card
    ; The function should return TRUE if the two cards form a blackjack, and FALSE otherwise


    ; check if we have an ace in any of both cards
    cmp rdi, CA
    je .has_ca
    cmp rsi, CA
    je .has_ca

    jmp .not_blackjack              ; in case we dont

    .has_ca:
    call value_of_card              ; get value of cards and store it in r8, r9
    mov r8, rax
    mov rdi, rsi
    call value_of_card
    mov r9, rax

    cmp r8, 10                      ; compare both values to ten-value card
    je .has_blackjack
    cmp r9, 10
    je .has_blackjack

    jmp .not_blackjack              ; in case there is no jump exit with false

    .has_blackjack:                 ; exit with true
    mov rax, TRUE
    ret

    .not_blackjack:
    mov rax, FALSE
    ret

global can_split_pairs
can_split_pairs:
    ; This function takes as parameters two numbers each representing a card
    ; The function should return TRUE if the two cards can be split into two pairs, and FALSE otherwise

    call value_of_card              ; get value of cards and store it in r8, r9
    mov r8, rax
    mov rdi, rsi
    call value_of_card
    mov r9, rax

    cmp r8, r9                      ; compare, if equal return true
    je .can_split

    mov rax, FALSE                 ; false case (no jump)
    ret

    .can_split:
    mov rax, TRUE
    ret

global can_double_down
can_double_down:
    ; This function takes as parameters two numbers each representing a card
    ; The function should return TRUE if the two cards form a hand that can be doubled down, and FALSE otherwise


    call value_of_card              ; get value of cards and store it in r8, r9
    mov r8, rax
    mov rdi, rsi
    call value_of_card

    add rax, r8                     ; sum values

    cmp rax, 9                      ; compare with 9, 10, 11
    je .can_double
    cmp rax, 10
    je .can_double
    cmp rax, 11
    je .can_double

    mov rax, FALSE                  ; case no jump, return false
    ret

    .can_double:
    mov rax, TRUE
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
