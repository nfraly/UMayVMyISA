// rr_arbiter.sv
// round robin with 2 simple priority arbiters and mask
module rr_arbiter (rr_if bus);

  localparam int N = $bits(bus.req);

  logic [$clog2(N)-1:0] Pointer; // RR pointer
  logic [N-1:0] Mask; // Built from Pointer
  logic [N-1:0] MaskedReq; // Req & Mask
  logic [N-1:0] MaskGrant; // masked arbiter grant
  logic [N-1:0] UnmaskGrant; // unmasked arbiter grant
  logic NoMask; // Flag used to determine if mask present


  // Mask built from previous pointer
  function automatic logic [N-1:0] build_mask(
	input logic [$clog2(N)-1:0] pointer
  );
	logic [N-1:0] mask;
	// Initialize mask as all 1's
	mask = '1;
	for (int i = 0; i <= pointer; i++) begin
		mask[i] = 1'b0;
	end
	
	return mask;
  endfunction


  // Convert one hot grant to index of requester that was just selected
  function automatic logic [$clog2(N)-1:0] PointerFromGrant(input logic[N-1:0] grant);
    // Default value if grant is all 0's
	PointerFromGrant = '0;

	for (int i = 0; i < N; i++) begin
	  if (grant[i]) begin
          PointerFromGrant = i[($clog2(N)-1):0];		// i width needs to match pointer width
		break;						                // Since grant is one hot, no need to finish loop
	  end
	end
  endfunction


  // Combinational logic for masking and nomask flag
  // Create mask based on pointer
  assign Mask = build_mask(Pointer);
  // Mask with module input request
  assign MaskedReq = bus.req & Mask;
  // If no input requested, set no mask flag, else, clear flag
  assign NoMask = (!MaskedReq) ? 1'b1 : 1'b0;

  // Define upper arbiter, masked arbiter
  simple_priority_arbiter #(N) masked_arbiter (.Req(MaskedReq), .Grant(MaskGrant));

  // Define lower arbiter
  simple_priority_arbiter #(N) unmasked_arbiter(.Req(bus.req), .Grant(UnmaskGrant));
	
  logic [N-1:0] next_grant;
  assign next_grant = NoMask ? UnmaskGrant : MaskGrant;  

  // sequential logic for grant and pointer
  always_ff @(posedge bus.clk or negedge bus.resetN) begin
	// active low reset clears pointers & grant
    if (!bus.resetN) begin
    	bus.grant <= '0;
    	Pointer <= '0;
    end
    else begin
    // TODO: update pointer only when granted request is accepted
      bus.grant <= next_grant;
      if (next_grant != '0)
        Pointer <= PointerFromGrant(next_grant);
    end
  end

endmodule: rr_arbiter
