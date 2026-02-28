// mul.sv
module boothmul #(
  parameter int WIDTH = 8
) (
  input  logic [WIDTH-1:0] w2mul,
  input  logic [WIDTH-1:0] x2mul,
  output logic [WIDTH*2-1:0] mul2acc
);


  logic [WIDTH-1:0] qIn [WIDTH:0];
  logic [WIDTH-1:0] aIn [WIDTH:0];
  logic [WIDTH-1:0] qOut [WIDTH:0];
  logic [WIDTH-1:0] aOut [WIDTH:0];
  logic [WIDTH-1:0] mIn [WIDTH:0];
  logic [WIDTH-1:0] mOut [WIDTH:0];
  logic qzIn [WIDTH:0];
  logic qzOut [WIDTH:0];

  //generate multiplier slices
  genvar slices;
  int i;

  // ALU is combinational so use direct input wiring.
  assign qzIn[0] = 1'b0;
  assign qIn[0] = w2mul;
  assign aIn[0] = '0;
  assign mIn[0] = x2mul;

  // Multiplier slices
  generate
    for (slices = 0; slices < WIDTH; slices++) begin : multiplier
      ppgBooth #(.WIDTH(WIDTH)) slice (
        .qIn(qOut[slices]),
        .qzIn(qzOut[slices]),
        .aIn(aOut[slices]),
        .mIn(mOut[slices]),
        .aOut(aIn[slices+1]),
        .mOut(mIn[slices+1]),
        .qOut(qIn[slices+1]),
        .qzOut(qzIn[slices+1])
      );
    end
  endgenerate

  // Remove reset since ALU is combinational for now
  always_comb begin
    for (i = 0; i <= WIDTH; i++) begin
      qOut[i] = qIn[i];
      qzOut[i] = qzIn[i];
      aOut[i] = aIn[i];
      mOut[i] = mIn[i];
    end
  end

  // Remove output register so ALU can observe result combinationally.
  assign mul2acc = {aIn[WIDTH], qIn[WIDTH]};

endmodule


module ppgBooth #(
  parameter int WIDTH = 8
) (
  input  logic [WIDTH-1:0] qIn,
  input  logic             qzIn,
  input  logic [WIDTH-1:0] aIn,
  input  logic [WIDTH-1:0] mIn,
  output logic [WIDTH-1:0] aOut,
  output logic [WIDTH-1:0] mOut,
  output logic [WIDTH-1:0] qOut,
  output logic             qzOut
);

  //control signals
  logic [1:0] psm;  //plus, stay, or minus

  logic plus, minus;  //adding or subtracting m from a

  //internal signals
  logic [WIDTH-1:0] a;

  //multiplication slice logic
  assign psm = {qIn[0], qzIn};

  //Add if they do not match and the lower bit is a 1
  assign plus = psm[1] ^ psm[0] ? psm[0] : 1'b0;

  //subtract if they do not match and the upper bit is a 1
  assign minus = psm[1] ^ psm[0] ? psm[1] : 1'b0;

  //Modify a as needed (problem with +- signs?)
  assign a = plus ? aIn + mIn : minus ? aIn - mIn : aIn;

  //shift {a,q} output
  assign aOut = {a[WIDTH-1], a[WIDTH-1:1]};
  assign qOut = {a[0], qIn[WIDTH-1:1]};
  assign qzOut = qIn[0];


  assign mOut = mIn;

endmodule
