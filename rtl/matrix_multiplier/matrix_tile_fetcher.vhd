entity matrix_tile_fetcher is 
    generic (
        DATA_WIDTH :  integer := 16;
        ROWS       :  integer := 4;
        COLS       :  integer := 4;
        TILE_ROWS  :  integer := 2;
        TILE_COLS  :  integer := 2
    );

    port (
        clk : in std_logic;
        rst : in std_logic;
        start : in std_logic;

        data_out

    );


end entity;