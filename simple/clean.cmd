@echo off

rmdir /S /Q _vivado
rmdir /S /Q .Xil
rmdir /S /Q platform

del *.jou
del *.log
del petalinux\\*.dsa
