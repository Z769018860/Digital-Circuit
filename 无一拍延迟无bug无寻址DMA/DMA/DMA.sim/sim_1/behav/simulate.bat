@echo off
set xv_path=F:\\vivado2017-2\\Vivado\\2017.2\\bin
call %xv_path%/xsim DMA_test_behav -key {Behavioral:sim_1:Functional:DMA_test} -tclbatch DMA_test.tcl -view E:/school/Maths/���ֵ�·/��һ���ӳ���bug��ѰַDMA/DMA/DMA_test_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0
