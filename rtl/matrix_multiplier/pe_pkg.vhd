library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


package pe_pkg is 
    constant PE_SIZE_C          : integer := 4;
    constant DATA_WIDTH_D       : integer := 16;
    constant DATA_WIDTH_W       : integer := 16;
    constant DATA_WIDTH_ACC     : integer := 32;

    type data_array             is array (PE_SIZE_C - 1 downto 0) of signed(DATA_WIDTH_D - 1 downto 0);
    type weight_array           is array (PE_SIZE_C - 1 downto 0) of signed(DATA_WIDTH_W - 1 downto 0);
    type acc_array              is array (PE_SIZE_C - 1 downto 0) of signed(DATA_WIDTH_ACC - 1 downto 0);



end package