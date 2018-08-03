library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity compression_function is
Port (

clk:    in std_logic;
rst:    in std_logic;
load:   in std_logic;
drdy:   out std_logic;
input:  in unsigned (31 downto 0);
output: out unsigned (255 downto 0)

 );
end compression_function;

architecture Behavioral of compression_function is

constant hh0: unsigned (31 downto 0):= X"6a09e667";
constant hh1: unsigned (31 downto 0):= X"bb67ae85";
constant hh2: unsigned (31 downto 0):= X"3c6ef372";
constant hh3: unsigned (31 downto 0):= X"a54ff53a";
constant hh4: unsigned (31 downto 0):= X"510e527f";
constant hh5: unsigned (31 downto 0):= X"9b05688c";
constant hh6: unsigned (31 downto 0):= X"1f83d9ab";
constant hh7: unsigned (31 downto 0):= X"5be0cd19";

signal a: unsigned (31 downto 0) := hh0;
signal b: unsigned (31 downto 0) := hh1;
signal c: unsigned (31 downto 0) := hh2;
signal d: unsigned (31 downto 0) := hh3;
signal e: unsigned (31 downto 0) := hh4;
signal f: unsigned (31 downto 0) := hh5;
signal g: unsigned (31 downto 0) := hh6;
signal h: unsigned (31 downto 0) := hh7;

signal h0: unsigned (31 downto 0):= hh0;
signal h1: unsigned (31 downto 0):= hh1;
signal h2: unsigned (31 downto 0):= hh2;
signal h3: unsigned (31 downto 0):= hh3;
signal h4: unsigned (31 downto 0):= hh4;
signal h5: unsigned (31 downto 0):= hh5;
signal h6: unsigned (31 downto 0):= hh6;
signal h7: unsigned (31 downto 0):= hh7;

signal digest_reg: unsigned (255 downto 0):= (others=>'0');
signal s1,s0,ch,maj: unsigned (31 downto 0);
signal count_enable: std_logic := '0';
signal count: integer range 0 to 63 := 0;
signal ready: std_logic := '0';
begin

process (clk,rst)
begin
    if rst = '1' then
    a <= hh0;
    b <= hh1;
    c <= hh2;
    d <= hh3;
    e <= hh4;
    f <= hh5;
    g <= hh6;
    h <= hh7;
    h0 <= hh0;
    h1 <= hh1;
    h2 <= hh2;
    h3 <= hh3;
    h4 <= hh4;
    h5 <= hh5;
    h6 <= hh6;
    h7 <= hh7;
    
    digest_reg <= (others=> '0');
    ready<= '0';
    elsif clk'event and clk = '1' then
        if load = '1' then
            count_enable <= '1';
            a <= (input + h + s1 + ch) + (s0 + maj);
            b <= a;
            c <= b;
            d <= c;
            e <= d + (input + h + s1 + ch);
            f <= e;
            g <= f;
            h <= g;
       end if;
       
       if count_enable = '1' then
        count<= count + 1;
       end if;
       if count = 63 then
            ready <= '1';
            h0<= h0+a;
            h1<= h1+b;
            h2<= h2+c;
            h3<= h3+d;
            h4<= h4+e;
            h5<= h5+f;
            h6<= h6+g;
            h7<= h7+h;
            digest_reg<= (h0+a) & (h1+b) & (h2+c) & (h3+d) & (h4+e) & (h5+f) & (h6+g) & (h7+h);
        elsif count >= 64 then
            ready <= '0';
            count<= 0;
            count_enable<='0';
            digest_reg<= (others=>'0');
        end if;              
    end if;
end process;

s0 <= rotate_right (a,2) XOR rotate_right (a,13) XOR rotate_right(a,22);
s1 <= rotate_right (e,6) XOR rotate_right (e,11) XOR rotate_right(e,25);
ch <= (e and f) xor ((not e) and g);
maj<= (a and b) xor (a and c) xor (b and c);

drdy<=ready;
--output<= h0 & h1 & h2 & h3 & h4 & h5 & h6 & h7;
output<= digest_reg;
end Behavioral;