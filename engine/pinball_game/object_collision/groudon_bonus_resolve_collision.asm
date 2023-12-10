ResolveGroudonBonusGameObjectCollisions:
	call TryCloseGate_GroudonBonus
	callba PlayLowTimeSfx
	call CheckTimeRanOut_GroudonBonus
	call ResolveGroudonCollision
	call ResolveGroudonBoulderCollision
	call UpdateGroudonEventTimer
	call UpdateGroudonFireball
	call UpdateGroudonFireballBreakoutCooldown
	call UpdateGroudonFireballBreakoutCounter
	call UpdateGroudonBoulderAnimations
	call UpdateGroudonAnimation
	ret

CheckTimeRanOut_GroudonBonus:
	ld a, [wTimeRanOut]
	and a
	ret z
	xor a
	ld [wTimeRanOut], a
	ld a, $1
	ld [wFlippersDisabled], a
	call LoadFlippersPalette
	callba StopTimer
	ret

TryCloseGate_GroudonBonus:
	ld a, [wGroudonBonusClosedGate]
	and a
	ret nz ; no need to close the gate if it already closed
	ld a, [wBallXPos + 1]
	cp 138
	ret nc ; can't close gate until ball is out of gate
	ld a, 1
	ld [wStageCollisionState], a
	ld [wGroudonBonusClosedGate], a
	callba LoadStageCollisionAttributes
	call LoadClosedGateGraphics_GroudonBonus
	ret

LoadClosedGateGraphics_GroudonBonus:
	; TODO
	ret

ResolveGroudonCollision:
	ld a, [wGroudonGroudonCollision]
	and a
	ret z
	xor a
	ld [wGroudonGroudonCollision], a

	ld a, [wNumGroudonHits]
	inc a
	ld [wNumGroudonHits], a

	; Don't interupt attack animations with the hit frame
	; Still count the hit, just don't make Groudon flinch
	ld a, [wGroudonAnimationId]
	cp a, GROUDONANIMATION_IDLE
	jp nz, .skipHitAnimation
	ld a, GROUDONANIMATION_HIT
	ld [wGroudonAnimationId], a
	sla a
	ld e, a
	ld d, $0
	ld hl, GroudonAnimations
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, wGroudonAnimation
	call InitAnimation
	call UpdateGroudonLimbGraphics

.skipHitAnimation
	ld bc, GROUDON_COLLISION_POINTS
	callba AddBigBCD6FromQueueWithBallMultiplier

	lb de, $00, $07
	call PlaySoundEffect
	ret

ResolveGroudonBoulderCollision:
	ld a, [wGroudonBoulderCollision]
	cp $FF
	ret z

	ld b, a
	ld a, $FF
	ld [wGroudonBoulderCollision], a
	ld a, b

	ld a, b
	sla b
	add a, b
	sla b
	add a, b ; a *= 7
	ld c, a
	ld b, 0
	ld hl, wGroudonBoulder0AnimationId
	add hl, bc
	push hl
	ld c, 4
	add hl, bc
	ld a, [hl] ; hl = BoulderHealth
	dec a
	ld [hl], a
	pop hl ; hl = BoulderAnimationId
	ld [hl], a
	inc hl ; hl = BoulderAnimation
	ld d, h
	ld e, l
	sla a
	ld c, a
	ld b, 0
	ld hl, GroudonBoulderAnimations
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call InitAnimation
	ret

; Pinball RS behavior:
;   prologue has Groudon and three boulders drop from above.
;   the first attack is four seconds after groudon drops.
;   about six or seven seconds between each attack
;   attack order is: lava plume barriers -> fireball -> boulder drop -> fireball -> repeat


UpdateGroudonEventTimer:
	ld hl, EventGroudonAnimation
	ld de, wGroudonEventAnimation
	call UpdateAnimation
	ret nc
	jp nz, .skipReset
	ld hl, EventGroudonAnimation
	ld de, wGroudonEventAnimation
	call InitAnimation

