library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity shift_register is
    port(
        i_clk : in std_logic;
        i_rst: in std_logic;
        i_start: in std_logic;
        i_w: in std_logic;
        i_we: in std_logic;
        o_addr: out std_logic_vector(15 downto 0)
        );
end shift_register;

architecture shift_register_arch of shift_register is
    signal addr: std_logic_vector(15 downto 0);
begin
    o_addr <= addr;
    port_memory_process: process(i_clk,i_rst)
    begin
        if i_clk'event AND i_clk = '1' then
            if i_rst = '1' then
                addr <= "0000000000000000";
            elsif i_we = '1' AND i_start = '1' then
                addr <= addr(14 downto 0) & i_w;
            end if;
        end if;
    end process;
end shift_register_arch;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity output_register is
    port(
        i_clk : in std_logic;
        i_rst: in std_logic;
        i_we: in std_logic;
        i_port: in std_logic_vector(1 downto 0);
        i_data: in std_logic_vector(7 downto 0);
        i_done: in std_logic;
        o_z0: out std_logic_vector(7 downto 0);
        o_z1: out std_logic_vector(7 downto 0);
        o_z2: out std_logic_vector(7 downto 0);
        o_z3: out std_logic_vector(7 downto 0);
        o_done: out std_logic
        );
end output_register;

architecture output_register_arch of output_register is
    signal done_mask: std_logic_vector(7 downto 0);
    signal mem_z0: std_logic_vector(7 downto 0);
    signal mem_z1: std_logic_vector(7 downto 0);
    signal mem_z2: std_logic_vector(7 downto 0);
    signal mem_z3: std_logic_vector(7 downto 0);
begin
    o_done <= i_done;
    done_mask <= i_done & i_done & i_done & i_done & i_done & i_done & i_done & i_done;
    o_z0 <= mem_z0 AND done_mask;
    o_z1 <= mem_z1 AND done_mask;
    o_z2 <= mem_z2 AND done_mask;
    o_z3 <= mem_z3 AND done_mask; 
    
    memory_process: process(i_clk,i_rst)
    begin
        if i_rst = '1' then
            mem_z0 <= "00000000";
            mem_z1 <= "00000000";
            mem_z2 <= "00000000";
            mem_z3 <= "00000000";
        elsif i_clk'event AND i_clk = '1' then
            if i_we = '1' then
                case i_port is
                    when "00" => mem_z0 <= i_data;
                    when "01" => mem_z1 <= i_data;
                    when "10" => mem_z2 <= i_data;
                    when "11" => mem_z3 <= i_data;
                    when others => NULL;
                end case;
            end if;
        end if;
    end process;
end output_register_arch;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fsm_register is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_w : in std_logic;
        o_port: out std_logic_vector(1 downto 0);
        o_done : out std_logic :='0';
        o_mem_we : out std_logic :='0';
        o_mem_en : out std_logic :='0';
        o_out_we : out std_logic :='0';
        o_shift_rst : out std_logic :='0';
        o_shift_we : out std_logic
        );
end fsm_register;

architecture fsm_register_arch of fsm_register is
    type S is ( WAIT_START , READ_PORT , READ_ADDRESS , ENABLE_MEMORY , WAIT_MEMORY , SAVE_DATA , PRINT_OUTPUT );
    signal state: S;
