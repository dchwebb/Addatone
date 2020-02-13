EESchema Schematic File Version 4
LIBS:STM32L152_Dev_Board-cache
EELAYER 30 0
EELAYER END
$Descr User 13780 9843
encoding utf-8
Sheet 1 1
Title "DisPhaze"
Date ""
Rev ""
Comp "Mountjoy Modular"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Connector:Conn_01x04_Male J1
U 1 1 5C1668B3
P 3950 1250
F 0 "J1" H 4150 800 50  0000 C CNN
F 1 "SWD_Header" H 4200 900 50  0000 C CNN
F 2 "Custom_Footprints:SWD_header" H 3950 1250 50  0001 C CNN
F 3 "~" H 3950 1250 50  0001 C CNN
	1    3950 1250
	1    0    0    -1  
$EndComp
$Comp
L power:+3.3V #PWR021
U 1 1 5C16690B
P 4150 1150
F 0 "#PWR021" H 4150 1000 50  0001 C CNN
F 1 "+3.3V" V 4165 1278 50  0000 L CNN
F 2 "" H 4150 1150 50  0001 C CNN
F 3 "" H 4150 1150 50  0001 C CNN
	1    4150 1150
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR022
U 1 1 5C166929
P 4150 1250
F 0 "#PWR022" H 4150 1000 50  0001 C CNN
F 1 "GND" V 4155 1122 50  0000 R CNN
F 2 "" H 4150 1250 50  0001 C CNN
F 3 "" H 4150 1250 50  0001 C CNN
	1    4150 1250
	0    -1   -1   0   
$EndComp
Text GLabel 4150 1450 2    50   Input ~ 0
SWCLK
Text GLabel 4150 1350 2    50   Input ~ 0
SWDIO
$Comp
L Device:Crystal Y1
U 1 1 5C166A7F
P 1600 2800
F 0 "Y1" V 1650 3050 50  0000 R CNN
F 1 "Crystal" V 1550 3150 50  0000 R CNN
F 2 "Custom_Footprints:Crystal_SMD" H 1600 2800 50  0001 C CNN
F 3 "~" H 1600 2800 50  0001 C CNN
	1    1600 2800
	0    -1   -1   0   
$EndComp
Wire Wire Line
	1850 2650 1600 2650
Wire Wire Line
	1850 2950 1600 2950
Wire Wire Line
	1600 2650 1200 2650
Connection ~ 1600 2650
$Comp
L Device:C C2
U 1 1 5C166F76
P 1050 2650
F 0 "C2" V 1000 2450 50  0000 L CNN
F 1 "18pF" V 1100 2400 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 1088 2500 50  0001 C CNN
F 3 "~" H 1050 2650 50  0001 C CNN
	1    1050 2650
	0    1    1    0   
$EndComp
$Comp
L Device:C C3
U 1 1 5C166FCD
P 1050 2950
F 0 "C3" V 1000 2750 50  0000 L CNN
F 1 "18pF" V 1100 2700 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 1088 2800 50  0001 C CNN
F 3 "~" H 1050 2950 50  0001 C CNN
	1    1050 2950
	0    1    1    0   
$EndComp
Wire Wire Line
	1200 2950 1600 2950
Connection ~ 1600 2950
Wire Wire Line
	900  2650 700  2650
Wire Wire Line
	700  2950 900  2950
$Comp
L power:GND #PWR01
U 1 1 5C167267
P 700 3100
F 0 "#PWR01" H 700 2850 50  0001 C CNN
F 1 "GND" V 705 2972 50  0000 R CNN
F 2 "" H 700 3100 50  0001 C CNN
F 3 "" H 700 3100 50  0001 C CNN
	1    700  3100
	1    0    0    -1  
$EndComp
$Comp
L power:+3.3V #PWR014
U 1 1 5C1676A3
P 2100 1650
F 0 "#PWR014" H 2100 1500 50  0001 C CNN
F 1 "+3.3V" H 2100 1800 50  0000 C CNN
F 2 "" H 2100 1650 50  0001 C CNN
F 3 "" H 2100 1650 50  0001 C CNN
	1    2100 1650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR015
U 1 1 5C1680D4
P 2550 5350
F 0 "#PWR015" H 2550 5100 50  0001 C CNN
F 1 "GND" H 2555 5177 50  0000 C CNN
F 2 "" H 2550 5350 50  0001 C CNN
F 3 "" H 2550 5350 50  0001 C CNN
	1    2550 5350
	1    0    0    -1  
$EndComp
Wire Wire Line
	2550 5250 2550 5350
$Comp
L Device:C C1
U 1 1 5C168D8F
P 3200 1900
F 0 "C1" H 3315 1946 50  0000 L CNN
F 1 "100nF" H 3315 1855 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 3238 1750 50  0001 C CNN
F 3 "~" H 3200 1900 50  0001 C CNN
	1    3200 1900
	-1   0    0    -1  
$EndComp
$Comp
L power:GND #PWR08
U 1 1 5C16955A
P 1650 2150
F 0 "#PWR08" H 1650 1900 50  0001 C CNN
F 1 "GND" H 1655 1977 50  0000 C CNN
F 2 "" H 1650 2150 50  0001 C CNN
F 3 "" H 1650 2150 50  0001 C CNN
	1    1650 2150
	1    0    0    -1  
