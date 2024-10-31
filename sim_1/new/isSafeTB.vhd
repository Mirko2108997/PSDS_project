library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sudoku_checker_tb is
end entity;

architecture test of sudoku_checker_tb is
    constant WIDTH : integer := 8;
    constant N : integer := 9;

    signal clk : std_logic := '0';
    signal reset : std_logic;
    signal grid_byte : std_logic_vector(WIDTH-1 downto 0);
    signal row : std_logic_vector(WIDTH-1 downto 0);
    signal col : std_logic_vector(WIDTH-1 downto 0);
    signal num : std_logic_vector(WIDTH-1 downto 0);
    signal safe : std_logic_vector(WIDTH-1 downto 0);

    component sudoku_checker
        generic (
            WIDTH: integer := WIDTH;
            N: integer := N
        );
        port (
            clk: in std_logic;
            reset: in std_logic;
            grid_byte: in std_logic_vector(WIDTH-1 downto 0);
            row: in std_logic_vector(WIDTH-1 downto 0);
            col: in std_logic_vector(WIDTH-1 downto 0);
            num: in std_logic_vector(WIDTH-1 downto 0);
            safe: out std_logic_vector(WIDTH-1 downto 0)
        );
    end component;

    type ByteArray is array (0 to 80) of std_logic_vector(WIDTH-1 downto 0);
    constant test_grid : ByteArray := (
    x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08", x"09",
    x"04", x"05", x"06", x"07", x"08", x"09", x"01", x"02", x"03",
    x"07", x"08", x"09", x"01", x"02", x"03", x"04", x"05", x"06",
    x"02", x"03", x"04", x"05", x"06", x"07", x"08", x"09", x"01",
    x"05", x"06", x"07", x"08", x"09", x"01", x"02", x"03", x"04",
    x"08", x"09", x"01", x"02", x"03", x"04", x"05", x"06", x"07",
    x"03", x"04", x"05", x"06", x"07", x"08", x"09", x"01", x"02",
    x"06", x"07", x"08", x"09", x"01", x"02", x"03", x"04", x"05",
    x"09", x"01", x"02", x"03", x"04", x"05", x"06", x"07", x"08"
    );

begin
    -- Clock generation
    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- DUT instantiation
    DUT: sudoku_checker
        generic map (
            WIDTH => WIDTH,
            N => N
        )
        port map (
            clk => clk,
            reset => reset,
            grid_byte => grid_byte,
            row => row,
            col => col,
            num => num,
            safe => safe
        );

    test_process : process
    begin
        -- Test 1: Reset and load grid
        reset <= '1';
        wait for 20 ns;
        reset <= '0';
        wait for 20 ns;
        
        -- Load grid data byte by byte
        for i in 0 to 80 loop
            grid_byte <= test_grid(i);
            wait for 20 ns;
        end loop;
        
        -- Test 2: Check for num in a column
        row <= "00000010";  
        col <= "00000001";  
        num <= x"10";        
        wait for 83*20 ns;

        assert safe = "00000010" report "Test 1 succes: num in column" severity warning;

        wait;
    end process;

end architecture;
