//this module is used to seperate the 8*32 Pixels matrix,and combine to 8 rows(1*32 pixels one row)
`define PIXEL 8
module Row_sep(             //功能待确认
input [8*32*`PIXEL-1:0]ref_ou,
output [32*`PIXEL-1:0] ref_row1,
output [32*`PIXEL-1:0] ref_row2,
output [32*`PIXEL-1:0] ref_row3,
output [32*`PIXEL-1:0] ref_row4,
output [32*`PIXEL-1:0] ref_row5,
output [32*`PIXEL-1:0] ref_row6,
output [32*`PIXEL-1:0] ref_row7,
output [32*`PIXEL-1:0] ref_row8
);

assign ref_row1={   ref_ou[(0*8+1)*`PIXEL-1:(0*8+1)*`PIXEL-`PIXEL],  ref_ou[(1*8+1)*`PIXEL-1:(1*8+1)*`PIXEL-`PIXEL],  ref_ou[(2*8+1)*`PIXEL-1:(2*8+1)*`PIXEL-`PIXEL],  ref_ou[(3*8+1)*`PIXEL-1:(3*8+1)*`PIXEL-`PIXEL],
					ref_ou[(4*8+1)*`PIXEL-1:(4*8+1)*`PIXEL-`PIXEL],  ref_ou[(5*8+1)*`PIXEL-1:(5*8+1)*`PIXEL-`PIXEL],  ref_ou[(6*8+1)*`PIXEL-1:(6*8+1)*`PIXEL-`PIXEL],  ref_ou[(7*8+1)*`PIXEL-1:(7*8+1)*`PIXEL-`PIXEL],
					ref_ou[(8*8+1)*`PIXEL-1:(8*8+1)*`PIXEL-`PIXEL],  ref_ou[(9*8+1)*`PIXEL-1:(9*8+1)*`PIXEL-`PIXEL],  ref_ou[(10*8+1)*`PIXEL-1:(10*8+1)*`PIXEL-`PIXEL],ref_ou[(11*8+1)*`PIXEL-1:(11*8+1)*`PIXEL-`PIXEL],
					ref_ou[(12*8+1)*`PIXEL-1:(12*8+1)*`PIXEL-`PIXEL],ref_ou[(13*8+1)*`PIXEL-1:(13*8+1)*`PIXEL-`PIXEL],ref_ou[(14*8+1)*`PIXEL-1:(14*8+1)*`PIXEL-`PIXEL],ref_ou[(15*8+1)*`PIXEL-1:(15*8+1)*`PIXEL-`PIXEL],
					ref_ou[(16*8+1)*`PIXEL-1:(16*8+1)*`PIXEL-`PIXEL],ref_ou[(17*8+1)*`PIXEL-1:(17*8+1)*`PIXEL-`PIXEL],ref_ou[(18*8+1)*`PIXEL-1:(18*8+1)*`PIXEL-`PIXEL],ref_ou[(19*8+1)*`PIXEL-1:(19*8+1)*`PIXEL-`PIXEL],
					ref_ou[(20*8+1)*`PIXEL-1:(20*8+1)*`PIXEL-`PIXEL],ref_ou[(21*8+1)*`PIXEL-1:(21*8+1)*`PIXEL-`PIXEL],ref_ou[(22*8+1)*`PIXEL-1:(22*8+1)*`PIXEL-`PIXEL],ref_ou[(23*8+1)*`PIXEL-1:(23*8+1)*`PIXEL-`PIXEL],
					ref_ou[(24*8+1)*`PIXEL-1:(24*8+1)*`PIXEL-`PIXEL],ref_ou[(25*8+1)*`PIXEL-1:(25*8+1)*`PIXEL-`PIXEL],ref_ou[(26*8+1)*`PIXEL-1:(26*8+1)*`PIXEL-`PIXEL],ref_ou[(27*8+1)*`PIXEL-1:(27*8+1)*`PIXEL-`PIXEL],
					ref_ou[(28*8+1)*`PIXEL-1:(28*8+1)*`PIXEL-`PIXEL],ref_ou[(29*8+1)*`PIXEL-1:(29*8+1)*`PIXEL-`PIXEL],ref_ou[(30*8+1)*`PIXEL-1:(30*8+1)*`PIXEL-`PIXEL],ref_ou[(31*8+1)*`PIXEL-1:(31*8+1)*`PIXEL-`PIXEL]};
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
assign ref_row2={   ref_ou[(0*8+2)*`PIXEL-1:(0*8+2)*`PIXEL-`PIXEL],  ref_ou[(1*8+2)*`PIXEL-1:(1*8+2)*`PIXEL-`PIXEL],  ref_ou[(2*8+2)*`PIXEL-1:(2*8+2)*`PIXEL-`PIXEL],  ref_ou[(3*8+2)*`PIXEL-1:(3*8+2)*`PIXEL-`PIXEL],
					ref_ou[(4*8+2)*`PIXEL-1:(4*8+2)*`PIXEL-`PIXEL],	 ref_ou[(5*8+2)*`PIXEL-1:(5*8+2)*`PIXEL-`PIXEL],  ref_ou[(6*8+2)*`PIXEL-1:(6*8+2)*`PIXEL-`PIXEL],  ref_ou[(7*8+2)*`PIXEL-1:(7*8+2)*`PIXEL-`PIXEL],
					ref_ou[(8*8+2)*`PIXEL-1:(8*8+2)*`PIXEL-`PIXEL],  ref_ou[(9*8+2)*`PIXEL-1:(9*8+2)*`PIXEL-`PIXEL],  ref_ou[(10*8+2)*`PIXEL-1:(10*8+2)*`PIXEL-`PIXEL],ref_ou[(11*8+2)*`PIXEL-1:(11*8+2)*`PIXEL-`PIXEL],
					ref_ou[(12*8+2)*`PIXEL-1:(12*8+2)*`PIXEL-`PIXEL],ref_ou[(13*8+2)*`PIXEL-1:(13*8+2)*`PIXEL-`PIXEL],ref_ou[(14*8+2)*`PIXEL-1:(14*8+2)*`PIXEL-`PIXEL],ref_ou[(15*8+2)*`PIXEL-1:(15*8+2)*`PIXEL-`PIXEL],
					ref_ou[(16*8+2)*`PIXEL-1:(16*8+2)*`PIXEL-`PIXEL],ref_ou[(17*8+2)*`PIXEL-1:(17*8+2)*`PIXEL-`PIXEL],ref_ou[(18*8+2)*`PIXEL-1:(18*8+2)*`PIXEL-`PIXEL],ref_ou[(19*8+2)*`PIXEL-1:(19*8+2)*`PIXEL-`PIXEL],
					ref_ou[(20*8+2)*`PIXEL-1:(20*8+2)*`PIXEL-`PIXEL],ref_ou[(21*8+2)*`PIXEL-1:(21*8+2)*`PIXEL-`PIXEL],ref_ou[(22*8+2)*`PIXEL-1:(22*8+2)*`PIXEL-`PIXEL],ref_ou[(23*8+2)*`PIXEL-1:(23*8+2)*`PIXEL-`PIXEL],
					ref_ou[(24*8+2)*`PIXEL-1:(24*8+2)*`PIXEL-`PIXEL],ref_ou[(25*8+2)*`PIXEL-1:(25*8+2)*`PIXEL-`PIXEL],ref_ou[(26*8+2)*`PIXEL-1:(26*8+2)*`PIXEL-`PIXEL],ref_ou[(27*8+2)*`PIXEL-1:(27*8+2)*`PIXEL-`PIXEL],
					ref_ou[(28*8+2)*`PIXEL-1:(28*8+2)*`PIXEL-`PIXEL],ref_ou[(29*8+2)*`PIXEL-1:(29*8+2)*`PIXEL-`PIXEL],ref_ou[(30*8+2)*`PIXEL-1:(30*8+2)*`PIXEL-`PIXEL],ref_ou[(31*8+2)*`PIXEL-1:(31*8+2)*`PIXEL-`PIXEL]};					
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
assign ref_row3={   ref_ou[(0*8+3)*`PIXEL-1:(0*8+3)*`PIXEL-`PIXEL],  ref_ou[(1*8+3)*`PIXEL-1:(1*8+3)*`PIXEL-`PIXEL],  ref_ou[(2*8+3)*`PIXEL-1:(2*8+3)*`PIXEL-`PIXEL],  ref_ou[(3*8+3)*`PIXEL-1:(3*8+3)*`PIXEL-`PIXEL],
					ref_ou[(4*8+3)*`PIXEL-1:(4*8+3)*`PIXEL-`PIXEL],  ref_ou[(5*8+3)*`PIXEL-1:(5*8+3)*`PIXEL-`PIXEL],  ref_ou[(6*8+3)*`PIXEL-1:(6*8+3)*`PIXEL-`PIXEL],  ref_ou[(7*8+3)*`PIXEL-1:(7*8+3)*`PIXEL-`PIXEL],
					ref_ou[(8*8+3)*`PIXEL-1:(8*8+3)*`PIXEL-`PIXEL],  ref_ou[(9*8+3)*`PIXEL-1:(9*8+3)*`PIXEL-`PIXEL],  ref_ou[(10*8+3)*`PIXEL-1:(10*8+3)*`PIXEL-`PIXEL],ref_ou[(11*8+3)*`PIXEL-1:(11*8+3)*`PIXEL-`PIXEL],
					ref_ou[(12*8+3)*`PIXEL-1:(12*8+3)*`PIXEL-`PIXEL],ref_ou[(13*8+3)*`PIXEL-1:(13*8+3)*`PIXEL-`PIXEL],ref_ou[(14*8+3)*`PIXEL-1:(14*8+3)*`PIXEL-`PIXEL],ref_ou[(15*8+3)*`PIXEL-1:(15*8+3)*`PIXEL-`PIXEL],
					ref_ou[(16*8+3)*`PIXEL-1:(16*8+3)*`PIXEL-`PIXEL],ref_ou[(17*8+3)*`PIXEL-1:(17*8+3)*`PIXEL-`PIXEL],ref_ou[(18*8+3)*`PIXEL-1:(18*8+3)*`PIXEL-`PIXEL],ref_ou[(19*8+3)*`PIXEL-1:(19*8+3)*`PIXEL-`PIXEL],
					ref_ou[(20*8+3)*`PIXEL-1:(20*8+3)*`PIXEL-`PIXEL],ref_ou[(21*8+3)*`PIXEL-1:(21*8+3)*`PIXEL-`PIXEL],ref_ou[(22*8+3)*`PIXEL-1:(22*8+3)*`PIXEL-`PIXEL],ref_ou[(23*8+3)*`PIXEL-1:(23*8+3)*`PIXEL-`PIXEL],
					ref_ou[(24*8+3)*`PIXEL-1:(24*8+3)*`PIXEL-`PIXEL],ref_ou[(25*8+3)*`PIXEL-1:(25*8+3)*`PIXEL-`PIXEL],ref_ou[(26*8+3)*`PIXEL-1:(26*8+3)*`PIXEL-`PIXEL],ref_ou[(27*8+3)*`PIXEL-1:(27*8+3)*`PIXEL-`PIXEL],
					ref_ou[(28*8+3)*`PIXEL-1:(28*8+3)*`PIXEL-`PIXEL],ref_ou[(29*8+3)*`PIXEL-1:(29*8+3)*`PIXEL-`PIXEL],ref_ou[(30*8+3)*`PIXEL-1:(30*8+3)*`PIXEL-`PIXEL],ref_ou[(31*8+3)*`PIXEL-1:(31*8+3)*`PIXEL-`PIXEL]};
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
assign ref_row4={   ref_ou[(0*8+4)*`PIXEL-1:(0*8+4)*`PIXEL-`PIXEL],  ref_ou[(1*8+4)*`PIXEL-1:(1*8+4)*`PIXEL-`PIXEL],  ref_ou[(2*8+4)*`PIXEL-1:(2*8+4)*`PIXEL-`PIXEL],  ref_ou[(3*8+4)*`PIXEL-1:(3*8+4)*`PIXEL-`PIXEL],
					ref_ou[(4*8+4)*`PIXEL-1:(4*8+4)*`PIXEL-`PIXEL],  ref_ou[(5*8+4)*`PIXEL-1:(5*8+4)*`PIXEL-`PIXEL],  ref_ou[(6*8+4)*`PIXEL-1:(6*8+4)*`PIXEL-`PIXEL],  ref_ou[(7*8+4)*`PIXEL-1:(7*8+4)*`PIXEL-`PIXEL],
					ref_ou[(8*8+4)*`PIXEL-1:(8*8+4)*`PIXEL-`PIXEL],  ref_ou[(9*8+4)*`PIXEL-1:(9*8+4)*`PIXEL-`PIXEL],  ref_ou[(10*8+4)*`PIXEL-1:(10*8+4)*`PIXEL-`PIXEL],ref_ou[(11*8+4)*`PIXEL-1:(11*8+4)*`PIXEL-`PIXEL],
					ref_ou[(12*8+4)*`PIXEL-1:(12*8+4)*`PIXEL-`PIXEL],ref_ou[(13*8+4)*`PIXEL-1:(13*8+4)*`PIXEL-`PIXEL],ref_ou[(14*8+4)*`PIXEL-1:(14*8+4)*`PIXEL-`PIXEL],ref_ou[(15*8+4)*`PIXEL-1:(15*8+4)*`PIXEL-`PIXEL],
					ref_ou[(16*8+4)*`PIXEL-1:(16*8+4)*`PIXEL-`PIXEL],ref_ou[(17*8+4)*`PIXEL-1:(17*8+4)*`PIXEL-`PIXEL],ref_ou[(18*8+4)*`PIXEL-1:(18*8+4)*`PIXEL-`PIXEL],ref_ou[(19*8+4)*`PIXEL-1:(19*8+4)*`PIXEL-`PIXEL],
					ref_ou[(20*8+4)*`PIXEL-1:(20*8+4)*`PIXEL-`PIXEL],ref_ou[(21*8+4)*`PIXEL-1:(21*8+4)*`PIXEL-`PIXEL],ref_ou[(22*8+4)*`PIXEL-1:(22*8+4)*`PIXEL-`PIXEL],ref_ou[(23*8+4)*`PIXEL-1:(23*8+4)*`PIXEL-`PIXEL],
					ref_ou[(24*8+4)*`PIXEL-1:(24*8+4)*`PIXEL-`PIXEL],ref_ou[(25*8+4)*`PIXEL-1:(25*8+4)*`PIXEL-`PIXEL],ref_ou[(26*8+4)*`PIXEL-1:(26*8+4)*`PIXEL-`PIXEL],ref_ou[(27*8+4)*`PIXEL-1:(27*8+4)*`PIXEL-`PIXEL],
					ref_ou[(28*8+4)*`PIXEL-1:(28*8+4)*`PIXEL-`PIXEL],ref_ou[(29*8+4)*`PIXEL-1:(29*8+4)*`PIXEL-`PIXEL],ref_ou[(30*8+4)*`PIXEL-1:(30*8+4)*`PIXEL-`PIXEL],ref_ou[(31*8+4)*`PIXEL-1:(31*8+4)*`PIXEL-`PIXEL]};
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
assign ref_row5={   ref_ou[(0*8+5)*`PIXEL-1:(0*8+5)*`PIXEL-`PIXEL],  ref_ou[(1*8+5)*`PIXEL-1:(1*8+5)*`PIXEL-`PIXEL],  ref_ou[(2*8+5)*`PIXEL-1:(2*8+5)*`PIXEL-`PIXEL],  ref_ou[(3*8+5)*`PIXEL-1:(3*8+5)*`PIXEL-`PIXEL],
					ref_ou[(4*8+5)*`PIXEL-1:(4*8+5)*`PIXEL-`PIXEL],  ref_ou[(5*8+5)*`PIXEL-1:(5*8+5)*`PIXEL-`PIXEL],  ref_ou[(6*8+5)*`PIXEL-1:(6*8+5)*`PIXEL-`PIXEL],  ref_ou[(7*8+5)*`PIXEL-1:(7*8+5)*`PIXEL-`PIXEL],
					ref_ou[(8*8+5)*`PIXEL-1:(8*8+5)*`PIXEL-`PIXEL],  ref_ou[(9*8+5)*`PIXEL-1:(9*8+5)*`PIXEL-`PIXEL],  ref_ou[(10*8+5)*`PIXEL-1:(10*8+5)*`PIXEL-`PIXEL],ref_ou[(11*8+5)*`PIXEL-1:(11*8+5)*`PIXEL-`PIXEL],
					ref_ou[(12*8+5)*`PIXEL-1:(12*8+5)*`PIXEL-`PIXEL],ref_ou[(13*8+5)*`PIXEL-1:(13*8+5)*`PIXEL-`PIXEL],ref_ou[(14*8+5)*`PIXEL-1:(14*8+5)*`PIXEL-`PIXEL],ref_ou[(15*8+5)*`PIXEL-1:(15*8+5)*`PIXEL-`PIXEL],
					ref_ou[(16*8+5)*`PIXEL-1:(16*8+5)*`PIXEL-`PIXEL],ref_ou[(17*8+5)*`PIXEL-1:(17*8+5)*`PIXEL-`PIXEL],ref_ou[(18*8+5)*`PIXEL-1:(18*8+5)*`PIXEL-`PIXEL],ref_ou[(19*8+5)*`PIXEL-1:(19*8+5)*`PIXEL-`PIXEL],
					ref_ou[(20*8+5)*`PIXEL-1:(20*8+5)*`PIXEL-`PIXEL],ref_ou[(21*8+5)*`PIXEL-1:(21*8+5)*`PIXEL-`PIXEL],ref_ou[(22*8+5)*`PIXEL-1:(22*8+5)*`PIXEL-`PIXEL],ref_ou[(23*8+5)*`PIXEL-1:(23*8+5)*`PIXEL-`PIXEL],
					ref_ou[(24*8+5)*`PIXEL-1:(24*8+5)*`PIXEL-`PIXEL],ref_ou[(25*8+5)*`PIXEL-1:(25*8+5)*`PIXEL-`PIXEL],ref_ou[(26*8+5)*`PIXEL-1:(26*8+5)*`PIXEL-`PIXEL],ref_ou[(27*8+5)*`PIXEL-1:(27*8+5)*`PIXEL-`PIXEL],
					ref_ou[(28*8+5)*`PIXEL-1:(28*8+5)*`PIXEL-`PIXEL],ref_ou[(29*8+5)*`PIXEL-1:(29*8+5)*`PIXEL-`PIXEL],ref_ou[(30*8+5)*`PIXEL-1:(30*8+5)*`PIXEL-`PIXEL],ref_ou[(31*8+5)*`PIXEL-1:(31*8+5)*`PIXEL-`PIXEL]};
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
assign ref_row6={   ref_ou[(0*8+6)*`PIXEL-1:(0*8+6)*`PIXEL-`PIXEL],  ref_ou[(1*8+6)*`PIXEL-1:(1*8+6)*`PIXEL-`PIXEL],  ref_ou[(2*8+6)*`PIXEL-1:(2*8+6)*`PIXEL-`PIXEL],  ref_ou[(3*8+6)*`PIXEL-1:(3*8+6)*`PIXEL-`PIXEL],
					ref_ou[(4*8+6)*`PIXEL-1:(4*8+6)*`PIXEL-`PIXEL],  ref_ou[(5*8+6)*`PIXEL-1:(5*8+6)*`PIXEL-`PIXEL],  ref_ou[(6*8+6)*`PIXEL-1:(6*8+6)*`PIXEL-`PIXEL],  ref_ou[(7*8+6)*`PIXEL-1:(7*8+6)*`PIXEL-`PIXEL],
					ref_ou[(8*8+6)*`PIXEL-1:(8*8+6)*`PIXEL-`PIXEL],  ref_ou[(9*8+6)*`PIXEL-1:(9*8+6)*`PIXEL-`PIXEL],  ref_ou[(10*8+6)*`PIXEL-1:(10*8+6)*`PIXEL-`PIXEL],ref_ou[(11*8+6)*`PIXEL-1:(11*8+6)*`PIXEL-`PIXEL],
					ref_ou[(12*8+6)*`PIXEL-1:(12*8+6)*`PIXEL-`PIXEL],ref_ou[(13*8+6)*`PIXEL-1:(13*8+6)*`PIXEL-`PIXEL],ref_ou[(14*8+6)*`PIXEL-1:(14*8+6)*`PIXEL-`PIXEL],ref_ou[(15*8+6)*`PIXEL-1:(15*8+6)*`PIXEL-`PIXEL],
					ref_ou[(16*8+6)*`PIXEL-1:(16*8+6)*`PIXEL-`PIXEL],ref_ou[(17*8+6)*`PIXEL-1:(17*8+6)*`PIXEL-`PIXEL],ref_ou[(18*8+6)*`PIXEL-1:(18*8+6)*`PIXEL-`PIXEL],ref_ou[(19*8+6)*`PIXEL-1:(19*8+6)*`PIXEL-`PIXEL],
					ref_ou[(20*8+6)*`PIXEL-1:(20*8+6)*`PIXEL-`PIXEL],ref_ou[(21*8+6)*`PIXEL-1:(21*8+6)*`PIXEL-`PIXEL],ref_ou[(22*8+6)*`PIXEL-1:(22*8+6)*`PIXEL-`PIXEL],ref_ou[(23*8+6)*`PIXEL-1:(23*8+6)*`PIXEL-`PIXEL],
					ref_ou[(24*8+6)*`PIXEL-1:(24*8+6)*`PIXEL-`PIXEL],ref_ou[(25*8+6)*`PIXEL-1:(25*8+6)*`PIXEL-`PIXEL],ref_ou[(26*8+6)*`PIXEL-1:(26*8+6)*`PIXEL-`PIXEL],ref_ou[(27*8+6)*`PIXEL-1:(27*8+6)*`PIXEL-`PIXEL],
					ref_ou[(28*8+6)*`PIXEL-1:(28*8+6)*`PIXEL-`PIXEL],ref_ou[(29*8+6)*`PIXEL-1:(29*8+6)*`PIXEL-`PIXEL],ref_ou[(30*8+6)*`PIXEL-1:(30*8+6)*`PIXEL-`PIXEL],ref_ou[(31*8+6)*`PIXEL-1:(31*8+6)*`PIXEL-`PIXEL]};
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
assign ref_row7={   ref_ou[(0*8+7)*`PIXEL-1:(0*8+7)*`PIXEL-`PIXEL],  ref_ou[(1*8+7)*`PIXEL-1:(1*8+7)*`PIXEL-`PIXEL],  ref_ou[(2*8+7)*`PIXEL-1:(2*8+7)*`PIXEL-`PIXEL],  ref_ou[(3*8+7)*`PIXEL-1:(3*8+7)*`PIXEL-`PIXEL],
					ref_ou[(4*8+7)*`PIXEL-1:(4*8+7)*`PIXEL-`PIXEL],  ref_ou[(5*8+7)*`PIXEL-1:(5*8+7)*`PIXEL-`PIXEL],  ref_ou[(6*8+7)*`PIXEL-1:(6*8+7)*`PIXEL-`PIXEL],  ref_ou[(7*8+7)*`PIXEL-1:(7*8+7)*`PIXEL-`PIXEL],
					ref_ou[(8*8+7)*`PIXEL-1:(8*8+7)*`PIXEL-`PIXEL],  ref_ou[(9*8+7)*`PIXEL-1:(9*8+7)*`PIXEL-`PIXEL],  ref_ou[(10*8+7)*`PIXEL-1:(10*8+7)*`PIXEL-`PIXEL],ref_ou[(11*8+7)*`PIXEL-1:(11*8+7)*`PIXEL-`PIXEL],
					ref_ou[(12*8+7)*`PIXEL-1:(12*8+7)*`PIXEL-`PIXEL],ref_ou[(13*8+7)*`PIXEL-1:(13*8+7)*`PIXEL-`PIXEL],ref_ou[(14*8+7)*`PIXEL-1:(14*8+7)*`PIXEL-`PIXEL],ref_ou[(15*8+7)*`PIXEL-1:(15*8+7)*`PIXEL-`PIXEL],
					ref_ou[(16*8+7)*`PIXEL-1:(16*8+7)*`PIXEL-`PIXEL],ref_ou[(17*8+7)*`PIXEL-1:(17*8+7)*`PIXEL-`PIXEL],ref_ou[(18*8+7)*`PIXEL-1:(18*8+7)*`PIXEL-`PIXEL],ref_ou[(19*8+7)*`PIXEL-1:(19*8+7)*`PIXEL-`PIXEL],
					ref_ou[(20*8+7)*`PIXEL-1:(20*8+7)*`PIXEL-`PIXEL],ref_ou[(21*8+7)*`PIXEL-1:(21*8+7)*`PIXEL-`PIXEL],ref_ou[(22*8+7)*`PIXEL-1:(22*8+7)*`PIXEL-`PIXEL],ref_ou[(23*8+7)*`PIXEL-1:(23*8+7)*`PIXEL-`PIXEL],
					ref_ou[(24*8+7)*`PIXEL-1:(24*8+7)*`PIXEL-`PIXEL],ref_ou[(25*8+7)*`PIXEL-1:(25*8+7)*`PIXEL-`PIXEL],ref_ou[(26*8+7)*`PIXEL-1:(26*8+7)*`PIXEL-`PIXEL],ref_ou[(27*8+7)*`PIXEL-1:(27*8+7)*`PIXEL-`PIXEL],
					ref_ou[(28*8+7)*`PIXEL-1:(28*8+7)*`PIXEL-`PIXEL],ref_ou[(29*8+7)*`PIXEL-1:(29*8+7)*`PIXEL-`PIXEL],ref_ou[(30*8+7)*`PIXEL-1:(30*8+7)*`PIXEL-`PIXEL],ref_ou[(31*8+7)*`PIXEL-1:(31*8+7)*`PIXEL-`PIXEL]};
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
assign ref_row8={   ref_ou[(0*8+8)*`PIXEL-1:(0*8+8)*`PIXEL-`PIXEL],  ref_ou[(1*8+8)*`PIXEL-1:(1*8+8)*`PIXEL-`PIXEL],  ref_ou[(2*8+8)*`PIXEL-1:(2*8+8)*`PIXEL-`PIXEL],  ref_ou[(3*8+8)*`PIXEL-1:(3*8+8)*`PIXEL-`PIXEL],
					ref_ou[(4*8+8)*`PIXEL-1:(4*8+8)*`PIXEL-`PIXEL],  ref_ou[(5*8+8)*`PIXEL-1:(5*8+8)*`PIXEL-`PIXEL],  ref_ou[(6*8+8)*`PIXEL-1:(6*8+8)*`PIXEL-`PIXEL],  ref_ou[(7*8+8)*`PIXEL-1:(7*8+8)*`PIXEL-`PIXEL],
					ref_ou[(8*8+8)*`PIXEL-1:(8*8+8)*`PIXEL-`PIXEL],  ref_ou[(9*8+8)*`PIXEL-1:(9*8+8)*`PIXEL-`PIXEL],  ref_ou[(10*8+8)*`PIXEL-1:(10*8+8)*`PIXEL-`PIXEL],ref_ou[(11*8+8)*`PIXEL-1:(11*8+8)*`PIXEL-`PIXEL],
					ref_ou[(12*8+8)*`PIXEL-1:(12*8+8)*`PIXEL-`PIXEL],ref_ou[(13*8+8)*`PIXEL-1:(13*8+8)*`PIXEL-`PIXEL],ref_ou[(14*8+8)*`PIXEL-1:(14*8+8)*`PIXEL-`PIXEL],ref_ou[(15*8+8)*`PIXEL-1:(15*8+8)*`PIXEL-`PIXEL],
					ref_ou[(16*8+8)*`PIXEL-1:(16*8+8)*`PIXEL-`PIXEL],ref_ou[(17*8+8)*`PIXEL-1:(17*8+8)*`PIXEL-`PIXEL],ref_ou[(18*8+8)*`PIXEL-1:(18*8+8)*`PIXEL-`PIXEL],ref_ou[(19*8+8)*`PIXEL-1:(19*8+8)*`PIXEL-`PIXEL],
					ref_ou[(20*8+8)*`PIXEL-1:(20*8+8)*`PIXEL-`PIXEL],ref_ou[(21*8+8)*`PIXEL-1:(21*8+8)*`PIXEL-`PIXEL],ref_ou[(22*8+8)*`PIXEL-1:(22*8+8)*`PIXEL-`PIXEL],ref_ou[(23*8+8)*`PIXEL-1:(23*8+8)*`PIXEL-`PIXEL],
					ref_ou[(24*8+8)*`PIXEL-1:(24*8+8)*`PIXEL-`PIXEL],ref_ou[(25*8+8)*`PIXEL-1:(25*8+8)*`PIXEL-`PIXEL],ref_ou[(26*8+8)*`PIXEL-1:(26*8+8)*`PIXEL-`PIXEL],ref_ou[(27*8+8)*`PIXEL-1:(27*8+8)*`PIXEL-`PIXEL],
					ref_ou[(28*8+8)*`PIXEL-1:(28*8+8)*`PIXEL-`PIXEL],ref_ou[(29*8+8)*`PIXEL-1:(29*8+8)*`PIXEL-`PIXEL],ref_ou[(30*8+8)*`PIXEL-1:(30*8+8)*`PIXEL-`PIXEL],ref_ou[(31*8+8)*`PIXEL-1:(31*8+8)*`PIXEL-`PIXEL]};
//--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

					
endmodule