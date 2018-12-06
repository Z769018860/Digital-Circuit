@echo off
set xv_path=F:\\vivado2017-2\\Vivado\\2017.2\\bin
call %xv_path%/xelab  -wto a8e6acc6862f4c68b13a18f7677d6fa3 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot testbench_behav xil_defaultlib.testbench xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
