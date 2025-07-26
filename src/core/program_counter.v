module Program_Counter (
    input wire clk,
    input wire reset,
    input wire [31:0] next_pc,
    output reg [31:0] pc
);

    initial begin
        pc = 32'h00000000;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 32'h00000000;
        end else begin
            pc <= next_pc;
        end
    end

endmodule
