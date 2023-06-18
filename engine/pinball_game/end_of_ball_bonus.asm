EndOfBallBonus:
	call FillBottomMessageBufferWithBlackTile
	call LoadEAcuteCharacterGfx
	call Func_f57f
	ld a, $60
	ld [hWY], a
	dec a
	ld [hLYC], a
	ld a, $fd
	ld [hLCDCMask], a
	call ShowBallBonusSummary
	ld a, $90
	ld [hWY], a
	ld a, $83
	ld [hLYC], a
	ld [hLastLYC], a
	ld a, $ff
	ld [hLCDCMask], a
	call FillBottomMessageBufferWithBlackTile
	ret

LoadEAcuteCharacterGfx:
	ld a, [hGameBoyColorFlag]
	and a
	jr nz, .gameboyColor
	ld a, BANK(E_Acute_CharacterGfx)
	ld hl, E_Acute_CharacterGfx
	ld de, vTilesSH tile $03
	ld bc, $0010
	call LoadVRAMData
	ret

.gameboyColor
	ld a, BANK(E_Acute_CharacterGfx_GameboyColor)
	ld hl, E_Acute_CharacterGfx_GameboyColor
	ld de, vTilesSH tile $03
	ld bc, $0010
	call LoadVRAMData
	ret

Func_f57f:
	xor a
	ld [wDrawBottomMessageBox], a
	ld hl, wBottomMessageText
	ld a, $81
	ld b, $40
.clearLoop
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	dec b
	jr nz, .clearLoop
	ld a, $0
	ld hl, wBottomMessageText
	ld de, vBGWin
	ld bc, $00c0
	call LoadVRAMData
	ret

ShowBallBonusSummary:
	ld de, wBottomMessageText + $40
	ld hl, BonusPointsText
	call PlaceTextAlphanumericOnly
	ld de, wBottomMessageText + $80
	ld hl, SubtotalPointsText
	call PlaceTextAlphanumericOnly
	ld hl, wEndOfBallBonusSubTotal
	call ClearBCD6Buffer
	ld hl, wEndOfBallBonusTotalScore
	call ClearBCD6Buffer
	ld a, 1
	ld [wBallBonusWaitForButtonPress], a
	call HandleNumPokemonCaughtBallBonus
	call HandleNumPokemonEvolvedBallBonus
	call HandleBallBonusForCurrentField
	call Func_f676
	ld a, 1
	ld [wBallBonusWaitForButtonPress], a
	call Func_f70d
	ld a, [wGameOver]
	and a
	ret z
	ld a, Bank(Music_GameOver)
	call SetSongBank
	ld de, MUSIC_GAME_OVER
	call PlaySong
	ld hl, wBottomMessageText
	ld bc, $0040
	call Func_f81b
	ld de, wBottomMessageText + $20
	ld hl, GameOverText
	call PlaceTextAlphanumericOnly
	ld bc, $0040
	ld de, $0000
	call Func_f80d
.waitForAPress
	rst AdvanceFrame
	ld a, [hNewlyPressedButtons]
	bit BIT_A_BUTTON, a
	jr z, .waitForAPress
	ret

HandleBallBonusForCurrentField:
	ld a, [wCurrentStage]
	rst JumpTable  ; calls JumpToFuncInTable
