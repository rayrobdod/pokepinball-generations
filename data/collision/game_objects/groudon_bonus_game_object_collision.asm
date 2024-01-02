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

GroudonBonusStagePillar1CollisionAttributes:
	db $00
	db $30, $31, $32, $33, $34, $35
	db $3c, $3d, $3e, $3f
	db $FF ; terminator

GroudonBonusStagePillar1CollisionData:
	db $12, $12  ; x, y bounding box
	db $01, (8 * 8 + 4), (9 * 8)  ; id, x, y
	db $00, (6 * 8), (6 * 8)  ; id, x, y
	db $03, (14 * 8), (6 * 8)  ; id, x, y
	db $FF ; terminator

; The two front pillars are too close for a bounding box to separate cleanly
GroudonBonusStagePillar2CollisionAttributes:
	db $00
	db $36, $37, $38, $39, $3a, $3b
	db $3c, $3d, $3e, $3f
	db $FF ; terminator

GroudonBonusStagePillar2CollisionData:
	db $12, $12  ; x, y bounding box
	db $02, (11 * 8 + 4), (9 * 8)  ; id, x, y
	db $FF ; terminator
