DEF NUM_GROUDON_HITS EQU 15
DEF GROUDON_DURATION EQU $0300  ; 3 minutes 0 seconds
DEF GROUDON_FIREBALL_Y_VELOCITY EQU 3
DEF GROUDON_FIREBALL_X_VELOCITY_BOUND EQU 3 * 4
; maximum between fireball and and pinball that counts as a hit
DEF GROUDON_FIREBALL_COLLISION_SIZE EQU 16
; Number of flipper button presses required to free the ball from a fireball
DEF GROUDON_FIREBALL_BREAKOUT_COUNTER EQU 8
; Minimum delay between consecutive flipper button presses to count towards fireball breakout
DEF GROUDON_FIREBALL_BREAKOUT_COOLDOWN EQU 8
