GroudonBonusStageGroudonCollisionAttributes:
	db $00 ; flat list
	db $20, $21, $22, $23
	db $24, $25, $26, $27
	db $28, $29, $2A, $2B
	db $2C, $2D, $2E, $2F
	db $FF ; terminator

GroudonBonusStageGroudonCollisionData:
	db $40, $40  ; x, y bounding box
	db $01, $30, $08  ; id, x, y
	db $FF ; terminator
