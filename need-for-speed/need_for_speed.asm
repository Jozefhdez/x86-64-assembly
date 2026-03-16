default rel

; The functions below make use of the following structs and enum:
;
; struct car_t {
;    char name[10];
;    int16_t speed;
;    float battery;
; };
;
; enum surface_t {
;    ASPHALT,
;    SAND,
;    ICE,
;    CLAY
; };
;
; struct track_t {
;    enum surface_t surface;
;    size_t distance;
; };
;
; struct race_t {
;    struct track_t track;
;    uint8_t num_of_laps;
;    struct car_t cars[6];
;    uint8_t num_of_running_cars;
; };
;
; struct tournament_t {
;    struct race_t races[20];
;    size_t num_of_races;
; };


section .text

global new_car
new_car:
    ; This function has signature: struct car_t new_car(short speed, const char name[]);
    ; It returns a new struct car_t with the values provided.
    ; The starting value for field 'battery' is 100.0.

    ret

global new_track
new_track:
    ; This function has signature: struct track_t new_track(enum surface_t surface, size_t distance);
    ; It returns a new struct track_t with the values provided.

    ret

global new_race
new_race: 
    ; This function has signature: struct race_t new_race(struct track_t track, uint8_t num_of_laps);
    ; It returns a new struct race_t with the values provided.
    ; The starting number of running cars is 0.

    ret

global add_participant
add_participant:
    ; This function has signature: bool add_participant(struct race_t *race, struct car_t car);
    ; If there's room for one more participant in the race, the car should be added to the list, updating the counter, and its participation is confirmed.
    ; Otherwise, the race organizers must inform the car's owner that it can't participate this time.
    
    ret

global add_race
add_race:
    ; This function has signature: void add_race(struct tournament_t *tournament, struct race_t race);
    ; It should add a race to the tournament's array and also update its counter.
    
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
