#!/bin/sh -f
xv_path="/opt/Xilinx/Vivado/2015.2"
ExecStep()
{
"$@"
RETVAL=$?
if [ $RETVAL -ne 0 ]
then
exit $RETVAL
fi
}
ExecStep $xv_path/bin/xelab -wto 3060b1d71edf4216b72a75c13a139b7b -m64 --debug typical --relax --mt 8 --include "../../../MicroProcessor.srcs/sources_1/ip/processor/ila_v5_1/hdl/verilog" --include "../../../MicroProcessor.srcs/sources_1/ip/processor/ltlib_v1_0/hdl/verilog" --include "../../../MicroProcessor.srcs/sources_1/ip/processor/xsdbs_v1_0/hdl/verilog" -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot TOP_TB_behav xil_defaultlib.TOP_TB xil_defaultlib.glbl -log elaborate.log
