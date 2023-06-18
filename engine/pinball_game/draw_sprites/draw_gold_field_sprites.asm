DrawSpritesGoldFieldTop:
	ld bc, $7f00
	callba DrawTimer
	callba DrawVoltorbSprites_GoldField
	call DrawDitto_GoldField
	call DrawBellsproutHead_GoldField
	call DrawBellsproutBody_GoldField
	call DrawStaryu_GoldField
	call DrawSpinner_GoldField
	callba DrawPinball
	call DrawEvolutionIndicatorArrows_GoldFieldTop
	call DrawEvolutionTrinket_GoldFieldTop
	ret

DrawSpritesGoldFieldBottom: ; 0x1757e
	ld bc, $7f00
	callba DrawTimer
	callba DrawMonCaptureAnimation
	call DrawAnimatedMon_GoldField
	call DrawPikachuSavers_GoldField
	callba DrawFlippers
	callba DrawPinball
	call DrawEvolutionIndicatorArrows_GoldFieldBottom
	call DrawEvolutionTrinket_GoldFieldBottom
	call DrawSlotGlow_GoldField
	ret

DrawAnimatedMon_GoldField: ; 0x17c96
	ld a, [wWildMonIsHittable]
	and a
	ret z
	ld a, $50
	ld hl, hSCX
	sub [hl]
	ld b, a
	ld a, $3e
	ld hl, hSCY
	sub [hl]
	ld c, a
	ld a, [wCurrentAnimatedMonSpriteFrame]
	ld e, a
	ld d, $0
	ld hl, AnimatedMonOAMIds_GoldField
	add hl, de
	ld a, [hl]
	call LoadOAMData
	ret

AnimatedMonOAMIds_GoldField:
	db $26, $27, $28, $29, $2A, $2B, $2C, $2D, $2E, $2F, $30, $31

DrawVoltorbSprites_GoldField: ; 0x17cc4
	ld de, wVoltorb1Animation
	ld hl, OAMData_17d15_GoldField
	call DrawVoltorbSprite_GoldField
	ld de, wVoltorb2Animation
	ld hl, OAMData_17d1b_GoldField
	call DrawVoltorbSprite_GoldField
	ld de, wVoltorb3Animation
	ld hl, OAMData_17d21_GoldField
	; fall through

DrawVoltorbSprite_GoldField: ; 0x17cdc
	push hl
	ld hl, AnimationData_17d27_GoldField
	call UpdateAnimation
	ld h, d
	ld l, e
	ld a, [hl] ;if counter is 0
	and a
	jr nz, .asm_17cf6
	call GenRandom
	and $f ;rand 37-30
	add $12
	ld [hli], a ;replace animation counter with new number
	ld a, $1
	ld [hli], a
	xor a
	ld [hl], a
.asm_17cf6
	pop hl
	inc de ;animation byte 2
	ld a, [hSCX]
	ld b, a
	ld a, [hli]
	sub b
	ld b, a
	ld a, [hSCY]
	ld c, a
	ld a, [hli]
	sub c
	ld c, a
	ld a, [wWhichAnimatedVoltorb]
	sub [hl]
	inc hl
	jr z, .asm_17d0c ;if voltorb is animated, load frame into a, otherwise a is 0
	ld a, [de]
.asm_17d0c
	ld e, a
	ld d, $0
	add hl, de ;load in appropriate OAM ID
	ld a, [hl]
	call LoadOAMData
	ret

OAMData_17d15_GoldField:
	db $3A, $4E ; x, y offsets
	db $00 ; attached voltorb
	db $BD, $BC, $F9 ; oam ids

OAMData_17d1b_GoldField:
	db $53, $44 ; x, y offsets
	db $01 ; attached voltorb
	db $BD, $BC, $F9 ; oam ids

OAMData_17d21_GoldField:
	db $4D, $60 ; x, y offsets
	db $02 ; attached voltorb
	db $BD, $BC, $F9 ; oam ids

AnimationData_17d27_GoldField:
; Each entry is [duration][OAM id]
	db $1E, $01
	db $1E, $02
	db $00 ; terminator

DrawDitto_GoldField: ; 0x17d34
	ld a, $0
	ld hl, hSCX
	sub [hl]
	ld b, a
	ld a, $10
	ld hl, hSCY
	sub [hl]
	ld c, a
	ld a, [wStageCollisionState]
	ld e, a
	ld d, $0
	ld hl, OAMIds_17d51_GoldField
	add hl, de
	ld a, [hl]
	call LoadOAMData
	ret

