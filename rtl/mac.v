// Simple 8x8 multiply-accumulate unit used as a demo design
module mac (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        en,
    input  wire [7:0]  a,
    input  wire [7:0]  b,
    output reg  [19:0] acc
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)  acc <= 20'd0;
        else if (en) acc <= acc + a * b;
    end
endmodule
