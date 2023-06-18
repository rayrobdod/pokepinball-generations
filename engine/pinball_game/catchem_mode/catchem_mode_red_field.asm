HandleRedCatchEmCollision: ; 0x20000
	ld a, [wSpecialModeCollisionID]
	cp SPECIAL_COLLISION_VOLTORB
	jp z, HandleVoltorbCollision_CatchemMode
	cp SPECIAL_COLLISION_SPINNER
	jp z, HandleSpinnerCollision_CatchemMode_RedField
	cp SPECIAL_COLLISION_BELLSPROUT
	jp z, HandleBellsproutCollision_CatchemMode
	cp SPECIAL_COLLISION_NOTHING
	jr z, .noCollision
	scf
	ret

.noCollision
	call CheckIfCatchemModeTimerExpired_RedField
	ld a, [wSpecialModeState]
	call CallInFollowingTable
CatchemModeCallTable_RedField: ; 0x20021
	padded_dab Func_20041
	padded_dab Func_2005f
	padded_dab Func_2006b
	padded_dab ShowAnimatedCatchemPokemon_RedField
	padded_dab UpdateMonState_CatchemMode_RedField
	padded_dab CatchPokemon_RedField
	padded_dab CapturePokemonAnimation_RedField
	padded_dab ConcludeCatchemMode_RedField

Func_20041: ; 0x20041
	ld a, [wNumberOfCatchModeTilesFlipped]
	cp $18
	jr nz, .NotDone
	ld a, [wCurrentStage]
	bit 0, a
	jr z, .NotDone
	ld hl, wSpecialModeState
	inc [hl]
	ld a, $14
	ld [wd54e], a
	ld a, $5
	ld [wd54f], a
.NotDone
	scf
	ret

Func_2005f: ; 0x2005f
	callba Func_10648
	scf
	ret

Func_2006b: ; 0x2006b
	ld a, [wCurrentStage]
	bit 0, a
	jr z, .asm_20098
	call Func_1130
	jr nz, .asm_200a1
	callba Func_10414
	callba Func_10362
	ld a, [hGameBoyColorFlag]
	and a
	callba nz, Func_10301
.asm_20098
	ld a, $1
	ld [wd5c6], a
	ld hl, wSpecialModeState
	inc [hl]
.asm_200a1
	scf
	ret

ShowAnimatedCatchemPokemon_RedField: ; 0x200a3
	ld a, [wCurrentStage]
	bit 0, a
	jr z, .asm_200af
	call Func_1130
	jr nz, .asm_200d1
.asm_200af
	callba ShowAnimatedWildMon
	callba PlayCatchemPokemonCry
	callba LoadWildMonCollisionMask
	ld hl, wSpecialModeState
	inc [hl]
.asm_200d1
	scf
	ret

UpdateMonState_CatchemMode_RedField: ; 0x200d3
	ld a, [wLoopsUntilNextCatchSpriteAnimationChange] ;dec time until next animation change, if zero jump
	dec a
	ld [wLoopsUntilNextCatchSpriteAnimationChange], a
	jr z, .ChangeAnimation
	ld a, [wCatchModeMonUpdateTimer] ;load ??? and inc it
	inc a
	ld [wCatchModeMonUpdateTimer], a
	and $3
	ret nz ;only continue every 4 loops?
.ChangeAnimation
	ld a, [wBallHitWildMon]
	and a
	jp z, .BallDidntHitMon ;if no ball hit(?), jump
	xor a
	ld [wBallHitWildMon], a ;toggle off ball hit
	ld a, [wCurrentCatchMonHitFrameDuration]
	ld [wLoopsUntilNextCatchSpriteAnimationChange], a ;load byte 3 of mystery data into ??? (cause it to loop X times between a colision check?)
	xor a
	ld [wCatchModeMonUpdateTimer], a ;load 0 into ??? stops double hits?
	ld a, [wCurrentCatchEmMon]
	cp (MEW - 1) >> 8
	jr nz, .notMew
	ld a, [wCurrentCatchEmMon + 1]
	cp (MEW - 1) & $FF
	jr nz, .notMew
	ld a, [wNumMewHits]
	inc a
	ld [wNumMewHits], a
	jr nz, .Not256MewHits
.notMew
	ld a, [wNumMonHits]
	cp $3
	jr z, .hitMonThreeTimes
	inc a
	ld [wNumMonHits], a
.Not256MewHits
	ld bc, ThreeHundredThousandPoints
	callba AddBigBCD6FromQueue
	ld bc, $0030
	ld de, $0000
	push bc
	push de
	call FillBottomMessageBufferWithBlackTile
	call EnableBottomText
	ld hl, wStationaryText2
	ld de, Data_2a2a
	call LoadScoreTextFromStack
	pop de
	pop bc
	ld hl, wStationaryText1
	ld de, HitText
	call LoadStationaryTextAndHeader
	ld a, [wNumMonHits]
	callba Func_10611 ;queue up a graphic based on number of mon hits
	ld c, $2
	jr .UpdateMonAnimation

.hitMonThreeTimes
	xor a
	ld [wTimeRanOut], a
	ld a, $1
	ld [wPauseTimer], a ;pause timer
	ld hl, wSpecialModeState ;inc ??
	inc [hl]
	ld c, $2
	jr .UpdateMonAnimation