$EndComp
$Comp
L Device:C C4
U 1 1 5C16995E
P 1150 1900
F 0 "C4" H 1265 1946 50  0000 L CNN
F 1 "100nF" H 1265 1855 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 1188 1750 50  0001 C CNN
F 3 "~" H 1150 1900 50  0001 C CNN
	1    1150 1900
	1    0    0    -1  
$EndComp
$Comp
L Device:C C9
U 1 1 5C169990
P 1650 1900
F 0 "C9" H 1765 1946 50  0000 L CNN
F 1 "100nF" H 1765 1855 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 1688 1750 50  0001 C CNN
F 3 "~" H 1650 1900 50  0001 C CNN
	1    1650 1900
	1    0    0    -1  
$EndComp
$Comp
L Device:C C10
U 1 1 5C1699C4
P 2100 1900
F 0 "C10" H 2215 1946 50  0000 L CNN
F 1 "100nF" H 2215 1855 50  0000 L CNN
F 2 "Capacitors_SMD:C_0805_HandSoldering" H 2138 1750 50  0001 C CNN
F 3 "~" H 2100 1900 50  0001 C CNN
	1    2100 1900
	1    0    0    -1  
$EndComp
Text Notes 1500 1350 0    50   ~ 0
Pins 9, 24, 36, 48 ground capacitors
$Comp
L power:+3.3V #PWR056
U 1 1 5C368261
P 8050 3550
F 0 "#PWR056" H 8050 3400 50  0001 C CNN
F 1 "+3.3V" H 8050 3700 50  0000 C CNN
F 2 "" H 8050 3550 50  0001 C CNN
F 3 "" H 8050 3550 50  0001 C CNN
	1    8050 3550
	1    0    0    -1  
$EndComp
$Comp
L power:PWR_FLAG #FLG01
U 1 1 5C368914
P 9200 1700
F 0 "#FLG01" H 9200 1775 50  0001 C CNN
F 1 "PWR_FLAG" H 9200 1874 50  0000 C CNN
F 2 "" H 9200 1700 50  0001 C CNN
F 3 "~" H 9200 1700 50  0001 C CNN
	1    9200 1700
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR043
U 1 1 5C368939
P 9200 1750
F 0 "#PWR043" H 9200 1500 50  0001 C CNN
F 1 "GND" H 9205 1577 50  0000 C CNN
F 2 "" H 9200 1750 50  0001 C CNN
F 3 "" H 9200 1750 50  0001 C CNN
	1    9200 1750
	1    0    0    -1  
$EndComp
Wire Wire Line
	9200 1700 9200 1750
$Comp
L Regulator_Linear:LM1117-3.3 U4
U 1 1 5C61B890
P 7600 3650
F 0 "U4" H 7600 3892 50  0000 C CNN
F 1 "LM1117-3.3" H 7600 3801 50  0000 C CNN
F 2 "TO_SOT_Packages_SMD:TO-252-3_TabPin2" H 7600 3650 50  0001 C CNN
F 3 "http://www.ti.com/lit/ds/symlink/lm1117.pdf" H 7600 3650 50  0001 C CNN
	1    7600 3650
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR051
U 1 1 5C61BA03
P 7600 3950
F 0 "#PWR051" H 7600 3700 50  0001 C CNN
F 1 "GND" H 7605 3777 50  0000 C CNN
F 2 "" H 7600 3950 50  0001 C CNN
F 3 "" H 7600 3950 50  0001 C CNN
	1    7600 3950
	1    0    0    -1  
$EndComp
$Comp
L Device:C C25
U 1 1 5C7EBE36
P 8050 3850
F 0 "C25" H 8200 3850 50  0000 C CNN
F 1 "10uF" H 8250 3750 50  0000 C CNN
F 2 "Capacitors_SMD:CP_Elec_3x5.3" H 8088 3700 50  0001 C CNN
F 3 "~" H 8050 3850 50  0001 C CNN
	1    8050 3850
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR057
U 1 1 5C7F54E8
P 8050 4000
F 0 "#PWR057" H 8050 3750 50  0001 C CNN
F 1 "GND" H 8055 3827 50  0000 C CNN
F 2 "" H 8050 4000 50  0001 C CNN
F 3 "" H 8050 4000 50  0001 C CNN
	1    8050 4000
	1    0    0    -1  
$EndComp
Wire Wire Line
	7900 3650 8050 3650
Wire Wire Line
	8050 3650 8050 3700
Wire Wire Line
	8050 3550 8050 3650
Connection ~ 8050 3650
$Comp
L Device:L L1
U 1 1 5C7FED08
P 8350 3650
F 0 "L1" V 8172 3650 50  0000 C CNN
F 1 "L" V 8263 3650 50  0000 C CNN
F 2 "Resistors_SMD:R_0805_HandSoldering" H 8350 3650 50  0001 C CNN
F 3 "~" H 8350 3650 50  0001 C CNN
	1    8350 3650
	0    1    1    0   
$EndComp
Wire Wire Line
	8050 3650 8200 3650
