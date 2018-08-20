library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use STD.TEXTIO.ALL;

entity TB_SHA256_File is
--  Port ( );
end TB_SHA256_File;

architecture Behavioral of TB_SHA256_File is

component SHA256 is
Port (
    clk:            in  std_logic;
    rst:            in  std_logic;
    enable:         in  std_logic;
    end_message:    in  std_logic;
    drdy:           out std_logic;
    input:          in  unsigned (7 downto 0);
    output:         out unsigned (255 downto 0)
 );
end component;

constant clk_period:                    time        := 4 ps;
constant input_filepath:                string      := "tb_in.txt";
constant output_filepath:               string      := "C:\Users\marco\Documents\GitHub\SHA_256-VHDL\sha256.srcs\sim_1\imports\tb_out.txt";
--constant input_filepath:                string      := "C:\Users\marco\Documents\GitHub\SHA_256-VHDL\sha256.srcs\sim_1\imports\tb_in.txt";
--constant output_filepath:               string      := "tb_out.txt";  -- ??

signal clk,rst,enable,drdy,end_message: std_logic   := '0';
signal input:                           unsigned (7 downto 0);
signal output:                          unsigned (255 downto 0);

begin

TEST_SHA256 : SHA256 port map (
    clk         => clk,
    rst         => rst,
    enable      => enable,
    end_message => end_message,
    drdy        => drdy,
    input       => input,
    output      => output
);

TB_IN: process
file input_file:        text open read_mode is input_filepath;
variable input_line:    LINE;
begin 
    if not (endfile(input_file)) then                               -- Esegue se il file non è vuoto
        end_message <= '0';
        enable      <= '0','1' after 2 ps;
        readline(input_file, input_line);
        for i in input_line'length downto 1 loop
            input   <= to_unsigned(character'pos(input_line(i)),8);
            wait for clk_period;
        end loop;
    end if;
        
    enable      <= '0';
    end_message <= '1', '0' after 3 ps ;
    wait;                                                           -- Viene eseguito solo una volta
end process;

TB_OUT: process (drdy)
file output_file:       text open write_mode is output_filepath;
variable output_line:   LINE;
begin
    if drdy = '1' then
        hwrite (output_line,std_logic_vector(output));
        writeline (output_file,output_line);
    end if;
end process;

TB_CLK: process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;

end Behavioral;