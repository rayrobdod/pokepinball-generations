; Plan:
;   use the second VRAM bank for groudon,
;   and the first VRAM bank for everything else

; The two idle frames already done can fit in 15 tiles after dedup,
; if each frame is 16 tiles or less, then 8 frames can fit in memory at once.

; Lets split the 8 frames into: three idle frames, one hit frame, and four attack frames.

; Assume four attack frames fit in 128 tiles, and about six seconds between attacks;
; that's about 20 tiles a second, or one tile per three frames.
; Queueing one Func_11d2 every three frames should not overload the tile data queue
; So, it should be possible to have four different frames for each attack.

TileDataPointers_GroudonLavaPlumeAttack:
FOR X, 0, 126, 2
	dw TileData_GroudonLavaPlumeAttack_{u:X}
ENDR

FOR X, 0, 126, 2
TileData_GroudonLavaPlumeAttack_{u:X}:
	dw Func_11d2
	db $20, $02
	dw vTilesBG tile X
	dw GroudonBonusGroudonLavaPlumeAttackGfx + (X * 16)
	db Bank(GroudonBonusGroudonLavaPlumeAttackGfx)
	db $00 ; terminator
ENDR
