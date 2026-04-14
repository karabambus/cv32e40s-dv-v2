// Copyright 2018 Robert Balas <balasr@student.ethz.ch>
// Copyright and related rights are licensed under the Solderpad Hardware
// License, Version 0.51 (the "License"); you may not use this file except in
// compliance with the License.  You may obtain a copy of the License at
// http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
// or agreed to in writing, software, hardware and materials distributed under
// this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.

// Wrapper for a CV32E40S testbench, containing CV32E40S, Memory and stdout peripheral
// Contributor: Robert Balas <balasr@student.ethz.ch>
// Module renamed from riscv_wrapper to cv32e40s_tb_wrapper because (1) the
// name of the core changed, and (2) the design has a cv32e40s_wrapper module.
//
// SPDX-License-Identifier: Apache-2.0 WITH SHL-0.51

import cv32e40s_pkg::*;

module cv32e40s_tb_wrapper
    #(parameter 
        INSTR_RDATA_WIDTH = 32,
        RAM_ADDR_WIDTH    = 22,
        BOOT_ADDR         = 32'h80,
        DM_HALTADDRESS    = 32'h1A11_0800,
        HART_ID           = 32'h0000_0000,
        IMP_PATCH_ID      = 4'h0
    )
    (
     input logic         clk_i,
     input logic         rst_ni,

     input logic [31:0]  boot_addr_i,
     input logic         fetch_enable_i,
     output logic        tests_passed_o,
     output logic        tests_failed_o,
     output logic [31:0] exit_value_o,
     output logic        exit_valid_o
    );

    // --- Core/RAM Interconnect Signals ---
    logic                                instr_req;
    logic                                instr_gnt;
    logic                                instr_rvalid;
    logic [31:0]                         instr_addr;
    logic [INSTR_RDATA_WIDTH-1:0]        instr_rdata;
    
    logic                                data_req;
    logic                                data_gnt;
    logic                                data_rvalid;
    logic [31:0]                         data_addr;
    logic                                data_we;
    logic [3:0]                          data_be;
    logic [31:0]                         data_rdata;
    logic [31:0]                         data_wdata;

    logic [31:0]                         irq;
    logic                                debug_req;
    logic                                fencei_flush_req;

    // PMP: All 16 regions OFF at reset, mseccfg=0, M-mode unrestricted.
    // Explicit localparams needed for Verilator constant folding.
    localparam cv32e40s_pkg::pmpncfg_t PMP_PMPNCFG_RV_SETTING[16] = '{default: cv32e40s_pkg::PMPNCFG_DEFAULT};
    localparam logic [31:0]            PMP_PMPADDR_RV_SETTING[16]  = '{default: 32'h0};
    localparam cv32e40s_pkg::mseccfg_t PMP_MSECCFG_RV_SETTING      = cv32e40s_pkg::MSECCFG_DEFAULT;

    // PMA Region 0: 0x00000000 – 0x003FFFFF (4 MB main memory)
    // Covers all code (.text) and data (.data, .bss, .tohost) sections.
    // Everything outside defaults to I/O (no exec, no misaligned, no PUSH/POP).
    localparam cv32e40s_pkg::pma_cfg_t PMA_CFG_SETTING[1] = '{
        '{
            word_addr_low:  32'h0000_0000,
            word_addr_high: 32'h0010_0000,
            main:           1'b1,
            bufferable:     1'b0,
            cacheable:      1'b0,
            integrity:      1'b0,
            default:        '0
        }
    };

    // --- CV32E40S Core Instantiation (Using your Template) ---
    cv32e40s_core #(
        .LIB                      ( 0 ),
        .RV32                     ( cv32e40s_pkg::RV32I ),
        .B_EXT                    ( cv32e40s_pkg::B_NONE ), // Changed from NONE to B_NONE
        .M_EXT                    ( cv32e40s_pkg::M      ),
        .DEBUG                    ( 1 ),
        .DM_REGION_START          ( 32'hF0000000 ),
        .DM_REGION_END            ( 32'hF0003FFF ),
        .DBG_NUM_TRIGGERS         ( 1 ),
        .PMP_GRANULARITY          ( 0 ),
        .PMP_NUM_REGIONS          ( 16 ),
        .PMP_PMPNCFG_RV           ( PMP_PMPNCFG_RV_SETTING ),
        .PMP_PMPADDR_RV           ( PMP_PMPADDR_RV_SETTING ),
        .PMP_MSECCFG_RV           ( PMP_MSECCFG_RV_SETTING ),
        .PMA_NUM_REGIONS          ( 1 ),
        // Use a raw zero-initializer if PMA_CFG_DEFAULT isn't in your package
        .PMA_CFG                  ( PMA_CFG_SETTING ), 
        .CLIC                     ( 0 ),
        .CLIC_ID_WIDTH            ( 5 ),
        .LFSR0_CFG                ( cv32e40s_pkg::LFSR_CFG_DEFAULT ), 
        .LFSR1_CFG                ( cv32e40s_pkg::LFSR_CFG_DEFAULT ),
        .LFSR2_CFG                ( cv32e40s_pkg::LFSR_CFG_DEFAULT )
    ) u_core (
        // Clock and reset
        .clk_i                    ( clk_i            ),
        .rst_ni                   ( rst_ni           ),
        .scan_cg_en_i             ( 1'b0             ),
        // Configuration
        .boot_addr_i              ( boot_addr_i      ),
        .mtvec_addr_i             ( 32'h0            ),
        .dm_halt_addr_i           ( DM_HALTADDRESS   ),
        .dm_exception_addr_i      ( 32'h0            ),
        .mhartid_i                ( HART_ID          ),
        .mimpid_patch_i           ( IMP_PATCH_ID     ),
        // Instruction memory interface
        .instr_req_o              ( instr_req        ),
        .instr_reqpar_o           (                  ), // Open
        .instr_gnt_i              ( instr_gnt        ),
        .instr_gntpar_i           ( 1'b0             ),
        .instr_addr_o             ( instr_addr       ),
        .instr_memtype_o          (                  ), // Open
        .instr_prot_o             (                  ), // Open
        .instr_achk_o             (                  ), // Open
        .instr_dbg_o              (                  ), // Open
        .instr_rvalid_i           ( instr_rvalid     ),
        .instr_rvalidpar_i        ( 1'b0             ),
        .instr_rdata_i            ( instr_rdata      ),
        .instr_err_i              ( 1'b0             ),
        .instr_rchk_i             ( 5'b0             ),
        // Data memory interface
        .data_req_o               ( data_req         ),
        .data_reqpar_o            (                  ), // Open
        .data_gnt_i               ( data_gnt         ),
        .data_gntpar_i            ( 1'b0             ),
        .data_addr_o              ( data_addr        ),
        .data_be_o                ( data_be          ),
        .data_memtype_o           (                  ), // Open
        .data_prot_o              (                  ), // Open
        .data_dbg_o               (                  ), // Open
        .data_wdata_o             ( data_wdata       ),
        .data_we_o                ( data_we          ),
        .data_achk_o              (                  ), // Open
        .data_rvalid_i            ( data_rvalid      ),
        .data_rvalidpar_i         ( 1'b0             ),
        .data_rdata_i             ( data_rdata       ),
        .data_err_i               ( 1'b0             ),
        .data_rchk_i              ( 5'b0             ),
        // Cycle
        .mcycle_o                 (                  ), // Open
        // Interrupt interface
        .irq_i                    ( irq              ),
        .clic_irq_i               ( 1'b0             ),
        .clic_irq_id_i            ( 5'b0             ),
        .clic_irq_level_i         ( 8'b0             ),
        .clic_irq_priv_i          ( 2'b0             ),
        .clic_irq_shv_i           ( 1'b0             ),
        // Fencei flush handshake
        .fencei_flush_req_o       ( fencei_flush_req ),
        .fencei_flush_ack_i       ( fencei_flush_req ), // Auto-ack
        // Debug interface
        .debug_req_i              ( debug_req        ),
        .debug_havereset_o        (                  ), // Open
        .debug_running_o          (                  ), // Open
        .debug_halted_o           (                  ), // Open
        .debug_pc_valid_o         (                  ), // Open
        .debug_pc_o               (                  ), // Open
        // Alert interface
        .alert_major_o            (                  ), // Open
        .alert_minor_o            (                  ), // Open
        // Special control signals
        .fetch_enable_i           ( fetch_enable_i   ),
        .core_sleep_o             (                  ), // Open
        .wu_wfe_i                 ( 1'b0             )
    );

    // --- Memory System ---
    mm_ram #(
        .RAM_ADDR_WIDTH    ( RAM_ADDR_WIDTH      ),
        .INSTR_RDATA_WIDTH ( INSTR_RDATA_WIDTH   )
    ) ram_i (
        .clk_i          ( clk_i          ),
        .rst_ni         ( rst_ni         ),
        .dm_halt_addr_i ( DM_HALTADDRESS ),

        .instr_req_i    ( instr_req      ),
        .instr_addr_i   ( { {(32-RAM_ADDR_WIDTH){1'b0}}, instr_addr[RAM_ADDR_WIDTH-1:0] } ),
        .instr_rdata_o  ( instr_rdata    ),
        .instr_rvalid_o ( instr_rvalid   ),
        .instr_gnt_o    ( instr_gnt      ),

        .data_req_i     ( data_req       ),
        .data_addr_i    ( data_addr      ),
        .data_we_i      ( data_we        ),
        .data_be_i      ( data_be        ),
        .data_wdata_i   ( data_wdata     ),
        .data_rdata_o   ( data_rdata     ),
        .data_rvalid_o  ( data_rvalid    ),
        .data_gnt_o     ( data_gnt       ),

        .irq_o          ( irq            ),
        .debug_req_o    ( debug_req      ),
        .tests_passed_o ( tests_passed_o ),
        .tests_failed_o ( tests_failed_o ),
        .exit_valid_o   ( exit_valid_o   ),
        .exit_value_o   ( exit_value_o   ),
        
        .pc_core_id_i   ( u_core.id_stage_i.if_id_pipe_i.pc ) 
    );

endmodule
