* Increase Offset to increase pitch; Reduce Spread to decrease spread
m.Offset = 2100			&& 2299
m.Spread = -680			&& -583

? ""
? "Spread: " + TRANSFORM(m.Spread) + "  Offset: " + TRANSFORM(m.Offset)

? calcPitch(2900)		&& 110
? calcPitch(2200)		&& 220
? calcPitch(1500)		&& 440


PROCEDURE calcPitch
LPARAMETERS pitch





RETURN m.Offset * (2.0 ^ (Pitch / m.Spread))
