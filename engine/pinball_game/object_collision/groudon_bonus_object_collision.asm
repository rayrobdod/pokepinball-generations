CheckGroudonBonusStageGameObjectCollisions:
	call CheckGroudonBonusStageFireballCollision
	call CheckGroudonBonusStageGroudonCollision
	call CheckGroudonBonusStageBoulderCollision
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

CheckGroudonBonusStageBoulderCollision:
FOR X, 0, 3
	ld a, [wGroudonBoulder{d:X}Health]
	and a
	jr z, .skipBoulder{d:X}
	ld a, [wGroudonBoulder{d:X}XPos]
	sub $8
	ld b, a
	ld a, [wGroudonBoulder{d:X}YPos]
	add $8
	ld c, a
	call CheckOneGroudonBonusStageBoulderCollision
	ld a, {d:X}
	jr c, .handleCollision
.skipBoulder{d:X}
ENDR

	ret

.handleCollision
	ld [wGroudonBoulderCollision], a
	ret

CheckOneGroudonBonusStageBoulderCollision:
; Input: b = xPos, c = yPos of boulder
; Output: carry if there was a collision
	ld a, [wBallXPos + 1]
	sub b
	cp $10
	jr nc, .noCollision
	ld b, a
	ld a, [wBallYPos + 1]
	sub c
	cp $10
	jr nc, .noCollision
	ld c, a

	ld e, c
	ld d, $0
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	sla e
	rl d
	ld h, d
	ld l, e
	ld e, b
	ld d, $0
	add hl, de
	ld de, GroudonBoulderCollisionAngles
	add hl, de
	ld a, BANK(GroudonBoulderCollisionAngles)
	; hl = GroudonBoulderCollisionAngles + b + c * $10
	call ReadByteFromBank
	bit 7, a
	jr nz, .noCollision
	sla a
	ld [wCollisionNormalAngle], a
	ld a, $1
	ld [wIsBallColliding], a
	scf
	ret

.noCollision
	and a
	ret

CheckGroudonBonusStageGroudonCollision:
	ld de, GroudonBonusStageGroudonCollisionData
	ld hl, GroudonBonusStageGroudonCollisionAttributes
	ld bc, wGroudonGroudonCollision
	and a
	jp HandleGameObjectCollision

INCLUDE "data/collision/game_objects/groudon_bonus_game_object_collision.asm"
