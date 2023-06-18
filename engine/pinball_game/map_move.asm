HandleMapModeCollision: ; 0x301ce
	ld a, [wCurrentStage]
	call CallInFollowingTable

HandleMapModeCollisionPointerTable: ; 0x301d4
	padded_dab HandleRedMapModeCollision      ; STAGE_RED_FIELD_TOP
	padded_dab HandleRedMapModeCollision      ; STAGE_RED_FIELD_BOTTOM
	padded_dab HandleBlueMapModeCollision     ; STAGE_BLUE_FIELD_TOP
	padded_dab HandleBlueMapModeCollision     ; STAGE_BLUE_FIELD_BOTTOM
	padded_dab HandleGoldMapModeCollision     ; STAGE_GOLD_FIELD_TOP
	padded_dab HandleGoldMapModeCollision     ; STAGE_GOLD_FIELD_BOTTOM
	padded_dab HandleSilverMapModeCollision   ; STAGE_SILVER_FIELD_TOP
	padded_dab HandleSilverMapModeCollision   ; STAGE_SILVER_FIELD_BOTTOM
	padded_dab HandleRubyMapModeCollision     ; STAGE_RUBY_FIELD_TOP
	padded_dab HandleRubyMapModeCollision     ; STAGE_RUBY_FIELD_BOTTOM
	padded_dab HandleSapphireMapModeCollision ; STAGE_SAPPHIRE_FIELD_TOP
	padded_dab HandleSapphireMapModeCollision ; STAGE_SAPPHIRE_FIELD_BOTTOM

StartMapMoveMode: ; 0x301ec
	ld a, [wInSpecialMode]
	and a
	ret nz
	ld a, $1
	ld [wInSpecialMode], a
	ld a, SPECIAL_MODE_MAP_MOVE
	ld [wSpecialMode], a
	xor a
	ld [wSpecialModeState], a
	ld bc, $0030  ; 30 seconds
	callba StartTimer
	ld a, [wCurrentStage]
	bit 0, a
	jr z, .asm_3021b
	ld a, [wMapMoveDirection]
	call LoadBillboardTileData
.asm_3021b
	ld a, [wCurrentStage]
	rst JumpTable  ; calls JumpToFuncInTable
CallTable_3021f: ; 0x3021f
	dw Func_311b4               ; STAGE_RED_FIELD_TOP
	dw Func_311b4               ; STAGE_RED_FIELD_BOTTOM
	dw Func_31326               ; STAGE_BLUE_FIELD_TOP
	dw Func_31326               ; STAGE_BLUE_FIELD_BOTTOM
	dw Func_311b4_GoldField     ; STAGE_GOLD_FIELD_TOP
	dw Func_311b4_GoldField     ; STAGE_GOLD_FIELD_BOTTOM
	dw Func_31326_SilverField   ; STAGE_SILVER_FIELD_TOP
	dw Func_31326_SilverField   ; STAGE_SILVER_FIELD_BOTTOM
	dw Func_311b4_RubyField     ; STAGE_RUBY_FIELD_TOP
	dw Func_311b4_RubyField     ; STAGE_RUBY_FIELD_BOTTOM
	dw Func_31326_SapphireField ; STAGE_SAPPHIRE_FIELD_TOP
	dw Func_31326_SapphireField ; STAGE_SAPPHIRE_FIELD_BOTTOM

ConcludeMapMoveMode: ; 0x3022b
	xor a
	ld [wBottomTextEnabled], a ;turn text off
	call FillBottomMessageBufferWithBlackTile ;clear text
	xor a
	ld [wInSpecialMode], a
	ld [wSpecialMode], a ;no longer in special modes
	callba StopTimer
	ld a, [wCurrentStage]
	rst JumpTable  ; calls JumpToFuncInTable
CallTable_30247: ; 0x30247
	dw Func_31234               ; STAGE_RED_FIELD_TOP
	dw Func_31234               ; STAGE_RED_FIELD_BOTTOM
	dw Func_313c3               ; STAGE_BLUE_FIELD_TOP
	dw Func_313c3               ; STAGE_BLUE_FIELD_TOP
	dw Func_31234_GoldField     ; STAGE_GOLD_FIELD_TOP
	dw Func_31234_GoldField     ; STAGE_GOLD_FIELD_BOTTOM
	dw Func_313c3_SilverField   ; STAGE_SILVER_FIELD_TOP
	dw Func_313c3_SilverField   ; STAGE_SILVER_FIELD_TOP
	dw Func_31234_RubyField     ; STAGE_RUBY_FIELD_TOP
	dw Func_31234_RubyField     ; STAGE_RUBY_FIELD_BOTTOM
	dw Func_313c3_SapphireField ; STAGE_SAPPHIRE_FIELD_TOP
	dw Func_313c3_SapphireField ; STAGE_SAPPHIRE_FIELD_TOP

INCLUDE "engine/pinball_game/billboard_tiledata.asm"

LoadScrollingMapNameText: ; 0x3118f
; Loads the scrolling message that displays the current map's name.
; Input: bc = pointer to prefix scrolling text
	push bc
	call FillBottomMessageBufferWithBlackTile
	call EnableBottomText
	ld a, [wCurrentMap]
	ld b, a
	sla a
	add b
	ld c, a
	ld b, $0
	ld hl, MapNames
	add hl, bc
	ld a, [hli]
	push af
	ld a, [hli]
	ld e, a
	ld a, [hli]
	ld d, a
	pop af
	push af
	ld hl, wScrollingText2
	call LoadScrollingTextFromBank
	pop af
	pop de
	ld hl, wScrollingText1
	call LoadScrollingTextFromBank
	ret

MapNames:
	dba PalletTownText
	dba ViridianCityText
	dba ViridianForestText
	dba PewterCityText
	dba MtMoonText
	dba CeruleanCityText
	dba VermilionSeasideText
	dba VermilionStreetsText
	dba RockMountainText
	dba LavenderTownText
	dba CeladonCityText
	dba CyclingRoadText
	dba FuchiaCityText
	dba SafariZoneText
	dba SaffronCityText
	dba SeafoamIslandsText
	dba CinnabarIslandText
	dba IndigoPlateauText
	dba NewBarkTownText
	dba VioletCityText
	dba RuinsOfAlphText
	dba DarkCaveText
	dba LakeOfRageText
	dba MahoganyTownText
	dba EcruteakCityText
	dba AzaleaTownText
	dba IlexForestText
	dba GoldenrodCityText
	dba NationalParkText
	dba OlivineCityText
	dba IcePathText
	dba MtMortarText
	dba BurnedTowerText
	dba TinTowerText
	dba WhirlIslandsText
	dba BlackthornCityText
	dba MtSilverText

Func_311b4: ; 0x311b4
	ld a, [wMapMoveDirection]
	and a
	jr nz, .asm_311ce
	ld a, $80
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	xor a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	ld [wIndicatorStates + 4], a
	jr .asm_311e2

.asm_311ce
	ld a, $80
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	xor a
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	ld [wIndicatorStates + 4], a
	jr .asm_311e2

.asm_311e2
	ld a, $2
	callba _LoadDiglettGraphics
	ld a, $5
	callba _LoadDiglettGraphics
	ld a, $6a
	ld [wStageCollisionMap + $f0], a
	ld a, $6b
	ld [wStageCollisionMap + $110], a
	ld a, $66
	ld [wStageCollisionMap + $e3], a
	ld a, $67
	ld [wStageCollisionMap + $103], a
	callba CloseSlotCave_
	ld a, $4
	ld [wd7ad], a
	ld de, MUSIC_HURRY_UP_BLUE ; Either MUSIC_HURRY_UP_BLUE or MUSIC_HURRY_UP_RED. They have the same id in their respective audio Banks.
	call PlaySong
	ld a, [wCurrentStage]
	bit 0, a
	ret z
	callba ClearAllRedIndicators
	ret