.skipReset
	ld a, [wGroudonEventAnimationFrame]
	rst JumpTable  ; calls JumpToFuncInTable
	MACRO GroudonEvent
		const \1
		dw \2
	ENDM
	const_def
	GroudonEvent GROUDONEVENT_IDLE, .idle
	GroudonEvent GROUDONEVENT_LAVAPLUME_INITGROUDONANIMATION, .groudonLavaplumeAnimationInit
	GroudonEvent GROUDONEVENT_ROCKTOMB_STARTGROUDONANIMATION, .groudonRockTombAnimationInit
	GroudonEvent GROUDONEVENT_FIREBALL_STARTGROUDONANIMATION, .groudonFireballAnimationInit
	GroudonEvent GROUDONEVENT_FIREBALL_FIRE, .fireballFire
	GroudonEvent GROUDONEVENT_ROCKTOMB_SUMMONROCKS, .summonRocks
	GroudonEvent GROUDONEVENT_LAVAPLUME_BREAKROCKS, .breakAllRocks

.idle
	ret

.groudonLavaplumeAnimationInit
	ld a, GROUDONANIMATION_LAVAPLUME
	jp .groudonAnimationInit

.groudonRockTombAnimationInit
	ld a, GROUDONANIMATION_ROCKTOMB
	jp .groudonAnimationInit

.groudonFireballAnimationInit
	ld a, GROUDONANIMATION_FIREBALL
	; fall through

.groudonAnimationInit
	ld [wGroudonAnimationId], a
	sla a
	ld e, a
	ld d, $0
	ld hl, GroudonAnimations
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, wGroudonAnimation
	call InitAnimation
	call UpdateGroudonLimbGraphics
	ret

.fireballFire
	xor a
	ld [wGroudonFireballXPos], a
	ld a, 80
	ld [wGroudonFireballXPos + 1], a
	ld a, 32
	ld [wGroudonFireballYPos], a

	ld a, [wBallYPos + 1]
	; 0 < a < 166; lookup table is 24 by 24
	; divide by 8 to scale to table height, then multiply by 24 to get to row
	; that is equivalent to and with $F8 and multiply by 3
	and $F8
	ld b, 0
	ld c, a
	ld l, c
	ld h, b
	sla c
	rl b
	add hl, bc
	ld b, 0
	ld a, [wBallXPos + 1]
	srl a
	srl a
	srl a
	ld c, a
	add hl, bc
	ld bc, .fireballXVelocities
	add hl, bc
	ld a, [hl]
	ld b, a
	ld c, 0
	sra b
	rr c
	sra b
	rr c
	ld a, c
	ld [wGroudonFireballXVelocity], a
	ld a, b
	ld [wGroudonFireballXVelocity + 1], a
	ret

.fireballXVelocities
	; a lookup table; 24 x 24, indicates the x velocity required to target a particular point
	; assuming the fireball starts at groudon's mouth, has the constant y velocity, has a maximum angle from down
	; these values are 6.2 fixed point; e.g. a value of 6 actually means 1.5 pixels per frame
	FOR Y, 1, 4
	FOR X, -10, 14
		IF X < 0
			DEF NUM = -GROUDON_FIREBALL_X_VELOCITY_BOUND
		ELSE
			DEF NUM = GROUDON_FIREBALL_X_VELOCITY_BOUND
		ENDC
		db NUM
	ENDR
	ENDR

	FOR Y, 1, 20
	FOR X, -10, 14
		DEF NUM = (((X) * 4 * GROUDON_FIREBALL_Y_VELOCITY) + 6) / (Y)
		IF NUM < -GROUDON_FIREBALL_X_VELOCITY_BOUND
			DEF NUM = -GROUDON_FIREBALL_X_VELOCITY_BOUND
		ELIF NUM > GROUDON_FIREBALL_X_VELOCITY_BOUND
			DEF NUM = GROUDON_FIREBALL_X_VELOCITY_BOUND
		ENDC
		db NUM
	ENDR
	ENDR

.breakAllRocks
FOR X, 0, 3
	ld a, [wGroudonBoulder{d:X}Health]
	and a
	jp z, .skipBreakBoulder{d:X}
	xor a
	ld [wGroudonBoulder{d:X}Health], a
	ld [wGroudonBoulder{d:X}AnimationId], a
	ld hl, GroudonBoudlerHealth0Animation
	ld de, wGroudonBoulder{d:X}Animation
	call InitAnimation
.skipBreakBoulder{d:X}
ENDR
	ret

