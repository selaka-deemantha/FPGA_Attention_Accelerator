library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pe_pkg.all;


entity pe_array_2D is
    generic (
        PE_SIZE             : integer := PE_SIZE_C;
        DATA_WIDTH          : integer := DATA_WIDTH_D;
        ACC_WIDTH           : integer := DATA_WIDTH_ACC
    );

    port (
        clk                 : in std_logic;
        rst                 : in std_logic;

        d_in                : in data_array;

        w_in                : in weight_array;

        clear_in            : in std_logic_vector(PE_SIZE-1 downto 0);

        acc_out             : out acc_array;
        acc_out_valid       : out std_logic_vector(PE_SIZE-1 downto 0)
    );
end entity;


architecture rtl of pe_array_2D is

    -- 2D interconnects
    type data_matrix_t is array (0 to PE_SIZE, 0 to PE_SIZE-1) of signed(DATA_WIDTH-1 downto 0);

    type acc_matrix_t is array (0 to PE_SIZE-1, 0 to PE_SIZE-1) of signed(ACC_WIDTH-1 downto 0);

    type pe_logic_matrix_t is array (0 to PE_SIZE-1, 0 to PE_SIZE-1) of std_logic;


    signal d_bus            : data_matrix_t;
    signal w_bus            : data_matrix_t;

    signal clear_bus        : pe_logic_matrix_t;

    signal acc_bus          : acc_matrix_t;
    signal acc_v_bus        : pe_logic_matrix_t;

begin

-- left edge and top edge

gen_inject_d : for i in 0 to PE_SIZE - 1 generate
begin

    d_bus(i,0)              <= d_in(i);
    v_bus(i,0)              <= v_bus(i);


end generate;

-- PE array

gen_row : for i in 0 to PE_SIZE - 1 generate
    gen_col : for j in 0 to PE_SIZE - 1 generate
        pe_inst : entity work.processing_element 
        generic map (
            DATA_WIDTH      => DATA_WIDTH,
            ACC_WIDTH       => ACC_WIDTH
        )
        port (
            clk             => clk,
            rst             => rst,

            d_in            => d_bus(i,j);
            d_out           => d_bus(i,j+1);

            w_in            => w_bus(i,j);
            w_out           => w_bus(i+1,j);

            valid_in        => v_bus(i,j);
            valid_out       => v_bus(i,j+1);

            last_in         => l_bus(i,j);
            last_out        => l_bus(i,j+1);

            acc_out         => acc_bus(i,j);
            acc_out_valid   => acc_v_bus(i,j);

        );
        
    end generate;
end generate;

process (clk) 
begin
    if rising_edge(clk) then





    end if


end process;


