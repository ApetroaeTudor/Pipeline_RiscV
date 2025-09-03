verilator --lint-only \
          -Wall \
         ./riscv_defines.vh \
         ./Exception_Control/*.*v \
         ./Control_Path/*.*v \
         ./Data_Path/*.*v \
         ./Hazard_Control/*.*v \
         ./Core/*.*v \
         ./SoC/*.*v; 