CallTable_f60d:
	dw HandleBallBonusRedField      ; STAGE_RED_FIELD_TOP
	dw HandleBallBonusRedField      ; STAGE_RED_FIELD_BOTTOM
	dw HandleBallBonusBlueField     ; STAGE_BLUE_FIELD_TOP
	dw HandleBallBonusBlueField     ; STAGE_BLUE_FIELD_BOTTOM
	dw HandleBallBonusGoldField     ; STAGE_GOLD_FIELD_TOP
	dw HandleBallBonusGoldField     ; STAGE_GOLD_FIELD_BOTTOM
	dw HandleBallBonusSilverField   ; STAGE_SILVER_FIELD_TOP
	dw HandleBallBonusSilverField   ; STAGE_SILVER_FIELD_BOTTOM
	dw HandleBallBonusRubyField     ; STAGE_RUBY_FIELD_TOP
	dw HandleBallBonusRubyField     ; STAGE_RUBY_FIELD_BOTTOM
	dw HandleBallBonusSapphireField ; STAGE_SAPPHIRE_FIELD_TOP
	dw HandleBallBonusSapphireField ; STAGE_SAPPHIRE_FIELD_BOTTOM
	dw DoNothing_faf6               ; STAGE_GENGAR_BONUS
	dw DoNothing_faf6               ; STAGE_GENGAR_BONUS
	dw DoNothing_faf7               ; STAGE_MEWTWO_BONUS
	dw DoNothing_faf7               ; STAGE_MEWTWO_BONUS
	dw DoNothing_faf8               ; STAGE_MEOWTH_BONUS
	dw DoNothing_faf8               ; STAGE_MEOWTH_BONUS

HandleNumPokemonCaughtBallBonus:
	ld de, wBottomMessageText + $01
	ld hl, NumPokemonCaughtText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $01
	ld a, [wNumPokemonCaughtInBallBonus]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumPokemonCaughtInBallBonus
	ld de, PointsPerPokemonCaught
	call Func_f853
	call Func_f824
	ret

HandleNumPokemonEvolvedBallBonus:
	ld de, wBottomMessageText
	ld hl, NumPokemonEvolvedText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText
	ld a, [wNumPokemonEvolvedInBallBonus]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumPokemonEvolvedInBallBonus
	ld de, PointsPerPokemonEvolved
	call Func_f853
	call Func_f824
	ret

Func_f676:
	ld b, $4
.asm_f678
	push bc
	ld hl, wBottomMessageText + $20
	ld de, wBottomMessageText
	ld bc, $00e0
	call LocalCopyData
	ld bc, $00c0
	ld de, $0000
	call Func_f80d
	ld a, [wBallBonusWaitForButtonPress]
	and a
	jr z, .asm_f69f
	rst AdvanceFrame
	ld a, [hNewlyPressedButtons]
	bit BIT_A_BUTTON, a
	jr z, .asm_f69f
	xor a
	ld [wBallBonusWaitForButtonPress], a
.asm_f69f
	pop bc
	dec b
	jr nz, .asm_f678
	ld de, wBottomMessageText + $40
	ld hl, MultiplierPointsText
	call PlaceTextAlphanumericOnly
	ld de, wBottomMessageText + $80
	ld hl, TotalPointsText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $50
	ld a, [wCurBonusMultiplier]
	call Func_f78e
	ld bc, $0040
	ld de, $0040
	call Func_f80d
.asm_f6c7
	push de
	push hl
	ld hl, wEndOfBallBonusTotalScore + $5
	ld de, wBottomMessageText + $86
	call Func_f8bd
	ld bc, $0040
	ld de, $0080
	call Func_f80d
	lb de, $00, $3e
	call PlaySoundEffect
	ld a, [wBallBonusWaitForButtonPress]
	and a
	jr z, .asm_f6f2
	rst AdvanceFrame
	ld a, [hNewlyPressedButtons]
	bit BIT_A_BUTTON, a
	jr z, .asm_f6f2
	xor a
	ld [wBallBonusWaitForButtonPress], a
.asm_f6f2
	pop hl
	pop de
	ld a, [wCurBonusMultiplier]
	and a
	jr z, .asm_f709
	dec a
	ld [wCurBonusMultiplier], a
	ld hl, wEndOfBallBonusTotalScore
	ld de, wEndOfBallBonusSubTotal
	call AddBigBCD6
	jr .asm_f6c7

.asm_f709
	call Func_f83a
	ret

Func_f70d:
	ld b, $4
