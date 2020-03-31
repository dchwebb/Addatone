m.f = FOPEN("D:\Eurorack\Addatone\Addatone_ICE40\impl_1\Addatone_ICE40_impl_1.bin")

m.tmpEof = FSEEK(m.f, 0, 2)

m.tmpBinArray = "const int bitstreamSize = " + TRANSFORM(m.tmpEof) + ";" + CHR(13) + "const uint8_t bitstream[] = {"

FSEEK(m.f, 0, 0)

m.tmpZeroMarker1 = 255
m.tmpZeroMarker2 = 254

m.FirstMarker = .F.
m.tmpZeroCount = 0

FOR m.byte = 0 TO m.tmpEof - 1
	m.tmpByte = ASC(FREAD(m.f, 1))
	
	*	Check if the marker we are using for compressing streams of zero occurs in the bitstream and abort if so
	IF m.FirstMarker AND m.tmpByte = m.tmpZeroMarker2
		MESSAGEBOX("Zero Marker found in bitstream - compression invalid")
		FCLOSE(m.f)
		RETURN
	ENDIF
	m.FirstMarker = (m.tmpByte = m.tmpZeroMarker1)
	
	IF m.tmpByte = 0 AND m.tmpZeroCount < 255
		m.tmpZeroCount = m.tmpZeroCount + 1
	ELSE
		DO CASE
		CASE m.tmpZeroCount < 4		&& No point compressing
			m.tmpBinArray = m.tmpBinArray + REPLICATE("0,", m.tmpZeroCount)
		OTHERWISE
			m.tmpBinArray = m.tmpBinArray + HexTran(m.tmpZeroMarker1) + "," + HexTran(m.tmpZeroMarker2) + "," + HexTran(m.tmpZeroCount) + ","
		ENDCASE
		m.tmpBinArray = m.tmpBinArray + HexTran(m.tmpByte) + ","
		m.tmpZeroCount = 0
	ENDIF

ENDFOR
FCLOSE(m.f)

m.tmpBinArray = LEFT(m.tmpBinArray, LEN(m.tmpBinArray) - 2) + "};"

= STRTOFILE(m.tmpBinArray, "D:\Eurorack\Addatone\Addatone_STM32F446\src\bitstream_c.h")

PROCEDURE HexTran
LPARAMETERS m.n

RETURN RIGHT(TRANSFORM(n, "@0"), 2)