_LoadStageDataRedFieldTop: ; 0x14000
	call Func_14091
	call LoadFieldStructureGraphics_RedField
	call LoadPinballUpgradeTriggersGraphics_RedField
	call LoadStaryuGraphics_Top
	call UpdateSpinnerChargeGraphics_RedField
	call LoadEvolutionTrinketGraphics_RedField
	call LoadSlotCaveCoverGraphics_RedField
	call LoadBallGraphics
	call LoadTimerGraphics
	ret

_LoadStageDataRedFieldBottom: ; 0x1401c
	call Func_14091
	call LoadBillboardGraphics_RedField
	call ClearAllRedIndicators
	call LoadCAVELightsGraphics_RedField
	call LoadBillboardStatusBarGraphics_RedField
	call Func_1414b
	call LoadEvolutionTrinketGraphics_RedField
	call LoadAgainTextGraphics
	call DrawBallSaverIcon
	call LoadDiglettGraphics
	call LoadStaryuGraphics_Bottom
	call LoadBonusMultiplierRailingGraphics_RedField
	call LoadSlotCaveCoverGraphics_RedField
	call LoadBallGraphics
	call LoadTimerGraphics
	ret

LoadTimerGraphics: ; 0x1404a
	ld a, [wTimerActive]
	and a
	ret z
	ld a, [hGameBoyColorFlag]
	and a
	ret nz
	ld a, [wd580]
	and a
	ret z
	ld a, $f
	ld [wd581], a
	call Func_1762f
	ld hl, wTimerDigits
	ld a, $ff
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ld hl, wTimerDigits
	ld a, [wTimerMinutes]
	and $f
	call LoadTimerDigitTiles
	ld a, [wTimerSeconds]
	swap a
	and $f
	call LoadTimerDigitTiles
	ld a, [wTimerSeconds]
	and $f
	call LoadTimerDigitTiles
	ld a, e
	srl a
	srl a
	ld d, $90 ; colon
	call LoadTimerDigitTiles
	ret

Func_14091: ; 0x14091
	ld a, $ff
	ld [wWhichAnimatedVoltorb], a
	ld [wWhichBumperGfx], a
	ld a, [wBallXPos + 1]
	ld [wd4c5], a
	ld a, [wBallYPos + 1]
	ld [wd4c6], a
	ld a, [wBallRotation]
	ld [wd4c7], a
	ld a, [wd503]
	and a
	ret z
	xor a
	ld [wd503], a
	ld a, [wd502]
	res 1, a
	ld [wd502], a
	and $1
	ld c, a
	ld a, [wStageCollisionState]
	and $fe
	or c
	ld [wStageCollisionState], a
	lb de, $00, $07
	call PlaySoundEffect
	ld a, [wCurrentStage]
	bit 0, a
	ret nz
	callba LoadStageCollisionAttributes
	call LoadFieldStructureGraphics_RedField
	ret

LoadBonusMultiplierRailingGraphics_RedField: ; 0x140e2
	ld a, $ff
	ld [wd60e], a
	ld [wd60f], a
	ld a, [wBonusMultiplierTensDigit]
	call _LoadBonusMultiplierRailingGraphics_RedField
	ld a, [wBonusMultiplierOnesDigit]
	add $14
	call _LoadBonusMultiplierRailingGraphics_RedField
	ret

LoadDiglettGraphics: ; 0x140f9
	ld a, [wLeftDiglettAnimationController]
	and a
	jr z, .asm_1410c ;skip ??? if wLeftDiglettAnimationController = 0
	xor a ;wut
	ld a, $66
	ld [wStageCollisionMap + $e3], a
	ld a, $67
	ld [wStageCollisionMap + $103], a ;load into the collision map?
	ld a, $2
.asm_1410c
	call _LoadDiglettGraphics
	ld a, [wLeftMapMoveCounter]
	call LoadDiglettNumberGraphics
	ld a, [wRightDiglettAnimationController]
	and a
	jr z, .asm_14127
	ld a, $6a
	ld [wStageCollisionMap + $f0], a
	ld a, $6b
	ld [wStageCollisionMap+ $110], a
	ld a, $2
