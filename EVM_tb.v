`timescale 1ns/1ps
`include "EVM.v"

module EVM_tb;

  reg clk;
  reg rst;
  reg start_vote;
  reg next_voter;
  reg [3:0] vote_btn;
  reg confirm;

  wire [3:0] vote_count_A;
  wire [3:0] vote_count_B;
  wire [3:0] vote_count_C;
  wire [3:0] vote_count_D;

  // -------------------------
  // DUT
  // -------------------------
  EVM dut (
    .clk(clk),
    .rst(rst),
    .start_vote(start_vote),
    .next_voter(next_voter),
    .vote_btn(vote_btn),
    .confirm(confirm),
    .vote_count_A(vote_count_A),
    .vote_count_B(vote_count_B),
    .vote_count_C(vote_count_C),
    .vote_count_D(vote_count_D)
  );

  // -------------------------
  // Clock: 10 ns period
  // -------------------------
  always #5 clk = ~clk;

  // -------------------------
  // Initial values
  // -------------------------
  initial begin
    clk = 0;
    rst = 1;              // RESET ASSERTED
    start_vote = 0;
    next_voter = 0;
    vote_btn = 4'b0000;
    confirm = 0;
  end

  // -------------------------
  // Reset release
  // -------------------------
  initial begin
    #20;
    rst = 0;              // RESET DEASSERTED
  end

  // -------------------------
  // TASK: cast one vote
  // -------------------------
  task cast_vote(input [3:0] candidate);
  begin
    // Enable voting
    @(negedge clk);
    start_vote = 1;
    @(negedge clk);
    start_vote = 0;

    // Press vote button
    @(negedge clk);
    vote_btn = candidate;

    // Confirm vote (1-cycle pulse)
    @(negedge clk);
    confirm = 1;
    @(negedge clk);
    confirm = 0;

    // Release button
    @(negedge clk);
    vote_btn = 4'b0000;

    // Allow next voter
    repeat (2) @(negedge clk);
    next_voter = 1;
    @(negedge clk);
    next_voter = 0;
  end
  endtask

  // -------------------------
  // Test sequence
  // -------------------------
  initial begin
    @(negedge rst);   // WAIT FOR RESET RELEASE

    // Voter 1 → A
    cast_vote(4'b0001);

    // Voter 2 → B
    cast_vote(4'b0010);

    // Voter 3 → A
    cast_vote(4'b0001);

    // Voter 4 → D
    cast_vote(4'b1000);

    #50;
    $display("=================================");
    $display("FINAL VOTE COUNTS");
    $display("A = %0d", vote_count_A);
    $display("B = %0d", vote_count_B);
    $display("C = %0d", vote_count_C);
    $display("D = %0d", vote_count_D);
    $display("=================================");
    $finish;
  end

  // -------------------------
  // Live monitor
  // -------------------------
  initial begin
    $monitor("T=%0t | A=%0d B=%0d C=%0d D=%0d",
              $time,
              vote_count_A,
              vote_count_B,
              vote_count_C,
              vote_count_D);
  end

  // -------------------------
  // Waveform dump
  // -------------------------
  initial begin
    $dumpfile("EVM.vcd");
   $dumpvars(0, EVM_tb);
  end

endmodule