Func_31234: ; 0x31234
	callba ResetIndicatorStates
	callba OpenSlotCave
	callba SetLeftAndRightAlleyArrowIndicatorStates_RedField
	callba Func_107e9
	ld a, [wCurrentStage]
	bit 0, a
	ret z
	callba ClearAllRedIndicators
	callba LoadSlotCaveCoverGraphics_RedField
	callba LoadMapBillboardTileData
	ret

ChooseNextMap_RedField: ; 0x31282
; Picks the next map to perform a map move.
; Also records which maps have been visited.
	ld a, [wNumMapMoves]
	inc a
	cp $6
	jr c, .dontReset
	ld a, $ff
	ld [wVisitedMaps], a
	ld [wVisitedMaps + 1], a
	ld [wVisitedMaps + 2], a
	ld [wVisitedMaps + 3], a
	ld [wVisitedMaps + 4], a
	ld [wVisitedMaps + 5], a
	xor a
.dontReset
	ld [wNumMapMoves], a
	cp $3
	jr c, .chooseMapFromArea1
	cp $5
	jr c, .chooseMapFromArea2
	ld a, INDIGO_PLATEAU
	ld [wCurrentMap], a
	ld [wVisitedMaps + 5], a
	ret

.chooseMapFromArea1
	call GenRandom
	and $7
	cp $7
	jr nc, .chooseMapFromArea1
	ld c, a
	ld b, $0
	ld hl, FirstMapMoveSet_RedField
	add hl, bc
	ld c, [hl]
	ld hl, wVisitedMaps
	ld a, [wNumMapMoves]
	and a
	jr z, .asm_312d4
	ld b, a
.asm_312cd
	ld a, [hli]
	cp c
	jr z, .chooseMapFromArea1
	dec b
	jr nz, .asm_312cd
.asm_312d4
	ld a, c
	ld [wCurrentMap], a
	ld a, [wNumMapMoves]
	ld c, a
	ld b, $0
	ld hl, wVisitedMaps
	add hl, bc
	ld a, [wCurrentMap]
	ld [hl], a
	ret

.chooseMapFromArea2
	call GenRandom
	and $3
	ld c, a
	ld b, $0
	ld hl, SecondMapMoveSet_RedField
	add hl, bc
	ld c, [hl]
	ld hl, wVisitedMaps + 3
	ld a, [wNumMapMoves]
	sub $3
	jr z, .asm_31306
	ld b, a
.asm_312ff
	ld a, [hli]
	cp c
	jr z, .chooseMapFromArea2
	dec b
	jr nz, .asm_312ff
.asm_31306
	ld a, c
	ld [wCurrentMap], a
	ld a, [wNumMapMoves]
	ld c, a
	ld b, $0
	ld hl, wVisitedMaps
	add hl, bc
	ld a, [wCurrentMap]
	ld [hl], a
	ret

FirstMapMoveSet_RedField:
	db PALLET_TOWN
	db VIRIDIAN_FOREST
	db PEWTER_CITY
	db CERULEAN_CITY
	db VERMILION_SEASIDE
	db ROCK_MOUNTAIN
	db LAVENDER_TOWN

SecondMapMoveSet_RedField:
	db CYCLING_ROAD
	db SAFARI_ZONE
	db SEAFOAM_ISLANDS
	db CINNABAR_ISLAND

Func_31326: ; 0x31326
	ld a, [wMapMoveDirection]
	and a
	jr nz, .asm_3134c
	ld a, $80
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	xor a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	ld [wIndicatorStates + 4], a
	ld a, $3
	callba _LoadPsyduckOrPoliwagGraphics
	jr .asm_31382

.asm_3134c
	ld a, $80
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	xor a
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	ld [wIndicatorStates + 4], a
	ld a, $1
	callba _LoadPsyduckOrPoliwagGraphics
	ld a, $6
	callba _LoadPsyduckOrPoliwagGraphics
	ld a, $7
	callba LoadPsyduckOrPoliwagNumberGraphics
.asm_31382
	ld a, [wCurrentStage]
	bit 0, a
	jr z, .asm_3139d
	ld a, $54
	ld [wStageCollisionMap + $e3], a
	ld a, $55
	ld [wStageCollisionMap + $103], a
	ld a, $52
	ld [wStageCollisionMap + $f0], a
	ld a, $53
	ld [wStageCollisionMap + $110], a
.asm_3139d
	ld a, $1
	ld [wd644], a
	callba CloseSlotCave
	ld de, MUSIC_HURRY_UP_BLUE ; Either MUSIC_HURRY_UP_BLUE or MUSIC_HURRY_UP_RED. They have the same id in their respective audio Banks.
	call PlaySong
	ld a, [wCurrentStage]
	bit 0, a
	ret z
	callba Func_1c2cb
	ret

Func_313c3: ; 0x313c3
	callba ResetIndicatorStates
	callba OpenSlotCave
	callba SetLeftAndRightAlleyArrowIndicatorStates_BlueField
	ld a, $0
	ld [wd644], a
	ld a, [wCurrentStage]
	bit 0, a
	ret z
	callba Func_1c2cb
	callba LoadSlotCaveCoverGraphics_BlueField
	callba LoadMapBillboardTileData
	ret

ChooseNextMap_BlueField: ; 0x3140b
; Picks the next map to perform a map move.
; Also records which maps have been visited.
	ld a, [wNumMapMoves]
	inc a
	cp $6
	jr c, .dontReset
	ld a, $ff
	ld [wVisitedMaps], a
	ld [wVisitedMaps + 1], a
	ld [wVisitedMaps + 2], a
	ld [wVisitedMaps + 3], a
	ld [wVisitedMaps + 4], a
	ld [wVisitedMaps + 5], a
	xor a
.dontReset
	ld [wNumMapMoves], a
	cp $3
	jr c, .chooseMapFromArea1
	cp $5
	jr c, .chooseMapFromArea2
	ld a, INDIGO_PLATEAU
	ld [wCurrentMap], a
	ld [wVisitedMaps + 5], a
	ret

.chooseMapFromArea1
	call GenRandom
	and $7
	cp $7
	jr nc, .chooseMapFromArea1
	ld c, a
	ld b, $0
	ld hl, FirstMapMoveSet_BlueField
	add hl, bc
	ld c, [hl]
	ld hl, wVisitedMaps
	ld a, [wNumMapMoves]
	and a
	jr z, .asm_3145e
	ld b, a
.asm_31457
	ld a, [hli]
	cp c
	jr z, .chooseMapFromArea1
	dec b
	jr nz, .asm_31457
.asm_3145e
	ld a, c
	ld [wCurrentMap], a
	ld a, [wNumMapMoves]
	ld c, a
	ld b, $0
	ld hl, wVisitedMaps
	add hl, bc
	ld a, [wCurrentMap]
	ld [hl], a
	ret

.chooseMapFromArea2
	call GenRandom
	and $3
	ld c, a
	ld b, $0
	ld hl, SecondMapMoveSet_BlueField
	add hl, bc
	ld c, [hl]
	ld hl, wVisitedMaps + 3
	ld a, [wNumMapMoves]
	sub $3
	jr z, .asm_31490
	ld b, a
.asm_31489
	ld a, [hli]
	cp c
	jr z, .chooseMapFromArea2
	dec b
	jr nz, .asm_31489
.asm_31490
	ld a, c
	ld [wCurrentMap], a
	ld a, [wNumMapMoves]
	ld c, a
	ld b, $0
	ld hl, wVisitedMaps
	add hl, bc
	ld a, [wCurrentMap]
	ld [hl], a
	ret

