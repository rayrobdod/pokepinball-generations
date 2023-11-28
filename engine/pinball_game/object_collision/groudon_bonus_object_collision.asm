CheckGroudonBonusStageGameObjectCollisions:
	call CheckGroudonBonusStageFireballCollision
	ret

CheckGroudonBonusStageFireballCollision:
	; It is a hit if `ball` is within `collision_size` pixels of `fireball`.
	; Short circuit if either dimension is greater than `collision_size`,
	; since distance cannot be smaller than either projection

	; e = abs(ball.y - fireball.y)
	ld a, [wBallYPos + 1]
	ld b, a
	ld a, [wGroudonFireballYPos]
	sub b
	jp nc, .skipNegateYDelta
	cpl
	add 1
.skipNegateYDelta:
	cp GROUDON_FIREBALL_COLLISION_SIZE
	ret nc
	ld e, a

	; a = abs(ball.x - fireball.x)
	ld a, [wBallXPos + 1]
	ld b, a
	ld a, [wGroudonFireballXPos + 1]
	sub b
	jp nc, .skipNegateXDelta
	cpl
	add 1
.skipNegateXDelta:
	cp GROUDON_FIREBALL_COLLISION_SIZE
	ret nc

	; bc = (ball.x - fireball.x) ** 2
	; de = (ball.y - fireball.y) ** 2
	assert 0 == SquaresLow % $100, "Execting SqauresLow to be aligned 8"
	assert SquaresLow + $100 == SquaresHigh
	ld h, SquaresLow / $100
	ld l, a
	ld c, [hl]
	inc h
	ld b, [hl]
	ld l, e
	ld d, [hl]
	dec h
	ld e, [hl]

	ld hl, -GROUDON_FIREBALL_COLLISION_SIZE ** 2
	add hl, bc
	add hl, de
	ret nc

	xor a
	ld [wGroudonFireballBreakoutCooldown], a
	ld [wEnableBallGravityAndTilt], a
	ld [wBallXVelocity], a
	ld [wBallXVelocity + 1], a
	ld [wBallYVelocity], a
	ld [wBallYVelocity + 1], a
	ld [wBallSpin], a
	ld a, $E0
	ld [wGroudonFireballYPos], a
	ld a, GROUDON_FIREBALL_BREAKOUT_COUNTER
	ld [wGroudonFireballBreakoutCounter], a

	ret
