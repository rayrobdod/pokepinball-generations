_LoadStageDataGroudonBonus:
	callba LoadBallGraphics
	call LoadFlippersPalette
	callba LoadTimerGraphics
	call UpdateGroudonLimbGraphics

FOR X, 0, 4
	ld hl, GroudonPillarSummonAnimation
	ld de, wGroudonPillar{u:X}Animation
	ld bc, TileDataPointers_GroudonFlamePillar_{u:X}
	call UpdateOneGroudonPillarGraphics
ENDR

	ret