.summonRocks
	call GenRandom
	and $3F
	add $10
	ld [wGroudonBoulder0XPos], a
	call GenRandom
	and $0F
	add $38
	ld [wGroudonBoulder0YPos], a

	call GenRandom
	and $3F
	add 160 - $3F - $10
	ld [wGroudonBoulder1XPos], a
	call GenRandom
	and $0F
	add $38
	ld [wGroudonBoulder1YPos], a

	call GenRandom
	and $3F
	add (160 - $3F - $10) / 2
	ld [wGroudonBoulder2XPos], a
	call GenRandom
	and $1F
	add $38
	ld [wGroudonBoulder2YPos], a

	ld a, GROUDON_BOULDER_HEALTH
	ld [wGroudonBoulder0AnimationId], a
	ld [wGroudonBoulder1AnimationId], a
	ld [wGroudonBoulder2AnimationId], a
	sla a
	ld c, a
	ld b, 0
	ld hl, GroudonBoulderAnimations
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	push hl
	ld de, wGroudonBoulder0Animation
	call InitAnimation

	pop hl
	push hl
	ld de, wGroudonBoulder1Animation
	call InitAnimation

	pop hl
	ld de, wGroudonBoulder2Animation
	call InitAnimation

	ret

EventGroudonAnimation:
	db 3 * 60, GROUDONEVENT_IDLE
	db $0C + $18, GROUDONEVENT_LAVAPLUME_INITGROUDONANIMATION
	db $18, GROUDONEVENT_LAVAPLUME_BREAKROCKS
	;db 3 * 60, GROUDONEVENT_LAVAPLUME_SPROUTLAVA
	db 3 * 60, GROUDONEVENT_IDLE
	db $20, GROUDONEVENT_FIREBALL_STARTGROUDONANIMATION
	db 3 * 60, GROUDONEVENT_FIREBALL_FIRE
	db 3 * 60, GROUDONEVENT_IDLE
	db $46, GROUDONEVENT_ROCKTOMB_STARTGROUDONANIMATION
	db 3 * 60, GROUDONEVENT_ROCKTOMB_SUMMONROCKS
	db 3 * 60, GROUDONEVENT_IDLE
	db $20, GROUDONEVENT_FIREBALL_STARTGROUDONANIMATION
	db 3 * 60, GROUDONEVENT_FIREBALL_FIRE
	db 3 * 60, GROUDONEVENT_IDLE
	db $00

UpdateGroudonFireball:
	ld a, [wGroudonFireballYPos]
	cp $B0
	ret nc ; disable fireball if it is below play area
	add GROUDON_FIREBALL_Y_VELOCITY
	ld [wGroudonFireballYPos], a
	ld de, wGroudonFireballXVelocity + 1
	ld hl, wGroudonFireballXPos
	call AddVelocityToPosition
	ret

UpdateGroudonFireballBreakoutCooldown:
	ld a, [wGroudonFireballBreakoutCooldown]
	and a
	ret z
	dec a
	ld [wGroudonFireballBreakoutCooldown], a
	ret

UpdateGroudonFireballBreakoutCounter:
	ld a, [wGroudonFireballBreakoutCounter]
	and a
	ret z

	ld hl, wKeyConfigLeftFlipper
	call IsKeyPressed
	jp nz, .checkCooldown
	ld hl, wKeyConfigRightFlipper
	call IsKeyPressed
	ret z

.checkCooldown
	ld a, [wGroudonFireballBreakoutCooldown]
	and a
	ret nz

	ld a, [wGroudonFireballBreakoutCounter]
	dec a
	ld [wGroudonFireballBreakoutCounter], a
	ld a, GROUDON_FIREBALL_BREAKOUT_COOLDOWN
	ld [wGroudonFireballBreakoutCooldown], a
	ret nz

	ld a, 1
	ld [wEnableBallGravityAndTilt], a
	ret

UpdateGroudonBoulderAnimations:
	ld a, [wGroudonBoulder0AnimationId]
	ld de, wGroudonBoulder0Animation
	call UpdateOneGroudonBoulderAnimations
	ld a, [wGroudonBoulder1AnimationId]
	ld de, wGroudonBoulder1Animation
	call UpdateOneGroudonBoulderAnimations
	ld a, [wGroudonBoulder2AnimationId]
	ld de, wGroudonBoulder2Animation
	; fall-through

