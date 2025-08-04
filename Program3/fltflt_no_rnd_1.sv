module TopLevel(
  input        clk, reset,
               start,
  output logic done);
  logic       nil1,		    	      
              nil2,		    	      // zero detect addend 2
			  nil3,                   // zero detect sum
              guard,	    	      // needed for subtraction
              round,
              sticky;
  logic[10:0] mant1,                   // mantissa of addend 1
              mant2;				   //  (w/ room for hidden bit)
  logic[11:0] mant3;	      	       // mantissa of sum, incl. overflow
  logic[ 5:0] exp1,			           // exponent of addend 1
              exp2,
              exp3;					   // exponent of sum
  logic       sign1,		           // sign of addend 1
              sign2,
              sign3;	               // sign of sum (or difference)

 logic     [8-1:0]  DataAddress;	   // in your model you would connect these	
 logic              ReadMem;		   //  to other blocks/modules	
 logic              WriteMem;	   		
 logic       [7:0]  DataIn;			
 logic       [7:0]  DataOut;
 int          pgm;			

  data_mem data_mem1(.*);

  always @(posedge clk) begin	 :main
    if(reset) pgm++;
    else if(start) begin
		guard  = 1'b0;
		round  = 1'b0;
		sticky = 1'b0;
		sign1  = data_mem1.mem_core[ 9][7];			 // load operands from data_mem
		sign2  = data_mem1.mem_core[11][7];
		exp1   = data_mem1.mem_core[ 9][6:2];
		exp2   = data_mem1.mem_core[11][6:2];
		nil1   = !data_mem1.mem_core[ 9][6:2];	     // zero exp trap
		nil2   = !data_mem1.mem_core[11][6:2];		 // zero exp trap
		mant1 <= { 1'b1,                         // hidden-1 always, unless exp==0
			data_mem1.mem_core[9][1:0],   // mantissa[9:8]
			data_mem1.mem_core[8][7:0]
		};                              // 1 + 2 + 8 = 11 bits
		mant2 <= { 1'b1,
			data_mem1.mem_core[11][1:0],
			data_mem1.mem_core[10][7:0]
		};
		done   = 1'b0;
    end

	else if (!done) begin	  :nonreset
		$display("diff = %d",exp1-exp2);
		//$display("mant2 = %b", mant2);	
	  exp3  = exp1;                     // covers equal exponent case; override if exp2>exp1   
	  if(sign1==sign2) begin  :netadd   // perform addition
        sign3 = sign1;				    // won't need guard, but would for subtraction
		if(exp1>exp2) begin
		  exp3 = exp1;				    
		  for(int j=0; j<(exp1-exp2); j++) begin
			mant2  = mant2>>1;
		  end
		end
		else if(exp2>exp1) begin             
          exp3 = exp2;
          for(int j=0; j<(exp2-exp1); j++) begin 
		    mant1  = mant1>>1;
		  end
		end
       	mant3 = mant1 + mant2;
		if(mant3[11]) begin	           
          exp3++;					   
		  mant3  = mant3>>1;
		end
		nil3=!exp3;
	  end   :netadd
      data_mem1.mem_core[13][7]								=	   sign3; 
      data_mem1.mem_core[13][6:2]							    =	   exp3 ; 
      {data_mem1.mem_core[13][1:0],data_mem1.mem_core[12]}  =	   mant3[9:0]; 
	  done = 1'b1;															     
	end	 :nonreset
  end  :main
endmodule