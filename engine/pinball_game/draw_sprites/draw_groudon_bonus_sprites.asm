DrawSpritesGroudonBonus:
	lb bc, 127, 101
	callba DrawTimer
	call DrawGroudonFireball
	call DrawGroudonBoulders
	call DrawGroudonPillars
	callba DrawFlippers
	callba DrawPinball
	call DrawGroudonBodySprite
	ret

DrawGroudonBodySprite:
	ld a, [wGroudonAnimationFrame]
	ld d, $0
	sla a
	rl d
	sla a
	rl d
	or $2
	ld e, a
	ld hl, GroudonFrames
	add hl, de
	ld a, [hl]
	cp $ff
	jr z, .drawSprite1

.drawSprite2
	ld a, [hl+]
	ld e, a

	ld a, [hl]
	ld hl, hSCY
	sub [hl]
	ld c, a

	ld hl, hSCX
	ld a, $40
	sub [hl]
	ld b, a

	ld a, e
	jp LoadOAMData2

.drawSprite1
	inc hl
	ld a, [hl]
	cp $ff
	ret z
	ld e, a

	ld hl, hSCY
	ld a, $28
	sub [hl]
	ld c, a

	ld hl, hSCX
	ld a, $50
	sub [hl]
	ld b, a

	ld a, e
	jp LoadOAMData

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

DrawGroudonPillars:
	ld de, wGroudonPillar0AnimationFrame
	lb bc, (6 * 8), (3 * 8)
	call DrawGroudonOnePillar

	ld de, wGroudonPillar1AnimationFrame
	lb bc, ((8 * 8) + 4), (6 * 8)
	call DrawGroudonOnePillar

	ld de, wGroudonPillar2AnimationFrame
	lb bc, ((11 * 8) + 4), (6 * 8)
	call DrawGroudonOnePillar

	ld de, wGroudonPillar3AnimationFrame
	lb bc, (14 * 8), (3 * 8)
	; fall-through

DrawGroudonOnePillar:
; Input: bc = x,y position
;        de = PillarAnimationFrame
	ld a, b
	ld hl, hSCX
	sub [hl]
	ld b, a
	ld a, [de]
	and 1
	ld hl, hSCY
	sub [hl]
	add c
	ld c, a
	ld a, [de]
	ld e, a
	ld d, $0
	ld hl, GroudonPillarFrames
	add hl, de
	ld a, [hl]
	cp $FF
	call nz, LoadOAMData2
	ret

DrawGroudonFireball:
	ld a, [wGroudonFireballYPos]
	cp $C0
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
	; change a's range to make comparisons not straddle zero
	add $80
	cp $82
	jr c, .notTravelingRight
	ld a, SPRITE2_GROUDON_FIREBALL_FIREBALL_RIGHT
	call LoadOAMData2
	ret
.notTravelingRight
	cp $7E
	jr nc, .notTravelingLeft
	ld a, SPRITE2_GROUDON_FIREBALL_FIREBALL_LEFT
	call LoadOAMData2
	ret
.notTravelingLeft
	ld a, SPRITE2_GROUDON_FIREBALL_FIREBALL_DOWN
	call LoadOAMData2
	ret
