InitBallForStage: ; 0x83ba
	ld a, [wLoadingSavedGame]
	and a
	jr z, .initBall
	call TryLoadWildMonCollisionMask
	call RestartStageMusic
	ret

.initBall
	xor a
	ld [wBallXVelocity], a
	ld [wBallXVelocity + 1], a
	ld [wBallYVelocity], a
	ld [wBallYVelocity + 1], a
	ld [wLeftFlipperState], a
	ld [wLeftFlipperState + 1], a
	ld [wRightFlipperState], a
	ld [wRightFlipperState + 1], a
	ld [wLeftFlipperStateChange], a
	ld [wLeftFlipperStateChange + 1], a
	ld [wRightFlipperStateChange], a
	ld [wRightFlipperStateChange + 1], a
	ld [wBallSpin], a
	ld [wBallRotation], a
	inc a
	ld [wPinballIsVisible], a
	ld [wEnableBallGravityAndTilt], a
	ld a, $20
	ld [wSCX], a
	ld a, [wCurrentStage]
	call CallInFollowingTable
InitBall_CallTable: ; 0x8404
	padded_dab InitBallRedField          ; STAGE_RED_FIELD_TOP
	padded_dab InitBallRedField          ; STAGE_RED_FIELD_BOTTOM
	padded_dab InitBallBlueField         ; STAGE_BLUE_FIELD_TOP
	padded_dab InitBallBlueField         ; STAGE_BLUE_FIELD_BOTTOM
	padded_dab InitBallGoldField         ; STAGE_GOLD_FIELD_TOP
	padded_dab InitBallGoldField         ; STAGE_GOLD_FIELD_BOTTOM
	padded_dab InitBallSilverField       ; STAGE_SILVER_FIELD_TOP
	padded_dab InitBallSilverField       ; STAGE_SILVER_FIELD_BOTTOM
	padded_dab InitBallRubyField         ; STAGE_RUBY_FIELD_TOP
	padded_dab InitBallRubyField         ; STAGE_RUBY_FIELD_BOTTOM
	padded_dab InitBallSapphireField     ; STAGE_SAPPHIRE_FIELD_TOP
	padded_dab InitBallSapphireField     ; STAGE_SAPPHIRE_FIELD_BOTTOM
	padded_dab InitBallGengarBonusStage  ; STAGE_GENGAR_BONUS
	padded_dab InitBallGengarBonusStage  ; STAGE_GENGAR_BONUS
	padded_dab InitBallMewtwoBonusStage  ; STAGE_MEWTWO_BONUS
	padded_dab InitBallMewtwoBonusStage  ; STAGE_MEWTWO_BONUS
	padded_dab InitBallMeowthBonusStage  ; STAGE_MEOWTH_BONUS
	padded_dab InitBallMeowthBonusStage  ; STAGE_MEOWTH_BONUS
	padded_dab InitBallDiglettBonusStage ; STAGE_DIGLETT_BONUS
	padded_dab InitBallDiglettBonusStage ; STAGE_DIGLETT_BONUS
	padded_dab InitBallSeelBonusStage    ; STAGE_SEEL_BONUS
	padded_dab InitBallSeelBonusStage    ; STAGE_SEEL_BONUS
	padded_dab InitBallGroudonBonusStage ; STAGE_GROUDON_BONUS
	padded_dab InitBallGroudonBonusStage ; STAGE_GROUDON_BONUS

TryLoadWildMonCollisionMask: ; 0x8444
	ld a, [wInSpecialMode]
	and a
	jr z, .done
	ld a, [wSpecialMode]
	and a
	jr nz, .done
	ld a, [wWildMonIsHittable]
	and a
	jr z, .done
	callba LoadWildMonCollisionMask
.done
	ret

RestartStageMusic: ; 0x8461
	ld a, [wStageSongBank]
	call SetSongBank
	ld a, [wStageSong]
	ld e, a
	ld d, $0
	call PlaySong
	ret