FirstMapMoveSet_BlueField:
	db VIRIDIAN_CITY
	db VIRIDIAN_FOREST
	db MT_MOON
	db CERULEAN_CITY
	db VERMILION_STREETS
	db ROCK_MOUNTAIN
	db CELADON_CITY

SecondMapMoveSet_BlueField:
	db FUCHSIA_CITY
	db SAFARI_ZONE
	db SAFFRON_CITY
	db CINNABAR_ISLAND

HandleRedMapModeCollision: ; 0x314ae
	ld a, [wTimerActive]
	and a
	ld a, [wSpecialModeCollisionID]
	jr z, .asm_314d0
	cp SPECIAL_COLLISION_LEFT_TRIGGER
	jp z, OpenRedMapMoveSlotFromLeft
	cp SPECIAL_COLLISION_STARYU_ALLEY_TRIGGER
	jp z, OpenRedMapMoveSlotFromLeft
	cp SPECIAL_COLLISION_RIGHT_TRIGGER
	jp z, OpenRedMapMoveSlotFromRight
	cp SPECIAL_COLLISION_BELLSPROUT
	jp z, OpenRedMapMoveSlotFromRight
	cp SPECIAL_COLLISION_SLOT_HOLE
	jp z, ResolveSucsessfulRedMapMove
.asm_314d0
	cp SPECIAL_COLLISION_NOTHING
	jr z, .asm_314d6
	scf
	ret

.asm_314d6
	call UpdateMapMove_RedField
	ld a, [wSpecialModeState]
	call CallInFollowingTable
PointerTable_314df: ; 0xd13df
	padded_dab Func_314ef
	padded_dab Func_314f1
	padded_dab Func_314f3
	padded_dab Func_31505

Func_314ef: ; 0x314ef
	scf
	ret

Func_314f1: ; 0x314f1
	scf
	ret

Func_314f3: ; 0x314f3
	callba ConcludeMapMoveMode
	ld de, MUSIC_BLUE_FIELD ; Either MUSIC_BLUE_FIELD or MUSIC_RED_FIELD. They have the same id in their respective audio Banks.
	call PlaySong
	scf
	ret

Func_31505: ; 0x31505
	ld a, [wBottomTextEnabled]
	and a
	ret nz
	call FillBottomMessageBufferWithBlackTile
	callba ConcludeMapMoveMode
	ld de, MUSIC_BLUE_FIELD ; Either MUSIC_BLUE_FIELD or MUSIC_RED_FIELD. They have the same id in their respective audio Banks.
	call PlaySong
	scf
	ret

UpdateMapMove_RedField: ; 0x3151f handle map move timer and fail when it expires
	ld a, $50
	ld [wLeftDiglettAnimationController], a
	ld [wRightDiglettAnimationController], a
	callba PlayLowTimeSfx
	ld a, [wTimeRanOut] ;if ??? is 0, quit, else make it zero (this only truns once per something?) and handle a failed map move
	and a
	ret z
	xor a
	ld [wTimeRanOut], a
	ld a, $3
	ld [wSpecialModeState], a
	xor a
	ld [wSlotIsOpen], a ;close slot and indicators
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 2], a
	ld [wIndicatorStates + 3], a
	ld [wIndicatorStates + 4], a
	ld a, [wCurrentStage]
	bit 0, a
	jr z, .asm_31577 ;if on stage without flippers(the tops), jump
	callba ClearAllRedIndicators ;clear indicators
	callba LoadSlotCaveCoverGraphics_RedField
	callba LoadMapBillboardTileData
.asm_31577
	callba StopTimer ;stop the timer
	call FillBottomMessageBufferWithBlackTile
	call EnableBottomText
	ld hl, wScrollingText1
	ld de, MapMoveFailedText
	call LoadScrollingText
	ret

OpenRedMapMoveSlotFromLeft: ; 0x31591
	ld a, [wMapMoveDirection]
	and a
	jr nz, .NotApplicibleOrCompleted
	ld a, [wIndicatorStates]
	and a
	jr z, .NotApplicibleOrCompleted
	xor a
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	ld a, $80
	ld [wIndicatorStates + 4], a
	ld a, $1
	ld [wSlotIsOpen], a
	ld [wSpecialModeState], a
.NotApplicibleOrCompleted
	scf
	ret

OpenRedMapMoveSlotFromRight: ; 0x315b3
	ld a, [wMapMoveDirection]
	and a
	jr z, .NotApplicibleOrCompleted
	ld a, [wIndicatorStates + 1]
	and a
	jr z, .NotApplicibleOrCompleted
	xor a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	ld a, $80
	ld [wIndicatorStates + 4], a
	ld a, $1
	ld [wSlotIsOpen], a
	ld [wSpecialModeState], a
.NotApplicibleOrCompleted
	scf
	ret

ResolveSucsessfulRedMapMove: ; 0x315d5
	ld de, MUSIC_NOTHING
	call PlaySong
	rst AdvanceFrame
	callba ChooseNextMap_RedField
	callba LoadMapBillboardTileData
	lb de, $25, $25
	call PlaySoundEffect
	ld bc, ArrivedAtMapText
	callba LoadScrollingMapNameText
.asm_31603
	callba UpdateBottomText
	rst AdvanceFrame
	ld a, [wBottomTextEnabled]
	and a
	jr nz, .asm_31603
	ld a, $2
	ld [wSpecialModeState], a
	scf
	ret

HandleBlueMapModeCollision: ; 0x3161b
	ld a, [wTimerActive]
	and a
	ld a, [wSpecialModeCollisionID]
	jr z, .asm_3163d
	cp SPECIAL_COLLISION_LEFT_TRIGGER
	jp z, Func_31708
	cp SPECIAL_COLLISION_SLOWPOKE
	jp z, Func_31708
	cp SPECIAL_COLLISION_RIGHT_TRIGGER
	jp z, Func_3172a
	cp SPECIAL_COLLISION_CLOYSTER
	jp z, Func_3172a
	cp SPECIAL_COLLISION_SLOT_HOLE
	jp z, Func_3174c
.asm_3163d
	cp SPECIAL_COLLISION_NOTHING
	jr z, .asm_31643
	scf
	ret

.asm_31643
	call UpdateMapMove_BlueField
	ld a, [wSpecialModeState]
	call CallInFollowingTable
PointerTable_3164c: ; 0x3164c
	padded_dab Func_3165c
	padded_dab Func_3165e
	padded_dab Func_31660
	padded_dab Func_31672

Func_3165c: ; 0x3165c
	scf
	ret

Func_3165e: ; 0x3165e
	scf
	ret

Func_31660: ; 0x31660
	callba ConcludeMapMoveMode
	ld de, MUSIC_BLUE_FIELD ; Either MUSIC_BLUE_FIELD or MUSIC_RED_FIELD. They have the same id in their respective audio Banks.
	call PlaySong
	scf
	ret

Func_31672: ; 0x31672
	ld a, [wBottomTextEnabled] ;if text is off
	and a
	ret nz
	call FillBottomMessageBufferWithBlackTile
	callba ConcludeMapMoveMode
	ld de, MUSIC_BLUE_FIELD ; Either MUSIC_BLUE_FIELD or MUSIC_RED_FIELD. They have the same id in their respective audio Banks.
	call PlaySong
	scf
	ret

UpdateMapMove_BlueField: ; 0x3168c
	ld a, $50
	ld [wLeftMapMovePoliwagAnimationCounter], a
	ld [wRightMapMovePsyduckFrame], a
	ld a, $3
	ld [wPsyduckState], a
	ld a, $1
	ld [wPoliwagState], a
	callba PlayLowTimeSfx
	ld a, [wTimeRanOut]
	and a
	ret z
	xor a
	ld [wTimeRanOut], a
	ld a, $3
	ld [wSpecialModeState], a
	xor a
	ld [wSlotIsOpen], a
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 2], a
	ld [wIndicatorStates + 3], a
	ld [wIndicatorStates + 4], a
	ld a, [wCurrentStage]
	bit 0, a
	jr z, .asm_316ee
	callba Func_1c2cb
	callba LoadSlotCaveCoverGraphics_BlueField
	callba LoadMapBillboardTileData
