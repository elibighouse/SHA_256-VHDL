library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity compression_function is
Port (
    clk:    in  std_logic;
    rst:    in  std_logic;
    load:   in  std_logic;
    drdy:   out std_logic;
    input:  in  unsigned (31 downto 0);
    output: out unsigned (255 downto 0)
);
end compression_function;

architecture Behavioral of compression_function is
type MEM_8x32 is array (0 to 7) of unsigned(31 downto 0);

constant def_hash: MEM_8x32 := (X"6a09e667",X"bb67ae85",X"3c6ef372", X"a54ff53a", -- Valori di hash iniziali
                                X"510e527f",X"9b05688c",X"1f83d9ab",X"5be0cd19");

-- Registri di elaborazione
signal a: unsigned (31 downto 0) := def_hash(0);
signal b: unsigned (31 downto 0) := def_hash(1);
signal c: unsigned (31 downto 0) := def_hash(2);
signal d: unsigned (31 downto 0) := def_hash(3);
signal e: unsigned (31 downto 0) := def_hash(4);
signal f: unsigned (31 downto 0) := def_hash(5);
signal g: unsigned (31 downto 0) := def_hash(6);
signal h: unsigned (31 downto 0) := def_hash(7);
--
signal int_hash:        MEM_8x32                := def_hash;        -- Registri di hash intermedio
signal count_enable:    std_logic               := '0';             -- Avvio contatore di processamento
signal ready:           std_logic               := '0';             -- Segnale di data ready
signal count:           unsigned (5 downto 0)   := (others=>'0');   -- Contatore delle operazioni, verranno svolte 64 operazioni
signal digest_reg:      unsigned (255 downto 0) := (others=>'0');   -- Registro di uscita
signal s1,s0,ch,maj:    unsigned (31 downto 0);                     -- Reti logiche per la computazione degli hash

begin

process (clk,rst)
begin
    if rst = '1' then       
        a               <= def_hash(0); -- Reset asincrono: tutti i registri di lavoro vengono riportati ai valori di hash predefiniti o azzerati
        b               <= def_hash(1);
        c               <= def_hash(2);
        d               <= def_hash(3);
        e               <= def_hash(4);
        f               <= def_hash(5);
        g               <= def_hash(6);
        h               <= def_hash(7);
        int_hash        <= def_hash;
        ready           <= '0';
        count_enable    <= '0';
        count           <= (others=>'0');
        digest_reg      <= (others=>'0');
        
    elsif clk'event and clk = '1' then
        if load = '1' then                              -- Se c'è un blocco in ingresso
            count_enable <= '1';                        -- Avvia il contatore dal prossimo ciclo di clock;
            a <= (input + h + s1 + ch) + (s0 + maj);    -- Aggiornamento dei registri (come indicato da NIST FIPS 180-4)
            b <= a;                                     -- ad ogni ciclo di clock;
            c <= b;
            d <= c;
            e <= d + (input + h + s1 + ch);
            f <= e;
            g <= f;
            h <= g;
       end if;
       
        if count_enable = '1' then                      -- Se il contatore è attivo, incrementa il valore ad ogni
            count <= count + 1;                         -- ciclo di clock;
        end if;

       if count = 63 then                               -- Se il blocco è stato elaborato
            ready           <= '1';                     -- Attiva la segnalazione data ready
            count_enable    <= '0';                     -- Disattiva il contatore
            int_hash(0)     <= int_hash(0) + a;         -- Prepara i registri di lavoro ad un eventuale nuovo blocco
            int_hash(1)     <= int_hash(1) + b;
            int_hash(2)     <= int_hash(2) + c;
            int_hash(3)     <= int_hash(3) + d;
            int_hash(4)     <= int_hash(4) + e;
            int_hash(5)     <= int_hash(5) + f;
            int_hash(6)     <= int_hash(6) + g;
            int_hash(7)     <= int_hash(7) + h;
            a               <= int_hash(0) + a;
            b               <= int_hash(1) + b;
            c               <= int_hash(2) + c;
            d               <= int_hash(3) + d;
            e               <= int_hash(4) + e;
            f               <= int_hash(5) + f;
            g               <= int_hash(6) + g;
            h               <= int_hash(7) + h;

            digest_reg <=   (int_hash(0)+a) & (int_hash(1)+b) & (int_hash(2)+c) & (int_hash(3)+d)
                            & (int_hash(4)+e) & (int_hash(5)+f) & (int_hash(6)+g) & (int_hash(7)+h); -- Aggiorna gli hash
        else
            ready <= '0';   -- Il circuito non considera pronto il dato fino al termine del conteggio
        end if;              
    end if;
end process;

-- Definizioni delle funzioni wordwise usate nella compressione
s0  <= rotate_right (a,2) XOR rotate_right (a,13) XOR rotate_right(a,22);
s1  <= rotate_right (e,6) XOR rotate_right (e,11) XOR rotate_right(e,25);
ch  <= (e and f) xor ((not e) and g);
maj <= (a and b) xor (a and c) xor (b and c);

-- Assegnamento dei registri di data ready e digest ai rispettivi port
drdy    <= ready;
output  <= digest_reg;

end Behavioral;