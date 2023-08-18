RubyStageDiglettCollisionAttributes:
	db $00  ; flat list
	db $64, $65, $68, $69
	db $FF ; terminator

RubyStageDiglettCollisionData:
	db $08, $0C  ; x, y bounding box
	db $01, $20, $40  ; id, x, y
	db $02, $80, $40  ; id, x, y
	db $FF ; terminator

RubyStageVoltorbCollisionAttributes:
	db $00  ; flat list
	db $11, $27, $32, $33, $3E, $3F
	db $34, $35, $40, $41, $4A, $4B, $31
	db $55, $56, $5E, $5F
	db $FF ; terminator

RubyStageVoltorbCollisionData:
	db $0E, $0E  ; x, y bounding box
	db $03, $52, $43  ; id, x, y
	db $04, $6B, $4C  ; id, x, y
	db $05, $59, $5F  ; id, x, y
	db $FF ; terminator

RubyStageBumpersCollisionAttributes:
	db $00  ; flat list
	db $32, $3F, $37, $3C, $34, $31, $3E, $36, $3B, $3D
	db $FF ; terminator

RubyStageBumpersCollisionData:
	db $06, $0B  ; x, y bounding box
	db $06, $30, $66  ; id, x, y
	db $07, $6F, $66  ; id, x, y
	db $FF ; terminator

RubyStageLaunchAlleyCollisionData:
	db $08, $08  ; x, y bounding box
	db $08, $A8, $98  ; id, x, y
	db $FF ; terminator

RubyStageSpinnerCollisionData:
	db $08, $04  ; x, y, bounding box
	db $09, $90, $6C  ; id, x, y
	db $FF ; terminator

RubyStageCAVELightsCollisionData:
	db $05, $03  ; x, y bounding box
	db $0A, $0E, $65  ; id, x, y
	db $0B, $1E, $65  ; id, x, y
	db $0C, $82, $65  ; id, x, y
	db $0D, $92, $65  ; id, x, y
	db $FF ; terminator

RubyStagePinballUpgradeTriggerCollisionData:
	db $06, $05  ; x, y bounding box
	db $0E, $4E, $2F  ; id, x, y
	db $0F, $60, $32  ; id, x, y
	db $10, $72, $3B  ; id, x, y
	db $FF ; terminator

RubyStageBoardTriggersCollisionData:
	db $09, $09  ; x, y bounding box
	; id, x, y
	db OBJ_ALLEYTRIGGER_LEFT_PRIMARY_RUBYFIELD,	18, 106 + 16
	db OBJ_ALLEYTRIGGER_LEFT_SECONDARY_RUBYFIELD,	25, 45 + 16
	db OBJ_ALLEYTRIGGER_RIGHT_PRIMARY_RUBYFIELD,	142, 106 + 16
	db OBJ_ALLEYTRIGGER_RIGHT_SECONDARY_RUBYFIELD,	133, 48 + 16
	db OBJ_ALLEYTRIGGER_INNERLEFT_PRIMARY_RUBYFIELD,	36, 92 + 16
	db OBJ_ALLEYTRIGGER_INNERLEFT_SECONDARY_RUBYFIELD,	38, 52 + 16
	db $FF ; terminator

RubyStageBellsproutCollisionData:
	db $06, $05  ; x, y bounding box
	db $1B, $7B, $76  ; id, x, y
	db $FF ; terminator

RubyStagePikachuCollisionData:
	db $03, $05  ; x, y bounding box
	db $1C, $0E, $7C  ; id, x, y
	db $1D, $92, $7C  ; id, x, y
	db $FF ; terminator

RubyStageWildPokemonCollisionAttributes:
	db $00  ; flat list
	db $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7, $D8, $D9, $DA, $DB, $DC, $DD, $DE, $DF
	db $FF ; terminator

RubyStageWildPokemonCollisionData:
	db $1A, $1A  ; x, y bounding box
	db $1E, $50, $40  ; id, x, y
	db $FF ; terminator

RubyStageDittoSlotCollisionData:
	db $03, $03  ; x, y bounding box
	db $1F, $12, $24  ; id, x, y
	db $FF ; terminator

RubyStageSlotCollisionData:
	db $04, $04  ; x, y bounding box
	db $20, $50, $16  ; id, x, y
	db $FF ; terminator

RubyStageBonusMultipliersCollisionAttributes:
	db $00  ; flat list
	db $4C, $4B, $48, $47, $4D, $4A
	db $FF ; terminator

RubyStageBonusMultipliersCollisionData:
	db $07, $07  ; x, y bounding box
	db $21, $2C, $20  ; id, x, y
	db $22, $74, $20  ; id, x, y
	db $FF ; terminator

RubyStageEvolutionTrinketCoordinatePointers: ; 0x145d2
	dw RubyStageTopEvolutionTrinketCoords
	dw RubyStageBottomEvolutionTrinketCoords

RubyStageTopEvolutionTrinketCoords: ; 0x156d6
; First byte is just non-zero to signify that the array hasn't ended.
; Second byte is x coordinate.
; Third byte is y coordinate.
	db $01, $44, $14
	db $01, $2A, $1A
	db $01, $5E, $1A
	db $01, $11, $2D
	db $01, $77, $2D
	db $01, $16, $3E
	db $01, $77, $3E
	db $01, $06, $6D
	db $01, $83, $6D
	db $01, $41, $82
	db $01, $51, $82
	db $01, $69, $82
	db $00  ; terminator

RubyStageBottomEvolutionTrinketCoords: ; 0x145fb
; First byte is just non-zero to signify that the array hasn't ended.
; Second byte is x coordinate.
; Third byte is y coordinate.
	db $01, $35, $1B
	db $01, $53, $1B
	db $01, $29, $1F
	db $01, $5F, $1F
	db $01, $26, $34
	db $01, $62, $34
	db $00  ; terminator
