default rel

section .rodata
    hundred dq 100.0
    one dq 1.0
    billable_hours dq 8.0
    billable_days dq 22.0

section .text

global daily_rate
daily_rate:
    ; This function takes an hourly_rate, as a 64-bit floating-point number (xmm0).
    ; It returns the daily rate, also as a 64-bit floating-point number.
    ; A day has 8 billable hours.
    
    movsd xmm1, [billable_hours]
    mulsd xmm0, xmm1                ; daily_rate = hourly_rate * billable_hours
    ret

global apply_discount
apply_discount:
    ; It takes as parameters a price and a discount in percent, both as 64-bit floating-point number, (xmm0, xmm1).
    ; It returns the price with discount applied, as a 64-bit floating-point number.
        
    movsd xmm2, [one]               ; xmm2 = 1.0
    divsd xmm1, [hundred]           ; xmm1 = discount / 100.0
    subsd xmm2, xmm1                ; xmm2 = 1.0 - (discount / 100.0)
    mulsd xmm0, xmm2                ; xmm0 = price * multiplier
    ret

global monthly_rate
monthly_rate:
    ; It takes as parameters an hourly_rate and a discount in percent, both as a 64-bit floating-point number, (xmm0, xmm1).
    ; It returns the discounted monthly rate, as a 64-bit integer, rounded up.
    ; A month has 22 billable days.

    movsd xmm2, [billable_days]
    mulsd xmm2, [billable_hours]    ; hours_per_month = hours_per_day * days_per_month

    mulsd xmm0, xmm2                ;  gross_pay = hourly_rate * hours_per_month

    ; xmm0 is already the price, xmm1 is already the discount percent
    call apply_discount             ; Result is now in xmm0

    roundsd xmm0, xmm0, 2           ; round up
    cvttsd2si rax, xmm0             ; move to rax reg
    
    ret

global days_in_budget
days_in_budget:
    ; It takes as parameters:
    ; 1. A budget as a 64-bit unsigned integer (rdi).
    ; 2. An hourly_rate, as a 64-bit floating-point number (xmm0).
    ; 3. A discount in percent, as a 64-bit floating-point number (xmm1).
    ; It returns the number of complete days of work the budget covers, as a 32-bit unsigned integer, rounded down.
    

    ; here im moving arguments to the top xmm registers becuase the functions use some registers to do calculations
    cvtsi2sd xmm8, rdi              ; xmm8 = budget (converted from rdi)
    movsd xmm9, xmm1                ; xmm9 = discount percentage

    ; xmm0 already has hourly_rate, so just call
    call daily_rate                 ; Result in xmm0

    ; xmm0 already has daily_rate
    movsd xmm1, xmm9                ; Move discount into xmm1
    call apply_discount             ; Result in xmm0

    movsd xmm1, xmm0                ; xmm1 = discounted_daily_rate
    movsd xmm0, xmm8                ; xmm0 = budget (float)
    divsd xmm0, xmm1                ; xmm0 = budget / rate

    cvttsd2si rax, xmm0             ; return as 32-bit int
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
