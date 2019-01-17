@echo off

rmdir /S /Q vivado
rmdir /S /Q .Xil
rmdir /S /Q platform

del *.jou
del *.log
del petalinux\\*.dsa