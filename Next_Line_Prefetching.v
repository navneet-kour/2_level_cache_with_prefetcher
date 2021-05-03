//Finding sum of all elements of 3X3 Matrix
module next_line();
//ISA
//opcode-2bits
//rs1,rs2-5bits
//rd-5bits
//imm-5bits
reg clk;
reg[4:0]pc;
reg[16:0] memory[1:31];
reg[7:0] registers[1:5];
reg[4:0]L1[0:1][1:4];
reg[4:0]L2[0:3][1:4];
reg[4:0]stream_buffer[1:3][1:3];
reg[1:0]state;
reg[16:0]instruction;
reg fetch_done = 0;
reg decode_done = 0;
reg execute_done = 0;
reg write_back_done = 0;
reg[1:0]opcode;
reg[4:0]imm,rs1,rs2,rd;
reg[4:0]address,address1;
reg L1_hit = 0;
reg buffer_hit = 0;
reg L2_hit = 0;
reg index_L1;
reg[2:1]index_L2;
reg[3:0]tag;

integer i; 

initial
begin
    
    memory[1] = 17'b00000000100000100;
    memory[2] = 17'b00011000010001101;
    memory[3] = 17'b00001000100000100;
    memory[4] = 17'b00011000010001101;
    memory[5] = 17'b00010000100000100;
    memory[6] = 17'b00011000010001101;
    memory[7] = 17'b00011000100000100;
    memory[8] = 17'b00011000010001101;
    memory[9] = 17'b00100000100000100;
    memory[10] = 17'b00011000010001101;
    memory[11] = 17'b00101000100000100;
    memory[12] = 17'b00011000010001101;
    memory[13] = 17'b00110000100000100;
    memory[14] = 17'b00011000010001101;
    memory[15] = 17'b00111000100000100;
    memory[16] = 17'b00011000010001101;
    memory[17] = 17'b01000000100000100;
    memory[18] = 17'b00011000010001101;
   
    //memory filling
    for(i = 20;i < 29;i++)begin
        memory[i] = i;
    end
    //L1 cache initializastion
    for(i = 0;i <= 1;i++)begin
        L1[i][2] = 0;
    end 
    //L2 cache initialization
    for(i = 0;i <= 3;i++)begin
        L2[i][2] = 0;
    end        
    $display("--------------------------MATRIX-------------------------------");
    $display("%d     %d     %d",memory[20],memory[21],memory[22]);
    $display("%d     %d     %d",memory[23],memory[24],memory[25]);
    $display("%d     %d     %d",memory[26],memory[27],memory[28]);
    registers[1] = 0;
    registers[2] = 20;
    registers[3] = 0;
    registers[4] = 0;
    registers[5] = 0;
    pc = 1;
    clk = 1;

end
always #5 clk = ~clk;
//fetch
always@(posedge clk)begin
    instruction = memory[pc];
    opcode = instruction[1:0];
    pc = pc+1;
    $display("PC = %d",pc);
    fetch_done = 1;    
end
//decode
always@(posedge fetch_done)begin
    case(opcode)
        2'b00:begin//load
                imm = instruction[16:12];
                rs1 = instruction[11:7];
                rd = instruction[6:2];
               
              end
        2'b01:begin//add
                rs2 = instruction[16:12];
                rs1 = instruction[11:7];
                rd = instruction[6:2];
              end
        2'b10:begin//store
                imm = instruction[16:12];
                rs2 = instruction[11:7];
                rs1 = instruction[6:2];
              end
    endcase      
    decode_done = 1;    
    fetch_done = 0;
