    SamplePos_RAM u_SamplePos_RAM(.clk_i(clk_i),
        .rst_i(rst_i),
        .clk_en_i(clk_en_i),
        .wr_en_i(wr_en_i),
        .wr_data_i(wr_data_i),
        .addr_i(addr_i),
        .rd_data_o(rd_data_o));
