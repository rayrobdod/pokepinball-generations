InitBallGroudonBonusStage:
	ld a, $0
	ld [wBallXPos], a
	ld a, $a6
	ld [wBallXPos + 1], a
	ld a, $0
	ld [wBallYPos], a
	ld a, $56
	ld [wBallYPos + 1], a
	ld a, $80
	ld [wBallXVelocity], a
	ld a, GROUDONANIMATION_IDLE
	ld [wGroudonAnimationId], a
	xor a
	ld [wSCX], a
	ld [wStageCollisionState], a
	ld [wGroudonBonusClosedGate], a
	ld [wLostBall], a

	ld de, wGroudonAnimation
	ld hl, IdleGroudonAnimation
	call InitAnimation
	ret
