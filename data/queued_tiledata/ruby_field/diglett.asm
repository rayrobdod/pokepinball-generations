TileListDataPointers_14a11_RubyField: ; 0x14a11
	dw TileListData_14a1d_RubyField
	dw TileListData_14a20_RubyField
	dw TileListData_14a23_RubyField
	dw TileListData_14a26_RubyField
	dw TileListData_14a29_RubyField
	dw TileListData_14a2c_RubyField

TileListData_14a1d_RubyField: ; 0x14a1d
	db $01
	dw TileListData_14a2f_RubyField

TileListData_14a20_RubyField: ; 0x14a20
	db $01
	dw TileListData_14a3d_RubyField

TileListData_14a23_RubyField: ; 0x14a23
	db $01
	dw TileListData_14a4b_RubyField

TileListData_14a26_RubyField: ; 0x14a26
	db $01
	dw TileListData_14a59_RubyField

TileListData_14a29_RubyField: ; 0x14a29
	db $01
	dw TileListData_14a67_RubyField

TileListData_14a2c_RubyField: ; 0x14a2c
	db $01
	dw TileListData_14a75_RubyField

TileListData_14a2f_RubyField: ; 0x14a2f
	dw LoadTileLists
	db $04 ; total number of tiles

	db $02 ; number of tiles
	dw vBGMap + $a3
	db $4C, $4D

	db $02 ; number of tiles
	dw vBGMap + $c3
	db $4E, $4F

	db $00  ; terminator

TileListData_14a3d_RubyField: ; 0x14a3d
	dw LoadTileLists
	db $04 ; total number of tiles

	db $02 ; number of tiles
	dw vBGMap + $a3
	db $50, $51

	db $02 ; number of tiles
	dw vBGMap + $c3
	db $52, $53

	db $00  ; terminator

TileListData_14a4b_RubyField: ; 0x14a4b
	dw LoadTileLists
	db $04 ; total number of tiles

	db $02 ; number of tiles
	dw vBGMap + $a3
	db $54, $80

	db $02 ; number of tiles
	dw vBGMap + $c3
	db $55, $80

	db $00  ; terminator

TileListData_14a59_RubyField: ; 0x14a59
	dw LoadTileLists
	db $04 ; total number of tiles

	db $02 ; number of tiles
	dw vBGMap + $af
	db $56, $57

	db $02 ; number of tiles
	dw vBGMap + $cf
	db $58, $59

	db $00  ; terminator

TileListData_14a67_RubyField: ; 0x14a67
	dw LoadTileLists
	db $04 ; total number of tiles

	db $02 ; number of tiles
	dw vBGMap + $af
	db $5a, $5b

	db $02 ; number of tiles
	dw vBGMap + $cf
	db $5c, $5d

	db $00  ; terminator

TileListData_14a75_RubyField: ; 0x14a75
	dw LoadTileLists
	db $04 ; total number of tiles

	db $02 ; number of tiles
	dw vBGMap + $af
	db $80, $5e

	db $02 ; number of tiles
	dw vBGMap + $cf
	db $80, $5f

	db $00  ; terminator

TileDataPointers_Linoone_GameBoyColor_RubyField:
	dw TileDataPointer_Linoone_Left_0_GameBoyColor_RubyField
	dw TileDataPointer_Linoone_Left_1_GameBoyColor_RubyField
	dw TileDataPointer_Linoone_Left_Hit_GameBoyColor_RubyField
	dw TileDataPointer_Linoone_Right_0_GameBoyColor_RubyField
	dw TileDataPointer_Linoone_Right_1_GameBoyColor_RubyField
	dw TileDataPointer_Linoone_Right_Hit_GameBoyColor_RubyField

Data_14af5_RubyField: ; 0x14af5
	dw Data_14b05_RubyField
	dw Data_14b0e_RubyField
	dw Data_14b17_RubyField
	dw Data_14b20_RubyField
	dw Data_14b29_RubyField
	dw Data_14b32_RubyField
	dw Data_14b3b_RubyField
	dw Data_14b44_RubyField

Data_14b05_RubyField: ; 0x14b05
	db $04
	dw Data_14b4d_RubyField
	dw Data_14b57_RubyField
	dw Data_14b61_RubyField
	dw Data_14b6b_RubyField

Data_14b0e_RubyField: ; 0x14b0e
	db $04
	dw Data_14b75_RubyField
	dw Data_14b7f_RubyField
	dw Data_14b89_RubyField
	dw Data_14b93_RubyField

Data_14b17_RubyField: ; 0x14b17
	db $04
	dw Data_14b9d_RubyField
	dw Data_14ba7_RubyField
	dw Data_14bb1_RubyField
	dw Data_14bbb_RubyField

Data_14b20_RubyField: ; 0x14b20
	db $04
	dw Data_14bc5_RubyField
	dw Data_14bcf_RubyField
	dw Data_14bd9_RubyField
	dw Data_14be3_RubyField

Data_14b29_RubyField: ; 0x14b29
	db $04
	dw Data_14bed_RubyField
	dw Data_14bf7_RubyField
	dw Data_14c01_RubyField
	dw Data_14c0b_RubyField

Data_14b32_RubyField: ; 0x14b32
	db $04
	dw Data_14c15_RubyField
	dw Data_14c1f_RubyField
	dw Data_14c29_RubyField
	dw Data_14c33_RubyField

Data_14b3b_RubyField: ; 0x14b3b
	db $04
	dw Data_14c3d_RubyField
	dw Data_14c47_RubyField
	dw Data_14c51_RubyField
	dw Data_14c5b_RubyField

