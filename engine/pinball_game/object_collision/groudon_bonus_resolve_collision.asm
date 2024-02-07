ResolveGroudonBonusGameObjectCollisions:
	call TryCloseGate_GroudonBonus
	callba PlayLowTimeSfx
	call CheckTimeRanOut_GroudonBonus
	call ResolveGroudonCollision
	call ResolveGroudonBoulderCollision
	call ResolveGroudonPillarCollision
	call UpdateGroudonEventTimer
	call UpdateGroudonFireball
	call UpdateGroudonFireballBreakoutCooldown
	call UpdateGroudonFireballBreakoutCounter
	call UpdateGroudonBoulderAnimations
	call UpdateGroudonPillarAnimations
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

FOR X, 0, 4
	ld a, [wGroudonPillar{d:X}Health]
	ld bc, TileDataPointers_GroudonFlamePillar_{d:X}
	call UpdateOneGroudonPillarCollision
ENDR

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

	ld bc, GROUDON_COLLISION_POINTS
	callba AddBigBCD6FromQueueWithBallMultiplier

	ld a, [wNumGroudonHits]
	inc a
	ld [wNumGroudonHits], a

	cp a, NUM_GROUDON_HITS
	jr nc, .groudonDefeated

	; Don't interrupt attack animations with the hit frame
	; Still count the hit, just don't make Groudon flinch
	ld a, [wGroudonAnimationId]
	cp a, GROUDONANIMATION_IDLE
	jr nz, .skipHitAnimation
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
	lb de, $00, $07
	call PlaySoundEffect
	ret

.groudonDefeated
	ld a, $1
	ld [wCompletedBonusStage], a
	ld [wFlippersDisabled], a
	; ld [wNextBonusStage], ???
	call LoadFlippersPalette
	callba StopTimer

	; TODO: alternate between retreat animation and capture animation

.initCaptureAnimation
	ld a, HIGH(GROUDON - 1)
	ld [wCurrentCatchEmMon], a
	ld a, LOW(GROUDON - 1)
	ld [wCurrentCatchEmMon + 1], a

	callba ShowCapturedPokemonText
	callba AddCaughtPokemonToParty
	callba LoadShakeBallGfx

	xor a
	ld [wBallXVelocity], a
	ld [wBallXVelocity + 1], a
	ld [wBallYVelocity], a
	ld [wBallYVelocity + 1], a
	ld [wPinballIsVisible], a
	ld [wEnableBallGravityAndTilt], a

	ld a, GROUDONANIMATION_CATCH
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

	ld a, $1
	ld [wFlippersDisabled], a
	call LoadFlippersPalette
	callba StopTimer

	lb de, $00, $0b
	call PlaySoundEffect

	ld bc, $20 - 6
	ld hl, wStageCollisionMap + $40 + 7
	ld d, 6
	xor a
.clearCollisionY
	ld e, 6
.clearCollisionX
	ld [hl], a
	inc hl
	dec e
	jr nz, .clearCollisionX
	add hl, bc
	dec d
	jr nz, .clearCollisionY

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

ResolveGroudonPillarCollision:
	ld a, [wGroudonPillarCollision]
	and a
	ret z
	xor a
	ld [wGroudonGroudonCollision], a

	ld a, [wGroudonPillarCollisionId]
	dec a
	jr z, .pillar1
	dec a
	jr z, .pillar2
	dec a
	jr z, .pillar3

.pillar0
	ld hl, wGroudonPillar0Health
	ld bc, TileDataPointers_GroudonFlamePillar_0
	ld de, wGroudonPillar0Animation
	jr .do

.pillar1
	ld hl, wGroudonPillar1Health
	ld bc, TileDataPointers_GroudonFlamePillar_1
	ld de, wGroudonPillar1Animation
	jr .do

.pillar2
	ld hl, wGroudonPillar2Health
	ld bc, TileDataPointers_GroudonFlamePillar_2
	ld de, wGroudonPillar2Animation
	jr .do

.pillar3
	ld hl, wGroudonPillar3Health
	ld bc, TileDataPointers_GroudonFlamePillar_3
	ld de, wGroudonPillar3Animation
	jr .do

.do
	ld a, [hl]
	and a
	ret z ; if health is already zero, don't lower health further
	dec a
	ld [hl], a
	push bc
	push de
	push af
	call UpdateOneGroudonPillarCollision

	pop af
	pop de
	push de
	dec de ; de = AnimationId
	ld [de], a
	inc de ; de = Animation
	sla a
	ld c, a
	ld b, $0
	ld hl, GroudonPillarAnimations
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	call InitAnimation

	pop de
	pop bc
	call UpdateOneGroudonPillarGraphics

	ret


