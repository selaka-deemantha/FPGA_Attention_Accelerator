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
    clear_in        : in std_logic;


    d_out           : out signed(DATA_WIDTH - 1 downto 0);
    w_out           : out signed(DATA_WIDTH - 1 downto 0);
    clear_out       : out std_logic;

    acc_in          : in signed(ACC_WIDTH - 1 downto 0);
    acc_out         : out signed(ACC_WIDTH - 1 downto 0)

);

end entity;

architecture rtl of processing_element is

    signal acc_reg : signed(ACC_WIDTH - 1 downto 0) := (others => '0');
    signal acc_out_reg : signed(ACC_WIDTH -1 downto 0) := (others => '0');
    signal acc_valid : std_logic := '0';

begin

process(clk)
    variable product : signed(2*DATA_WIDTH-1 downto 0);
begin
    if rising_edge(clk) then


        if rst = '1' then

            acc_reg       <= (others => '0');

            d_out         <= (others => '0');
            w_out         <= (others => '0');


            acc_out_reg   <= (others => '0');
            clear_out     <= '0';
            acc_valid     <= '0';

        else

            d_out     <= d_in;
            w_out     <= w_in;
            clear_out <= clear_in;

            product := d_in * w_in;

            if clear_in = '1' then
                acc_out_reg <= acc_reg + resize(product, ACC_WIDTH);
                acc_reg <= (others => '0');
                acc_valid <= '1';
            else
                acc_reg <= acc_reg + resize(product, ACC_WIDTH);
                acc_valid <= '0';
            end if;
        end if;
    end if;
end process;

acc_out <= acc_out_reg when acc_valid = '1' else acc_in;


end architecture;