OAMIds_17d51_GoldField:
	db $C9
	db $C9
	db $C9
	db $C9
	db $C8
	db $C8
	db $CA
	db $CA

DrawBellsproutHead_GoldField: ; 0x17d59
	ld a, $74
	ld hl, hSCX
	sub [hl]
	ld b, a
	ld a, $52
	ld hl, hSCY
	sub [hl]
	ld c, a
	ld a, [wBellsproutAnimationFrame]
	ld e, a
	ld d, $0
	ld hl, BellsproutHeadAnimationOAMIds_GoldField
	add hl, de
	ld a, [hl]
	call LoadOAMData
	ret

BellsproutHeadAnimationOAMIds_GoldField: ; 0x17d76
	db $FB
	db $FC
	db $FD
	db $FE

DrawBellsproutBody_GoldField: ; 0x17d7a
	ld a, [hGameBoyColorFlag]
	and a
	ret z
	ld a, $67
	ld hl, hSCX
	sub [hl]
	ld b, a
	ld a, $54
	ld hl, hSCY
	sub [hl]
	ld c, a
	ld a, $FA
	call LoadOAMData
	ret

DrawStaryu_GoldField: ; 0x17d92
	ld a, [hGameBoyColorFlag]
	and a
	ret z
	ld hl, AnimationData_17dd0_GoldField
	ld de, wStaryuAnimation
	call UpdateAnimation
	ld a, [wStaryuAnimationFrameCounter]
	and a
	jr nz, .drawStaryu
	ld a, $13
	ld [wStaryuAnimationFrameCounter], a
	xor a
	ld [wStaryuAnimationFrame], a
	ld [wStaryuAnimationIndex], a
.drawStaryu
	ld a, $2b
	ld hl, hSCX
	sub [hl]
	ld b, a
	ld a, $69
	ld hl, hSCY
	sub [hl]
	ld c, a
	ld a, [wStaryuAnimationFrame]
	ld e, a
	ld d, $0
	ld hl, OAMIds_17dce_GoldField
	add hl, de
	ld a, [hl]
	call LoadOAMData2
	ret

OAMIds_17dce_GoldField: ; 0x17dce
	db $8F
	db $90

AnimationData_17dd0_GoldField:
; Each entry is [duration][OAM id]
	db $14, $00
	db $13, $01
	db $15, $00
	db $12, $01
	db $14, $00
	db $13, $01
	db $16, $00
	db $13, $01
	db $0 ; terminator

DrawSpinner_GoldField: ; 0x17de1
	ld a, $88
	ld hl, hSCX
	sub [hl]
	ld b, a
	ld a, $5a
	ld hl, hSCY
	sub [hl]
	ld c, a
	ld a, [wSpinnerState + 1]
	srl a
	srl a
	ld e, a
	ld d, $0
	ld hl, SpinnerOAMIds_GoldField
	add hl, de
	ld a, [hl]
	call LoadOAMData2
	ret

SpinnerOAMIds_GoldField: ; 0x17e02
	db $89, $8A, $8B, $8C, $8D, $8E

DrawPikachuSavers_GoldField: ; 0x17e08
	ld a, [hSCX]
	ld d, a
	ld a, [hSCY]
	ld e, a
	ld a, [wPikachuSaverSlotRewardActive]
	and a
	ld a, [wWhichPikachuSaverSide]
	jr z, .asm_17e33
	ld a, [wd51c]
	and a
	jr nz, .asm_17e29
	ld a, [hFrameCounter]
	srl a
	srl a
	srl a
	and $1
	jr .asm_17e33

.asm_17e29
	ld a, [wBallXPos + 1]
	cp $50
	ld a, $1
	jr nc, .asm_17e33
	xor a
.asm_17e33
	sla a
	ld c, a
	ld b, $0
	ld hl, PikachuSaverOAMOffsets_GoldStage
	add hl, bc
	ld a, [hli]
	sub d
	ld b, a
	ld a, [hli]
	sub e
	ld c, a
	ld a, [wPikachuSaverAnimationFrame]
	add $e
	call LoadOAMData
	ret

PikachuSaverOAMOffsets_GoldStage:
	dw $7E0F
	dw $7E92

DrawEvolutionIndicatorArrows_GoldFieldTop: ; 0x17efb
	ld a, [wEvolutionObjectsDisabled]
	and a
	ret nz
	ld a, [hFrameCounter]
	bit 4, a
	ret z
	ld de, wIndicatorStates + 5
	ld hl, EvolutionIndicatorArrowsOAM_GoldFieldTop
	ld b, $6
	jr DrawEvolutionIndicatorArrows_GoldField

