transcript off
onbreak {quit -force}
onerror {quit -force}
transcript on

vlib work
vlib riviera/xpm
vlib riviera/xbip_utils_v3_0_14
vlib riviera/axi_utils_v2_0_10
vlib riviera/mult_gen_v12_0_22
vlib riviera/xbip_dsp48_wrapper_v3_0_6
vlib riviera/xbip_pipe_v3_0_10
vlib riviera/floating_point_v7_1_19
vlib riviera/dds_compiler_v6_0_26
vlib riviera/xil_defaultlib

vmap xpm riviera/xpm
vmap xbip_utils_v3_0_14 riviera/xbip_utils_v3_0_14
vmap axi_utils_v2_0_10 riviera/axi_utils_v2_0_10
vmap mult_gen_v12_0_22 riviera/mult_gen_v12_0_22
vmap xbip_dsp48_wrapper_v3_0_6 riviera/xbip_dsp48_wrapper_v3_0_6
vmap xbip_pipe_v3_0_10 riviera/xbip_pipe_v3_0_10
vmap floating_point_v7_1_19 riviera/floating_point_v7_1_19
vmap dds_compiler_v6_0_26 riviera/dds_compiler_v6_0_26
vmap xil_defaultlib riviera/xil_defaultlib

vlog -work xpm  -incr "+incdir+../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/3cbc" -l xpm -l xbip_utils_v3_0_14 -l axi_utils_v2_0_10 -l mult_gen_v12_0_22 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l floating_point_v7_1_19 -l dds_compiler_v6_0_26 -l xil_defaultlib \
"C:/Xilinx/Vivado/Vivado/2024.2/data/ip/xpm/xpm_cdc/hdl/xpm_cdc.sv" \

vcom -work xpm -93  -incr \
"C:/Xilinx/Vivado/Vivado/2024.2/data/ip/xpm/xpm_VCOMP.vhd" \

vcom -work xbip_utils_v3_0_14 -93  -incr \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/b27f/hdl/xbip_utils_v3_0_vh_rfs.vhd" \

vcom -work axi_utils_v2_0_10 -93  -incr \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/7e77/hdl/axi_utils_v2_0_vh_rfs.vhd" \

vcom -work mult_gen_v12_0_22 -93  -incr \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/e765/hdl/mult_gen_v12_0_vh_rfs.vhd" \

vcom -work xbip_dsp48_wrapper_v3_0_6 -93  -incr \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/f596/hdl/xbip_dsp48_wrapper_v3_0_vh_rfs.vhd" \

vcom -work xbip_pipe_v3_0_10 -93  -incr \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d531/hdl/xbip_pipe_v3_0_vh_rfs.vhd" \

vcom -work floating_point_v7_1_19 -93  -incr \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/bf3d/hdl/floating_point_v7_1_rfs.vhd" \

vlog -work floating_point_v7_1_19  -incr -v2k5 "+incdir+../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/3cbc" -l xpm -l xbip_utils_v3_0_14 -l axi_utils_v2_0_10 -l mult_gen_v12_0_22 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l floating_point_v7_1_19 -l dds_compiler_v6_0_26 -l xil_defaultlib \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/bf3d/hdl/floating_point_v7_1_rfs.v" \

vcom -work dds_compiler_v6_0_26 -2008  -incr \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/float_pkg.vhd" \

vcom -work dds_compiler_v6_0_26 -93  -incr \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/dds_compiler_v6_0_viv_comp.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/dds_compiler_v6_0_comp.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/pkg_dds_compiler_v6_0.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/pkg_beta.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/pkg_alpha.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/dds_compiler_v6_0_hdl_comps.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/dither_wrap.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/pipe_add.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/lut_ram.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/lut5_ram.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/flt_ufma_consts.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/flt_ufma.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/sin_cos.vhd" \

vcom -work dds_compiler_v6_0_26 -2008  -incr \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/sin_cos_fp.vhd" \

vcom -work dds_compiler_v6_0_26 -93  -incr \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/sin_cos_fp_reconstruct.vhd" \

vcom -work dds_compiler_v6_0_26 -2008  -incr \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/sin_cos_fp_partition.vhd" \

vcom -work dds_compiler_v6_0_26 -93  -incr \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/sin_cos_quad_rast.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/dsp48_wrap.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/accum.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/raster_accum.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/multadd.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/dds_compiler_v6_0_eff_lut.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/dds_compiler_v6_0_eff.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/dds_compiler_v6_0_rdy.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/dds_compiler_v6_0_core.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/dds_compiler_v6_0_viv.vhd" \
"../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/d32a/hdl/dds_compiler_v6_0.vhd" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/SIGNAL_GENERATOR/ip/SIGNAL_GENERATOR_dds_compiler_0_0/sim/SIGNAL_GENERATOR_dds_compiler_0_0.vhd" \

vlog -work xil_defaultlib  -incr -v2k5 "+incdir+../../../../IIR_DECIMATION.gen/sources_1/bd/SIGNAL_GENERATOR/ipshared/3cbc" -l xpm -l xbip_utils_v3_0_14 -l axi_utils_v2_0_10 -l mult_gen_v12_0_22 -l xbip_dsp48_wrapper_v3_0_6 -l xbip_pipe_v3_0_10 -l floating_point_v7_1_19 -l dds_compiler_v6_0_26 -l xil_defaultlib \
"../../../bd/SIGNAL_GENERATOR/ip/SIGNAL_GENERATOR_clk_wiz_0_0/SIGNAL_GENERATOR_clk_wiz_0_0_clk_wiz.v" \
"../../../bd/SIGNAL_GENERATOR/ip/SIGNAL_GENERATOR_clk_wiz_0_0/SIGNAL_GENERATOR_clk_wiz_0_0.v" \

vcom -work xil_defaultlib -93  -incr \
"../../../bd/SIGNAL_GENERATOR/sim/SIGNAL_GENERATOR.vhd" \

vlog -work xil_defaultlib \
"glbl.v"

