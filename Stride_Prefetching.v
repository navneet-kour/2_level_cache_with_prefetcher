//Finding TRACE of 6X6 Matrix
module stride();
//ISA
//opcode-2bits
//rs1,rs2-5bits
//rd-5bits
//imm-6bits
reg clk;
reg[4:0]pc;
reg[17:0] memory[1:50];
reg[7:0] registers[1:5];
reg[5:0]L1[0:1][1:4];
reg[5:0]L2[0:3][1:4];
reg[5:0]stream_buffer[1:2][1:3];
reg[1:0]state;
reg[17:0]instruction;
reg fetch_done = 0;
reg decode_done = 0;
reg execute_done = 0;
reg write_back_done = 0;
reg[1:0]opcode;
reg[5:0]imm;
reg[4:0]rs1,rs2,rd;
reg[5:0]address,address1;
reg L1_hit = 0;
reg buffer_hit = 0;
reg L2_hit = 0;
reg index_L1;
reg[2:1]index_L2;
reg[3:0]tag;

integer i,k=7;//STRIDE 

initial
begin
    
    memory[1] = 18'b000000000100000100;
    memory[2] = 18'b000011000010001101;
    memory[3] = 18'b000111000100000100;
    memory[4] = 18'b000011000010001101;
    memory[5] = 18'b001110000100000100;
    memory[6] = 18'b000011000010001101;
    memory[7] = 18'b010101000100000100;
    memory[8] = 18'b000011000010001101;
    memory[9] = 18'b011100000100000100;
    memory[10] = 18'b000011000010001101;
    memory[11] = 18'b100011000100000100;
    memory[12] = 18'b000011000010001101;
    //memory filling
    for(i = 13;i < 49;i++)begin
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
    $display("%d     %d     %d      %d    %d    %d",memory[13],memory[14],memory[15],memory[16],memory[17],memory[18]);
    $display("%d     %d     %d      %d    %d    %d",memory[19],memory[20],memory[21],memory[22],memory[23],memory[24]);
    $display("%d     %d     %d      %d    %d    %d",memory[25],memory[26],memory[27],memory[28],memory[29],memory[30]);
    $display("%d     %d     %d      %d    %d    %d",memory[31],memory[32],memory[33],memory[34],memory[35],memory[36]);
    $display("%d     %d     %d      %d    %d    %d",memory[37],memory[38],memory[39],memory[40],memory[41],memory[42]);
    $display("%d     %d     %d      %d    %d    %d\n",memory[43],memory[44],memory[45],memory[46],memory[47],memory[48]);
    registers[1] = 0;
    registers[2] = 13;
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
    $display("PC = %d",pc);
    fetch_done = 1;    
