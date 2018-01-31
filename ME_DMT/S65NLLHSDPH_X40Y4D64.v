/*
    Copyright (c) 2009 SMIC
    Filename:      S65NLLHSDPH_X40Y4D64.v
    IP code :      S65NLLHSDPH
    Version:       1.7.0
    CreateDate:    Dec 10, 2016

    Verilog Model for Synchronous Dual-Port SRAM
    SMIC 65nm LL Logic Process

    Configuration: -instname S65NLLHSDPH_X40Y4D64 -rows 40 -bits 64 -mux 4 
    Redundancy: Off
    Bit-Write: Off
*/
/* DISCLAIMER                                                                      */
/*                                                                                 */  
/*   SMIC hereby provides the quality information to you but makes no claims,      */
/* promises or guarantees about the accuracy, completeness, or adequacy of the     */
/* information herein. The information contained herein is provided on an "AS IS"  */
/* basis without any warranty, and SMIC assumes no obligation to provide support   */
/* of any kind or otherwise maintain the information.                              */  
/*   SMIC disclaims any representation that the information does not infringe any  */
/* intellectual property rights or proprietary rights of any third parties. SMIC   */
/* makes no other warranty, whether express, implied or statutory as to any        */
/* matter whatsoever, including but not limited to the accuracy or sufficiency of  */
/* any information or the merchantability and fitness for a particular purpose.    */
/* Neither SMIC nor any of its representatives shall be liable for any cause of    */
/* action incurred to connect to this service.                                     */  
/*                                                                                 */
/* STATEMENT OF USE AND CONFIDENTIALITY                                            */  
/*                                                                                 */  
/*   The following/attached material contains confidential and proprietary         */  
/* information of SMIC. This material is based upon information which SMIC         */  
/* considers reliable, but SMIC neither represents nor warrants that such          */
/* information is accurate or complete, and it must not be relied upon as such.    */
/* This information was prepared for informational purposes and is for the use     */
/* by SMIC's customer only. SMIC reserves the right to make changes in the         */  
/* information at any time without notice.                                         */  
/*   No part of this information may be reproduced, transmitted, transcribed,      */  
/* stored in a retrieval system, or translated into any human or computer          */ 
/* language, in any form or by any means, electronic, mechanical, magnetic,        */  
/* optical, chemical, manual, or otherwise, without the prior written consent of   */
/* SMIC. Any unauthorized use or disclosure of this material is strictly           */  
/* prohibited and may be unlawful. By accepting this material, the receiving       */  
/* party shall be deemed to have acknowledged, accepted, and agreed to be bound    */
/* by the foregoing limitations and restrictions. Thank you.                       */  
/*                                                                                 */  

`timescale 1ns/1ps
`celldefine

module S65NLLHSDPH_X40Y4D64 (
                         QA,
                         QB,
			  CLKA,
			  CLKB,
			  CENA,
			  CENB,
			  WENA,
			  WENB,
			  AA,
			  AB,
			  DA,
			  DB);


