`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2017/12/26 10:32:43
// Design Name: 
// Module Name: DMA
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


module DMA(
    input clk, 
    input rst_n,
    
    input mem_to_dma_valid, //a signal to control the validity of input from memory to dma
    input mem_to_dma_enable,//a signal to show that memory is available to accept input
    input cpu_to_dma_valid, //a signal to control the validity of input from cpu to dma
    input cpu_to_dma_enable,//a signal to show that cpu is available to accept input
    input address_valid,//a signal to control the validity of achievement of address
    input address_enable,//a signal to show that dma is available to accept address==mem_to_dma_enable
   
    input [10:0] length,//a given random length to represent the user's need
    input [3:0] mem_data_out,//data in from memory to dma
    input [7:0] cpu_data_out,//data in from cpu to dma        
    
    output reg [3:0] mem_data_in,//data out from dma to memory
    output reg [7:0] cpu_data_in,//data out from dma to cpu

    output reg dma_to_mem_valid,
    output reg dma_to_mem_enable,
    output reg dma_to_cpu_valid,
    output reg dma_to_cpu_enable
    );
    
    reg data_flow_direction=0;//1:memory to cpu, 0:cpu to memory

    reg [7:0] buf1 [7:0];
    reg [7:0] buf2 [7:0];
   // reg [9:0] address;//temp
    
    reg [2:0] buf1_read_ptr, buf2_read_ptr;//the pointer points to the position of reading
    reg [2:0] buf1_write_ptr, buf2_write_ptr;//the pointer points to the position of writing
    reg [1:0] counter_ptr;
   // reg [3:0] adress_read_ptr,adress_write_ptr;
    reg buf1_write_low, buf1_read_low;//write or read in the low position
    reg buf2_write_low, buf2_read_low;//write or read in the low position
    reg counter_low;
    //reg [3:0] address_write_low,address_read_low;

    reg [4:0] counter_buf1, counter_buf2;//count the number of data in buf1 and buf2
    reg [1:0] counter_address [10:0];

    reg [5:0] currentstate, nextstate;
    //memory to cpu direction
    parameter    S0  = 6'b00_0000;//empty buf1, empty buf2 
    parameter    S1  = 6'b00_0001;//not full buf1, not empty buf2 
    parameter    S2  = 6'b00_0010;//full buf1, not empty buf2
    parameter    S3  = 6'b00_0100;//not full buf1, empty buf2
    //cpu to memory direction
    parameter    S4  = 6'b00_1000;//not empty buf1, not full buf2
    parameter    S5  = 6'b01_0000;//not empty buf1, full buf2
    parameter    S6  = 6'b10_0000;//empty buf1, not full buf2

    always@(posedge clk or negedge rst_n)
        begin
            if(!rst_n)
                begin
                    currentstate <= S0;
                    nextstate <= S0;
                end
            else
                begin
                    currentstate <= nextstate;
                end
        end

    always@(*)
        begin
                case(currentstate)
                    S0:
                          if (counter_buf1<16&&counter_buf1>0&&counter_buf2<16&&counter_buf2>0)
                             nextstate = S1;
                          else
                             nextstate = currentstate;
                    S1:
                        if(counter_buf1==16 && counter_buf2>0)
                            nextstate = S2;
                        else if(counter_buf1<16 && counter_buf2==0)
                            nextstate = S3;
                        else if(counter_buf1==16 && counter_buf2==0)//？
                            nextstate = S4;
                        else if(counter_buf1==0&&counter_buf2==0)
                            nextstate = S0;
                        else 
                            nextstate = currentstate;
                    S2:
                        if(counter_buf1==16 && counter_buf2==0)//？
                            nextstate = S4;
                        else
                            nextstate = currentstate;
                    S3:
                        if(counter_buf1==16 && counter_buf2==0)//？
                            nextstate = S4;
                        else if(counter_buf1==0&&counter_buf2==0)
                            nextstate = S0;
                        else
                            nextstate = currentstate;
                    S4:
                        if(counter_buf1>0 && counter_buf2==16)
                            nextstate = S5;
                        else if(counter_buf1==0 && counter_buf2<16)
                            nextstate = S6;
                        else if(counter_buf1==0 && counter_buf2==16)//？
                            nextstate = S1;
                        else
                            nextstate = currentstate;
                    S5:
                        if(counter_buf1==0 && counter_buf2==16)//？
                            nextstate = S1;
                        else
                            nextstate = currentstate;
                    S6:
                        if(counter_buf1==0 && counter_buf2==16)//？
                            nextstate = S1;
                        else if(counter_buf1==0&&counter_buf2==0)
                            nextstate = S0;
                        else
                            nextstate = currentstate;
                    default:
                        nextstate = currentstate;
                endcase
        end

        always@(negedge rst_n)
            begin
                if(!rst_n)
                    begin
                        data_flow_direction=~data_flow_direction;

                        mem_data_in=4'b0000;
                        cpu_data_in=8'b0000_0000;
                        counter_low=1;
                        counter_ptr=0;
                        if (length>9'd256)
                        begin
                            counter_address[0]=9'd256;//初始所取的数据未输出
                            counter_address[1]=length-9'd256;
                            counter_low=0;
                        end
                        else
                            counter_address[0]=length;

                        counter_buf1=0;
                        counter_buf2=0;

                        buf1_read_ptr=0;
                        buf1_write_ptr=0;
                        buf2_read_ptr=0;
                        buf2_write_ptr=0;

                        buf1_write_low=1;
                        buf1_read_low=1;
                        buf2_write_low=1;
                        buf2_read_low=1;

                        if(data_flow_direction)
                            begin
                                dma_to_mem_enable=1;
                                dma_to_cpu_valid=0;
                                dma_to_mem_valid=0;
                                dma_to_cpu_enable=0;
                            end
                        else
                            begin
                                dma_to_mem_enable=0;
                                dma_to_cpu_valid=0;
                                dma_to_mem_valid=0;
                                dma_to_cpu_enable=1;
                            end
                    end
            end

        always@(posedge clk)//为啥阻塞赋值和非阻塞赋值交叉着用？
            begin
                if(data_flow_direction)
                    begin
                        case(nextstate)
                            S1,S3:
                                begin
                                    if(counter_address[counter_ptr]==0)
                                       begin
                                          buf1_write_low <= 0;
                                          buf1_write_ptr <= 3;
                                          counter_buf1 <= 7;
                                          if (counter_low==0&&counter_ptr==0)
                                          begin
                                            counter_ptr <= counter_ptr+1;
                                            counter_low <= 1;
                                          end
                                          if (counter_ptr==1)
                                            counter_ptr <= 0;
                                       end
                                    else
                                    if(mem_to_dma_valid && dma_to_mem_enable&&address_valid&&address_enable)
                                        begin
                                            if(buf1_write_low)
                                                buf1[buf1_write_ptr][3:0] <= mem_data_out;
                                            else
                                                buf1[buf1_write_ptr][7:4] <= mem_data_out;
                                    
                                            if(!buf1_write_low)
                                                buf1_write_ptr <= buf1_write_ptr+1;
                                    
                                            buf1_write_low <= ~buf1_write_low;

                                            counter_buf1 <= counter_buf1 + 1;
                                            counter_address[counter_ptr] <= counter_address[counter_ptr] - 1;
                                        end
                                end
                            S4, S6:
                                begin
                                    if(counter_address[counter_ptr]==0)
                                        begin
                                            buf2_write_low <= 0;
                                            buf2_write_ptr <= 3;
                                            counter_buf2 <= 7;
                                            if (counter_low==0&&counter_ptr==0)
                                            begin
                                               counter_ptr <= counter_ptr+1;
                                               counter_low <= 1;
                                            end
                                            if (counter_ptr==1)
                                                counter_ptr <= 0;
                                        end
                                    else
                                    if(mem_to_dma_valid && dma_to_mem_enable&&address_valid&&address_enable)
                                        begin
                                            if(buf2_write_low)
                                                buf2[buf2_write_ptr][3:0] <= mem_data_out;
                                            else
                                                buf2[buf2_write_ptr][7:4] <= mem_data_out;
                                    
                                            if(!buf2_write_low)
                                                buf2_write_ptr <= buf2_write_ptr+1;
                                    
                                            buf2_write_low <= ~buf2_write_low;

                                            counter_buf2 <= counter_buf2 + 1;
                                            counter_address[counter_ptr] <= counter_address[counter_ptr] - 1;
                                        end
                                end
                            default: ;
                        endcase
                    end
                else
                    begin
                        case(nextstate)
                            S1,S3:
                                begin
                                    if(cpu_to_dma_valid && dma_to_cpu_enable)
                                        begin
                                            buf1[buf1_write_ptr] <= cpu_data_out;
                                    
                                            buf1_write_ptr <= buf1_write_ptr+1;

                                            counter_buf1 <= counter_buf1 + 2;
                                        end
                                end
                            S4,S6:
                                begin
                                    if(cpu_to_dma_valid && dma_to_cpu_enable)
                                        begin
                                            buf2[buf2_write_ptr] <= cpu_data_out;
                                    
                                            buf2_write_ptr <= buf2_write_ptr+1;

                                            counter_buf2 <= counter_buf2 + 2;
                                        end
                                end
                            default: ;
                        endcase
                    end
            end        

        always@(posedge clk)
            begin
                if(data_flow_direction)
                    begin
                        case(nextstate)
                            S1,S2:
                                begin
                                    if(dma_to_cpu_valid && cpu_to_dma_enable)
                                        begin
                                            cpu_data_in <= buf2[buf2_read_ptr];

                                            buf2_read_ptr <= buf2_read_ptr + 1;

                                            counter_buf2 <= counter_buf2 - 2;
                                        end
                                end
                            S4,S5:
                                begin
                                    if(dma_to_cpu_valid && cpu_to_dma_enable)
                                        begin
                                            cpu_data_in <= buf1[buf1_read_ptr];

                                            buf1_read_ptr <= buf1_read_ptr + 1;

                                            counter_buf1 <= counter_buf1 - 2;
                                        end
                                end
                            default: ;
                        endcase
                    end 
                else
                    begin
                        case(nextstate)
                            S1,S2:
                                begin
                                    if(dma_to_mem_valid && mem_to_dma_enable)
                                        begin
                                            if(buf2_read_low)
                                                mem_data_in <= buf2[buf2_read_ptr][3:0];
                                            else
                                                mem_data_in <= buf2[buf2_read_ptr][7:4];
                                            
                                            if(!buf2_read_low)
                                                buf2_read_ptr <= buf2_read_ptr + 1;

                                            buf2_read_low = ~buf2_read_ptr;

                                            counter_buf2 <= counter_buf2 - 1;
                                        end
                                end
                            S4,S5:
                                begin
                                    if(dma_to_mem_valid && mem_to_dma_enable)
                                        begin
                                            if(buf1_read_low)
                                                mem_data_in <= buf1[buf1_read_ptr][3:0];
                                            else
                                                mem_data_in <= buf1[buf1_read_ptr][7:4];
                                            
                                            if(!buf1_read_low)
                                                buf1_read_ptr <= buf1_read_ptr + 1;

                                            buf1_read_low = ~buf1_read_ptr;

                                            counter_buf1 <= counter_buf1 - 1;
                                        end
                                end
                            default: ;
                        endcase
                    end
            end

        always@(posedge clk)
            begin
                if(data_flow_direction)
                    case(nextstate)
                        S1,S4:
                            begin
                                dma_to_mem_enable <= 1;
                                dma_to_cpu_valid <= 1;
                            end
                        S2,S5:
                            begin
                                dma_to_mem_enable <= 0;//？
                            end
                        S3,S6:
                            begin
                                dma_to_cpu_valid <= 0;//？
                            end
                        default: ;
                    endcase
                else
                    case(nextstate)
                        S1,S4:
                            begin
                                dma_to_mem_valid <= 1;
                                dma_to_cpu_enable <= 1;
                            end
                        S2,S5:
                            begin
                                dma_to_cpu_enable <= 0;//？
                            end
                        S3,S6:
                            begin
                                dma_to_mem_valid <= 0;//？
                            end
                    endcase
            end

endmodule
            