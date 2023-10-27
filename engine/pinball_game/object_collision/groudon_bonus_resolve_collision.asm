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

.idle
	ret

.groudonLavaplumeAnimationInit
	ld a, GROUDONANIMATION_LAVAPLUME
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
	;db $01, GROUDONEVENT_FIREBALL_STARTGROUDONANIMATION
	;db 3 * 60, GROUDONEVENT_FIREBALL_FIRE
	;db 3 * 60, GROUDONEVENT_IDLE
	;db $01, GROUDONEVENT_ROCKTOMB_STARTGROUDONANIMATION
	;db 3 * 60, GROUDONEVENT_ROCKTOMB_SUMMONROCKS
	;db 3 * 60, GROUDONEVENT_IDLE
	;db $01, GROUDONEVENT_FIREBALL_STARTGROUDONANIMATION
	;db 3 * 60, GROUDONEVENT_FIREBALL_FIRE
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
	;GroudonAnimation GROUDONANIMATION_FIREBALL, FireballGroudonAnimation
	GroudonAnimation GROUDONANIMATION_LAVAPLUME, LavaPlumeGroudonAnimation
	;GroudonAnimation GROUDONANIMATION_ROCKTOMB, RockTombGroudonAnimation

IdleGroudonAnimation:
	db $28, GROUDONFRAME_IDLE_0
	db $28, GROUDONFRAME_IDLE_1
	db $00 ; terminator

LavaPlumeGroudonAnimation:
	db $0C, GROUDONFRAME_LAVAPLUME_0
	db $18, GROUDONFRAME_LAVAPLUME_1
	db $08, GROUDONFRAME_LAVAPLUME_2_HALFGLOW
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

GroudonFrames:
	MACRO GroudonFrame
		const \1
		dw \2
		db $00
		db \3
	ENDM
	const_def

	GroudonFrame GROUDONFRAME_FFFFFF, $FFFF, $FF
	GroudonFrame GROUDONFRAME_IDLE_0, TileDataPointer_GroudonLimbs_Idle0, SPRITE_GROUDON_IDLE_0
	GroudonFrame GROUDONFRAME_IDLE_1, TileDataPointer_GroudonLimbs_Idle1, SPRITE_GROUDON_IDLE_1
	GroudonFrame GROUDONFRAME_LAVAPLUME_0, TileDataPointer_GroudonLimbs_LavaPlume0, SPRITE_GROUDON_LAVAPLUME_0
	GroudonFrame GROUDONFRAME_LAVAPLUME_1, TileDataPointer_GroudonLimbs_LavaPlume1, SPRITE_GROUDON_LAVAPLUME_1
	GroudonFrame GROUDONFRAME_LAVAPLUME_2, TileDataPointer_GroudonLimbs_LavaPlume2, SPRITE_GROUDON_LAVAPLUME_2
	GroudonFrame GROUDONFRAME_LAVAPLUME_3, TileDataPointer_GroudonLimbs_LavaPlume3, SPRITE_GROUDON_LAVAPLUME_3
	GroudonFrame GROUDONFRAME_LAVAPLUME_4, TileDataPointer_GroudonLimbs_LavaPlume4, SPRITE_GROUDON_LAVAPLUME_4
	GroudonFrame GROUDONFRAME_LAVAPLUME_2_HALFGLOW, TileDataPointer_GroudonLimbs_LavaPlume2_HalfGlow, SPRITE_GROUDON_LAVAPLUME_2
	GroudonFrame GROUDONFRAME_LAVAPLUME_3_HALFGLOW, TileDataPointer_GroudonLimbs_LavaPlume3_HalfGlow, SPRITE_GROUDON_LAVAPLUME_3
	GroudonFrame GROUDONFRAME_LAVAPLUME_3_FULLGLOW, TileDataPointer_GroudonLimbs_LavaPlume3_FullGlow, SPRITE_GROUDON_LAVAPLUME_3
	GroudonFrame GROUDONFRAME_LAVAPLUME_4_NOGLOW, TileDataPointer_GroudonLimbs_LavaPlume4_NoGlow, SPRITE_GROUDON_LAVAPLUME_4
