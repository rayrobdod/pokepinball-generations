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
	; the fireball being this far below the visible area will disable the fireball,
	; and all other fireball variables are set when the fireball is 'created',
	; so those variables don't have to be set here
	ld a, $E0
	ld [wGroudonFireballYPos], a
	xor a
	ld [wSCX], a
	ld [wStageCollisionState], a
	ld [wGroudonBonusClosedGate], a
	ld [wGroudonFireballBreakoutCounter], a
	ld [wLostBall], a

	ret
