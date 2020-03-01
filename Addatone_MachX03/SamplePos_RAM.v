/* Verilog netlist generated by SCUBA Diamond (64-bit) 3.11.2.446 */
/* Module Version: 7.5 */
/* C:\lscc\diamond\3.11_x64\ispfpga\bin\nt64\scuba.exe -w -n SamplePos_RAM -lang verilog -synth lse -bus_exp 7 -bb -arch xo3c00f -type bram -wp 10 -rp 1000 -addr_width 8 -data_width 16 -num_rows 256 -cascade -1 -memfile d:/eurorack/addatone/addatone_machx03/lut/sample_pos_lut_optimised.mem -memformat hex -writemode NORMAL  */
/* Sun Mar 01 15:11:10 2020 */


`timescale 1 ns / 1 ps
module SamplePos_RAM (Clock, ClockEn, Reset, WE, Address, Data, Q)/* synthesis NGD_DRC_MASK=1 */;
    input wire Clock;
    input wire ClockEn;
    input wire Reset;
    input wire WE;
    input wire [7:0] Address;
    input wire [15:0] Data;
    output wire [15:0] Q;

    wire scuba_vhi;
    wire scuba_vlo;

    VHI scuba_vhi_inst (.Z(scuba_vhi));

    VLO scuba_vlo_inst (.Z(scuba_vlo));

    defparam SamplePos_RAM_0_0_0.INIT_DATA = "STATIC" ;
    defparam SamplePos_RAM_0_0_0.ASYNC_RESET_RELEASE = "SYNC" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_1F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_1E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_1D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_1C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_1B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_1A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_19 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_18 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_17 = "0x0840300E490D2750903A0B2680D8250E06A04E290C00A048790A41B00A310A87505A660986D0B86A" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_16 = "0x0D0660B8210C65F09604090620143F024720D8060CE090F669070330725C09E1F0B80A0F86B0E260" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_15 = "0x0FC7D050510CC05000700C04E0A03408E3A03A310DA480FC2705A300B8680E20F0121608A5204C06" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_14 = "0x0E65A0600F0D8730187C0F0730B4430BC7D030380527402E0A0F0020A6290EC7204A380FE630C238" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_13 = "0x0E04A072370283D0AE130885A0346300A530B0420944A01E660D05D0B4640E23F0361B0CE4605C5B" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_12 = "0x0981407809000420B87504E0E0287D0B40D09E620D2460943205A67096100005C018390F40504052" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_11 = "0x0842B0262104E0B034000A80D0AE0A06C280F06504A30026660545B0FA1D07E550E004024220B016" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_10 = "0x0D40808E1C0F6170D24C03E40050090CE360A87208C220B22C09A110462A066000A0000300002000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_0F = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_0E = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_0D = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_0C = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_0B = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_0A = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_09 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_08 = "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_07 = "0x23DAE2B93311E3D1471E266001EAE10011E171D71471E1EA8F0F50A07A8F0A23D1C2CC1EB853331E" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_06 = "0x28F7033333214B82159928FC20F4B80F5C2332280288F35C8F1470A11E512B814333C23330A26747" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_05 = "0x1983D0008F2E03D146003D6283D7990291E1C3D707A002E0B81C3EB0A2A33AEB8266281C3C219828" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_04 = "0x215C2000B81EBAE0A2513D7AE38466050E1147EB11EF50291E28E7A35DD70511E07A0002866267EB" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_03 = "0x28FC2266B81EAE1028660A27A0F4661C2661471E3851E2B8CC28F850F4513AE140CC661702819866" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_02 = "0x333990A28F28E7A1EA3D2B9700A2E10F585029C211ECC0F5C21C35C35C0028EF5333330F43D0011E" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_01 = "0x0F46635C8F2B8660F5471EA3D171C2198A3147851C34735C2823D0A30AE12B83D147993847A3D628" ;
    defparam SamplePos_RAM_0_0_0.INITVAL_00 = "0x384A3171992155C11EF5171EB147D7028283331E0511E11EF51C3330CDC235C00000000000000000" ;
    defparam SamplePos_RAM_0_0_0.CSDECODE_B = "0b000" ;
    defparam SamplePos_RAM_0_0_0.CSDECODE_A = "0b000" ;
    defparam SamplePos_RAM_0_0_0.WRITEMODE_B = "NORMAL" ;
    defparam SamplePos_RAM_0_0_0.WRITEMODE_A = "NORMAL" ;
    defparam SamplePos_RAM_0_0_0.GSR = "ENABLED" ;
    defparam SamplePos_RAM_0_0_0.RESETMODE = "ASYNC" ;
    defparam SamplePos_RAM_0_0_0.REGMODE_B = "NOREG" ;
    defparam SamplePos_RAM_0_0_0.REGMODE_A = "NOREG" ;
    defparam SamplePos_RAM_0_0_0.DATA_WIDTH_B = 9 ;
    defparam SamplePos_RAM_0_0_0.DATA_WIDTH_A = 9 ;
    DP8KC SamplePos_RAM_0_0_0 (.DIA8(Data[8]), .DIA7(Data[7]), .DIA6(Data[6]), 
        .DIA5(Data[5]), .DIA4(Data[4]), .DIA3(Data[3]), .DIA2(Data[2]), 
        .DIA1(Data[1]), .DIA0(Data[0]), .ADA12(scuba_vlo), .ADA11(scuba_vlo), 
        .ADA10(Address[7]), .ADA9(Address[6]), .ADA8(Address[5]), .ADA7(Address[4]), 
        .ADA6(Address[3]), .ADA5(Address[2]), .ADA4(Address[1]), .ADA3(Address[0]), 
        .ADA2(scuba_vlo), .ADA1(scuba_vlo), .ADA0(scuba_vhi), .CEA(ClockEn), 
        .OCEA(ClockEn), .CLKA(Clock), .WEA(WE), .CSA2(scuba_vlo), .CSA1(scuba_vlo), 
        .CSA0(scuba_vlo), .RSTA(Reset), .DIB8(scuba_vlo), .DIB7(scuba_vlo), 
        .DIB6(Data[15]), .DIB5(Data[14]), .DIB4(Data[13]), .DIB3(Data[12]), 
        .DIB2(Data[11]), .DIB1(Data[10]), .DIB0(Data[9]), .ADB12(scuba_vhi), 
        .ADB11(scuba_vlo), .ADB10(Address[7]), .ADB9(Address[6]), .ADB8(Address[5]), 
        .ADB7(Address[4]), .ADB6(Address[3]), .ADB5(Address[2]), .ADB4(Address[1]), 
        .ADB3(Address[0]), .ADB2(scuba_vlo), .ADB1(scuba_vlo), .ADB0(scuba_vhi), 
        .CEB(ClockEn), .OCEB(ClockEn), .CLKB(Clock), .WEB(WE), .CSB2(scuba_vlo), 
        .CSB1(scuba_vlo), .CSB0(scuba_vlo), .RSTB(Reset), .DOA8(Q[8]), .DOA7(Q[7]), 
        .DOA6(Q[6]), .DOA5(Q[5]), .DOA4(Q[4]), .DOA3(Q[3]), .DOA2(Q[2]), 
        .DOA1(Q[1]), .DOA0(Q[0]), .DOB8(), .DOB7(), .DOB6(Q[15]), .DOB5(Q[14]), 
        .DOB4(Q[13]), .DOB3(Q[12]), .DOB2(Q[11]), .DOB1(Q[10]), .DOB0(Q[9]))
             /* synthesis MEM_LPC_FILE="SamplePos_RAM.lpc" */
             /* synthesis MEM_INIT_FILE="sample_pos_lut_optimised.mem" */;



    // exemplar begin
    // exemplar attribute SamplePos_RAM_0_0_0 MEM_LPC_FILE SamplePos_RAM.lpc
    // exemplar attribute SamplePos_RAM_0_0_0 MEM_INIT_FILE sample_pos_lut_optimised.mem
    // exemplar end

endmodule
