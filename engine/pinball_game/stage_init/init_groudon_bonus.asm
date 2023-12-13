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
	ld [wGroudonBoulder1Health], a
	ld [wGroudonBoulder2Health], a
	ld [wGroudonBoulder0AnimationFrameCounter], a
	ld [wGroudonBoulder1AnimationFrameCounter], a
	ld [wGroudonBoulder2AnimationFrameCounter], a
	assert 0 == GROUDONBOULDERFRAME_HIDDEN
	ld [wGroudonBoulder0AnimationFrame], a
	ld [wGroudonBoulder1AnimationFrame], a
	ld [wGroudonBoulder2AnimationFrame], a
	assert 0 == GROUDONANIMATION_IDLE
	ld [wGroudonAnimationId], a

	ld a, $1
	ld [wDisableHorizontalScrollForBallStart], a
	ld a, $FF
	ld [wGroudonBoulderCollision], a

	; The base bonus stages temporarily take away your field multiplier for the duration of the bonus stage
	; This stage instead, like the stages in RS, allows keeping the field multiplier during the stage, but will degrade the ball on any unforced ball loss
	ld a, [wBallType]
	ld [wBallTypeBackup], a

	ld hl, EventGroudonAnimation
	ld de, wGroudonEventAnimation
	call InitAnimation

	ld hl, IdleGroudonAnimation
	ld de, wGroudonAnimation
	call InitAnimation

	ld bc, GROUDON_DURATION
	callba StartTimer

	ld a, Bank(Music_MewtwoStage)
	call SetSongBank
	ld de, MUSIC_MEWTWO_STAGE
	call PlaySong
	ret