UpdateOneGroudonBoulderAnimations:
; Input: a = BoulderAnimationId value
;        de = BoulderAnimationFrame pointer
	push de
	sla a
	ld e, a
	ld d, $0
	ld hl, GroudonBoulderAnimations
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	pop de ; de = BoulderAnimationFrameCounter
	call UpdateAnimation
	ret nc

	inc de ; de = BoulderAnimationFrame
	ld a, [de]
	cp GROUDONBOULDERFRAME_WAITING_TO_FALL
	; stagger the boulders' fall somewhat
	jp nz, .skipWaitingToFall
	dec de ; de = BoulderAnimationFrameCounter
	call GenRandom
	and $0F
	ld [de], a
	ret

.skipWaitingToFall
	 ; de = BoulderAnimationFrame
	cp GROUDONBOULDERFRAME_FALLING
	; make fall duration correspond to y position
	; DrawGroudonBoulders uses duration during the falling frame as a y offset
	; This combines to make the boulder fall from slightly above screen
	jp nz, .skipFalling
	ld hl, 4
	add hl, de ; hl = BoulderYPos
	ld a, [hl]
	srl a
	add a, 8
	dec de ; de = BoulderAnimationFrameCounter
	ld [de], a
	ret

.skipFalling
	 ; de = BoulderAnimationFrame
	cp GROUDONBOULDERFRAME_FELL
	; delays setting the boulder's health until it has fallen
	; so that the ball can't interact with the boulder until is has finished falling
	jp nz, .skipHealth3
	ld a, GROUDON_BOULDER_HEALTH
	ld hl, 2
	add hl, de ; hl = BoulderHealth
	ld [hl], a
	ret

.skipHealth3
	ret

GroudonBoulderAnimations:
	dw GroudonBoudlerHealth0Animation
	dw GroudonBoulderHealth1Animation
	dw GroudonBoulderHealth2Animation
	dw GroudonBoulderSummonAnimation

GroudonBoudlerHealth0Animation:
	db $08, GROUDONBOULDERFRAME_CRUMBLE_0
	db $08, GROUDONBOULDERFRAME_CRUMBLE_1
	db $01, GROUDONBOULDERFRAME_HIDDEN
	db $00 ; terminator

FOR X, 1, GROUDON_BOULDER_HEALTH
GroudonBoulderHealth{u:X}Animation:
	db $06, GROUDONBOULDERFRAME_HEALTH_{u:X}_RIGHT
	db $06, GROUDONBOULDERFRAME_HEALTH_{u:X}_LEFT
	db $01, GROUDONBOULDERFRAME_HEALTH_{u:X}
	db $00 ; terminator
ENDR

GroudonBoulderSummonAnimation:
	db $01, GROUDONBOULDERFRAME_HIDDEN
	db $01, GROUDONBOULDERFRAME_WAITING_TO_FALL
	db $01, GROUDONBOULDERFRAME_FALLING
	db $01, GROUDONBOULDERFRAME_FELL
	db $01, GROUDONBOULDERFRAME_HEALTH_3
	db $00 ; terminator

