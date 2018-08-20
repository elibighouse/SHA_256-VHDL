library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity message_scheduler is
Port (
    load:   in  std_logic;
    clk:    in  std_logic;
    rst:    in  std_logic;
    drdy:   out std_logic;
    input:  in  unsigned (31 downto 0);
    output: out unsigned (31 downto 0) 
);
end message_scheduler;

architecture Behavioral of message_scheduler is
type reg32 is array (0 to 15) of unsigned (31 downto 0);
type table is array (0 to 63) of unsigned (31 downto 0);

-- Costanti descritte in NIST FIPS-180-4
constant k: table :=
(   X"428a2f98", X"71374491", X"b5c0fbcf", X"e9b5dba5", X"3956c25b", X"59f111f1", X"923f82a4", X"ab1c5ed5",
    X"d807aa98", X"12835b01", X"243185be", X"550c7dc3", X"72be5d74", X"80deb1fe", X"9bdc06a7", X"c19bf174",
    X"e49b69c1", X"efbe4786", X"0fc19dc6", X"240ca1cc", X"2de92c6f", X"4a7484aa", X"5cb0a9dc", X"76f988da",
    X"983e5152", X"a831c66d", X"b00327c8", X"bf597fc7", X"c6e00bf3", X"d5a79147", X"06ca6351", X"14292967",
    X"27b70a85", X"2e1b2138", X"4d2c6dfc", X"53380d13", X"650a7354", X"766a0abb", X"81c2c92e", X"92722c85",
    X"a2bfe8a1", X"a81a664b", X"c24b8b70", X"c76c51a3", X"d192e819", X"d6990624", X"f40e3585", X"106aa070",
    X"19a4c116", X"1e376c08", X"2748774c", X"34b0bcb5", X"391c0cb3", X"4ed8aa4a", X"5b9cca4f", X"682e6ff3",
    X"748f82ee", X"78a5636f", X"84c87814", X"8cc70208", X"90befffa", X"a4506ceb", X"bef9a3f7", X"c67178f2");

signal sigma0, sigma1:  unsigned (31 downto 0);                             -- Reti logiche per il parsing
signal r:               reg32                   := (others=>(others=>'0')); -- Serie di shift register da 32 bit
signal count:           unsigned (5 downto 0)   := (others=>'0');           -- Contatore di shift
signal count_enable:    std_logic               := '0';                     -- Enable per il contatore di shift
signal ready:           std_logic               := '0';                     -- Segnale di data ready per il circuito successivo

begin

process (clk,rst)
begin
    if rst = '1' then                               -- Reset asincrono
    r               <= (others=>(others=>'0')); 
    count_enable    <= '0';
    count           <= (others=>'0');
    
    elsif clk'event and clk = '1' then
        if load = '1' then                          -- Se c'è un blocco in caricamento
            if ready = '0' then                     -- Dal prossimo ciclo di clock inizia ad inviare dati e inizia a contare
                count_enable    <= '1';
                ready           <= '1';
            end if;
            r(0) <= input;                          -- Inserisci l'input nello shift register più a sinistra
        else
            r(0) <= sigma1 + r(6) + sigma0 + r(15); -- Altrimenti, quando nella catena sono presenti tutte le 16 word del blocco,
        end if;                                     -- per 48 cicli verrà eseguita l'estensione a 2048 bit
        
        for I in 1 to 15 loop                       -- Ad ogni ciclo di clock avviene uno shift a destra delle word
            r(I) <= r(I-1);
        end loop;
        
        if count_enable = '1' then                  -- Se il contatore è attivo, incrementa il conteggio
            count <= count + 1;
        end if;
                        
        if count = 63 then                          -- Tutte le operazioni sono state svolte. Da qui count tornerà a 0 (fermandosi)
            ready           <= '0';                 -- e non verranno forniti nuovi dati al blocco di compressione
            count_enable    <= '0';
        end if;
    end if;
end process;

drdy    <= ready;                                   -- Collegamento del segnale di data ready al suo port
output  <= r(0) + k(to_integer(count));             -- Somma delle word in uscita con la costante corrispondente

-- Definizione delle reti logiche
sigma0  <= rotate_right (r(14),7) XOR rotate_right (r(14),18) XOR shift_right(r(14),3);
sigma1  <= rotate_right (r(1),17) XOR rotate_right (r(1),19) XOR shift_right(r(1),10);
end Behavioral;