begin
    o_mem_we <= '0';
    
    fsm_process: process(i_clk,i_rst)
    begin
        if i_rst = '1' then
            state <= WAIT_START;
            o_done <= '0';
            o_mem_en <= '0';
            o_out_we <= '0';
            o_shift_rst <= '0';
            o_shift_we <= '0';
        elsif i_clk'event AND i_clk = '1' then
            case state is
                when WAIT_START =>
                    case i_start is
                        when '1' => 
                            state <= READ_PORT;
                            o_port(1) <= i_w;
                            o_shift_rst <= '1';
                        when others => NULL;
                    end case;
                when READ_PORT =>
                    state <= READ_ADDRESS;
                    o_port(0) <= i_w;
                    o_shift_rst <= '0';
                    o_shift_we <= '1';
                when READ_ADDRESS =>
                    case i_start is
                        when '0' => 
                            state <= ENABLE_MEMORY;
                            o_mem_en <= '1';
                            o_shift_we <= '0';
                        when others => NULL;
                    end case;
                when ENABLE_MEMORY =>
                    state <= WAIT_MEMORY;
                    o_out_we <= '1';
                when WAIT_MEMORY =>
                    state <= SAVE_DATA;
                    o_mem_en <= '0';
                    o_out_we <= '0';
                when SAVE_DATA =>
                    state <= PRINT_OUTPUT;
                    o_done <= '1';
                when PRINT_OUTPUT =>
                    state <= WAIT_START;
                    o_done <= '0';
                when others =>
                    state <= WAIT_START;
                    o_done <= '0';
                    o_mem_en <= '0';
                    o_out_we <= '0';
                    o_shift_rst <= '0';
                    o_shift_we <= '0';
            end case;        
        end if;
    end process;
end fsm_register_arch;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_w : in std_logic;
        o_z0 : out std_logic_vector(7 downto 0);
        o_z1 : out std_logic_vector(7 downto 0);
        o_z2 : out std_logic_vector(7 downto 0);
        o_z3 : out std_logic_vector(7 downto 0);
        o_done : out std_logic;
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we : out std_logic;
        o_mem_en : out std_logic
        );
end project_reti_logiche;

architecture project_reti_logiche_arch of project_reti_logiche is
    signal out_port: std_logic_vector(1 downto 0);
    signal done: std_logic;
    signal out_we : std_logic;
    signal shift_rst : std_logic;
    signal shift_we : std_logic;
    
    component shift_register is
    port(
        i_clk : in std_logic;
        i_rst: in std_logic;
        i_start: in std_logic;
        i_w: in std_logic;
        i_we: in std_logic;
        o_addr: out std_logic_vector(15 downto 0)
        );
    end component;
    
    component output_register is
    port(
        i_clk : in std_logic;
        i_rst: in std_logic;
        i_we: in std_logic;
        i_port: in std_logic_vector(1 downto 0);
        i_data: in std_logic_vector(7 downto 0);
        i_done: in std_logic;
        o_z0: out std_logic_vector(7 downto 0);
        o_z1: out std_logic_vector(7 downto 0);
        o_z2: out std_logic_vector(7 downto 0);
        o_z3: out std_logic_vector(7 downto 0);
        o_done: out std_logic
        );
    end component;
    
    component fsm_register is
    port(
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_w : in std_logic;
        o_port: out std_logic_vector(1 downto 0);
        o_done : out std_logic :='0';
        o_mem_we : out std_logic :='0';
        o_mem_en : out std_logic :='0';
        o_out_we : out std_logic :='0';
        o_shift_rst : out std_logic :='0';
        o_shift_we : out std_logic :='0'
        );
    end component;
    
begin
    
    ADDRESS:
    shift_register port map(
        i_clk => i_clk,
        i_rst => shift_rst,
        i_start => i_start,
        i_w => i_w,
        i_we => shift_we,
        o_addr => o_mem_addr
    );
    
    OUTPUT:
    output_register port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_we => out_we,
        i_port => out_port,
        i_data => i_mem_data,
        i_done => done,
        o_z0 => o_z0,
        o_z1 => o_z1,
        o_z2 => o_z2,
        o_z3 => o_z3,
        o_done => o_done
    );
    
    FSM:
    fsm_register port map(
        i_clk => i_clk,
        i_rst => i_rst,
        i_start => i_start,
        i_w => i_w,
        o_port => out_port,
        o_done => done,
        o_mem_we => o_mem_we,
        o_mem_en => o_mem_en,
        o_out_we => out_we,
        o_shift_rst => shift_rst,
        o_shift_we => shift_we
    );
    
end project_reti_logiche_arch;
