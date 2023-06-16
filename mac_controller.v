`timescale 1ns / 1ps

module mac_controller (
    input wire         clk,
    input wire         rstn,
    input wire         en,
    input wire         flush,

    input wire  [31:0] input_feature,
    input wire  [31:0] weight,
    input wire   [8:0] bias,

    output reg  [25:0] result,
    output reg         done
);
    reg   [3:0] mac_en;
    wire  [3:0] mac_done;

    wire [17:0] mac_result;

    wire [15:0] mac_result0;
    wire [15:0] mac_result1;
    wire [15:0] mac_result2;
    wire [15:0] mac_result3;

    assign mac_result =   (mac_done[0] ? mac_result0[15:0] : 16'b0)
                        + (mac_done[1] ? mac_result1[15:0] : 16'b0)
                        + (mac_done[2] ? mac_result2[15:0] : 16'b0)
                        + (mac_done[3] ? mac_result3[15:0] : 16'b0);

    mac mac0 (
        .clk           (clk),
        .rstn          (rstn),
        .en            (mac_en[0]),

        .input_feature (input_feature[7:0]),
        .weight        (weight[7:0]),

        .result        (mac_result0[15:0]),
        .done          (mac_done[0])
    );
    mac mac1 (
        .clk           (clk),
        .rstn          (rstn),
        .en            (mac_en[1]),

        .input_feature (input_feature[15:8]),
        .weight        (weight[15:8]),

        .result        (mac_result1[15:0]),
        .done          (mac_done[1])
    );
    mac mac2 (
        .clk           (clk),
        .rstn          (rstn),
        .en            (mac_en[2]),

        .input_feature (input_feature[23:16]),
        .weight        (weight[23:16]),

        .result        (mac_result2[15:0]),
        .done          (mac_done[2])
    );
    mac mac3 (
        .clk           (clk),
        .rstn          (rstn),
        .en            (mac_en[3]),

        .input_feature (input_feature[31:24]),
        .weight        (weight[31:24]),

        .result        (mac_result3[15:0]),
        .done          (mac_done[3])
    );

    always @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            result <= 26'b0;
            done   <= 1'b0;
        end
        else begin
            if (en) begin
                if (mac_done) begin
                    result <= result + mac_result;
                end
                else begin
                end
            end
            else if (flush) begin
                result <= 26'b0;
                done   <= 1'b0;
            end
            else begin
                result <= result;
                done   <= 1'b0;
            end
        end
    end
endmodule