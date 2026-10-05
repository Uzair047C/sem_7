library verilog;
use verilog.vl_types.all;
entity bitadder is
    port(
        A               : in     vl_logic;
        B               : in     vl_logic;
        C               : in     vl_logic;
        sum             : out    vl_logic;
        cout            : out    vl_logic
    );
end bitadder;
