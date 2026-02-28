// rr_arbiter.sv
// round robin with 2 simple priority arbiters and mask
module rr_arbiter #(parameter int N = 3) (rr_if bus);

  logic [$clog2(N)-1:0] Pointer; // RR pointer
  logic [N-1:0] Mask;
  logic [N-1:0] MaskedReq;
  logic [N-1:0] MaskGrant;
  logic [N-1:0] UnmaskGrant;
  logic NoMask;

  // Mask built from previous pointer
  function automatic logic [N-1:0] build_mask(input logic [$clog2(N)-1:0] pointer);
    logic [N-1:0] mask;
    mask = '1;
    for (int i = 0; i <= pointer; i++) mask[i] = 1'b0;
    return mask;
  endfunction

  // Convert one hot grant to index of requestor that was just selected
  function automatic logic [$clog2(N)-1:0] PointerFromGrant(input logic [N-1:0] grant);
    PointerFromGrant = '0;
    for (int i = 0; i < N; i++) begin
      if (grant[i]) begin
        PointerFromGrant = i[$clog2(N)-1:0];
        break;
      end
    end
  endfunction

  assign Mask      = build_mask(Pointer);
  assign MaskedReq = bus.req & Mask;
  assign NoMask    = (!MaskedReq) ? 1'b1 : 1'b0;

  // Upper arbiter, masked arbiter
  simple_priority_arbiter #(N) masked_arbiter  (.Req(MaskedReq), .Grant(MaskGrant));
  // Lower arbiter
  simple_priority_arbiter #(N) unmasked_arbiter(.Req(bus.req),  .Grant(UnmaskGrant));

  logic [N-1:0] next_grant;
  assign next_grant = NoMask ? UnmaskGrant : MaskGrant;

  always_ff @(posedge bus.clk or negedge bus.resetN) begin
    if (!bus.resetN) begin
      bus.grant <= '0;
      Pointer   <= '0;
    end else begin
      bus.grant <= next_grant;
      if (next_grant != '0)
        Pointer <= PointerFromGrant(next_grant);
    end
  end

endmodule