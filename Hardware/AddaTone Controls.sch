EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "Addatone"
Date ""
Rev ""
Comp "Mountjoy Modular"
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
Text GLabel 9150 2600 0    50   Input ~ 0
MIX_SWITCH
$Comp
L Device:R_POT FreqScale1
U 1 1 5C7E8920
P 7350 3900
F 0 "FreqScale1" H 7280 3946 50  0000 R CNN
F 1 "B10k" H 7280 3855 50  0000 R CNN
F 2 "Custom_Footprints:Alpha_9mm_Potentiometer" H 7350 3900 50  0001 C CNN
F 3 "~" H 7350 3900 50  0001 C CNN
	1    7350 3900
	1    0    0    -1  
$EndComp
Text GLabel 7600 3900 2    50   Input ~ 0
FREQ_SC_POT
$Comp
L power:+3.3VA #PWR022
U 1 1 5C80C27F
P 7350 3600
F 0 "#PWR022" H 7350 3450 50  0001 C CNN
F 1 "+3.3VA" H 7365 3773 50  0000 C CNN
F 2 "" H 7350 3600 50  0001 C CNN
F 3 "" H 7350 3600 50  0001 C CNN
	1    7350 3600
	1    0    0    -1  
$EndComp
Wire Wire Line
	7350 3600 7350 3750
$Comp
L power:GND #PWR023
U 1 1 5C80FC0B
P 7350 4250
F 0 "#PWR023" H 7350 4000 50  0001 C CNN
F 1 "GND" H 7355 4077 50  0000 C CNN
F 2 "" H 7350 4250 50  0001 C CNN
F 3 "" H 7350 4250 50  0001 C CNN
	1    7350 4250
	1    0    0    -1  
$EndComp
$Comp
L Device:R_POT HarmCount1
U 1 1 5C88F637
P 5650 3950
F 0 "HarmCount1" H 5580 3996 50  0000 R CNN
F 1 "B10k" H 5580 3905 50  0000 R CNN
F 2 "Custom_Footprints:Alpha_9mm_Potentiometer" H 5650 3950 50  0001 C CNN
F 3 "~" H 5650 3950 50  0001 C CNN
	1    5650 3950
	1    0    0    -1  
$EndComp
Text GLabel 5900 3950 2    50   Input ~ 0
HARM_COUNT_POT
Wire Wire Line
	5800 3950 5900 3950
$Comp
L power:+3.3VA #PWR016
U 1 1 5C88F640
P 5650 3650
F 0 "#PWR016" H 5650 3500 50  0001 C CNN
F 1 "+3.3VA" H 5665 3823 50  0000 C CNN
F 2 "" H 5650 3650 50  0001 C CNN
F 3 "" H 5650 3650 50  0001 C CNN
	1    5650 3650
	1    0    0    -1  
$EndComp
Wire Wire Line
	5650 3650 5650 3800
$Comp
L power:GND #PWR017
U 1 1 5C88F647
P 5650 4250
F 0 "#PWR017" H 5650 4000 50  0001 C CNN
F 1 "GND" H 5655 4077 50  0000 C CNN
F 2 "" H 5650 4250 50  0001 C CNN
F 3 "" H 5650 4250 50  0001 C CNN
	1    5650 4250
	1    0    0    -1  
$EndComp
Wire Wire Line
	5650 4100 5650 4250
Wire Wire Line
	1550 4000 1650 4000
Text GLabel 5900 1300 2    50   Input ~ 0
FTUNE
$Comp
L power:+3.3VA #PWR012
U 1 1 5C9C8E9C
P 5650 1000
F 0 "#PWR012" H 5650 850 50  0001 C CNN
F 1 "+3.3VA" H 5665 1173 50  0000 C CNN
F 2 "" H 5650 1000 50  0001 C CNN
F 3 "" H 5650 1000 50  0001 C CNN
	1    5650 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	5650 1000 5650 1150
$Comp
L power:GND #PWR013
U 1 1 5C9C8EA3
P 5650 1650
F 0 "#PWR013" H 5650 1400 50  0001 C CNN
F 1 "GND" H 5655 1477 50  0000 C CNN
F 2 "" H 5650 1650 50  0001 C CNN
F 3 "" H 5650 1650 50  0001 C CNN
	1    5650 1650
	1    0    0    -1  
$EndComp
$Comp
L Device:R_POT CTune1
U 1 1 5C8AF8CD
P 7300 1300
F 0 "CTune1" H 7230 1346 50  0000 R CNN
F 1 "B10k" H 7230 1255 50  0000 R CNN
F 2 "Custom_Footprints:Alpha_9mm_Potentiometer" H 7300 1300 50  0001 C CNN
F 3 "~" H 7300 1300 50  0001 C CNN
	1    7300 1300
	1    0    0    -1  
$EndComp
Text GLabel 7550 1300 2    50   Input ~ 0
CTUNE
Wire Wire Line
	7450 1300 7550 1300
$Comp
L power:+3.3VA #PWR018
U 1 1 5C8AF8D5
P 7300 1000
F 0 "#PWR018" H 7300 850 50  0001 C CNN
F 1 "+3.3VA" H 7315 1173 50  0000 C CNN
F 2 "" H 7300 1000 50  0001 C CNN
F 3 "" H 7300 1000 50  0001 C CNN
	1    7300 1000
	1    0    0    -1  
$EndComp
Wire Wire Line
	7300 1000 7300 1150
$Comp
L power:GND #PWR019
U 1 1 5C8AF8DC
P 7300 1600
F 0 "#PWR019" H 7300 1350 50  0001 C CNN
F 1 "GND" H 7305 1427 50  0000 C CNN
F 2 "" H 7300 1600 50  0001 C CNN
F 3 "" H 7300 1600 50  0001 C CNN
	1    7300 1600
	1    0    0    -1  
$EndComp
Wire Wire Line
	7300 1450 7300 1600
$Comp
L Device:R_POT Harm1
U 1 1 5C8C3CC9
P 5650 2650
F 0 "Harm1" H 5580 2696 50  0000 R CNN
F 1 "B10k" H 5580 2605 50  0000 R CNN
F 2 "Custom_Footprints:Alpha_9mm_Potentiometer" H 5650 2650 50  0001 C CNN
F 3 "~" H 5650 2650 50  0001 C CNN
	1    5650 2650
	1    0    0    -1  
$EndComp
Text GLabel 5900 2650 2    50   Input ~ 0
HARM1_POT
$Comp
L power:+3.3VA #PWR014
U 1 1 5C8C3CD1
P 5650 2350
F 0 "#PWR014" H 5650 2200 50  0001 C CNN
F 1 "+3.3VA" H 5665 2523 50  0000 C CNN
F 2 "" H 5650 2350 50  0001 C CNN
F 3 "" H 5650 2350 50  0001 C CNN
	1    5650 2350
	1    0    0    -1  
$EndComp
Wire Wire Line
	5650 2350 5650 2500
$Comp
L power:GND #PWR015
U 1 1 5C8C3CD8
P 5650 3000
F 0 "#PWR015" H 5650 2750 50  0001 C CNN
F 1 "GND" H 5655 2827 50  0000 C CNN
F 2 "" H 5650 3000 50  0001 C CNN
F 3 "" H 5650 3000 50  0001 C CNN
	1    5650 3000
	1    0    0    -1  
$EndComp
$Comp
L thonkiconn:AudioJack2_Ground_Switch J3
U 1 1 5C8DCECD
P 3400 1300
F 0 "J3" H 3404 1642 50  0000 C CNN
F 1 "PItch_In" H 3404 1551 50  0000 C CNN
F 2 "Custom_Footprints:THONKICONN_hole" H 3400 1300 50  0001 C CNN
F 3 "~" H 3400 1300 50  0001 C CNN
	1    3400 1300
	1    0    0    -1  
$EndComp
Wire Wire Line
	3600 1300 3950 1300
$Comp
L power:GND #PWR06
U 1 1 5C8E7D2E
P 3650 1200
F 0 "#PWR06" H 3650 950 50  0001 C CNN
F 1 "GND" V 3650 1000 50  0000 C CNN
F 2 "" H 3650 1200 50  0001 C CNN
F 3 "" H 3650 1200 50  0001 C CNN
	1    3650 1200
	0    -1   -1   0   
$EndComp
Wire Wire Line
	3600 1200 3650 1200
Text GLabel 3650 1400 2    50   Input ~ 0
CV_IN
Wire Wire Line
	3600 1400 3650 1400
$Comp
L thonkiconn:AudioJack2_Ground_Switch J4
U 1 1 5CA42DD8
P 3400 2050
F 0 "J4" H 3404 2392 50  0000 C CNN
F 1 "Harm1_In" H 3404 2301 50  0000 C CNN
F 2 "Custom_Footprints:THONKICONN_hole" H 3400 2050 50  0001 C CNN
F 3 "~" H 3400 2050 50  0001 C CNN
	1    3400 2050
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR08
U 1 1 5CA430F3
P 3700 2250
F 0 "#PWR08" H 3700 2000 50  0001 C CNN
F 1 "GND" V 3700 2050 50  0000 C CNN
F 2 "" H 3700 2250 50  0001 C CNN
F 3 "" H 3700 2250 50  0001 C CNN
	1    3700 2250
	1    0    0    -1  
$EndComp
Wire Wire Line
	3700 2150 3700 2250
Connection ~ 3700 2150
Wire Wire Line
	3600 2150 3700 2150
Wire Wire Line
	3600 1950 3700 1950
Wire Wire Line
	3700 1950 3700 2150
$Comp
L thonkiconn:AudioJack2_Ground_Switch J5
U 1 1 5CADEC24
P 3400 2900
F 0 "J5" H 3404 3242 50  0000 C CNN
F 1 "Harm2_In" H 3404 3151 50  0000 C CNN
F 2 "Custom_Footprints:THONKICONN_hole" H 3400 2900 50  0001 C CNN
F 3 "~" H 3400 2900 50  0001 C CNN
	1    3400 2900
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR09
U 1 1 5CADEC2A
P 3700 3100
F 0 "#PWR09" H 3700 2850 50  0001 C CNN
F 1 "GND" V 3700 2900 50  0000 C CNN
F 2 "" H 3700 3100 50  0001 C CNN
F 3 "" H 3700 3100 50  0001 C CNN
	1    3700 3100
	1    0    0    -1  
$EndComp
Wire Wire Line
	3700 3000 3700 3100
Connection ~ 3700 3000
Wire Wire Line
	3600 3000 3700 3000
Wire Wire Line
	3600 2800 3700 2800
Wire Wire Line
	3700 2800 3700 3000
$Comp
L thonkiconn:AudioJack2_Ground_Switch J6
U 1 1 5CAEC3B2
P 3400 3750
F 0 "J6" H 3404 4092 50  0000 C CNN
F 1 "Freq_Scale_In" H 3404 4001 50  0000 C CNN
F 2 "Custom_Footprints:THONKICONN_hole" H 3400 3750 50  0001 C CNN
F 3 "~" H 3400 3750 50  0001 C CNN
	1    3400 3750
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR07
U 1 1 5CAEC3B8
P 3650 4000
F 0 "#PWR07" H 3650 3750 50  0001 C CNN
F 1 "GND" V 3650 3800 50  0000 C CNN
F 2 "" H 3650 4000 50  0001 C CNN
F 3 "" H 3650 4000 50  0001 C CNN
	1    3650 4000
	1    0    0    -1  
$EndComp
Wire Wire Line
	3600 2050 3950 2050
Wire Wire Line
	3600 2900 3950 2900
Wire Wire Line
	3600 3750 3900 3750
Wire Wire Line
	3600 3650 3650 3650
$Comp
L Device:R_POT Harm2
U 1 1 5CC5909D
P 7350 2650
F 0 "Harm2" H 7280 2696 50  0000 R CNN
F 1 "B10k" H 7280 2605 50  0000 R CNN
F 2 "Custom_Footprints:Alpha_9mm_Potentiometer" H 7350 2650 50  0001 C CNN
F 3 "~" H 7350 2650 50  0001 C CNN
	1    7350 2650
	1    0    0    -1  
$EndComp
Text GLabel 7600 2650 2    50   Input ~ 0
HARM2_POT
$Comp
L power:+3.3VA #PWR020
U 1 1 5CC590A5
P 7350 2350
F 0 "#PWR020" H 7350 2200 50  0001 C CNN
F 1 "+3.3VA" H 7365 2523 50  0000 C CNN
F 2 "" H 7350 2350 50  0001 C CNN
F 3 "" H 7350 2350 50  0001 C CNN
	1    7350 2350
	1    0    0    -1  
$EndComp
Wire Wire Line
	7350 2350 7350 2500
$Comp
L power:GND #PWR021
U 1 1 5CC590AC
P 7350 3000
F 0 "#PWR021" H 7350 2750 50  0001 C CNN
F 1 "GND" H 7355 2827 50  0000 C CNN
F 2 "" H 7350 3000 50  0001 C CNN
F 3 "" H 7350 3000 50  0001 C CNN
	1    7350 3000
	1    0    0    -1  
$EndComp
$Comp
L thonkiconn:AudioJack2_Ground_Switch J7
U 1 1 5CCCC44F
P 1850 4000
F 0 "J7" H 1617 3979 50  0000 R CNN
F 1 "DAC1_Out" H 1617 4070 50  0000 R CNN
F 2 "Custom_Footprints:THONKICONN_hole" H 1850 4000 50  0001 C CNN
F 3 "~" H 1850 4000 50  0001 C CNN
	1    1850 4000
	-1   0    0    1   
$EndComp
NoConn ~ 1650 3900
$Comp
L power:GND #PWR010
U 1 1 5CCDAF78
P 1600 4200
F 0 "#PWR010" H 1600 3950 50  0001 C CNN
F 1 "GND" H 1605 4027 50  0000 C CNN
F 2 "" H 1600 4200 50  0001 C CNN
F 3 "" H 1600 4200 50  0001 C CNN
	1    1600 4200
	1    0    0    -1  
$EndComp
Wire Wire Line
	1650 4100 1600 4100
Wire Wire Line
	1600 4100 1600 4200
Wire Wire Line
	1550 4800 1650 4800
$Comp
L thonkiconn:AudioJack2_Ground_Switch J8
U 1 1 5CCE9915
P 1850 4800
F 0 "J8" H 1617 4779 50  0000 R CNN
F 1 "DAC2_Out" H 1617 4870 50  0000 R CNN
F 2 "Custom_Footprints:THONKICONN_hole" H 1850 4800 50  0001 C CNN
F 3 "~" H 1850 4800 50  0001 C CNN
	1    1850 4800
	-1   0    0    1   
$EndComp
NoConn ~ 1650 4700
$Comp
L power:GND #PWR011
U 1 1 5CCE991C
P 1600 5000
F 0 "#PWR011" H 1600 4750 50  0001 C CNN
F 1 "GND" H 1605 4827 50  0000 C CNN
F 2 "" H 1600 5000 50  0001 C CNN
F 3 "" H 1600 5000 50  0001 C CNN
	1    1600 5000
	1    0    0    -1  
$EndComp
Wire Wire Line
	1650 4900 1600 4900
Wire Wire Line
	1600 4900 1600 5000
Wire Wire Line
	3600 3850 3650 3850
Wire Wire Line
	3650 3650 3650 3850
Connection ~ 3650 3850
Wire Wire Line
	3650 3850 3650 4000
$Comp
L Switch:SW_SPST SW4
U 1 1 5E8B1CBD
P 9550 2600
F 0 "SW4" H 9550 2835 50  0000 C CNN
F 1 "SW_SPST" H 9550 2744 50  0000 C CNN
F 2 "Custom_Footprints:SPDTSubMiniature" H 9550 2600 50  0001 C CNN
F 3 "~" H 9550 2600 50  0001 C CNN
	1    9550 2600
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR025
U 1 1 5E8B261E
P 9950 2700
F 0 "#PWR025" H 9950 2450 50  0001 C CNN
F 1 "GND" H 9955 2527 50  0000 C CNN
F 2 "" H 9950 2700 50  0001 C CNN
F 3 "" H 9950 2700 50  0001 C CNN
	1    9950 2700
	1    0    0    -1  
$EndComp
Wire Wire Line
	9150 2600 9350 2600
Wire Wire Line
	9750 2600 9950 2600
Wire Wire Line
	9950 2600 9950 2700
Text GLabel 9150 2100 0    50   Input ~ 0
RING_MOD
$Comp
L Switch:SW_SPST SW3
U 1 1 5EAA8228
P 9550 2100
F 0 "SW3" H 9550 2335 50  0000 C CNN
F 1 "SW_SPST" H 9550 2244 50  0000 C CNN
F 2 "Custom_Footprints:SPDTSubMiniature" H 9550 2100 50  0001 C CNN
F 3 "~" H 9550 2100 50  0001 C CNN
	1    9550 2100
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR027
U 1 1 5EAA8232
P 9950 2200
F 0 "#PWR027" H 9950 1950 50  0001 C CNN
F 1 "GND" H 9955 2027 50  0000 C CNN
F 2 "" H 9950 2200 50  0001 C CNN
F 3 "" H 9950 2200 50  0001 C CNN
	1    9950 2200
	1    0    0    -1  
$EndComp
Wire Wire Line
	9150 2100 9350 2100
Wire Wire Line
	9750 2100 9950 2100
Wire Wire Line
	9950 2100 9950 2200
$Comp
L power:GND #PWR026
U 1 1 5EAF9BBF
P 9950 1700
F 0 "#PWR026" H 9950 1450 50  0001 C CNN
F 1 "GND" H 9955 1527 50  0000 C CNN
F 2 "" H 9950 1700 50  0001 C CNN
F 3 "" H 9950 1700 50  0001 C CNN
	1    9950 1700
	1    0    0    -1  
$EndComp
Wire Wire Line
	9750 1600 9950 1600
Wire Wire Line
	9950 1600 9950 1700
$Comp
L power:GND #PWR024
U 1 1 5EC1363E
P 9950 1150
F 0 "#PWR024" H 9950 900 50  0001 C CNN
F 1 "GND" H 9955 977 50  0000 C CNN
F 2 "" H 9950 1150 50  0001 C CNN
F 3 "" H 9950 1150 50  0001 C CNN
	1    9950 1150
	1    0    0    -1  
$EndComp
Wire Wire Line
	9750 1050 9950 1050
Wire Wire Line
	9950 1050 9950 1150
Wire Wire Line
	7500 2650 7600 2650
Wire Wire Line
	7350 2800 7350 3000
Wire Wire Line
	7500 3900 7600 3900
Wire Wire Line
	7350 4050 7350 4250
Wire Wire Line
	5800 2650 5900 2650
Wire Wire Line
	5650 2800 5650 3000
$Comp
L Device:R_POT FTune1
U 1 1 5C9C8E94
P 5650 1300
F 0 "FTune1" H 5580 1346 50  0000 R CNN
F 1 "B10k" H 5580 1255 50  0000 R CNN
F 2 "Custom_Footprints:Alpha_9mm_Potentiometer" H 5650 1300 50  0001 C CNN
F 3 "~" H 5650 1300 50  0001 C CNN
	1    5650 1300
	1    0    0    -1  
$EndComp
Wire Wire Line
	5650 1450 5650 1650
Wire Wire Line
	5800 1300 5900 1300
Wire Wire Line
	9150 1050 9350 1050
Text GLabel 9150 1050 0    50   Input ~ 0
RESET
Wire Wire Line
	9150 1600 9350 1600
Text GLabel 9150 1600 0    50   Input ~ 0
Calibration
Text GLabel 1850 2200 0    50   Input ~ 0
CV_IN
Text GLabel 1850 2700 0    50   Input ~ 0
FREQ_SC_POT
Text GLabel 1850 1750 0    50   Input ~ 0
CTUNE
Text GLabel 1850 3000 0    50   Input ~ 0
HARM2_POT
Text GLabel 1850 1350 0    50   Input ~ 0
HARM_COUNT_POT
Text GLabel 1850 1550 0    50   Input ~ 0
FTUNE
Text GLabel 1850 1650 0    50   Input ~ 0
HARM1_POT
Text GLabel 1850 2600 0    50   Input ~ 0
PITCH_CVIN
Text GLabel 1850 2500 0    50   Input ~ 0
HARM1_CVIN
Text GLabel 1850 1050 0    50   Input ~ 0
HARM2_CVIN
Text GLabel 1850 3300 0    50   Input ~ 0
AUDIO1_OUT
Text GLabel 1850 3200 0    50   Input ~ 0
AUDIO2_OUT
Text GLabel 1850 1950 0    50   Input ~ 0
MIX_SWITCH
Text GLabel 1850 2900 0    50   Input ~ 0
RESET
Text GLabel 1850 1850 0    50   Input ~ 0
RING_MOD
Text GLabel 1850 1150 0    50   Input ~ 0
FREQ_SCALE_CVIN
Text GLabel 1850 2800 0    50   Input ~ 0
Calibration
$Comp
L power:+3.3V #PWR05
U 1 1 5F200B39
P 1850 3100
F 0 "#PWR05" H 1850 2950 50  0001 C CNN
F 1 "+3.3V" V 1850 3350 50  0000 C CNN
F 2 "" H 1850 3100 50  0001 C CNN
F 3 "" H 1850 3100 50  0001 C CNN
	1    1850 3100
	0    -1   -1   0   
$EndComp
$Comp
L power:+3.3VA #PWR01
U 1 1 5F2050BB
P 1850 1250
F 0 "#PWR01" H 1850 1100 50  0001 C CNN
F 1 "+3.3VA" V 1850 1400 50  0000 L CNN
F 2 "" H 1850 1250 50  0001 C CNN
F 3 "" H 1850 1250 50  0001 C CNN
	1    1850 1250
	0    -1   -1   0   
$EndComp
$Comp
L power:+3.3VA #PWR03
U 1 1 5F210359
P 1850 2300
F 0 "#PWR03" H 1850 2150 50  0001 C CNN
F 1 "+3.3VA" V 1850 2450 50  0000 L CNN
F 2 "" H 1850 2300 50  0001 C CNN
F 3 "" H 1850 2300 50  0001 C CNN
	1    1850 2300
	0    -1   -1   0   
$EndComp
$Comp
L power:GND #PWR04
U 1 1 5F23E21A
P 1850 2400
F 0 "#PWR04" H 1850 2150 50  0001 C CNN
F 1 "GND" V 1850 2200 50  0000 C CNN
F 2 "" H 1850 2400 50  0001 C CNN
F 3 "" H 1850 2400 50  0001 C CNN
	1    1850 2400
	0    1    1    0   
$EndComp
$Comp
L power:GND #PWR02
U 1 1 5F23EF62
P 1850 1450
F 0 "#PWR02" H 1850 1200 50  0001 C CNN
F 1 "GND" V 1850 1250 50  0000 C CNN
F 2 "" H 1850 1450 50  0001 C CNN
F 3 "" H 1850 1450 50  0001 C CNN
	1    1850 1450
	0    1    1    0   
$EndComp
Text GLabel 1550 4000 0    50   Input ~ 0
AUDIO1_OUT
Text GLabel 1550 4800 0    50   Input ~ 0
AUDIO2_OUT
Text GLabel 3950 1300 2    50   Input ~ 0
PITCH_CVIN
Text GLabel 3950 2050 2    50   Input ~ 0
HARM1_CVIN
Text GLabel 3950 2900 2    50   Input ~ 0
HARM2_CVIN
Text GLabel 3900 3750 2    50   Input ~ 0
FREQ_SCALE_CVIN
$Comp
L Switch:SW_Push SW1
U 1 1 5EA45426
P 9550 1050
F 0 "SW1" H 9550 1335 50  0000 C CNN
F 1 "SW_Push" H 9550 1244 50  0000 C CNN
F 2 "Buttons_Switches_THT:SW_PUSH_6mm" H 9550 1250 50  0001 C CNN
F 3 "~" H 9550 1250 50  0001 C CNN
	1    9550 1050
	1    0    0    -1  
$EndComp
$Comp
L Switch:SW_Push SW2
U 1 1 5EA49376
P 9550 1600
F 0 "SW2" H 9550 1885 50  0000 C CNN
F 1 "SW_Push" H 9550 1794 50  0000 C CNN
F 2 "Buttons_Switches_THT:SW_PUSH_6mm" H 9550 1800 50  0001 C CNN
F 3 "~" H 9550 1800 50  0001 C CNN
	1    9550 1600
	1    0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x12_Male J2
U 1 1 5E9B6880
P 2050 2700
F 0 "J2" H 2022 2674 50  0000 R CNN
F 1 "Conn_01x12_Male" H 2022 2583 50  0000 R CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x12_Pitch2.54mm" H 2050 2700 50  0001 C CNN
F 3 "~" H 2050 2700 50  0001 C CNN
	1    2050 2700
	-1   0    0    -1  
$EndComp
$Comp
L Connector:Conn_01x10_Male J1
U 1 1 5E9B71EC
P 2050 1450
F 0 "J1" H 2022 1424 50  0000 R CNN
F 1 "Conn_01x10_Male" H 2022 1333 50  0000 R CNN
F 2 "Pin_Headers:Pin_Header_Straight_1x10_Pitch2.54mm" H 2050 1450 50  0001 C CNN
F 3 "~" H 2050 1450 50  0001 C CNN
	1    2050 1450
	-1   0    0    -1  
$EndComp
$EndSCHEMATC
