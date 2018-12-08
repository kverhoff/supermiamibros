



--*****************************************

--	  SUPER MIAMI BROS.
--   FileName:         vhdl3.vhd
--   Dependencies:     none
--   Version 1.0
--   

--*****************************************




--
--   FileName:         hw_image_generator.vhd
--   Dependencies:     none
--   Design Software:  Quartus II 64-bit Version 12.1 Build 177 SJ Full Version
--
--   HDL CODE IS PROVIDED "AS IS."  DIGI-KEY EXPRESSLY DISCLAIMS ANY
--   WARRANTY OF ANY KIND, WHETHER EXPRESS OR IMPLIED, INCLUDING BUT NOT
--   LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
--   PARTICULAR PURPOSE, OR NON-INFRINGEMENT. IN NO EVENT SHALL DIGI-KEY
--   BE LIABLE FOR ANY INCIDENTAL, SPECIAL, INDIRECT OR CONSEQUENTIAL
--   DAMAGES, LOST PROFITS OR LOST DATA, HARM TO YOUR EQUIPMENT, COST OF
--   PROCUREMENT OF SUBSTITUTE GOODS, TECHNOLOGY OR SERVICES, ANY CLAIMS
--   BY THIRD PARTIES (INCLUDING BUT NOT LIMITED TO ANY DEFENSE THEREOF),
--   ANY CLAIMS FOR INDEMNITY OR CONTRIBUTION, OR OTHER SIMILAR COSTS.
--
--   Version History
--   Version 1.0 05/10/2013 Scott Larson
--     Initial Public Release
--    
--------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

