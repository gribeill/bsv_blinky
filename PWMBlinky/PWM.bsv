package PWM;

typedef UInt#(8) Count;

interface Counter;
    (*always_ready*)
    method Count value(); 
    (*always_ready*)
    method Action zero();
endinterface

module mkCounter(Counter ifc);

    Reg#(Count) cnt <- mkReg(0);
    Wire#(Bool) zero_req <- mkDWire(False);

    rule count_up;
        if (zero_req) cnt <= 0;
        else cnt <= cnt + 1;
    endrule

    method Count value();
        return cnt;
    endmethod

    method Action zero();
        zero_req <= True;
    endmethod


endmodule

interface PWM;
    (*always_ready*)
    method Action set_duty_cycle(Count duty_cycle);
    (*always_ready*)
    method bit pwm_value();
endinterface

module mkPWM(PWM);

    Counter count <- mkCounter();
    Reg#(Count)   dc <- mkReg(0);
    Reg#(bit) pwm_val <- mkReg(0);

    rule pwm_value_update;
        if (dc > count.value()) pwm_val <= 1;
        else pwm_val <= 0;
    endrule 

    rule reset_counter (dc == 0);
        count.zero();
    endrule

    method bit pwm_value();
        return pwm_val;
    endmethod

    method Action set_duty_cycle(Count duty_cycle);
        dc <= duty_cycle;
    endmethod
endmodule

endpackage