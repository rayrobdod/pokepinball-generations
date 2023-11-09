DrawSpritesGroudonBonus:
	lb bc, 127, 102
	callba DrawTimer
	call DrawGroudonFireball
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
