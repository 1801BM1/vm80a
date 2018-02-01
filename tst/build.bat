@echo off
rem
rem 8080exe.asm - Exerciser software
rem 8080int.asm - preliminary interrupt test
rem 8080pre.asm - preliminary instruction test
rem 8080tst.asm - arbitrary working test
rem
rem Biulding the Exerciser test software command:
rem
rem biuld 8080exe
rem
rem Convert local labels
rem
tools\atxt32 -l@@ %1.asm %1.mac

rem
rem Compile the assembly source
rem
tools\zmac -8 -m %1.mac

rem
rem Convert and copy the resukts
rem Xilinx mem file requires manual header and tail removing
rem
rem srec_cat zout\%1.hex -Intel -fill 0xFF 0x0000 0x4000 -o rom\memini.mem -Ascii-Hex -obs=1
srec_cat zout\%1.hex -Intel -o rom\memini.bin -VMem 8
srec_cat zout\%1.hex -Intel -fill 0xFF 0x0000 0x4000 -o rom\memini.mif -Memory_Initialization_File 8 -obs=1
rem
rem Some cleanup
rem
rd .\zout /s /q
del %1.mac
@echo on

