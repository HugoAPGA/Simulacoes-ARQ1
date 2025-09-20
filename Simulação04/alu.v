module alu (
  input wire [31:0] op1,   // rs1
  input wire [31:0] op2,   // rs2 or Immediate
  input wire [31:0] instr, // instruction
  output reg [31:0] res);  // result

  // Posições importantes da instrução
  wire [6:0] type_instruction = instr[6:0];
  wire [2:0] funct3 = instr[14:12];
  wire [6:0] funct7 = instr[31:25];

  // Variável para o shift amount
  wire [4:0] shamt = op2[31:27] == 5'b00000 ? op2[4:0] : 5'b00000;

  always_comb begin
    // Inicializa o resultado para evitar latches
    res = 32'b0;

    case (type_instruction)
      // R-type instructions
      7'b0110011: begin
        case (funct3)
          3'b000: begin // ADD / SUB
            if (funct7 == 7'b0000000) begin
              res = op1 + op2; // ADD
            end else if (funct7 == 7'b0100000) begin
              res = op1 - op2; // SUB
            end
          end
          3'b001: res = op1 << shamt; // SLL
          3'b010: res = ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0; // SLT
          3'b011: res = (op1 < op2) ? 32'b1 : 32'b0; // SLTU
          3'b100: res = op1 ^ op2; // XOR
          3'b101: begin // SRL / SRA
            if (funct7 == 7'b0000000)
              res = op1 >> shamt; // SRL
            else if (funct7 == 7'b0100000)
              res = $signed(op1) >>> shamt; // SRA
          end
          3'b110: res = op1 | op2; // OR
          3'b111: res = op1 & op2; // AND
          default: res = 32'b0;
        endcase
      end
      
      // I-type ALU operations
      7'b0010011: begin
        case (funct3)
          3'b000: res = op1 + op2; // ADDI
          3'b010: res = ($signed(op1) < $signed(op2)) ? 32'b1 : 32'b0; // SLTI
          3'b011: res = (op1 < op2) ? 32'b1 : 32'b0; // SLTIU
          3'b100: res = op1 ^ op2; // XORI
          3'b110: res = op1 | op2; // ORI
          3'b111: res = op1 & op2; // ANDI
          3'b001: begin // SLLI
            if (funct7 == 7'b0000000) begin
                res = op1 << shamt;
            end
          end
          3'b101: begin // SRLI / SRAI
            if (funct7 == 7'b0000000)
              res = op1 >> shamt; // SRLI
            else if (funct7 == 7'b0100000)
              res = $signed(op1) >>> shamt; // SRAI
          end
          default: res = 32'b0;
        endcase
      end
      7'b1110011: begin
        // ECALL and EBREAK do not produce an ALU result
        res = op1 | op2; // Just a placeholder operation
      end
      default: res = 32'b0; // Default case for unsupported instructions
    endcase
  end
endmodule