.asm_316ee
	callba StopTimer
	call FillBottomMessageBufferWithBlackTile
	call EnableBottomText
	ld hl, wScrollingText1
	ld de, MapMoveFailedText
	call LoadScrollingText
	ret

Func_31708: ; 0x31708
	ld a, [wMapMoveDirection]
	and a
	jr nz, .asm_31728
	ld a, [wIndicatorStates]
	and a
	jr z, .asm_31728
	xor a
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	ld a, $80
	ld [wIndicatorStates + 4], a
	ld a, $1
	ld [wSlotIsOpen], a
	ld [wSpecialModeState], a
.asm_31728
	scf
	ret

Func_3172a: ; 0x3172a
	ld a, [wMapMoveDirection]
	and a
	jr z, .asm_3174a
	ld a, [wIndicatorStates + 1]
	and a
	jr z, .asm_3174a
	xor a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	ld a, $80
	ld [wIndicatorStates + 4], a
	ld a, $1
	ld [wSlotIsOpen], a
	ld [wSpecialModeState], a
.asm_3174a
	scf
	ret

Func_3174c: ; 0x3174c
	ld de, MUSIC_NOTHING
	call PlaySong
	rst AdvanceFrame
	callba ChooseNextMap_BlueField
	callba LoadMapBillboardTileData
	lb de, $25, $25
	call PlaySoundEffect
	ld bc, ArrivedAtMapText
	callba LoadScrollingMapNameText
.asm_3177a
	callba UpdateBottomText
	rst AdvanceFrame
	ld a, [wBottomTextEnabled]
	and a
	jr nz, .asm_3177a
	ld a, $2
	ld [wSpecialModeState], a
	scf
	ret


HandleGoldMapModeCollision: ; 0x314ae
	ld a, [wTimerActive]
	and a
	ld a, [wSpecialModeCollisionID]
	jr z, .asm_314d0
	cp SPECIAL_COLLISION_LEFT_TRIGGER
	jp z, OpenGoldMapMoveSlotFromLeft
	cp SPECIAL_COLLISION_STARYU_ALLEY_TRIGGER
	jp z, OpenGoldMapMoveSlotFromLeft
	cp SPECIAL_COLLISION_RIGHT_TRIGGER
	jp z, OpenGoldMapMoveSlotFromRight
	cp SPECIAL_COLLISION_BELLSPROUT
	jp z, OpenGoldMapMoveSlotFromRight
	cp SPECIAL_COLLISION_SLOT_HOLE
	jp z, ResolveSucsessfulGoldMapMove
.asm_314d0
	cp SPECIAL_COLLISION_NOTHING
	jr z, .asm_314d6
	scf
	ret

.asm_314d6
	call UpdateMapMove_GoldField
	ld a, [wSpecialModeState]
	call CallInFollowingTable
PointerTable_314df_GoldField: ; 0xd13df
	padded_dab Func_314ef_GoldField
	padded_dab Func_314f1_GoldField
	padded_dab Func_314f3_GoldField
	padded_dab Func_31505_GoldField

Func_314ef_GoldField: ; 0x314ef
	scf
	ret

Func_314f1_GoldField: ; 0x314f1
	scf
	ret

Func_314f3_GoldField: ; 0x314f3
	callba ConcludeMapMoveMode
	ld de, $0001
	call PlaySong
	scf
	ret

Func_31505_GoldField: ; 0x31505
	ld a, [wBottomTextEnabled]
	and a
	ret nz
	call FillBottomMessageBufferWithBlackTile
	callba ConcludeMapMoveMode
	ld de, $0001
	call PlaySong
	scf
	ret

UpdateMapMove_GoldField:
	ld a, $50
	ld [wLeftDiglettAnimationController], a
	ld [wRightDiglettAnimationController], a
	callba PlayLowTimeSfx
	ld a, [wTimeRanOut]
	and a
	ret z
	xor a
	ld [wTimeRanOut], a
	ld a, $3
	ld [wSpecialModeState], a
	xor a
	ld [wSlotIsOpen], a ;close slot and indicators
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 2], a
	ld [wIndicatorStates + 3], a
	ld [wIndicatorStates + 4], a
	ld a, [wCurrentStage]
	bit 0, a
	jr z, .asm_31577 ;if on stage without flippers(the tops), jump
	callba ClearAllGoldIndicators ;clear indicators
	callba LoadSlotCaveCoverGraphics_GoldField
	callba LoadMapBillboardTileData
.asm_31577
	callba StopTimer ;stop the timer
	call FillBottomMessageBufferWithBlackTile
	call EnableBottomText
	ld hl, wScrollingText1
	ld de, MapMoveFailedText
	call LoadScrollingText
	ret

OpenGoldMapMoveSlotFromLeft: ; 0x31591
	ld a, [wMapMoveDirection]
	and a
	jr nz, .asm_315b1
	ld a, [wIndicatorStates]
	and a
	jr z, .asm_315b1
	xor a
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	ld a, $80
	ld [wIndicatorStates + 4], a
	ld a, $1
	ld [wSlotIsOpen], a
	ld [wSpecialModeState], a
.asm_315b1
	scf
	ret

OpenGoldMapMoveSlotFromRight: ; 0x315b3
	ld a, [wMapMoveDirection]
	and a
	jr z, .asm_315d3
	ld a, [wIndicatorStates + 1]
	and a
	jr z, .asm_315d3
	xor a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	ld a, $80
	ld [wIndicatorStates + 4], a
	ld a, $1
	ld [wSlotIsOpen], a
	ld [wSpecialModeState], a
.asm_315d3
	scf
	ret

ResolveSucsessfulGoldMapMove: ; 0x315d5
	ld de, $0000
	call PlaySong
	rst AdvanceFrame
	callba ChooseNextMap_GoldField
	callba LoadMapBillboardTileData
	lb de, $25, $25
	call PlaySoundEffect
	ld bc, ArrivedAtMapText
	callba LoadScrollingMapNameText
.asm_31603
	callba UpdateBottomText
	rst AdvanceFrame
	ld a, [wBottomTextEnabled]
	and a
	jr nz, .asm_31603
	callba TryReleaseRoamingDogs
	ld a, $2
	ld [wSpecialModeState], a
	scf
	ret

Func_311b4_GoldField: ; 0x311b4
	ld a, [wMapMoveDirection]
	and a
	jr nz, .asm_311ce
	ld a, $80
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	xor a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	ld [wIndicatorStates + 4], a
	jr .asm_311e2

.asm_311ce
	ld a, $80
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	xor a
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	ld [wIndicatorStates + 4], a
	jr .asm_311e2

.asm_311e2
	ld a, $2
	callba _LoadDiglettGraphics
	ld a, $5
	callba _LoadDiglettGraphics
	ld a, $6a
	ld [wStageCollisionMap + $f0], a
	ld a, $6b
	ld [wStageCollisionMap + $110], a
	ld a, $66
	ld [wStageCollisionMap + $e3], a
	ld a, $67
	ld [wStageCollisionMap + $103], a
	callba CloseSlotCave_GoldField
	ld a, $4
	ld [wd7ad], a
	ld de, MUSIC_HURRY_UP_BLUE ; Either MUSIC_HURRY_UP_BLUE or MUSIC_HURRY_UP_RED. They have the same id in their respective audio Banks.
	call PlaySong
	ld a, [wCurrentStage]
	bit 0, a
	ret z
	callba ClearAllGoldIndicators
	ret

