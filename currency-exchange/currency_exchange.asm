default rel

; Some of the functions below make use of an enum currency_t defined as:
; enum currency_t {
;    GBP,
;    EUR,
;    JPY,
;    AUD,
;    BRL,
;    CNY,
;    CAD,
;    INR
; };

section .rodata
    currencies_arr:
        db "GBP", 0
        db "EUR", 0
        db "JPY", 0
        db "AUD", 0
        db "BRL", 0
        db "CNY", 0
        db "CAD", 0
        db "INR", 0

    hundred dq 100.0

section .text

global stringify_currency
stringify_currency:
    ; This function has signature: void stringify_currency(char *buffer, enum currency_t currency);
    ; buffer (rdi), currency (esi)
    ; It stores the string representation for the value of a enum currency_t in the passed buffer

    movsxd rax, esi                             ; move enum (32 bits) to 64 bit register
    imul rax, 4                                 ; calculate byte offset (4 chars per string)

    lea rsi, [currencies_arr]                   ; load base address of array
    add rsi, rax                                ; add offset jumpt to correct string

    mov rcx, 4                                  ; 4 bytes (1 each char and the terminator)
    rep movsb                                   ; copy from rsi to rdi

    ret

global exchange_rate
exchange_rate:
    ; This function has signature: double exchange_rate(enum currency_t domestic_currency, enum currency_t foreign_currency, const double *value_in_US_dollars);
    ; domestic_currency (rdi), foreign_currency (rsi), value_in_US_dollars (rdx)
    ; It returns the value of one unit of foreign currency in the domestic currency.
    ; `value_in_US_dollars` is a pointer to the beginning of an array of `double` with the value of 1 unit of each enum currency_t, in dollars.

    movsd xmm1, qword [rdx + rdi*8]             ; get the double value_in_US_dollars of domestic_currency
    movsd xmm0, qword [rdx + rsi*8]             ; get the double value_in_US_dollars of foreign_currency
    divsd xmm0, xmm1                            ; exchange_rate = foreign_currency_in_dollars / domestic_currency_in_dollars

    ret 

global get_value_of_bills
get_value_of_bills:
    ; This function has signature: uint64_t get_value_of_bills(unsigned long long denomination, unsigned short number_of_bills);
    ; denomination (rdi), number_of_bills (si)
    ; It returns the total value of the bills.
    
    movzx rax, si                               ; zero-extend si into rax register
    mul rdi                                     ; multiply denomination * number_of_bills
    ret

global get_number_of_bills
get_number_of_bills:
    ; This function has signature: unsigned int get_number_of_bills(float amount, unsigned long long denomination);
    ; amount (xmm0), denomination (rdi)
    ; It returns the nuumber of whole bills that can be received within the given amount.

    roundss xmm0, xmm0, 1
    cvttss2si rax, xmm0                         ; convert float amount to integer with truncation
    xor rdx, rdx                                ; clear dividend high bits
    div rdi                                     ; divide by denomination (in rdi)
    ret
    
global exchangeable_value
exchangeable_value:
    ; This function has signature: uint32_t exchangeable_value(float budget, double exchange_rate, uint8_t spread, unsigned long long denomination);
    ; budget (xmm0), exchange_rate (xmm1), spread (dil), denomination (rsi)
    ; It returns the maximum value of the new currency after calculating the exchange rate adjusted by the spread.

    ; 1. Convert spread from integer to decimal percentage
    movzx eax, dil
    cvtsi2sd xmm2, eax
    divsd xmm2, [hundred]

    ; 2. Calculate the spread fee
    movsd xmm3, xmm1
    mulsd xmm1, xmm2

    ; 3. Calculate the actual rate (original rate + the fee)
    addsd xmm1, xmm3

    ; 4. Find out how much foreign currency we can get for our budget
    ; (Note: budget needs to be converted to double for the division)
    cvtss2sd xmm0, xmm0
    divsd xmm0, xmm1

    ; 5. Re-use previous function to find out how many whole bills that gives us
    ; (Note: max_money must be cast back down to float to match the signature)
    cvtsd2ss xmm0, xmm0
    mov rdi, rsi
    call get_number_of_bills

    mul rdi
    ret
    
%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif