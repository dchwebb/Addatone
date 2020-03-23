component Sine_LUT is
    port(
        rd_clk_i: in std_logic;
        rst_i: in std_logic;
        rd_en_i: in std_logic;
        rd_clk_en_i: in std_logic;
        rd_addr_i: in std_logic_vector(10 downto 0);
        rd_data_o: out std_logic_vector(15 downto 0)
    );
end component;

__: Sine_LUT port map(
    rd_clk_i=>,
    rst_i=>,
    rd_en_i=>,
    rd_clk_en_i=>,
    rd_addr_i=>,
    rd_data_o=>
);
