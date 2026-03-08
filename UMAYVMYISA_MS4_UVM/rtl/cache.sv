/* cache.sv
* Private Cache with MESI Coherence
*
* Organization:
*    128B capacity
*    4-way set associative
*    4B line size
*    random replacement (invalid first)
*    write-back + write-allocate
*    one outstanding MIU request at a time
*    snoop command handling for read and RFO
*/

import system_widths_pkg::*;

module cache (
  input logic clk,
  input logic resetN,
  miu_cache_if.slave miu_if, 
  cache_mem_if.master mem_if,
  snoop_if.listener snoop,
  output logic snoop_req_valid,
  output logic [ADDR_W-1:0] snoop_req_addr,
  output logic snoop_req_cmd,
  input logic snoop_req_grant,
  input logic snoop_req_done,
  output logic snoop_proc_busy
);

  parameter int CORE_ID = 0;
  parameter int CACHE_SIZE = 128;
  parameter int LINE_SIZE = 4;
  parameter int WAYS = 4;

  localparam int TOTAL_LINES = CACHE_SIZE / LINE_SIZE;
  localparam int SETS = TOTAL_LINES / WAYS;

  localparam int OFFSET_W = (LINE_SIZE <= 1) ? 1 : $clog2(LINE_SIZE);
  localparam int INDEX_W  = (SETS <= 1) ? 1 : $clog2(SETS);
  localparam int TAG_W    = ADDR_W - INDEX_W - OFFSET_W;
  localparam int WAY_W    = (WAYS <= 1) ? 1 : $clog2(WAYS);

  typedef enum logic [3:0] {
    IDLE, LOOKUP, WB_SEND, WB_WAIT, FETCH_LINE, FETCH_WAIT,
    SNOOP_WB_SEND, SNOOP_WB_WAIT, SNOOP_WAIT_GRANT, SNOOP_WAIT_DONE, SNOOP_WAIT_STORE_DONE
  } state_t;
  state_t state;

  // Cache arrays: [way][set][byte]
  logic [7:0] data_arr [0:WAYS-1][0:SETS-1][0:LINE_SIZE-1];
  logic [TAG_W-1:0] tag_arr [0:WAYS-1][0:SETS-1];
  logic valid_arr [0:WAYS-1][0:SETS-1];
  logic dirty_arr [0:WAYS-1][0:SETS-1];
  typedef enum logic [1:0] {MESI_I, MESI_S, MESI_E, MESI_M} mesi_t;
  mesi_t mesi_arr [0:WAYS-1][0:SETS-1];

  // One latched MIU request at a time
  logic req_we;
  logic [ADDR_W-1:0] req_addr;
  logic [7:0] req_wdata;
  logic [TAG_W-1:0] req_tag;
  logic [INDEX_W-1:0] req_idx;
  logic [OFFSET_W-1:0] req_offset;

  // Lookup results
  logic hit_any;
  logic [WAY_W-1:0] hit_way;
  logic [WAYS-1:0] valid_vec;
  logic [WAY_W-1:0] victim_way_next;

  // Miss handling state
  logic [WAY_W-1:0] victim_way;
  logic [TAG_W-1:0] evict_tag;
  logic victim_valid;
  logic victim_dirty;
  logic [OFFSET_W-1:0] wb_offset;
  logic [OFFSET_W-1:0] fetch_offset;
  logic [7:0] rand_replace;
  logic need_snoop_req;
  logic snoop_req_cmd_int;
  logic [ADDR_W-1:0] snoop_req_addr_int;

  // One deep pending snoop queue so snoops aren't lost while cache is busy
  logic snoop_pending;
  logic snoop_pending_cmd; // 0 = read, 1 = RFO
  logic [ADDR_W-1:0] snoop_pending_addr;
  logic [INDEX_W-1:0] snoop_pending_idx;
  logic [TAG_W-1:0] snoop_pending_tag;
  logic snoop_pending_hit_any;
  logic [WAY_W-1:0] snoop_pending_hit_way;

  // Snoop induced writeback tracking (for dirty/shared owner lines)
  logic [WAY_W-1:0] snoop_way;
  logic [INDEX_W-1:0] snoop_idx;
  logic [TAG_W-1:0] snoop_tag;
  logic [OFFSET_W-1:0] snoop_wb_offset;
  logic snoop_post_inval;

  // Response pulse to MIU
  logic resp_valid;
  logic [7:0] resp_data;

  logic [1:0] core_id_snoopbus;

  // Request/response handshakes
  wire accept_miu_req = (state == IDLE) && !need_snoop_req && miu_if.cache_req_valid && miu_if.cache_req_ready;

  wire accept_mem_req = (state inside {WB_SEND, FETCH_LINE, SNOOP_WB_SEND}) && mem_if.mem_req_valid && mem_if.mem_req_ready;

  wire got_mem_resp = (state inside {WB_WAIT, FETCH_WAIT, SNOOP_WB_WAIT}) && mem_if.mem_resp_valid;

  // MIU side
  assign miu_if.cache_req_ready = (state == IDLE) && !need_snoop_req;
  assign miu_if.cache_resp_valid = resp_valid;
  assign miu_if.cache_resp_data = resp_data;
  assign snoop_req_valid = need_snoop_req;
  assign snoop_req_addr = snoop_req_addr_int;
  assign snoop_req_cmd = snoop_req_cmd_int;
  assign snoop_proc_busy = snoop_pending || (state inside {SNOOP_WB_SEND, SNOOP_WB_WAIT});
  assign core_id_snoopbus = CORE_ID[1:0];
  assign snoop_pending_idx = snoop_pending_addr[OFFSET_W+INDEX_W-1:OFFSET_W];
  assign snoop_pending_tag = snoop_pending_addr[ADDR_W-1:OFFSET_W+INDEX_W];

  function automatic logic [WAY_W-1:0] choose_victim(
    input logic [WAYS-1:0] set_valid,
    input logic [WAY_W-1:0] rnd
  );
    logic found_invalid;
    logic [WAY_W-1:0] pick;
    pick = rnd;
    found_invalid = 1'b0;
    for (int w = 0; w < WAYS; ++w) begin
      if (!set_valid[w] && !found_invalid) begin
        pick = w[WAY_W-1:0];
        found_invalid = 1'b1;
      end
    end
    return pick;
  endfunction

  function automatic logic [ADDR_W-1:0] make_addr(
    input logic [TAG_W-1:0] tag,
    input logic [INDEX_W-1:0] idx,
    input logic [OFFSET_W-1:0] off
  );
    logic [ADDR_W-1:0] a;
    a = {tag, idx, off};
    return a;
  endfunction

  // Per request combinational lookup on the indexed set
  always_comb begin
    hit_any = 1'b0;
    hit_way = '0;
    valid_vec = '0;

    for (int w = 0; w < WAYS; ++w) begin
      valid_vec[w] = valid_arr[w][req_idx];
      if (valid_arr[w][req_idx] && (tag_arr[w][req_idx] == req_tag) && !hit_any) begin
        hit_any = 1'b1;
        hit_way = w[WAY_W-1:0];
      end
    end

    victim_way_next = choose_victim(valid_vec, rand_replace[WAY_W-1:0]);
  end

  // Lookup helper for pending snoop request
  always_comb begin
    snoop_pending_hit_any = 1'b0;
    snoop_pending_hit_way = '0;
    for (int w = 0; w < WAYS; ++w) begin
      if (valid_arr[w][snoop_pending_idx] && (tag_arr[w][snoop_pending_idx] == snoop_pending_tag) && !snoop_pending_hit_any) begin
        snoop_pending_hit_any = 1'b1;
        snoop_pending_hit_way = w[WAY_W-1:0];
      end
    end
  end

  // Memory side request generation
  always_comb begin
    mem_if.mem_req_valid = 1'b0;
    mem_if.mem_req_we = 1'b0;
    mem_if.mem_req_addr = '0;
    mem_if.mem_req_write = '0;

    case (state)
      WB_SEND: begin
        mem_if.mem_req_valid = 1'b1;
        mem_if.mem_req_we = 1'b1;
        mem_if.mem_req_addr = make_addr(evict_tag, req_idx, wb_offset);
        mem_if.mem_req_write = data_arr[victim_way][req_idx][wb_offset];
      end

      SNOOP_WB_SEND: begin
        mem_if.mem_req_valid = 1'b1;
        mem_if.mem_req_we = 1'b1;
        mem_if.mem_req_addr = make_addr(snoop_tag, snoop_idx, snoop_wb_offset);
        mem_if.mem_req_write = data_arr[snoop_way][snoop_idx][snoop_wb_offset];
      end

      FETCH_LINE: begin
        mem_if.mem_req_valid = 1'b1;
        mem_if.mem_req_we = 1'b0;
        mem_if.mem_req_addr = make_addr(req_tag, req_idx, fetch_offset);
      end

      default: begin
      end
    endcase
  end

  // Cache control/datapath
  always_ff @(posedge clk or negedge resetN) begin
    if (!resetN) begin
      state <= IDLE;

      req_we <= 1'b0;
      req_addr <= '0;
      req_wdata <= '0;
      req_tag <= '0;
      req_idx <= '0;
      req_offset <= '0;

      victim_way <= '0;
      evict_tag <= '0;
      victim_valid <= 1'b0;
      victim_dirty <= 1'b0;
      wb_offset <= '0;
      fetch_offset <= '0;
      rand_replace <= 8'h1;
      need_snoop_req <= 1'b0;
      snoop_req_cmd_int <= 1'b1;
      snoop_req_addr_int <= '0;
      snoop_pending <= 1'b0;
      snoop_pending_cmd <= 1'b0;
      snoop_pending_addr <= '0;
      snoop_way <= '0;
      snoop_idx <= '0;
      snoop_tag <= '0;
      snoop_wb_offset <= '0;
      snoop_post_inval <= 1'b0;

      resp_valid <= 1'b0;
      resp_data <= '0;

      for (int w = 0; w < WAYS; ++w) begin
        for (int s = 0; s < SETS; ++s) begin
          valid_arr[w][s] <= 1'b0;
          dirty_arr[w][s] <= 1'b0;
          mesi_arr[w][s] <= MESI_I;
          tag_arr[w][s] <= '0;
          for (int b = 0; b < LINE_SIZE; ++b) begin
            data_arr[w][s][b] <= '0;
          end
        end
      end
    end
    else begin
      // Default: response is a 1 cycle pulse
      resp_valid <= 1'b0;

      // Simple LFSR for random replacement selection
      rand_replace <= {rand_replace[6:0], rand_replace[7] ^ rand_replace[5] ^ rand_replace[4] ^ rand_replace[3]};

      // Snoop request to arbiter is level-based until granted
      if (need_snoop_req && snoop_req_grant) begin
        need_snoop_req <= 1'b0;
      end

      // Queue snoops even while busy so they are not dropped
      // Only one slot for now. Might need to increase queue depth
      if (snoop.snoop_valid && (snoop.snoop_core != core_id_snoopbus) && !snoop_pending) begin
        snoop_pending <= 1'b1;
        snoop_pending_cmd <= snoop.snoop_cmd;
        snoop_pending_addr <= snoop.snoop_addr;
      end

      case (state)
        IDLE: begin
          // Service pending snoops before taking new requests
          if (snoop_pending) begin
            if (snoop_pending_hit_any) begin
              // RFO path
              if (snoop_pending_cmd == 1'b1) begin
                if (dirty_arr[snoop_pending_hit_way][snoop_pending_idx] || (mesi_arr[snoop_pending_hit_way][snoop_pending_idx] == MESI_M)) begin
                  // Dirty owner must write back before invalidating
                  snoop_way <= snoop_pending_hit_way;
                  snoop_idx <= snoop_pending_idx;
                  snoop_tag <= tag_arr[snoop_pending_hit_way][snoop_pending_idx];
                  snoop_wb_offset <= '0;
                  snoop_post_inval <= 1'b1;
                  state <= SNOOP_WB_SEND;
                end
                else begin
                  valid_arr[snoop_pending_hit_way][snoop_pending_idx] <= 1'b0;
                  dirty_arr[snoop_pending_hit_way][snoop_pending_idx] <= 1'b0;
                  mesi_arr[snoop_pending_hit_way][snoop_pending_idx] <= MESI_I;
                  snoop_pending <= 1'b0;
                end
              end
              else begin
                // Read Path - Dirty owner writes back, then demoted to shared
                if (dirty_arr[snoop_pending_hit_way][snoop_pending_idx] || (mesi_arr[snoop_pending_hit_way][snoop_pending_idx] == MESI_M)) begin
                  snoop_way <= snoop_pending_hit_way;
                  snoop_idx <= snoop_pending_idx;
                  snoop_tag <= tag_arr[snoop_pending_hit_way][snoop_pending_idx];
                  snoop_wb_offset <= '0;
                  snoop_post_inval <= 1'b0;
                  state <= SNOOP_WB_SEND;
                end
                else begin
                  if (mesi_arr[snoop_pending_hit_way][snoop_pending_idx] == MESI_E)
                    mesi_arr[snoop_pending_hit_way][snoop_pending_idx] <= MESI_S;
                  snoop_pending <= 1'b0;
                end
              end
            end
            else begin
              snoop_pending <= 1'b0;
            end
          end
          else if (accept_miu_req) begin
            req_we <= miu_if.cache_req_we;
            req_addr <= miu_if.cache_req_addr;
            req_wdata <= miu_if.cache_req_write;
            req_offset <= miu_if.cache_req_addr[OFFSET_W-1:0];
            req_idx <= miu_if.cache_req_addr[OFFSET_W+INDEX_W-1:OFFSET_W];
            req_tag <= miu_if.cache_req_addr[ADDR_W-1:OFFSET_W+INDEX_W];

            if (miu_if.cache_req_we) begin
              // Store requests issue RFO on snoop bus
              need_snoop_req <= 1'b1;
              snoop_req_cmd_int <= 1'b1;
              snoop_req_addr_int <= miu_if.cache_req_addr;
            end

            state <= LOOKUP;
          end
        end

        LOOKUP: begin
          if (hit_any) begin
            if (req_we) begin
              // Store hit -> update cached byte and set dirty
              data_arr[hit_way][req_idx][req_offset] <= req_wdata;
              dirty_arr[hit_way][req_idx] <= 1'b1;
              mesi_arr[hit_way][req_idx] <= MESI_M;
              if (!need_snoop_req || snoop_req_done) begin
                resp_data <= 8'h00;
                resp_valid <= 1'b1;
                state <= IDLE;
              end
              else begin
                state <= SNOOP_WAIT_STORE_DONE;
              end
            end
            else begin
              // Load hit -> return cached byte
              resp_data <= data_arr[hit_way][req_idx][req_offset];
              resp_valid <= 1'b1;
              state <= IDLE;
            end
          end
          else begin
            // Miss -> pick replacement way (invalid first, else random)
            victim_way <= victim_way_next;
            evict_tag <= tag_arr[victim_way_next][req_idx];
            victim_valid <= valid_arr[victim_way_next][req_idx];
            victim_dirty <= dirty_arr[victim_way_next][req_idx];
            wb_offset <= '0;
            fetch_offset <= '0;

            // Load miss issues read and waits for snoop completion
            if (!req_we && !need_snoop_req) begin
              need_snoop_req <= 1'b1;
              snoop_req_cmd_int <= 1'b0;
              snoop_req_addr_int <= req_addr;
              state <= SNOOP_WAIT_GRANT;
            end
            else if (valid_arr[victim_way_next][req_idx] && dirty_arr[victim_way_next][req_idx]) begin
              // Write back dirty victim before fetch
              state <= WB_SEND;
            end
            else begin
              state <= FETCH_LINE;
            end
          end
        end

        SNOOP_WAIT_GRANT: begin
          // Wait until read is granted
          if (!need_snoop_req) begin
            if (snoop_req_done) begin
              if (victim_valid && victim_dirty) state <= WB_SEND;
              else                              state <= FETCH_LINE;
            end
            else state <= SNOOP_WAIT_DONE;
          end
        end

        SNOOP_WAIT_DONE: begin
          // Wait for mp_system to signal this read snoop transaction has completed across peer caches
          if (snoop_req_done) begin
            if (victim_valid && victim_dirty) state <= WB_SEND;
            else                              state <= FETCH_LINE;
          end
        end

        WB_SEND: if (accept_mem_req) state <= WB_WAIT;

        WB_WAIT: begin
          if (got_mem_resp) begin
            if (wb_offset == LINE_SIZE-1) begin
              fetch_offset <= '0;
              state <= FETCH_LINE;
            end
            else begin
              wb_offset <= wb_offset + 1;
              state <= WB_SEND;
            end
          end
        end

        FETCH_LINE: begin
          if (accept_mem_req) state <= FETCH_WAIT;
        end

        FETCH_WAIT: begin
          if (got_mem_resp) begin
            // Fill one byte of the incoming line
            data_arr[victim_way][req_idx][fetch_offset] <= mem_if.mem_resp_data;

            if (fetch_offset == LINE_SIZE-1) begin
              // Final refill byte received -> commit tag/valid and service request
              tag_arr[victim_way][req_idx] <= req_tag;
              valid_arr[victim_way][req_idx] <= 1'b1;

              if (req_we) begin
                // Write allocate store miss -> update target byte and mark dirty
                data_arr[victim_way][req_idx][req_offset] <= req_wdata;
                dirty_arr[victim_way][req_idx] <= 1'b1;
                mesi_arr[victim_way][req_idx] <= MESI_M;

                if (!need_snoop_req || snoop_req_done) begin
                  resp_data <= 8'h00;
                  resp_valid <= 1'b1;
                  state <= IDLE;
                end

                else state <= SNOOP_WAIT_STORE_DONE;
              end
              else begin
                dirty_arr[victim_way][req_idx] <= 1'b0;
                mesi_arr[victim_way][req_idx] <= MESI_E;

                // If requested byte is the final arriving byte, use response directly
                // Otherwise it was written in an earlier fetch cycle
                if (req_offset == fetch_offset) resp_data <= mem_if.mem_resp_data;
                else                            resp_data <= data_arr[victim_way][req_idx][req_offset];

                resp_valid <= 1'b1;
                state <= IDLE;
              end
            end
            else begin
              fetch_offset <= fetch_offset + 1;
              state <= FETCH_LINE;
            end
          end
        end

        SNOOP_WAIT_STORE_DONE: begin
          // Don't finish store until RFO has finished
          if (!need_snoop_req || snoop_req_done) begin
            resp_data <= 8'h00;
            resp_valid <= 1'b1;
            state <= IDLE;
          end
        end

        SNOOP_WB_SEND: begin
          if (accept_mem_req) state <= SNOOP_WB_WAIT;
        end

        SNOOP_WB_WAIT: begin
          if (got_mem_resp) begin
            if (snoop_wb_offset == LINE_SIZE-1) begin
              dirty_arr[snoop_way][snoop_idx] <= 1'b0;

              if (snoop_post_inval) begin
                valid_arr[snoop_way][snoop_idx] <= 1'b0;
                mesi_arr[snoop_way][snoop_idx] <= MESI_I;
              end
              else begin
                valid_arr[snoop_way][snoop_idx] <= 1'b1;
                mesi_arr[snoop_way][snoop_idx] <= MESI_S;
              end
              snoop_pending <= 1'b0;
              state <= IDLE;
            end
            else begin
              snoop_wb_offset <= snoop_wb_offset + 1'b1;
              state <= SNOOP_WB_SEND;
            end
          end
        end

        default: state <= IDLE;
      endcase
    end
  end

endmodule: cache
