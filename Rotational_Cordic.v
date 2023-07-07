/******************************************************************************
 *
 * Module: Rotational Cordic
 *
 * Description: Rotational CORDIC used for the rotation of the vectors 
 *
 * Author: Mohamed Mostafa
 *******************************************************************************************/


/*
*The input and the output also here is 28 bits and it's divided as 14 bits for the numbers on the left of the decimal point
*and 14 bits for the numbers on the right of the decimal point.
*
*/


module Rotate_CORDIC
#(parameter N = 32,           //number of stages which is greater than the wordlength by 4 or more this helps in accuracy 
            WordLength = 28   // WordLength is 12 bits
)


(
input clock,
input Areset,
input Start,
input [WordLength-1:0]X0,
input [WordLength-1:0]Y0,
input [WordLength-1:0]Theta0,

output reg signed [WordLength-1:0] XN,
output reg signed [WordLength-1:0] YN,        //supposed to be 0 
output reg signed [WordLength-1:0] ThetaN);

reg [18:0]Cos_Value[0:(N-1)];
reg [18:0]aTan_Value[0:(N-1)];


wire [31:0] beta_lut [0:31];

// here the number of bits used for the decimal point is 32 bits divided as 4 bits for the number on the left of the decimal point which almost 0 
// and the rest of these bits is used for the numbers on the right of the decimal point
   
`define BETA_0  28'b0000_0111_1000_0101_0011_1001_1000  // = atan 2^0     = 0.7853981633974483
`define BETA_1  28'b0000_0100_0110_0011_0110_0100_0111  // = atan 2^(-1)  = 0.4636476090008061
`define BETA_2  28'b0000_0010_0100_0100_1001_0111_1000  // = atan 2^(-2)  = 0.24497866312686414
`define BETA_3  28'b0000_0001_0010_0100_0011_0101_0100  // = atan 2^(-3)  = 0.12435499454676144
`define BETA_4  28'b0000_0000_0110_0010_0100_0001_1000  // = atan 2^(-4)  = 0.06241880999595735
`define BETA_5  28'b0000_0000_0011_0001_0010_0011_1001  // = atan 2^(-5)  = 0.031239833430268277
`define BETA_6  28'b0000_0000_0001_0101_0110_0010_0011  // = atan 2^(-6)  = 0.015623728620476831
`define BETA_7  28'b0000_0000_0000_0111_1000_0001_0010  // = atan 2^(-7)  = 0.007812341060101111
`define BETA_8  28'b0000_0000_0000_0011_1001_0000_0110  // = atan 2^(-8)  = 0.0039062301319669718
`define BETA_9  28'b0000_0000_0000_0001_1001_0101_0011  // = atan 2^(-9)  = 0.0019531225164788188
`define BETA_10 28'b0000_0000_0000_0000_1001_0111_0110  // = atan 2^(-10) = 0.0009765621895593195
`define BETA_11 28'b0000_0000_0000_0000_0100_1000_1000  // = atan 2^(-11) = 0.0004882812111948983
`define BETA_12 28'b0000_0000_0000_0000_0010_0100_0100 // = atan 2^(-12) = 0.00024414062014936177
`define BETA_13 28'b0000_0000_0000_0000_0001_0010_0010  // = atan 2^(-13) = 0.00012207031189367021
`define BETA_14 28'b0000_0000_0000_0000_0000_0110_0001 // = atan 2^(-14) = 6.103515617420877e-05
`define BETA_15 28'b0000_0000_0000_0000_0000_0011_0000  // = atan 2^(-15) = 3.0517578115526096e-05
`define BETA_16 28'b0000_0000_0000_0000_0000_0001_0101  // = atan 2^(-16) = 1.5258789061315762e-05
`define BETA_17 28'b0000_0000_0000_0000_0000_0000_0111 // = atan 2^(-17) = 7.62939453110197e-06
`define BETA_18 28'b0000_0000_0000_0000_0000_0000_0011  // = atan 2^(-18) = 3.814697265606496e-06
`define BETA_19 28'b0000_0000_0000_0000_0000_0000_0001 // = atan 2^(-19) = 1.907348632810187e-06
`define BETA_20 28'b0000_0000_0000_0000_0000_0000_0000  // = atan 2^(-20) = 9.536743164059608e-07
`define BETA_21 28'b0000_0000_0000_0000_0000_0000_0000  // = atan 2^(-21) = 4.7683715820308884e-07
`define BETA_22 28'b0000_0000_0000_0000_0000_0000_0000 // = atan 2^(-22) = 2.3841857910155797e-07
`define BETA_23 28'b0000_0000_0000_0000_0000_0000_0000 // = atan 2^(-23) = 1.1920928955078068e-07
`define BETA_24 28'b0000_0000_0000_0000_0000_0000_0000  // = atan 2^(-24) = 5.960464477539055e-08
`define BETA_25 28'b0000_0000_0000_0000_0000_0000_0000  // = atan 2^(-25) = 2.9802322387695303e-08
`define BETA_26 28'b0000_0000_0000_0000_0000_0000_0000 // = atan 2^(-26) = 1.4901161193847655e-08
`define BETA_27 28'b0000_0000_0000_0000_0000_0000_0000  // = atan 2^(-27) = 7.450580596923828e-09
`define BETA_28 28'b0000_0000_0000_0000_0000_0000_0000  // = atan 2^(-28) = 3.725290298461914e-09
`define BETA_29 28'b0000_0000_0000_0000_0000_0000_0000  // = atan 2^(-29) = 1.862645149230957e-09
`define BETA_30 28'b0000_0000_0000_0000_0000_0000_0000  // = atan 2^(-30) = 9.313225746154785e-10
`define BETA_31 28'b0000_0000_0000_0000_0000_0000_0000  // = atan 2^(-31) = 4.656612873077393e-10


