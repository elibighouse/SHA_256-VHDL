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
    clk:            in  std_logic;
    rst:            in  std_logic;
    enable:         in  std_logic;
    end_message:    in  std_logic;
    drdy:           out std_logic;
    input:          in  unsigned (7 downto 0);
    output:         out unsigned (255 downto 0)
 );
end component;

constant clk_period:                    time := 4 ps;
signal clk,rst,enable,drdy,end_message: std_logic;
signal input:                           unsigned (7 downto 0);
signal output:                          unsigned (255 downto 0);

-- TEST

---- "abc"
---- BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD
--constant msg_len : natural := 3;
--type message is array (msg_len-1 downto 0) of unsigned (7 downto 0);
--signal test: message := (X"61", X"62", X"63");

---- "The quick brown fox jumps over the lazy dog."
---- EF537F25C895BFA782526529A9B63D97AA631564D5D789C2B765448C8635FB6C
--constant msg_len : natural := 44;
--type message is array (msg_len-1 downto 0) of unsigned (7 downto 0);
--signal test: message := (X"54", X"68", X"65", X"20", X"71", X"75", X"69", X"63", X"6B", X"20", X"62", X"72", X"6F", X"77", X"6E", X"20", X"66", X"6F", X"78", X"20", X"6A", X"75", X"6D", X"70", X"73", X"20", X"6F", X"76", X"65", X"72", X"20", X"74", X"68", X"65", X"20", X"6C", X"61", X"7A", X"79", X"20", X"64", X"6F", X"67", X"2E");

---- "abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"
---- 248D6A61D20638B8E5C026930C3E6039A33CE45964FF2167F6ECEDD419DB06C1
--constant msg_len : natural := 56;
--type message is array (msg_len-1 downto 0) of unsigned (7 downto 0);
--signal test: message := (X"61", X"62", X"63", X"64", X"62", X"63", X"64", X"65", X"63", X"64", X"65", X"66", X"64", X"65", X"66", X"67", X"65", X"66", X"67", X"68", X"66", X"67", X"68", X"69", X"67", X"68", X"69", X"6A", X"68", X"69", X"6A", X"6B", X"69", X"6A", X"6B", X"6C", X"6A", X"6B", X"6C", X"6D", X"6B", X"6C", X"6D", X"6E", X"6C", X"6D", X"6E", X"6F", X"6D", X"6E", X"6F", X"70", X"6E", X"6F", X"70", X"71");

---- "What's in a name? That which we call a rose by any other name would smell as sweet"
---- EC0F4F302E26633DBB18155939B449417DA676F8A1A1EB8BA9DEFA88637A94D8
--constant msg_len : natural := 82;
--type message is array (msg_len-1 downto 0) of unsigned (7 downto 0);
--signal test: message := (X"57", X"68", X"61", X"74", X"27", X"73", X"20", X"69", X"6E", X"20", X"61", X"20", X"6E", X"61", X"6D", X"65", X"3F", X"20", X"54", X"68", X"61", X"74", X"20", X"77", X"68", X"69", X"63", X"68", X"20", X"77", X"65", X"20", X"63", X"61", X"6C", X"6C", X"20", X"61", X"20", X"72", X"6F", X"73", X"65", X"20", X"62", X"79", X"20", X"61", X"6E", X"79", X"20", X"6F", X"74", X"68", X"65", X"72", X"20", X"6E", X"61", X"6D", X"65", X"20", X"77", X"6F", X"75", X"6C", X"64", X"20", X"73", X"6D", X"65", X"6C", X"6C", X"20", X"61", X"73", X"20", X"73", X"77", X"65", X"65", X"74");

