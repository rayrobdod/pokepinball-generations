DrawSpritesGroudonBonus:
	lb bc, 127, 102
	callba DrawTimer
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
