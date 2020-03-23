m.sinlut = ""
m.sinlut_dec = ""
m.samples = 2048
FOR m.x = 0 TO m.samples - 1
	m.val = (SIN(2 * PI() * m.x / m.samples) * (2^15 - 1)) &&+ 2^15
	m.sinlut = m.sinlut + RIGHT(TRANSFORM(ROUND(m.val, 0), "@0"), 4) + CHR(13) + CHR(10)
	m.sinlut_dec = m.sinlut_dec + TRANSFORM(ROUND(m.val, 0)) + CHR(13) + CHR(10)
ENDFOR

_cliptext = m.sinlut_dec

*= STRTOFILE(m.sinlut, "D:\Eurorack\Addatone\Addatone_MachX03\sine_lut\sin_lut" + TRANSFORM(m.samples) + ".mem")