assign beta_lut[0] = `BETA_0;
assign beta_lut[1] = `BETA_1;
assign beta_lut[2] = `BETA_2;
assign beta_lut[3] = `BETA_3;
assign beta_lut[4] = `BETA_4;
assign beta_lut[5] = `BETA_5;
assign beta_lut[6] = `BETA_6;
assign beta_lut[7] = `BETA_7;
assign beta_lut[8] = `BETA_8;
assign beta_lut[9] = `BETA_9;
assign beta_lut[10] = `BETA_10;
assign beta_lut[11] = `BETA_11;
assign beta_lut[12] = `BETA_12;
assign beta_lut[13] = `BETA_13;
assign beta_lut[14] = `BETA_14;
assign beta_lut[15] = `BETA_15;
assign beta_lut[16] = `BETA_16;
assign beta_lut[17] = `BETA_17;
assign beta_lut[18] = `BETA_18;
assign beta_lut[19] = `BETA_19;
assign beta_lut[20] = `BETA_20;
assign beta_lut[21] = `BETA_21;
assign beta_lut[22] = `BETA_22;
assign beta_lut[23] = `BETA_23;
assign beta_lut[24] = `BETA_24;
assign beta_lut[25] = `BETA_25;
assign beta_lut[26] = `BETA_26;
assign beta_lut[27] = `BETA_27;
assign beta_lut[28] = `BETA_28;
assign beta_lut[29] = `BETA_29;
assign beta_lut[30] = `BETA_30;
assign beta_lut[31] = `BETA_31;
   
   

reg [18:0]Factor;
integer i;


reg signed [WordLength-1:0]X_Current;
reg signed [WordLength-1:0]X_Next;
reg signed [WordLength-1:0]Y_Current;
reg [4:0]Count_Current;
reg enable_Current;
reg signed [WordLength-1:0]Y_Next;
reg signed [WordLength-1:0]Theta_Current;
reg signed[WordLength-1:0]Theta_Next;
reg [4:0]Count_Next;
reg enable_Next;



wire [WordLength -1 :0] X_signbits = {WordLength{X_Current[WordLength -1 ]}};
wire [WordLength -1 :0] Y_signbits = {WordLength{Y_Current[WordLength -1 ]}};
wire [WordLength -1 :0] X_SHR =  X_Current >>> Count_Current;          //2^-i is represented in verilog as 2**-i and it represents shifting
wire [WordLength -1 :0] Y_SHR =  Y_Current >>> Count_Current;          // >>> for logical shift to the right


wire Direction = (Theta_Current[WordLength-1]);

wire [31:0] aTan_LUT = beta_lut[Count_Current];


always @(posedge clock or negedge Areset)
begin

if(~Areset)
begin
     XN <= 0;
	 YN <= 0;
	 ThetaN <= 0;
	 Count_Current <= 0;
	 enable_Current <=0;
end
else 
begin
    X_Current <= X_Next ;
	Y_Current <= Y_Next ;
	Theta_Current <= Theta_Next ;
	Count_Current <= Count_Next;
	enable_Current <= enable_Next;
	
end
end

always @(*)
begin
       X_Next = X_Current;
	   Y_Next = Y_Current;
	   Theta_Next = Theta_Current;
	   Count_Next = Count_Current;
	   enable_Next = enable_Current;
	   
	   if(enable_Current)       
	   begin
       X_Next = X_Current + (Direction ? Y_SHR : -Y_SHR );    //this will vary according to the sign of the Y since it's a Vectoring CORDIC
       Y_Next = Y_Current + (Direction ? -X_SHR : X_SHR );     
       Theta_Next = Theta_Current + (Direction ? aTan_LUT : -aTan_LUT);
	   Count_Next = Count_Current +1;
	        if(Count_Current == N -1 )
			begin
			   enable_Next = 0;
			   XN = X_Next ;
			   YN = Y_Next ;
			   ThetaN = Theta_Next;
            end	   
		end	
		else
           begin
             if(Start)
                  begin
                  X_Next = X0 ;
                  Y_Next = Y0 ;
                  Theta_Next = Theta0;
				  Count_Next = 0;
				  enable_Next = 1;          // Go to compute mode.
                  end		  
           end		   
end

endmodule