Func_31234_GoldField: ; 0x31234
	callba ResetIndicatorStates
	callba OpenSlotCave
	callba SetLeftAndRightAlleyArrowIndicatorStates_GoldField
	callba Func_107e9
	ld a, [wCurrentStage]
	bit 0, a
	ret z
	callba ClearAllGoldIndicators
	callba LoadSlotCaveCoverGraphics_GoldField
	callba LoadMapBillboardTileData
	ret

ChooseNextMap_GoldField: ; 0x31282
; Picks the next map to perform a map move.
; Also records which maps have been visited.
	ld a, [wNumMapMoves]
	inc a
	cp $6
	jr c, .dontReset
	ld a, $ff
	ld [wVisitedMaps], a
	ld [wVisitedMaps + 1], a
	ld [wVisitedMaps + 2], a
	ld [wVisitedMaps + 3], a
	ld [wVisitedMaps + 4], a
	ld [wVisitedMaps + 5], a
	xor a
.dontReset
	ld [wNumMapMoves], a
	cp $3
	jr c, .chooseMapFromArea1
	cp $5
	jr c, .chooseMapFromArea2
	ld a, MT_SILVER
	ld [wCurrentMap], a
	ld [wVisitedMaps + 5], a
	ret

.chooseMapFromArea1
	call GenRandom
	and $7 ; there are 8 maps in the Gold field initial map list.
	ld c, a
	ld b, $0
	ld hl, FirstMapMoveSet_GoldField
	add hl, bc
	ld c, [hl]
	ld hl, wVisitedMaps
	ld a, [wNumMapMoves]
	and a
	jr z, .asm_312d4
	ld b, a
.asm_312cd
	ld a, [hli]
	cp c
	jr z, .chooseMapFromArea1
	dec b
	jr nz, .asm_312cd
.asm_312d4
	ld a, c
	ld [wCurrentMap], a
	ld a, [wNumMapMoves]
	ld c, a
	ld b, $0
	ld hl, wVisitedMaps
	add hl, bc
	ld a, [wCurrentMap]
	ld [hl], a
	ret

.chooseMapFromArea2
	call GenRandom
	and $7
	cp 5
	jr nc, .chooseMapFromArea2
	ld c, a
	ld b, $0
	ld hl, SecondMapMoveSet_GoldField
	add hl, bc
	ld c, [hl]
	ld hl, wVisitedMaps + 3
	ld a, [wNumMapMoves]
	sub $3
	jr z, .asm_31306
	ld b, a
.asm_312ff
	ld a, [hli]
	cp c
	jr z, .chooseMapFromArea2
	dec b
	jr nz, .asm_312ff
.asm_31306
	ld a, c
	ld [wCurrentMap], a
	ld a, [wNumMapMoves]
	ld c, a
	ld b, $0
	ld hl, wVisitedMaps
	add hl, bc
	ld a, [wCurrentMap]
	ld [hl], a
	ret

FirstMapMoveSet_GoldField:
	db NEW_BARK_TOWN
	db VIOLET_CITY
	db RUINS_OF_ALPH
	db LAKE_OF_RAGE
	db ECRUTEAK_CITY
	db ILEX_FOREST
	db GOLDENROD_CITY
	db OLIVINE_CITY

SecondMapMoveSet_GoldField:
	db ICE_PATH
	db DARK_CAVE
	db BURNED_TOWER
	db TIN_TOWER
	db BLACKTHORN_CITY

HandleSilverMapModeCollision: ; 0x3161b
	ld a, [wTimerActive]
	and a
	ld a, [wSpecialModeCollisionID]
	jr z, .asm_3163d
	cp SPECIAL_COLLISION_LEFT_TRIGGER
	jp z, Func_31708_SilverField
	cp SPECIAL_COLLISION_SLOWPOKE
	jp z, Func_31708_SilverField
	cp SPECIAL_COLLISION_RIGHT_TRIGGER
	jp z, Func_3172a_SilverField
	cp SPECIAL_COLLISION_CLOYSTER
	jp z, Func_3172a_SilverField
	cp SPECIAL_COLLISION_SLOT_HOLE
	jp z, Func_3174c_SilverField
.asm_3163d
	cp SPECIAL_COLLISION_NOTHING
	jr z, .asm_31643
	scf
	ret

.asm_31643
	call UpdateMapMove_SilverField
	ld a, [wSpecialModeState]
	call CallInFollowingTable
PointerTable_3164c_SilverField: ; 0x3164c
	padded_dab Func_3165c_SilverField
	padded_dab Func_3165e_SilverField
	padded_dab Func_31660_SilverField
	padded_dab Func_31672_SilverField

Func_3165c_SilverField: ; 0x3165c
	scf
	ret

Func_3165e_SilverField: ; 0x3165e
	scf
	ret

Func_31660_SilverField: ; 0x31660
	callba ConcludeMapMoveMode
	ld de, $0001
	call PlaySong
	scf
	ret

Func_31672_SilverField: ; 0x31672
	ld a, [wBottomTextEnabled] ;if text is off
	and a
	ret nz
	call FillBottomMessageBufferWithBlackTile
	callba ConcludeMapMoveMode
	ld de, $0001
	call PlaySong
	scf
	ret

UpdateMapMove_SilverField: ; 0x3168c
	ld a, $50
	ld [wLeftMapMovePoliwagAnimationCounter], a
	ld [wRightMapMovePsyduckFrame], a
	ld a, $3
	ld [wPsyduckState], a
	ld a, $1
	ld [wPoliwagState], a
	callba PlayLowTimeSfx
	ld a, [wTimeRanOut]
	and a
	ret z
	xor a
	ld [wTimeRanOut], a
	ld a, $3
	ld [wSpecialModeState], a
	xor a
	ld [wSlotIsOpen], a
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 2], a
	ld [wIndicatorStates + 3], a
	ld [wIndicatorStates + 4], a
	ld a, [wCurrentStage]
	bit 0, a
	jr z, .asm_316ee
	callba Func_1c2cb
	callba LoadSlotCaveCoverGraphics_SilverField
	callba LoadMapBillboardTileData
.asm_316ee
	callba StopTimer
	call FillBottomMessageBufferWithBlackTile
	call EnableBottomText
	ld hl, wScrollingText1
	ld de, MapMoveFailedText
	call LoadScrollingText
	ret

Func_31708_SilverField: ; 0x31708
	ld a, [wMapMoveDirection]
	and a
	jr nz, .asm_31728
	ld a, [wIndicatorStates]
	and a
	jr z, .asm_31728
	xor a
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	ld a, $80
	ld [wIndicatorStates + 4], a
	ld a, $1
	ld [wSlotIsOpen], a
	ld [wSpecialModeState], a
.asm_31728
	scf
	ret

Func_3172a_SilverField: ; 0x3172a
	ld a, [wMapMoveDirection]
	and a
	jr z, .asm_3174a
	ld a, [wIndicatorStates + 1]
	and a
	jr z, .asm_3174a
	xor a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	ld a, $80
	ld [wIndicatorStates + 4], a
	ld a, $1
	ld [wSlotIsOpen], a
	ld [wSpecialModeState], a
.asm_3174a
	scf
	ret

Func_3174c_SilverField: ; 0x3174c
	ld de, $0000
	call PlaySong
	rst AdvanceFrame
	callba ChooseNextMap_SilverField
	callba LoadMapBillboardTileData
	lb de, $25, $25
	call PlaySoundEffect
	ld bc, ArrivedAtMapText
	callba LoadScrollingMapNameText
.asm_3177a
	callba UpdateBottomText
	rst AdvanceFrame
	ld a, [wBottomTextEnabled]
	and a
	jr nz, .asm_3177a
	callba TryReleaseRoamingDogs
	ld a, $2
	ld [wSpecialModeState], a
	scf
	ret