GroudonBoulderFrames:
	MACRO GroudonBoulderFrame
		const \1
		db \2 ; x offset
		db \3 ; sprite id
	ENDM
	const_def

	GroudonBoulderFrame GROUDONBOULDERFRAME_HIDDEN, 0, $FF
	GroudonBoulderFrame GROUDONBOULDERFRAME_HEALTH_3, 0, SPRITE2_GROUDON_BOULDER_HEALTH_3
	GroudonBoulderFrame GROUDONBOULDERFRAME_HEALTH_2, 0, SPRITE2_GROUDON_BOULDER_HEALTH_2
	GroudonBoulderFrame GROUDONBOULDERFRAME_HEALTH_2_RIGHT, 1, SPRITE2_GROUDON_BOULDER_HEALTH_2
	GroudonBoulderFrame GROUDONBOULDERFRAME_HEALTH_2_LEFT, -1, SPRITE2_GROUDON_BOULDER_HEALTH_2
	GroudonBoulderFrame GROUDONBOULDERFRAME_HEALTH_1, 0, SPRITE2_GROUDON_BOULDER_HEALTH_1
	GroudonBoulderFrame GROUDONBOULDERFRAME_HEALTH_1_RIGHT, 1, SPRITE2_GROUDON_BOULDER_HEALTH_1
	GroudonBoulderFrame GROUDONBOULDERFRAME_HEALTH_1_LEFT, -1, SPRITE2_GROUDON_BOULDER_HEALTH_1
	GroudonBoulderFrame GROUDONBOULDERFRAME_CRUMBLE_0, 0, SPRITE2_GROUDON_BOULDER_CRUMBLE_0
	GroudonBoulderFrame GROUDONBOULDERFRAME_CRUMBLE_1, 0, SPRITE2_GROUDON_BOULDER_CRUMBLE_1
	GroudonBoulderFrame GROUDONBOULDERFRAME_WAITING_TO_FALL, 0, $FF
	GroudonBoulderFrame GROUDONBOULDERFRAME_FALLING, 0, SPRITE2_GROUDON_BOULDER_HEALTH_3
	GroudonBoulderFrame GROUDONBOULDERFRAME_FELL, 0, SPRITE2_GROUDON_BOULDER_HEALTH_3

UpdateGroudonAnimation:
	ld a, [wGroudonAnimationId]
	sla a
	ld e, a
	ld d, $0
	ld hl, GroudonAnimations
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, wGroudonAnimation
	call UpdateAnimation
	ret nc

	jp nz, .skipStartIdleAnimation
	; When any animation ends, return to the idle animation
	ld a, GROUDONANIMATION_IDLE
	ld [wGroudonAnimationId], a
	sla a
	ld e, a
	ld d, $0
	ld hl, GroudonAnimations
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld de, wGroudonAnimation
	call InitAnimation

.skipStartIdleAnimation
	; Since UpdateAnimation cannot select a frame based on where the pinball is; instead do so here:
	; If this animation just unconditionally updated to the fireball down attack frame,
	; instead select the fireball attack frame that is facing towards the pinball
	ld a, [wGroudonAnimationFrame]
	cp GROUDONFRAME_FIREBALL_DOWN
	jp nz, .skipFireballFacing
	ld a, [wBallXPos + 1]
	cp $68
	jp c, .fireballFacingIsNotRight
	ld a, GROUDONFRAME_FIREBALL_RIGHT
	ld [wGroudonAnimationFrame], a
	jp .skipFireballFacing
.fireballFacingIsNotRight
	cp $38
	jp nc, .skipFireballFacing
	ld a, GROUDONFRAME_FIREBALL_LEFT
	ld [wGroudonAnimationFrame], a

.skipFireballFacing
	; called here instead of in ResolveGroudonBonusGameObjectCollisions
	; so that the limb graphics are only redrawn when the animation frame changes
	call UpdateGroudonLimbGraphics
	ret



UpdateGroudonLimbGraphics:
	ld a, [wGroudonAnimationFrame]
	sla a
	sla a
	ld e, a
	ld d, $0
	ld hl, GroudonFrames
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, BANK(TileDataPointer_GroudonLimbs_Idle0)
	call QueueGraphicsToLoad
	ret

GroudonAnimations:
	MACRO GroudonAnimation
		const \1
		dw \2
	ENDM
	const_def

	GroudonAnimation GROUDONANIMATION_IDLE, IdleGroudonAnimation
	GroudonAnimation GROUDONANIMATION_HIT, HitGroudonAnimation
	;GroudonAnimation GROUDONANIMATION_PROLOGUE, PrologueGroudonAnimation
	GroudonAnimation GROUDONANIMATION_FIREBALL, FireballGroudonAnimation
	GroudonAnimation GROUDONANIMATION_LAVAPLUME, LavaPlumeGroudonAnimation
	GroudonAnimation GROUDONANIMATION_ROCKTOMB, RockTombGroudonAnimation

IdleGroudonAnimation:
	db $28, GROUDONFRAME_IDLE_0
	db $28, GROUDONFRAME_IDLE_1
	db $00 ; terminator

HitGroudonAnimation:
	db $0C, GROUDONFRAME_HIT
	db $00 ; terminator