ENTITY hw_image_generator IS
	GENERIC(
		pixels_y :	INTEGER := 4000;    --row that first color will persist until
		pixels_x	:	INTEGER := 900);   --column that first color will persist until
		
	PORT(
		disp_ena		:	IN		STD_LOGIC;	--display enable ('1' = display time, '0' = blanking time)
		row			:	IN		INTEGER;		--row pixel coordinate
		column		:	IN		INTEGER;		--column pixel coordinate
		clk			: 	IN		STD_LOGIC;	-- 50 MHz clock
	   reset : in std_logic;  --DUH
		keyjump :IN STD_LOGIC; --DUH
		keymoveright :IN STD_LOGIC; --DUH
		keymoveleft :IN STD_LOGIC; --DUH
		LEDscore       : out std_logic_vector(0 to 6);
		LEDscore2       : out std_logic_vector(0 to 6);
		red			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --red magnitude output to DAC
		green			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');  --green magnitude output to DAC
		blue			:	OUT	STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0')); --blue magnitude output to DAC
END hw_image_generator;

ARCHITECTURE behavior OF hw_image_generator IS
  
   signal enemymove	:	INTEGER RANGE -2147483647 to 2147483647:= 0;  --buttcheese
   signal score 	: INTEGER RANGE 0 TO 500:= 0;  --buttcheese
	signal counter 	: std_logic_vector(16 downto 0);--jumpspeed 16
	signal counter2 	: std_logic_vector(15 downto 0);--movespeed 17
	signal counter3 	: std_logic_vector(19 downto 0);--enemyspeed
	signal clock  		: std_logic_vector(1 downto 0);
	signal jump	:	INTEGER RANGE 0 TO 500:= 0;  --buttcheese
	signal jumpdown	:	INTEGER RANGE 0 TO 1:= 0;  --buttcheese
	signal dojump	:	INTEGER RANGE 0 TO 1:= 0;  --buttcheese
	signal stopjump	:	INTEGER RANGE 0 TO 1:= 0;  --buttcheese
	signal move	:	INTEGER RANGE 10 to 1300:= 10;  --buttcheese
	signal move2	:	INTEGER RANGE -1000 to 1920:= -1000;  --buttcheese
	signal playafoot : INTEGER RANGE 0 to 2000:= 851;
	signal playahead : INTEGER RANGE 0 to 2000:= 951;
	signal gameposition	:	INTEGER RANGE -2147483647 to 2147483647:= 0;  --buttcheese
	signal gameposition2	:	INTEGER RANGE -2147483647 to 2147483647:= 0;  --buttcheese
	signal score1	:	INTEGER RANGE 1 to 20000:= 1;  --buttcheese
	signal score2	:	INTEGER RANGE -2147483647 to 2147483647:= 0;  --buttcheese
	signal stop	:	INTEGER RANGE 0 TO 2:= 0;  --buttcheese
	signal brickline0move :	INTEGER RANGE 0 to 1920:= 0;  --buttcheese
	signal brickline1move :	INTEGER RANGE 0 to 1920:= 96;  --buttcheese
	signal brickline2move :	INTEGER RANGE 0 to 1920:= 192;  --buttcheese
	signal brickline3move :	INTEGER RANGE 0 to 1920:= 288;  --buttcheese
	signal brickline4move :	INTEGER RANGE 0 to 1920:= 384;  --buttcheese
	signal brickline5move :	INTEGER RANGE 0 to 1920:= 480;  --buttcheese
	signal brickline6move :	INTEGER RANGE 0 to 1920:= 576;  --buttcheese
	signal brickline7move :	INTEGER RANGE 0 to 1920:= 672;  --buttcheese
	signal brickline8move :	INTEGER RANGE 0 to 1920:=768;  --buttcheese
	signal brickline9move :	INTEGER RANGE 0 to 1920:= 864;  --buttcheese
	signal brickline10move :	INTEGER RANGE 0 to 1920:= 960;  --buttcheese
	signal brickline11move :	INTEGER RANGE 0 to 1920:= 1056;  --buttcheese
	signal brickline12move :	INTEGER RANGE 0 to 1920:= 1152;  --buttcheese
	signal brickline13move :	INTEGER RANGE 0 to 1920:= 1248;  --buttcheese
	signal brickline14move :	INTEGER RANGE 0 to 1920:= 1344;  --buttcheese
	signal brickline15move :	INTEGER RANGE 0 to 1920:= 1440;  --buttcheese
	signal brickline16move :	INTEGER RANGE 0 to 1920:= 1536;  --buttcheese
	signal brickline17move :	INTEGER RANGE 0 to 1920:= 1632;  --buttcheese
	signal brickline18move :	INTEGER RANGE 0 to 1920:= 1728;  --buttcheese
	signal brickline19move :	INTEGER RANGE 0 to 1920:= 1824;  --buttcheese
	signal brickline20move :	INTEGER RANGE 0 to 1920:= 1920;  --buttcheese
	
	--**********************************************************************************obstacle parameters, dont forget to change jump<50 in collision detection for item you change
	constant jumpheight :INTEGER RANGE 0 TO 500:=300;
	constant block1left : INTEGER RANGE 0 to 12000 := 2550;
	constant block1right : INTEGER RANGE 0 to 12000 := 2600;
	constant block1bottom : INTEGER RANGE 0 to 2000 := 950;
	constant block1top : INTEGER RANGE 0 to 2000 := 900;
	
	constant block2left : INTEGER RANGE 0 to 12000 := 5550;
	constant block2right : INTEGER RANGE 0 to 120000 := 5600;
	constant block2bottom : INTEGER RANGE 0 to 2000 := 950;
	constant block2top : INTEGER RANGE 0 to 2000 := 900;
	
	constant block3left : INTEGER RANGE 0 to 12000 := 6550;
	constant block3right : INTEGER RANGE 0 to 120000 := 6600;
	constant block3bottom : INTEGER RANGE 0 to 2000 := 950;
	constant block3top : INTEGER RANGE 0 to 2000 := 900;
	
	constant block4left : INTEGER RANGE 0 to 120000 := 8550;
	constant block4right : INTEGER RANGE 0 to 120000 := 8600;
	constant block4bottom : INTEGER RANGE 0 to 2000 := 950;
	constant block4top : INTEGER RANGE 0 to 2000 := 900;
	
	constant block5left : INTEGER RANGE 0 to 120000 := 9550;
	constant block5right : INTEGER RANGE 0 to 120000 := 9600;
	constant block5bottom : INTEGER RANGE 0 to 2000 := 950;
	constant block5top : INTEGER RANGE 0 to 2000 := 900;
	
	constant block6left : INTEGER RANGE 0 to 120000 := 10000;
	constant block6right : INTEGER RANGE 0 to 120000 := 10050;
	constant block6bottom : INTEGER RANGE 0 to 2000 := 950;
	constant block6top : INTEGER RANGE 0 to 2000 := 900;
	
	constant block7left : INTEGER RANGE 0 to 120000 := 10300;
	constant block7right : INTEGER RANGE 0 to 120000 := 10350;
	constant block7bottom : INTEGER RANGE 0 to 2000 := 950;
	constant block7top : INTEGER RANGE 0 to 2000 := 900;
	
	constant block8left : INTEGER RANGE 0 to 120000 := 11550;
	constant block8right : INTEGER RANGE 0 to 120000 := 11600;
	constant block8bottom : INTEGER RANGE 0 to 2000 := 950;
	constant block8top : INTEGER RANGE 0 to 2000 := 900;
	
	constant block9left : INTEGER RANGE 0 to 120000 := 12550;
	constant block9right : INTEGER RANGE 0 to 120000 := 12600;
	constant block9bottom : INTEGER RANGE 0 to 2000 := 950;
	constant block9top : INTEGER RANGE 0 to 2000 := 900;
	
		constant block10left : INTEGER RANGE 0 to 120000 := 12550;
	constant block10right : INTEGER RANGE 0 to 120000 := 12600;
	constant block10bottom : INTEGER RANGE 0 to 2000 := 950;
	constant block10top : INTEGER RANGE 0 to 2000 := 900;
	
		constant block11left : INTEGER RANGE 0 to 120000 := 12550;
	constant block11right : INTEGER RANGE 0 to 120000 := 12600;
	constant block11bottom : INTEGER RANGE 0 to 2000 := 950;
	constant block11top : INTEGER RANGE 0 to 2000 := 900;
	


	
BEGIN
PROCESS(clk)
BEGIN
	
	--*******************************************************************************ones spot seven seg led score number
	if score1>0 and score1<2000  then		--0
				LEDscore <= "0000001";
				
				
			elsif score1>2000 and score1<4000 then	--1
				LEDscore <= "1001111";
			
			elsif score1>4000 and score1<6000 then	--2
				LEDscore <= "0010010";
			
			elsif score1>6000 and score1<8000 then	--3
				LEDscore <= "0000110";
			
			elsif score1>8000 and score1<10000 then	--4
				LEDscore <= "1001100";
			
			elsif score1>10000 and score1<12000 then	--5
				LEDscore <= "0100100";
			
			elsif score1>12000 and score1<14000 then	--6
				LEDscore <= "0100000";
			
			elsif score1>14000 and score1<16000 then	--7
				LEDscore <= "0001111";
				
			elsif score1>16000 and score1<18000 then	--8
				LEDscore <= "0000000";
				
			elsif score1>18000 and score1<20000 then	--9
				LEDscore <= "0001100";
			end if;
			
	--*******************************************************************************tens spot seven seg led score number  (begin)
				if score2=0 then
				LEDscore2 <= "0000001";
				
				elsIf score2=1 then 
				LEDscore2 <= "1001111";
				elsif score2=2 then
				LEDscore2 <= "0010010";
				elsif score=3 then
				LEDscore2 <= "0000110";
				elsif score=4 then
				LEDscore2 <= "1001100";
				elsif score=5 then
				LEDscore2 <= "0100100";
				
				elsif score=6 then
				LEDscore2 <= "0100000";
				
				elsif score=7 then
				LEDscore2 <= "0001111";
				elsif score=8 then
				LEDscore2 <= "0000000";
				elsif score=9 then
				LEDscore2 <= "0001100";
				end if;
				
	--*******************************************************************************tens spot seven seg led score number (end)			
			
				
	
	
	
		if clk'EVENT and clk = '1' then
			counter <= counter + 1;
			if(counter = 0) then
--*************************************jump original****************************************			
--			if (keyjump='0') then
--			 dojump<=1;
--			end if;

--			if (jump <=(jumpheight-1) and jumpdown=0 and dojump=1 and stopjump=0) then
--				jump <= jump + 1;
--				elsif (jump >=jumpheight and jumpdown=0)then
--				jumpdown<=1;
--				elsif (jump>=1 and jumpdown=1)then
--				jump<=jump - 1;
--				elsif (jumpdown=1) then
--				dojump<=0;
--				jumpdown<=0;
--					
--				end if;
--******************************************************************************************************************JUMP(begin)
			if (keyjump='0') then
				dojump<=1;
			end if;
			
			if (jump = 0 and keyjump = '1') then
				stopjump <= 0;
			end if;
			
				-- jump button is pressed and we're not at the max height
				if (jump <=(jumpheight-1) and jumpdown=0 and dojump=1 and stopjump=0 and keyjump = '0') then
				jump <= jump + 1;
				
				-- jump button is released and we're not at the max height
				elsif (jump <=(jumpheight-1) and jumpdown=0 and dojump=1 and stopjump=0 and keyjump = '1') then
				jumpdown <= 1;
				stopjump <= 1;
				elsif (jump >=jumpheight and jumpdown=0)then
				jumpdown<=1;
				stopjump <= 1;
				elsif (jump>=1 and jumpdown=1)then
				jump<=jump - 1;
				elsif (jumpdown=1) then
				dojump<=0;
				jumpdown<=0;
				
				end if;
			end if;
		end if;
		
	--******************************************************************************************************************JUMP(end)
	
	END PROCESS;

	--******************************************************************************************************************COLLISION variables
	PROCESS(keymoveright,keymoveleft,stop)
	variable collision	:	INTEGER RANGE 0 TO 1:=0;  --collision set to 1 if collision detected.
	variable collisionwidthdetection	:	INTEGER RANGE 980 TO 1020:= 996;  --Change this variable to scan wider or narrower area.
	BEGIN
	
	collisionwidthdetection:=(collisionwidthdetection-1);
	



--block collision stuffs*******************************************************************************block collision stuffs**********
IF (((gameposition) /= ((block1left-collisionwidthdetection)-enemymove)) and collision/=1) THEN
stop<=1;
elsif(jump<50) then  --***********************************************************************************Jump>50 must be changed to block height player is jumping over, 50 is just default
stop<=2;
collision:=1;
END IF;	
IF (((gameposition) /= ((block1left-1000)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block1left-998)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block1left-996)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;

--block collision stuffs*******************************************************************************block collision stuffs***********

--block collision stuffs*******************************************************************************block collision stuffs**********
IF (((gameposition) /= ((block2left-collisionwidthdetection)-enemymove))and collision/=1) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;	
IF (((gameposition) /= ((block2left-1000)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block2left-998)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block2left-996)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;

--block collision stuffs*******************************************************************************block collision stuffs***********

--block collision stuffs*******************************************************************************block collision stuffs**********
IF (((gameposition) /= ((block3left-collisionwidthdetection)-enemymove))and collision/=1) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;	
IF (((gameposition) /= ((block3left-1000)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block3left-998)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block3left-996)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;

--block collision stuffs*******************************************************************************block collision stuffs***********
--block collision stuffs*******************************************************************************block collision stuffs**********
IF (((gameposition) /= ((block4left-collisionwidthdetection)-enemymove))and collision/=1) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;	
IF (((gameposition) /= ((block4left-1000)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block4left-998)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block4left-996)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;

--block collision stuffs*******************************************************************************block collision stuffs***********
--block collision stuffs*******************************************************************************block collision stuffs**********
IF (((gameposition) /= ((block5left-collisionwidthdetection)-enemymove))and collision/=1) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;	
IF (((gameposition) /= ((block5left-1000)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block5left-998)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block5left-996)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;

--block collision stuffs*******************************************************************************block collision stuffs***********
--block collision stuffs*******************************************************************************block collision stuffs**********
IF (((gameposition) /= ((block6left-collisionwidthdetection)-enemymove))and collision/=1) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;	
IF (((gameposition) /= ((block6left-1000)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block6left-998)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block6left-996)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;

--block collision stuffs*******************************************************************************block collision stuffs***********
--block collision stuffs*******************************************************************************block collision stuffs**********
IF (((gameposition) /= ((block7left-collisionwidthdetection)-enemymove))and collision/=1) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;	
IF (((gameposition) /= ((block7left-1000)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block7left-998)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
END IF;
IF (((gameposition) /= ((block7left-996)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;

--block collision stuffs*******************************************************************************block collision stuffs***********
--block collision stuffs*******************************************************************************block collision stuffs**********
IF (((gameposition) /= ((block8left-collisionwidthdetection)-enemymove))and collision/=1) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;	
IF (((gameposition) /= ((block8left-1000)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block8left-998)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block8left-996)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;

--block collision stuffs*******************************************************************************block collision stuffs***********
--block collision stuffs*******************************************************************************block collision stuffs**********
IF (((gameposition) /= ((block9left-collisionwidthdetection)-enemymove))and collision/=1) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;	
IF (((gameposition) /= ((block9left-1000)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block9left-998)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block9left-996)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;

--block collision stuffs*******************************************************************************block collision stuffs***********
--block collision stuffs*******************************************************************************block collision stuffs**********
IF (((gameposition) /= ((block10left-collisionwidthdetection)-enemymove))and collision/=1) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;	
IF (((gameposition) /= ((block10left-1000)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
END IF;
IF (((gameposition) /= ((block10left-998)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block10left-996)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;

--block collision stuffs*******************************************************************************block collision stuffs***********
--block collision stuffs*******************************************************************************block collision stuffs**********
IF (((gameposition) /= ((block11left-collisionwidthdetection)-enemymove))and collision/=1) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;	
IF (((gameposition) /= ((block11left-1000)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block11left-998)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;
IF (((gameposition) /= ((block11left-996)-enemymove))) THEN
stop<=1;
elsif(jump<50) then
stop<=2;
collision:=1;
END IF;

--block collision stuffs*******************************************************************************block collision stuffs***********


	
	
	
	
	
	
	if clk'EVENT and clk = '1' then  --enemy movement speed clock
			counter3 <= counter3 + 1;
			if(counter3 = 0) then
			
			enemymove<=enemymove+1;
			end if;
	end if;
	
	
	if clk'EVENT and clk = '1' then  --collision variable update speed and variable resets.
			counter2 <= counter2 + 1;
			if(counter2 = 0) then
			
--			if (stop=2) then
--			collision:=1;
--			end if;
			
		if (reset='0') then
	   	brickline0move<=0;
			brickline1move<=96;
			brickline2move<=192;
			brickline3move<=288;
			brickline4move<=384;
			brickline5move<=480;
			brickline6move<=576;
			brickline7move<=672;
			brickline8move<=768;
			brickline9move<=864;
			brickline10move<=960;
			brickline11move<=1056;
			brickline12move<=1152;
			brickline13move<=1248;
			brickline14move<=1344;
			brickline15move<=1440;
			brickline16move<=1536;
			brickline17move<=1632;
			brickline18move<=1728;
			brickline19move<=1824;
			brickline20move<=1920;
			gameposition<=0;
			gameposition2<=0;
			collision:=0;
			enemymove<=0;
			score1<=1;
			score2<=0;
			
						end if;
		
		if (keymoveright='0'and keymoveleft = '1' and collision=0) then  --clock for brick vert line movement, game position 1 and 2, and more score code.
			
			gameposition<=gameposition+1;
			gameposition2<=gameposition2+1;
			brickline0move<=brickline0move-1;
			brickline1move<=brickline1move-1;
			brickline2move<=brickline2move-1;
			brickline3move<=brickline3move-1;
			brickline4move<=brickline4move-1;
			brickline5move<=brickline5move-1;
			brickline6move<=brickline6move-1;
			brickline7move<=brickline7move-1;
			brickline8move<=brickline8move-1;
			brickline9move<=brickline9move-1;
			brickline10move<=brickline10move-1;
			brickline11move<=brickline11move-1;
			brickline12move<=brickline12move-1;
			brickline13move<=brickline13move-1;
			brickline14move<=brickline14move-1;
			brickline15move<=brickline15move-1;
			brickline16move<=brickline16move-1;
			brickline17move<=brickline17move-1;
			brickline18move<=brickline18move-1;
			brickline19move<=brickline19move-1;
			brickline20move<=brickline10move-1;
			
			if score1<=20000 then
			score1<=score1+1;
			else
			score1<=1;
			score2<=score2+1;
			end if;
						end if;
						
		
	
	if (keymoveleft='0' and keymoveright = '1' and collision=0) then
	gameposition<=gameposition-1;
			gameposition2<=gameposition2-1;
			
			brickline0move<=brickline0move+1;
			brickline1move<=brickline1move+1;
			brickline2move<=brickline2move+1;
			brickline3move<=brickline3move+1;
			brickline4move<=brickline4move+1;
			brickline5move<=brickline5move+1;
			brickline6move<=brickline6move+1;
			brickline7move<=brickline7move+1;
			brickline8move<=brickline8move+1;
			brickline9move<=brickline9move+1;
			brickline10move<=brickline10move+1;
			brickline11move<=brickline11move+1;
			brickline12move<=brickline12move+1;
			brickline13move<=brickline13move+1;
			brickline14move<=brickline14move+1;
			brickline15move<=brickline15move+1;
			brickline16move<=brickline16move+1;
			brickline17move<=brickline17move+1;
			brickline18move<=brickline18move+1;
			brickline19move<=brickline19move+1;
			brickline20move<=brickline20move+1;
			
			--score1<=score1-1;
						end if;
						end if;
						end if;
	END PROCESS;
	
		
	
	
	

	PROCESS(disp_ena, row, column,gameposition,stop)
				
				variable brickhoriz	:	INTEGER RANGE 730 TO 1030:= 750;  --buttcheese
				variable brickhoriz2	:	INTEGER RANGE 730 TO 1030:= 755;  --buttcheese
				
				
				
				

variable brickline1	:	INTEGER RANGE 0 TO 1920:=41;  --buttcheese
	BEGIN
	
IF(disp_ena = '1') THEN		--display time
			IF(row > 0 AND column > 950) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			ELSE
				red <= (OTHERS => '0');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '1');
			END IF;
		ELSE								--blanking time
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row > 920 AND row < 1000 AND column > (playafoot-jump) And column < (playahead-jump)) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
			end if;
		ELSE								--blanking time
			red <= (OTHERS => '0');
			green <= (OTHERS => '0');
			blue <= (OTHERS => '0');
		END IF;
		--bad dudes***********************************************************************************************************************bad dudes
		
		IF(disp_ena = '1') THEN		--display time
			IF(row > ((block1left-gameposition)-enemymove) AND row < ((block1right-gameposition)-enemymove) AND column > (block1top) And column < (block1bottom)) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			end if;
			ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		
		IF(disp_ena = '1') THEN		--display time
			IF(row > ((block2left-gameposition)-enemymove) AND row < ((block2right-gameposition)-enemymove) AND column > (block2top) And column < (block2bottom)) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			end if;
			ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row > ((block3left-gameposition)-enemymove) AND row < ((block3right-gameposition)-enemymove) AND column > (block3top) And column < (block3bottom)) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			end if;
			ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row > ((block4left-gameposition)-enemymove) AND row < ((block4right-gameposition)-enemymove) AND column > (block4top) And column < (block4bottom)) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			end if;
		
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		--bad dude*********************************************************************************************************************bad dude
		IF(disp_ena = '1') THEN		--display time
			IF(row > ((block5left-gameposition)-enemymove) AND row < ((block5right-gameposition)-enemymove) AND column > (block5top) And column < (block5bottom)) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			end if;
		
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		--bad dude*********************************************************************************************************************bad dude
		--bad dude*********************************************************************************************************************bad dude
		IF(disp_ena = '1') THEN		--display time
			IF(row > ((block6left-gameposition)-enemymove) AND row < ((block6right-gameposition)-enemymove) AND column > (block6top) And column < (block6bottom)) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			end if;
		
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		--bad dude*********************************************************************************************************************bad dude
		--bad dude*********************************************************************************************************************bad dude
		IF(disp_ena = '1') THEN		--display time
			IF(row > ((block7left-gameposition)-enemymove) AND row < ((block7right-gameposition)-enemymove) AND column > (block7top) And column < (block7bottom)) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			end if;
		
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		--bad dude*********************************************************************************************************************bad dude
		--bad dude*********************************************************************************************************************bad dude
		IF(disp_ena = '1') THEN		--display time
			IF(row > ((block8left-gameposition)-enemymove) AND row < ((block8right-gameposition)-enemymove) AND column > (block8top) And column < (block8bottom)) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			end if;
		
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		--bad dude*********************************************************************************************************************bad dude
		--bad dude*********************************************************************************************************************bad dude
		IF(disp_ena = '1') THEN		--display time
			IF(row > ((block9left-gameposition)-enemymove) AND row < ((block9right-gameposition)-enemymove) AND column > (block9top) And column < (block9bottom)) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			end if;
		
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		--bad dude*********************************************************************************************************************bad dude
		--bad dude*********************************************************************************************************************bad dude
		IF(disp_ena = '1') THEN		--display time
			IF(row > ((block10left-gameposition)-enemymove) AND row < ((block10right-gameposition)-enemymove) AND column > (block10top) And column < (block10bottom)) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			end if;
		
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		--bad dude*********************************************************************************************************************bad dude
		--bad dude*********************************************************************************************************************bad dude
		IF(disp_ena = '1') THEN		--display time
			IF(row > ((block11left-gameposition)-enemymove) AND row < ((block11right-gameposition)-enemymove) AND column > (block11top) And column < (block11bottom)) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '0');
				blue <= (OTHERS => '0');
			end if;
		
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		--bad dude*********************************************************************************************************************bad dude
		
		
		
		
		
		--Horizontal lines for bricks****************************************************************************************************
		
		
		IF(disp_ena = '1') THEN		--display time
		if(row > 0 AND column > (brickhoriz+200) and column <(brickhoriz2+200)) then
		red <= (OTHERS => '1');
		green	<= (OTHERS => '1');
		blue <= (OTHERS => '1');
		END if;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
		if(row > 0 AND column > (brickhoriz+240) and column <(brickhoriz2+240)) then
		red <= (OTHERS => '1');
		green	<= (OTHERS => '1');
		blue <= (OTHERS => '1');
		END if;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		
		
		IF(disp_ena = '1') THEN		--display time
		if(row > 0 AND column > (brickhoriz+280) and column <(brickhoriz2+280)) then
		red <= (OTHERS => '1');
		green	<= (OTHERS => '1');
		blue <= (OTHERS => '1');
		END if;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		
		
		
		IF(disp_ena = '1') THEN		--display time
		if(row > 0 AND column > (brickhoriz+320) and column <(brickhoriz2+320)) then
		red <= (OTHERS => '1');
		green	<= (OTHERS => '1');
		blue <= (OTHERS => '1');
		END if;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		
		IF(disp_ena = '1') THEN		--display time
		if(row > 0 AND column > (brickhoriz+400) and column <(brickhoriz2+400)) then
		red <= (OTHERS => '1');
		green	<= (OTHERS => '1');
		blue <= (OTHERS => '1');
		END if;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		--****************************************************************
		
		IF(disp_ena = '1') THEN		--display time
			IF(row > (move2+1) and row < (move2+600) AND column > 150 and column <300) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		--***************
		IF(disp_ena = '1') THEN		--display time
			IF(row > (move2+block1bottom) and row < (move2+block1top) AND column > block1left and column < block1right) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
			--*************************************************************vertbrick lines begin top row***************************************************	
		
--		


		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline0move-48) and row > (brickline0move-53) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline1move) and row > (brickline1move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline2move) and row > (brickline2move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline3move) and row > (brickline3move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline4move) and row > (brickline4move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline5move) and row > (brickline5move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline6move) and row > (brickline6move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline7move) and row > (brickline7move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline8move) and row > (brickline8move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline9move) and row > (brickline9move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline10move) and row > (brickline10move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline11move) and row > (brickline11move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline12move) and row > (brickline12move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline13move) and row > (brickline13move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline14move) and row > (brickline14move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline15move) and row > (brickline15move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline16move) and row > (brickline16move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline17move) and row > (brickline17move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline18move) and row > (brickline18move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
			IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline20move) and row > (brickline20move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline19move) and row > (brickline19move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
			IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline20move) and row > (brickline20move-5) AND column > 951 and column <991) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		

		
		--*************************************************************vertbrick lines end top row***************************************************	
		
		
		--Middle row ******************************************************************************************************************
		
		
		
		
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline0move-48) and row > (brickline0move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline1move-48) and row > (brickline1move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline2move-48) and row > (brickline2move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline3move-48) and row > (brickline3move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline4move-48) and row > (brickline4move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline5move-48) and row > (brickline5move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline6move-48) and row > (brickline6move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline7move-48) and row > (brickline7move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline8move-48) and row > (brickline8move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline9move-48) and row > (brickline9move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline10move-48) and row > (brickline10move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline11move-48) and row > (brickline11move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline12move-48) and row > (brickline12move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline13move-48) and row > (brickline13move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline14move-48) and row > (brickline14move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline15move-48) and row > (brickline15move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline16move-48) and row > (brickline16move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline17move-48) and row > (brickline17move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline18move-48) and row > (brickline18move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
			
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline19move-48) and row > (brickline19move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
			IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline20move-48) and row > (brickline20move-53) AND column >991 and column <1031) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		

		
--***************************************************************************************************************************last row of vert bricks.
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline0move) and row > (brickline0move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline1move) and row > (brickline1move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline2move) and row > (brickline2move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline3move) and row > (brickline3move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline4move) and row > (brickline4move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline5move) and row > (brickline5move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline6move) and row > (brickline6move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline7move) and row > (brickline7move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline8move) and row > (brickline8move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline9move) and row > (brickline9move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline10move) and row > (brickline10move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline11move) and row > (brickline11move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline12move) and row > (brickline12move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline13move) and row > (brickline13move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline14move) and row > (brickline14move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline15move) and row > (brickline15move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline16move) and row > (brickline16move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline17move) and row > (brickline17move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline18move) and row > (brickline18move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
			IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline20move) and row > (brickline20move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		
		IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline19move) and row > (brickline19move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
			IF(disp_ena = '1') THEN		--display time
			IF(row < (brickline20move) and row > (brickline20move-5) AND column > 1031 and column <1071) THEN
				red <= (OTHERS => '1');
				green	<= (OTHERS => '1');
				blue <= (OTHERS => '1');
				
						END IF;
		ELSE								--blanking time
		red <= (OTHERS => '0');
		green <= (OTHERS => '0');
		blue <= (OTHERS => '0');
		END IF;
		
		end if;
		--end last brick row vert **************************************************************************************************************
		end if;
	END PROCESS;
END behavior;