.asm_14127
	add $3
	call _LoadDiglettGraphics
	ld a, [wRightMapMoveCounter]
	add $4
	call LoadDiglettNumberGraphics
	ret

ClearAllRedIndicators: ; 0x14135
	ld bc, $0000
.Loop5Times
	push bc
	ld hl, wIndicatorStates ;for each of 5 states
	add hl, bc
	ld a, [hl]
	res 7, a ;clear bit 7
	call LoadArrowIndicatorGraphics_RedField
	pop bc
	inc c
	ld a, c
	cp $5
	jr nz, .Loop5Times
	ret

Func_1414b: ; 0x1414b
	ld a, [wInSpecialMode]
	and a
	ret z
	ld a, [wSpecialMode]
	cp SPECIAL_MODE_MAP_MOVE
	ret z
	ld a, [wd5c6]
	and a
	jr nz, .asm_14165
	ld a, [wCapturingMon]
	and a
	jr nz, .asm_14165
	jp Func_14210

.asm_14165
	callba Func_141f2
	callba Func_10362
	ld a, [hGameBoyColorFlag]
	and a
	callba nz, Func_10301
	ld a, [wCapturingMon]
	and a
	ret z
	ld a, BANK(PikachuSaverGfx)
	ld hl, PikachuSaverGfx + $c0
	ld de, vTilesOB tile $7e
	ld bc, $0020
	call FarCopyData
	ld a, BANK(BallCaptureSmokeGfx)
	ld hl, BallCaptureSmokeGfx
	ld de, vTilesSH tile $10
	ld bc, $0180
	call FarCopyData
	callba LoadShakeBallGfx_DuringLoadStage
	ret

Func_141f2: ; 0x141f2
	ld a, $80
	hlCoord 7, 4, vBGMap
	call Func_14209
	hlCoord 7, 5, vBGMap
	call Func_14209
	hlCoord 7, 6, vBGMap
	call Func_14209
	hlCoord 7, 7, vBGMap
	; fall through

Func_14209: ; 0x14209
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ret

Func_14210: ; 0x14210
	ld hl, wBillboardTilesIlluminationStates
	ld b, $18
.asm_14215
	ld a, [hli]
	xor $1
	ld [hli], a
	dec b
	jr nz, .asm_14215
	callba Func_10184
	ld a, [hGameBoyColorFlag]
	and a
	callba nz, Func_102bc
	ret

LoadEvolutionTrinketGraphics_RedField: ; 0x14234
	ld a, [wInSpecialMode]
	and a
	ret z
	ld a, [wSpecialMode]
	cp SPECIAL_MODE_EVOLUTION
	ret nz
	ld a, [wNumEvolutionTrinkets]
	cp $3
	ret z
	ld a, [wCurrentStage]
	bit 0, a
	jr nz, .asm_1425c
	ld de, vTilesSH tile $10
	call LoadEvolutionTrinketGfx_RedField
	jr .asm_1426a

.asm_1425c
	ld de, vTilesOB tile $20
	call LoadEvolutionTrinketGfx_RedField
.asm_1426a
	ld a, [wEvolutionObjectsDisabled]
	and a
	ret z
	ld a, [hGameBoyColorFlag]
	and a
	ret z
	ld a, BANK(EvolutionTrinketPalettes)
	ld hl, EvolutionTrinketPalettes
	ld de, $0070
	ld bc, $0010
	call FarCopyCGBPals
	ret

LoadEvolutionTrinketGfx_RedField:
; de = destination for gfx
	ld a, [wCurrentEvolutionType]
	cp EVO_BREEDING
	jr z, .breeding
	dec a
	ld c, a
	ld b, $0
	swap c
	sla c
	ld hl, EvolutionTrinketsGfx
	add hl, bc
	ld bc, $0020
	ld a, BANK(EvolutionTrinketsGfx)
	jr .load
.breeding
	ld a, BANK(BreedingTrinketGfx)
	ld hl, BreedingTrinketGfx
	ld bc, $0020
.load
	call FarCopyData
	ret

