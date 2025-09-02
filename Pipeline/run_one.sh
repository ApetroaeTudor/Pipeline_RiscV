iverilog -g2012 \
        ./riscv_defines.vh \
        ./Exception_Control/*.*v \
        ./Control_Path/*.*v \
        ./Data_Path/*.*v \
        ./Hazard_Control/*.*v \
        ./Core/*.*v \
        ./SoC/*.*v \
        ./Memory/*.*v \
        ./Testbenches/SoC_TOP_Tb.*v;

vvp a.out
