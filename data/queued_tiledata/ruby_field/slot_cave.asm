TileDataPointers_1644d_RubyField:
	dw TileData_16455_RubyField
	dw TileData_16458_RubyField
	dw TileData_1645b_RubyField
	dw TileData_16460_RubyField

TileData_16455_RubyField: ; 0x16455
	db $01
	dw TileData_16465_RubyField

TileData_16458_RubyField: ; 0x16458
	db $01
	dw TileData_1646f_RubyField

TileData_1645b_RubyField: ; 0x1645b
	db $02
	dw TileData_16479_RubyField
	dw TileData_16483_RubyField

TileData_16460_RubyField: ; 0x16460
	db $02
	dw TileData_1648D_RubyField
	dw TileData_16497_RubyField

TileData_16465_RubyField: ; 0x16465
	dw Func_11d2
	db $20, $02
	dw vTilesSH tile $46
	dw StageRubyFieldTopBaseGameBoyGfx + $1c0
	db Bank(StageRubyFieldTopBaseGameBoyGfx)
	db $00

TileData_1646f_RubyField: ; 0x1646f
	dw Func_11d2
	db $20, $02
	dw vTilesSH tile $46
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $340
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00

TileData_16479_RubyField: ; 0x16479
	dw Func_11d2
	db $20, $02
	dw vTilesBG tile $48
	dw StageRedFieldBottomBaseGameBoyGfx + $c80
	db Bank(StageRedFieldBottomBaseGameBoyGfx)
	db $00

TileData_16483_RubyField: ; 0x16483
	dw Func_11d2
	db $20, $02
	dw vTilesBG tile $4A
	dw StageRedFieldBottomBaseGameBoyGfx + $CA0
	db Bank(StageRedFieldBottomBaseGameBoyGfx)
	db $00

TileData_1648D_RubyField: ; 0x1648D
	dw Func_11d2
	db $20, $02
	dw vTilesBG tile $48
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $340
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00

TileData_16497_RubyField: ; 0x16497
	dw Func_11d2
	db $20, $02
	dw vTilesBG tile $4A
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $360
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00

TileDataPointers_SlotCave_GameBoyColor_RubyField:
	dw TileDataPointer_SlotCave_Top_Closed_GameBoyColor_RubyField
	dw TileDataPointer_SlotCave_Top_Open_GameBoyColor_RubyField
	dw TileDataPointer_SlotCave_Closed_GameBoyColor_RubyField
	dw TileDataPointer_SlotCave_Open_GameBoyColor_RubyField
