HandleBallLossGroudonBonus:
	ld a, [wCurrentStageBackup]
	ld hl, wCurrentStage
	cp [hl]
	ret z

	; if bonus stage was won, return to main stage
	ld a, [wNumGroudonHits]
	cp NUM_GROUDON_HITS
	jr nc, .return_from_bonus_stage
	; if bonus stage was lost, return to main stage
	ld a, [wFlippersDisabled]
	and a
	jr nz, .return_from_bonus_stage

.continue_bonus_stage
	; The base bonus stages temporarily take away your field multiplier for the duration of the bonus stage
	; This stage instead, like the stages in RS, allows keeping the field multiplier during the stage, but will degrade the ball on any unforced ball loss
	ld a, [wBallType]
	ld c, a
	ld b, $0
	ld hl, BallTypeDegradationRubyField
	add hl, bc
	ld a, Bank(BallTypeDegradationRubyField)
	call ReadByteFromBank
	ld [wBallType], a
	ld [wBallTypeBackup], a
	callba TransitionPinballUpgrade

	xor a
	ld [wPinballIsVisible], a
	ld [wEnableBallGravityAndTilt], a
	ld [wBallSpin], a
	ld [wBallRotation], a
	ld hl, wBallXVelocity
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hli], a

	lb de, $00, $0b
	call PlaySoundEffect
	ret

.return_from_bonus_stage
	xor a
	ld [wTimeRanOut], a
	ld [wTimerActive], a
	ld [wGoingToBonusStage], a
	ld a, $1
	ld [wReturningFromBonusStage], a
	ld a, $2
	ld [wd4c8], a
	xor a
	ld [wDisableHorizontalScrollForBallStart], a
	ld a, [wCompletedBonusStage]
	and a
	ret nz
	call FillBottomMessageBufferWithBlackTile
	call EnableBottomText
	ld hl, wScrollingText3
	ld de, EndGroudonStageText
	call LoadScrollingText
	ret