end
//decode
always@(posedge fetch_done)begin
    case(opcode)
        2'b00:begin//load
                imm = instruction[17:12];
                rs1 = instruction[11:7];
                rd = instruction[6:2];
               
              end
        2'b01:begin//add
                rs2 = instruction[17:12];
                rs1 = instruction[11:7];
                rd = instruction[6:2];
              end
        2'b10:begin//store
                imm = instruction[17:12];
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
    $display("------------------------REGISTERS------------------------------------------------------");
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
                      
                      if(L1[index_L1][3] == address[5:1])begin//L1 tag match
                        
                          registers[rd] = L1[index_L1][4];
                      end
                      else begin//L1 miss(tag)
                          if(stream_buffer[1][1] == address[5:1])begin//sb tag match
                              if(stream_buffer[1][2] == 1)begin//sb available bit
                                  registers[rd] = stream_buffer[1][3];
                                  L1[index_L1][4] = stream_buffer[1][3];
                                  L1[index_L1][3] = address[5:1];
                                  L1[index_L1][2] = 1;
                                  L2[index_L2][4] = stream_buffer[1][3];
                                  L2[index_L2][3] = address[5:2];
                                  L2[index_L2][2] = 1;
                                  for(i = 1; i <= 2;i++)begin//pop and stride prefetched
                                    address1  = address1 + k;//k=7-->STRIDE
                                    tag = address1[5:1];
                                    stream_buffer[i][3] = memory[address1];
                                    stream_buffer[i][2] = 1;
                                    stream_buffer[i][1] = memory[tag];
                                  end
                              end
                              else begin//available bit false(check L2)
                            if(L2[index_L2][2] == 1)begin//valid bit check
                                if(L2[index_L2][3] == address[5:2])begin//tag check
                                    registers[rd] = L2[index_L2][4];
                                end
                                else begin//L2 miss(tag nm)
                                    L1[index_L1][4] = memory[address];
                                    L1[index_L1][3] = address[5:1];
                                    L1[index_L1][2] = 1;
                                    L2[index_L2][4] = memory[address];
                                    registers[rd] = L1[index_L1][4];
                                    L2[index_L2][3] = address[5:2];
                                    L2[index_L2][2] = 1;                                                                    
                                end
                              end
                            else begin//L2 miss(not valid )
                                L1[index_L1][4] = memory[address];
                                L1[index_L1][3] = address[5:1];
                                L1[index_L1][2] = 1;
                                L2[index_L2][4] = memory[address];
                                registers[rd] = L1[index_L1][4];
                                L2[index_L2][3] = address[5:2];
                                L2[index_L2][2] = 1;     
                            end                                
                            for(i = 1; i <= 3;i++)begin//STRIDE PREFETCHING
                                address1  = address1+k;
                                tag = address1[5:1];
                                stream_buffer[i][3] = memory[address1];
                                stream_buffer[i][2] = 1;
                                stream_buffer[i][1] = memory[tag];
                            end
                        end
                    end   
                    else begin//SB not tag match
                              if(L2[index_L2][2] == 1)begin//valid bit check
                                if(L2[index_L2][3] == address[5:2])begin//tag check
                                    registers[rd] = L2[index_L2][4];
                                end
                                else begin//L2 miss tag nm
                                    L1[index_L1][4] = memory[address];
                                    L1[index_L1][3] = address[5:1];
                                    L1[index_L1][2] = 1;
                                    L2[index_L2][4] = memory[address];
                                    registers[rd] = L1[index_L1][4];
                                    L2[index_L2][3] = address[5:2];
                                    L2[index_L2][2] = 1;                                                                    
                                end
                              end
                            else begin//L2 miss--not valid
                                L1[index_L1][4] = memory[address];
                                L1[index_L1][3] = address[5:1];
                                L1[index_L1][2] = 1;
                                L2[index_L2][4] = memory[address];
                                L2[index_L2][3] = address[5:2];
                                L2[index_L2][2] = 1;     
                                registers[rd] = L1[index_L1][4];
                            end                                
                            for(i = 1; i <= 3;i++)begin//STRIDE PREFETCHING
                                address1  = address1+i*k;
                                tag = address1[5:1];
                                stream_buffer[i][3] = memory[address1];
                                stream_buffer[i][2] = 1;
                                stream_buffer[i][1] = memory[tag];
                            end
                        end
                    end
                         
            end                  
            else begin //L1 valid bit=0
                if(stream_buffer[1][1] == address[5:1])begin//sb tag match
                              if(stream_buffer[1][2] == 1)begin//sb available bit
                                  registers[rd] = stream_buffer[1][3];
                                  L1[index_L1][4] = stream_buffer[1][3];
                                  L1[index_L1][3] = address[5:1];
                                  L1[index_L1][2] = 1;
                                  L2[index_L2][4] = stream_buffer[1][3];
                                  L2[index_L2][3] = address[5:2];
                                  L2[index_L2][2] = 1;
                                  for(i = 1; i <= 3;i++)begin//pop and STRIDE prefetched
                                    address1  = address1+k;
                                    tag = address1[5:1];
                                    stream_buffer[i][3] = memory[address1];
                                    stream_buffer[i][1] = memory[tag];
                                  end
                              end
                              else begin//available bit false(check L2)
                            if(L2[index_L2][2] == 1)begin//valid bit check
                                if(L2[index_L2][3] == address[5:2])begin//tag check
                                    registers[rd] = L2[index_L2][4];
                                end
                                else begin//L2 miss(tag nm)
                                    L1[index_L1][4] = memory[address];
                                    L1[index_L1][3] = address[5:1];
                                    L1[index_L1][2] = 1;
                                    L2[index_L2][4] = memory[address];
                                    L2[index_L2][3] = address[5:2];
                                    L2[index_L2][2] = 1;            
                                    registers[rd] = L1[index_L1][4];                                                        
                                end
                              end
                            else begin//L2 miss(not valid )
                                L1[index_L1][4] = memory[address];
                                L1[index_L1][3] = address[5:1];
                                L1[index_L1][2] = 1;
                                L2[index_L2][4] = memory[address];
                                L2[index_L2][3] = address[5:2];
                                L2[index_L2][2] = 1;     
                                registers[rd] = L1[index_L1][4];
                            end                                
                            for(i = 1; i <= 3;i++)begin//STRIDE PREFETCHING
                                address1  = address1+k;
                                tag = address1[5:1];
                                stream_buffer[i][3] = memory[address1];
                                stream_buffer[i][2] = 1;
                                stream_buffer[i][1] = memory[tag];
                            end
                        end
                    end   
                    else begin//SB not tag match
                              if(L2[index_L2][2] == 1)begin//valid bit check
                                if(L2[index_L2][3] == address[5:2])begin//tag check
                                    registers[rd] = L2[index_L2][4];
                                end
                                else begin//L2 miss tag nm
                                    L1[index_L1][4] = memory[address];
                                    L1[index_L1][3] = address[5:1];
                                    L1[index_L1][2] = 1;
                                    L2[index_L2][4] = memory[address];
                                    L2[index_L2][3] = address[5:2];
                                    L2[index_L2][2] = 1;
                                    registers[rd] = L1[index_L1][4];                                                                    
                                end
                              end
                            else begin//L2 miss--not valid
                                $display("L2 miss-->not valid");
                                L1[index_L1][4] = memory[address];
                                L1[index_L1][3] = address[5:1];
                                L1[index_L1][2] = 1;
                                L2[index_L2][4] = memory[address];
                                L2[index_L2][3] = address[5:2];
                                L2[index_L2][2] = 1;     
                                registers[rd] = L1[index_L1][4];
                            end                                
                            for(i = 1; i <= 3;i++)begin//STRIDE PREFETCHING
                                address1  = address1+k;
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
      pc = pc+1;

    if(pc == 13)begin
        $display("TRACE of MATRIX= %d",registers[3]);
        $finish;
    end

end

endmodule