LavaPlumeGroudonAnimation:
	db $0C, GROUDONFRAME_LAVAPLUME_WINDUP_0
	db $18, GROUDONFRAME_LAVAPLUME_WINDUP_1
	db $08, GROUDONFRAME_LAVAPLUME_WINDUP_2_HALFGLOW
	db $04, GROUDONFRAME_LAVAPLUME_3_FULLGLOW
	db $04, GROUDONFRAME_LAVAPLUME_4
	db $04, GROUDONFRAME_LAVAPLUME_3
	db $04, GROUDONFRAME_LAVAPLUME_4
	db $04, GROUDONFRAME_LAVAPLUME_3
	db $04, GROUDONFRAME_LAVAPLUME_4
	db $04, GROUDONFRAME_LAVAPLUME_3_HALFGLOW
	db $04, GROUDONFRAME_LAVAPLUME_4
	db $04, GROUDONFRAME_LAVAPLUME_3
	db $04, GROUDONFRAME_LAVAPLUME_4
	db $04, GROUDONFRAME_LAVAPLUME_3
	db $04, GROUDONFRAME_LAVAPLUME_4
	db $04, GROUDONFRAME_LAVAPLUME_3
	db $04, GROUDONFRAME_LAVAPLUME_4
	db $04, GROUDONFRAME_LAVAPLUME_3
	db $04, GROUDONFRAME_LAVAPLUME_4
	db $04, GROUDONFRAME_LAVAPLUME_3
	db $04, GROUDONFRAME_LAVAPLUME_4_NOGLOW
	db $04, GROUDONFRAME_LAVAPLUME_3
	db $04, GROUDONFRAME_LAVAPLUME_4
	db $00 ; terminator

RockTombGroudonAnimation:
	db $08, GROUDONFRAME_ROCKTOMB_0
	db $0C, GROUDONFRAME_ROCKTOMB_1
	db $05, GROUDONFRAME_ROCKTOMB_2
	db $05, GROUDONFRAME_ROCKTOMB_3
	db $05, GROUDONFRAME_ROCKTOMB_4
	db $08, GROUDONFRAME_ROCKTOMB_5
	db $08, GROUDONFRAME_ROCKTOMB_6
	db $05, GROUDONFRAME_ROCKTOMB_7
	db $0E, GROUDONFRAME_ROCKTOMB_8
	db $00 ; terminator

FireballGroudonAnimation:
	db $08, GROUDONFRAME_IDLE_1
	db $08, GROUDONFRAME_FIREBALL_WINDUP_0
	db $10, GROUDONFRAME_FIREBALL_WINDUP_1
	db $10, GROUDONFRAME_FIREBALL_DOWN
	db $10, GROUDONFRAME_FIREBALL_RESET
	db $00 ; terminator

