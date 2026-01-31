module boothmul #(parameter WIDTH = 8) (input logic [WIDTH-1:0] w2mul, input logic [WIDTH-1:0] x2mul, input logic clk, input logic rst, output logic [WIDTH*2-1:0] mul2acc);

//Pipeline registers per stage
logic [WIDTH:0] qInPipe [WIDTH+1:0];
logic [WIDTH:0] aInPipe [WIDTH+1:0];
logic [WIDTH:0] qOutPipe [WIDTH+1:0];
logic [WIDTH:0] aOutPipe [WIDTH+1:0];
logic [WIDTH:0] mInPipe [WIDTH+1:0];
logic [WIDTH:0] mOutPipe [WIDTH+1:0];
logic qzInPipe [WIDTH+1:0];
logic qzOutPipe [WIDTH+1:0];

int count;
//setup first slice of multiplier
assign qzInPipe[0] = '0;
assign qInPipe[0] = {1'b0, w2mul};
assign aInPipe[0] = '0;
assign mInPipe[0] = {1'b0, x2mul};

//generate multiplier slices
genvar slices;
int i;

generate
for (slices = 0; slices <= WIDTH; slices++)
	begin : multiplier
		//instantiate each multiplier pipeline stage
		ppgBooth #(.WIDTH(WIDTH)) slice (.qIn(qOutPipe[slices]), .qzIn(qzOutPipe[slices]), .aIn(aOutPipe[slices]), .mIn(mOutPipe[slices]), .clk(clk), .rst(rst), .aOut(aInPipe[slices+1]), .mOut (mInPipe[slices+1]), .qOut(qInPipe[slices+1]), .qzOut(qzInPipe[slices+1]));
	end
	endgenerate

always_ff @(posedge clk) begin
	if (rst) begin
    for (i = 0; i <= WIDTH+1; i++) begin
		qOutPipe[i] <= '0;
		aOutPipe[i] <= '0;
		qzOutPipe[i] <= '0;
		mOutPipe[i] <= '0;
    end
	end
	else begin
		for (i = 0; i <= WIDTH+1; i=i+1)
		begin
			qOutPipe[i] <= qInPipe[i];
			qzOutPipe[i] <= qzInPipe[i];
			aOutPipe[i] <= aInPipe[i];
			mOutPipe[i] <= mInPipe[i];
		end
	end
end
//assign outputs
assign mul2acc = {aInPipe[WIDTH+1], qInPipe[WIDTH+1]};


/*always_ff @(posedge clk) begin
  if(rst) begin
    count <= '0;
    validOut <= 1'b0;
  end
  else if (count < (WIDTH + 1)) begin
    validOut <= 1'b0; 
    count <= count + 1'b1;
  end
  else begin
    validOut <= 1'b1;
    count <= count;
  end
end*/  
  

endmodule



module ppgBooth #(parameter WIDTH = 8) (input logic [WIDTH:0] qIn, input logic qzIn, input logic [WIDTH:0] aIn, input logic [WIDTH:0] mIn, input logic clk, input logic rst, output logic [WIDTH:0] aOut, output logic [WIDTH:0] mOut, output logic [WIDTH:0] qOut, output logic qzOut);

//control signals
logic [1:0] psm; //plus, stay, or minus

logic plus, minus; //adding or subtracting m from a

//internal signals
logic [WIDTH:0] a;

//multiplication slice logic
assign psm = {qIn[0], qzIn};

//Add if they do not match and the lower bit is a 1
assign plus = psm[1] ^ psm[0] ? psm[0] : 0;

//subtract if they do not match and the upper bit is a 1
assign minus = psm[1] ^ psm[0] ? psm[1] : 0;

//Modify a as needed
assign a = plus ? aIn+mIn : minus ? aIn-mIn : aIn;

//shift {a,q} output
assign aOut = {a[WIDTH], a[WIDTH:1]};
assign qOut = {a[0], qIn[WIDTH:1]};
assign qzOut = qIn[0];

//Pass m onto the next stage
assign mOut = mIn;

endmodule
