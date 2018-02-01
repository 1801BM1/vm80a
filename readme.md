The vm80a is the core built on the base of the revengineered real 580BM80A die.
The 580BM80A chip is the Soviet replica of early Intel i8080A microprocessor,
and these ones are very close topologically.

The techology parameters are:
- 5 micron scale
- one metal and one polycrystallline silicon layer
- NMOS schematics with depletion mode loads
- the extra high voltage source (+12V) is needed
- high voltage direct clock phases (+12V)
- no built-in negative bias generator, extra negative voltage source is required

The reversing was performed in the following stages:
- crystall decapsulation (with hot acid etching)
- taking the panorama shapshot of combined upper metal and polysilicon layers
- etching upper metal and polysilicon layers
- taking the panorama shapshot of diffusion layer with the prints of polysilicon layer
- vectorizing the photoes in the SprintLayout editor
- transferring the topology to the PCAD-2004 pcb editor
- convertiong topology to PCAD-2004 schematics using the back annotation feature
- writing the Verilog code on the precise schematics base
- patching the code to eliminate the asynchronous nature of original circuits
- simulating and testing the resulting vm80a core on the real FPGAs
- thorough i8080 exerciser tests were passed successfully

Directory structure

\sch    - topology in Sprint Layout format
        - topology in PCD-2004 pcb format
        - schematics in PCD-2004 pcb format
        - schematics in pdf (print version)

\org	- synchronous vm80a core, all original timings are kept intact, 
          includes the wrapper for usage as in-place-substitution of real i8080/580BM80A 
          
\wbc	- Wishbone compatible version of vm80a core, uses single clock, FPGA-optimized,
          supports the original command execution timings only

FPGA development board list:
\de0	- Altera DE0      http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=364
\de1	- Altera DE1      http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=53&No=83
\de2	- Altera DE2-115  http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=139&No=502
\309    - Alinx AX309     http://artofcircuits.com/product/alinx-ax309-spartan-6-fpga-development-board-xc6slx9-2ftg256c