GroudonFrames:
	MACRO GroudonFrame
		const \1
		dw \2
		db $00
		db \3
	ENDM
	const_def

	GroudonFrame GROUDONFRAME_IDLE_0, TileDataPointer_GroudonLimbs_Idle0, SPRITE2_GROUDON_IDLE_0
	GroudonFrame GROUDONFRAME_IDLE_1, TileDataPointer_GroudonLimbs_Idle1, SPRITE2_GROUDON_IDLE_1
	GroudonFrame GROUDONFRAME_HIT, TileDataPointer_GroudonLimbs_Hit, SPRITE2_GROUDON_HIT
	GroudonFrame GROUDONFRAME_LAVAPLUME_WINDUP_0, TileDataPointer_GroudonLimbs_LavaPlumeWindup0, SPRITE2_GROUDON_LAVAPLUME_WINDUP_0
	GroudonFrame GROUDONFRAME_LAVAPLUME_WINDUP_1, TileDataPointer_GroudonLimbs_LavaPlumeWindup1, SPRITE2_GROUDON_LAVAPLUME_WINDUP_1
	GroudonFrame GROUDONFRAME_LAVAPLUME_WINDUP_2, TileDataPointer_GroudonLimbs_LavaPlumeWindup2, SPRITE2_GROUDON_LAVAPLUME_WINDUP_2
	GroudonFrame GROUDONFRAME_LAVAPLUME_3, TileDataPointer_GroudonLimbs_LavaPlume3, SPRITE2_GROUDON_LAVAPLUME_3
	GroudonFrame GROUDONFRAME_LAVAPLUME_4, TileDataPointer_GroudonLimbs_LavaPlume4, SPRITE2_GROUDON_LAVAPLUME_4
	GroudonFrame GROUDONFRAME_FIREBALL_WINDUP_0, TileDataPointer_GroudonLimbs_FireballWindup0, SPRITE2_GROUDON_FIREBALL_WINDUP_0
	GroudonFrame GROUDONFRAME_FIREBALL_WINDUP_1, TileDataPointer_GroudonLimbs_FireballWindup1_HalfGlow, SPRITE2_GROUDON_FIREBALL_WINDUP_1
	GroudonFrame GROUDONFRAME_FIREBALL_DOWN, TileDataPointer_GroudonLimbs_FireballDown_NoGlow, SPRITE2_GROUDON_FIREBALL_DOWN
	GroudonFrame GROUDONFRAME_FIREBALL_RIGHT, TileDataPointer_GroudonLimbs_FireballRight_NoGlow, SPRITE2_GROUDON_FIREBALL_RIGHT
	GroudonFrame GROUDONFRAME_FIREBALL_LEFT, TileDataPointer_GroudonLimbs_FireballLeft_NoGlow, SPRITE2_GROUDON_FIREBALL_LEFT
	GroudonFrame GROUDONFRAME_FIREBALL_RESET, TileDataPointer_GroudonLimbs_FireballReset, SPRITE2_GROUDON_FIREBALL_RESET
	GroudonFrame GROUDONFRAME_ROCKTOMB_0, TileDataPointer_GroudonLimbs_RockTomb0, SPRITE2_GROUDON_ROCKTOMB_0
	GroudonFrame GROUDONFRAME_ROCKTOMB_1, TileDataPointer_GroudonLimbs_RockTomb1, SPRITE2_GROUDON_ROCKTOMB_1
	GroudonFrame GROUDONFRAME_ROCKTOMB_2, TileDataPointer_GroudonLimbs_RockTomb2, SPRITE2_GROUDON_ROCKTOMB_2
	GroudonFrame GROUDONFRAME_ROCKTOMB_3, TileDataPointer_GroudonLimbs_RockTomb3, SPRITE2_GROUDON_ROCKTOMB_3
	GroudonFrame GROUDONFRAME_ROCKTOMB_4, TileDataPointer_GroudonLimbs_RockTomb4, SPRITE2_GROUDON_ROCKTOMB_4
	GroudonFrame GROUDONFRAME_ROCKTOMB_5, TileDataPointer_GroudonLimbs_RockTomb5, SPRITE2_GROUDON_ROCKTOMB_5
	GroudonFrame GROUDONFRAME_ROCKTOMB_6, TileDataPointer_GroudonLimbs_RockTomb6, SPRITE2_GROUDON_ROCKTOMB_6
	GroudonFrame GROUDONFRAME_ROCKTOMB_7, TileDataPointer_GroudonLimbs_RockTomb7, SPRITE2_GROUDON_ROCKTOMB_7
	GroudonFrame GROUDONFRAME_ROCKTOMB_8, TileDataPointer_GroudonLimbs_RockTomb8, SPRITE2_GROUDON_ROCKTOMB_8
	GroudonFrame GROUDONFRAME_LAVAPLUME_WINDUP_2_HALFGLOW, TileDataPointer_GroudonLimbs_LavaPlumeWindup2_HalfGlow, SPRITE2_GROUDON_LAVAPLUME_WINDUP_2
	GroudonFrame GROUDONFRAME_LAVAPLUME_3_HALFGLOW, TileDataPointer_GroudonLimbs_LavaPlume3_HalfGlow, SPRITE2_GROUDON_LAVAPLUME_3
	GroudonFrame GROUDONFRAME_LAVAPLUME_3_FULLGLOW, TileDataPointer_GroudonLimbs_LavaPlume3_FullGlow, SPRITE2_GROUDON_LAVAPLUME_3
	GroudonFrame GROUDONFRAME_LAVAPLUME_4_NOGLOW, TileDataPointer_GroudonLimbs_LavaPlume4_NoGlow, SPRITE2_GROUDON_LAVAPLUME_4
