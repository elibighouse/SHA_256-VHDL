library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity padding is
Port ( 
    clk:            in  std_logic;
    rst:            in  std_logic;
    enable:         in  std_logic;              -- '1' per il caricamento del messaggio (tenere alto)
    end_message:    in  std_logic;              -- '1' invia la coda (basta una pressione)
    input:          in  unsigned (7 downto 0);
    drdy:           out std_logic;
    sent:           out std_logic;              -- '1' se la coda è stata svuotata
    output:         out unsigned (31 downto 0)            
);
end padding;


architecture Behavioral of padding is
constant blocknum: natural := 9;                                                                -- Numero massimo di blocchi (bit messaggio massimo = blocknum * 448 - 8)
type message_array is array (0 to blocknum-1) of unsigned (511 downto 0);                       -- Array dove il messaggio verrà suddiviso in blocchi da 512 bit

signal padded_message:  message_array           := (('1',others=>'0'),others=>(others=>'0'));   -- Sarà il bit '1' annesso al messaggio
signal length:          unsigned (63 downto 0)  := (others=>'0');                               -- Lunghezza in bit del messaggio da inviare
signal count:           unsigned (5 downto 0)   := (others=>'0');                               -- Contatore di attesa
signal bytes:           unsigned (8 downto 0)   := (others=>'0');                               -- Contatore riempimento dell'ultimo blocco
signal bytes_sent:      unsigned (3 downto 0)   := (others=>'0');                               -- Contatore di byte inviati
signal output_enable:   std_logic               := '0';                                         -- Segnale di inizio fase di svuotamento del padder                                            --
signal wait_scheduler:  std_logic               := '0';                                         -- Segnale di attesa per la fine della'estensione del blocco
signal blocks:          unsigned (31 downto 0)  := (0=>'1',others=>'0');                        -- Contatore dei blocchi usati e da inviare

begin

PAD_MESSAGE: process (clk,rst)
begin
    if rst = '1' then
        padded_message  <= (('1',others=>'0'),others=>(others=>'0'));
        length          <= (others=>'0');
        bytes           <= (others=>'0');
        blocks          <= (0=>'1',others=>'0');
        output_enable   <= '0';
    elsif clk'event and clk = '1' then
        if enable = '1' then                    -- Durante il caricamento del messaggio
            output_enable   <= '0';
            count           <= (others=>'0');      
            length          <= length + 8;      -- Conta i byte in ingresso totali in formato bit
            bytes           <= bytes + 8;       -- Conta i byte in ingresso nell'ultimo blocco da inviare in formato bit
            
            if bytes = 440 then                 -- Se un blocco con dati ASCII ha più di 440 bit, verrà usato anche il blocco successivo, 
                blocks<= blocks+1;              -- infatti se si è qui si è arrivati a 448 bit di messaggio+padding
            end if;
                
            -- Shift di ingresso (8 bit alla volta)
            padded_message(0)<=input&padded_message(0)(511 downto 8);
            for I in 1 to blocknum-1 loop
                padded_message(I)<= padded_message(I-1)(7 downto 0) & padded_message(I)(511 downto 8); -- i primi 8 bit sono gli ultimi 8 del precedente
            end loop;
            --
        elsif end_message = '1' then
            if output_enable = '0' then                                                 -- Alla fine del messaggio entra nello stato di invio              
                output_enable                                       <= '1';
                bytes_sent                                          <= (others=>'0');
                padded_message(to_integer(blocks)-1) (63 downto 0)  <= length;          -- Inserimento di length nell'ultimo blocco inviato             
            end if;
            
        end if;
        
        if output_enable = '1' and blocks > 0 and wait_scheduler = '0' then -- Se ci sono blocchi da inviare e non si è in attesa 
            bytes_sent <= bytes_sent + 1;                                   -- Conta le word da 32 bit inviate ad ogni clock
            if bytes_sent = 15 then                                         -- Terminato un blocco metti in attesa
                blocks          <= blocks-1;
                wait_scheduler  <= '1';
            end if;
                          
            -- Shift di uscita (32 bit alla volta)
            for I in 0 to blocknum-2 loop
                padded_message(I) <= padded_message(I)(511-32 downto 0) & padded_message(I+1)(511 downto 512-32);
            end loop;
            padded_message(blocknum-1)<= padded_message(blocknum-1)(511-32 downto 0) & X"00000000";
            --
        end if;
        
        if wait_scheduler = '1' then                                        -- Dopo l'invio, viene attesa l'esecuzione della 
            count <= count+1;                                               -- estensione prima di inviare un altri blocchi
            if count = 48 then
                count           <= (others=>'0');
                wait_scheduler  <= '0';
            end if;
        end if;
        
        if blocks = 0 then                                                  -- Tutti i blocchi sono stati inviati, riporta il
            output_enable <= '0';                                           -- sistema in stato di ricezione (mantiene gli hash intermedi)
        end if;
                                 
    end if;
end process;

drdy    <= '1' when wait_scheduler = '0' and output_enable = '1' and blocks > 0 else '0';   -- Segnalazione per il circuito successivo
output  <= padded_message(0)(511 downto 512-32);
sent    <= '1' when blocks = 0 else '0';
end Behavioral;
