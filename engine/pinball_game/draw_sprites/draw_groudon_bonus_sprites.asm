DrawSpritesGroudonBonus:
	lb bc, 127, 101
	callba DrawTimer
	call DrawGroudonFireball
	call DrawGroudonBoulders
	callba DrawFlippers
	callba DrawPinball
	call DrawGroudonBodySprite
	ret

DrawGroudonBodySprite:
	ld a, $40
	ld hl, hSCX
	sub [hl]
	ld b, a
	ld a, $0
	ld hl, hSCY
	sub [hl]
	ld c, a
	ld a, [wGroudonAnimationFrame]
	sla a
	sla a
	or $3
	ld e, a
	ld d, $0
	ld hl, GroudonFrames
	add hl, de
	ld a, [hl]
	call LoadOAMData2
	ret

DrawGroudonBoulders:
	ld hl, wGroudonBoulder0AnimationId
	call DrawGroudonOneBoulder
	ld hl, wGroudonBoulder1AnimationId
	call DrawGroudonOneBoulder
	ld hl, wGroudonBoulder2AnimationId
	; fall-through

DrawGroudonOneBoulder:
; Input: hl = BoulderAnimationId
	inc hl ; hl = BoulderAnimationFrameCounter
	inc hl ; hl = BoulderAnimationFrame
	push hl
	ld a, [hl]
	sla a
	ld c, a
	ld b, 0
	ld hl, GroudonBoulderFrames
	add hl, bc
	ld a, [hli]
	ld d, a
	ld a, [hl]
	cp $FF
	pop hl ; hl = BoulderXAnimationFrame
	ret z
	ld e, a
	; d = x offset
	; e = sprite id

	ld a, [hld] ; hl = BoulderXAnimationFrameCounter
	cp GROUDONBOULDERFRAME_FALLING
	ld a, 0
	jr nz, .skipFallingYOffset
	ld a, [hl]
	sla a
	cpl
.skipFallingYOffset
	ld bc, 5
	add hl, bc ; hl = BoulderXYPos
	add [hl]
	dec hl ; hl = BoulderXXPos
	push hl
	ld hl, hSCY
	sub [hl]
	ld c, a
	pop hl ; hl = BoulderXXPos

	ld a, [hl]
	ld hl, hSCX
	sub [hl]
	add d
	ld b, a

	ld a, e
	call nz, LoadOAMData2
	ret

DrawGroudonFireball:
	ld a, [wGroudonFireballYPos]
	cp $B0
	ret nc ; disable fireball if it is below play area
	ld hl, hSCY
	sub [hl]
	ld c, a
	ld a, [wGroudonFireballXPos + 1]
	ld hl, hSCX
	sub [hl]
	ld b, a

	ld a, [wGroudonFireballXVelocity + 1]
	; -4 < a < 4
	; change a's range to make comparisons easier
	add $80
	cp $82
	jp c, .notTravelingRight
	ld a, SPRITE2_GROUDON_FIREBALL_FIREBALL_RIGHT
	call LoadOAMData2
	ret
.notTravelingRight
	cp $7E
	jp nc, .notTravelingLeft
	ld a, SPRITE2_GROUDON_FIREBALL_FIREBALL_LEFT
	call LoadOAMData2
	ret
.notTravelingLeft
	ld a, SPRITE2_GROUDON_FIREBALL_FIREBALL_DOWN
	call LoadOAMData2
	ret
