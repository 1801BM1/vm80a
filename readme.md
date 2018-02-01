## Die photo

![Die photo](/img/vm80a.jpg)

Links to raw photos (please, note, files are LARGE):
- [Top metal, 11Kx10K, 95M](http://www.1801bm1.com/files/retro/580/images/580vm80a-2.jpg)
- [Top metal, 11Kx10K, 140M](http://www.1801bm1.com/files/retro/580/images/580vm80a-3.jpg)
- [Diffusion, 5.5Kx5K, 28M](http://www.1801bm1.com/files/retro/580/images/580vm80a-sil.jpg)

## Abstract
The vm80a is the core built on the base of the revengineered real 580BM80A die.
The 580BM80A chip is the Soviet replica of early Intel i8080A microprocessor,
and these ones are very close topologically.

The silicon techology parameters are:
- 5 micron scale
- one metal and one polycrystalline silicon layer
- NMOS schematics with depletion mode loads
- the extra high voltage source (+12V) is required
- high voltage direct clock phases (+12V)
- no built-in negative bias generator, extra negative voltage source is required

The reversing was performed in the following stages:
- crystall decapsulation (with hot acid etching)
- taking the panorama shapshot of combined upper metal and polysilicon layers
- etching upper metal and polysilicon layers
- taking the panorama shapshot of diffusion layer with the prints of polysilicon layer
- vectorizing the photos in the SprintLayout editor
- transferring the topology to the PCAD-2004 pcb editor
- converting topology to PCAD-2004 schematics using the back annotation
- writing the Verilog code on the precise schematics base
- patching the code to eliminate the asynchronous nature of original circuits
- simulating and testing the resulting vm80a core on the real FPGAs
- thorough i8080 exerciser tests were passed successfully

## Results
The project provides two i8080 models in Verilog - the one is pin-compatible with original
processor and other is refactored to be implemented within SoC and has the Wishbone interface.
Both approaches are proven on the real boards and FPGAs.
The models are compact and fast enough, the typical speed and area for Wishbone-featured model
on the DE0 board (Cyclone EP3C16F484C6):
- 104MHz clock, 607 LUTs and 187 flip-flops, no RAM blocks
 
## Directory structure
#### \sch    
- topology in Sprint Layout format
- topology in PCD-2004 pcb format
- schematics in PCD-2004 sch format
- schematics in [pdf](/sch/vm80a.pdf) (gate level)

#### \org
- synchronous vm80a core, all original timings are kept intact, 
includes the wrapper for usage as in-place-substitution of real i8080/580BM80A 
          
#### \wbc
- Wishbone compatible version of vm80a core, uses single clock, FPGA-optimized,
follows the original command execution timings

#### \tst
- i8080 Exerciser test software and some other tests

## Supported FPGA development boards:
- [Altera DE0](http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&No=364)
- [Altera DE1](http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=53&No=83)
- [Altera DE2-115](http://www.terasic.com.tw/cgi-bin/page/archive.pl?Language=English&CategoryNo=139&No=502)
- [Alinx AX309](http://artofcircuits.com/product/alinx-ax309-spartan-6-fpga-development-board-xc6slx9-2ftg256c)

