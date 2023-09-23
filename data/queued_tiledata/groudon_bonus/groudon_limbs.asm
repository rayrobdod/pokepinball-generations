TileDataPointer_GroudonLimbs_Idle0:
	db $03
	dw TileData_GroudonLimbs_Idle0_0
	dw TileData_GroudonLimbs_Idle0_2
	dw TileData_GroudonLimbs_Idle0_4

TileData_GroudonLimbs_Idle0_0:
	dw LoadTileLists
	db 2 * 6

	db $06
	dw vBGMap + 0 * $20 + 7
	db $80, $81, $82, $83, $84, $85

	db $06
	dw vBGMap + 1 * $20 + 7
	db $86, $87, $88, $89, $8a, $8b

	db $00

TileData_GroudonLimbs_Idle0_2:
	dw LoadTileLists
	db 2 * 6

	db $06
	dw vBGMap + 2 * $20 + 7
	db $8c, $8d, $8e, $8f, $90, $91

	db $06
	dw vBGMap + 3 * $20 + 7
	db $92, $93, $94, $95, $96, $97

	db $00

TileData_GroudonLimbs_Idle0_4:
	dw LoadTileLists
	db 2 * 6

	db $06
	dw vBGMap + 4 * $20 + 7
	db $98, $99, $9a, $9b, $9c, $9d

	db $06
	dw vBGMap + 5 * $20 + 7
	db $9e, $9f, $a0, $a1, $a2, $a3

	db $00

TileDataPointer_GroudonLimbs_Idle1:
	db $03
	dw TileData_GroudonLimbs_Idle1_0
	dw TileData_GroudonLimbs_Idle1_2
	dw TileData_GroudonLimbs_Idle1_4

TileData_GroudonLimbs_Idle1_0:
	dw LoadTileLists
	db 2 * 6

	db $06
	dw vBGMap + 0 * $20 + 7
	db $a4, $a5, $a6, $a7, $a8, $a9

	db $06
	dw vBGMap + 1 * $20 + 7
	db $aa, $ab, $ac, $ad, $ae, $af

	db $00

TileData_GroudonLimbs_Idle1_2:
	dw LoadTileLists
	db 2 * 6

	db $06
	dw vBGMap + 2 * $20 + 7
	db $b0, $b1, $b2, $b3, $b4, $b5

	db $06
	dw vBGMap + 3 * $20 + 7
	db $b6, $b7, $b8, $b9, $ba, $bb

	db $00

TileData_GroudonLimbs_Idle1_4:
	dw LoadTileLists
	db 2 * 6

	db $06
	dw vBGMap + 4 * $20 + 7
	db $bc, $bd, $be, $bf, $c0, $c1

	db $06
	dw vBGMap + 5 * $20 + 7
	db $c2, $c3, $c4, $c5, $c6, $c7

	db $00
