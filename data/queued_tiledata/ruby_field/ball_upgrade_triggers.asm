TileDataPointers_15511_RubyField:
	dw TileData_1551d_RubyField
	dw TileData_15523_RubyField
	dw TileData_1552a_RubyField

TileDataPointers_15517_RubyField:
	dw TileData_15530_RubyField
	dw TileData_15536_RubyField
	dw TileData_1553d_RubyField

TileData_1551d_RubyField: ; 0x1551d
	db $01 ; total number of tiles

	db $01 ; number of tiles
	dw vBGMap + $E7
	db $ac

	db $00 ; terminator

TileData_15523_RubyField: ; 0x15523
	db $02 ; total number of tiles

	db $02 ; number of tiles
	dw vBGMap + $C9
	db $ad, $ae

	db $00 ; terminator

TileData_1552a_RubyField: ; 0x1552a
	db $01 ; total number of tiles

	db $01 ; number of tiles
	dw vBGMap + $CC
	db $af

	db $00 ; terminator

TileData_15530_RubyField: ; 0x15530
	db $01 ; total number of tiles

	db $01 ; number of tiles
	dw vBGMap + $E7
	db $66

	db $00 ; terminator

TileData_15536_RubyField: ; 0x15536
	db $02 ; total number of tiles

	db $02 ; number of tiles
	dw vBGMap + $C9
	db $68, $69

	db $00 ; terminator

TileData_1553d_RubyField: ; 0x1553d
	db $01 ; total number of tiles

	db $01 ; number of tiles
	dw vBGMap + $CC
	db $6a

	db $00 ; terminator

TileDataPointers_BallUpgrade_On_GameBoyColor_RubyField:
	dw TileData_BallUpgrade_Left_On_GameBoyColor_RubyField
	dw TileData_BallUpgrade_Center_On_GameBoyColor_RubyField
	dw TileData_BallUpgrade_Right_On_GameBoyColor_RubyField

TileDataPointers_BallUpgrade_Off_GameBoyColor_RubyField:
	dw TileData_BallUpgrade_Left_Off_GameBoyColor_RubyField
	dw TileData_BallUpgrade_Center_Off_GameBoyColor_RubyField
	dw TileData_BallUpgrade_Right_Off_GameBoyColor_RubyField
