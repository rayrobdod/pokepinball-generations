ResolveGroudonBonusGameObjectCollisions:
	call TryCloseGate_GroudonBonus
	callba PlayLowTimeSfx
	call CheckTimeRanOut_GroudonBonus
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
	;GroudonAnimation GROUDONANIMATION_LAVAPLUME, LavaPlumeGroudonAnimation
	;GroudonAnimation GROUDONANIMATION_ROCKTOMB, RockTombGroudonAnimation

IdleGroudonAnimation:
	db $10, GROUDONFRAME_IDLE_0
	db $10, GROUDONFRAME_IDLE_1
	db $10, GROUDONFRAME_IDLE_0
	db $10, GROUDONFRAME_IDLE_1
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