// 这个参数有疑问，word应该是96，address width应该是7（补到8了）
  parameter	Bits = 64;
  parameter	Word_Depth = 160;
  parameter	Add_Width = 8;

  output          [Bits-1:0]      	QA;
  output          [Bits-1:0]      	QB;
  input		   		CLKA;
  input		   		CLKB;
  input		   		CENA;
  input		   		CENB;
  input		   		WENA;
  input		   		WENB;

  input	[Add_Width-1:0] 	AA;
  input	[Add_Width-1:0] 	AB;
  input	[Bits-1:0] 		DA;
  input	[Bits-1:0] 		DB;

  wire [Bits-1:0] 	QA_int;
  wire [Bits-1:0] 	QB_int;
  wire [Add_Width-1:0] 	AA_int;
  wire [Add_Width-1:0] 	AB_int;
  wire                 	CLKA_int;
  wire                 	CLKB_int;
  wire                 	CENA_int;
  wire                 	CENB_int;
  wire                 	WENA_int;
  wire                 	WENB_int;
  wire [Bits-1:0] 	DA_int;
  wire [Bits-1:0] 	DB_int;

  reg  [Bits-1:0] 	QA_latched;
  reg  [Bits-1:0] 	QB_latched;
  reg  [Add_Width-1:0] 	AA_latched;
  reg  [Add_Width-1:0] 	AB_latched;
  reg  [Bits-1:0] 	DA_latched;
  reg  [Bits-1:0] 	DB_latched;
  reg                  	CENA_latched;
  reg                  	CENB_latched;
  reg                  	LAST_CLKA;
  reg                  	LAST_CLKB;
  reg                  	WENA_latched;
  reg                  	WENB_latched;

  reg 			AA0_flag;
  reg 			AA1_flag;
  reg 			AA2_flag;
  reg 			AA3_flag;
  reg 			AA4_flag;
  reg 			AA5_flag;
  reg 			AA6_flag;
  reg 			AA7_flag;
  reg 			AB0_flag;
  reg 			AB1_flag;
  reg 			AB2_flag;
  reg 			AB3_flag;
  reg 			AB4_flag;
  reg 			AB5_flag;
  reg 			AB6_flag;
  reg 			AB7_flag;

  reg                	CENA_flag;
  reg                	CENB_flag;
  reg                   CLKA_CYC_flag;
  reg                   CLKB_CYC_flag;
  reg                   CLKA_H_flag;
  reg                   CLKB_H_flag;
  reg                   CLKA_L_flag;
  reg                   CLKB_L_flag;

  reg 			DA0_flag;
  reg 			DA1_flag;
  reg 			DA2_flag;
  reg 			DA3_flag;
  reg 			DA4_flag;
  reg 			DA5_flag;
  reg 			DA6_flag;
  reg 			DA7_flag;
  reg 			DA8_flag;
  reg 			DA9_flag;
  reg 			DA10_flag;
  reg 			DA11_flag;
  reg 			DA12_flag;
  reg 			DA13_flag;
  reg 			DA14_flag;
  reg 			DA15_flag;
  reg 			DA16_flag;
  reg 			DA17_flag;
  reg 			DA18_flag;
  reg 			DA19_flag;
  reg 			DA20_flag;
  reg 			DA21_flag;
  reg 			DA22_flag;
  reg 			DA23_flag;
  reg 			DA24_flag;
  reg 			DA25_flag;
  reg 			DA26_flag;
  reg 			DA27_flag;
  reg 			DA28_flag;
  reg 			DA29_flag;
  reg 			DA30_flag;
  reg 			DA31_flag;
  reg 			DA32_flag;
  reg 			DA33_flag;
  reg 			DA34_flag;
  reg 			DA35_flag;
  reg 			DA36_flag;
  reg 			DA37_flag;
  reg 			DA38_flag;
  reg 			DA39_flag;
  reg 			DA40_flag;
  reg 			DA41_flag;
  reg 			DA42_flag;
  reg 			DA43_flag;
  reg 			DA44_flag;
  reg 			DA45_flag;
  reg 			DA46_flag;
  reg 			DA47_flag;
  reg 			DA48_flag;
  reg 			DA49_flag;
  reg 			DA50_flag;
  reg 			DA51_flag;
  reg 			DA52_flag;
  reg 			DA53_flag;
  reg 			DA54_flag;
  reg 			DA55_flag;
  reg 			DA56_flag;
  reg 			DA57_flag;
  reg 			DA58_flag;
  reg 			DA59_flag;
  reg 			DA60_flag;
  reg 			DA61_flag;
  reg 			DA62_flag;
  reg 			DA63_flag;
  reg 			DB0_flag;
  reg 			DB1_flag;
  reg 			DB2_flag;
  reg 			DB3_flag;
  reg 			DB4_flag;
  reg 			DB5_flag;
  reg 			DB6_flag;
  reg 			DB7_flag;
  reg 			DB8_flag;
  reg 			DB9_flag;
  reg 			DB10_flag;
  reg 			DB11_flag;
  reg 			DB12_flag;
  reg 			DB13_flag;
  reg 			DB14_flag;
  reg 			DB15_flag;
  reg 			DB16_flag;
  reg 			DB17_flag;
  reg 			DB18_flag;
  reg 			DB19_flag;
  reg 			DB20_flag;
  reg 			DB21_flag;
  reg 			DB22_flag;
  reg 			DB23_flag;
  reg 			DB24_flag;
  reg 			DB25_flag;
  reg 			DB26_flag;
  reg 			DB27_flag;
  reg 			DB28_flag;
  reg 			DB29_flag;
  reg 			DB30_flag;
  reg 			DB31_flag;
  reg 			DB32_flag;
  reg 			DB33_flag;
  reg 			DB34_flag;
  reg 			DB35_flag;
  reg 			DB36_flag;
  reg 			DB37_flag;
  reg 			DB38_flag;
  reg 			DB39_flag;
  reg 			DB40_flag;
  reg 			DB41_flag;
  reg 			DB42_flag;
  reg 			DB43_flag;
  reg 			DB44_flag;
  reg 			DB45_flag;
  reg 			DB46_flag;
  reg 			DB47_flag;
  reg 			DB48_flag;
  reg 			DB49_flag;
  reg 			DB50_flag;
  reg 			DB51_flag;
  reg 			DB52_flag;
  reg 			DB53_flag;
  reg 			DB54_flag;
  reg 			DB55_flag;
  reg 			DB56_flag;
  reg 			DB57_flag;
  reg 			DB58_flag;
  reg 			DB59_flag;
  reg 			DB60_flag;
  reg 			DB61_flag;
  reg 			DB62_flag;
  reg 			DB63_flag;

reg                   WENA_flag; 
reg                   WENB_flag; 

reg                   VIOA_flag;
reg                   VIOB_flag;
reg                   LAST_VIOA_flag;
reg                   LAST_VIOB_flag;

