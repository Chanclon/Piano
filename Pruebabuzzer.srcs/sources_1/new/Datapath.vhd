library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity datapath is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        switches    : in  STD_LOGIC_VECTOR (3 downto 0);
        addr_en     : in  STD_LOGIC;
        we          : in  STD_LOGIC;
        play_mode   : in  STD_LOGIC;
        reset_ptr   : in  STD_LOGIC;
        
        audio_out   : out STD_LOGIC;
        mem_full    : out STD_LOGIC  -- SALIDA DE AVISO
    );
end datapath;

architecture Behavioral of datapath is
    type ram_type is array (0 to 63) of STD_LOGIC_VECTOR(3 downto 0);
    signal song_ram : ram_type := (others => (others => '0'));
    signal addr_ptr : unsigned(5 downto 0) := (others => '0');
    signal current_note : STD_LOGIC_VECTOR(3 downto 0);
    
    signal counter_freq : integer := 0;
    signal toggle_spkr  : std_logic := '0';
    signal period       : integer := 0;
begin

    -- Lógica del Puntero
    process(clk, reset)
    begin
        if reset = '1' then
            addr_ptr <= (others => '0');
        elsif rising_edge(clk) then
            if reset_ptr = '1' then
                addr_ptr <= (others => '0');
            elsif addr_en = '1' then
                addr_ptr <= addr_ptr + 1;
            end if;
        end if;
    end process;

    mem_full <= '1' when addr_ptr = 63 else '0'; 

    process(clk)
    begin
        if rising_edge(clk) then
            if we = '1' then
                song_ram(to_integer(addr_ptr)) <= switches;
            end if;
        end if;
    end process;

    current_note <= song_ram(to_integer(addr_ptr)) when play_mode = '1' else switches;

    
    process(current_note)
    begin
        case current_note is
            when "0001" => period <= 191113; 
            when "0010" => period <= 170262; 
            when "0011" => period <= 151686; 
            when "0100" => period <= 143173; 
            when "0101" => period <= 127553; 
            when "0110" => period <= 113636; 
            when "0111" => period <= 101239; 
            when "1000" => period <= 95556;  
            when "1001" => period <= 85131; 
            when "1010" => period <= 75843;  
            when "1011" => period <= 71586;  
            when "1100" => period <= 63776;  
            when "1101" => period <= 56818;  
            when "1110" => period <= 50619;  
            when "1111" => period <= 47778; 
            when others => period <= 0;      
        end case;
    end process;

    process(clk, reset)
    begin
        if reset = '1' then
            counter_freq <= 0;
            toggle_spkr <= '0';
        elsif rising_edge(clk) then
            if period > 0 then
                if counter_freq >= period then
                    toggle_spkr <= not toggle_spkr;
                    counter_freq <= 0;
                else
                    counter_freq <= counter_freq + 1;
                end if;
            else
                toggle_spkr <= '0';
                counter_freq <= 0;
            end if;
        end if;
    end process;
    
    audio_out <= toggle_spkr;

end Behavioral;