m.sinLutPos = ""
m.sinLutNeg = ""
m.sindec = ""

*	Hex - using twos complement
m.samples = 1500
FOR m.x = 0 TO (m.samples / 2) - 1
	m.val = ROUND((SIN(2 * PI() * m.x / m.samples) * (2^15 - 1)), 0)
	
	m.sinLutPos = m.sinLutPos + RIGHT(TRANSFORM(m.val, "@0"), 4) + CHR(13) + CHR(10)
	m.sinLutNeg = m.sinLutNeg + RIGHT(TRANSFORM(BITNOT(m.val) + 1, "@0"), 4) + CHR(13) + CHR(10)

ENDFOR

*	Decimal for checking
FOR m.x = 0 TO m.samples - 1
	m.val = ROUND((SIN(2 * PI() * m.x / m.samples) * (2^15 - 1)), 0)
	
	m.sindec = m.sindec + TRANSFORM(m.val) + CHR(13) + CHR(10)
ENDFOR

m.sinlut = m.sinLutPos + m.sinLutNeg

_cliptext = m.sindec

= STRTOFILE(m.sinlut, "D:\docs\FPGA\Oscillator\sin_lut_2c_" + TRANSFORM(m.samples) + ".mem")