$Comp
L power:+3.3VA #PWR060
U 1 1 5C8021B0
P 8550 3550
F 0 "#PWR060" H 8550 3400 50  0001 C CNN
F 1 "+3.3VA" H 8450 3700 50  0000 L CNN
F 2 "" H 8550 3550 50  0001 C CNN
F 3 "" H 8550 3550 50  0001 C CNN
	1    8550 3550
	1    0    0    -1  
$EndComp
$Comp
L Device:C C21
U 1 1 5C802280
P 7200 3850
F 0 "C21" H 7050 3850 50  0000 C CNN
F 1 "10uF" H 7050 3750 50  0000 C CNN
F 2 "Capacitors_SMD:CP_Elec_3x5.3" H 7238 3700 50  0001 C CNN
F 3 "~" H 7200 3850 50  0001 C CNN
	1    7200 3850
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR046
U 1 1 5C802306
P 7200 4000
F 0 "#PWR046" H 7200 3750 50  0001 C CNN
F 1 "GND" H 7205 3827 50  0000 C CNN
F 2 "" H 7200 4000 50  0001 C CNN
F 3 "" H 7200 4000 50  0001 C CNN
	1    7200 4000
	1    0    0    -1  
$EndComp
Wire Wire Line
	7050 3650 7200 3650
Wire Wire Line
	7200 3700 7200 3650
Connection ~ 7200 3650
Wire Wire Line
	7200 3650 7300 3650
$Comp
L power:+3.3VA #PWR016
U 1 1 5C9ADA19
P 2750 1650
F 0 "#PWR016" H 2750 1500 50  0001 C CNN
F 1 "+3.3VA" H 2600 1800 50  0000 L CNN
F 2 "" H 2750 1650 50  0001 C CNN
F 3 "" H 2750 1650 50  0001 C CNN
	1    2750 1650
	1    0    0    -1  
$EndComp
$Comp
L Diode:1N5819 D2
U 1 1 5C90987E
P 8100 2000
F 0 "D2" H 8100 1784 50  0000 C CNN
F 1 "1N5819" H 8100 1875 50  0000 C CNN
F 2 "Diodes_SMD:D_SOD-123" H 8100 1825 50  0001 C CNN
F 3 "http://www.vishay.com/docs/88525/1n5817.pdf" H 8100 2000 50  0001 C CNN
	1    8100 2000
	-1   0    0    1   
$EndComp
$Comp
L Diode:1N5819 D3
U 1 1 5C9099CE
P 8100 2400
F 0 "D3" H 8100 2616 50  0000 C CNN
F 1 "1N5819" H 8100 2525 50  0000 C CNN
F 2 "Diodes_SMD:D_SOD-123" H 8100 2225 50  0001 C CNN
F 3 "http://www.vishay.com/docs/88525/1n5817.pdf" H 8100 2400 50  0001 C CNN
	1    8100 2400
	1    0    0    -1  
$EndComp
$Comp
L Device:CP C22
U 1 1 5C909B35
P 7650 1450
F 0 "C22" V 7395 1450 50  0000 C CNN
F 1 "22uF" V 7486 1450 50  0000 C CNN
F 2 "Capacitors_SMD:CP_Elec_4x5.8" H 7688 1300 50  0001 C CNN
F 3 "~" H 7650 1450 50  0001 C CNN
	1    7650 1450
	0    1    1    0   
$EndComp
$Comp
L Device:CP C23
U 1 1 5C9145AA
P 7650 2800
F 0 "C23" V 7905 2800 50  0000 C CNN
F 1 "22uF" V 7814 2800 50  0000 C CNN
F 2 "Capacitors_SMD:CP_Elec_4x5.8" H 7688 2650 50  0001 C CNN
F 3 "~" H 7650 2800 50  0001 C CNN
	1    7650 2800
	0    -1   -1   0   
$EndComp
Wire Wire Line
	7850 2000 7950 2000
Wire Wire Line
	7850 2400 7950 2400
Wire Wire Line
	8250 2000 8300 2000
Wire Wire Line
	8300 2000 8300 1450
Wire Wire Line
	8300 1450 7800 1450
Wire Wire Line
	7500 1450 6900 1450
Wire Wire Line
	6900 1450 6900 2200
Wire Wire Line
	6900 2200 7350 2200
Wire Wire Line
	8250 2400 8300 2400
Wire Wire Line
	8300 2400 8300 2800
Wire Wire Line
	8300 2800 7800 2800
Wire Wire Line
	7500 2800 6900 2800
Wire Wire Line
	6900 2800 6900 2200
Connection ~ 6900 2200
Wire Wire Line
	7350 2300 7350 2200
Connection ~ 7350 2200
Wire Wire Line
	7350 2100 7350 2200
Wire Wire Line
	7850 2100 7350 2100
Connection ~ 7350 2100
Wire Wire Line
	7850 2200 7350 2200
Wire Wire Line
	7850 2300 7350 2300
Connection ~ 7350 2300
Wire Wire Line
	7350 2400 7850 2400
Connection ~ 7850 2400
Wire Wire Line
	7350 2000 7850 2000
Connection ~ 7850 2000
$Comp
L power:VEE #PWR059
U 1 1 5C9AB2C7
P 8300 2800
F 0 "#PWR059" H 8300 2650 50  0001 C CNN
F 1 "VEE" H 8318 2973 50  0000 C CNN
F 2 "" H 8300 2800 50  0001 C CNN
F 3 "" H 8300 2800 50  0001 C CNN
	1    8300 2800
	-1   0    0    1   
$EndComp
$Comp
L power:VCC #PWR058
U 1 1 5C9AB39C
P 8300 1450
F 0 "#PWR058" H 8300 1300 50  0001 C CNN
F 1 "VCC" H 8317 1623 50  0000 C CNN
F 2 "" H 8300 1450 50  0001 C CNN
F 3 "" H 8300 1450 50  0001 C CNN
	1    8300 1450
	1    0    0    -1  
$EndComp
Connection ~ 8300 2800
Connection ~ 8300 1450
$Comp
L power:-12V #PWR050
U 1 1 5C9AB842
P 7350 2400
F 0 "#PWR050" H 7350 2500 50  0001 C CNN
F 1 "-12V" V 7350 2650 50  0000 C CNN
F 2 "" H 7350 2400 50  0001 C CNN
F 3 "" H 7350 2400 50  0001 C CNN
	1    7350 2400
	0    -1   -1   0   
$EndComp
Connection ~ 7350 2400
$Comp
L power:+12V #PWR049
U 1 1 5C9ABB1D
P 7350 2000
F 0 "#PWR049" H 7350 1850 50  0001 C CNN
F 1 "+12V" V 7365 2128 50  0000 L CNN
F 2 "" H 7350 2000 50  0001 C CNN
F 3 "" H 7350 2000 50  0001 C CNN
	1    7350 2000
	0    -1   -1   0   
$EndComp
Connection ~ 7350 2000
$Comp
L power:GND #PWR044
U 1 1 5C9E963D
P 6900 2200
F 0 "#PWR044" H 6900 1950 50  0001 C CNN
F 1 "GND" H 6905 2027 50  0000 C CNN
F 2 "" H 6900 2200 50  0001 C CNN
F 3 "" H 6900 2200 50  0001 C CNN
	1    6900 2200
	0    1    1    0   
$EndComp
$Comp
L power:VCC #PWR045
U 1 1 5C9EA706
P 7050 3650
F 0 "#PWR045" H 7050 3500 50  0001 C CNN
F 1 "VCC" V 7068 3777 50  0000 L CNN
F 2 "" H 7050 3650 50  0001 C CNN
F 3 "" H 7050 3650 50  0001 C CNN
	1    7050 3650
	0    -1   -1   0   
$EndComp
Wire Wire Line
	700  2650 700  2950
Wire Wire Line
	700  2950 700  3100
Connection ~ 700  2950
Wire Wire Line
	1150 2050 1150 2150
Wire Wire Line
	1650 2150 2100 2150
Connection ~ 1650 2150
Wire Wire Line
	1650 2050 1650 2150
Wire Wire Line
	2100 2150 2100 2050
Wire Wire Line
	1650 1750 1650 1650
Wire Wire Line
	1150 1750 1150 1650
Connection ~ 1650 1650
Wire Wire Line
	2100 1650 1650 1650
Wire Wire Line
	2100 1750 2100 1650
Wire Wire Line
	3200 2150 3200 2050
Wire Wire Line
	3200 1650 2750 1650
Wire Wire Line
	3200 1750 3200 1650
Wire Wire Line
	2100 1650 2550 1650
Connection ~ 2100 1650
Wire Wire Line
	2550 2350 2550 1650
Wire Wire Line
	8550 3550 8550 3650
Wire Wire Line
	8550 3650 8500 3650
$Comp
L power:+12V #PWR0101
U 1 1 5D477E58
P 9200 1050
F 0 "#PWR0101" H 9200 900 50  0001 C CNN
F 1 "+12V" V 9215 1178 50  0000 L CNN
F 2 "" H 9200 1050 50  0001 C CNN
F 3 "" H 9200 1050 50  0001 C CNN
	1    9200 1050
	-1   0    0    1   
$EndComp
$Comp
L power:PWR_FLAG #FLG0101
U 1 1 5D477FFD
P 9200 1000
F 0 "#FLG0101" H 9200 1075 50  0001 C CNN
F 1 "PWR_FLAG" H 9200 1174 50  0000 C CNN
F 2 "" H 9200 1000 50  0001 C CNN
F 3 "~" H 9200 1000 50  0001 C CNN
	1    9200 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	9200 1000 9200 1050
$Comp
L power:PWR_FLAG #FLG0103
U 1 1 5CB20466
P 8800 1700
F 0 "#FLG0103" H 8800 1775 50  0001 C CNN
F 1 "PWR_FLAG" H 8800 1874 50  0000 C CNN
F 2 "" H 8800 1700 50  0001 C CNN
F 3 "~" H 8800 1700 50  0001 C CNN
	1    8800 1700
	1    0    0    -1  
$EndComp
Wire Wire Line
	8800 1700 8800 1750
