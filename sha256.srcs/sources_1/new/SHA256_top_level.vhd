library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SHA256 is
Port (
    clk:    in std_logic;
    rst:    in std_logic;
    load:   in std_logic;
    drdy:   out std_logic;
    input:  in unsigned (31 downto 0);
    output: out unsigned (255 downto 0)
 );
end SHA256;

architecture Structural of SHA256 is

component message_scheduler is
Port (
    load:   in std_logic;
    clk:    in std_logic;
    rst:    in std_logic;
    drdy:   out std_logic;
    input:  in unsigned (31 downto 0);
    output: out unsigned (31 downto 0) 
);
end component;

component compression_function is
Port (
    clk:    in std_logic;
    rst:    in std_logic;
    load:   in std_logic;
    drdy:   out std_logic;
    input:  in unsigned (31 downto 0);
    output: out unsigned (255 downto 0)
);
end component;

-- msg
signal input_compression: unsigned (31 downto 0);
signal drdy_to_load: std_logic;

begin

MSG_SCHEDULER: message_scheduler port map (
    clk=>clk,
    rst=>rst,
    load=>load,
    input=>input,
    drdy=>drdy_to_load,
    output=>input_compression
);

COMPRESSION_FUNC: compression_function port map (
    clk=>clk,
    rst=>rst,
    load=>drdy_to_load,
    input=>input_compression,
    drdy=>drdy,
    output=>output
);

end Structural;