Data_14b44_RubyField: ; 0x14b44
	db $04
	dw Data_14c65_RubyField
	dw Data_14c6f_RubyField
	dw Data_14c79_RubyField
	dw Data_14c83_RubyField

Data_14b4d_RubyField: ; 0x14b4d
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $26
	dw StageRubyFieldBottomBaseGameBoyGfx + $a60
	db Bank(StageRubyFieldBottomBaseGameBoyGfx)
	db $00 ; terminator

Data_14b57_RubyField: ; 0x14b57
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $29
	dw StageRubyFieldBottomBaseGameBoyGfx + $a90
	db Bank(StageRubyFieldBottomBaseGameBoyGfx)
	db $00 ; terminator

Data_14b61_RubyField: ; 0x14b61
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $2C
	dw StageRubyFieldBottomBaseGameBoyGfx + $ac0
	db Bank(StageRubyFieldBottomBaseGameBoyGfx)
	db $00 ; terminator

Data_14b6b_RubyField: ; 0x14b6b
	dw Func_11d2
	db $10, $01
	dw vTilesBG tile $2F
	dw StageRubyFieldBottomBaseGameBoyGfx + $af0
	db Bank(StageRubyFieldBottomBaseGameBoyGfx)
	db $00 ; terminator

Data_14b75_RubyField: ; 0x14b75
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $26
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $720
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14b7f_RubyField: ; 0x14b7f
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $29
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $750
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14b89_RubyField: ; 0x14b89
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $2C
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $780
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14b93_RubyField: ; 0x14b93
	dw Func_11d2
	db $10, $01
	dw vTilesBG tile $2F
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $7B0
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14b9d_RubyField: ; 0x14b9d
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $26
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $7C0
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14ba7_RubyField: ; 0x14ba7
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $29
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $7F0
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14bb1_RubyField: ; 0x14bb1
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $2C
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $820
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14bbb_RubyField: ; 0x14bbb
	dw Func_11d2
	db $10, $01
	dw vTilesBG tile $2F
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $850
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14bc5_RubyField: ; 0x14bc5
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $26
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $860
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14bcf_RubyField: ; 0x14bcf
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $29
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $890
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14bd9_RubyField: ; 0x14bd9
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $2C
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $8C0
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14be3_RubyField: ; 0x14be3
	dw Func_11d2
	db $10, $01
	dw vTilesBG tile $2F
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $8F0
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14bed_RubyField: ; 0x14bed
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $30
	dw StageRubyFieldBottomBaseGameBoyGfx + $B00
	db Bank(StageRubyFieldBottomBaseGameBoyGfx)
	db $00 ; terminator

Data_14bf7_RubyField: ; 0x14bf7
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $33
	dw StageRubyFieldBottomBaseGameBoyGfx + $B30
	db Bank(StageRubyFieldBottomBaseGameBoyGfx)
	db $00 ; terminator

Data_14c01_RubyField: ; 0x14c01
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $36
	dw StageRubyFieldBottomBaseGameBoyGfx + $B60
	db Bank(StageRubyFieldBottomBaseGameBoyGfx)
	db $00 ; terminator

Data_14c0b_RubyField: ; 0x14c0b
	dw Func_11d2
	db $10, $01
	dw vTilesBG tile $39
	dw StageRubyFieldBottomBaseGameBoyGfx + $B90
	db Bank(StageRubyFieldBottomBaseGameBoyGfx)
	db $00 ; terminator

Data_14c15_RubyField: ; 0x14c15
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $30
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $900
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14c1f_RubyField: ; 0x14c1f
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $33
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $930
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14c29_RubyField: ; 0x14c29
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $36
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $960
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14c33_RubyField: ; 0x14c33
	dw Func_11d2
	db $10, $01
	dw vTilesBG tile $39
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $990
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14c3d_RubyField: ; 0x14c3d
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $30
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $9A0
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14c47_RubyField: ; 0x14c47
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $33
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $9D0
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14c51_RubyField: ; 0x14c51
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $36
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $A00
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14c5b_RubyField: ; 0x14c5b
	dw Func_11d2
	db $10, $01
	dw vTilesBG tile $39
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $A30
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14c65_RubyField: ; 0x14c65
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $30
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $A40
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14c6f_RubyField: ; 0x14c6f
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $33
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $A70
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14c79_RubyField: ; 0x14c79
	dw Func_11d2
	db $30, $03
	dw vTilesBG tile $36
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $AA0
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

Data_14c83_RubyField: ; 0x14c83
	dw Func_11d2
	db $10, $01
	dw vTilesBG tile $39
	dw StageRedFieldBottomIndicatorsGfx_Gameboy + $AD0
	db Bank(StageRedFieldBottomIndicatorsGfx_Gameboy)
	db $00 ; terminator

TileDataPointers_Gulpin_GameBoyColor_RubyField:
	dw TileDataPointer_Gulpin_Left_0_GameBoyColor_RubyField
	dw TileDataPointer_Gulpin_Left_1_GameBoyColor_RubyField
	dw TileDataPointer_Gulpin_Left_2_GameBoyColor_RubyField
	dw TileDataPointer_Gulpin_Left_3_GameBoyColor_RubyField
	dw TileDataPointer_Gulpin_Right_0_GameBoyColor_RubyField
	dw TileDataPointer_Gulpin_Right_1_GameBoyColor_RubyField
	dw TileDataPointer_Gulpin_Right_2_GameBoyColor_RubyField
	dw TileDataPointer_Gulpin_Right_3_GameBoyColor_RubyField
