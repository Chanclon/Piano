library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity controller is
    Port (
        clk         : in  STD_LOGIC;
        reset       : in  STD_LOGIC;
        btn_record  : in  STD_LOGIC;
        btn_play    : in  STD_LOGIC;
        btn_stop    : in  STD_LOGIC;
        
        mem_full    : in  STD_LOGIC;
        
        addr_en     : out STD_LOGIC;
        we          : out STD_LOGIC;
        play_mode   : out STD_LOGIC;
        reset_ptr   : out STD_LOGIC;
        led_status  : out STD_LOGIC_VECTOR(1 downto 0)
    );
end controller;

architecture Behavioral of controller is
    type state_type is (IDLE, RECORDING, PLAYBACK);
    signal state, next_state : state_type;
    constant TEMPO_LIMIT : integer := 25000000; 
    signal tempo_cnt : integer := 0;
    signal tempo_pulse : std_logic := '0';
begin

    -- Generador de Ritmo
    process(clk, reset)
    begin
        if reset = '1' then
            tempo_cnt <= 0;
            tempo_pulse <= '0';
        elsif rising_edge(clk) then
            if state = RECORDING or state = PLAYBACK then
                if tempo_cnt >= TEMPO_LIMIT then
                    tempo_cnt <= 0;
                    tempo_pulse <= '1';
                else
                    tempo_cnt <= tempo_cnt + 1;
                    tempo_pulse <= '0';
                end if;
            else
                tempo_cnt <= 0;
                tempo_pulse <= '0';
            end if;
        end if;
    end process;

    -- Registro de Estado
    process(clk, reset)
    begin
        if reset = '1' then
            state <= IDLE;
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
    end process;

    -- Lógica de Estado
    process(state, btn_record, btn_play, btn_stop, mem_full,tempo_pulse )
    begin
        next_state <= state;
        we <= '0';
        play_mode <= '0';
        addr_en <= '0';
        reset_ptr <= '0';
        led_status <= "00";

        case state is
            when IDLE =>
                reset_ptr <= '1';
                if btn_record = '1' then
                    next_state <= RECORDING;
                elsif btn_play = '1' then
                    next_state <= PLAYBACK;
                end if;

            when RECORDING =>
                led_status <= "01";
                we <= '1';
                
                -- Aquí está la lógica de control:
                -- Si el datapath dice mem_full='1', nos vamos a IDLE
                if mem_full = '1' or btn_stop = '1' then
                    next_state <= IDLE;
                elsif tempo_pulse = '1' then
                    addr_en <= '1';
                end if;

            when PLAYBACK =>
                led_status <= "10";
                play_mode <= '1';

                -- También paramos reproducción si llega al final
                if mem_full = '1' or btn_stop = '1' then
                    next_state <= IDLE;
                elsif tempo_pulse = '1' then
                    addr_en <= '1';
                end if;
        end case;
    end process;
end Behavioral;