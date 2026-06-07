library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity processing_element is

generic (
    DATA_WIDTH      : integer := 8;
    ACC_WIDTH       : integer := 32

);


port (
    clk             : in std_logic;
    rst             : in std_logic;

    d_in            : in signed(DATA_WIDTH - 1 downto 0);
    w_in            : in signed(DATA_WIDTH - 1 downto 0);
    last_in         : in std_logic;
    valid_in        : in std_logic;

    d_out           : out signed(DATA_WIDTH - 1 downto 0);
    w_out           : out signed(DATA_WIDTH - 1 downto 0);
    last_out        : out std_logic;
    valid_out       : out std_logic;

    acc_out         : out signed(ACC_WIDTH - 1 downto 0);
    acc_out_valid   : out std_logic


);


end entity;

architecture rtl of processing_element is

    signal acc_reg : signed(ACC_WIDTH - 1 downto 0) := (others => '0');

begin

process(clk)
    variable product : signed(2*DATA_WIDTH-1 downto 0);
begin
    if rising_edge(clk) then


        if rst = '1' then

            acc_reg       <= (others => '0');

            d_out         <= (others => '0');
            w_out         <= (others => '0');
            valid_out     <= '0';
            last_out      <= '0';

            acc_out       <= (others => '0');
            acc_out_valid <= '0';

        else

            d_out     <= d_in;
            w_out     <= w_in;
            valid_out <= valid_in;
            last_out  <= last_in;

            acc_out_valid <= '0';

            if valid_in = '1' then

                product := d_in * w_in;

                if last_in = '1' then

                    acc_out <= acc_reg + resize(product, ACC_WIDTH);
                    acc_out_valid <= '1';

                    acc_reg <= (others => '0');

                else
                    acc_reg <= acc_reg + resize(product, ACC_WIDTH);
                end if;

            end if;

        end if;
    end if;
end process;


end architecture;


