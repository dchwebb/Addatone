m.f = FOPEN("D:\Eurorack\Addatone\Addatone_ICE40\impl_1\Addatone_ICE40_impl_1.bin")

m.tmpEof = FSEEK(m.f, 0, 2)

m.tmpBinArray = ""

FSEEK(m.f, 0, 0)

m.tmpZeroMarker1 = 255
m.tmpZeroMarker2 = 254

m.FirstMarker = .F.
m.tmpZeroCount = 0

FOR m.byte = 0 TO m.tmpEof - 1
	IF m.byte = m.tmpEof - 1
		SUSPEND
	ENDIF
	
	m.tmpByte = ASC(FREAD(m.f, 1))
	
	*	Check if the marker we are using for compressing streams of zero occurs in the bitstream and abort if so
	IF m.FirstMarker AND m.tmpByte = m.tmpZeroMarker2
		MESSAGEBOX("Zero Marker found in bitstream - compression invalid")
		FCLOSE(m.f)
		RETURN
	ENDIF
	m.FirstMarker = (m.tmpByte = m.tmpZeroMarker1)
	
	IF m.tmpByte = 0 AND m.tmpZeroCount < 255 AND m.byte < m.tmpEof - 4
		m.tmpZeroCount = m.tmpZeroCount + 1
	ELSE
		IF m.tmpZeroCount < 4		&& No point compressing
			m.tmpBinArray = m.tmpBinArray + REPLICATE("0,", m.tmpZeroCount)
		ELSE
			m.tmpBinArray = m.tmpBinArray + HexTran(m.tmpZeroMarker1) + "," + HexTran(m.tmpZeroMarker2) + "," + HexTran(m.tmpZeroCount) + ","
		ENDIF
		m.tmpBinArray = m.tmpBinArray + HexTran(m.tmpByte) + ","
		m.tmpZeroCount = 0
	ENDIF

ENDFOR
FCLOSE(m.f)

m.tmpBinArray = "const uint8_t bitstreamZeroMarker1 = " + HexTran(m.tmpZeroMarker1) + ";" + CHR(13) +;
 "const uint8_t bitstreamZeroMarker2 = " + HexTran(m.tmpZeroMarker2) + ";" + CHR(13) +;
 "const uint32_t bitstreamSize = " + TRANSFORM(OCCURS(",", m.tmpBinArray)) + ";" + CHR(13) +;
 "const uint8_t bitstream[] = {" + LEFT(m.tmpBinArray, LEN(m.tmpBinArray) - 1) + "};"

= STRTOFILE(m.tmpBinArray, "D:\Eurorack\Addatone\Addatone_STM32F446\src\bitstream_c.h")

*****************
PROCEDURE HexTran
LPARAMETERS m.n

RETURN TRANSFORM(n)

*RETURN RIGHT(TRANSFORM(n, "@0"), 2)