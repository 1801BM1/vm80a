onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label tb/a -radix hexadecimal -childformat {{{/tb80a/a[15]} -radix hexadecimal} {{/tb80a/a[14]} -radix hexadecimal} {{/tb80a/a[13]} -radix hexadecimal} {{/tb80a/a[12]} -radix hexadecimal} {{/tb80a/a[11]} -radix hexadecimal} {{/tb80a/a[10]} -radix hexadecimal} {{/tb80a/a[9]} -radix hexadecimal} {{/tb80a/a[8]} -radix hexadecimal} {{/tb80a/a[7]} -radix hexadecimal} {{/tb80a/a[6]} -radix hexadecimal} {{/tb80a/a[5]} -radix hexadecimal} {{/tb80a/a[4]} -radix hexadecimal} {{/tb80a/a[3]} -radix hexadecimal} {{/tb80a/a[2]} -radix hexadecimal} {{/tb80a/a[1]} -radix hexadecimal} {{/tb80a/a[0]} -radix hexadecimal}} -subitemconfig {{/tb80a/a[15]} {-height 15 -radix hexadecimal} {/tb80a/a[14]} {-height 15 -radix hexadecimal} {/tb80a/a[13]} {-height 15 -radix hexadecimal} {/tb80a/a[12]} {-height 15 -radix hexadecimal} {/tb80a/a[11]} {-height 15 -radix hexadecimal} {/tb80a/a[10]} {-height 15 -radix hexadecimal} {/tb80a/a[9]} {-height 15 -radix hexadecimal} {/tb80a/a[8]} {-height 15 -radix hexadecimal} {/tb80a/a[7]} {-height 15 -radix hexadecimal} {/tb80a/a[6]} {-height 15 -radix hexadecimal} {/tb80a/a[5]} {-height 15 -radix hexadecimal} {/tb80a/a[4]} {-height 15 -radix hexadecimal} {/tb80a/a[3]} {-height 15 -radix hexadecimal} {/tb80a/a[2]} {-height 15 -radix hexadecimal} {/tb80a/a[1]} {-height 15 -radix hexadecimal} {/tb80a/a[0]} {-height 15 -radix hexadecimal}} /tb80a/a
add wave -noupdate -label tb/d -radix hexadecimal -childformat {{{/tb80a/d[7]} -radix hexadecimal} {{/tb80a/d[6]} -radix hexadecimal} {{/tb80a/d[5]} -radix hexadecimal} {{/tb80a/d[4]} -radix hexadecimal} {{/tb80a/d[3]} -radix hexadecimal} {{/tb80a/d[2]} -radix hexadecimal} {{/tb80a/d[1]} -radix hexadecimal} {{/tb80a/d[0]} -radix hexadecimal}} -subitemconfig {{/tb80a/d[7]} {-height 15 -radix hexadecimal} {/tb80a/d[6]} {-height 15 -radix hexadecimal} {/tb80a/d[5]} {-height 15 -radix hexadecimal} {/tb80a/d[4]} {-height 15 -radix hexadecimal} {/tb80a/d[3]} {-height 15 -radix hexadecimal} {/tb80a/d[2]} {-height 15 -radix hexadecimal} {/tb80a/d[1]} {-height 15 -radix hexadecimal} {/tb80a/d[0]} {-height 15 -radix hexadecimal}} /tb80a/d
add wave -noupdate -label tb/y -radix hexadecimal /tb80a/d_cyc
add wave -noupdate -label tb/sync /tb80a/sync
add wave -noupdate -label tb/dbin /tb80a/dbin
add wave -noupdate -label {tb/wr_n} /tb80a/wr_n
add wave -noupdate -label tb/clk /tb80a/clk
add wave -noupdate -label tb/f1 /tb80a/f1
add wave -noupdate -label tb/f2 /tb80a/f2
add wave -noupdate -label a -radix hexadecimal -childformat {{{/tb80a/vm80a/core/a[15]} -radix hexadecimal} {{/tb80a/vm80a/core/a[14]} -radix hexadecimal} {{/tb80a/vm80a/core/a[13]} -radix hexadecimal} {{/tb80a/vm80a/core/a[12]} -radix hexadecimal} {{/tb80a/vm80a/core/a[11]} -radix hexadecimal} {{/tb80a/vm80a/core/a[10]} -radix hexadecimal} {{/tb80a/vm80a/core/a[9]} -radix hexadecimal} {{/tb80a/vm80a/core/a[8]} -radix hexadecimal} {{/tb80a/vm80a/core/a[7]} -radix hexadecimal} {{/tb80a/vm80a/core/a[6]} -radix hexadecimal} {{/tb80a/vm80a/core/a[5]} -radix hexadecimal} {{/tb80a/vm80a/core/a[4]} -radix hexadecimal} {{/tb80a/vm80a/core/a[3]} -radix hexadecimal} {{/tb80a/vm80a/core/a[2]} -radix hexadecimal} {{/tb80a/vm80a/core/a[1]} -radix hexadecimal} {{/tb80a/vm80a/core/a[0]} -radix hexadecimal}} -subitemconfig {{/tb80a/vm80a/core/a[15]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/a[14]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/a[13]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/a[12]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/a[11]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/a[10]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/a[9]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/a[8]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/a[7]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/a[6]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/a[5]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/a[4]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/a[3]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/a[2]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/a[1]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/a[0]} {-height 15 -radix hexadecimal}} /tb80a/vm80a/core/a
add wave -noupdate -label d -radix hexadecimal -childformat {{{/tb80a/vm80a/core/d[7]} -radix hexadecimal} {{/tb80a/vm80a/core/d[6]} -radix hexadecimal} {{/tb80a/vm80a/core/d[5]} -radix hexadecimal} {{/tb80a/vm80a/core/d[4]} -radix hexadecimal} {{/tb80a/vm80a/core/d[3]} -radix hexadecimal} {{/tb80a/vm80a/core/d[2]} -radix hexadecimal} {{/tb80a/vm80a/core/d[1]} -radix hexadecimal} {{/tb80a/vm80a/core/d[0]} -radix hexadecimal}} -subitemconfig {{/tb80a/vm80a/core/d[7]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/d[6]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/d[5]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/d[4]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/d[3]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/d[2]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/d[1]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/d[0]} {-height 15 -radix hexadecimal}} /tb80a/vm80a/core/d
add wave -noupdate -group reg -label acc -radix hexadecimal -childformat {{{/tb80a/vm80a/core/acc[7]} -radix hexadecimal} {{/tb80a/vm80a/core/acc[6]} -radix hexadecimal} {{/tb80a/vm80a/core/acc[5]} -radix hexadecimal} {{/tb80a/vm80a/core/acc[4]} -radix hexadecimal} {{/tb80a/vm80a/core/acc[3]} -radix hexadecimal} {{/tb80a/vm80a/core/acc[2]} -radix hexadecimal} {{/tb80a/vm80a/core/acc[1]} -radix hexadecimal} {{/tb80a/vm80a/core/acc[0]} -radix hexadecimal}} -subitemconfig {{/tb80a/vm80a/core/acc[7]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/acc[6]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/acc[5]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/acc[4]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/acc[3]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/acc[2]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/acc[1]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/acc[0]} {-height 15 -radix hexadecimal}} /tb80a/vm80a/core/acc
add wave -noupdate -group reg -label bc -radix hexadecimal -childformat {{{/tb80a/vm80a/core/r16_bc[15]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_bc[14]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_bc[13]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_bc[12]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_bc[11]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_bc[10]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_bc[9]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_bc[8]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_bc[7]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_bc[6]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_bc[5]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_bc[4]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_bc[3]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_bc[2]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_bc[1]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_bc[0]} -radix hexadecimal}} -subitemconfig {{/tb80a/vm80a/core/r16_bc[15]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_bc[14]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_bc[13]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_bc[12]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_bc[11]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_bc[10]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_bc[9]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_bc[8]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_bc[7]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_bc[6]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_bc[5]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_bc[4]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_bc[3]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_bc[2]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_bc[1]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_bc[0]} {-height 15 -radix hexadecimal}} /tb80a/vm80a/core/r16_bc
add wave -noupdate -group reg -label de -radix hexadecimal /tb80a/vm80a/core/r16_de
add wave -noupdate -group reg -label hl -radix hexadecimal /tb80a/vm80a/core/r16_hl
add wave -noupdate -group reg -label pc -radix hexadecimal /tb80a/vm80a/core/r16_pc
add wave -noupdate -group reg -label sp -radix hexadecimal /tb80a/vm80a/core/r16_sp
add wave -noupdate -group reg -label wz -radix hexadecimal -childformat {{{/tb80a/vm80a/core/r16_wz[15]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_wz[14]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_wz[13]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_wz[12]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_wz[11]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_wz[10]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_wz[9]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_wz[8]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_wz[7]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_wz[6]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_wz[5]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_wz[4]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_wz[3]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_wz[2]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_wz[1]} -radix hexadecimal} {{/tb80a/vm80a/core/r16_wz[0]} -radix hexadecimal}} -subitemconfig {{/tb80a/vm80a/core/r16_wz[15]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_wz[14]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_wz[13]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_wz[12]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_wz[11]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_wz[10]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_wz[9]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_wz[8]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_wz[7]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_wz[6]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_wz[5]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_wz[4]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_wz[3]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_wz[2]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_wz[1]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/r16_wz[0]} {-height 15 -radix hexadecimal}} /tb80a/vm80a/core/r16_wz
add wave -noupdate -group psw -label tmp_c /tb80a/vm80a/core/tmp_c
add wave -noupdate -group psw -label psw_c /tb80a/vm80a/core/psw_c
add wave -noupdate -group psw -label psw_ac /tb80a/vm80a/core/psw_ac
add wave -noupdate -group psw -label psw_z /tb80a/vm80a/core/psw_z
add wave -noupdate -group psw -label psw_p /tb80a/vm80a/core/psw_p
add wave -noupdate -group psw -label psw_s /tb80a/vm80a/core/psw_s
add wave -noupdate -group psw -label psw_ld /tb80a/vm80a/core/psw_ld
add wave -noupdate -group psw -label psw_wr /tb80a/vm80a/core/psw_wr
add wave -noupdate -expand -group ext -label tb/reset /tb80a/reset
add wave -noupdate -expand -group ext -label tb/ready /tb80a/ready
add wave -noupdate -expand -group ext -label {tb/intr} /tb80a/intr
add wave -noupdate -expand -group ext -label tb/hold /tb80a/hold
add wave -noupdate -expand -group ext -label tb/inte /tb80a/inte
add wave -noupdate -expand -group ext -label tb/hlda /tb80a/hlda
add wave -noupdate -expand -group ext -label abufena /tb80a/vm80a/core/abufena
add wave -noupdate -expand -group ext -label db_stb /tb80a/vm80a/core/db_stb
add wave -noupdate -expand -group ext -label db_ena /tb80a/vm80a/core/db_ena
add wave -noupdate -expand -group ext -label di -radix hexadecimal /tb80a/vm80a/core/di
add wave -noupdate -group mux -label {mxr0 (pc)} /tb80a/vm80a/core/mxr0
add wave -noupdate -group mux -label {mxr1 (hl/de)} /tb80a/vm80a/core/mxr1
add wave -noupdate -group mux -label {mxr2 (hl/de)} /tb80a/vm80a/core/mxr2
add wave -noupdate -group mux -label {mxr3 (bc)} /tb80a/vm80a/core/mxr3
add wave -noupdate -group mux -label {mxr4 (sp)} /tb80a/vm80a/core/mxr4
add wave -noupdate -group mux -label {mxr5 (wz)} /tb80a/vm80a/core/mxr5
add wave -noupdate -group mux -label mxwadr /tb80a/vm80a/core/mxwadr
add wave -noupdate -group mux -label mxrh /tb80a/vm80a/core/mxrh
add wave -noupdate -group mux -label mxrl /tb80a/vm80a/core/mxrl
add wave -noupdate -group mux -label mxw16 /tb80a/vm80a/core/mxw16
add wave -noupdate -group mux -label mxwh /tb80a/vm80a/core/mxwh
add wave -noupdate -group mux -label mxwl /tb80a/vm80a/core/mxwl
add wave -noupdate -group mux -label mxo -radix hexadecimal -childformat {{{/tb80a/vm80a/core/mxo[15]} -radix hexadecimal} {{/tb80a/vm80a/core/mxo[14]} -radix hexadecimal} {{/tb80a/vm80a/core/mxo[13]} -radix hexadecimal} {{/tb80a/vm80a/core/mxo[12]} -radix hexadecimal} {{/tb80a/vm80a/core/mxo[11]} -radix hexadecimal} {{/tb80a/vm80a/core/mxo[10]} -radix hexadecimal} {{/tb80a/vm80a/core/mxo[9]} -radix hexadecimal} {{/tb80a/vm80a/core/mxo[8]} -radix hexadecimal} {{/tb80a/vm80a/core/mxo[7]} -radix hexadecimal} {{/tb80a/vm80a/core/mxo[6]} -radix hexadecimal} {{/tb80a/vm80a/core/mxo[5]} -radix hexadecimal} {{/tb80a/vm80a/core/mxo[4]} -radix hexadecimal} {{/tb80a/vm80a/core/mxo[3]} -radix hexadecimal} {{/tb80a/vm80a/core/mxo[2]} -radix hexadecimal} {{/tb80a/vm80a/core/mxo[1]} -radix hexadecimal} {{/tb80a/vm80a/core/mxo[0]} -radix hexadecimal}} -subitemconfig {{/tb80a/vm80a/core/mxo[15]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxo[14]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxo[13]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxo[12]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxo[11]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxo[10]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxo[9]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxo[8]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxo[7]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxo[6]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxo[5]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxo[4]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxo[3]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxo[2]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxo[1]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxo[0]} {-height 15 -radix hexadecimal}} /tb80a/vm80a/core/mxo
add wave -noupdate -group mux -label mxi -radix hexadecimal -childformat {{{/tb80a/vm80a/core/mxi[15]} -radix hexadecimal} {{/tb80a/vm80a/core/mxi[14]} -radix hexadecimal} {{/tb80a/vm80a/core/mxi[13]} -radix hexadecimal} {{/tb80a/vm80a/core/mxi[12]} -radix hexadecimal} {{/tb80a/vm80a/core/mxi[11]} -radix hexadecimal} {{/tb80a/vm80a/core/mxi[10]} -radix hexadecimal} {{/tb80a/vm80a/core/mxi[9]} -radix hexadecimal} {{/tb80a/vm80a/core/mxi[8]} -radix hexadecimal} {{/tb80a/vm80a/core/mxi[7]} -radix hexadecimal} {{/tb80a/vm80a/core/mxi[6]} -radix hexadecimal} {{/tb80a/vm80a/core/mxi[5]} -radix hexadecimal} {{/tb80a/vm80a/core/mxi[4]} -radix hexadecimal} {{/tb80a/vm80a/core/mxi[3]} -radix hexadecimal} {{/tb80a/vm80a/core/mxi[2]} -radix hexadecimal} {{/tb80a/vm80a/core/mxi[1]} -radix hexadecimal} {{/tb80a/vm80a/core/mxi[0]} -radix hexadecimal}} -subitemconfig {{/tb80a/vm80a/core/mxi[15]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxi[14]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxi[13]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxi[12]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxi[11]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxi[10]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxi[9]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxi[8]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxi[7]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxi[6]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxi[5]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxi[4]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxi[3]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxi[2]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxi[1]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/mxi[0]} {-height 15 -radix hexadecimal}} /tb80a/vm80a/core/mxi
add wave -noupdate -group xxx -label tb/d_in -radix hexadecimal /tb80a/d_in
add wave -noupdate -group xxx -label tb/d_out -radix hexadecimal -childformat {{{/tb80a/d_out[7]} -radix hexadecimal} {{/tb80a/d_out[6]} -radix hexadecimal} {{/tb80a/d_out[5]} -radix hexadecimal} {{/tb80a/d_out[4]} -radix hexadecimal} {{/tb80a/d_out[3]} -radix hexadecimal} {{/tb80a/d_out[2]} -radix hexadecimal} {{/tb80a/d_out[1]} -radix hexadecimal} {{/tb80a/d_out[0]} -radix hexadecimal}} -subitemconfig {{/tb80a/d_out[7]} {-height 15 -radix hexadecimal} {/tb80a/d_out[6]} {-height 15 -radix hexadecimal} {/tb80a/d_out[5]} {-height 15 -radix hexadecimal} {/tb80a/d_out[4]} {-height 15 -radix hexadecimal} {/tb80a/d_out[3]} {-height 15 -radix hexadecimal} {/tb80a/d_out[2]} {-height 15 -radix hexadecimal} {/tb80a/d_out[1]} {-height 15 -radix hexadecimal} {/tb80a/d_out[0]} {-height 15 -radix hexadecimal}} /tb80a/d_out
add wave -noupdate -group xxx -label tb/d_cyc -radix hexadecimal /tb80a/d_cyc
add wave -noupdate -group ms -label i -radix hexadecimal -childformat {{{/tb80a/vm80a/core/i[7]} -radix hexadecimal} {{/tb80a/vm80a/core/i[6]} -radix hexadecimal} {{/tb80a/vm80a/core/i[5]} -radix hexadecimal} {{/tb80a/vm80a/core/i[4]} -radix hexadecimal} {{/tb80a/vm80a/core/i[3]} -radix hexadecimal} {{/tb80a/vm80a/core/i[2]} -radix hexadecimal} {{/tb80a/vm80a/core/i[1]} -radix hexadecimal} {{/tb80a/vm80a/core/i[0]} -radix hexadecimal}} -subitemconfig {{/tb80a/vm80a/core/i[7]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/i[6]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/i[5]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/i[4]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/i[3]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/i[2]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/i[1]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/i[0]} {-height 15 -radix hexadecimal}} /tb80a/vm80a/core/i
add wave -noupdate -group ms -group t -label t1 /tb80a/vm80a/core/t1
add wave -noupdate -group ms -group t -label t2 /tb80a/vm80a/core/t2
add wave -noupdate -group ms -group t -label t3 /tb80a/vm80a/core/t3
add wave -noupdate -group ms -group t -label t4 /tb80a/vm80a/core/t4
add wave -noupdate -group ms -group t -label t5 /tb80a/vm80a/core/t5
add wave -noupdate -group ms -group t -label {tw} /tb80a/vm80a/core/tw
add wave -noupdate -group ms -expand -group m -label m1 /tb80a/vm80a/core/m1
add wave -noupdate -group ms -expand -group m -label m2 /tb80a/vm80a/core/m2
add wave -noupdate -group ms -expand -group m -label m3 /tb80a/vm80a/core/m3
add wave -noupdate -group ms -expand -group m -label m4 /tb80a/vm80a/core/m4
add wave -noupdate -group ms -expand -group m -label m5 /tb80a/vm80a/core/m5
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id00
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id01
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id02
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id03
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id04
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id05
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id06
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id07
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id08
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id09
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id10
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id80
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id81
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id82
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id83
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id84
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id85
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id86
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_11x
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_adc
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_add
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_ana
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_call
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_cma
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_cmc
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_cmp
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_cxx
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_daa
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_dad
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_dcr
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_dcx
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_eidi
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_hlt
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_idm
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_idr
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_in
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_inr
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_inx
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_io
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_jmp
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_jxx
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_lhld
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_lsax
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_lxi
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_mov
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_mvi
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_mvim
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_mvmr
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_mvrm
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_nop
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_op
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_opa
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_opi
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_opm
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_ora
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_out
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_pchl
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_pop
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_popsw
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_pupsw
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_push
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_rar
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_ret
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_rlc
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_rst
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_rxc
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_rxx
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_sbb
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_sha
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_shld
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_sphl
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_stc
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_stlda
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_sub
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_xchg
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_xra
add wave -noupdate -group ms -group id /tb80a/vm80a/core/id_xthl
add wave -noupdate -group ms -label jmptake /tb80a/vm80a/core/jmptake
add wave -noupdate -group ms -label goto /tb80a/vm80a/core/goto
add wave -noupdate -group ms -label tree0 /tb80a/vm80a/core/tree0
add wave -noupdate -group ms -label tree1 /tb80a/vm80a/core/tree1
add wave -noupdate -group ms -label tree2 /tb80a/vm80a/core/tree2
add wave -noupdate -group ms -label m836 /tb80a/vm80a/core/m836
add wave -noupdate -group ms -label m839 /tb80a/vm80a/core/m839
add wave -noupdate -group ms -label m871 /tb80a/vm80a/core/m871
add wave -noupdate -group ms -label {mstart} /tb80a/vm80a/core/mstart
add wave -noupdate -group ms -label ms0 /tb80a/vm80a/core/ms0
add wave -noupdate -group ms -label ms1 /tb80a/vm80a/core/ms1
add wave -noupdate -group ms -label mstart /tb80a/vm80a/core/mstart
add wave -noupdate -group ms -label {minta} /tb80a/vm80a/core/minta
add wave -noupdate -group ms -label {thalt} /tb80a/vm80a/core/thalt
add wave -noupdate -group ms -label eom /tb80a/vm80a/core/eom
add wave -noupdate -group ms -label start /tb80a/vm80a/core/start
add wave -noupdate -group alu -label s -radix hexadecimal /tb80a/vm80a/core/s
add wave -noupdate -group alu -label r -radix hexadecimal /tb80a/vm80a/core/r
add wave -noupdate -group alu -label x -radix hexadecimal /tb80a/vm80a/core/x
add wave -noupdate -group alu -label c -radix hexadecimal /tb80a/vm80a/core/c
add wave -noupdate -group alu -label cl /tb80a/vm80a/core/cl
add wave -noupdate -group alu -label ch /tb80a/vm80a/core/ch
add wave -noupdate -group alu -label xr -radix hexadecimal -childformat {{{/tb80a/vm80a/core/xr[7]} -radix hexadecimal} {{/tb80a/vm80a/core/xr[6]} -radix hexadecimal} {{/tb80a/vm80a/core/xr[5]} -radix hexadecimal} {{/tb80a/vm80a/core/xr[4]} -radix hexadecimal} {{/tb80a/vm80a/core/xr[3]} -radix hexadecimal} {{/tb80a/vm80a/core/xr[2]} -radix hexadecimal} {{/tb80a/vm80a/core/xr[1]} -radix hexadecimal} {{/tb80a/vm80a/core/xr[0]} -radix hexadecimal}} -expand -subitemconfig {{/tb80a/vm80a/core/xr[7]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/xr[6]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/xr[5]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/xr[4]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/xr[3]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/xr[2]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/xr[1]} {-height 15 -radix hexadecimal} {/tb80a/vm80a/core/xr[0]} {-height 15 -radix hexadecimal}} /tb80a/vm80a/core/xr
add wave -noupdate -group alu -label {alu_xwr} /tb80a/vm80a/core/alu_xwr
add wave -noupdate -group alu -label alu_srd /tb80a/vm80a/core/alu_srd
add wave -noupdate -group alu -label alu_xrd -radix hexadecimal /tb80a/vm80a/core/alu_xrd
add wave -noupdate -group alu -label alu_zrd /tb80a/vm80a/core/alu_zrd
add wave -noupdate -group alu -label alu_frd /tb80a/vm80a/core/alu_frd
add wave -noupdate -group alu -label alu_r00 /tb80a/vm80a/core/alu_r00
add wave -noupdate -group alu -label alu_rld /tb80a/vm80a/core/alu_rld
add wave -noupdate -group alu -label alu_rwr /tb80a/vm80a/core/alu_rwr
add wave -noupdate -group alu -label alu_ald /tb80a/vm80a/core/alu_ald
add wave -noupdate -group alu -label alu_ard /tb80a/vm80a/core/alu_ard
add wave -noupdate -group alu -label alu_awr /tb80a/vm80a/core/alu_awr
add wave -noupdate -group syn -label tb/sync /tb80a/sync
add wave -noupdate -group syn -label sy_hlta /tb80a/vm80a/core/sy_hlta
add wave -noupdate -group syn -label sy_inp /tb80a/vm80a/core/sy_inp
add wave -noupdate -group syn -label sy_inta /tb80a/vm80a/core/sy_inta
add wave -noupdate -group syn -label sy_m1 /tb80a/vm80a/core/sy_m1
add wave -noupdate -group syn -label sy_memr /tb80a/vm80a/core/sy_memr
add wave -noupdate -group syn -label sy_out /tb80a/vm80a/core/sy_out
add wave -noupdate -group syn -label sy_stack /tb80a/vm80a/core/sy_stack
add wave -noupdate -group syn -label sy_wo_n /tb80a/vm80a/core/sy_wo_n
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {4680000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 212
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {4082636 ps} {5277364 ps}
