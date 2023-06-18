HandleBallLossSeelBonus: ; 0xe08b
	xor a
	ld [wd64e], a
	ld a, [wFlippersDisabled]
	and a
	jr z, .flippersEnabled
	ld a, [wCompletedBonusStage]
	and a
	jr z, .asm_e0b8
.flippersEnabled
	ld a, [wSeelStageScore]
	cp 20
	jr nc, .asm_e0b8
	cp 5
	jr c, .asm_e0aa
	sub 4
	jr .asm_e0ab

.asm_e0aa
	xor a
.asm_e0ab
	ld [wSeelStageScore], a
	callba Func_262f4
.asm_e0b8
	ld a, [wCurrentStageBackup]
	ld hl, wCurrentStage
	cp [hl]
	ret z
	ld a, [wd794]
	cp $0
	jr nz, .asm_e0c8
	ret

.asm_e0c8
	lb de, $00, $02
	call PlaySoundEffect
	xor a
	ld [wTimerActive], a
	ld [wTimerActive], a ; duplicate instruction
	ld [wGoingToBonusStage], a
	ld a, $1
	ld [wReturningFromBonusStage], a
	ld a, $2
	ld [wd4c8], a
	xor a
	ld [wDisableHorizontalScrollForBallStart], a
	ld [wd794], a
	ld a, [wCompletedBonusStage]
	and a
	ret nz
	call FillBottomMessageBufferWithBlackTile
	call EnableBottomText
	ld hl, wScrollingText3
	ld de, EndSeelStageText
	call LoadScrollingText
	ret
