FOR X, 0, 4
TileDataPointers_GroudonFlamePillar_{u:X}:
	; The order of these should match the order of `GroudonPillarFrames`
	dw TileDataPointer_GroudonFlamePillar_{u:X}_Hidden
	dw TileDataPointer_GroudonFlamePillar_{u:X}_Summon_Frame0
	dw TileDataPointer_GroudonFlamePillar_{u:X}_Summon_Frame1
	dw TileDataPointer_GroudonFlamePillar_{u:X}_Summon_Frame2
	dw TileDataPointer_GroudonFlamePillar_{u:X}_Health1_Frame0
	dw TileDataPointer_GroudonFlamePillar_{u:X}_Health1_Frame1
	dw TileDataPointer_GroudonFlamePillar_{u:X}_Health2_Frame0
	dw TileDataPointer_GroudonFlamePillar_{u:X}_Health2_Frame1
	dw TileDataPointer_GroudonFlamePillar_{u:X}_Health3_Frame0
	dw TileDataPointer_GroudonFlamePillar_{u:X}_Health3_Frame1
	dw TileData_GroudonFlamePillar_{u:X}_Collision_Off
	dw TileData_GroudonFlamePillar_{u:X}_Collision_On
ENDR

FOR X, 1, 3
TileDataPointer_GroudonFlamePillar_{u:X}_Hidden:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Hidden

TileData_GroudonFlamePillar_{u:X}_Hidden:
	dw LoadTileLists
	db 2 * 3

	db $03
	dw vBGMap + 6 * $20 + 4 + ({u:X} * 3)
	db $80, $80, $80

	db $03
	dw vBGMap + 7 * $20 + 4 + ({u:X} * 3)
	db $80, $80, $80

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Summon_Frame0:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Summon_Frame0

TileData_GroudonFlamePillar_{u:X}_Summon_Frame0:
	dw LoadTileLists
	db 2 * 3

	db $03
	dw vBGMap + 6 * $20 + 4 + ({u:X} * 3)
	db $80, $80, $80

	db $03
	dw vBGMap + 7 * $20 + 4 + ({u:X} * 3)
	db $a8, $a9, $aa

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Summon_Frame1:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Summon_Frame1

TileData_GroudonFlamePillar_{u:X}_Summon_Frame1:
	dw LoadTileLists
	db 2 * 3

	db $03
	dw vBGMap + 6 * $20 + 4 + ({u:X} * 3)
	db $ab, $ac, $ad

	db $03
	dw vBGMap + 7 * $20 + 4 + ({u:X} * 3)
	db $ae, $af, $b0

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Summon_Frame2:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Summon_Frame2

TileData_GroudonFlamePillar_{u:X}_Summon_Frame2:
	dw LoadTileLists
	db 2 * 3

	db $03
	dw vBGMap + 6 * $20 + 4 + ({u:X} * 3)
	db $b1, $b2, $b3

	db $03
	dw vBGMap + 7 * $20 + 4 + ({u:X} * 3)
	db $b4, $b5, $b6

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Health1_Frame0:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Health1_Frame0

TileData_GroudonFlamePillar_{u:X}_Health1_Frame0:
	dw LoadTileLists
	db 2 * 3

	db $03
	dw vBGMap + 6 * $20 + 4 + ({u:X} * 3)
	db $80, $80, $80

	db $03
	dw vBGMap + 7 * $20 + 4 + ({u:X} * 3)
	db $b7, $b8, $b9

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Health1_Frame1:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Health1_Frame1

TileData_GroudonFlamePillar_{u:X}_Health1_Frame1:
	dw LoadTileLists
	db 2 * 3

	db $03
	dw vBGMap + 6 * $20 + 4 + ({u:X} * 3)
	db $80, $80, $80

	db $03
	dw vBGMap + 7 * $20 + 4 + ({u:X} * 3)
	db $ba, $bb, $bc

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Health2_Frame0:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Health2_Frame0

