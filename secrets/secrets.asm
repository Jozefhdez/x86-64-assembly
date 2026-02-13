section .text

PRIVATE_KEY equ 0b1011_0011_0011_1100

global extract_higher_bits
extract_higher_bits:
    ; This function has a 16-bit integer as argument, di
    ; it returns the higher 8-bit value of the argument.
    ; Mask
    
    mov ax, di                      ; example ax = 1010_1010_0101_0101
    shr ax, 8                       ; example ax = 0000_0000_1010_1010
    ret

global extract_lower_bits
extract_lower_bits:
    ; This function takes one 16-bit integer as argument, di
    ; it return the lower 8-bit value of it.
    ; Message

    mov ax, di                  ; example ax = 1010_1010_0101_0101
    and ax, 0x00FF              ; example 0x00FF = 0000_0000_1111_1111, the and ensures we only get the 1s in the first 8 bits
    ret

global extract_redundant_bits
extract_redundant_bits:
    ; This function takes one 16-bit integer as argument, di
    ; It returns a 8-bit integer with all bits set in both the lower and the higher 8 bits of the argument.

    mov ax, di                  ; first move the 16-bit integer to the ax register (to use ah/al)
    and al, ah                  ; perform AND operation and get '1' where it is also 1 in both halves
    ret

global set_message_bits
set_message_bits:
    ; This function takes one 16-bit integer as argument.
    ; It returns a 8-bit integer with all bits set if they are set in the higher 8 bits of the argument, the others unchanged.
    ; Mask _ Message  
    
    mov ax, di                  ; move 16-bits into ax register
    or al, ah                   ; or operation between the message (al, lower bits) and Mask (ah, higher bits), to set into a 1 corresponding bits
    ret

global rotate_private_key
rotate_private_key:
    ; This function takes one 16-bit integer as argument.
    ; It returns a 16-bit integer with bits of the private key rotated to the left a number of positions equal to the redundant bits.
    ; The private key is 0b1011_0011_0011_1100.
    ; A bit is redundant when it is set in both the lowest 8-bit portion of the argument and the highest 8-bit portion of the argument.   
    
    call extract_redundant_bits            ; get redundant bits in AL register
    movzx cx, al                           ; expand AL into 16-bit register CX (popcnt does not work with 8 bit registers)
    popcnt cx, cx                          ; count the amount of redundant bits
    mov ax, PRIVATE_KEY                    ; load 16-bit PRIVATE_KEY and rotate left by CL
    rol ax, cl
    
    ret

global format_private_key
format_private_key:
    ; This function takes one 16-bit integer as argument, di
    ; It returns a 8-bit integer with the private key fully formatted.
    ; To format a private key, you must:
    ; - Rotate it.
    ; - Isolate the lowest 8-bit portion of the rotated private key, which is the base value.
    ; - Isolate the highest 8-bit portion of the rotated private key, which is a mask to be applied to the base value.
    ; - Flip set bits in the base value that are also set in the mask.
    ; - Flip all bits in the result.

    call rotate_private_key         ; rotate PRIVATE_KEY based on redundant bits in DI, returns rotated key in AX (AL=base, AH=mask)
    xor al, ah                      ; flip bits in base (AL) that are also set in mask (AH)
    not al                          ; flip all bits in the result

    ret

global decrypt_message
decrypt_message:
    ; This function takes one 16-bit integer as argument
    ; It returns a 16-bit integer, of which:
    ; - The higher 8 bits are the formatted private key, according to 'format_private_key'
    ; - The lower 8 bits are the message with all bits set, according to 'set_message_bits'

    call format_private_key
    mov bl, al                  ; bl = high byte

    call set_message_bits
    mov cl, al                  ; cl = low byte

    movzx ax, bl                ; move high byte into 16-bit register
    shl ax, 8                   ; shift it 8 bits to be on the higher end
    or  al, cl                  ; mask low bits into 16-bit register

    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
