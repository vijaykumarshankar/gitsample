/*Exercise 3 — Per-Client Running Sum (The Real Problem)
DUT behavior:

Input: client_id (4-bit), data_in (32-bit), valid_in
Output: client_id (4-bit), data_out (32-bit), valid_out
DUT maintains a separate running sum per client_id
Output is the running sum for that client at the time of that transaction
Example for client 0: inputs 3, 5, 2 → outputs 3, 8, 10
Example for client 1: inputs 7, 1 → outputs 7, 8
Outputs for different client_ids can arrive out of order
Outputs for the same client_id always arrive in order

Same structure — write_input(client_id, data_in), write_output(client_id, data_out), pass/fail counters, empty queue guard.*/
class scorebaord;

logic [31:0] data_q[bit[3:0]][$];
logic [31:0] sum[bit[3:0]];
logic [31:0] exp;
int pass_cnt;
int fail_cnt;

function new();
    exp = 0;
    pass_cnt=0;
    fail_cnt=0;
endfunction

function void write_in(logic [31:0] data_in, logic [3:0] client_id);
    sum[client_id] = sum[client_id]+data_in;
    data_q[client_id].push_back(sum[client_id]);
endfunction

function void write_out(logic [31:0] data_out, logic[3:0] client_id);
    if(data_q[client_id].size() == 0) begin
    $display("ERROR: QUEUE is EMPTY ");
    return;
    end
    else begin
        exp = data_q[client_id].pop_front();
        if(exp == data_out) begin
            pass_cnt = pass_cnt+1;
            $display("PASS : client_id %0d : pass count:%0d", client_id, pass_cnt);
        end else begin
            fail_cnt = fail_cnt+1;
            $display("FAIL: client_id %0d : exp = %0h, got = %0h, fail count =%0d", client_id,exp, data_out,fail_cnt );
        end
    end
endfunction

endclass

/*DUT behavior:

Input: client_id (4-bit), data_in (32-bit), valid_in
Output: client_id (4-bit), data_out (32-bit), valid_out
DUT computes the running sum of each group of 4 transactions per client_id
After every 4 inputs for a client, the sum resets to 0 and starts again
Example for client 0: inputs 3, 5, 2, 8, 1, 4 → outputs 3, 8, 10, 18, 1, 5
Outputs for different client_ids can arrive out of order
Outputs for the same client_id always arrive in order
Maximum 20 outstanding transactions at any time

Write the complete scoreboard class. Same methods: write_in, write_out, pass/fail counters, empty queue guard.*/

class scoreboard;

logic [31:0] data_q[bit[3:0]] [$];
logic [31:0] sum[bit[3:0]];
int s_ctr[bit[3:0]];
logic [31:0] exp;
int pass_cnt;
int fail_cnt;

function new();
    exp = 0;
    pass_cnt = 0;
    fail_cnt = 0;
endfunction

function void data_input(logic [31:0] data_in, logic [3:0] client_id);

    int total;
    total = 0;
    foreach (data_q[i])
        total = total+data_q[i].size();
    if(total >= 20) begin 
        $display("ERROR buffer full ");
        return;
    end

    if(s_ctr[client_id] == 4) begin
        s_ctr[client_id] = 0;
        sum[client_id] = 0;
    end 
        sum[client_id] = data_in + sum[client_id];
        data_q[client_id].push_back(sum[client_id]);
        s_ctr[client_id] = s_ctr[client_id] + 1;
endfunction

function void write_out(logic [31:0] data_out, logic [3:0] client_id);

    if(data_q[client_id].size() == 0)begin
        $display("ERROR: QUEUE is EMPTY ");
        return;
    end else begin

        exp = data_q[client_id].pop_front();
        if(exp == data_out)begin
            pass_cnt = pass_cnt + 1;
            $display("PASS : client_id %0d : data_out %0h , pass_count %0d", client_id, data_out, pass_cnt);
        end else begin
            fail_cnt = fail_cnt + 1;
            $display("FAIL : client_id %0d : exp %0h , got: %0h , fail_count %0d", client_id, exp, data_out, fail_cnt);
        end
    end
endfunction
endclass