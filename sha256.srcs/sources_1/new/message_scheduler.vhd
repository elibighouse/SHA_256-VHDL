library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity message_scheduler is
Port (
    load:   in std_logic;
    clk:    in std_logic;
    rst:    in std_logic;
    drdy:   out std_logic;
    input:  in unsigned (31 downto 0);
    output: out unsigned (31 downto 0) 
);
end message_scheduler;

architecture Behavioral of message_scheduler is
type reg32 is array (0 to 15) of unsigned (31 downto 0);
type table is array (0 to 63) of unsigned (31 downto 0);

signal k: table := 
( X"428a2f98", X"71374491", X"b5c0fbcf", X"e9b5dba5", X"3956c25b", X"59f111f1", X"923f82a4", X"ab1c5ed5",
  X"d807aa98", X"12835b01", X"243185be", X"550c7dc3", X"72be5d74", X"80deb1fe", X"9bdc06a7", X"c19bf174",
  X"e49b69c1", X"efbe4786", X"0fc19dc6", X"240ca1cc", X"2de92c6f", X"4a7484aa", X"5cb0a9dc", X"76f988da",
  X"983e5152", X"a831c66d", X"b00327c8", X"bf597fc7", X"c6e00bf3", X"d5a79147", X"06ca6351", X"14292967",
  X"27b70a85", X"2e1b2138", X"4d2c6dfc", X"53380d13", X"650a7354", X"766a0abb", X"81c2c92e", X"92722c85",
  X"a2bfe8a1", X"a81a664b", X"c24b8b70", X"c76c51a3", X"d192e819", X"d6990624", X"f40e3585", X"106aa070",
  X"19a4c116", X"1e376c08", X"2748774c", X"34b0bcb5", X"391c0cb3", X"4ed8aa4a", X"5b9cca4f", X"682e6ff3",
  X"748f82ee", X"78a5636f", X"84c87814", X"8cc70208", X"90befffa", X"a4506ceb", X"bef9a3f7", X"c67178f2"
  );
  
signal r:               reg32 := (others=> X"00000000");
signal count:           integer range 0 to 63 := 0 ;
signal count_enable:    std_logic := '0';
signal sigma0, sigma1:  unsigned (31 downto 0);
signal ready :          std_logic := '0';
begin

process (clk,rst)
begin
    if rst = '1' then
    r <= (others=> X"00000000");
    count_enable <= '0';
    count <= 0;
    
    elsif clk'event and clk = '1' then
        if load = '1' and ready = '0' then
            count_enable <= '1';
            ready <= '1';
        end if;
        
        if count_enable = '1' then
            count <= count + 1;
        end if;
        
        if load = '1' and count <= 16 then
            r(0)<= input;
        else
            r(0)<= sigma1 + r(6) + sigma0 + r(15);
        end if;
        
        if count >= 62 then
            count_enable <= '0';
        end if;
        
        if count >=63 then
            ready <= '0';
        end if;
        for I in 1 to 15 loop
            r(I)<=r(I-1);
        end loop;
        
        --output<=r(0);
    end if;
end process;

sigma0 <= rotate_right (r(14),7) XOR rotate_right (r(14),18) XOR shift_right(r(14),3);
sigma1 <= rotate_right (r(1),17) XOR rotate_right (r(1),19) XOR shift_right(r(1),10);
--drdy <= '1' when count >= 0 and count <=63 else '0';
drdy <= ready;
output<=r(0) + k(count);
end Behavioral;