.asm_f70f
	push bc
	ld hl, wBottomMessageText + $20
	ld de, wBottomMessageText
	ld bc, $00e0
	call LocalCopyData
	ld bc, $00c0
	ld de, $0000
	call Func_f80d
	ld a, [wBallBonusWaitForButtonPress]
	and a
	jr z, .asm_f736
	rst AdvanceFrame
	ld a, [hNewlyPressedButtons]
	bit BIT_A_BUTTON, a
	jr z, .asm_f736
	xor a
	ld [wBallBonusWaitForButtonPress], a
.asm_f736
	pop bc
	dec b
	jr nz, .asm_f70f
	ld de, wBottomMessageText + $60
	ld hl, ScoreText
	call PlaceTextAlphanumericOnly
	ld hl, wScore + $5
	ld de, wBottomMessageText + $66
	call Func_f8bd
	ld bc, $0040
	ld de, $0060
	call Func_f80d
	lb de, $00, $3e
	call PlaySoundEffect
	ld a, [wBallBonusWaitForButtonPress]
	and a
	jr z, .asm_f76c
	rst AdvanceFrame
	ld a, [hNewlyPressedButtons]
	bit BIT_A_BUTTON, a
	jr z, .asm_f76c
	xor a
	ld [wBallBonusWaitForButtonPress], a
.asm_f76c
	ld hl, wScore
	ld de, wEndOfBallBonusTotalScore
	call AddBigBCD6
	ld hl, wScore + $5
	ld de, wBottomMessageText + $66
	call Func_f8bd
	ld bc, $0040
	ld de, $0060
	call Func_f80d
	call Func_f83a
	call Func_f83a
	ret

Func_f78e:
	push hl
	call ConvertHexByteToDecWord
	pop hl
	ld c, $1
	ld a, d
	call .asm_f7a4
	inc hl
	ld a, e
	swap a
	call .asm_f7a4
	inc hl
	ld c, $0
	ld a, e
	; fall through
.asm_f7a4
	and $f
	jr nz, .asm_f7ab
	ld a, c
	and a
	ret nz
.asm_f7ab
	add $86
	ld [hl], a
	ld c, $0
	ret

PlaceTextAlphanumericOnly:
	ld a, [wd805] ;id unusedTextFlag is set, take olther path
	and a
	jr nz, .UnusedBranch
.loop
	ld a, [hli]
	and a
	ret z ;if end of text, ret
	cp "0"
	jr c, .NotADigit ;if a digit, add $56 and skip letter check
	cp "9" + 1
	jr nc, .NotADigit
	add $56
	jr .IsValidChar

.NotADigit
	cp "A"
	jr c, .NotALetter ;if a letter, add $56 and skip letter check
	cp "Z" + 1
	jr nc, .NotALetter
	add $bf
	jr .IsValidChar

.NotALetter
	cp "e" ;check if acute e
	jr nz, .NotAcuteE
	ld a, $83
	jr .IsValidChar

.NotAcuteE
	ld a, $81 ;if none of the above groups, replace with a space
.IsValidChar
	ld [de], a ;load result into de
	inc de
	jr .loop

.UnusedBranch
	ld a, [hli]
	and a
	ret z
	cp "0"
	jr c, .asm_f7ef
	cp "9" + 1
	jr nc, .asm_f7ef
	add $56
	jr .asm_f809

.asm_f7ef
	cp $a0
	jr c, .asm_f7fb
	cp $e0
	jr nc, .asm_f7fb
	sub $80
	jr .asm_f809

.asm_f7fb
	cp $e0
	jr c, .asm_f807
	cp $f4
	jr nc, .asm_f807
	sub $50
	jr .asm_f809

.asm_f807
	ld a, $81
.asm_f809
	ld [de], a
	inc de
	jr .UnusedBranch

Func_f80d:
	hlCoord 0, 0, vBGWin
	add hl, de
	push hl
	ld hl, wBottomMessageText
	add hl, de
	pop de
	call LoadVRAMData
	ret

Func_f81b:
	ld a, $81
	ld [hli], a
	dec bc
	ld a, b
	or c
	jr nz, Func_f81b
	ret