TileData_GroudonFlamePillar_{u:X}_Health2_Frame0:
	dw LoadTileLists
	db 2 * 3

	db $03
	dw vBGMap + 6 * $20 + 4 + ({u:X} * 3)
	db $80, $80, $80

	db $03
	dw vBGMap + 7 * $20 + 4 + ({u:X} * 3)
	db $bd, $be, $bf

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Health2_Frame1:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Health2_Frame1

TileData_GroudonFlamePillar_{u:X}_Health2_Frame1:
	dw LoadTileLists
	db 2 * 3

	db $03
	dw vBGMap + 6 * $20 + 4 + ({u:X} * 3)
	db $80, $80, $80

	db $03
	dw vBGMap + 7 * $20 + 4 + ({u:X} * 3)
	db $c0, $c1, $c2

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Health3_Frame0:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Health3_Frame0

TileData_GroudonFlamePillar_{u:X}_Health3_Frame0:
	dw LoadTileLists
	db 2 * 3

	db $03
	dw vBGMap + 6 * $20 + 4 + ({u:X} * 3)
	db $80, $80, $80

	db $03
	dw vBGMap + 7 * $20 + 4 + ({u:X} * 3)
	db $c3, $c4, $c5

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Health3_Frame1:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Health3_Frame1

TileData_GroudonFlamePillar_{u:X}_Health3_Frame1:
	dw LoadTileLists
	db 2 * 3

	db $03
	dw vBGMap + 6 * $20 + 4 + ({u:X} * 3)
	db $80, $80, $80

	db $03
	dw vBGMap + 7 * $20 + 4 + ({u:X} * 3)
	db $c6, $c7, $c8

	db $00

TileData_GroudonFlamePillar_{u:X}_Collision_Off:
	db $03
	dw wStageCollisionMap + 8 * $20 + 4 + ({u:X} * 3)
	db $00, $00, $00

	db $03
	dw wStageCollisionMap + 9 * $20 + 4 + ({u:X} * 3)
	db $00, $00, $00

	db $00
ENDR

FOR X, 0, 4, 3
TileDataPointer_GroudonFlamePillar_{u:X}_Hidden:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Hidden

TileData_GroudonFlamePillar_{u:X}_Hidden:
	dw LoadTileLists
	db 2 * 2

	db $02
	dw vBGMap + 3 * $20 + 5 + ({u:X} * 8 / 3)
	db $80, $80

	db $02
	dw vBGMap + 4 * $20 + 5 + ({u:X} * 8 / 3)
	db $80, $80

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Summon_Frame0:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Summon_Frame0

TileData_GroudonFlamePillar_{u:X}_Summon_Frame0:
	dw LoadTileLists
	db 2 * 2

	db $02
	dw vBGMap + 3 * $20 + 5 + ({u:X} * 8 / 3)
	db $80, $80

	db $02
	dw vBGMap + 4 * $20 + 5 + ({u:X} * 8 / 3)
	db $c9, $ca

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Summon_Frame1:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Summon_Frame1

TileData_GroudonFlamePillar_{u:X}_Summon_Frame1:
	dw LoadTileLists
	db 2 * 2

	db $02
	dw vBGMap + 3 * $20 + 5 + ({u:X} * 8 / 3)
	db $cb, $cc

	db $02
	dw vBGMap + 4 * $20 + 5 + ({u:X} * 8 / 3)
	db $cd, $ce

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Summon_Frame2:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Summon_Frame2

TileData_GroudonFlamePillar_{u:X}_Summon_Frame2:
	dw LoadTileLists
	db 2 * 2

	db $02
	dw vBGMap + 3 * $20 + 5 + ({u:X} * 8 / 3)
	db $cf, $d0

	db $02
	dw vBGMap + 4 * $20 + 5 + ({u:X} * 8 / 3)
	db $d1, $d2

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Health1_Frame0:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Health1_Frame0

