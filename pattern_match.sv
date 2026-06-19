/*Pattern Detection Function
Write a SystemVerilog function that:

Takes a 256-bit data input and a 16-bit pattern to search for
Data arrives in 8-bit chunks — meaning you process the 256-bit data 8 bits at a time, sliding a 16-bit window across it
Returns the count of how many times the 16-bit pattern appears in the 256-bit data
Pattern can overlap — 16'hAAAA appearing as AAAA counts twice

Example:
data    = 256'h0000_ABAB_ABAB_0000...
pattern = 16'hABAB
count   = 3  (overlapping matches at byte positions 2,3 and 3,4 and 4,5)
Constraints:

Process data strictly 8 bits at a time — no direct 16-bit slicing of the full 256 bits
Function must return an integer count
Must handle the boundary correctly — last window at bit position 248 looks at bits [255:240]*/
//How many windows total?
//Starting positions: 0, 8, 16, 24 ... 240. That's 240/8 + 1 = 31 windows.

function int pattern_match(logic [255:0] data_in, logic [15:0] pattern);

    int incr;
    incr=8;
    logic [15:0] s_window;
    int count = 0;

    for(int i = 0 ; i<= 240; i= i+incr) begin
            s_window[15:0]=data_in[i+:16];
            if(pattern == s_window)
                count = count+1;
    end
    return(count);
endfunction
