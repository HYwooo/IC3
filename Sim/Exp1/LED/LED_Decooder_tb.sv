`timescale 1ns / 1ns
module LED_Decoder_tb;
  // Testbench signals
  reg  [4:0] seg_ctrl_tb;
  wire [7:0] seg_valid_out_tb;

  // Instantiate the DUT (Device Under Test)
  LED_Decoder dut (
      .rst_n(1),
      .dig_ctrl(seg_ctrl_tb),
      .o_dig_sel(seg_valid_out_tb)
  );

  // Test procedure
  initial begin
    // Test vector array
    reg [4:0] test_vectors[0:31];
    reg [7:0] expected_outputs[0:31];
    integer i;

    // Initialize test vectors and expected outputs
    test_vectors[0] = 5'h00;
    expected_outputs[0] = ~8'h3f;
    test_vectors[1] = 5'h01;
    expected_outputs[1] = ~8'h06;
    test_vectors[2] = 5'h02;
    expected_outputs[2] = ~8'h5b;
    test_vectors[3] = 5'h03;
    expected_outputs[3] = ~8'h4f;
    test_vectors[4] = 5'h04;
    expected_outputs[4] = ~8'h66;
    test_vectors[5] = 5'h05;
    expected_outputs[5] = ~8'h6d;
    test_vectors[6] = 5'h06;
    expected_outputs[6] = ~8'h7d;
    test_vectors[7] = 5'h07;
    expected_outputs[7] = ~8'h07;
    test_vectors[8] = 5'h08;
    expected_outputs[8] = ~8'h7f;
    test_vectors[9] = 5'h09;
    expected_outputs[9] = ~8'h6f;
    test_vectors[10] = 5'h0a;
    expected_outputs[10] = ~8'h77;
    test_vectors[11] = 5'h0b;
    expected_outputs[11] = ~8'h7c;
    test_vectors[12] = 5'h0c;
    expected_outputs[12] = ~8'h39;
    test_vectors[13] = 5'h0d;
    expected_outputs[13] = ~8'h5e;
    test_vectors[14] = 5'h0e;
    expected_outputs[14] = ~8'h79;
    test_vectors[15] = 5'h0f;
    expected_outputs[15] = ~8'h71;
    test_vectors[16] = 5'h10;
    expected_outputs[16] = ~(8'h3f + 8'h80);
    test_vectors[17] = 5'h11;
    expected_outputs[17] = ~(8'h06 + 8'h80);
    test_vectors[18] = 5'h12;
    expected_outputs[18] = ~(8'h5b + 8'h80);
    test_vectors[19] = 5'h13;
    expected_outputs[19] = ~(8'h4f + 8'h80);
    test_vectors[20] = 5'h14;
    expected_outputs[20] = ~(8'h66 + 8'h80);
    test_vectors[21] = 5'h15;
    expected_outputs[21] = ~(8'h6d + 8'h80);
    test_vectors[22] = 5'h16;
    expected_outputs[22] = ~(8'h7d + 8'h80);
    test_vectors[23] = 5'h17;
    expected_outputs[23] = ~(8'h07 + 8'h80);
    test_vectors[24] = 5'h18;
    expected_outputs[24] = ~(8'h7f + 8'h80);
    test_vectors[25] = 5'h19;
    expected_outputs[25] = ~(8'h6f + 8'h80);
    test_vectors[26] = 5'h1a;
    expected_outputs[26] = ~(8'h77 + 8'h80);
    test_vectors[27] = 5'h1b;
    expected_outputs[27] = ~(8'h7c + 8'h80);
    test_vectors[28] = 5'h1c;
    expected_outputs[28] = ~(8'h39 + 8'h80);
    test_vectors[29] = 5'h1d;
    expected_outputs[29] = ~(8'h5e + 8'h80);
    test_vectors[30] = 5'h1e;
    expected_outputs[30] = ~(8'h79 + 8'h80);
    test_vectors[31] = 5'h1f;
    expected_outputs[31] = ~(8'h71 + 8'h80);

    // Apply test vectors and check results
    for (i = 0; i < 32; i = i + 1) begin
      seg_ctrl_tb = test_vectors[i];
      #10;  // Wait for the output to stabilize
      assert (seg_valid_out_tb == expected_outputs[i])
      else
        $fatal(
            "Test failed for seg_ctrl = %h, expected = %h, got = %h",
            seg_ctrl_tb,
            expected_outputs[i],
            seg_valid_out_tb
        );
    end
    $display("**********************************************");
    $info("All tests passed.");
    $display("**********************************************");
    $finish;
  end
endmodule