Func_31326_SilverField: ; 0x31326
	ld a, [wMapMoveDirection]
	and a
	jr nz, .asm_3134c
	ld a, $80
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	xor a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	ld [wIndicatorStates + 4], a
	ld a, $3
	callba _LoadPsyduckOrPoliwagGraphics
	jr .asm_31382

.asm_3134c
	ld a, $80
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	xor a
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	ld [wIndicatorStates + 4], a
	ld a, $1
	callba _LoadPsyduckOrPoliwagGraphics
	ld a, $6
	callba _LoadPsyduckOrPoliwagGraphics
	ld a, $7
	callba LoadPsyduckOrPoliwagNumberGraphics
.asm_31382
	ld a, [wCurrentStage]
	bit 0, a
	jr z, .asm_3139d
	ld a, $54
	ld [wStageCollisionMap + $e3], a
	ld a, $55
	ld [wStageCollisionMap + $103], a
	ld a, $52
	ld [wStageCollisionMap + $f0], a
	ld a, $53
	ld [wStageCollisionMap + $110], a
.asm_3139d
	ld a, $1
	ld [wd644], a
	callba CloseSlotCave
	ld de, $0003
	call PlaySong
	ld a, [wCurrentStage]
	bit 0, a
	ret z
	callba Func_1c2cb_SilverField
	ret

Func_313c3_SilverField: ; 0x313c3
	callba ResetIndicatorStates
	callba OpenSlotCave
	callba SetLeftAndRightAlleyArrowIndicatorStates_SilverField
	ld a, $0
	ld [wd644], a
	ld a, [wCurrentStage]
	bit 0, a
	ret z
	callba Func_1c2cb_SilverField
	callba LoadSlotCaveCoverGraphics_SilverField
	callba LoadMapBillboardTileData
	ret

ChooseNextMap_SilverField: ; 0x3140b
; Picks the next map to perform a map move.
; Also records which maps have been visited.
	ld a, [wNumMapMoves]
	inc a
	cp $6
	jr c, .dontReset
	ld a, $ff
	ld [wVisitedMaps], a
	ld [wVisitedMaps + 1], a
	ld [wVisitedMaps + 2], a
	ld [wVisitedMaps + 3], a
	ld [wVisitedMaps + 4], a
	ld [wVisitedMaps + 5], a
	xor a
.dontReset
	ld [wNumMapMoves], a
	cp $3
	jr c, .chooseMapFromArea1
	cp $5
	jr c, .chooseMapFromArea2
	ld a, MT_SILVER
	ld [wCurrentMap], a
	ld [wVisitedMaps + 5], a
	ret

.chooseMapFromArea1
	call GenRandom
	and $7 ; there are 8 maps in the first map list for silver field
	ld c, a
	ld b, $0
	ld hl, FirstMapMoveSet_SilverField
	add hl, bc
	ld c, [hl]
	ld hl, wVisitedMaps
	ld a, [wNumMapMoves]
	and a
	jr z, .asm_3145e
	ld b, a
.asm_31457
	ld a, [hli]
	cp c
	jr z, .chooseMapFromArea1
	dec b
	jr nz, .asm_31457
.asm_3145e
	ld a, c
	ld [wCurrentMap], a
	ld a, [wNumMapMoves]
	ld c, a
	ld b, $0
	ld hl, wVisitedMaps
	add hl, bc
	ld a, [wCurrentMap]
	ld [hl], a
	ret

.chooseMapFromArea2
	call GenRandom
	and $7
	cp 5
	jr nc, .chooseMapFromArea2
	ld c, a
	ld b, $0
	ld hl, SecondMapMoveSet_SilverField
	add hl, bc
	ld c, [hl]
	ld hl, wVisitedMaps + 3
	ld a, [wNumMapMoves]
	sub $3
	jr z, .asm_31490
	ld b, a
.asm_31489
	ld a, [hli]
	cp c
	jr z, .chooseMapFromArea2
	dec b
	jr nz, .asm_31489
.asm_31490
	ld a, c
	ld [wCurrentMap], a
	ld a, [wNumMapMoves]
	ld c, a
	ld b, $0
	ld hl, wVisitedMaps
	add hl, bc
	ld a, [wCurrentMap]
	ld [hl], a
	ret

FirstMapMoveSet_SilverField:
	db NEW_BARK_TOWN
	db VIOLET_CITY
	db DARK_CAVE
	db MAHOGANY_TOWN
	db AZALEA_TOWN
	db ILEX_FOREST
	db NATIONAL_PARK
	db OLIVINE_CITY

SecondMapMoveSet_SilverField:
	db ICE_PATH
	db MT_MORTAR
	db BURNED_TOWER
	db WHIRL_ISLANDS
	db BLACKTHORN_CITY

INCLUDE "engine/pinball_game/roaming_dogs.asm"

HandleRubyMapModeCollision: ; 0x314ae
	ld a, [wTimerActive]
	and a
	ld a, [wSpecialModeCollisionID]
	jr z, .asm_314d0
	cp SPECIAL_COLLISION_LEFT_TRIGGER
	jp z, OpenRubyMapMoveSlotFromLeft
	cp SPECIAL_COLLISION_STARYU_ALLEY_TRIGGER
	jp z, OpenRubyMapMoveSlotFromLeft
	cp SPECIAL_COLLISION_RIGHT_TRIGGER
	jp z, OpenRubyMapMoveSlotFromRight
	cp SPECIAL_COLLISION_BELLSPROUT
	jp z, OpenRubyMapMoveSlotFromRight
	cp SPECIAL_COLLISION_SLOT_HOLE
	jp z, ResolveSucsessfulRubyMapMove
.asm_314d0
	cp SPECIAL_COLLISION_NOTHING
	jr z, .asm_314d6
	scf
	ret

.asm_314d6
	call UpdateMapMove_RubyField
	ld a, [wSpecialModeState]
	call CallInFollowingTable
PointerTable_314df_RubyField: ; 0xd13df
	padded_dab Func_314ef_RubyField
	padded_dab Func_314f1_RubyField
	padded_dab Func_314f3_RubyField
	padded_dab Func_31505_RubyField

Func_314ef_RubyField: ; 0x314ef
	scf
	ret

Func_314f1_RubyField: ; 0x314f1
	scf
	ret

Func_314f3_RubyField: ; 0x314f3
	callba ConcludeMapMoveMode
	ld de, $0001
	call PlaySong
	scf
	ret

Func_31505_RubyField: ; 0x31505
	ld a, [wBottomTextEnabled]
	and a
	ret nz
	call FillBottomMessageBufferWithBlackTile
	callba ConcludeMapMoveMode
	ld de, $0001
	call PlaySong
	scf
	ret

UpdateMapMove_RubyField:
	ld a, $50
	ld [wLeftDiglettAnimationController], a
	ld [wRightDiglettAnimationController], a
	callba PlayLowTimeSfx
	ld a, [wTimeRanOut]
	and a
	ret z
	xor a
	ld [wTimeRanOut], a
	ld a, $3
	ld [wSpecialModeState], a
	xor a
	ld [wSlotIsOpen], a ;close slot and indicators
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 2], a
	ld [wIndicatorStates + 3], a
	ld [wIndicatorStates + 4], a
	ld a, [wCurrentStage]
	bit 0, a
	jr z, .asm_31577 ;if on stage without flippers(the tops), jump
	callba ClearAllRubyIndicators ;clear indicators
	callba LoadSlotCaveCoverGraphics_RubyField
	callba LoadMapBillboardTileData
.asm_31577
	callba StopTimer ;stop the timer
	call FillBottomMessageBufferWithBlackTile
	call EnableBottomText
	ld hl, wScrollingText1
	ld de, MapMoveFailedText
	call LoadScrollingText
	ret

