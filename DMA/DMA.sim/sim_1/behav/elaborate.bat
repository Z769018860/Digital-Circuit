@echo off
set xv_path=F:\\vivado2017-2\\Vivado\\2017.2\\bin
call %xv_path%/xelab  -wto bfa191f2789d4461bf84a74eaad313a7 -m64 --debug typical --relax --mt 2 -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip --snapshot DMA_test_behav xil_defaultlib.DMA_test xil_defaultlib.glbl -log elaborate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
