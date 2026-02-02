; Everything that comes after a semicolon (;) is a comment

WEIGHT_OF_EMPTY_BOX equ 500
TRUCK_HEIGHT equ 300
PAY_PER_BOX equ 5
PAY_PER_TRUCK_TRIP equ 220

section .text

; You should implement functions in the .text section
; A skeleton is provided for the first function

; the global directive makes a function visible to the test files
global get_box_weight
get_box_weight:
    ; This function takes the following parameters:
    ; - The number of items for the first product in the box, as a 16-bit non-negative integer, di
    ; - The weight of each item of the first product, in grams, as a 16-bit non-negative integer, si
    ; - The number of items for the second product in the box, as a 16-bit non-negative integer, dx
    ; - The weight of each item of the second product, in grams, as a 16-bit non-negative integer, cx
    ; The function must return the total weight of a box, in grams, as a 32-bit non-negative integer
    
    movzx eax, di                  ; prepare eax (convert to 32 bit to avoid overflow)
    movzx ebx, si                  ; prepare ebx
    imul eax, esi
    
    movzx edx, dx
    movzx ebx, cx                  ; prepare ebx
    imul edx, ecx

    add eax, edx                   ; add previous result to eax
    add eax, WEIGHT_OF_EMPTY_BOX   ; add weight of box 

    ret                            ; return value in eax

global max_number_of_boxes
max_number_of_boxes:
    ; TODO: define the 'max_number_of_boxes' function
    ; This function takes the following parameter:
    ; - The height of the box, in centimeters, as a 8-bit non-negative integer, dil
    ; The function must return how many boxes can be stacked vertically, as a 8-bit non-negative integer

    mov eax, TRUCK_HEIGHT        ; dividend in 16-bit register
    div dil

    ret

global items_to_be_moved
items_to_be_moved:
    ; TODO: define the 'items_to_be_moved' function
    ; This function takes the following parameters:
    ; - The number of items still unaccounted for a product, as a 32-bit non-negative integer, edi
    ; - The number of items for the product in a box, as a 32-bit non-negative integer, esi
    ; The function must return how many items remain to be moved, after counting those in the box, as a 32-bit integer

    mov eax, edi                ; move num of total items to eax
    sub eax, esi                ; substract items moved (eax = eax - esi)

    ret

global calculate_payment
calculate_payment:
    ; TODO: define the 'calculate_payment' function
    ; This function takes the following parameters:
    ; - The upfront payment, as a 64-bit non-negative integer, rdi
    ; - The total number of boxes moved, as a 32-bit non-negative integer, esi
    ; - The number of truck trips made, as a 32-bit non-negative integer, edx
    ; - The number of lost items, as a 32-bit non-negative integer, ecx
    ; - The value of each lost item, as a 64-bit non-negative integer, r8
    ; - The number of other workers to split the payment/debt with you, as a 8-bit positive integer, r9b
    ; The function must return how much you should be paid, or pay, at the end, as a 64-bit integer (possibly negative)

    ; total = (esi * PAY_PER_BOX) + (edx * PAY_PER_TRUCK_TRIP) - (ecx * r8) - rdi
    ; payment = (total / (r9b + 1)) + (total % (r9b + 1))
    ; remember that you get your share and also the remainder of the division

    neg rdi
    mov rax, rdi

    ; (esi * PAY_PER_BOX)
    imul    rsi, PAY_PER_BOX
    add     rax, rsi

    ; (edx * PAY_PER_TRUCK_TRIP)
    imul    rdx, PAY_PER_TRUCK_TRIP
    add     rax, rdx

    ; subtract  (ecx * r8)
    imul rcx, r8
	sub rax, rcx

    ; (total / (r9b + 1)) + (total % (r9b + 1))
	inc r9
	cqo
	idiv r9
	add rax, rdx
	ret

    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