UpdateGroudonEventTimer:
	; no more events occur after groudon has been defeated
	ld a, [wNumGroudonHits]
	cp a, NUM_GROUDON_HITS
	ret nc

	ld hl, EventGroudonAnimation
	ld de, wGroudonEventAnimation
	call UpdateAnimation
	ret nc
	jr nz, .skipReset
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
	GroudonEvent GROUDONEVENT_LAVAPLUME_SUMMONPILLARS, .summonPillars
	GroudonEvent GROUDONEVENT_LAVAPLUME_BREAKPILLARS, .breakAllPillars

.idle
	ret

.groudonLavaplumeAnimationInit
	ld a, GROUDONANIMATION_LAVAPLUME
	jr .groudonAnimationInit

.groudonRockTombAnimationInit
	ld a, GROUDONANIMATION_ROCKTOMB
	jr .groudonAnimationInit

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
	jr z, .skipBreakBoulder{d:X}
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

.breakAllPillars
FOR X, 0, 4
	ld a, [wGroudonPillar{d:X}Health]
	and a
	jr z, .skipBreakPillar{d:X}
	xor a
	ld [wGroudonPillar{d:X}Health], a
	assert 0 == GROUDONPILLARANIMATION_DEFEAT
	ld [wGroudonPillar{d:X}AnimationId], a

	ld bc, TileDataPointers_GroudonFlamePillar_{d:X}
	call UpdateOneGroudonPillarCollision

	ld hl, GroudonPillarHealth0Animation
	ld de, wGroudonPillar{d:X}Animation
	call InitAnimation

	ld bc, TileDataPointers_GroudonFlamePillar_{d:X}
	ld de, wGroudonPillar{d:X}Animation
	call UpdateOneGroudonPillarGraphics
.skipBreakPillar{d:X}
ENDR
	ret

.summonPillars
	ld a, GROUDONPILLARANIMATION_SUMMON
FOR X, 0, 4
	ld [wGroudonPillar{d:X}AnimationId], a
ENDR

FOR X, 0, 4
	ld hl, GroudonPillarSummonAnimation
	ld de, wGroudonPillar{d:X}Animation
	call InitAnimation

	ld bc, TileDataPointers_GroudonFlamePillar_{d:X}
	ld de, wGroudonPillar{d:X}Animation
	call UpdateOneGroudonPillarGraphics
ENDR
	ret

EventGroudonAnimation:
; Pinball RS behavior:
;   prologue has Groudon and three boulders drop from above.
;   the first attack is four seconds after groudon drops.
;   about six or seven seconds between each attack
;   attack order is: lava plume barriers -> fireball -> boulder drop -> fireball -> repeat

	db (3 * 60) - 8, GROUDONEVENT_IDLE
	db 8, GROUDONEVENT_LAVAPLUME_BREAKPILLARS
	db $0C + $18, GROUDONEVENT_LAVAPLUME_INITGROUDONANIMATION
	db $18, GROUDONEVENT_LAVAPLUME_BREAKROCKS
	db 3 * 60, GROUDONEVENT_LAVAPLUME_SUMMONPILLARS
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
	cp $C0
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
	jr nz, .checkCooldown
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
;        de = BoulderAnimation pointer
	sla a

	add LOW(GroudonBoulderAnimations)
	ld l, a
	adc HIGH(GroudonBoulderAnimations)
	sub l
	ld h, a
	; hl = GroudonBoulderAnimations + `AnimId` * 2

	ld a, [hli]
	ld h, [hl]
	ld l, a
	call UpdateAnimation
	ret nc

	inc de ; de = BoulderAnimationFrame
	ld a, [de]
	cp GROUDONBOULDERFRAME_WAITING_TO_FALL
	; stagger the boulders' fall somewhat
	jr nz, .skipWaitingToFall
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
	jr nz, .skipFalling
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
	jr nz, .skipHealth3
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


UpdateGroudonPillarAnimations:
	ld de, wGroudonPillar0AnimationId
	ld bc, TileDataPointers_GroudonFlamePillar_0
	call UpdateOneGroudonPillarAnimation

	ld de, wGroudonPillar1AnimationId
	ld bc, TileDataPointers_GroudonFlamePillar_1
	call UpdateOneGroudonPillarAnimation

	ld de, wGroudonPillar2AnimationId
	ld bc, TileDataPointers_GroudonFlamePillar_2
	call UpdateOneGroudonPillarAnimation

	ld de, wGroudonPillar3AnimationId
	ld bc, TileDataPointers_GroudonFlamePillar_3
	; fall-through