$Comp
L power:+3.3VA #PWR0104
U 1 1 5CB34D3A
P 8800 1750
F 0 "#PWR0104" H 8800 1600 50  0001 C CNN
F 1 "+3.3VA" H 8700 1900 50  0000 L CNN
F 2 "" H 8800 1750 50  0001 C CNN
F 3 "" H 8800 1750 50  0001 C CNN
	1    8800 1750
	-1   0    0    1   
$EndComp
$Comp
L power:VEE #PWR0105
U 1 1 5CB35B68
P 9200 2400
F 0 "#PWR0105" H 9200 2250 50  0001 C CNN
F 1 "VEE" H 9218 2573 50  0000 C CNN
F 2 "" H 9200 2400 50  0001 C CNN
F 3 "" H 9200 2400 50  0001 C CNN
	1    9200 2400
	-1   0    0    1   
$EndComp
Wire Wire Line
	8800 1000 8800 1050
$Comp
L power:PWR_FLAG #FLG0102
U 1 1 5D48BCA2
P 8800 1000
F 0 "#FLG0102" H 8800 1075 50  0001 C CNN
F 1 "PWR_FLAG" H 8800 1174 50  0000 C CNN
F 2 "" H 8800 1000 50  0001 C CNN
F 3 "~" H 8800 1000 50  0001 C CNN
	1    8800 1000
	1    0    0    -1  
$EndComp
$Comp
L power:-12V #PWR0102
U 1 1 5D48BAFD
P 8800 1050
F 0 "#PWR0102" H 8800 1150 50  0001 C CNN
F 1 "-12V" V 8800 1300 50  0000 C CNN
F 2 "" H 8800 1050 50  0001 C CNN
F 3 "" H 8800 1050 50  0001 C CNN
	1    8800 1050
	-1   0    0    1   
$EndComp
Wire Wire Line
	9200 2350 9200 2400
$Comp
L power:PWR_FLAG #FLG0104
U 1 1 5CB4D472
P 9200 2350
F 0 "#FLG0104" H 9200 2425 50  0001 C CNN
F 1 "PWR_FLAG" H 9200 2524 50  0000 C CNN
F 2 "" H 9200 2350 50  0001 C CNN
F 3 "~" H 9200 2350 50  0001 C CNN
	1    9200 2350
	1    0    0    -1  
$EndComp
Wire Wire Line
	8800 2350 8800 2400
$Comp
L power:PWR_FLAG #FLG0105
U 1 1 5CB61F63
P 8800 2350
F 0 "#FLG0105" H 8800 2425 50  0001 C CNN
F 1 "PWR_FLAG" H 8800 2524 50  0000 C CNN
F 2 "" H 8800 2350 50  0001 C CNN
F 3 "~" H 8800 2350 50  0001 C CNN
	1    8800 2350
	1    0    0    -1  
$EndComp
$Comp
L power:VCC #PWR0106
U 1 1 5CB7826E
P 8800 2400
F 0 "#PWR0106" H 8800 2250 50  0001 C CNN
F 1 "VCC" H 8817 2573 50  0000 C CNN
F 2 "" H 8800 2400 50  0001 C CNN
F 3 "" H 8800 2400 50  0001 C CNN
	1    8800 2400
	-1   0    0    1   
$EndComp
Wire Wire Line
	2450 2350 2550 2350
Connection ~ 2550 2350
Wire Wire Line
	2650 2350 2550 2350
Wire Wire Line
	2450 5250 2550 5250
Connection ~ 2550 5250
Wire Wire Line
	1150 1650 1650 1650
Wire Wire Line
	1150 2150 1650 2150
Connection ~ 2750 1650
Wire Wire Line
	2750 1650 2750 2350
$Comp
L power:GND #PWR0103
U 1 1 5E4E8026
P 3200 2150
F 0 "#PWR0103" H 3200 1900 50  0001 C CNN
F 1 "GND" H 3205 1977 50  0000 C CNN
F 2 "" H 3200 2150 50  0001 C CNN
F 3 "" H 3200 2150 50  0001 C CNN
	1    3200 2150
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW1
U 1 1 5E500C7B
P 6900 4600
F 0 "SW1" H 6900 4500 50  0000 C CNN
F 1 "SW_Push" H 6900 4400 50  0000 C CNN
F 2 "Buttons_Switches_SMD:SW_SPST_EVPBF" H 6900 4800 50  0001 C CNN
F 3 "~" H 6900 4800 50  0001 C CNN
	1    6900 4600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0107
U 1 1 5E501371
P 6550 4650
F 0 "#PWR0107" H 6550 4400 50  0001 C CNN
F 1 "GND" H 6555 4477 50  0000 C CNN
F 2 "" H 6550 4650 50  0001 C CNN
F 3 "" H 6550 4650 50  0001 C CNN
	1    6550 4650
	1    0    0    -1  
$EndComp
Wire Wire Line
	7100 4600 7250 4600
Wire Wire Line
	6700 4600 6550 4600
Wire Wire Line
	6550 4600 6550 4650
