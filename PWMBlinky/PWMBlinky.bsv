package PWMBlinky;

import PWM::*;

interface PWMBlinkyIfc;
    (*always_ready, result="rgb_led0_r"*)
    method bit r_led();
    (*always_ready, result="rgb_led0_g"*)
    method bit g_led();
    (*always_ready, result="rgb_led0_b"*)
    method bit b_led();
    (*always_ready, always_enabled, prefix=""*)
    method Action usr_btn_press((*port="usr_btn"*) bit btn);
    (*always_ready*)
    method bit rst_n();
endinterface

(*synthesize, no_default_reset, default_clock_osc="clk48"*)
module mkPWMBlinky(PWMBlinkyIfc);

    Reg#(UInt#(20)) wheel_counter <- mkRegU();
    Reg#(Count)  wheel_position <- mkRegU();

    Reg#(Count) pwm_dc_r <- mkRegU();
    Reg#(Count) pwm_dc_g <- mkRegU();
    Reg#(Count) pwm_dc_b <- mkRegU();

    PWM pwm_r <- mkPWM(reset_by noReset);
    PWM pwm_g <- mkPWM(reset_by noReset);
    PWM pwm_b <- mkPWM(reset_by noReset);

    Reg#(bit) reset_sr <- mkRegU;

    rule update;

        wheel_counter <= wheel_counter + 1;

        if (wheel_counter == 0)
            wheel_position <= wheel_position+1;

        if (wheel_position < 85) begin 
            pwm_dc_r <= (wheel_position*3);
            pwm_dc_g <= 0;
            pwm_dc_b <= 255 - (wheel_position*3);
        end else if (wheel_position < 170) begin
            pwm_dc_r <= 255 - ((wheel_position-85)*3);
            pwm_dc_g <= ((wheel_position-85)*3);
            pwm_dc_b <= 0;
        end else begin 
            pwm_dc_r <= 0;
            pwm_dc_g <= 255 - ((wheel_position-170)*3);
            pwm_dc_b <= (wheel_position-170)*3;
        end

        pwm_r.set_duty_cycle(pwm_dc_r);
        pwm_g.set_duty_cycle(pwm_dc_g);
        pwm_b.set_duty_cycle(pwm_dc_b);

    endrule 

    method r_led();
        return ~pwm_r.pwm_value();
    endmethod

    method g_led();
        return ~pwm_g.pwm_value();
    endmethod 

    method b_led();
        return ~pwm_b.pwm_value();
    endmethod

    method bit rst_n();
        return reset_sr;
    endmethod 

    method Action usr_btn_press(bit usr_btn);
        reset_sr <= usr_btn;
    endmethod


endmodule
endpackage