Func_f824:
	call Func_f83a
	ld hl, wBottomMessageText
	ld bc, $0040
	call Func_f81b
	ld hl, wBottomMessageText + $48
	ld bc, $0038
	call Func_f81b
	ret

Func_f83a:
	ld a, [wBallBonusWaitForButtonPress]
	and a
	ret z
	ld b, $46
.asm_f841
	push bc
	rst AdvanceFrame
	pop bc
	ld a, [hNewlyPressedButtons]
	bit BIT_A_BUTTON, a
	jr nz, .asm_f84e
	dec b
	jr nz, .asm_f841
	ret

.asm_f84e
	xor a
	ld [wBallBonusWaitForButtonPress], a
	ret

Func_f853:
	push hl
	ld hl, wEndOfBallBonusCategoryScore
	call ClearBCD6Buffer
	pop hl
.asm_f85b
	push de
	push hl
	ld hl, wEndOfBallBonusCategoryScore + $5
	ld de, wBottomMessageText + $46
	call Func_f8bd
	ld bc, $0040
	ld de, $0040
	call Func_f80d
	lb de, $00, $3e
	call PlaySoundEffect
	ld a, [wBallBonusWaitForButtonPress]
	and a
	jr z, .asm_f886
	rst AdvanceFrame
	ld a, [hNewlyPressedButtons]
	bit BIT_A_BUTTON, a
	jr z, .asm_f886
	xor a
	ld [wBallBonusWaitForButtonPress], a
.asm_f886
	pop hl
	pop de
	ld a, [hl]
	and a
	jr z, .asm_f899
	dec [hl]
	push de
	push hl
	ld hl, wEndOfBallBonusCategoryScore
	call AddBigBCD6
	pop hl
	pop de
	jr .asm_f85b

.asm_f899
	ld hl, wEndOfBallBonusSubTotal
	ld de, wEndOfBallBonusCategoryScore
	call AddBigBCD6
	ld hl, wEndOfBallBonusSubTotal + $5
	ld de, wBottomMessageText + $86
	call Func_f8bd
	ld bc, $0040
	ld de, $0080
	call Func_f80d
	ret

ClearBCD6Buffer:
	xor a
	ld b, $6
.loop
	ld [hli], a
	dec b
	jr nz, .loop
	ret

Func_f8bd:
	ld bc, $0c01
.asm_f8c0
	ld a, [hl]
	swap a
	call Func_f8d5
	inc de
	dec b
	ld a, [hld]
	call Func_f8d5
	inc de
	dec b
	jr nz, .asm_f8c0
	ld a, $86
	ld [de], a
	inc de
	ret

Func_f8d5:
	and $f
	jr nz, .asm_f8e0
	ld a, b
	dec a
	jr z, .asm_f8e0
	ld a, c
	and a
	ret nz
.asm_f8e0
	add $86
	ld [de], a
	ld c, $0
	ld a, b
	cp $c
	jr z, .asm_f8f5
	cp $9
	jr z, .asm_f8f5
	cp $6
	jr z, .asm_f8f5
	cp $3
	ret nz
.asm_f8f5
	push de
	ld a, e
	add $20
	ld e, a
	jr nc, .asm_f8fd
	inc d
.asm_f8fd
	ld a, $82
	ld [de], a
	pop de
	ret

AddBigBCD6:
FOR X, 6
	ld a, [de]
	if X == 0
		add [hl]
	else
		adc [hl]
	endc
	daa
	ld [hli], a
	inc de
ENDR
	ret

PointsPerPokemonCaught:
	bigBCD6 50000

PointsPerPokemonEvolved:
	bigBCD6 75000

PointsPerBellsproutEntry:
PointsPerCloysterEntry:
PointsPerSlowpokeEntry:
	bigBCD6 7500

PointsPerPoliwagTriple:
PointsPerPsyduckTriple:
PointsPerDugtrioTriple:
	bigBCD6 5000

PointsPerCAVECompletion:
	bigBCD6 2500

