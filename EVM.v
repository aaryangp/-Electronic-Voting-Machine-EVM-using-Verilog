module EVM(
input clk,rst,
input start_vote ,
input next_voter,
input [3:0] vote_btn,
input confirm ,
output reg [3:0] vote_count_A ,
output reg [3:0] vote_count_B ,
output reg [3:0] vote_count_C ,
output reg [3:0] vote_count_D 
);

parameter A = 4'b0001 ;
parameter B = 4'b0010 ;
parameter C = 4'b0100 ;
parameter D = 4'b1000 ;

parameter IDLE = 2'b00 ;
parameter READY = 2'b01 ;
parameter VOTE_CAST = 2'b10 ;
parameter LOCKED = 2'b11 ;

reg [1:0] ns,ps ;

always@(posedge clk)
  begin
    if(rst)
    begin
      ps <= IDLE ;
    end
    else
      ps <= ns ;
  end

  always@(posedge clk) begin
  if(rst) begin
    vote_count_A <= 4'b0 ;
    vote_count_B <= 4'b0;
    vote_count_C <= 4'b0;
    vote_count_D <= 4'b0;
  end
  else if(ps == VOTE_CAST) begin
     case (vote_btn)
      A: vote_count_A <= vote_count_A + 1;
      B: vote_count_B <= vote_count_B + 1;
      C: vote_count_C <= vote_count_C + 1;
      D: vote_count_D <= vote_count_D + 1;
      default : ;
    endcase

  end
  end


always@(*)begin
    ns = IDLE ;

    case(ps)

    IDLE : begin
          if(start_vote == 1'b1)
          ns = READY ;
          else
          ns = IDLE ;

    end

    READY : begin
          if(confirm && (vote_btn != 4'b0000))
           ns = VOTE_CAST;
           else
           ns = READY ;
    end


    VOTE_CAST: begin
        ns = LOCKED ;
    end


   LOCKED: begin
  if(next_voter)
    ns = READY;
  else
    ns = LOCKED;
   end

    default : ns = IDLE ;

    endcase
    
end

endmodule