LoadBillboardStatusBarGraphics_RedField: ; 0x14282
	ld a, [wInSpecialMode]
	and a
	jr z, .asm_1429e
	ld a, [wSpecialMode]
	and a
	jr nz, .asm_14296
	ld a, [wNumMonHits]
	and a
	call nz, Func_142b3
	ret

.asm_14296
	cp SPECIAL_MODE_EVOLUTION
	jr nz, .asm_1429e
	call Func_142c3
	ret

.asm_1429e
	ld a, [wPreviousNumPokeballs]
	call LoadPokeballsGraphics_RedField
	ld a, BANK(CaughtPokeballGfx)
	ld hl, CaughtPokeballGfx
	ld de, vTilesSH tile $2e
	ld bc, $0020
	call FarCopyData
	ret

Func_142b3: ; 0x142b3
	push af
	callba Func_10611
	pop af
	dec a
	jr nz, Func_142b3
	ret

Func_142c3: ; 0x142c3
	ld de, $0000
	ld a, [wNumEvolutionTrinkets]
	and a
	ret z
	ld b, a
.asm_142cc
	ld a, [wCurrentEvolutionType]
	call Func_142d7
	inc de
	dec b
	jr nz, .asm_142cc
	ret

Func_142d7: ; 0x142d7
	push bc
	push de
	dec a
	ld c, a
	ld b, $0
	swap c
	ld hl, EvolutionProgressIconsGfx
	add hl, bc
	add hl, bc
	swap e
	sla e
	push hl
	ld hl, vTilesSH tile $2e
	add hl, de
	ld d, h
	ld e, l
	pop hl
	ld bc, $0020
	ld a, BANK(EvolutionProgressIconsGfx)
	call FarCopyData
	pop de
	pop bc
	ret

LoadBallGraphics: ; 0x142fc
	ld a, [wd4c8]
	and a
	jr nz, .miniBall
	callba LoadBallGfx
	jr .loadBallPalette

.miniBall
	cp $1
	jr nz, .superMiniBall
	callba LoadMiniBallGfx
	jr .loadBallPalette

.superMiniBall
	callba LoadSuperMiniPinballGfx
.loadBallPalette
	ld a, [hGameBoyColorFlag]
	and a
	ret z
	ld a, [wBallType]
	ld b, a
	add b
	add b ; multiply ball type id by 3
	ld c, a
	ld b, 0
	ld hl, BallPalettePointers
	add hl, bc ; hl points to entry in BallPalettePointers
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	ld a, [hli]
	ld h, d
	ld l, e ; hl = gfx pointer, a = bank of gfx
	ld de, $0040
	ld bc, $0008
	call FarCopyCGBPals
	ret

BallPalettePointers:
	dwb PokeBallObjPalette, Bank(PokeBallObjPalette)
	dwb GreatBallObjPalette, Bank(GreatBallObjPalette)
	dwb UltraBallObjPalette, Bank(UltraBallObjPalette)
	dwb MasterBallObjPalette, Bank(MasterBallObjPalette)
	dwb GSBallObjPalette, Bank(GSBallObjPalette)

LoadBillboardGraphics_RedField: ; 0x14377
	ld a, [wInSpecialMode]
	and a
	jr nz, .asm_143b1
	ld a, [wOpenedSlotByGetting3Pokeballs]
	and a
	jr z, .asm_14393
	ld a, [wNextBonusStage]
	add $3
	callba LoadBillboardTileData
	ret

.asm_14393
	ld a, [wOpenedSlotByGetting4CAVELights]
	and a
	jr z, .asm_143a6
	ld a, BILLBOARD_SLOT
	callba LoadBillboardTileData
	ret

.asm_143a6
	callba LoadMapBillboardTileData
	ret

.asm_143b1
	ld a, [wSpecialMode]
	cp SPECIAL_MODE_MAP_MOVE
	ret nz
	ld a, [wSpecialModeState]
	cp $3
	jr nz, .asm_143c9
	callba LoadMapBillboardTileData
	ret

.asm_143c9
	ld a, [wSlotIsOpen]
	and a
	ld a, $2
	jr nz, .asm_143d6
	ld a, [wMapMoveDirection]
.asm_143d6
	callba LoadBillboardTileData
	ret
