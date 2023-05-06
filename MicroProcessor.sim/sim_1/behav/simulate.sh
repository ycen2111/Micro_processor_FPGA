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
ExecStep $xv_path/bin/xsim TOP_TB_behav -key {Behavioral:sim_1:Functional:TOP_TB} -tclbatch TOP_TB.tcl -log simulate.log