reg [Add_Width-1:0]   AA_flag;
reg [Add_Width-1:0]   AB_flag;
reg [Bits-1:0]        DA_flag;
reg [Bits-1:0]        DB_flag;

 reg                   LAST_CENA_flag;
 reg                   LAST_CENB_flag;
 reg                   LAST_WENA_flag;
 reg                   LAST_WENB_flag;

 reg [Add_Width-1:0]   LAST_AA_flag;
 reg [Add_Width-1:0]   LAST_AB_flag;
 reg [Bits-1:0]        LAST_DA_flag;
 reg [Bits-1:0]        LAST_DB_flag;

  reg                   LAST_CLKA_CYC_flag;
  reg                   LAST_CLKB_CYC_flag;
  reg                   LAST_CLKA_H_flag;
  reg                   LAST_CLKB_H_flag;
  reg                   LAST_CLKA_L_flag;
  reg                   LAST_CLKB_L_flag;
  wire                  CEA_flag;
  wire                  CEB_flag;
  wire                    clkconfA_flag;
  wire                    clkconfB_flag;
  wire                    clkconf_flag;

  wire                  WRA_flag;
  wire                  WRB_flag;

  reg    [Bits-1:0] 	mem_array[Word_Depth-1:0];

  integer      i;
  integer      n;

 buf qa_buf[Bits-1:0] (QA, QA_int);
  buf qb_buf[Bits-1:0] (QB, QB_int);
  buf (CLKA_int, CLKA);
  buf (CLKB_int, CLKB);
  buf (CENA_int, CENA);
  buf (CENB_int, CENB);
  buf (WENA_int, WENA);
  buf (WENB_int, WENB);
  buf aa_buf[Add_Width-1:0] (AA_int, AA);
  buf ab_buf[Add_Width-1:0] (AB_int, AB);
  buf da_buf[Bits-1:0] (DA_int, DA);   
  buf db_buf[Bits-1:0] (DB_int, DB);   

  assign QA_int=QA_latched;
  assign QB_int=QB_latched;
  assign CEA_flag=!CENA_int;
  assign CEB_flag=!CENB_int;

  assign WRA_flag=(!CENA_int && !WENA_int);
  assign WRB_flag=(!CENB_int && !WENB_int);
  assign clkconfA_flag=(AA_int===AB_latched) && (CENA_int!==1'b1) && (CENB_latched!==1'b1);
  assign clkconfB_flag=(AB_int===AA_latched) && (CENB_int!==1'b1) && (CENA_latched!==1'b1);
  assign clkconf_flag=(AA_int===AB_int) && (CENA_int!==1'b1) && (CENB_int!==1'b1);

   always @(CLKA_int)
    begin
      casez({LAST_CLKA, CLKA_int})
        2'b01: begin
          CENA_latched = CENA_int;
          WENA_latched = WENA_int;
          AA_latched = AA_int;
          DA_latched = DA_int;
          rw_memA;
        end
        2'b10,
        2'bx?,
        2'b00,
        2'b11: ;
        2'b?x: begin
	  for(i=0;i<Word_Depth;i=i+1)
    	    mem_array[i]={Bits{1'bx}};
    	  QA_latched={Bits{1'bx}};
          rw_memA;
          end
      endcase
    LAST_CLKA=CLKA_int;
   end

always @(CLKB_int)
    begin
      casez({LAST_CLKB, CLKB_int})
        2'b01: begin
          CENB_latched = CENB_int;
          WENB_latched = WENB_int;
          AB_latched = AB_int;
          DB_latched = DB_int;
          rw_memB;
        end
        2'b10,
        2'bx?,
        2'b00,
        2'b11: ;
        2'b?x: begin
          for(i=0;i<Word_Depth;i=i+1)
    	    mem_array[i]={Bits{1'bx}};
QB_latched={Bits{1'bx}};
          rw_memA;
          end
      endcase
    LAST_CLKB=CLKB_int;
   end


  always @(CENA_flag
           	or WENA_flag
		or AA0_flag
		or AA1_flag
		or AA2_flag
		or AA3_flag
		or AA4_flag
		or AA5_flag
		or AA6_flag
		or AA7_flag
		or DA0_flag
		or DA1_flag
		or DA2_flag
		or DA3_flag
		or DA4_flag
		or DA5_flag
		or DA6_flag
		or DA7_flag
		or DA8_flag
		or DA9_flag
		or DA10_flag
		or DA11_flag
		or DA12_flag
		or DA13_flag
		or DA14_flag
		or DA15_flag
		or DA16_flag
		or DA17_flag
		or DA18_flag
		or DA19_flag
		or DA20_flag
		or DA21_flag
		or DA22_flag
		or DA23_flag
		or DA24_flag
		or DA25_flag
		or DA26_flag
		or DA27_flag
		or DA28_flag
		or DA29_flag
		or DA30_flag
		or DA31_flag
		or DA32_flag
		or DA33_flag
		or DA34_flag
		or DA35_flag
		or DA36_flag
		or DA37_flag
		or DA38_flag
		or DA39_flag
		or DA40_flag
		or DA41_flag
		or DA42_flag
		or DA43_flag
		or DA44_flag
		or DA45_flag
		or DA46_flag
		or DA47_flag
		or DA48_flag
		or DA49_flag
		or DA50_flag
		or DA51_flag
		or DA52_flag
		or DA53_flag
		or DA54_flag
		or DA55_flag
		or DA56_flag
		or DA57_flag
		or DA58_flag
		or DA59_flag
		or DA60_flag
		or DA61_flag
		or DA62_flag
		or DA63_flag
           	or CLKA_CYC_flag
           	or CLKA_H_flag
           	or CLKA_L_flag
                or VIOA_flag)
    begin
      update_flag_busA;
      CENA_latched = (CENA_flag!==LAST_CENA_flag) ? 1'bx : CENA_latched ;
      WENA_latched = (WENA_flag!==LAST_WENA_flag) ? 1'bx : WENA_latched ;
      for (n=0; n<Add_Width; n=n+1)
      AA_latched[n] = (AA_flag[n]!==LAST_AA_flag[n]) ? 1'bx : AA_latched[n] ;
      for (n=0; n<Bits; n=n+1)
      DA_latched[n] = (DA_flag[n]!==LAST_DA_flag[n]) ? 1'bx : DA_latched[n] ;
      LAST_CENA_flag = CENA_flag;
      LAST_WENA_flag = WENA_flag;
      LAST_AA_flag = AA_flag;
      LAST_DA_flag = DA_flag;
      LAST_CLKA_CYC_flag = CLKA_CYC_flag;
      LAST_CLKA_H_flag = CLKA_H_flag;
      LAST_CLKA_L_flag = CLKA_L_flag;
      if(VIOA_flag!==LAST_VIOA_flag)
      begin
          if(WENB_latched===1'b1)
            QB_latched={Bits{1'bx}};
          else
            begin
              if(WENA_latched===1'b1)
                QA_latched={Bits{1'bx}};
              else
                begin
                  if(^(AA_latched)===1'bx)
                    for(i=0;i<Word_Depth;i=i+1)
                      mem_array[i]={Bits{1'bx}};
                  else
                    mem_array[AA_latched]={Bits{1'bx}};
                end
            end
          LAST_VIOA_flag=VIOA_flag;
        end
      else
      rw_memA;
   end

always @(CENB_flag
           	or WENB_flag
		or AB0_flag
		or AB1_flag
		or AB2_flag
		or AB3_flag
		or AB4_flag
		or AB5_flag
		or AB6_flag
		or AB7_flag
		or DB0_flag
		or DB1_flag
		or DB2_flag
		or DB3_flag
		or DB4_flag
		or DB5_flag
		or DB6_flag
		or DB7_flag
		or DB8_flag
		or DB9_flag
		or DB10_flag
		or DB11_flag
		or DB12_flag
		or DB13_flag
		or DB14_flag
		or DB15_flag
		or DB16_flag
		or DB17_flag
		or DB18_flag
		or DB19_flag
		or DB20_flag
		or DB21_flag
		or DB22_flag
		or DB23_flag
		or DB24_flag
		or DB25_flag
		or DB26_flag
		or DB27_flag
		or DB28_flag
		or DB29_flag
		or DB30_flag
		or DB31_flag
		or DB32_flag
		or DB33_flag
		or DB34_flag
		or DB35_flag
		or DB36_flag
		or DB37_flag
		or DB38_flag
		or DB39_flag
		or DB40_flag
		or DB41_flag
		or DB42_flag
		or DB43_flag
		or DB44_flag
		or DB45_flag
		or DB46_flag
		or DB47_flag
		or DB48_flag
		or DB49_flag
		or DB50_flag
		or DB51_flag
		or DB52_flag
		or DB53_flag
		or DB54_flag
		or DB55_flag
		or DB56_flag
		or DB57_flag
		or DB58_flag
		or DB59_flag
		or DB60_flag
		or DB61_flag
		or DB62_flag
		or DB63_flag
           	or CLKB_CYC_flag
           	or CLKB_H_flag
           	or CLKB_L_flag
                or VIOB_flag)
begin
      update_flag_busB;
      CENB_latched = (CENB_flag!==LAST_CENB_flag) ? 1'bx : CENB_latched ;
      WENB_latched = (WENB_flag!==LAST_WENB_flag) ? 1'bx : WENB_latched ;
      for (n=0; n<Add_Width; n=n+1)
      AB_latched[n] = (AB_flag[n]!==LAST_AB_flag[n]) ? 1'bx : AB_latched[n] ;
      for (n=0; n<Bits; n=n+1)
      DB_latched[n] = (DB_flag[n]!==LAST_DB_flag[n]) ? 1'bx : DB_latched[n] ;
      LAST_CENB_flag = CENB_flag;
      LAST_WENB_flag = WENB_flag;
      LAST_AB_flag = AB_flag;
      LAST_DB_flag = DB_flag;
      LAST_CLKB_CYC_flag = CLKB_CYC_flag;
      LAST_CLKB_H_flag = CLKB_H_flag;
      LAST_CLKB_L_flag = CLKB_L_flag;
      if(VIOB_flag!==LAST_VIOB_flag)
        begin
          if(WENA_latched===1'b1)
            QA_latched={Bits{1'bx}};
          else
            begin
              if(WENB_latched===1'b1)
                QB_latched={Bits{1'bx}};
              else
                begin
                  if(^(AB_latched)===1'bx)
                    for(i=0;i<Word_Depth;i=i+1)
                      mem_array[i]={Bits{1'bx}};
                  else
                    mem_array[AB_latched]={Bits{1'bx}};
                end
            end
          LAST_VIOB_flag=VIOB_flag;
        end
      else
      rw_memB;
   end

  task rw_memA;
    begin
      if(CENA_latched==1'b0)
        begin
	  if(WENA_latched==1'b1) 	
   	    begin
   	      if(^(AA_latched)==1'bx)
   	        QA_latched={Bits{1'bx}};
   	      else
		QA_latched=mem_array[AA_latched];
       	    end
          else if(WENA_latched==1'b0)
   	    begin
   	      if(^(AA_latched)==1'bx)
   	        begin
                  x_mem;
   	          QA_latched={Bits{1'bx}};
   	        end   	        
   	      else
		begin
   	          mem_array[AA_latched]=DA_latched;
   	          QA_latched=mem_array[AA_latched];
   	        end
   	    end
	  else 
     	    begin
   	      QA_latched={Bits{1'bx}};
   	      if(^(AA_latched)===1'bx)
                for(i=0;i<Word_Depth;i=i+1)
   		  mem_array[i]={Bits{1'bx}};   	        
              else
		mem_array[AA_latched]={Bits{1'bx}};
   	    end
	end  	    	    
      else if(CENA_latched===1'bx)
        begin
	  if(WENA_latched===1'b1)
   	    QA_latched={Bits{1'bx}};
	  else 
	    begin
   	      QA_latched={Bits{1'bx}};
	      if(^(AA_latched)===1'bx)
                x_mem;
              else
		mem_array[AA_latched]={Bits{1'bx}};
   	    end	      	    	  
        end
    end
  endtask

  task rw_memB;
    begin
      if(CENB_latched==1'b0)
        begin
	  if(WENB_latched==1'b1) 	
   	    begin
   	      if(^(AB_latched)==1'bx)
   	        QB_latched={Bits{1'bx}};
   	      else
		QB_latched=mem_array[AB_latched];
       	    end
          else if(WENB_latched==1'b0)
   	    begin
   	      if(^(AB_latched)==1'bx)
   	        begin
                  x_mem;
   	          QB_latched={Bits{1'bx}};
   	        end   	        
   	      else
		begin
   	          mem_array[AB_latched]=DB_latched;
   	          QB_latched=mem_array[AB_latched];
   	        end
   	    end
	  else 
     	    begin
   	      QB_latched={Bits{1'bx}};
   	      if(^(AB_latched)===1'bx)
                for(i=0;i<Word_Depth;i=i+1)
   		  mem_array[i]={Bits{1'bx}};   	        
              else
		mem_array[AB_latched]={Bits{1'bx}};
   	    end
	end  	    	    
      else if(CENB_latched===1'bx)
        begin
	  if(WENB_latched===1'b1)
   	    QA_latched={Bits{1'bx}};
	  else 
	    begin
   	      QB_latched={Bits{1'bx}};
	      if(^(AA_latched)===1'bx)
                x_mem;
              else
		mem_array[AB_latched]={Bits{1'bx}};
   	    end	      	    	  
        end
    end
  endtask

   task x_mem;
   begin
     for(i=0;i<Word_Depth;i=i+1)
     mem_array[i]={Bits{1'bx}};
   end
   endtask

  task update_flag_busA;
  begin
    AA_flag = {
		AA7_flag,
		AA6_flag,
		AA5_flag,
		AA4_flag,
		AA3_flag,
		AA2_flag,
		AA1_flag,
                AA0_flag};
    DA_flag = {
		DA63_flag,
		DA62_flag,
		DA61_flag,
		DA60_flag,
		DA59_flag,
		DA58_flag,
		DA57_flag,
		DA56_flag,
		DA55_flag,
		DA54_flag,
		DA53_flag,
		DA52_flag,
		DA51_flag,
		DA50_flag,
		DA49_flag,
		DA48_flag,
		DA47_flag,
		DA46_flag,
		DA45_flag,
		DA44_flag,
		DA43_flag,
		DA42_flag,
		DA41_flag,
		DA40_flag,
		DA39_flag,
		DA38_flag,
		DA37_flag,
		DA36_flag,
		DA35_flag,
		DA34_flag,
		DA33_flag,
		DA32_flag,
		DA31_flag,
		DA30_flag,
		DA29_flag,
		DA28_flag,
		DA27_flag,
		DA26_flag,
		DA25_flag,
		DA24_flag,
		DA23_flag,
		DA22_flag,
		DA21_flag,
		DA20_flag,
		DA19_flag,
		DA18_flag,
		DA17_flag,
		DA16_flag,
		DA15_flag,
		DA14_flag,
		DA13_flag,
		DA12_flag,
		DA11_flag,
		DA10_flag,
		DA9_flag,
		DA8_flag,
		DA7_flag,
		DA6_flag,
		DA5_flag,
		DA4_flag,
		DA3_flag,
		DA2_flag,
		DA1_flag,
                DA0_flag};
   end
   endtask

  task update_flag_busB;
  begin
    AB_flag = {
		AB7_flag,
		AB6_flag,
		AB5_flag,
		AB4_flag,
		AB3_flag,
		AB2_flag,
		AB1_flag,
                AB0_flag};
    DB_flag = {
		DB63_flag,
		DB62_flag,
		DB61_flag,
		DB60_flag,
		DB59_flag,
		DB58_flag,
		DB57_flag,
		DB56_flag,
		DB55_flag,
		DB54_flag,
		DB53_flag,
		DB52_flag,
		DB51_flag,
		DB50_flag,
		DB49_flag,
		DB48_flag,
		DB47_flag,
		DB46_flag,
		DB45_flag,
		DB44_flag,
		DB43_flag,
		DB42_flag,
		DB41_flag,
		DB40_flag,
		DB39_flag,
		DB38_flag,
		DB37_flag,
		DB36_flag,
		DB35_flag,
		DB34_flag,
		DB33_flag,
		DB32_flag,
		DB31_flag,
		DB30_flag,
		DB29_flag,
		DB28_flag,
		DB27_flag,
		DB26_flag,
		DB25_flag,
		DB24_flag,
		DB23_flag,
		DB22_flag,
		DB21_flag,
		DB20_flag,
		DB19_flag,
		DB18_flag,
		DB17_flag,
		DB16_flag,
		DB15_flag,
		DB14_flag,
		DB13_flag,
		DB12_flag,
		DB11_flag,
		DB10_flag,
		DB9_flag,
		DB8_flag,
		DB7_flag,
		DB6_flag,
		DB5_flag,
		DB4_flag,
		DB3_flag,
		DB2_flag,
		DB1_flag,
                DB0_flag};
   end
   endtask

  specify
    (posedge CLKA => (QA[0] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[1] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[2] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[3] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[4] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[5] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[6] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[7] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[8] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[9] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[10] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[11] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[12] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[13] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[14] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[15] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[16] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[17] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[18] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[19] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[20] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[21] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[22] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[23] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[24] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[25] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[26] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[27] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[28] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[29] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[30] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[31] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[32] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[33] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[34] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[35] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[36] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[37] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[38] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[39] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[40] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[41] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[42] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[43] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[44] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[45] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[46] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[47] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[48] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[49] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[50] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[51] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[52] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[53] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[54] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[55] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[56] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[57] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[58] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[59] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[60] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[61] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[62] : 1'bx))=(1.000,1.000);
    (posedge CLKA => (QA[63] : 1'bx))=(1.000,1.000);

    (posedge CLKB => (QB[0] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[1] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[2] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[3] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[4] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[5] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[6] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[7] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[8] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[9] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[10] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[11] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[12] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[13] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[14] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[15] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[16] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[17] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[18] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[19] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[20] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[21] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[22] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[23] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[24] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[25] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[26] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[27] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[28] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[29] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[30] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[31] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[32] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[33] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[34] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[35] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[36] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[37] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[38] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[39] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[40] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[41] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[42] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[43] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[44] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[45] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[46] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[47] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[48] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[49] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[50] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[51] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[52] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[53] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[54] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[55] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[56] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[57] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[58] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[59] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[60] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[61] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[62] : 1'bx))=(1.000,1.000);
    (posedge CLKB => (QB[63] : 1'bx))=(1.000,1.000);

    $setuphold(posedge CLKA &&& CEA_flag,posedge AA[0],1.000,0.500,AA0_flag);
    $setuphold(posedge CLKA &&& CEA_flag,negedge AA[0],1.000,0.500,AA0_flag);
    $setuphold(posedge CLKA &&& CEA_flag,posedge AA[1],1.000,0.500,AA1_flag);
    $setuphold(posedge CLKA &&& CEA_flag,negedge AA[1],1.000,0.500,AA1_flag);
    $setuphold(posedge CLKA &&& CEA_flag,posedge AA[2],1.000,0.500,AA2_flag);
    $setuphold(posedge CLKA &&& CEA_flag,negedge AA[2],1.000,0.500,AA2_flag);
    $setuphold(posedge CLKA &&& CEA_flag,posedge AA[3],1.000,0.500,AA3_flag);
    $setuphold(posedge CLKA &&& CEA_flag,negedge AA[3],1.000,0.500,AA3_flag);
    $setuphold(posedge CLKA &&& CEA_flag,posedge AA[4],1.000,0.500,AA4_flag);
    $setuphold(posedge CLKA &&& CEA_flag,negedge AA[4],1.000,0.500,AA4_flag);
    $setuphold(posedge CLKA &&& CEA_flag,posedge AA[5],1.000,0.500,AA5_flag);
    $setuphold(posedge CLKA &&& CEA_flag,negedge AA[5],1.000,0.500,AA5_flag);
    $setuphold(posedge CLKA &&& CEA_flag,posedge AA[6],1.000,0.500,AA6_flag);
    $setuphold(posedge CLKA &&& CEA_flag,negedge AA[6],1.000,0.500,AA6_flag);
    $setuphold(posedge CLKA &&& CEA_flag,posedge AA[7],1.000,0.500,AA7_flag);
    $setuphold(posedge CLKA &&& CEA_flag,negedge AA[7],1.000,0.500,AA7_flag);

    $setuphold(posedge CLKB &&& CEB_flag,posedge AB[0],1.000,0.500,AB0_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge AB[0],1.000,0.500,AB0_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge AB[1],1.000,0.500,AB1_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge AB[1],1.000,0.500,AB1_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge AB[2],1.000,0.500,AB2_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge AB[2],1.000,0.500,AB2_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge AB[3],1.000,0.500,AB3_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge AB[3],1.000,0.500,AB3_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge AB[4],1.000,0.500,AB4_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge AB[4],1.000,0.500,AB4_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge AB[5],1.000,0.500,AB5_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge AB[5],1.000,0.500,AB5_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge AB[6],1.000,0.500,AB6_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge AB[6],1.000,0.500,AB6_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge AB[7],1.000,0.500,AB7_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge AB[7],1.000,0.500,AB7_flag);

    $setuphold(posedge CLKA,posedge CENA,1.000,0.500,CENA_flag);
    $setuphold(posedge CLKA,negedge CENA,1.000,0.500,CENA_flag);
    $period(posedge CLKA,1.20015,CLKA_CYC_flag);
    $width(posedge CLKA,0.360045,0,CLKA_H_flag);
    $width(negedge CLKA,0.360045,0,CLKA_L_flag);

    $setuphold(posedge CLKB,posedge CENB,1.000,0.500,CENB_flag);
    $setuphold(posedge CLKB,negedge CENB,1.000,0.500,CENB_flag);
    $period(posedge CLKB,1.20015,CLKB_CYC_flag);
    $width(posedge CLKB,0.360045,0,CLKB_H_flag);
    $width(negedge CLKB,0.360045,0,CLKB_L_flag);
    
    $setup(posedge CLKA,posedge CLKB &&& clkconfB_flag,2.000,VIOB_flag);
    $hold(posedge CLKA,posedge CLKB &&& clkconf_flag,0.010,VIOB_flag);
    $setup(posedge CLKB,posedge CLKA &&& clkconfA_flag,2.000,VIOA_flag);
    $hold(posedge CLKB,posedge CLKA &&& clkconf_flag,0.010,VIOA_flag);

    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[0],1.000,0.500,DA0_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[0],1.000,0.500,DA0_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[1],1.000,0.500,DA1_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[1],1.000,0.500,DA1_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[2],1.000,0.500,DA2_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[2],1.000,0.500,DA2_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[3],1.000,0.500,DA3_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[3],1.000,0.500,DA3_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[4],1.000,0.500,DA4_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[4],1.000,0.500,DA4_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[5],1.000,0.500,DA5_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[5],1.000,0.500,DA5_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[6],1.000,0.500,DA6_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[6],1.000,0.500,DA6_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[7],1.000,0.500,DA7_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[7],1.000,0.500,DA7_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[8],1.000,0.500,DA8_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[8],1.000,0.500,DA8_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[9],1.000,0.500,DA9_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[9],1.000,0.500,DA9_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[10],1.000,0.500,DA10_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[10],1.000,0.500,DA10_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[11],1.000,0.500,DA11_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[11],1.000,0.500,DA11_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[12],1.000,0.500,DA12_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[12],1.000,0.500,DA12_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[13],1.000,0.500,DA13_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[13],1.000,0.500,DA13_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[14],1.000,0.500,DA14_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[14],1.000,0.500,DA14_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[15],1.000,0.500,DA15_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[15],1.000,0.500,DA15_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[16],1.000,0.500,DA16_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[16],1.000,0.500,DA16_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[17],1.000,0.500,DA17_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[17],1.000,0.500,DA17_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[18],1.000,0.500,DA18_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[18],1.000,0.500,DA18_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[19],1.000,0.500,DA19_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[19],1.000,0.500,DA19_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[20],1.000,0.500,DA20_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[20],1.000,0.500,DA20_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[21],1.000,0.500,DA21_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[21],1.000,0.500,DA21_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[22],1.000,0.500,DA22_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[22],1.000,0.500,DA22_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[23],1.000,0.500,DA23_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[23],1.000,0.500,DA23_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[24],1.000,0.500,DA24_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[24],1.000,0.500,DA24_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[25],1.000,0.500,DA25_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[25],1.000,0.500,DA25_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[26],1.000,0.500,DA26_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[26],1.000,0.500,DA26_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[27],1.000,0.500,DA27_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[27],1.000,0.500,DA27_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[28],1.000,0.500,DA28_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[28],1.000,0.500,DA28_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[29],1.000,0.500,DA29_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[29],1.000,0.500,DA29_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[30],1.000,0.500,DA30_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[30],1.000,0.500,DA30_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[31],1.000,0.500,DA31_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[31],1.000,0.500,DA31_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[32],1.000,0.500,DA32_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[32],1.000,0.500,DA32_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[33],1.000,0.500,DA33_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[33],1.000,0.500,DA33_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[34],1.000,0.500,DA34_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[34],1.000,0.500,DA34_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[35],1.000,0.500,DA35_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[35],1.000,0.500,DA35_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[36],1.000,0.500,DA36_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[36],1.000,0.500,DA36_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[37],1.000,0.500,DA37_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[37],1.000,0.500,DA37_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[38],1.000,0.500,DA38_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[38],1.000,0.500,DA38_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[39],1.000,0.500,DA39_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[39],1.000,0.500,DA39_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[40],1.000,0.500,DA40_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[40],1.000,0.500,DA40_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[41],1.000,0.500,DA41_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[41],1.000,0.500,DA41_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[42],1.000,0.500,DA42_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[42],1.000,0.500,DA42_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[43],1.000,0.500,DA43_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[43],1.000,0.500,DA43_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[44],1.000,0.500,DA44_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[44],1.000,0.500,DA44_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[45],1.000,0.500,DA45_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[45],1.000,0.500,DA45_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[46],1.000,0.500,DA46_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[46],1.000,0.500,DA46_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[47],1.000,0.500,DA47_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[47],1.000,0.500,DA47_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[48],1.000,0.500,DA48_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[48],1.000,0.500,DA48_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[49],1.000,0.500,DA49_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[49],1.000,0.500,DA49_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[50],1.000,0.500,DA50_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[50],1.000,0.500,DA50_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[51],1.000,0.500,DA51_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[51],1.000,0.500,DA51_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[52],1.000,0.500,DA52_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[52],1.000,0.500,DA52_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[53],1.000,0.500,DA53_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[53],1.000,0.500,DA53_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[54],1.000,0.500,DA54_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[54],1.000,0.500,DA54_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[55],1.000,0.500,DA55_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[55],1.000,0.500,DA55_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[56],1.000,0.500,DA56_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[56],1.000,0.500,DA56_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[57],1.000,0.500,DA57_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[57],1.000,0.500,DA57_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[58],1.000,0.500,DA58_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[58],1.000,0.500,DA58_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[59],1.000,0.500,DA59_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[59],1.000,0.500,DA59_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[60],1.000,0.500,DA60_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[60],1.000,0.500,DA60_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[61],1.000,0.500,DA61_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[61],1.000,0.500,DA61_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[62],1.000,0.500,DA62_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[62],1.000,0.500,DA62_flag);
    $setuphold(posedge CLKA &&& WRA_flag,posedge DA[63],1.000,0.500,DA63_flag);
    $setuphold(posedge CLKA &&& WRA_flag,negedge DA[63],1.000,0.500,DA63_flag);
    $setuphold(posedge CLKA &&& CEA_flag,posedge WENA,1.000,0.500,WENA_flag);
    $setuphold(posedge CLKA &&& CEA_flag,negedge WENA,1.000,0.500,WENA_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[0],1.000,0.500,DB0_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[0],1.000,0.500,DB0_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[1],1.000,0.500,DB1_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[1],1.000,0.500,DB1_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[2],1.000,0.500,DB2_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[2],1.000,0.500,DB2_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[3],1.000,0.500,DB3_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[3],1.000,0.500,DB3_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[4],1.000,0.500,DB4_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[4],1.000,0.500,DB4_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[5],1.000,0.500,DB5_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[5],1.000,0.500,DB5_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[6],1.000,0.500,DB6_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[6],1.000,0.500,DB6_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[7],1.000,0.500,DB7_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[7],1.000,0.500,DB7_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[8],1.000,0.500,DB8_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[8],1.000,0.500,DB8_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[9],1.000,0.500,DB9_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[9],1.000,0.500,DB9_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[10],1.000,0.500,DB10_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[10],1.000,0.500,DB10_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[11],1.000,0.500,DB11_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[11],1.000,0.500,DB11_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[12],1.000,0.500,DB12_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[12],1.000,0.500,DB12_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[13],1.000,0.500,DB13_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[13],1.000,0.500,DB13_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[14],1.000,0.500,DB14_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[14],1.000,0.500,DB14_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[15],1.000,0.500,DB15_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[15],1.000,0.500,DB15_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[16],1.000,0.500,DB16_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[16],1.000,0.500,DB16_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[17],1.000,0.500,DB17_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[17],1.000,0.500,DB17_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[18],1.000,0.500,DB18_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[18],1.000,0.500,DB18_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[19],1.000,0.500,DB19_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[19],1.000,0.500,DB19_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[20],1.000,0.500,DB20_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[20],1.000,0.500,DB20_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[21],1.000,0.500,DB21_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[21],1.000,0.500,DB21_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[22],1.000,0.500,DB22_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[22],1.000,0.500,DB22_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[23],1.000,0.500,DB23_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[23],1.000,0.500,DB23_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[24],1.000,0.500,DB24_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[24],1.000,0.500,DB24_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[25],1.000,0.500,DB25_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[25],1.000,0.500,DB25_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[26],1.000,0.500,DB26_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[26],1.000,0.500,DB26_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[27],1.000,0.500,DB27_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[27],1.000,0.500,DB27_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[28],1.000,0.500,DB28_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[28],1.000,0.500,DB28_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[29],1.000,0.500,DB29_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[29],1.000,0.500,DB29_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[30],1.000,0.500,DB30_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[30],1.000,0.500,DB30_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[31],1.000,0.500,DB31_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[31],1.000,0.500,DB31_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[32],1.000,0.500,DB32_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[32],1.000,0.500,DB32_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[33],1.000,0.500,DB33_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[33],1.000,0.500,DB33_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[34],1.000,0.500,DB34_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[34],1.000,0.500,DB34_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[35],1.000,0.500,DB35_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[35],1.000,0.500,DB35_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[36],1.000,0.500,DB36_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[36],1.000,0.500,DB36_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[37],1.000,0.500,DB37_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[37],1.000,0.500,DB37_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[38],1.000,0.500,DB38_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[38],1.000,0.500,DB38_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[39],1.000,0.500,DB39_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[39],1.000,0.500,DB39_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[40],1.000,0.500,DB40_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[40],1.000,0.500,DB40_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[41],1.000,0.500,DB41_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[41],1.000,0.500,DB41_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[42],1.000,0.500,DB42_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[42],1.000,0.500,DB42_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[43],1.000,0.500,DB43_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[43],1.000,0.500,DB43_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[44],1.000,0.500,DB44_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[44],1.000,0.500,DB44_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[45],1.000,0.500,DB45_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[45],1.000,0.500,DB45_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[46],1.000,0.500,DB46_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[46],1.000,0.500,DB46_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[47],1.000,0.500,DB47_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[47],1.000,0.500,DB47_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[48],1.000,0.500,DB48_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[48],1.000,0.500,DB48_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[49],1.000,0.500,DB49_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[49],1.000,0.500,DB49_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[50],1.000,0.500,DB50_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[50],1.000,0.500,DB50_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[51],1.000,0.500,DB51_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[51],1.000,0.500,DB51_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[52],1.000,0.500,DB52_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[52],1.000,0.500,DB52_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[53],1.000,0.500,DB53_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[53],1.000,0.500,DB53_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[54],1.000,0.500,DB54_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[54],1.000,0.500,DB54_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[55],1.000,0.500,DB55_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[55],1.000,0.500,DB55_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[56],1.000,0.500,DB56_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[56],1.000,0.500,DB56_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[57],1.000,0.500,DB57_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[57],1.000,0.500,DB57_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[58],1.000,0.500,DB58_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[58],1.000,0.500,DB58_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[59],1.000,0.500,DB59_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[59],1.000,0.500,DB59_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[60],1.000,0.500,DB60_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[60],1.000,0.500,DB60_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[61],1.000,0.500,DB61_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[61],1.000,0.500,DB61_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[62],1.000,0.500,DB62_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[62],1.000,0.500,DB62_flag);
    $setuphold(posedge CLKB &&& WRB_flag,posedge DB[63],1.000,0.500,DB63_flag);
    $setuphold(posedge CLKB &&& WRB_flag,negedge DB[63],1.000,0.500,DB63_flag);
    $setuphold(posedge CLKB &&& CEB_flag,posedge WENB,1.000,0.500,WENB_flag);
    $setuphold(posedge CLKB &&& CEB_flag,negedge WENB,1.000,0.500,WENB_flag);

  endspecify
endmodule

`endcelldefine
