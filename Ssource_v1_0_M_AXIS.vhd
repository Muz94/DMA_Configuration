library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity Ssource_v1_0_M_AXIS is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
		C_M_AXIS_TDATA_WIDTH	: integer	:= 32;
		-- Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
		C_M_START_COUNT	: integer	:= 32;
		Desired_Number_of_Frames      : integer := 5
	);
	
	port (
		-- Users to add ports here
     
		-- User ports ends
		-- Do not modify the ports beyond this line

		-- Global ports
		M_AXIS_ACLK	: in std_logic;
		-- 
		M_AXIS_ARESETN	: in std_logic;
		-- Master Stream Ports. TVALID indicates that the master is driving a valid transfer, A transfer takes place when both TVALID and TREADY are asserted. 
		M_AXIS_TVALID	: out std_logic;
		-- TDATA is the primary payload that is used to provide the data that is passing across the interface from the master.
		M_AXIS_TDATA	: out std_logic_vector(C_M_AXIS_TDATA_WIDTH-1 downto 0);
		-- TSTRB is the byte qualifier that indicates whether the content of the associated byte of TDATA is processed as a data byte or a position byte.
		M_AXIS_TSTRB	: out std_logic_vector((C_M_AXIS_TDATA_WIDTH/8)-1 downto 0);
		-- TLAST indicates the boundary of a packet.
		M_AXIS_TLAST	: out std_logic;
		-- TREADY indicates that the slave can accept a transfer in the current cycle.
		M_AXIS_TREADY	: in std_logic
		
		
	);
end Ssource_v1_0_M_AXIS;

 architecture implementation of Ssource_v1_0_M_AXIS is

   type state_stream is ( idle, start_stream , terminate_stream);
   
     signal state_s : state_stream;
	
	signal stream_data       : integer := 0;
	signal AXIS_data  : std_logic_vector(31 downto 0);
	signal Tvalid      : std_logic := '0';
	signal Tlast        : std_logic := '0';
	signal counter              : integer := 0;
	signal ctr   : integer := 0;
	signal frame_1   : std_logic := '0';
	signal frame_2    : std_logic := '0';
	signal frame_number : integer := 0;
	signal offset_value  : integer := 0;
	signal countreg : integer := -1;
	signal base_value : integer := 0;
	signal first_frame_size : integer := 254;
	signal start_frame : std_logic := '0';
	
	


begin
                                                            

	-- Add user logic here
    
    --  Design for the M_AXIS_TData where data is datat 32 bits and is incremented whenevr tready and tvalid are high
      
     process(M_AXIS_ACLK)
   
     begin
     
     
     if rising_edge(M_AXIS_ACLK) then
          if (M_AXIS_ARESETN = '0') then
           stream_data  <= 0;
            frame_number <= 0;
           
           
       
    else
    
    
    
         
         if(frame_number = 0) then
             
              if(Tvalid = '1' and M_AXIS_TREADY ='1') then
           
                 stream_data <= stream_data + 1;
                 counter <= counter + 1;
              
            
                  if(stream_data = first_frame_size) then
                        Tlast <= '1';
              
                    else
                       Tlast <= '0';       
            
             end if;
             
         end if;
                         
         end if;
       
       if(frame_number = 1) then
       
           
          if(Tvalid = '1' and M_AXIS_TREADY ='1') then
            stream_data <= stream_data + 1;
            counter <= counter + 1;
          
               
               if(stream_data = offset_value) then
                    Tlast <= '1';

                   else
                   Tlast <= '0';
              
                  end if;
                  end if;
 
     end if;
     
           
     if(frame_number = 2) then
        if(Tvalid = '1' and M_AXIS_TREADY ='1') then
          stream_data <= stream_data + 1;
          counter <= counter + 1;
             
             if(stream_data = offset_value) then
                  Tlast <= '1';

                 else
                 Tlast <= '0';
            
                end if;
                end if;

   end if; 
     
            
   if(frame_number = 3) then
      if(Tvalid = '1' and M_AXIS_TREADY ='1') then
        stream_data <= stream_data + 1;
         counter <= counter + 1;
           
           if(stream_data = offset_value) then
                Tlast <= '1';

               else
               Tlast <= '0';
          
              end if;
              end if;

 end if;
 
 
        
 if(frame_number = 4) then
    if(Tvalid = '1' and M_AXIS_TREADY ='1') then
      stream_data <= stream_data + 1;
         counter <= counter +1;
         if(stream_data = offset_value) then
              Tlast <= '1';

             else
             Tlast <= '0';
        
            end if;
            end if;

end if;
     
     
     if(Tlast = '1') then
        frame_number <= frame_number + 1;
      end if;
         
 
   end if; 
    end if;
   
       end process;
       

  
    process( M_AXIS_ACLK)
      begin
         if rising_edge(M_AXIS_ACLK) then
            if(M_AXIS_ARESETN ='0') then       
                  offset_value <= 0;   
             else
             
      case frame_number is 
             
             when 0 =>
             
              Tvalid <= '1';
           if(Tvalid = '1' and M_AXIS_TREADY = '1' and Tlast = '1') then
              Tvalid <= '0';
             end if;
           --offset_value <= first_frame_size;
             if(counter = first_frame_size+1) then
             offset_value <= counter + 1279;
                end if; 
         
             when 1 =>
             Tvalid <= '1';
              if(Tvalid = '1' and M_AXIS_TREADY = '1' and Tlast = '1') then
              Tvalid <= '0';
                end if;
           
                if(counter = offset_value ) then
                 offset_value <= counter + 768;
                end if; 
          
             when 2 =>
             
               Tvalid <= '1';
               if(Tvalid = '1' and M_AXIS_TREADY = '1' and Tlast = '1') then
                Tvalid <= '0';
                end if;
              if(counter = offset_value) then
               offset_value <= counter + 1024;
                end if; 
              
             when 3 =>
               Tvalid <= '1';
               if(Tvalid = '1' and M_AXIS_TREADY = '1' and Tlast = '1') then
                 Tvalid <= '0';
                end if;
             if(counter = offset_value ) then
               offset_value <= counter + 2048;
               end if;
                  
              when others =>
                  offset_value <= 0;    
          end case;
            
                        
                 end if;
                                           
              end if;
          
           end process;
          
          
  
  
        
               








   
 --  process(M_AXIS_ACLK)
 --  begin
 --   if rising_edge(M_AXIS_ACLK) then
 --     if(M_AXIS_ARESETN ='0') then
 --          Tvalid_signa <= '0';
 --       elsif( ct = 1) then
 --        Tvalid_signal <= '1';
 --        else
 --         ct <= ct + 1;
 --       end if;
 --       end if;
 --       end process;
             
                           
                               
                     M_AXIS_TLAST <= Tlast;
                     
                     M_AXIS_TDATA <= AXIS_data;
                                    
                     M_AXIS_TVALID <= Tvalid;
                     
                     AXIS_data <= std_logic_vector(to_unsigned(stream_data, AXIS_data'length)); 
               
                                    
                   
                        
                 
                 
                    
                  
                    
            
            
         
          
                    
          
            
            
            
            
            
            
            
            
            
      
     




	-- User logic ends

end implementation;