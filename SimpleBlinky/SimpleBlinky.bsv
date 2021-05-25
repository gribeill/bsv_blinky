package SimpleBlinky;

interface SimpleBlinkIfc;
    (*always_ready, result= "rgb_led0_r"*)
    method bit r_led();
    (*always_ready, result= "rgb_led0_g"*)
    method bit g_led();
    (*always_ready, result= "rgb_led0_b"*)
    method bit b_led();
endinterface: SimpleBlinkIfc

(*synthesize*)
(*no_default_reset*)
(*default_clock_osc = "clk48"*)
module mkSimpleBlinky(SimpleBlinkIfc);

    //Use U register since we don't have a default reset 
    //and don't really care about the initial state. 
    Reg#(UInt#(27)) cnt <- mkRegU();

    rule count_up;
        cnt <= cnt + 1;
    endrule

    method bit r_led();
        return ~pack(cnt)[24];
    endmethod

    method bit g_led();
        return ~pack(cnt)[25];
    endmethod

    method bit b_led();
        return ~pack(cnt)[26];
    endmethod

endmodule: mkSimpleBlinky
endpackage: SimpleBlinky




