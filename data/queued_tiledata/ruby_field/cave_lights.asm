TileDataPointers_CaveLights_On_GameBoy_RubyField:
	dw TileData_CaveLight_C_On_GameBoy_RubyField
	dw TileData_CaveLight_A_On_GameBoy_RubyField
	dw TileData_CaveLight_V_On_GameBoy_RubyField
	dw TileData_CaveLight_E_On_GameBoy_RubyField

TileDataPointers_CaveLights_Off_GameBoy_RubyField:
	dw TileData_CaveLight_C_Off_GameBoy_RubyField
	dw TileData_CaveLight_A_Off_GameBoy_RubyField
	dw TileData_CaveLight_V_Off_GameBoy_RubyField
	dw TileData_CaveLight_E_Off_GameBoy_RubyField

TileData_CaveLight_C_On_GameBoy_RubyField:
	db $01 ; total number of tiles

	db $01 ; number of tiles
	dw vBGMap + $121
	db $7d

	db $00 ; terminator

TileData_CaveLight_A_On_GameBoy_RubyField:
	db $01 ; total number of tiles

	db $01 ; number of tiles
	dw vBGMap + $123
	db $7d

	db $00 ; terminator

TileData_CaveLight_V_On_GameBoy_RubyField:
	db $01 ; total number of tiles

	db $01 ; number of tiles
	dw vBGMap + $130
	db $7f

	db $00 ; terminator

TileData_CaveLight_E_On_GameBoy_RubyField:
	db $01 ; total number of tiles

	db $01 ; number of tiles
	dw vBGMap + $132
	db $7f

	db $00 ; terminator

TileData_CaveLight_C_Off_GameBoy_RubyField:
	db $01 ; total number of tiles

	db $01 ; number of tiles
	dw vBGMap + $121
	db $7c

	db $00 ; terminator

TileData_CaveLight_A_Off_GameBoy_RubyField:
	db $01 ; total number of tiles

	db $01 ; number of tiles
	dw vBGMap + $123
	db $7c

	db $00 ; terminator

TileData_CaveLight_V_Off_GameBoy_RubyField:
	db $01 ; total number of tiles

	db $01 ; number of tiles
	dw vBGMap + $130
	db $7e

	db $00 ; terminator

TileData_CaveLight_E_Off_GameBoy_RubyField:
	db $01 ; total number of tiles

	db $01 ; number of tiles
	dw vBGMap + $132
	db $7e

	db $00 ; terminator

TileDataPointers_CaveLights_On_GameBoyColor_RubyField:
	dw TileData_CaveLight_C_On_GameBoyColor_RubyField
	dw TileData_CaveLight_A_On_GameBoyColor_RubyField
	dw TileData_CaveLight_V_On_GameBoyColor_RubyField
	dw TileData_CaveLight_E_On_GameBoyColor_RubyField

TileDataPointers_CaveLights_Off_GameBoyColor_RubyField:
	dw TileData_CaveLight_C_Off_GameBoyColor_RubyField
	dw TileData_CaveLight_A_Off_GameBoyColor_RubyField
	dw TileData_CaveLight_V_Off_GameBoyColor_RubyField
	dw TileData_CaveLight_E_Off_GameBoyColor_RubyField
