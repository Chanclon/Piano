library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity MusicSystem_top is
    Port (
        clk     : in STD_LOGIC;
        btnC    : in STD_LOGIC; 
        btnU    : in STD_LOGIC; 
        btnL    : in STD_LOGIC; 
        btnD    : in STD_LOGIC; 
        sw      : in STD_LOGIC_VECTOR (3 downto 0);
        led     : out STD_LOGIC_VECTOR (1 downto 0); 
        JA      : out STD_LOGIC_VECTOR (0 downto 0)
    );
end MusicSystem_top;

architecture Behavioral of MusicSystem_top is

    signal reset_int : std_logic;
    signal s_addr_en, s_we, s_play_mode, s_reset_ptr : std_logic;
    signal s_audio : std_logic;
    
    signal s_mem_full : std_logic; 

    component controller
    Port (
        clk, reset, btn_record, btn_play, btn_stop : in STD_LOGIC;
        mem_full : in STD_LOGIC; 
        addr_en, we, play_mode, reset_ptr : out STD_LOGIC;
        led_status : out STD_LOGIC_VECTOR(1 downto 0)
    );
    end component;

    component datapath
    Port (
        clk, reset : in STD_LOGIC;
        switches : in STD_LOGIC_VECTOR(3 downto 0);
        addr_en, we, play_mode, reset_ptr : in STD_LOGIC;
        audio_out : out STD_LOGIC;
        mem_full : out STD_LOGIC 
    );
    end component;

begin
    reset_int <= btnC;

    -- Conectamos el controlador
    U_CTRL: controller Port Map (
        clk => clk,
        reset => reset_int,
        btn_record => btnU,
        btn_play => btnL,
        btn_stop => btnD,
        mem_full => s_mem_full, 
        addr_en => s_addr_en,
        we => s_we,
        play_mode => s_play_mode,
        reset_ptr => s_reset_ptr,
        led_status => led
    );

    -- Conectamos el datapath
    U_PATH: datapath Port Map (
        clk => clk,
        reset => reset_int,
        switches => sw,
        addr_en => s_addr_en,
        we => s_we,
        play_mode => s_play_mode,
        reset_ptr => s_reset_ptr,
        audio_out => s_audio,
        mem_full => s_mem_full 
    );

    JA(0) <= s_audio; 

end Behavioral;