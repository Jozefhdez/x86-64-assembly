default rel

; struct car_t {
;    char name[10]; // offset 0,  size 10
;    int16_t speed; // offset 10, size 2
;    float battery; // offset 12, size 4
;                   // total: 16 bytes
; };

; enum surface_t {
;    ASPHALT, // 0
;    SAND,    // 1
;    ICE,     // 2
;    CLAY     // 3
; };

; struct track_t {
;    enum surface_t surface; // offset 0, size 4
;                            // padding: 4 bytes
;    size_t distance;        // offset 8, size 8
;                            // total: 16 bytes
; };

; struct race_t {
;    struct track_t track;        // offset 0, size 16
;    uint8_t num_of_laps;         // offset 16, size 1
;                                 // padding: 3 bytes
;    struct car_t cars[6];        // offset 20, size 96
;    uint8_t num_of_running_cars; // offset 116, size 1
;                                 // padding: 7 bytes
;                                 // total: 120 bytes
; };

; struct tournament_t {
;    struct race_t races[20]; // offset 0, size 2400
;    size_t num_of_races;     // offset 2400, size 8
;                             // total: 2408 bytes
; };

section .rodata
    battery dd 100.0

section .text

global new_car
new_car:
    ; This function has signature: struct car_t new_car(short speed, const char name[]);
    ; speed (di), name (rsi)
    ; It returns a new struct car_t with the values provided.
    ; The starting value for field 'battery' is 100.0.

    sub rsp, 16             ; allocate 16 bytes in stack
    mov qword [rsp], 0      ; zero bytes 0–7
    mov qword [rsp + 8], 0  ; zero bytes 8–15

    mov [rsp + 10], di      ; put speed in corresponding byte (rdi register is used later to copy name, so set it early)

    lea rdi, [rsp]          ; get addres to write into
    mov rcx, 10             ; 10 bytes
    rep movsb               ; copy 10 bytes from rsi (name arg) into rdi (rsp, our struct)

    movss xmm0, [battery]   ; move battery into register
    movss [rsp + 12], xmm0  ; put battery in corresponding byte
    
    ; load struct's data into rax and rdx to return it
    mov rax, [rsp]
    mov rdx, [rsp + 8]

    add rsp, 16             ; free allocated memo, restore rsp to where it was before the call
    ret

global new_track
new_track:
    ; This function has signature: struct track_t new_track(enum surface_t surface, size_t distance);
    ; surface (edi), distance (rsi)
    ; It returns a new struct track_t with the values provided.

    sub rsp, 16             ; allocate 16 bytes
    mov [rsp], edi          ; move surface into first 4 bytes
    mov [rsp + 8], rsi      ; move distance into last 8 bytes
    
    ; load struct's data into rax and rdx to return it
    mov rax, [rsp]
    mov rdx, [rsp + 8]
    
    add rsp, 16             ;  free allocated memo
    ret

global new_race
new_race: 
    ; This function has signature: struct race_t new_race(struct track_t track, uint8_t num_of_laps);
    ; track (rsi+rdx),  num_of_laps (cl)
    ; It returns a new struct race_t with the values provided.
    ; The starting number of running cars is 0.

    mov r8, rdi             ; save output pointer (rdi clobbered by rep stosb)
    mov bl, cl              ; save num_of_laps (rcx clobbered by rep stosb)

    xor eax, eax            ; zero value to store
    mov ecx, 120            ; 120 bytes to zero
    rep stosb               ; zero output buffer

    mov rdi, r8             ; restore output pointer
    mov [rdi], rsi          ; track.surface + padding (offset 0)
    mov [rdi + 8], rdx      ; track.distance (offset 8)
    mov [rdi + 16], bl      ; num_of_laps (offset 16)

    mov rax, rdi            ; return output pointer
    ret

global add_participant
add_participant:
    ; This function has signature: bool add_participant(struct race_t *race, struct car_t car);
    ; rdi (pointer to race_t)
    ; rsi (car_t bytes 0-7  (name[0..7]))
    ; rdx (car_t bytes 8-15 (name[8..9] + speed + battery))
    ; If there's room for one more participant in the race, the car should be added to the list, updating the counter, and its participation is confirmed.
    ; Otherwise, the race organizers must inform the car's owner that it can't participate this time.

    movzx rax, byte [rdi + 116] ; load num_of_running_cars (zero-extended to avoid garbage in upper bytes)
    cmp al, 6                   ; check if race is full
    jl .participating           ; if room, add car

    xor al, al                  ; return false (no room)
    ret

    .participating:
        imul rax, rax, 16       ; rax = num_of_running_cars * 16 (offset within cars array)
        add rax, 20             ; rax = offset from struct base (cars start at offset 20)
        add rax, rdi            ; rax = absolute address of free slot

        mov [rax], rsi          ; write car bytes 0-7
        mov [rax + 8], rdx      ; write car bytes 8-15
        add byte [rdi + 116], 1 ; increment num_of_running_cars

    mov rax, 1                  ; return true (car added)
    ret

global add_race
add_race:
    ; This function has signature: void add_race(struct tournament_t *tournament, struct race_t race);
    ; rdi (pointer to tournament_t)
    ; race_t (on the stack, accessible via rsp)
    ; It should add a race to the tournament's array and also update its counter.

    mov r8, rdi                  ; save tournament pointer (rdi clobbered by rep movsb)
    mov rax, [rdi + 2400]        ; load num_of_races
    imul rax, 120                ; rax = num_of_races * 120 (offset of next free slot)
    add rdi, rax                 ; rdi = address of next free slot in races array

    lea rsi, [rsp + 8]           ; rsi = address of race on stack (rsp+8 skips return address)
    mov rcx, 120                 ; 120 bytes to copy
    rep movsb                    ; copy race from stack into tournament

    add qword [r8 + 2400], 1     ; increment num_of_races
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
