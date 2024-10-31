library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sudoku_checker is
    generic (
        WIDTH: integer := 8;  -- Width of each byte
        N: integer := 9       -- Size of the Sudoku grid (9x9)
    );
    port (
        clk: in std_logic;
        reset: in std_logic;
        grid_byte: in std_logic_vector(WIDTH-1 downto 0);  -- Single 8-bit input for grid data
        row: in std_logic_vector(WIDTH-1 downto 0);  -- Row index (1 byte)
        col: in std_logic_vector(WIDTH-1 downto 0);  -- Column index (1 byte)
        num: in std_logic_vector(WIDTH-1 downto 0);  -- Number to check (1 byte)
        safe: out std_logic_vector(WIDTH-1 downto 0)  -- Output status
    );
end entity;

architecture behavior of sudoku_checker is
    type state_type is (idle, load_grid, check_row, check_col, check_submatrix, done);
    signal state_reg, state_next: state_type;

    type ByteArray is array (0 to 80) of std_logic_vector(WIDTH-1 downto 0);
    signal internal_array_r, internal_array_nxt : ByteArray;
    signal index_r, index_nxt: unsigned(6 downto 0) := (others => '0');
    signal i_reg, i_nxt, j_reg, j_nxt: unsigned(WIDTH-1 downto 0) := (others => '0');

    signal safe_temp_r, safe_temp_nxt: std_logic_vector(WIDTH-1 downto 0) := (others => '0');

begin
    process (clk, reset)
    begin
        if reset = '1' then
            state_reg <= idle;
            index_r <= (others => '0');
            i_reg <= (others => '0');
            j_reg <= (others => '0');
            safe_temp_r <= (others => '0');
            for i in 0 to 80 loop
                internal_array_r(i) <= (others => '0');
            end loop;
        elsif rising_edge(clk) then
            state_reg <= state_next;
            i_reg <= i_nxt;
            j_reg <= j_nxt;
            safe_temp_r <= safe_temp_nxt;
            index_r <= index_nxt;
            for i in 0 to 80 loop
                internal_array_r(i) <= internal_array_nxt(i);
            end loop;

        end if;
    end process;

    -- Next state logic and transition
    process (state_reg, index_r, i_reg, row, num, col, j_reg, grid_byte, internal_array_r)
    begin
        state_next <= state_reg;
        safe_temp_nxt <= (others => '0');
        i_nxt <= i_reg;
        j_nxt <= j_reg;
        internal_array_nxt <= internal_array_r;
        index_nxt <= index_r;
        case state_reg is
            when idle =>
            
                if index_r = 0 then
                    state_next <= load_grid;
                end if;
                
            when load_grid =>
                if index_r < 80 then
                    internal_array_nxt(to_integer(index_r)) <= grid_byte;
                    index_nxt <= index_r + 1;
                    state_next <= load_grid;
                end if;
            
                if index_r >= 80 then
                    report "GRID LOADED" severity warning;
                    state_next <= check_row;
                end if;

            when check_row =>
            report "Test 2 failed: num in row" severity warning;
                if i_reg < to_unsigned(N-1, WIDTH) then
                    if internal_array_r(to_integer(unsigned(row)) * N + to_integer(i_reg)) = num then
                        safe_temp_nxt <= "00000010";
                        state_next <= done;
                    else
                        i_nxt <= i_reg + 1;
                    end if;
                else
                    i_nxt <= (others => '0');
                    state_next <= check_col;
                end if;

            when check_col =>
                if i_reg < to_unsigned(N-1, WIDTH) then
                    if internal_array_r(to_integer(i_reg) * N + to_integer(unsigned(col))) = num then
                        safe_temp_nxt <= "00000010";
                        state_next <= done;
                    else
                        i_nxt <= i_reg + 1;
                    end if;
                else
                    i_nxt <= (others => '0');
                    j_nxt <= (others => '0');
                    state_next <= check_submatrix;
                end if;

            when check_submatrix =>
                if i_reg < to_unsigned(2, WIDTH) then
                    if j_reg < to_unsigned(2, WIDTH) then
                        if internal_array_r((to_integer(unsigned(row))/3*3 + to_integer(i_reg)) * N +
                                           (to_integer(unsigned(col))/3*3 + to_integer(j_reg))) = num then
                            safe_temp_nxt <= "00000010";
                            state_next <= done;
                        else
                            j_nxt <= j_reg + 1;
                        end if;
                    else
                        i_nxt <= i_reg + 1;
                        j_nxt <= (others => '0');
                    end if;
                else
                    state_next <= done;
                end if;

            when done =>
                state_next <= idle;
                index_nxt <= to_unsigned(0,7);
                i_nxt <= to_unsigned(0,WIDTH);
                j_nxt <= to_unsigned(0,WIDTH);
            when others =>
                state_next <= idle;
        end case;
    end process;

    safe <= safe_temp_r when state_reg = done else (others => '0');

end architecture behavior;