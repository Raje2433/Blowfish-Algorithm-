module Blowfishencrypt(
    output reg [63:0] ciphertext,
    output reg [31:0] temp_out,
    output reg [31:0] F_out,
    input [63:0] plaintext,
    input [127:0] key,
    input clock,
    input reset
);

reg [31:0] P[0:17];
reg [31:0] S1[0:255];
reg [31:0] S2[0:255];
reg [31:0] S3[0:255];
reg [31:0] S4[0:255];
reg [31:0] XL, XR;
reg [31:0] temp;
reg [31:0] F_value;
reg [31:0] key_word[0:17];
reg [31:0] subkey_word;
integer i, j;

// Initial P-array and S-box values
initial begin
    // Initialize P-array and S-boxes
    P[0] = 32'h243f6a88;
    P[1] = 32'h85a308d3;
    // Other P-array initialization values
    P[2] = 32'h13198a2e;
  P[3] = 32'h03707344;
  P[4] = 32'ha4093822;
  P[5] = 32'h299f31d0;
  P[6] = 32'h082efa98;
  P[7] = 32'hec4e6c89;
  P[8] = 32'h452821e6;
  P[9] = 32'h38d01377;
  P[10] = 32'hbe5466cf;
  P[11] = 32'h34e90c6c;
  P[12] = 32'hc0ac29b7;
  P[13] = 32'hc97c50dd;
  P[14] = 32'h3f84d5b5;
  P[15] = 32'hb5470917;
  P[16] = 32'h9216d5d9;
  P[17] = 32'h8979fb1b;
    // Initialize S-boxes
    for (i = 0; i < 256; i = i + 1) begin
        
    
      S1[i] = i^32'h243f6a88; // Replace with the actual value for S1[i]
      S2[i] = i^32'h85a308d3; // Replace with the actual value for S2[i]
      S3[i] = i^32'h13198a2e; // Replace with the actual value for S3[i]
      S4[i] = i^32'h03707344; // Replace with the actual value for S4[i]
 
    end

    // Convert the 128-bit key into an array of 32-bit words
    // Convert the 128-bit key into an array of 32-bit words
    for (i = 0; i < 18; i = i + 1) begin
        key_word[i] = key[(i * 32) +: 32];
    end

    // XOR the key with the P-array
    for (i = 0; i < 18; i = i + 1) begin
        P[i] = P[i] ^ key_word[i];
    end

    // Perform the key expansion
    j = 0;
    for (i = 0; i < 18; i = i + 1) begin
        subkey_word = (key_word[j] + P[i]) & 32'hFFFFFFFF;
        P[i] = (P[i] + subkey_word) & 32'hFFFFFFFF;
        key_word[j] = subkey_word;
        j = (j == 17) ? 0 : (j + 1);
    end
end

always @(posedge clock or posedge reset) begin
    if (reset) begin
        XL <= 0;
        XR <= 0;
        ciphertext <= 0;
        temp_out <= 0;
        F_out <= 0;
    end else begin
        // Perform Blowfish encryption
        XL <= plaintext[63:32];
        XR <= plaintext[31:0];

        // Feistel network iterations
        for (i = 0; i < 16; i = i + 1) begin
            temp = XL;
            XL = XR ^ P[i];
            XR = temp ^ ((((S1[XL[31:24]] + S2[XL[23:16]]) ^ S3[XL[15:8]]) + S4[XL[7:0]]) & 32'hFFFFFFFF);
        end

        // Swap XL and XR
        temp = XL;
        XL = XR ^ P[16];
        XR = temp ^ P[17];

        // Recombine XL and XR
        ciphertext <= {XL, XR};

        // Output temp, and F
        temp_out <= temp;
        F_value = ((((S1[XL[31:24]] + S2[XL[23:16]]) ^ S3[XL[15:8]]) + S4[XL[7:0]]) & 32'hFFFFFFFF);
        F_out <= F_value;
    end
end

endmodule