NoConn ~ 1950 2950
$Comp
L MCU_ST_STM32L4:STM32L451CCUx U1
U 1 1 5E448758
P 2550 3750
F 0 "U1" H 2550 5331 50  0000 C CNN
F 1 "STM32L451CCUx" H 2550 5240 50  0000 C CNN
F 2 "Custom_Footprints:ARM-UQFN-48-7x7mm_Pitch0.5mm" H 2050 2350 50  0001 R CNN
F 3 "http://www.st.com/st-web-ui/static/active/en/resource/technical/document/datasheet/DM00340475.pdf" H 2550 3750 50  0001 C CNN
	1    2550 3750
	1    0    0    -1  
$EndComp
Wire Wire Line
	2550 5250 2650 5250
Text GLabel 7250 4600 2    50   Input ~ 0
Reset
Text GLabel 1750 2550 0    50   Input ~ 0
Reset
Wire Wire Line
	1750 2550 1950 2550
Wire Wire Line
	1850 2950 1850 2850
Wire Wire Line
	1850 2850 1950 2850
Wire Wire Line
	1850 2650 1850 2750
Wire Wire Line
	1850 2750 1950 2750
Connection ~ 2650 5250
Wire Wire Line
	2650 5250 2750 5250
Wire Wire Line
	2350 5250 2450 5250
Connection ~ 2450 5250
Wire Wire Line
	1850 3250 1950 3250
Wire Wire Line
	1850 3150 1950 3150
$Comp
L Eurorack_Header:Eurorack_10_pin_power J4
U 1 1 5E51E6D3
P 7650 2200
F 0 "J4" H 7850 1750 50  0000 C CNN
F 1 "Eurorack_10_pin_power" H 7800 1850 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_2x05_Pitch2.54mm" H 7650 2200 50  0001 C CNN
F 3 "" H 7650 2200 50  0001 C CNN
	1    7650 2200
	-1   0    0    1   
$EndComp
Text GLabel 3200 4950 2    50   Input ~ 0
SWCLK
Text GLabel 3200 4850 2    50   Input ~ 0
SWDIO
Wire Wire Line
	3150 4850 3200 4850
Wire Wire Line
	3150 4950 3200 4950
Text GLabel 1850 3150 0    50   Input ~ 0
PC13
Wire Wire Line
	1850 3350 1950 3350
Text GLabel 1850 3350 0    50   Input ~ 0
PC15
Wire Wire Line
	1850 3550 1950 3550
Text GLabel 1850 3250 0    50   Input ~ 0
PC14
Wire Wire Line
	1850 3650 1950 3650
Wire Wire Line
	1850 3750 1950 3750
Wire Wire Line
	1850 3850 1950 3850
Text GLabel 1850 3850 0    50   Input ~ 0
PB3
Wire Wire Line
	1850 3950 1950 3950
Text GLabel 1850 3950 0    50   Input ~ 0
PB4
Wire Wire Line
	1850 4050 1950 4050
Text GLabel 1850 4050 0    50   Input ~ 0
PB5
Wire Wire Line
	1850 4150 1950 4150
Text GLabel 1850 4150 0    50   Input ~ 0
PB6
Wire Wire Line
	1850 4250 1950 4250
Text GLabel 1850 4250 0    50   Input ~ 0
PB7
Wire Wire Line
	1850 4350 1950 4350
Text GLabel 1850 4350 0    50   Input ~ 0
PB8
Wire Wire Line
	1850 4450 1950 4450
Text GLabel 1850 4450 0    50   Input ~ 0
PB9
Wire Wire Line
	1850 4550 1950 4550
Wire Wire Line
	1850 4650 1950 4650
Text GLabel 1850 4650 0    50   Input ~ 0
PB11
Wire Wire Line
	1850 4750 1950 4750
Text GLabel 1850 4750 0    50   Input ~ 0
PB12
Wire Wire Line
	1850 4850 1950 4850
Text GLabel 1850 4850 0    50   Input ~ 0
PB13
Wire Wire Line
	1850 4950 1950 4950
Text GLabel 1850 4950 0    50   Input ~ 0
PB14
Wire Wire Line
	1850 5050 1950 5050
Text GLabel 1850 5050 0    50   Input ~ 0
PB15
Wire Wire Line
	3250 3550 3150 3550
Text GLabel 3250 3550 2    50   Input ~ 0
PA0
Wire Wire Line
	3250 3650 3150 3650
Text GLabel 3250 3650 2    50   Input ~ 0
PA1
Wire Wire Line
	3250 3750 3150 3750
Text GLabel 3250 3750 2    50   Input ~ 0
PA2
Wire Wire Line
	3250 3850 3150 3850
Text GLabel 3250 3850 2    50   Input ~ 0
PA3
Wire Wire Line
	3250 3950 3150 3950
Wire Wire Line
	3250 4050 3150 4050
Wire Wire Line
	3250 4150 3150 4150
Wire Wire Line
	3250 4250 3150 4250
Wire Wire Line
	3250 4350 3150 4350
Text GLabel 3250 4350 2    50   Input ~ 0
PA8
Wire Wire Line
	3250 4450 3150 4450
Text GLabel 3250 4450 2    50   Input ~ 0
PA9
Wire Wire Line
	3250 4550 3150 4550
Text GLabel 3250 4550 2    50   Input ~ 0
PA10
Wire Wire Line
	3250 4650 3150 4650