end
//execute
always@(posedge decode_done)begin
    $display("------------------------L1------------------------------------------------------");
    $display("VALID                TAG            DATA ");
    $display("0x%0d                0x%0d          0x%0d            ",L1[0][2],L1[0][3],L1[0][4]);
    $display("0x%0d                0x%0d          0x%0d              \n",L1[1][2],L1[1][3],L1[1][4]);
    $display("------------------------L2------------------------------------------------------");
    $display("VALID                TAG            DATA ");
    $display("0x%0d                0x%0d          0x%0d            ",L2[0][2],L2[0][3],L2[0][4]);
    $display("0x%0d                0x%0d          0x%0d              ",L2[1][2],L2[1][3],L2[1][4]);
    $display("0x%0d                0x%0d          0x%0d            ",L2[2][2],L2[2][3],L2[2][4]);
    $display("0x%0d                0x%0d          0x%0d              \n",L2[3][2],L2[3][3],L2[3][4]);
    $display("------------------------STREAM BUFFER------------------------------------------------------");
    $display("TAG                AVAILABLE BIT            DATA ");
    $display("0x%0d                0x%0d                  0x%0d            ",stream_buffer[1][1],stream_buffer[1][2],stream_buffer[1][3]);
    $display("0x%0d                0x%0d                  0x%0d              ",stream_buffer[2][1],stream_buffer[2][2],stream_buffer[2][3]);
    $display("0x%0d                0x%0d                  0x%0d            \n",stream_buffer[3][1],stream_buffer[3][2],stream_buffer[3][3]);
     $display("------------------------REGISTERS
     ------------------------------------------------------");
    $display(" DATA ");
    $display(" 0x%0d            ", registers[1]);
    $display(" 0x%0d            ", registers[2]);
    $display(" 0x%0d            ", registers[3]);
    $display(" 0x%0d            ", registers[4]);
    $display(" 0x%0d           \n",registers[5]);
      case(opcode)
          2'b00:begin
                  $display("imm = %d, registers[rs1] = %d",imm,registers[rs1]);
                  address = imm+registers[rs1];
                  address1  = address;
                  index_L1 = address[0];
                  index_L2 = address[1:0];
                   $display("index_L1=%0d, index_L2= %0d", index_L1,index_L2);
                   $display("address=%0d, L1[index_L1][3]= %0d", address,L1[index_L1][3]);

                  if(L1[index_L1][2] == 1)begin//L1 valid
                      if(L1[index_L1][3] == address[4:1])begin//L1 tag match
                         
                          registers[rd] = L1[index_L1][4];
                      end
                      else begin//L1 miss(tag)
                          if(stream_buffer[1][1] == address[4:1])begin//sb tag match
                              if(stream_buffer[1][2] == 1)begin//sb available bit
                                  registers[rd] = stream_buffer[1][3];
                                  L1[index_L1][4] = stream_buffer[1][3];
                                  L1[index_L1][3] = address[4:1];
                                  L1[index_L1][2] = 1;
                                  L2[index_L2][4] = stream_buffer[1][3];
                                  L2[index_L2][3] = address[4:2];
                                  L2[index_L2][2] = 1;
                                  for(i = 1; i <= 3;i++)begin//pop and nextline prefetched
                                    address1  = address1+1;
                                    tag = address1[4:1];
                                    stream_buffer[i][3] = memory[address1];
                                    stream_buffer[i][2] = 1;
                                    stream_buffer[i][1] = memory[tag];
                                  end
                              end
                              else begin//available bit false(check L2)
                            if(L2[index_L2][2] == 1)begin//valid bit check
                                if(L2[index_L2][3] == address[4:2])begin//tag check
                                    registers[rd] = L2[index_L2][4];
                                end
                                else begin//L2 miss(tag nm)
                                    L1[index_L1][4] = memory[address];
                                    L1[index_L1][3] = address[4:1];
                                    L1[index_L1][2] = 1;
                                    L2[index_L2][4] = memory[address];
                                    registers[rd] = L1[index_L1][4];
                                    L2[index_L2][3] = address[4:2];
                                    L2[index_L2][2] = 1;                                                                    
                                end
                              end
                            else begin//L2 miss(not valid )
                                L1[index_L1][4] = memory[address];
                                L1[index_L1][3] = address[4:1];
                                L1[index_L1][2] = 1;
                                L2[index_L2][4] = memory[address];
                                registers[rd] = L1[index_L1][4];
                                L2[index_L2][3] = address[4:2];
                                L2[index_L2][2] = 1;     
                            end                                
                            for(i = 1; i <= 3;i++)begin//NEXT LINE PREFETCHING
                                address1  = address1+1;
                                tag = address1[4:1];
                                stream_buffer[i][3] = memory[address1];
                                stream_buffer[i][2] = 1;
                                stream_buffer[i][1] = memory[tag];
                            end
                        end
                    end   
                    else begin//SB not tag match
                              if(L2[index_L2][2] == 1)begin//valid bit check
                                if(L2[index_L2][3] == address[4:2])begin//tag check
                                    registers[rd] = L2[index_L2][4];
                                end
                                else begin//L2 miss tag nm
                                    L1[index_L1][4] = memory[address];
                                    L1[index_L1][3] = address[4:1];
                                    L1[index_L1][2] = 1;
                                    L2[index_L2][4] = memory[address];
                                    registers[rd] = L1[index_L1][4];
                                    L2[index_L2][3] = address[4:2];
                                    L2[index_L2][2] = 1;                                                                    
                                end
                              end
                            else begin//L2 miss--not valid
                                L1[index_L1][4] = memory[address];
                                L1[index_L1][3] = address[4:1];
                                L1[index_L1][2] = 1;
                                L2[index_L2][4] = memory[address];
                                L2[index_L2][3] = address[4:2];
                                L2[index_L2][2] = 1;     
                                registers[rd] = L1[index_L1][4];
                            end                                
                            for(i = 1; i <= 3;i++)begin//NEXT LINE PREFETCHING
                                address1  = address1+1;
                                tag = address1[4:1];
                                stream_buffer[i][3] = memory[address1];
                                stream_buffer[i][2] = 1;
                                stream_buffer[i][1] = memory[tag];
                            end
                        end
                    end
                         
            end                  
            else begin //L1 valid bit=0
                if(stream_buffer[1][1] == address[4:1])begin//sb tag match
                              if(stream_buffer[1][2] == 1)begin//sb available bit
                                  registers[rd] = stream_buffer[1][3];
                                  L1[index_L1][4] = stream_buffer[1][3];
                                  L1[index_L1][3] = address[4:1];
                                  L1[index_L1][2] = 1;
                                  L2[index_L2][4] = stream_buffer[1][3];
                                  L2[index_L2][3] = address[4:2];
                                  L2[index_L2][2] = 1;
                                  for(i = 1; i <= 3;i++)begin//pop and nextline prefetched
                                    address1  = address1+1;
                                    tag = address1[4:1];
                                    stream_buffer[i][3] = memory[address1];
                                    stream_buffer[i][1] = memory[tag];
                                  end
                              end
                              else begin//available bit false(check L2)
                            if(L2[index_L2][2] == 1)begin//valid bit check
                                if(L2[index_L2][3] == address[4:2])begin//tag check
                                    registers[rd] = L2[index_L2][4];
                                end
                                else begin//L2 miss(tag nm)
                                    L1[index_L1][4] = memory[address];
                                    L1[index_L1][3] = address[4:1];
                                    L1[index_L1][2] = 1;
                                    L2[index_L2][4] = memory[address];
                                    L2[index_L2][3] = address[4:2];
                                    L2[index_L2][2] = 1;            
                                    registers[rd] = L1[index_L1][4];                                                        
                                end
                              end
                            else begin//L2 miss(not valid )
                                L1[index_L1][4] = memory[address];
                                L1[index_L1][3] = address[4:1];
                                L1[index_L1][2] = 1;
                                L2[index_L2][4] = memory[address];
                                L2[index_L2][3] = address[4:2];
                                L2[index_L2][2] = 1;     
                                registers[rd] = L1[index_L1][4];
                            end                                
                            for(i = 1; i <= 3;i++)begin//NEXT LINE PREFETCHING
                                address1  = address1+1;
                                tag = address1[4:1];
                                stream_buffer[i][3] = memory[address1];
                                stream_buffer[i][2] = 1;
                                stream_buffer[i][1] = memory[tag];
                            end
                        end
                    end   
                    else begin//SB not tag match
                              if(L2[index_L2][2] == 1)begin//valid bit check
                                if(L2[index_L2][3] == address[4:2])begin//tag check
                                    registers[rd] = L2[index_L2][4];
                                end
                                else begin//L2 miss tag nm
                                    L1[index_L1][4] = memory[address];
                                    L1[index_L1][3] = address[4:1];
                                    L1[index_L1][2] = 1;
                                    L2[index_L2][4] = memory[address];
                                    L2[index_L2][3] = address[4:2];
                                    L2[index_L2][2] = 1;
                                    registers[rd] = L1[index_L1][4];                                                                    
                                end
                              end
                            else begin//L2 miss--not valid
                                $display("L2 miss--->not valid");
                                L1[index_L1][4] = memory[address];
                                L1[index_L1][3] = address[4:1];
                                L1[index_L1][2] = 1;
                                L2[index_L2][4] = memory[address];
                                L2[index_L2][3] = address[4:2];
                                L2[index_L2][2] = 1;     
                                registers[rd] = L1[index_L1][4];
                            end                                
                            for(i = 1; i <= 3;i++)begin//NEXT LINE PREFETCHING
                                address1  = address1+1;
                                tag = address1[4:1];
                                stream_buffer[i][3] = memory[address1];
                                stream_buffer[i][2] = 1;
                                stream_buffer[i][1] = memory[tag];
                            end
                        end
                
            end 
          end                               
          2'b01:begin
                registers[rd] = registers[rs1] + registers[rs2];
                end

      endcase      
      execute_done = 1;
      decode_done = 0;

    if(pc == 20)begin
        $display("Final Sum of MATRIX= %d",registers[rd]);
        $finish;
    end

end

endmodule