.BallDidntHitMon
	ld a, [wLoopsUntilNextCatchSpriteAnimationChange]
	and a
	ret nz ;run if ??? = 0. wLoopsUntilNextCatchSpriteAnimationChange is how many loops apart to run this?
	ld a, [wCurrentAnimatedMonSpriteType]
	ld c, a
	ld a, [wCurrentAnimatedMonSpriteFrame]
	sub c ;if ??? - ??? >= 1, make c 1, else make it 0
	cp $1
	ld c, $0
	jr nc, .SetFrameTo0
	ld c, $1
.SetFrameTo0
	ld b, $0
	ld hl, wCurrentCatchMonIdleFrame1Duration ;add c to ???, place it in ???. the mystery data sets how far apart these checks are
	add hl, bc
	ld a, [hl]
	ld [wLoopsUntilNextCatchSpriteAnimationChange], a
	xor a
	ld [wCatchModeMonUpdateTimer], a; 0 out ???
.UpdateMonAnimation
	ld a, [wCurrentAnimatedMonSpriteType] ;add c to first animation type, add to second animation type?
	add c
	ld [wCurrentAnimatedMonSpriteFrame], a
	scf
	ret

CatchPokemon_RedField: ; 0x20193
	ld a, [wd580]
	and a
	jr z, .asm_2019e
	xor a
	ld [wd580], a
	ret

.asm_2019e
	callba BallCaptureInit
	ld hl, wSpecialModeState
	inc [hl]
	callba ShowCapturedPokemonText
	callba AddCaughtPokemonToParty
	scf
	ret

CapturePokemonAnimation_RedField: ; 0x201c2
	callba CapturePokemonAnimation
	scf
	ret

ConcludeCatchemMode_RedField: ; 0x201ce
	ld a, [wBottomTextEnabled]
	and a
	ret nz
	call FillBottomMessageBufferWithBlackTile
	callba RestoreBallSaverAfterCatchEmMode
	callba ConcludeCatchEmMode
	ld de, MUSIC_RED_FIELD
	call PlaySong
	scf
	ret

CheckIfCatchemModeTimerExpired_RedField: ; 0x201f2
	callba PlayLowTimeSfx
	ld a, [wTimeRanOut]
	and a
	ret z
	xor a
	ld [wTimeRanOut], a
	ld a, $7
	ld [wSpecialModeState], a
	; Automatically set Mew as caught, since you can't possibly catch it
	ld a, [wCurrentCatchEmMon]
	cp (MEW - 1) >> 8
	jr nz, .asm_2021b
	ld a, [wCurrentCatchEmMon + 1]
	cp (MEW - 1) & $FF
	jr nz, .asm_2021b
	callba SetPokemonOwnedFlag
.asm_2021b
	callba StopTimer
	callba Func_106a6
	ret

HandleVoltorbCollision_CatchemMode: ; 0x20230 resolve hitting a voltorb in catch mode?
	ld a, [wNumberOfCatchModeTilesFlipped]
	cp $18
	jr z, .AllTilesFlipped ;if FlippedCount is 24, add to jackpot and ret c
	sla a
	ld c, a
	ld b, $0
	ld hl, wBillboardTilesIlluminationStates
	add hl, bc
	ld d, $4
.LoopFlippedStatusInsertion
	ld a, $1
	ld [hli], a
	inc hl ;load in 1
	ld a, l
	cp wNumberOfCatchModeTilesFlipped % $100
	jr z, .ExitLoop ;continue until you reach FlippedCount or until 4 spaces are done
	dec d
	jr nz, .LoopFlippedStatusInsertion
.ExitLoop
	ld a, [wNumberOfCatchModeTilesFlipped]
	add $4 ;then add 4 to FlippedCount, clamp to 24
	cp $18
	jr c, .DontClamp
	ld a, $18
.DontClamp
	ld [wNumberOfCatchModeTilesFlipped], a
	cp $18
	jr nz, .NotDoneFlipping
	xor a
	ld [wIndicatorStates + 9], a ;if 24, unmark voltorb arrow indicator
.NotDoneFlipping
	callba Func_10184 ;load billboard graphics?
	ld bc, OneHundredThousandPoints
	callba AddBigBCD6FromQueue
	ld bc, $0010
	ld de, $0000
	push bc
	push de
	call FillBottomMessageBufferWithBlackTile
	call EnableBottomText
	ld hl, wStationaryText2
	ld de, CatchModeTileFlippedScoreStationaryTextHeader
	call LoadScoreTextFromStack
	pop de
	pop bc
	ld hl, wStationaryText1
	ld de, FlippedText
	call LoadStationaryTextAndHeader
.AllTilesFlipped
	ld bc, $0001
	ld de, $0000
	call AddBCDEToJackpot
	scf
	ret

HandleSpinnerCollision_CatchemMode_RedField: ; 0x202a8
	ld bc, $0000
	ld de, $1000
	call AddBCDEToJackpot
	ret

HandleBellsproutCollision_CatchemMode: ; 0x202b2
	ld bc, $0005
	ld de, $0000
	call AddBCDEToJackpot
	ret
