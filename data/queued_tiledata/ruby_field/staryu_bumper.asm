LoadChinchouStateTable_RubyField:
	dw LoadChinchouState0_RubyField
	dw LoadChinchouState1_RubyField
	dw LoadChinchouState2_RubyField
	dw LoadChinchouState3_RubyField

LoadChinchouState0_RubyField: ;0x16918
	db $02
	dw TileData_16921_RubyField
	dw TransitionToUnlitChinchou_RubyField

LoadChinchouState1_RubyField: ;0x1691b
	db $02
	dw TileData_16934_RubyField
    dw TransitionToLitChinchou_RubyField

LoadChinchouState2_RubyField: ;0x1691e
	db $02
	dw TileData_16947_RubyField
	dw TransitionToUnlitChinchou_RubyField
	
LoadChinchouState3_RubyField: ;0x1691e
	db $02
	dw TileData_16947_RubyField
	dw TransitionToLitChinchou_RubyField

TileData_16921_RubyField: ; 0x16921
	dw LoadTileLists
	db $03

	db $02
	dw vBGMap + $1E7
	db $C6, $C7

	db $01
	dw vBGMap + $207
	db $C8

	db $00

TileData_16934_RubyField: ; 0x16934
	dw LoadTileLists
	db $03

	db $02
	dw vBGMap + $1E7
	db $C6, $C7

	db $01
	dw vBGMap + $207
	db $C8

	db $00

TileData_16947_RubyField: ; 0x16947
	dw LoadTileLists
	db $03

	db $02
	dw vBGMap + $1E7
	db $CA, $CB

	db $01
	dw vBGMap + $207
	db $CC

	db $00

TransitionToLitChinchou_RubyField:
    dw LoadPalettes
	db $08
	db $04 ; number of colors
	db $18
	dw StageRubyFieldTopBGPalette3Lit
	db Bank(StageRubyFieldTopBGPalette3Lit)
	db $00 ; terminator
	
TransitionToUnlitChinchou_RubyField:
    dw LoadPalettes
	db $08
	db $04 ; number of colors
	db $18
	dw StageRubyFieldTopBGPalette3Unlit
	db Bank(StageRubyFieldTopBGPalette3Unlit)
	db $00 ; terminator