PointsPerSpinnerTurn:
	bigBCD6 1000

HandleBallBonusRedField:
	call HandleBellsproutEntriesBallBonus
	call HandleDugtrioTriplesBallBonus
	call HandleCAVECompletionsBallBonus_RedField
	call HandleSpinnerTurnsBallBonus_RedField
	ret

HandleBellsproutEntriesBallBonus:
	ld de, wBottomMessageText + $03
	ld hl, BellsproutCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $03
	ld a, [wNumBellsproutEntries]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumBellsproutEntries
	ld de, PointsPerBellsproutEntry
	call Func_f853
	call Func_f824
	ret

HandleDugtrioTriplesBallBonus:
	ld de, wBottomMessageText + $04
	ld hl, DugtrioCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $04
	ld a, [wNumDugtrioTriples]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumDugtrioTriples
	ld de, PointsPerDugtrioTriple
	call Func_f853
	call Func_f824
	ret

HandleCAVECompletionsBallBonus_RedField:
	ld de, wBottomMessageText + $03
	ld hl, CaveShotCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $03
	ld a, [wNumCAVECompletions]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumCAVECompletions
	ld de, PointsPerCAVECompletion
	call Func_f853
	call Func_f824
	ret

HandleSpinnerTurnsBallBonus_RedField:
	ld de, wBottomMessageText + $01
	ld hl, SpinnerTurnsCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $01
	ld a, [wNumSpinnerTurns]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumSpinnerTurns
	ld de, PointsPerSpinnerTurn
	call Func_f853
	call Func_f824
	ret

HandleBallBonusBlueField:
	call HandleCloysterEntriesBallBonus
	call HandleSlowpokeEntriesBallBonus
	call HandlePoliwagTriplesBallBonus
	call HandlePsyduckTriplesBallBonus
	call HandleCAVECompletionsBallBonus_BlueField
	call HandleSpinnerTurnsBallBonus_BlueField
	ret

HandleCloysterEntriesBallBonus:
	ld de, wBottomMessageText + $04
	ld hl, CloysterCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $04
	ld a, [wNumCloysterEntries]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumCloysterEntries
	ld de, PointsPerCloysterEntry
	call Func_f853
	call Func_f824
	ret

HandleSlowpokeEntriesBallBonus:
	ld de, wBottomMessageText + $04
	ld hl, SlowpokeCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $04
	ld a, [wNumSlowpokeEntries]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumSlowpokeEntries
	ld de, PointsPerSlowpokeEntry
	call Func_f853
	call Func_f824
	ret

HandlePoliwagTriplesBallBonus:
	ld de, wBottomMessageText + $04
	ld hl, PoliwagCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $04
	ld a, [wNumPoliwagTriples]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumPoliwagTriples
	ld de, PointsPerPoliwagTriple
	call Func_f853
	call Func_f824
	ret

HandlePsyduckTriplesBallBonus:
	ld de, wBottomMessageText + $04
	ld hl, PsyduckCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $04
	ld a, [wNumPsyduckTriples]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumPsyduckTriples
	ld de, PointsPerPsyduckTriple
	call Func_f853
	call Func_f824
	ret

HandleCAVECompletionsBallBonus_BlueField:
	ld de, wBottomMessageText + $03
	ld hl, CaveShotCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $03
	ld a, [wNumCAVECompletions]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumCAVECompletions
	ld de, PointsPerCAVECompletion
	call Func_f853
	call Func_f824
	ret

HandleSpinnerTurnsBallBonus_BlueField:
	ld de, wBottomMessageText + $01
	ld hl, SpinnerTurnsCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $01
	ld a, [wNumSpinnerTurns]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumSpinnerTurns
	ld de, PointsPerSpinnerTurn
	call Func_f853
	call Func_f824
	ret

HandleBallBonusGoldField:
	call HandleBellsproutEntriesBallBonus_GoldField
	call HandleDugtrioTriplesBallBonus_GoldField
	call HandleCAVECompletionsBallBonus_GoldField
	call HandleSpinnerTurnsBallBonus_GoldField
	ret