UpdateOneGroudonPillarAnimation:
; Input: de = pointer to the pillar's animation id
;        bc = TileDataPointers for the pillar
	push bc
	ld a, [de]
	sla a
	ld c, a
	ld b, $0
	ld hl, GroudonPillarAnimations
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc de ; de = Animation (FrameCounter)
	call UpdateAnimation
	pop bc
	ret nc

	jr nz, .skipRestartAnimation
	dec de ; de = AnimationId
	ld a, [de]
	cp GROUDONPILLARANIMATION_DEFEAT
	ret z
	cp GROUDONPILLARANIMATION_SUMMON
	jr nz, .skipSummonAnimationFinished
	dec a
	ld [de], a
	ld hl, 4
	add hl, de ; hl = Health
	ld a, GROUDON_PILLAR_HEALTH
	ld [hl], a
	push de
	push bc
	call UpdateOneGroudonPillarCollision
	pop bc
	pop de
.skipSummonAnimationFinished
	push bc
	sla a
	ld c, a
	ld b, $0
	ld hl, GroudonPillarAnimations
	add hl, bc
	ld a, [hli]
	ld h, [hl]
	ld l, a
	inc de ; de = Animation (FrameCounter)
	push de
	call InitAnimation
	pop de
	pop bc
.skipRestartAnimation
	; fall-though

UpdateOneGroudonPillarGraphics:
; Input: de = pointer to the pillar's animation
;        bc = TileDataPointers for the pillar
	inc de ; AnimationFrame
	ld a, [de]
	sla a
	ld e, a
	ld d, $0
	ld h, b
	ld l, c
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ld a, BANK(TileDataPointers_GroudonFlamePillar_1)
	call QueueGraphicsToLoad
	ret

UpdateOneGroudonPillarCollision:
; Input: a = the pillar's health
;        bc = TileDataPointers for the pillar
	and a
	ld l, GROUDONPILLAR_COLLISION_OFF * 2
	jr z, .healthIsZero
	ld l, GROUDONPILLAR_COLLISION_ON * 2
.healthIsZero
	ld h, 0
	add hl, bc
	ld a, [hli]
	ld d, [hl]
	ld e, a
	call LoadTileLists
	ret

GroudonPillarAnimations:
	MACRO GroudonPillarAnimation
		const \1
		dw \2
	ENDM
	const_def

	GroudonPillarAnimation GROUDONPILLARANIMATION_DEFEAT, GroudonPillarHealth0Animation
	GroudonPillarAnimation GROUDONPILLARANIMATION_HEALTH1, GroudonPillarHealth1Animation
	GroudonPillarAnimation GROUDONPILLARANIMATION_HEALTH2, GroudonPillarHealth2Animation
	GroudonPillarAnimation GROUDONPILLARANIMATION_HEALTH3, GroudonPillarHealth3Animation
	GroudonPillarAnimation GROUDONPILLARANIMATION_SUMMON, GroudonPillarSummonAnimation

GroudonPillarHealth0Animation:
	db $03, GROUDONPILLARFRAME_SUMMON2
	db $03, GROUDONPILLARFRAME_SUMMON0
	db $01, GROUDONPILLARFRAME_HIDDEN
	db $00

GroudonPillarHealth1Animation:
	db $10, GROUDONPILLARFRAME_HEALTH1_0
	db $10, GROUDONPILLARFRAME_HEALTH1_1
	db $00

GroudonPillarHealth2Animation:
	db $10, GROUDONPILLARFRAME_HEALTH2_0
	db $10, GROUDONPILLARFRAME_HEALTH2_1
	db $00

GroudonPillarHealth3Animation:
	db $10, GROUDONPILLARFRAME_HEALTH3_0
	db $10, GROUDONPILLARFRAME_HEALTH3_1
	db $00

GroudonPillarSummonAnimation:
	db $0c, GROUDONPILLARFRAME_SUMMON0
	db $08, GROUDONPILLARFRAME_SUMMON1
	db $06, GROUDONPILLARFRAME_SUMMON2
	db $00