-- "Lorem ipsum dolor sit amet, consectetur adipisci elit, sed eiusmod tempor incidunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur. Quis aute iure reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint obcaecat cupiditat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum"
-- 14C39BC296402CDDECD3B1CBC0E8A0A7E2C19A86708B198B5AFB932AF66133B9
constant msg_len : natural := 451;
type message is array (msg_len-1 downto 0) of unsigned (7 downto 0);
signal test: message := (X"4C", X"6F", X"72", X"65", X"6D", X"20", X"69", X"70", X"73", X"75", X"6D", X"20", X"64", X"6F", X"6C", X"6F", X"72", X"20", X"73", X"69", X"74", X"20", X"61", X"6D", X"65", X"74", X"2C", X"20", X"63", X"6F", X"6E", X"73", X"65", X"63", X"74", X"65", X"74", X"75", X"72", X"20", X"61", X"64", X"69", X"70", X"69", X"73", X"63", X"69", X"20", X"65", X"6C", X"69", X"74", X"2C", X"20", X"73", X"65", X"64", X"20", X"65", X"69", X"75", X"73", X"6D", X"6F", X"64", X"20", X"74", X"65", X"6D", X"70", X"6F", X"72", X"20", X"69", X"6E", X"63", X"69", X"64", X"75", X"6E", X"74", X"20", X"75", X"74", X"20", X"6C", X"61", X"62", X"6F", X"72", X"65", X"20", X"65", X"74", X"20", X"64", X"6F", X"6C", X"6F", X"72", X"65", X"20", X"6D", X"61", X"67", X"6E", X"61", X"20", X"61", X"6C", X"69", X"71", X"75", X"61", X"2E", X"20", X"55", X"74", X"20", X"65", X"6E", X"69", X"6D", X"20", X"61", X"64", X"20", X"6D", X"69", X"6E", X"69", X"6D", X"20", X"76", X"65", X"6E", X"69", X"61", X"6D", X"2C", X"20", X"71", X"75", X"69", X"73", X"20", X"6E", X"6F", X"73", X"74", X"72", X"75", X"6D", X"20", X"65", X"78", X"65", X"72", X"63", X"69", X"74", X"61", X"74", X"69", X"6F", X"6E", X"65", X"6D", X"20", X"75", X"6C", X"6C", X"61", X"6D", X"20", X"63", X"6F", X"72", X"70", X"6F", X"72", X"69", X"73", X"20", X"73", X"75", X"73", X"63", X"69", X"70", X"69", X"74", X"20", X"6C", X"61", X"62", X"6F", X"72", X"69", X"6F", X"73", X"61", X"6D", X"2C", X"20", X"6E", X"69", X"73", X"69", X"20", X"75", X"74", X"20", X"61", X"6C", X"69", X"71", X"75", X"69", X"64", X"20", X"65", X"78", X"20", X"65", X"61", X"20", X"63", X"6F", X"6D", X"6D", X"6F", X"64", X"69", X"20", X"63", X"6F", X"6E", X"73", X"65", X"71", X"75", X"61", X"74", X"75", X"72", X"2E", X"20", X"51", X"75", X"69", X"73", X"20", X"61", X"75", X"74", X"65", X"20", X"69", X"75", X"72", X"65", X"20", X"72", X"65", X"70", X"72", X"65", X"68", X"65", X"6E", X"64", X"65", X"72", X"69", X"74", X"20", X"69", X"6E", X"20", X"76", X"6F", X"6C", X"75", X"70", X"74", X"61", X"74", X"65", X"20", X"76", X"65", X"6C", X"69", X"74", X"20", X"65", X"73", X"73", X"65", X"20", X"63", X"69", X"6C", X"6C", X"75", X"6D", X"20", X"64", X"6F", X"6C", X"6F", X"72", X"65", X"20", X"65", X"75", X"20", X"66", X"75", X"67", X"69", X"61", X"74", X"20", X"6E", X"75", X"6C", X"6C", X"61", X"20", X"70", X"61", X"72", X"69", X"61", X"74", X"75", X"72", X"2E", X"20", X"45", X"78", X"63", X"65", X"70", X"74", X"65", X"75", X"72", X"20", X"73", X"69", X"6E", X"74", X"20", X"6F", X"62", X"63", X"61", X"65", X"63", X"61", X"74", X"20", X"63", X"75", X"70", X"69", X"64", X"69", X"74", X"61", X"74", X"20", X"6E", X"6F", X"6E", X"20", X"70", X"72", X"6F", X"69", X"64", X"65", X"6E", X"74", X"2C", X"20", X"73", X"75", X"6E", X"74", X"20", X"69", X"6E", X"20", X"63", X"75", X"6C", X"70", X"61", X"20", X"71", X"75", X"69", X"20", X"6F", X"66", X"66", X"69", X"63", X"69", X"61", X"20", X"64", X"65", X"73", X"65", X"72", X"75", X"6E", X"74", X"20", X"6D", X"6F", X"6C", X"6C", X"69", X"74", X"20", X"61", X"6E", X"69", X"6D", X"20", X"69", X"64", X"20", X"65", X"73", X"74", X"20", X"6C", X"61", X"62", X"6F", X"72", X"75", X"6D");

signal I : natural := 0;
begin

--end_message <='1';                                  -- Test stringa vuota (commentare TB_IN): verrà inviato solo il segnale end_message
                                                    -- e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855
TEST_SHA256 : SHA256 port map (
    clk         => clk,
    rst         => rst,
    enable      => enable,
    end_message => end_message,
    drdy        => drdy,
    input       => input,
    output      => output
);

TB_IN: process(clk,rst)
begin
    if rst = '1' then                              -- Riavvia il test (verifica reset dei moduli)
        I <= 0;
        enable <= '0';
        end_message <= '0'; 
	elsif clk = '1' and clk'event then
	   if I <= msg_len-1 then                      -- Invia un nuovo carattere ad ogni nuovo colpo di clock
	       enable      <= '1';
	       input       <= test(I);
	       I           <= I + 1;
	   elsif I = msg_len then                      -- Alla fine dell'invio viene una pausa tra enable ed end_message 
	       enable      <= '0';                     
	       end_message <= '1' after 3 ps;
	   end if;
	   
	   if end_message = '1' and I = msg_len then   
	       end_message <= '0' after 3 ps;           -- Test pressione end_message (basta che sia abbastanza lunga per avviare l'uscita)
	       I<= msg_len + 1;
	   end if;  
	end if;
end process;

TB_clk: process
begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
end process;

rst <= '1', '0' after 3 ps;                        -- Reset prima di avviare il test

end Behavioral;
