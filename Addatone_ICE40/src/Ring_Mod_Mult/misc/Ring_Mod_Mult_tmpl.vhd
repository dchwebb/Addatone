component Ring_Mod_Mult is
    port(
        clk_i: in std_logic;
        clk_en_i: in std_logic;
        rst_i: in std_logic;
        data_a_i: in std_logic_vector(19 downto 0);
        data_b_i: in std_logic_vector(19 downto 0);
        result_o: out std_logic_vector(39 downto 0)
    );
end component;

__: Ring_Mod_Mult port map(
    clk_i=>,
    clk_en_i=>,
    rst_i=>,
    data_a_i=>,
    data_b_i=>,
    result_o=>
);
