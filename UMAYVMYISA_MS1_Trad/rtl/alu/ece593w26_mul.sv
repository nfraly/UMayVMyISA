module boothmul #(parameter WIDTH = 8) (input logic [WIDTH-1:0] w2mul, input logic [WIDTH-1:0] x2mul, input logic clk, input logic rst, output logic [WIDTH*2-1:0] mul2acc);

//Pipeline registers per stage
logic [WIDTH-1:0] qIn [WIDTH:0];
logic [WIDTH-1:0] aIn [WIDTH:0];
logic [WIDTH-1:0] qOut [WIDTH:0];
logic [WIDTH-1:0] aOut [WIDTH:0];
logic [WIDTH-1:0] mIn [WIDTH:0];
logic [WIDTH-1:0] mOut [WIDTH:0];
logic qzIn [WIDTH:0];
logic qzOut [WIDTH:0];
logic [WIDTH-1:0] x2mulReg, w2mulReg;
logic [WIDTH*2-1:0] mul2accReg;

int count;
//setup first slice of multiplier
assign qzIn[0] = '0;
assign qIn[0] = {1'b0, w2mulReg};
assign aIn[0] = '0;
assign mIn[0] = {1'b0, x2mulReg};

//generate multiplier slices
genvar slices;
int i;

generate
for (slices = 0; slices < WIDTH; slices++)
	begin : multiplier
		//instantiate each multiplier pipeline stage
		ppgBooth #(.WIDTH(WIDTH)) slice (.qIn(qOut[slices]), .qzIn(qzOut[slices]), .aIn(aOut[slices]), .mIn(mOut[slices]), .clk(clk), .rst(rst), .aOut(aIn[slices+1]), .mOut (mIn[slices+1]), .qOut(qIn[slices+1]), .qzOut(qzIn[slices+1]));
	end
	endgenerate

//setup signals for generate loop
always_comb begin
	if (rst) begin
    for (i = 0; i <= WIDTH; i++) begin
		qOut[i] = '0;
		aOut[i] = '0;
		qzOut[i] = '0;
		mOut[i] = '0;
    end
	end
	else begin
		for (i = 0; i <= WIDTH; i=i+1)
		begin
			qOut[i] = qIn[i];
			qzOut[i] = qzIn[i];
			aOut[i] = aIn[i];
			mOut[i] = mIn[i];
		end
	end
end


//Register input/output

always_ff @(posedge clk) begin
    if (rst) begin
        mul2accReg <= '0;
        x2mulReg <= '0;
        w2mulReg <= '0;
    end
    else begin
        mul2accReg <= {aIn[WIDTH], qIn[WIDTH]};
        x2mulReg <= x2mul;
        w2mulReg <= w2mul;
    end
end

assign mul2acc = mul2accReg;


endmodule



module ppgBooth #(parameter WIDTH = 8) (input logic [WIDTH-1:0] qIn, input logic qzIn, input logic [WIDTH-1:0] aIn, input logic [WIDTH-1:0] mIn, input logic clk, input logic rst, output logic [WIDTH-1:0] aOut, output logic [WIDTH-1:0] mOut, output logic [WIDTH-1:0] qOut, output logic qzOut);

//control signals
logic [1:0] psm; //plus, stay, or minus

logic plus, minus; //adding or subtracting m from a

//internal signals
logic [WIDTH-1:0] a;

//multiplication slice logic
assign psm = {qIn[0], qzIn};

//Add if they do not match and the lower bit is a 1
assign plus = psm[1] ^ psm[0] ? psm[0] : 0;

//subtract if they do not match and the upper bit is a 1
assign minus = psm[1] ^ psm[0] ? psm[1] : 0;

//Modify a as needed
assign a = plus ? aIn+mIn : minus ? aIn-mIn : aIn;

//shift {a,q} output
assign aOut = {a[WIDTH-1], a[WIDTH-1:1]};
assign qOut = {a[0], qIn[WIDTH-1:1]};
assign qzOut = qIn[0];

//Pass m onto the next stage
assign mOut = mIn;

endmodule
