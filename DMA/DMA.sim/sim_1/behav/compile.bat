@echo off
set xv_path=F:\\vivado2017-2\\Vivado\\2017.2\\bin
echo "xvlog -m64 --relax -prj DMA_test_vlog.prj"
call %xv_path%/xvlog  -m64 --relax -prj DMA_test_vlog.prj -log xvlog.log
call type xvlog.log > compile.log
if "%errorlevel%"=="1" goto END
if "%errorlevel%"=="0" goto SUCCESS
:END
exit 1
:SUCCESS
exit 0
