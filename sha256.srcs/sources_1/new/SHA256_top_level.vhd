library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity SHA256 is
Port (
    clk:            in  std_logic;
    rst:            in  std_logic;
    enable:         in  std_logic;
    end_message:    in  std_logic;
    drdy:           out std_logic;
    input:          in  unsigned (7 downto 0);
    output:         out unsigned (255 downto 0)
 );
end SHA256;

architecture Structural of SHA256 is

component padding is
Port ( 
    clk:            in  std_logic;
    rst:            in  std_logic;
    enable:         in  std_logic;
    end_message:    in  std_logic;
    input:          in  unsigned (7 downto 0);
    drdy:           out std_logic; 
    sent:           out std_logic;
    output:         out unsigned (31 downto 0)            
);
end component;

component message_scheduler is
Port (
    load:   in  std_logic;
    clk:    in  std_logic;
    rst:    in  std_logic;
    drdy:   out std_logic;
    input:  in  unsigned (31 downto 0);
    output: out unsigned (31 downto 0) 
);
end component;

component compression_function is
Port (
    clk:    in  std_logic;
    rst:    in  std_logic;
    load:   in  std_logic;
    drdy:   out std_logic;
    input:  in  unsigned (31 downto 0);
    output: out unsigned (255 downto 0)
);
end component;

signal message_sent:                    std_logic;
signal compression_done:                std_logic;
signal drdy_to_load_message_scheduler:  std_logic;
signal drdy_to_load:                    std_logic;

signal input_compression:               unsigned (31 downto 0);
signal input_message_scheduler:         unsigned (31 downto 0);

begin

PADDER_BLOCK: padding port map (
    clk         => clk,
    rst         => rst,
    enable      => enable,
    end_message => end_message,
    input       => input,
    drdy        => drdy_to_load_message_scheduler, 
    sent        => message_sent,
    output      => input_message_scheduler         

);

MSG_SCHEDULER: message_scheduler port map (
    clk     => clk,
    rst     => rst,
    load    => drdy_to_load_message_scheduler,
    input   => input_message_scheduler,
    drdy    => drdy_to_load,
    output  => input_compression
);

COMPRESSION_FUNC: compression_function port map (
    clk     => clk,
    rst     => rst,
    load    => drdy_to_load,
    input   => input_compression,
    drdy    => compression_done,
    output  => output
);

drdy <= message_sent and compression_done;
end Structural;