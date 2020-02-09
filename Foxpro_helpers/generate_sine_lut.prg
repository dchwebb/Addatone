m.sinlut = ""
m.samples = 1500
FOR m.x = 0 TO m.samples - 1
	m.val = (SIN(2 * PI() * m.x / m.samples) * (2^15 - 1)) + 2^15
	m.sinlut = m.sinlut + RIGHT(TRANSFORM(ROUND(m.val, 0), "@0"), 4) + CHR(13) + CHR(10)
ENDFOR

_cliptext = m.sinlut

= STRTOFILE(m.sinlut, "D:\docs\FPGA\Oscillator\sin_lut" + TRANSFORM(m.samples) + ".mem")