OpenRubyMapMoveSlotFromLeft: ; 0x31591
	ld a, [wMapMoveDirection]
	and a
	jr nz, .asm_315b1
	ld a, [wIndicatorStates]
	and a
	jr z, .asm_315b1
	xor a
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	ld a, $80
	ld [wIndicatorStates + 4], a
	ld a, $1
	ld [wSlotIsOpen], a
	ld [wSpecialModeState], a
.asm_315b1
	scf
	ret

OpenRubyMapMoveSlotFromRight: ; 0x315b3
	ld a, [wMapMoveDirection]
	and a
	jr z, .asm_315d3
	ld a, [wIndicatorStates + 1]
	and a
	jr z, .asm_315d3
	xor a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	ld a, $80
	ld [wIndicatorStates + 4], a
	ld a, $1
	ld [wSlotIsOpen], a
	ld [wSpecialModeState], a
.asm_315d3
	scf
	ret

ResolveSucsessfulRubyMapMove: ; 0x315d5
	ld de, MUSIC_NOTHING
	call PlaySong
	rst AdvanceFrame
	callba ChooseNextMap_RubyField
	callba LoadMapBillboardTileData
	lb de, $25, $25
	call PlaySoundEffect
	ld bc, ArrivedAtMapText
	callba LoadScrollingMapNameText
.asm_3177a
	callba UpdateBottomText
	rst AdvanceFrame
	ld a, [wBottomTextEnabled]
	and a
	jr nz, .asm_3177a
	ld a, $2
	ld [wSpecialModeState], a
	scf
	ret

Func_311b4_RubyField: ; 0x311b4
	ld a, [wMapMoveDirection]
	and a
	jr nz, .asm_311ce
	ld a, $80
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	xor a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	ld [wIndicatorStates + 4], a
	jr .asm_311e2

.asm_311ce
	ld a, $80
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	xor a
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	ld [wIndicatorStates + 4], a
	jr .asm_311e2

.asm_311e2
	ld a, $2
	callba _LoadDiglettGraphics
	ld a, $5
	callba _LoadDiglettGraphics
	ld a, $6a
	ld [wStageCollisionMap + $f0], a
	ld a, $6b
	ld [wStageCollisionMap + $110], a
	ld a, $66
	ld [wStageCollisionMap + $e3], a
	ld a, $67
	ld [wStageCollisionMap + $103], a
	callba CloseSlotCave_
	ld a, $4
	ld [wd7ad], a
	ld de, MUSIC_HURRY_UP_BLUE ; Either MUSIC_HURRY_UP_BLUE or MUSIC_HURRY_UP_RED. They have the same id in their respective audio Banks.
	call PlaySong
	ld a, [wCurrentStage]
	bit 0, a
	ret z
	callba ClearAllRubyIndicators
	ret

Func_31234_RubyField: ; 0x31234
	callba ResetIndicatorStates
	callba OpenSlotCave
	callba SetLeftAndRightAlleyArrowIndicatorStates_RubyField
	callba Func_107e9
	ld a, [wCurrentStage]
	bit 0, a
	ret z
	callba ClearAllRubyIndicators
	callba LoadSlotCaveCoverGraphics_RubyField
	callba LoadMapBillboardTileData
	ret

ChooseNextMap_RubyField: ; 0x31282
; Picks the next map to perform a map move.
; Also records which maps have been visited.
	ld a, [wNumMapMoves]
	inc a
	cp $6
	jr c, .dontReset
	ld a, $ff
	ld [wVisitedMaps], a
	ld [wVisitedMaps + 1], a
	ld [wVisitedMaps + 2], a
	ld [wVisitedMaps + 3], a
	ld [wVisitedMaps + 4], a
	ld [wVisitedMaps + 5], a
	xor a
.dontReset
	ld [wNumMapMoves], a
	cp $3
	jr c, .chooseMapFromArea1
	cp $5
	jr c, .chooseMapFromArea2
	ld a, MT_SILVER
	ld [wCurrentMap], a
	ld [wVisitedMaps + 5], a
	ret

.chooseMapFromArea1
	call GenRandom
	and $7 ; there are 8 maps in the Ruby field initial map list.
	ld c, a
	ld b, $0
	ld hl, FirstMapMoveSet_RubyField
	add hl, bc
	ld c, [hl]
	ld hl, wVisitedMaps
	ld a, [wNumMapMoves]
	and a
	jr z, .asm_312d4
	ld b, a
.asm_312cd
	ld a, [hli]
	cp c
	jr z, .chooseMapFromArea1
	dec b
	jr nz, .asm_312cd
.asm_312d4
	ld a, c
	ld [wCurrentMap], a
	ld a, [wNumMapMoves]
	ld c, a
	ld b, $0
	ld hl, wVisitedMaps
	add hl, bc
	ld a, [wCurrentMap]
	ld [hl], a
	ret

.chooseMapFromArea2
	call GenRandom
	and $7
	cp 5
	jr nc, .chooseMapFromArea2
	ld c, a
	ld b, $0
	ld hl, SecondMapMoveSet_RubyField
	add hl, bc
	ld c, [hl]
	ld hl, wVisitedMaps + 3
	ld a, [wNumMapMoves]
	sub $3
	jr z, .asm_31306
	ld b, a
.asm_312ff
	ld a, [hli]
	cp c
	jr z, .chooseMapFromArea2
	dec b
	jr nz, .asm_312ff
.asm_31306
	ld a, c
	ld [wCurrentMap], a
	ld a, [wNumMapMoves]
	ld c, a
	ld b, $0
	ld hl, wVisitedMaps
	add hl, bc
	ld a, [wCurrentMap]
	ld [hl], a
	ret

FirstMapMoveSet_RubyField:
	db NEW_BARK_TOWN
	db VIOLET_CITY
	db RUINS_OF_ALPH
	db LAKE_OF_RAGE
	db ECRUTEAK_CITY
	db ILEX_FOREST
	db GOLDENROD_CITY
	db OLIVINE_CITY

SecondMapMoveSet_RubyField:
	db ICE_PATH
	db DARK_CAVE
	db BURNED_TOWER
	db TIN_TOWER
	db BLACKTHORN_CITY

HandleSapphireMapModeCollision: ; 0x3161b
	ld a, [wTimerActive]
	and a
	ld a, [wSpecialModeCollisionID]
	jr z, .asm_3163d
	cp SPECIAL_COLLISION_LEFT_TRIGGER
	jp z, Func_31708_SapphireField
	cp SPECIAL_COLLISION_SLOWPOKE
	jp z, Func_31708_SapphireField
	cp SPECIAL_COLLISION_RIGHT_TRIGGER
	jp z, Func_3172a_SapphireField
	cp SPECIAL_COLLISION_CLOYSTER
	jp z, Func_3172a_SapphireField
	cp SPECIAL_COLLISION_SLOT_HOLE
	jp z, Func_3174c_SapphireField
.asm_3163d
	cp SPECIAL_COLLISION_NOTHING
	jr z, .asm_31643
	scf
	ret

.asm_31643
	call UpdateMapMove_SapphireField
	ld a, [wSpecialModeState]
	call CallInFollowingTable
PointerTable_3164c_SapphireField: ; 0x3164c
	padded_dab Func_3165c_SapphireField
	padded_dab Func_3165e_SapphireField
	padded_dab Func_31660_SapphireField
	padded_dab Func_31672_SapphireField

Func_3165c_SapphireField: ; 0x3165c
	scf
	ret

Func_3165e_SapphireField: ; 0x3165e
	scf
	ret

Func_31660_SapphireField: ; 0x31660
	callba ConcludeMapMoveMode
	ld de, $0001
	call PlaySong
	scf
	ret

