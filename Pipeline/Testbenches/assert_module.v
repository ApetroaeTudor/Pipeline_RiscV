module assert_module(
    input clk,
    input test
);
    always@(posedge clk)
    begin
        if(test!=1)
        begin
            $display("assert_moduleION FAILED IN %m");
            $finish;
        end
    end
endmodule