`timescale 1ns / 1ps

/*
* Company: Santa Clara University
* Engineer: Jonathan Trinh
*
* Create Date: 02/13/2020 10:26:48 PM
* Design Name:
* Module Name: puf_serial
* Project Name: Delay-based Physical Unclonable Function Implementation
* Target Devices: Digilent S7-25, S7-50 (Xilinx Spartan 7)
* Tool Versions:
* Description: Serialized PUF scheme. It takes in an 8-bit input, scrambles it giving
*              two random ring oscillators to compare outputting a bit. The bit is
*              stored into a buffer. When this is repeated 7 more times. An 8-bit
*              bus is ready to be read.
*
* Dependencies: scrambler_lfsr, ring_osc, mux_16to1, post_mux_counter, race_arbiter, smart_buffer
*
* Revision:
* Revision 0.01 - File Created
* Additional Comments:
*
*/

module puf_serial(
    output[7:0] response,
    output done,
    input [7:0] challenge,
    input [31:0] enable,
    input clock, reset
);

  (* dont_touch = "yes" *) logic out, bit_done, local_counter_reset, scrambler_reset, arbiter_reset;
  (* dont_touch = "yes" *) logic [3:0] buffer_count;
  (* dont_touch = "yes" *) logic buffer_full, buffer_empty;
  (* dont_touch = "yes" *) logic [7:0] scrambler_out;
  (* dont_touch = "yes" *) logic [31:0] ro_out;
  (* dont_touch = "yes" *) logic first_mux_out, second_mux_out;
  (* dont_touch = "yes" *) logic fin1, fin2;
  (* dont_touch = "yes" *) logic [22:0] pmc1_out, pmc2_out;


  (* dont_touch = "yes" *) scrambler_lfsr scrambler (
    .challenge  (challenge),
    .scrambler_out (scrambler_out),
    .clock (clock),
    .reset (reset),
    .scrambler_reset(scrambler_reset));

  (* dont_touch = "yes" *) ring_osc first_ro (
    .enable (enable[15:0]),
    .ro_out (ro_out[15:0])); // An array of ring oscillators

  (* dont_touch = "yes" *) ring_osc second_ro (
    .enable (enable[31:16]),
    .ro_out (ro_out[31:16])); // An array of ring oscillators

  (* dont_touch = "yes" *) mux_16to1 first_mux (
    .ro_out (ro_out[0:15]),
    .scrambler_out (scrambler_out[3:0]),
    .first_mux_out (first_mux_out));

  (* dont_touch = "yes" *) mux_16to1 second_mux (
    .ro_out (ro_out[16:31]),
    .scrambler_out (scrambler_out[7:4]),
    .second_mux_out (second_mux_out));

  (* dont_touch = "yes" *) post_mux_counter pmc1 (
    .pmc1_out (pmc1_out),
    .fin1 (fin1),
    .enable (enable[0]),
    .first_mux_out(first_mux_out),
    .local_counter_reset (local_counter_reset));

  (* dont_touch = "yes" *) post_mux_counter pmc2 (
    .pmc2_out (pmc2_out),
    .fin2 (fin2),
    .enable (enable[0]),
    .second_mux_out (second_mux_out),
    .local_counter_reset (local_counter_reset));

  (* dont_touch = "yes" *) race_arbiter arb (
    .fin1 (fin1),
    .fin2 (fin2),
    .arbiter_reset (arbiter_reset),
    .out (out),
    .bit_done (bit_done));

  (* dont_touch = "yes" *) smart_buffer buff (
    .clock (clock),
    .out (out),
    .bit_done (bit_done),
    .response (response),
    .buffer_count (buffer_count),
    .buffer_full (buffer_full),
    .buffer_empty (buffer_empty),
    .reset (reset),
    .scrambler_reset (scrambler_reset),
    .arbiter_reset (arbiter_reset),
    .local_counter_reset (local_counter_reset),
    .done (done));

endmodule