GroudonPillarFrames:
	; The order of these should match the order of `TileDataPointers_GroudonFlamePillar_X`
	MACRO GroudonPillarFrame
		const \1
		db \2
	ENDM
	const_def

	GroudonPillarFrame GROUDONPILLARFRAME_HIDDEN, $FF
	GroudonPillarFrame GROUDONPILLARFRAME_SUMMON0, $FF
	GroudonPillarFrame GROUDONPILLARFRAME_SUMMON1, $FF
	GroudonPillarFrame GROUDONPILLARFRAME_SUMMON2, $FF
	GroudonPillarFrame GROUDONPILLARFRAME_HEALTH1_0, SPRITE2_GROUDON_PILLAR_HEALTH_1
	GroudonPillarFrame GROUDONPILLARFRAME_HEALTH1_1, SPRITE2_GROUDON_PILLAR_HEALTH_1
	GroudonPillarFrame GROUDONPILLARFRAME_HEALTH2_0, SPRITE2_GROUDON_PILLAR_HEALTH_2
	GroudonPillarFrame GROUDONPILLARFRAME_HEALTH2_1, SPRITE2_GROUDON_PILLAR_HEALTH_2
	GroudonPillarFrame GROUDONPILLARFRAME_HEALTH3_0, SPRITE2_GROUDON_PILLAR_HEALTH_3
	GroudonPillarFrame GROUDONPILLARFRAME_HEALTH3_1, SPRITE2_GROUDON_PILLAR_HEALTH_3
	const GROUDONPILLAR_COLLISION_OFF
	const GROUDONPILLAR_COLLISION_ON


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

	jr nz, .skipStartIdleAnimation
	ld a, [wGroudonAnimationId]
	cp GROUDONANIMATION_CATCH
	jr z, .finishCatch
	; When any animation other than RETREAT and CATCH ends, return to the idle animation
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
	jr nz, .skipFireballFacing
	ld a, [wBallXPos + 1]
	cp $68
	jr c, .fireballFacingIsNotRight
	ld a, GROUDONFRAME_FIREBALL_RIGHT
	ld [wGroudonAnimationFrame], a
	jr .skipFireballFacing
.fireballFacingIsNotRight
	cp $38
	jr nc, .skipFireballFacing
	ld a, GROUDONFRAME_FIREBALL_LEFT
	ld [wGroudonAnimationFrame], a
.skipFireballFacing

	ld a, [wGroudonAnimationFrame]
	cp GROUDONFRAME_CATCH_12
	jr nz, .skipPlayPokeballWiggleSfx
	lb de, $00, $41
	call PlaySoundEffect
.skipPlayPokeballWiggleSfx

	; called here instead of in ResolveGroudonBonusGameObjectCollisions
	; so that the limb graphics are only redrawn when the animation frame changes
	call UpdateGroudonLimbGraphics
	ret

.finishCatch
	call MainLoopUntilTextIsClear
	ld a, $50
	ld [wBallXPos + 1], a
	ld a, $30
	ld [wBallYPos + 1], a
	ld a, $80
	ld [wBallXVelocity], a
	ld a, GROUDONFRAME_HIDDEN
	ld [wGroudonAnimationFrame], a
	xor a
	ld [wBallXPos], a
	ld [wBallYPos], a
	ld a, $1
	ld [wPinballIsVisible], a
	ld [wEnableBallGravityAndTilt], a

	call FillBottomMessageBufferWithBlackTile
	call EnableBottomText
	ld hl, wScrollingText3
	ld de, GroudonStageClearedText
	call LoadScrollingText
	lb de, $4b, $2a
	call PlaySoundEffect

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
	;GroudonAnimation GROUDONANIMATION_RETREAT, RetreatGroudonAnimation
	GroudonAnimation GROUDONANIMATION_CATCH, CatchGroudonAnimation

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

CatchGroudonAnimation:
	; cannot use CapturePokemonAnimation
	; since CapturePokemonAnimation performs unwanted state changes
	; such as changing the music, showing a jackpot and changing the BallSaver lights

	; cannot UpdateAnimation using BallCaptureAnimationData since BallCaptureAnimationData is in a different bank

	; thus, requiring this duplication of BallCaptureAnimationData
	db $05, GROUDONFRAME_CATCH_0
	db $05, GROUDONFRAME_CATCH_1
	db $05, GROUDONFRAME_CATCH_2
	db $04, GROUDONFRAME_CATCH_3
	db $06, GROUDONFRAME_CATCH_4
	db $08, GROUDONFRAME_CATCH_5
	db $07, GROUDONFRAME_CATCH_6
	db $05, GROUDONFRAME_CATCH_7
	db $04, GROUDONFRAME_CATCH_8
	db $04, GROUDONFRAME_CATCH_9
	db $04, GROUDONFRAME_CATCH_10
	db $04, GROUDONFRAME_CATCH_11
	db $24, GROUDONFRAME_CATCH_10
	db $09, GROUDONFRAME_CATCH_12
	db $09, GROUDONFRAME_CATCH_10
	db $09, GROUDONFRAME_CATCH_12
	db $27, GROUDONFRAME_CATCH_10
	db $09, GROUDONFRAME_CATCH_12
	db $09, GROUDONFRAME_CATCH_10
	db $09, GROUDONFRAME_CATCH_12
	db $24, GROUDONFRAME_CATCH_10
	db $01, GROUDONFRAME_CATCH_10
	db $00

