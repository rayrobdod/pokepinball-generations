RubyStageDiglettCollisionAttributes:
	db $00  ; flat list
	db $64, $65, $68, $69
	db $FF ; terminator

RubyStageDiglettCollisionData:
	db $08, $0C  ; x, y bounding box
	db $01, $20, $40  ; id, x, y
	db $02, $80, $40  ; id, x, y
	db $FF ; terminator

RubyStageVoltorbCollisionDataList:
	dw RubyStageVoltorbCollisionData1
	dw RubyStageVoltorbCollisionData1
	dw RubyStageVoltorbCollisionData2

RubyStageVoltorbCollisionData1:
	db $0E, $0E  ; x, y bounding box
	db $03, $52, $43  ; id, x, y
	db $04, $6B, $4C  ; id, x, y
	db $05, $59, $5F  ; id, x, y
	db $FF ; terminator

RubyStageVoltorbCollisionData2:
	db $0E, $0E  ; x, y bounding box
	db $03, 92, 80  ; id, x, y
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

RubyStageBumperStanceChangeCollisionData:
	db $05, $08  ; x, y bounding box
	db $19, 63, 112  ; id, x, y
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
	db $1F, 54, 71  ; id, x, y
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
	db $01, 61 - 8, 14 + 8	; top of loop
	db $01, 14 - 8, 83 + 8	; left alley
	db $01, 31 - 8, 79 + 8	; inner-left alley
	db $01, 139 - 8, 71 + 8	; right alley
	db $01, 47 - 8, 83 + 8	; in front of evolution cave
	db $01, 114 - 8, 122 + 8	; in front of sharpedo
	db $01, 91 - 8, 41 + 8	; just below center ball multiplier trigger
	db $01, 60 - 8, 95 + 8	; in front of bumper stance switch
	db $01, 91 - 8, 106 + 8	; below bumpers
	db $01, 64 - 8, 122 + 8	; in middle of open area
	db $01, 64 - 8, 63 + 8	; to left of bumpers
	db $01, 116 - 8, 57 + 8	; to right of bumpers
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

INCLUDE "data/collision/maps/ruby_stage_top.collision.object-data"