HandleBellsproutEntriesBallBonus_GoldField:
	ld de, wBottomMessageText + $03
	ld hl, BellsproutCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $03
	ld a, [wNumBellsproutEntries]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumBellsproutEntries
	ld de, PointsPerBellsproutEntry
	call Func_f853
	call Func_f824
	ret

HandleDugtrioTriplesBallBonus_GoldField:
	ld de, wBottomMessageText + $04
	ld hl, DugtrioCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $04
	ld a, [wNumDugtrioTriples]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumDugtrioTriples
	ld de, PointsPerDugtrioTriple
	call Func_f853
	call Func_f824
	ret

HandleCAVECompletionsBallBonus_GoldField:
	ld de, wBottomMessageText + $03
	ld hl, CaveShotCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $03
	ld a, [wNumCAVECompletions]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumCAVECompletions
	ld de, PointsPerCAVECompletion
	call Func_f853
	call Func_f824
	ret

HandleSpinnerTurnsBallBonus_GoldField:
	ld de, wBottomMessageText + $01
	ld hl, SpinnerTurnsCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $01
	ld a, [wNumSpinnerTurns]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumSpinnerTurns
	ld de, PointsPerSpinnerTurn
	call Func_f853
	call Func_f824
	ret

HandleBallBonusSilverField:
	call HandleCloysterEntriesBallBonus_SilverField
	call HandleSlowpokeEntriesBallBonus_SilverField
	call HandlePoliwagTriplesBallBonus_SilverField
	call HandlePsyduckTriplesBallBonus_SilverField
	call HandleCAVECompletionsBallBonus_SilverField
	call HandleSpinnerTurnsBallBonus_SilverField
	ret

HandleCloysterEntriesBallBonus_SilverField:
	ld de, wBottomMessageText + $04
	ld hl, CloysterCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $04
	ld a, [wNumCloysterEntries]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumCloysterEntries
	ld de, PointsPerCloysterEntry
	call Func_f853
	call Func_f824
	ret

HandleSlowpokeEntriesBallBonus_SilverField:
	ld de, wBottomMessageText + $04
	ld hl, SlowpokeCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $04
	ld a, [wNumSlowpokeEntries]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumSlowpokeEntries
	ld de, PointsPerSlowpokeEntry
	call Func_f853
	call Func_f824
	ret

HandlePoliwagTriplesBallBonus_SilverField:
	ld de, wBottomMessageText + $04
	ld hl, PoliwagCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $04
	ld a, [wNumPoliwagTriples]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumPoliwagTriples
	ld de, PointsPerPoliwagTriple
	call Func_f853
	call Func_f824
	ret

HandlePsyduckTriplesBallBonus_SilverField:
	ld de, wBottomMessageText + $04
	ld hl, PsyduckCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $04
	ld a, [wNumPsyduckTriples]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumPsyduckTriples
	ld de, PointsPerPsyduckTriple
	call Func_f853
	call Func_f824
	ret

HandleCAVECompletionsBallBonus_SilverField:
	ld de, wBottomMessageText + $03
	ld hl, CaveShotCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $03
	ld a, [wNumCAVECompletions]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumCAVECompletions
	ld de, PointsPerCAVECompletion
	call Func_f853
	call Func_f824
	ret

HandleSpinnerTurnsBallBonus_SilverField:
	ld de, wBottomMessageText + $01
	ld hl, SpinnerTurnsCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $01
	ld a, [wNumSpinnerTurns]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumSpinnerTurns
	ld de, PointsPerSpinnerTurn
	call Func_f853
	call Func_f824
	ret

HandleBallBonusRubyField:
	call HandleBellsproutEntriesBallBonus_RubyField
	call HandleDugtrioTriplesBallBonus_RubyField
	call HandleCAVECompletionsBallBonus_RubyField
	call HandleSpinnerTurnsBallBonus_RubyField
	ret