GroudonFrames:
	MACRO GroudonFrame
		const \1
		dw \2
		db \3
		db \4
	ENDM
	const_def

	GroudonFrame GROUDONFRAME_IDLE_0, TileDataPointer_GroudonLimbs_Idle0, $FF, SPRITE2_GROUDON_IDLE_0
	GroudonFrame GROUDONFRAME_IDLE_1, TileDataPointer_GroudonLimbs_Idle1, $FF, SPRITE2_GROUDON_IDLE_1
	GroudonFrame GROUDONFRAME_HIT, TileDataPointer_GroudonLimbs_Hit, $FF, SPRITE2_GROUDON_HIT
	GroudonFrame GROUDONFRAME_LAVAPLUME_WINDUP_0, TileDataPointer_GroudonLimbs_LavaPlumeWindup0, $FF, SPRITE2_GROUDON_LAVAPLUME_WINDUP_0
	GroudonFrame GROUDONFRAME_LAVAPLUME_WINDUP_1, TileDataPointer_GroudonLimbs_LavaPlumeWindup1, $FF, SPRITE2_GROUDON_LAVAPLUME_WINDUP_1
	GroudonFrame GROUDONFRAME_LAVAPLUME_WINDUP_2, TileDataPointer_GroudonLimbs_LavaPlumeWindup2, $FF, SPRITE2_GROUDON_LAVAPLUME_WINDUP_2
	GroudonFrame GROUDONFRAME_LAVAPLUME_3, TileDataPointer_GroudonLimbs_LavaPlume3, $FF, SPRITE2_GROUDON_LAVAPLUME_3
	GroudonFrame GROUDONFRAME_LAVAPLUME_4, TileDataPointer_GroudonLimbs_LavaPlume4, $FF, SPRITE2_GROUDON_LAVAPLUME_4
	GroudonFrame GROUDONFRAME_FIREBALL_WINDUP_0, TileDataPointer_GroudonLimbs_FireballWindup0, $FF, SPRITE2_GROUDON_FIREBALL_WINDUP_0
	GroudonFrame GROUDONFRAME_FIREBALL_WINDUP_1, TileDataPointer_GroudonLimbs_FireballWindup1_HalfGlow, $FF, SPRITE2_GROUDON_FIREBALL_WINDUP_1
	GroudonFrame GROUDONFRAME_FIREBALL_DOWN, TileDataPointer_GroudonLimbs_FireballDown_NoGlow, $FF, SPRITE2_GROUDON_FIREBALL_DOWN
	GroudonFrame GROUDONFRAME_FIREBALL_RIGHT, TileDataPointer_GroudonLimbs_FireballRight_NoGlow, $FF, SPRITE2_GROUDON_FIREBALL_RIGHT
	GroudonFrame GROUDONFRAME_FIREBALL_LEFT, TileDataPointer_GroudonLimbs_FireballLeft_NoGlow, $FF, SPRITE2_GROUDON_FIREBALL_LEFT
	GroudonFrame GROUDONFRAME_FIREBALL_RESET, TileDataPointer_GroudonLimbs_FireballReset, $FF, SPRITE2_GROUDON_FIREBALL_RESET
	GroudonFrame GROUDONFRAME_ROCKTOMB_0, TileDataPointer_GroudonLimbs_RockTomb0, $FF, SPRITE2_GROUDON_ROCKTOMB_0
	GroudonFrame GROUDONFRAME_ROCKTOMB_1, TileDataPointer_GroudonLimbs_RockTomb1, $FF, SPRITE2_GROUDON_ROCKTOMB_1
	GroudonFrame GROUDONFRAME_ROCKTOMB_2, TileDataPointer_GroudonLimbs_RockTomb2, $FF, SPRITE2_GROUDON_ROCKTOMB_2
	GroudonFrame GROUDONFRAME_ROCKTOMB_3, TileDataPointer_GroudonLimbs_RockTomb3, $FF, SPRITE2_GROUDON_ROCKTOMB_3
	GroudonFrame GROUDONFRAME_ROCKTOMB_4, TileDataPointer_GroudonLimbs_RockTomb4, $FF, SPRITE2_GROUDON_ROCKTOMB_4
	GroudonFrame GROUDONFRAME_ROCKTOMB_5, TileDataPointer_GroudonLimbs_RockTomb5, $FF, SPRITE2_GROUDON_ROCKTOMB_5
	GroudonFrame GROUDONFRAME_ROCKTOMB_6, TileDataPointer_GroudonLimbs_RockTomb6, $FF, SPRITE2_GROUDON_ROCKTOMB_6
	GroudonFrame GROUDONFRAME_ROCKTOMB_7, TileDataPointer_GroudonLimbs_RockTomb7, $FF, SPRITE2_GROUDON_ROCKTOMB_7
	GroudonFrame GROUDONFRAME_ROCKTOMB_8, TileDataPointer_GroudonLimbs_RockTomb8, $FF, SPRITE2_GROUDON_ROCKTOMB_8
	GroudonFrame GROUDONFRAME_LAVAPLUME_WINDUP_2_HALFGLOW, TileDataPointer_GroudonLimbs_LavaPlumeWindup2_HalfGlow, $FF, SPRITE2_GROUDON_LAVAPLUME_WINDUP_2
	GroudonFrame GROUDONFRAME_LAVAPLUME_3_HALFGLOW, TileDataPointer_GroudonLimbs_LavaPlume3_HalfGlow, $FF, SPRITE2_GROUDON_LAVAPLUME_3
	GroudonFrame GROUDONFRAME_LAVAPLUME_3_FULLGLOW, TileDataPointer_GroudonLimbs_LavaPlume3_FullGlow, $FF, SPRITE2_GROUDON_LAVAPLUME_3
	GroudonFrame GROUDONFRAME_LAVAPLUME_4_NOGLOW, TileDataPointer_GroudonLimbs_LavaPlume4_NoGlow, $FF, SPRITE2_GROUDON_LAVAPLUME_4
	; TODO: after pret merge, replace following `$19 + XX`s with `SPRITE_BALL_CAPTURE_XX`
	GroudonFrame GROUDONFRAME_CATCH_0, TileDataPointer_GroudonLimbs_Hidden, $19 + 0, $FF
	GroudonFrame GROUDONFRAME_CATCH_1, TileDataPointer_GroudonLimbs_Hidden, $19 + 1, $FF
	GroudonFrame GROUDONFRAME_CATCH_2, TileDataPointer_GroudonLimbs_Hidden, $19 + 2, $FF
	GroudonFrame GROUDONFRAME_CATCH_3, TileDataPointer_GroudonLimbs_Hidden, $19 + 3, $FF
	GroudonFrame GROUDONFRAME_CATCH_4, TileDataPointer_GroudonLimbs_Hidden, $19 + 4, $FF
	GroudonFrame GROUDONFRAME_CATCH_5, TileDataPointer_GroudonLimbs_Hidden, $19 + 5, $FF
	GroudonFrame GROUDONFRAME_CATCH_6, TileDataPointer_GroudonLimbs_Hidden, $19 + 6, $FF
	GroudonFrame GROUDONFRAME_CATCH_7, TileDataPointer_GroudonLimbs_Hidden, $19 + 7, $FF
	GroudonFrame GROUDONFRAME_CATCH_8, TileDataPointer_GroudonLimbs_Hidden, $19 + 8, $FF
	GroudonFrame GROUDONFRAME_CATCH_9, TileDataPointer_GroudonLimbs_Hidden, $19 + 9, $FF
	GroudonFrame GROUDONFRAME_CATCH_10, TileDataPointer_GroudonLimbs_Hidden, $19 + 10, $FF
	GroudonFrame GROUDONFRAME_CATCH_11, TileDataPointer_GroudonLimbs_Hidden, $19 + 11, $FF
	GroudonFrame GROUDONFRAME_CATCH_12, TileDataPointer_GroudonLimbs_Hidden, $19 + 12, $FF
	GroudonFrame GROUDONFRAME_HIDDEN, TileDataPointer_GroudonLimbs_Hidden, $FF, $FF
