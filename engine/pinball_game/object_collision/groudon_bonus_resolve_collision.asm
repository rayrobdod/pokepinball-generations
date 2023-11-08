ResolveGroudonBonusGameObjectCollisions:
	call TryCloseGate_GroudonBonus
	callba PlayLowTimeSfx
	call CheckTimeRanOut_GroudonBonus
	call UpdateGroudonEventTimer
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


EventGroudonAnimation:
	db 3 * 60, GROUDONEVENT_IDLE
	db $0C + $18, GROUDONEVENT_LAVAPLUME_INITGROUDONANIMATION
	;db $18, GROUDONEVENT_LAVAPLUME_BREAKROCKS
	;db 3 * 60, GROUDONEVENT_LAVAPLUME_SPROUTLAVA
	db 3 * 60, GROUDONEVENT_IDLE
	db $20, GROUDONEVENT_FIREBALL_STARTGROUDONANIMATION
	;db 3 * 60, GROUDONEVENT_FIREBALL_FIRE
	db 3 * 60, GROUDONEVENT_IDLE
	db $46, GROUDONEVENT_ROCKTOMB_STARTGROUDONANIMATION
	;db 3 * 60, GROUDONEVENT_ROCKTOMB_SUMMONROCKS
	db 3 * 60, GROUDONEVENT_IDLE
	db $20, GROUDONEVENT_FIREBALL_STARTGROUDONANIMATION
	;db 3 * 60, GROUDONEVENT_FIREBALL_FIRE
	db 3 * 60, GROUDONEVENT_IDLE
	db $00

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
	;GroudonAnimation GROUDONANIMATION_HIT, HitGroudonAnimation
	;GroudonAnimation GROUDONANIMATION_PROLOGUE, PrologueGroudonAnimation
	GroudonAnimation GROUDONANIMATION_FIREBALL, FireballGroudonAnimation
	GroudonAnimation GROUDONANIMATION_LAVAPLUME, LavaPlumeGroudonAnimation
	GroudonAnimation GROUDONANIMATION_ROCKTOMB, RockTombGroudonAnimation

IdleGroudonAnimation:
	db $28, GROUDONFRAME_IDLE_0
	db $28, GROUDONFRAME_IDLE_1
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