Text GLabel 3250 4650 2    50   Input ~ 0
PA11
Wire Wire Line
	3250 4750 3150 4750
Text GLabel 3250 4750 2    50   Input ~ 0
PA12
Wire Wire Line
	3250 5050 3150 5050
Text GLabel 3250 5050 2    50   Input ~ 0
PA15
Wire Wire Line
	4350 2800 4450 2800
Wire Wire Line
	4350 2700 4450 2700
Text GLabel 4350 3900 0    50   Input ~ 0
PC13
Wire Wire Line
	4350 2900 4450 2900
Text GLabel 4350 4100 0    50   Input ~ 0
PC15
Wire Wire Line
	4350 3000 4450 3000
Text GLabel 5350 3400 2    50   Input ~ 0
PB0
Text GLabel 4350 4000 0    50   Input ~ 0
PC14
Wire Wire Line
	4350 3100 4450 3100
Text GLabel 5350 3500 2    50   Input ~ 0
PB1
Wire Wire Line
	4350 3200 4450 3200
Text GLabel 5350 3600 2    50   Input ~ 0
PB2
Wire Wire Line
	4350 3300 4450 3300
Text GLabel 4350 3200 0    50   Input ~ 0
PB3
Wire Wire Line
	4350 3400 4450 3400
Text GLabel 4350 3300 0    50   Input ~ 0
PB4
Wire Wire Line
	4350 3500 4450 3500
Text GLabel 4350 3400 0    50   Input ~ 0
PB5
Wire Wire Line
	4350 3600 4450 3600
Text GLabel 4350 3500 0    50   Input ~ 0
PB6
Wire Wire Line
	4350 3700 4450 3700
Text GLabel 4350 3600 0    50   Input ~ 0
PB7
Wire Wire Line
	4350 3800 4450 3800
Text GLabel 4350 3700 0    50   Input ~ 0
PB8
Wire Wire Line
	4350 3900 4450 3900
Text GLabel 4350 3800 0    50   Input ~ 0
PB9
Wire Wire Line
	4350 4000 4450 4000
Text GLabel 5350 3700 2    50   Input ~ 0
PB10
Wire Wire Line
	4350 4100 4450 4100
Text GLabel 5350 3800 2    50   Input ~ 0
PB11
Text GLabel 5350 3900 2    50   Input ~ 0
PB12
Wire Wire Line
	4350 4300 4450 4300
Text GLabel 5350 4000 2    50   Input ~ 0
PB13
Text GLabel 5350 4100 2    50   Input ~ 0
PB14
Text GLabel 5350 4200 2    50   Input ~ 0
PB15
Wire Wire Line
	5350 2600 5250 2600
Text GLabel 5350 2600 2    50   Input ~ 0
PA0
Wire Wire Line
	5350 2700 5250 2700
Text GLabel 5350 2700 2    50   Input ~ 0
PA1
Wire Wire Line
	5350 2800 5250 2800
Text GLabel 5350 2800 2    50   Input ~ 0
PA2
Wire Wire Line
	5350 2900 5250 2900
Text GLabel 5350 2900 2    50   Input ~ 0
PA3
Wire Wire Line
	5350 3000 5250 3000
Text GLabel 5350 3000 2    50   Input ~ 0
PA4
Wire Wire Line
	5350 3100 5250 3100
Text GLabel 5350 3100 2    50   Input ~ 0
PA5
Wire Wire Line
	5350 3200 5250 3200
Text GLabel 5350 3200 2    50   Input ~ 0
PA6
Wire Wire Line
	5350 3300 5250 3300
Text GLabel 5350 3300 2    50   Input ~ 0
PA7
Wire Wire Line
	5350 3400 5250 3400
Text GLabel 5350 4300 2    50   Input ~ 0
PA8
Wire Wire Line
	5350 3500 5250 3500
Text GLabel 4350 2600 0    50   Input ~ 0
PA9
Wire Wire Line
	5350 3600 5250 3600
Text GLabel 4350 2700 0    50   Input ~ 0
PA10
Wire Wire Line
	5350 3700 5250 3700
Text GLabel 4350 2800 0    50   Input ~ 0
PA11
Wire Wire Line
	5350 3800 5250 3800
Text GLabel 4350 2900 0    50   Input ~ 0
PA12
Wire Wire Line
	5350 3900 5250 3900
Text GLabel 4350 3100 0    50   Input ~ 0
PA15
Wire Wire Line
	5250 4000 5350 4000
Wire Wire Line
	5250 4300 5350 4300
Wire Wire Line
	5350 4100 5250 4100
Wire Wire Line
	5350 4200 5250 4200
$Comp
L Connector:Conn_01x22_Female J3
U 1 1 5E71A7D4
P 5050 3400
F 0 "J3" H 4800 2150 50  0000 C CNN
F 1 "Conn_01x22_Female" H 4750 2050 50  0000 C CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x22_Pitch2.54mm" H 5050 3400 50  0001 C CNN
F 3 "~" H 5050 3400 50  0001 C CNN
	1    5050 3400
	-1   0    0    -1  