DrawEvolutionIndicatorArrows_GoldFieldBottom: ; 0x17f0f
	ld a, [wEvolutionObjectsDisabled]
	and a
	ret nz
	ld a, [hFrameCounter]
	bit 4, a
	ret z
	ld de, wIndicatorStates + 11
	ld hl, EvolutionIndicatorArrowsOAM_GoldFieldBottom
	ld b, $8
DrawEvolutionIndicatorArrows_GoldField: ; 0x17f21
	push bc
	ld a, [hSCX]
	ld b, a
	ld a, [hli]
	sub b
	ld b, a
	ld a, [hSCY]
	ld c, a
	ld a, [hli]
	sub c
	ld c, a
	ld a, [de]
	and a
	ld a, [hli]
	call nz, LoadOAMData
	pop bc
	inc de
	dec b
	jr nz, DrawEvolutionIndicatorArrows_GoldField
	ret

EvolutionIndicatorArrowsOAM_GoldFieldTop:
	db $0D, $37 ; x, y offsets
	db $D1 ; oam id

	db $46, $22 ; x, y offsets
	db $D6 ; oam id

	db $8A, $4A ; x, y offsets
	db $D2 ; oam id

	db $41, $81 ; x, y offsets
	db $D3 ; oam id

	db $3D, $65 ; x, y offsets
	db $D5 ; oam id

	db $73, $74 ; x, y offsets
	db $D4 ; oam id

EvolutionIndicatorArrowsOAM_GoldFieldBottom:
	db $2D, $13 ; x, y offsets
	db $32 ; oam id

	db $6A, $13 ; x, y offsets
	db $33 ; oam id

	db $25, $2D ; x, y offsets
	db $34 ; oam id

	db $73, $2D ; x, y offsets
	db $35 ; oam id

	db $0F, $40 ; x, y offsets
	db $36 ; oam id

	db $1F, $40 ; x, y offsets
	db $36 ; oam id

	db $79, $40 ; x, y offsets
	db $37 ; oam id

	db $89, $40 ; x, y offsets
	db $37 ; oam id

DrawEvolutionTrinket_GoldFieldTop: ; 0x17f64
	ld a, [wEvolutionObjectsDisabled]
	and a
	ret z
	ld de, wActiveEvolutionTrinkets
	ld hl, EvolutionTrinketOAMOffsets_GoldFieldTop
	ld b, $c
	ld c, $39
	jr DrawEvolutionTrinket_GoldField

DrawEvolutionTrinket_GoldFieldBottom: ; 0x17f75
	ld a, [wEvolutionObjectsDisabled]
	and a
	ret z
	ld de, wActiveEvolutionTrinkets + 12
	ld hl, EvolutionTrinketOAMOffsets_GoldFieldBottom
	ld b, $6
	ld c, $40
DrawEvolutionTrinket_GoldField: ; 0x17f84
	push bc
	ld a, [de]
	add c
	cp c
	push af
	ld a, [hSCX]
	ld b, a
	ld a, [hli]
	sub b
	ld b, a
	ld a, [hSCY]
	ld c, a
	ld a, [hli]
	sub c
	ld c, a
	ld a, [hFrameCounter]
	and $e
	jr nz, .asm_17f9c
	dec c
.asm_17f9c
	pop af
	call nz, LoadOAMData
	pop bc
	inc de
	dec b
	jr nz, DrawEvolutionTrinket_GoldField
	ret

EvolutionTrinketOAMOffsets_GoldFieldTop:
; x, y offsets
	db $4C, $0C
	db $32, $12
	db $66, $12
	db $19, $25
	db $7F, $25
	db $1E, $36
	db $7F, $36
	db $0E, $65
	db $8B, $65
	db $49, $7A
	db $59, $7A
	db $71, $7A

EvolutionTrinketOAMOffsets_GoldFieldBottom:
; x, y offsets
	db $3D, $13
	db $5B, $13
	db $31, $17
	db $67, $17
	db $2E, $2C
	db $6A, $2C

DrawSlotGlow_GoldField: ; 0x17fca
; Draws the glowing animation surround the slot cave entrance.
	ld a, [wSlotIsOpen]
	and a
	ret z
	ld a, [wSlotGlowingAnimationCounter]
	inc a
	ld [wSlotGlowingAnimationCounter], a
	ld a, $40
	ld hl, hSCX
	sub [hl]
	ld b, a
	ld a, $1
	ld hl, hSCY
	sub [hl]
	ld c, a
	ld a, [wSlotGlowingAnimationCounter]
	srl a
	srl a
	srl a
	and $3
	add $4f
	cp $52
	call nz, LoadOAMData
	ret
