`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/31 16:39:33
// Design Name: 
// Module Name: DMA_test
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module DMA_test;
    reg clk;
    reg rst_n;

    reg mem_to_dma_valid;
    reg mem_to_dma_enable;
    reg cpu_to_dma_valid;
    reg cpu_to_dma_enable;
    reg address_valid;
    reg address_enable;
    
    reg [9:0] length;
    reg [3:0] mem_data_out;
    reg [7:0] cpu_data_out;
    
    wire  [3:0] mem_data_in;
    wire  [7:0] cpu_data_in;

    wire  dma_to_mem_valid;
    wire  dma_to_mem_enable;
    wire  dma_to_cpu_valid;
    wire  dma_to_cpu_enable;

    initial
        begin
            clk=0;
            rst_n=0;
            mem_data_out=0;
            cpu_data_out=0;
            length <= ({$random}%128)*4;
            #10000
            $finish;
        end
    initial
        begin
            #20 rst_n=1;
        end
    always #50 clk=~clk;
    //always #5000 rst_n=~rst_n;

    always@(posedge clk)
        begin
            mem_to_dma_valid <= {$random}%2;
            mem_to_dma_enable <= {$random}%2;
            cpu_to_dma_valid <= {$random}%2;
            cpu_to_dma_enable <= {$random}%2;
            address_valid <= {$random}%2;
            address_enable <= {$random}%2;
            mem_data_out <= {$random}%16;
            cpu_data_out <= {$random}%256;
            
            $display("mem_data_in=%d, cpu_data_in=%d, dma_to_cpu_enable=%d, dma_to_cpu_valid=%d, dma_to_mem_enable=%d, dma_to_mem_valid=%d, address_valid=%d, address_enable=%d, length=%d", mem_data_in, cpu_data_in, dma_to_cpu_enable, dma_to_cpu_valid, dma_to_mem_enable, dma_to_mem_valid, address_valid, address_enable, length);
        end
DMA u_DMA(.clk(clk), .rst_n(rst_n), .mem_to_dma_valid(mem_to_dma_valid), .mem_to_dma_enable(mem_to_dma_enable), .cpu_to_dma_enable(cpu_to_dma_enable), .cpu_to_dma_valid(cpu_to_dma_valid), .address_valid(adress_valid), .address_enable(address_enable), .length(length), .mem_data_out(mem_data_out), .cpu_data_out(cpu_data_out), .mem_data_in(mem_data_in), .cpu_data_in(cpu_data_in), .dma_to_cpu_enable(dma_to_cpu_enable), .dma_to_cpu_valid(dma_to_cpu_valid), .dma_to_mem_enable(dma_to_mem_enable), .dma_to_mem_valid(dma_to_mem_valid));
endmodule