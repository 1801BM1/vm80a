@echo off
rem
rem Convert local labels
rem
atxt32 -l@@ %1.asm %1.mac

rem
rem Compile the assembly source
rem
zmac -8 -m %1.mac

rem
rem Convert and copy the resukts
rem
if not exist ..\syn\de0\out (mkdir ..\syn\de0\out)
srec_cat zout\%1.hex -Intel -fill 0 0x0000 0x8000 -o ..\syn\de0\out\memini.mif -Memory_Initialization_File 8
srec_cat zout\%1.hex -Intel -o ..\sim\de0\memini.bin -VMem 8

rem
rem Some cleanup
rem
rd .\zout /s /q
del %1.mac

@echo on