TileData_GroudonFlamePillar_{u:X}_Health1_Frame0:
	dw LoadTileLists
	db 2 * 2

	db $02
	dw vBGMap + 3 * $20 + 5 + ({u:X} * 8 / 3)
	db $80, $80

	db $02
	dw vBGMap + 4 * $20 + 5 + ({u:X} * 8 / 3)
	db $d3, $d4

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Health1_Frame1:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Health1_Frame1

TileData_GroudonFlamePillar_{u:X}_Health1_Frame1:
	dw LoadTileLists
	db 2 * 2

	db $02
	dw vBGMap + 3 * $20 + 5 + ({u:X} * 8 / 3)
	db $80, $80

	db $02
	dw vBGMap + 4 * $20 + 5 + ({u:X} * 8 / 3)
	db $d5, $d6

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Health2_Frame0:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Health2_Frame0

TileData_GroudonFlamePillar_{u:X}_Health2_Frame0:
	dw LoadTileLists
	db 2 * 2

	db $02
	dw vBGMap + 3 * $20 + 5 + ({u:X} * 8 / 3)
	db $80, $80

	db $02
	dw vBGMap + 4 * $20 + 5 + ({u:X} * 8 / 3)
	db $d7, $d8

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Health2_Frame1:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Health2_Frame1

TileData_GroudonFlamePillar_{u:X}_Health2_Frame1:
	dw LoadTileLists
	db 2 * 2

	db $02
	dw vBGMap + 3 * $20 + 5 + ({u:X} * 8 / 3)
	db $80, $80

	db $02
	dw vBGMap + 4 * $20 + 5 + ({u:X} * 8 / 3)
	db $d9, $da

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Health3_Frame0:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Health3_Frame0

TileData_GroudonFlamePillar_{u:X}_Health3_Frame0:
	dw LoadTileLists
	db 2 * 2

	db $02
	dw vBGMap + 3 * $20 + 5 + ({u:X} * 8 / 3)
	db $80, $80

	db $02
	dw vBGMap + 4 * $20 + 5 + ({u:X} * 8 / 3)
	db $db, $dc

	db $00

TileDataPointer_GroudonFlamePillar_{u:X}_Health3_Frame1:
	db $01
	dw TileData_GroudonFlamePillar_{u:X}_Health3_Frame1

TileData_GroudonFlamePillar_{u:X}_Health3_Frame1:
	dw LoadTileLists
	db 2 * 2

	db $02
	dw vBGMap + 3 * $20 + 5 + ({u:X} * 8 / 3)
	db $80, $80

	db $02
	dw vBGMap + 4 * $20 + 5 + ({u:X} * 8 / 3)
	db $dd, $de

	db $00

TileData_GroudonFlamePillar_{u:X}_Collision_Off:
	db $02
	dw wStageCollisionMap + 5 * $20 + 5 + ({u:X} * 8 / 3)
	db $00, $00

	db $02
	dw wStageCollisionMap + 6 * $20 + 5 + ({u:X} * 8 / 3)
	db $00, $00

	db $00
ENDR

TileData_GroudonFlamePillar_0_Collision_On:
	db $02
	dw wStageCollisionMap + 5 * $20 + 5
	db $3e, $3f

	db $02
	dw wStageCollisionMap + 6 * $20 + 5
	db $3c, $3d

	db $00

TileData_GroudonFlamePillar_1_Collision_On:
	db $03
	dw wStageCollisionMap + 8 * $20 + 7
	db $33, $34, $35

	db $03
	dw wStageCollisionMap + 9 * $20 + 7
	db $30, $31, $32

	db $00

TileData_GroudonFlamePillar_2_Collision_On:
	db $03
	dw wStageCollisionMap + 8 * $20 + 10
	db $39, $3a, $3b

	db $03
	dw wStageCollisionMap + 9 * $20 + 10
	db $36, $37, $38

	db $00

TileData_GroudonFlamePillar_3_Collision_On:
	db $02
	dw wStageCollisionMap + 5 * $20 + 13
	db $3e, $3f

	db $02
	dw wStageCollisionMap + 6 * $20 + 13
	db $3c, $3d

	db $00