$EndComp
NoConn ~ 2350 2350
Text Notes 2238 2984 0    50   ~ 0
BOOT0
Text GLabel 3250 4250 2    50   Input ~ 0
PA7
Text GLabel 3250 4150 2    50   Input ~ 0
PA6
Text GLabel 3250 4050 2    50   Input ~ 0
PA5
Text GLabel 3250 3950 2    50   Input ~ 0
PA4
Text GLabel 1850 4550 0    50   Input ~ 0
PB10
Text GLabel 1850 3750 0    50   Input ~ 0
PB2
Text GLabel 1850 3650 0    50   Input ~ 0
PB1
Text GLabel 1850 3550 0    50   Input ~ 0
PB0
$Comp
L Connector:Conn_01x20_Female J2
U 1 1 5E88F24B
P 4650 3300
F 0 "J2" H 4450 2200 50  0000 L CNN
F 1 "Conn_01x20_Female" H 4100 2050 50  0000 L CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x20_Pitch2.54mm" H 4650 3300 50  0001 C CNN
F 3 "~" H 4650 3300 50  0001 C CNN
	1    4650 3300
	1    0    0    -1  
$EndComp
$Comp
L power:VEE #PWR0108
U 1 1 5E8C5D95
P 5350 4500
F 0 "#PWR0108" H 5350 4350 50  0001 C CNN
F 1 "VEE" V 5350 4700 50  0000 C CNN
F 2 "" H 5350 4500 50  0001 C CNN
F 3 "" H 5350 4500 50  0001 C CNN
	1    5350 4500
	0    1    1    0   
$EndComp
Wire Wire Line
	5250 2400 5350 2400
$Comp
L power:VCC #PWR0109
U 1 1 5E8CD9F4
P 4350 2400
F 0 "#PWR0109" H 4350 2250 50  0001 C CNN
F 1 "VCC" V 4350 2600 50  0000 C CNN
F 2 "" H 4350 2400 50  0001 C CNN
F 3 "" H 4350 2400 50  0001 C CNN
	1    4350 2400
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR0110
U 1 1 5E8D2216
P 4350 4200
F 0 "#PWR0110" H 4350 3950 50  0001 C CNN
F 1 "GND" V 4350 4000 50  0000 C CNN
F 2 "" H 4350 4200 50  0001 C CNN
F 3 "" H 4350 4200 50  0001 C CNN
	1    4350 4200
	0    1    1    0   
$EndComp
Wire Wire Line
	4350 4200 4450 4200
Wire Wire Line
	5250 4400 5350 4400
Wire Wire Line
	5250 4500 5350 4500
Wire Wire Line
	5250 2500 5350 2500
Wire Wire Line
	4350 2400 4450 2400
Wire Wire Line
	4350 2500 4450 2500
Wire Wire Line
	4350 2600 4450 2600
$Comp
L power:+3.3V #PWR0111
U 1 1 5E91CB6B
P 4350 4300
F 0 "#PWR0111" H 4350 4150 50  0001 C CNN
F 1 "+3.3V" V 4365 4428 50  0000 L CNN
F 2 "" H 4350 4300 50  0001 C CNN
F 3 "" H 4350 4300 50  0001 C CNN
	1    4350 4300
	0    -1   -1   0   
$EndComp
$Comp
L power:+3.3V #PWR0112
U 1 1 5E926DAC
P 5350 4400
F 0 "#PWR0112" H 5350 4250 50  0001 C CNN
F 1 "+3.3V" V 5365 4528 50  0000 L CNN
F 2 "" H 5350 4400 50  0001 C CNN
F 3 "" H 5350 4400 50  0001 C CNN
	1    5350 4400
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0114
U 1 1 5E9285D7
P 5350 2500
F 0 "#PWR0114" H 5350 2250 50  0001 C CNN
F 1 "GND" V 5350 2300 50  0000 C CNN
F 2 "" H 5350 2500 50  0001 C CNN
F 3 "" H 5350 2500 50  0001 C CNN
	1    5350 2500
	0    -1   -1   0   
$EndComp
$Comp
L power:+3.3V #PWR0115
U 1 1 5E928CC1
P 5350 2400
F 0 "#PWR0115" H 5350 2250 50  0001 C CNN
F 1 "+3.3V" V 5365 2528 50  0000 L CNN
F 2 "" H 5350 2400 50  0001 C CNN
F 3 "" H 5350 2400 50  0001 C CNN
	1    5350 2400
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR0116
U 1 1 5E9853F5
P 4350 3000
F 0 "#PWR0116" H 4350 2750 50  0001 C CNN
F 1 "GND" V 4350 2800 50  0000 C CNN
F 2 "" H 4350 3000 50  0001 C CNN
F 3 "" H 4350 3000 50  0001 C CNN
	1    4350 3000
	0    1    1    0   
$EndComp
$Comp
L power:+3.3VA #PWR?
U 1 1 5E98768A
P 4350 2500
F 0 "#PWR?" H 4350 2350 50  0001 C CNN
F 1 "+3.3VA" V 4350 2650 50  0000 L CNN
F 2 "" H 4350 2500 50  0001 C CNN
F 3 "" H 4350 2500 50  0001 C CNN
	1    4350 2500
	0    -1   -1   0   
$EndComp
$EndSCHEMATC