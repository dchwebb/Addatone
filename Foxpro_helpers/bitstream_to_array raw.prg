*m.f = FOPEN("D:\Eurorack\Addatone\Addatone_ICE40\impl_1\Addatone_ICE40_impl_1.bin")
m.f = FOPEN("D:\Eurorack\Addatone\Addatone_ICE40\impl_addatone\Addatone_ICE40_impl_Addatone.bin")
m.tmpEof = FSEEK(m.f, 0, 2)

m.tmpBinArray = "const int bitstreamSize = " + TRANSFORM(m.tmpEof) + ";" + CHR(13) + "const uint8_t bitstream[] = {"
FSEEK(m.f, 0, 0)

FOR m.byte = 0 TO m.tmpEof - 1
	m.tmpBinArray = m.tmpBinArray + TRANSFORM(ASC(FREAD(m.f, 1))) + ", "
ENDFOR

FCLOSE(m.f)

m.tmpBinArray = LEFT(m.tmpBinArray, LEN(m.tmpBinArray) - 2) + "};"

= STRTOFILE(m.tmpBinArray, "D:\Eurorack\Addatone\Addatone_STM32F446\src\bitstream.h")