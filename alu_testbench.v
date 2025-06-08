module alu #(parameter DATA_WIDTH = 8, CMD_WIDTH = 4)(
        input clk, rst, MODE, CE,
        input [1:0]INP_VALID,
        input [CMD_WIDTH-1:0]CMD,
        input [DATA_WIDTH-1:0]OPA,OPB,
        input CIN,
        output reg [2*DATA_WIDTH:0]res,
        output reg cout, oflow, g, l, e, err
);
        localparam ADD = 4'b0000, //ARITHMETIC
                        SUB = 4'b0001,
                        ADD_CIN = 4'b0010,
                        SUB_CIN = 4'b0011,
                        INC_A = 4'b0100,
                        DEC_A = 4'b0101,
                        INC_B = 4'b0110,
                        DEC_B = 4'b0111,
                        CMP = 4'b1000,
                        MUL_1 = 4'b1001,
                        MUL_2 = 4'b1010,
                        ADD_S = 4'b1011,
                        SUB_S = 4'b1100,
                        AND = 4'b0000, //LOGICAL
                        NAND = 4'b0001,
                        OR = 4'b0010,
                        NOR = 4'b0011,
                        XOR = 4'b0100,
                        XNOR = 4'b0101,
                        NOT_A = 4'b0110,
                        NOT_B = 4'b0111,
                        SHR1_A = 4'b1000,
                        SHL1_A = 4'b1001,
                        SHR1_B = 4'b1010,
                        SHL1_B = 4'b1011,
                        ROL_A_B = 4'b1100,
                        ROR_A_B = 4'b1101;

        localparam N = $clog2(DATA_WIDTH);
        
        localparam signed [DATA_WIDTH:0] MAX_POS = (1 << (DATA_WIDTH - 1)) - 1;
        localparam signed [DATA_WIDTH:0] MIN_NEG = -(1 << (DATA_WIDTH - 1));

        reg [DATA_WIDTH-1:0]opa_reg, opb_reg;
        reg [CMD_WIDTH-1:0] cmd_reg;
        reg mode_reg, ce_reg;
        reg [1:0] inp_valid_reg;
        reg cin_reg;
        
        reg [DATA_WIDTH-1:0] mul_opa, mul_opb;
        reg mul_reg1;
        reg [2*DATA_WIDTH:0] mul_res;
        reg mul_reg2;
        
        reg [N-1:0]shift_amount;
        
        reg [2*DATA_WIDTH:0] RES;
        reg COUT, OFLOW, G, L, E, ERR;
        
        wire signed [DATA_WIDTH-1:0] opa_s = opa_reg;
        wire signed [DATA_WIDTH-1:0] opb_s = opb_reg;
        reg signed [2*DATA_WIDTH:0] res_s;
        
    	always@(posedge clk or posedge rst) begin
		if(rst) begin
			opa_reg <= 0;
			opb_reg <= 0;
			ce_reg <= 0;
			mode_reg <= 0;
			cmd_reg <= 0;
			inp_valid_reg <= 0;
			cin_reg <= 0;
		end
		else begin
			opa_reg <= OPA;
			opb_reg <= OPB;
			cmd_reg <= CMD;
			mode_reg <= MODE;
			ce_reg <= CE;
			inp_valid_reg <= INP_VALID;
			cin_reg <= CIN;
		end
	end

	always @(*) begin
        RES = 0;
        COUT = 0;
        OFLOW = 0;
        G = 0;
        L = 0;
        E = 0;
        ERR = 0;
        res_s = 0;
        
        if(ce_reg) begin
            if(mode_reg) begin
                if(inp_valid_reg == 2'b11)begin
                    case(cmd_reg)
                        ADD : begin
                            RES = opa_reg + opb_reg;
                            COUT = RES[DATA_WIDTH]?1:0;
                        end
                        SUB : begin
                            OFLOW = (opa_reg < opb_reg)?1:0;
                            RES = opa_reg - opb_reg;
                        end
                        ADD_CIN : begin
                            RES = opa_reg + opb_reg + cin_reg;
                            COUT = RES[DATA_WIDTH]?1:0;
                        end
                        SUB_CIN : begin
                            OFLOW = (opa_reg < opb_reg)?1:0;
                            RES = opa_reg - opb_reg - cin_reg;
                        end
                        CMP : begin
                            if(opa_reg == opb_reg)
                            begin
                                E = 1'b1;
                            end
                            else if(opa_reg > opb_reg)
                            begin
                                G = 1'b1;
                            end
                            else if(opa_reg < opb_reg)
                            begin
                                L = 1'b1;
                            end
                            else
                            begin
                                E = 0;
                                G = 0;
                                L = 0;
                            end
                        end
                        MUL_1 : begin
                                if(mul_reg2) begin
                                    RES = mul_res;
                                end else begin
                                    RES = 0;
                                end
                        end
                        MUL_2 : begin
                                if(mul_reg2) begin
                                   RES = mul_res;
                                end else begin
                                    RES = 0;
                                end
                        end
                        ADD_S : begin
                                res_s = opa_s + opb_s;
                                RES = res_s;
                                COUT = res_s[DATA_WIDTH];
                                OFLOW = (res_s > MAX_POS) || (res_s < MIN_NEG);
                                E = (opa_s == opb_s)?1:0;
                                G = (opa_s > opb_s)?1:0;
                                L = (opa_s < opb_s)?1:0;
                        end
					    SUB_S : begin
                                res_s = opa_s - opb_s;
                                RES = res_s;
                                COUT = res_s[DATA_WIDTH];
                                OFLOW = (res_s > MAX_POS) || (res_s < MIN_NEG);
                                E = (opa_s == opb_s)?1:0;
                                G = (opa_s > opb_s)?1:0;
                                L = (opa_s < opb_s)?1:0;
                        end
                        default : begin
                                    RES = 0;
                                    COUT = 0;
                                    OFLOW = 0;
                                    G = 0;
                                    L = 0;
                                    E = 0;
                                    ERR = 1;
                               end
                    endcase
                end

                else if(inp_valid_reg == 2'b10) begin
                    case(cmd_reg)
                        INC_A : begin
                            RES = opa_reg + 1;
                            OFLOW = RES[DATA_WIDTH]?1:0;
                        end
                        DEC_A : begin
                            RES = opa_reg - 1;
                            OFLOW = (OPA < 1)?1:0;
                        end
                        default : begin
                            RES = 0;
                            COUT = 0;
                            OFLOW = 0;
                            G = 0;
                            L = 0;
                            E = 0;
                            ERR = 1;
                        end
                    endcase
                end

                else if(inp_valid_reg == 2'b01) begin
                    case(cmd_reg)
                        INC_B : begin
                            RES = opb_reg + 1;
                            OFLOW = RES[DATA_WIDTH]?1:0;
                        end
                        DEC_B : begin
                            RES = opb_reg - 1;
                            OFLOW = (opb_reg < 1)?1:0;
                        end
                        default : begin
                            RES = 0;
                            COUT = 0;
                            OFLOW = 0;
                            E = 0;
                            G = 0;
                            L = 0;
                            ERR = 1;
                        end
                    endcase
                end
				
				else begin
                        RES = 0;
                        COUT = 0;
                        OFLOW = 0;
                        G = 0;
                        L = 0;
                        E = 0;
                        ERR = 1;
                end
            end

            else begin
                if(inp_valid_reg == 2'b11) begin
                    case(cmd_reg)
                        AND : RES = {1'b0, opa_reg & opb_reg};
                        NAND : RES = {1'b0, ~(opa_reg & opb_reg)};
                        OR : RES = {1'b0, opa_reg | opb_reg};
                        NOR : RES = {1'b0, ~(opa_reg | opb_reg)};
                        XOR : RES = {1'b0, opa_reg ^ opb_reg};
                        XNOR : RES = {1'b0, ~(opa_reg ^ opb_reg)};
                        SHR1_A : RES = {1'b0, opa_reg >> 1};
                        SHL1_A : RES = {1'b0, opa_reg << 1};
                        SHR1_B : RES = {1'b0, opb_reg >> 1};
                        SHL1_B : RES = {1'b0, opb_reg << 1};
                        ROL_A_B : begin
                            ERR = (opb_reg[7] | opb_reg[6] | opb_reg[5] | opb_reg[4]);
                            shift_amount = opb_reg[N-1:0];
                            if(shift_amount == 0) begin
                                RES = opa_reg;
                            end
                            else begin
                                RES = (opa_reg << shift_amount) | (opa_reg >> (DATA_WIDTH - shift_amount));
                            end
                        end
			            ROR_A_B : begin
                            ERR = (opb_reg[7] | opb_reg[6] | opb_reg[5] | opb_reg[4]);
                            shift_amount = opb_reg[N-1:0];
                            if(shift_amount == 0)begin
                                RES = opa_reg;
                            end
                            else begin
                                RES = (opa_reg >> shift_amount) | (opa_reg << (DATA_WIDTH - shift_amount));
                            end
                        end
                        default : begin
                            RES = 0;
                            COUT = 0;
                            OFLOW = 0;
                            E = 0;
                            G = 0;
                            L = 0;
                            ERR = 1;
                        end
                    endcase
                end

                else if(inp_valid_reg == 2'b10) begin
                    case(cmd_reg)
                        NOT_A : RES = {1'b0, ~opa_reg};
                        default : ERR = 1;
                    endcase
                end

                else if(inp_valid_reg == 2'b01) begin
                    case(cmd_reg)
                        NOT_B : RES = {1'b0, ~opb_reg};
                        default : ERR = 1;
                    endcase
                end
                else begin
                    RES = 0;
                    COUT = 0;
                    OFLOW = 0;
                    E = 0;
                    G = 0;
                    L = 0;
                    ERR = 1;
                end
            end
        end
    end
    
    always@(posedge clk  or posedge rst) begin
        if(rst) begin
            mul_opa <= 0;
            mul_opb <= 0;
            mul_reg1 <= 0;
            mul_reg2 <= 0;
        end
        
        else begin
            if(ce_reg && mode_reg && inp_valid_reg == 2'b11) begin
                case(cmd_reg)
                    MUL_1 : begin
                        mul_opa <= opa_reg + 1;
                        mul_opb <= opb_reg + 1;
                    end
                    MUL_2 : begin
                        mul_opa <= opa_reg >> 1;
                        mul_opb <= opb_reg;
                    end
                    default : begin
                        mul_opa <= opa_reg;
                        mul_opb <= opb_reg;
                    end
                endcase
                mul_reg1 <= 1;
            end else begin
                mul_reg1 <= 0;
            end
        end
    end  
    
    always @(posedge clk or posedge rst) begin
        if(rst) begin
            mul_res <= 0;
            mul_reg2 <= 0;
        end else begin
            if(mul_reg1) begin
                mul_res <= mul_opa * mul_opb;
                mul_reg2 <= 1;
            end else begin
                mul_reg2 <= 0;
            end
        end
    end
    
    always@(posedge clk or posedge rst) begin
        if(rst) begin
            res <= 0;
            cout <= 0;
            oflow <= 0;
            g <= 0;
            l <= 0;
            e <= 0;
            err <= 0;
        end 
        else begin
            res <= RES;
            cout <= COUT;
            oflow <= OFLOW;
            g <= G;
            l <= L;
            e <= E;
            err <= ERR;
        end
    end
endmodule
