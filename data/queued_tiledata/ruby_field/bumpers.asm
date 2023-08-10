TileDataPointers_16010_RubyField:
	dw TileData_16018_RubyField
	dw TileData_1601b_RubyField
	dw TileData_1601e_RubyField
	dw TileData_16021_RubyField

TileData_16018_RubyField: ; 0x16018
	db $01
	dw TileData_16024_RubyField

TileData_1601b_RubyField: ; 0x1601b
	db $01
	dw TileData_1603B_RubyField

TileData_1601e_RubyField: ; 0x1601e
	db $01
	dw TileData_16052_RubyField

TileData_16021_RubyField: ; 0x16021
	db $01
	dw TileData_16069_RubyField

TileData_16024_RubyField: ; 0x16024
	dw LoadTileLists
	db $07 ; total number of tiles

	db $01 ; number of tiles
	dw vBGMap + $124
	db $60

	db $02 ; number of tiles
	dw vBGMap + $144
	db $61, $62

	db $02 ; number of tiles
	dw vBGMap + $164
	db $63, $64

	db $02 ; number of tiles
	dw vBGMap + $185
	db $65, $66

	db $00 ; terminator

TileData_1603B_RubyField: ; 0x1603B
	dw LoadTileLists
	db $07 ; total number of tiles

	db $01 ; number of tiles
	dw vBGMap + $124
	db $67

	db $02 ; number of tiles
	dw vBGMap + $144
	db $68, $69

	db $02 ; number of tiles
	dw vBGMap + $164
	db $6A, $6B

	db $02 ; number of tiles
	dw vBGMap + $185
	db $6C, $6D

	db $00 ; terminator

TileData_16052_RubyField: ; 0x16052
	dw LoadTileLists
	db $07 ; total number of tiles

	db $01 ; number of tiles
	dw vBGMap + $12F
	db $6E

	db $02 ; number of tiles
	dw vBGMap + $14E
	db $6F, $70

	db $02 ; number of tiles
	dw vBGMap + $16E
	db $71, $72

	db $02 ; number of tiles
	dw vBGMap + $18D
	db $73, $74

	db $00 ; terminator

TileData_16069_RubyField: ; 0x16069
	dw LoadTileLists
	db $07 ; total number of tiles

	db $01 ; number of tiles
	dw vBGMap + $12F
	db $75

	db $02 ; number of tiles
	dw vBGMap + $14E
	db $76, $77

	db $02 ; number of tiles
	dw vBGMap + $16E
	db $78, $79

	db $02 ; number of tiles
	dw vBGMap + $18D
	db $7A, $7B

	db $00 ; terminator

TileDataPointers_Slingshots_RubyField:
	dw TileDataPointer_Slingshot_Left_Off_GameBoyColor_RubyField
	dw TileDataPointer_Slingshot_Left_On_GameBoyColor_RubyField
	dw TileDataPointer_Slingshot_Right_Off_GameBoyColor_RubyField
	dw TileDataPointer_Slingshot_Right_On_GameBoyColor_RubyField
