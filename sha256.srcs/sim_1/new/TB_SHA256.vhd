library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity TB_SHA256 is
--  Port ( );
end TB_SHA256;

architecture Behavioral of TB_SHA256 is

component SHA256 is
Port (
    clk:    in std_logic;
    rst:    in std_logic;
    load:   in std_logic;
    drdy:   out std_logic;
    input:  in unsigned (31 downto 0);
    output: out unsigned (255 downto 0)
 );
end component;
type test is array (0 to 15) of unsigned (31 downto 0);

signal clk,rst : std_logic;
signal load,drdy: std_logic := '0';
signal input : unsigned (31 downto 0);
signal output: unsigned (255 downto 0);

signal message: test := (0=>X"61626380",15=> X"00000018",others => X"00000000");
signal I : natural := 0;
begin

TEST_SHA256 : SHA256 port map (
    clk     => clk,
    rst     => rst,
    load    => load,
    drdy    => drdy,
    input   => input,
    output  => output
);

TB_input:process (clk)
begin
    if clk'event and clk = '1' then
        if I<=15 then
            load <= '1';
            input<=message(I);
            I<=I+1;
        else
            load <= '0';
        end if;
    end if;
end process;

TB_clk: process
begin
    clk <= '0';
    wait for 2 ps;
    clk <= '1';
    wait for 2 ps;
end process;

rst<='0';
--rst <= '1', '0' after 2 ps;

end Behavioral;