HandleBellsproutEntriesBallBonus_RubyField:
	ld de, wBottomMessageText + $03
	ld hl, BellsproutCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $03
	ld a, [wNumBellsproutEntries]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumBellsproutEntries
	ld de, PointsPerBellsproutEntry
	call Func_f853
	call Func_f824
	ret

HandleDugtrioTriplesBallBonus_RubyField:
	ld de, wBottomMessageText + $04
	ld hl, DugtrioCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $04
	ld a, [wNumDugtrioTriples]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumDugtrioTriples
	ld de, PointsPerDugtrioTriple
	call Func_f853
	call Func_f824
	ret

HandleCAVECompletionsBallBonus_RubyField:
	ld de, wBottomMessageText + $03
	ld hl, CaveShotCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $03
	ld a, [wNumCAVECompletions]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumCAVECompletions
	ld de, PointsPerCAVECompletion
	call Func_f853
	call Func_f824
	ret

HandleSpinnerTurnsBallBonus_RubyField:
	ld de, wBottomMessageText + $01
	ld hl, SpinnerTurnsCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $01
	ld a, [wNumSpinnerTurns]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumSpinnerTurns
	ld de, PointsPerSpinnerTurn
	call Func_f853
	call Func_f824
	ret

HandleBallBonusSapphireField:
	call HandleCloysterEntriesBallBonus_SapphireField
	call HandleSlowpokeEntriesBallBonus_SapphireField
	call HandlePoliwagTriplesBallBonus_SapphireField
	call HandlePsyduckTriplesBallBonus_SapphireField
	call HandleCAVECompletionsBallBonus_SapphireField
	call HandleSpinnerTurnsBallBonus_SapphireField
	ret

HandleCloysterEntriesBallBonus_SapphireField:
	ld de, wBottomMessageText + $04
	ld hl, CloysterCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $04
	ld a, [wNumCloysterEntries]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumCloysterEntries
	ld de, PointsPerCloysterEntry
	call Func_f853
	call Func_f824
	ret

HandleSlowpokeEntriesBallBonus_SapphireField:
	ld de, wBottomMessageText + $04
	ld hl, SlowpokeCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $04
	ld a, [wNumSlowpokeEntries]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumSlowpokeEntries
	ld de, PointsPerSlowpokeEntry
	call Func_f853
	call Func_f824
	ret

HandlePoliwagTriplesBallBonus_SapphireField:
	ld de, wBottomMessageText + $04
	ld hl, PoliwagCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $04
	ld a, [wNumPoliwagTriples]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumPoliwagTriples
	ld de, PointsPerPoliwagTriple
	call Func_f853
	call Func_f824
	ret

HandlePsyduckTriplesBallBonus_SapphireField:
	ld de, wBottomMessageText + $04
	ld hl, PsyduckCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $04
	ld a, [wNumPsyduckTriples]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumPsyduckTriples
	ld de, PointsPerPsyduckTriple
	call Func_f853
	call Func_f824
	ret

HandleCAVECompletionsBallBonus_SapphireField:
	ld de, wBottomMessageText + $03
	ld hl, CaveShotCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $03
	ld a, [wNumCAVECompletions]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumCAVECompletions
	ld de, PointsPerCAVECompletion
	call Func_f853
	call Func_f824
	ret

HandleSpinnerTurnsBallBonus_SapphireField:
	ld de, wBottomMessageText + $01
	ld hl, SpinnerTurnsCounterText
	call PlaceTextAlphanumericOnly
	ld hl, wBottomMessageText + $01
	ld a, [wNumSpinnerTurns]
	call Func_f78e
	ld bc, $0040
	ld de, $0000
	call Func_f80d
	ld hl, wNumSpinnerTurns
	ld de, PointsPerSpinnerTurn
	call Func_f853
	call Func_f824
	ret

DoNothing_faf6:
	ret

DoNothing_faf7:
	ret

DoNothing_faf8:
	ret

; XXX
	ret

; XXX
	ret