Func_31672_SapphireField: ; 0x31672
	ld a, [wBottomTextEnabled] ;if text is off
	and a
	ret nz
	call FillBottomMessageBufferWithBlackTile
	callba ConcludeMapMoveMode
	ld de, $0001
	call PlaySong
	scf
	ret

UpdateMapMove_SapphireField: ; 0x3168c
	ld a, $50
	ld [wLeftMapMovePoliwagAnimationCounter], a
	ld [wRightMapMovePsyduckFrame], a
	ld a, $3
	ld [wPsyduckState], a
	ld a, $1
	ld [wPoliwagState], a
	callba PlayLowTimeSfx
	ld a, [wTimeRanOut]
	and a
	ret z
	xor a
	ld [wTimeRanOut], a
	ld a, $3
	ld [wSpecialModeState], a
	xor a
	ld [wSlotIsOpen], a
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 2], a
	ld [wIndicatorStates + 3], a
	ld [wIndicatorStates + 4], a
	ld a, [wCurrentStage]
	bit 0, a
	jr z, .asm_316ee
	callba Func_1c2cb
	callba LoadSlotCaveCoverGraphics_SapphireField
	callba LoadMapBillboardTileData
.asm_316ee
	callba StopTimer
	call FillBottomMessageBufferWithBlackTile
	call EnableBottomText
	ld hl, wScrollingText1
	ld de, MapMoveFailedText
	call LoadScrollingText
	ret

Func_31708_SapphireField: ; 0x31708
	ld a, [wMapMoveDirection]
	and a
	jr nz, .asm_31728
	ld a, [wIndicatorStates]
	and a
	jr z, .asm_31728
	xor a
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	ld a, $80
	ld [wIndicatorStates + 4], a
	ld a, $1
	ld [wSlotIsOpen], a
	ld [wSpecialModeState], a
.asm_31728
	scf
	ret

Func_3172a_SapphireField: ; 0x3172a
	ld a, [wMapMoveDirection]
	and a
	jr z, .asm_3174a
	ld a, [wIndicatorStates + 1]
	and a
	jr z, .asm_3174a
	xor a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	ld a, $80
	ld [wIndicatorStates + 4], a
	ld a, $1
	ld [wSlotIsOpen], a
	ld [wSpecialModeState], a
.asm_3174a
	scf
	ret

Func_3174c_SapphireField: ; 0x3174c
	ld de, MUSIC_NOTHING
	call PlaySong
	rst AdvanceFrame
	callba ChooseNextMap_SapphireField
	callba LoadMapBillboardTileData
	lb de, $25, $25
	call PlaySoundEffect
	ld bc, ArrivedAtMapText
	callba LoadScrollingMapNameText
.asm_3177a
	callba UpdateBottomText
	rst AdvanceFrame
	ld a, [wBottomTextEnabled]
	and a
	jr nz, .asm_3177a
	ld a, $2
	ld [wSpecialModeState], a
	scf
	ret

Func_31326_SapphireField: ; 0x31326
	ld a, [wMapMoveDirection]
	and a
	jr nz, .asm_3134c
	ld a, $80
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	xor a
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	ld [wIndicatorStates + 4], a
	ld a, $3
	callba _LoadPsyduckOrPoliwagGraphics
	jr .asm_31382

.asm_3134c
	ld a, $80
	ld [wIndicatorStates + 1], a
	ld [wIndicatorStates + 3], a
	xor a
	ld [wIndicatorStates], a
	ld [wIndicatorStates + 2], a
	ld [wIndicatorStates + 4], a
	ld a, $1
	callba _LoadPsyduckOrPoliwagGraphics
	ld a, $6
	callba _LoadPsyduckOrPoliwagGraphics
	ld a, $7
	callba LoadPsyduckOrPoliwagNumberGraphics
.asm_31382
	ld a, [wCurrentStage]
	bit 0, a
	jr z, .asm_3139d
	ld a, $54
	ld [wStageCollisionMap + $e3], a
	ld a, $55
	ld [wStageCollisionMap + $103], a
	ld a, $52
	ld [wStageCollisionMap + $f0], a
	ld a, $53
	ld [wStageCollisionMap + $110], a
.asm_3139d
	ld a, $1
	ld [wd644], a
	callba CloseSlotCave
	ld de, $0003
	call PlaySong
	ld a, [wCurrentStage]
	bit 0, a
	ret z
	callba Func_1c2cb_SapphireField
	ret

Func_313c3_SapphireField: ; 0x313c3
	callba ResetIndicatorStates
	callba OpenSlotCave
	callba SetLeftAndRightAlleyArrowIndicatorStates_SapphireField
	ld a, $0
	ld [wd644], a
	ld a, [wCurrentStage]
	bit 0, a
	ret z
	callba Func_1c2cb_SapphireField
	callba LoadSlotCaveCoverGraphics_SapphireField
	callba LoadMapBillboardTileData
	ret

ChooseNextMap_SapphireField: ; 0x3140b
; Picks the next map to perform a map move.
; Also records which maps have been visited.
	ld a, [wNumMapMoves]
	inc a
	cp $6
	jr c, .dontReset
	ld a, $ff
	ld [wVisitedMaps], a
	ld [wVisitedMaps + 1], a
	ld [wVisitedMaps + 2], a
	ld [wVisitedMaps + 3], a
	ld [wVisitedMaps + 4], a
	ld [wVisitedMaps + 5], a
	xor a
.dontReset
	ld [wNumMapMoves], a
	cp $3
	jr c, .chooseMapFromArea1
	cp $5
	jr c, .chooseMapFromArea2
	ld a, MT_SILVER
	ld [wCurrentMap], a
	ld [wVisitedMaps + 5], a
	ret

.chooseMapFromArea1
	call GenRandom
	and $7 ; there are 8 maps in the first map list for Sapphire field
	ld c, a
	ld b, $0
	ld hl, FirstMapMoveSet_SapphireField
	add hl, bc
	ld c, [hl]
	ld hl, wVisitedMaps
	ld a, [wNumMapMoves]
	and a
	jr z, .asm_3145e
	ld b, a
.asm_31457
	ld a, [hli]
	cp c
	jr z, .chooseMapFromArea1
	dec b
	jr nz, .asm_31457
.asm_3145e
	ld a, c
	ld [wCurrentMap], a
	ld a, [wNumMapMoves]
	ld c, a
	ld b, $0
	ld hl, wVisitedMaps
	add hl, bc
	ld a, [wCurrentMap]
	ld [hl], a
	ret

.chooseMapFromArea2
	call GenRandom
	and $7
	cp 5
	jr nc, .chooseMapFromArea2
	ld c, a
	ld b, $0
	ld hl, SecondMapMoveSet_SapphireField
	add hl, bc
	ld c, [hl]
	ld hl, wVisitedMaps + 3
	ld a, [wNumMapMoves]
	sub $3
	jr z, .asm_31490
	ld b, a
.asm_31489
	ld a, [hli]
	cp c
	jr z, .chooseMapFromArea2
	dec b
	jr nz, .asm_31489
.asm_31490
	ld a, c
	ld [wCurrentMap], a
	ld a, [wNumMapMoves]
	ld c, a
	ld b, $0
	ld hl, wVisitedMaps
	add hl, bc
	ld a, [wCurrentMap]
	ld [hl], a
	ret

FirstMapMoveSet_SapphireField:
	db NEW_BARK_TOWN
	db VIOLET_CITY
	db DARK_CAVE
	db MAHOGANY_TOWN
	db AZALEA_TOWN
	db ILEX_FOREST
	db NATIONAL_PARK
	db OLIVINE_CITY

SecondMapMoveSet_SapphireField:
	db ICE_PATH
	db MT_MORTAR
	db BURNED_TOWER
	db WHIRL_ISLANDS
	db BLACKTHORN_CITY
