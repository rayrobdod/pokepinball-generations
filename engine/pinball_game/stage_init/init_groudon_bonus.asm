InitGroudonBonusStage:
	ld a, [wLoadingSavedGame]
	and a
	ret nz
	xor a
	ld [wStageCollisionState], a
	ld [wNumGroudonHits], a
	ld [wCompletedBonusStage], a
	ld [wd4c8], a
	ld [wGroudonBoulder0Health], a
	ld [wGroudonBoulder0AnimationFrameCounter], a
	ld a, $1
	ld [wDisableHorizontalScrollForBallStart], a
	ld a, $FF
	ld [wGroudonBoulderCollision], a
	ld [wGroudonBoulder0AnimationFrame], a

	; The base bonus stages temporarily take away your field multiplier for the duration of the bonus stage
	; This stage instead, like the stages in RS, allows keeping the field multiplier during the stage, but will degrade the ball on any unforced ball loss
	ld a, [wBallType]
	ld [wBallTypeBackup], a

	ld hl, EventGroudonAnimation
	ld de, wGroudonEventAnimation
	call InitAnimation

	ld bc, GROUDON_DURATION
	callba StartTimer

	ld a, Bank(Music_MewtwoStage)
	call SetSongBank
	ld de, MUSIC_MEWTWO_STAGE
	call PlaySong
	ret
