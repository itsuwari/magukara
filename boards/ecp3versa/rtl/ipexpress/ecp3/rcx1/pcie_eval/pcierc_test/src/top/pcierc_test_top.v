// =============================================================================
//                           COPYRIGHT NOTICE
// Copyright 2000-2001 (c) Lattice Semiconductor Corporation
// ALL RIGHTS RESERVED
// This confidential and proprietary software may be used only as authorised
// by a licensing agreement from Lattice Semiconductor Corporation.
// The entire notice above must be reproduced on all authorized copies and
// copies may only be made to the extent permitted by a licensing agreement
// from Lattice Semiconductor Corporation.
//
// Lattice Semiconductor Corporation    TEL : 1-800-Lattice (USA and Canada)
// 5555 NE Moore Court                        408-826-6000 (other locations)
// Hillsboro, OR 97124                  web  : http://www.latticesemi.com/
// U.S.A                                email: techsupport@latticesemi.com
// =============================================================================
//                         FILE DETAILS
// Project          : pci_express_top
// File             : pci_express_top_pp.v
// Title            :
// Dependencies     : 
// Description      : User Top level for IP. 
// =============================================================================
module pcierc_test_top (
   // Clock and Reset
   input  wire              refclkp,        // 100MHz from board
   input  wire              refclkn,        // 100MHz from board
   output wire              sys_clk_125,    // 125MHz output clock from core 
   input  wire              rst_n,

   // ASIC side pins for PCSA.  These pins must exist for the PCS core.
   input  wire              hdinp0,         // exemplar attribute hdinp0 NOPAD true
   input  wire              hdinn0,         // exemplar attribute hdinp0 NOPAD true
   output wire              hdoutp0,        // exemplar attribute hdoutp0 NOPAD true
   output wire              hdoutn0,        // exemplar attribute hdoutp0 NOPAD true

   input wire [3:0]       phy_force_cntl,   // debug force bus
                                            // [0] - Force LSM Status Active
                                            // [1] - Force Received Electrical Idle
                                            // [2] - Force PHY Connection Status
                                            // [3] - Force Disable Scrambler to PCS

   input wire [12:0]      phy_ltssm_cntl,   // LTSSM control bus
                                            // [0] - Disable the training process
                                            // [1] - Force to retraing Link
                                            // [2] - HL req. to Disable Scrambling bit in TS1/TS2 
                                            // [3] - HL req a jump to Disable
                                            // [4] - HL req a jump to detect
                                            // [5] - HL req a jump to Hot reset
                                            // [6] - HL req a jump to TX L0s
                                            // [7] - HL req a jump to L1
                                            // [8] - HL req a jump to L2 
                                            // [9] - HL req a jump to L0s TX FTS 
                                            // [10] - HL req a jump to Loopback
                                            // [11] - HL req a jump to recovery 
                                            // [12] - HL req a jump to CFG 


   // Power Management Interface
   input wire  [1:0]         tx_dllp_val,         // Req for Sending PM/Vendor type DLLP
   input wire  [2:0]         tx_pmtype,           // Power Management Type
   input wire  [23:0]        tx_vsd_data,         // Vendor Type DLLP contents

   // From TX user Interface  
   input wire                tx_req_vc0,          // VC0 Request from User  
   input wire [15:0]         tx_data_vc0,         // VC0 Input data from user logic 
   input wire                tx_st_vc0,           // VC0 start of pkt from user logic.  
   input wire                tx_end_vc0,          // VC0 End of pkt from user logic. 
   input wire                tx_nlfy_vc0,         // VC0 End of nullified pkt from user logic.  
   input wire                ph_buf_status_vc0,   // VC0 Indicate the Full/alm.Full status of the PH buffers
   input wire                pd_buf_status_vc0,   // VC0 Indicate PD Buffer has got space less than Max Pkt size
   input wire                nph_buf_status_vc0,  // VC0 For NPH
   input wire                npd_buf_status_vc0,  // VC0 For NPD
   input wire                cplh_buf_status_vc0, // VC0 For CPLH
   input wire                cpld_buf_status_vc0, // VC0 For CPLD
   input wire                ph_processed_vc0,    // VC0 TL has processed one TLP Header - PH Type
   input wire                pd_processed_vc0,    // VC0 TL has processed one TLP Data - PD TYPE
   input wire                nph_processed_vc0,   // VC0 For NPH
   input wire                npd_processed_vc0,   // VC0 For NPD
   input wire                cplh_processed_vc0,  // VC0 For CPLH
   input wire                cpld_processed_vc0,  // VC0 For CPLD
   input wire [7:0]          pd_num_vc0,          // VC0 For PD -- No. of Data processed
   input wire [7:0]          npd_num_vc0,         // VC0 For PD
   input wire [7:0]          cpld_num_vc0,        // VC0 For CPLD

   // User Loop back data
   input wire  [15:0]        tx_lbk_data,     // TX User Master Loopback data
   input wire  [1:0]         tx_lbk_kcntl,    // TX User Master Loopback control
   output wire               tx_lbk_rdy,      // TX loop back is ready to accept data
   output wire [15:0]        rx_lbk_data,     // RX User Master Loopback data
   output wire [1:0]         rx_lbk_kcntl,    // RX User Master Loopback control

   // Power Management/ Vendor specific DLLP
   output wire               tx_dllp_sent,    // Requested PM DLLP is sent
   output wire [2:0]         rxdp_pmd_type,   // PM DLLP type bits.
   output wire [23:0]        rxdp_vsd_data ,  // Vendor specific DLLP data.
   output wire [1:0]         rxdp_dllp_val,   // PM/Vendor specific DLLP valid.

   // To TX User Interface
   output wire               tx_rdy_vc0,         // VC0 TX ready indicating signal
   output wire [8:0]         tx_ca_ph_vc0,       // VC0 Available credit for Posted Type Headers
   output wire [12:0]        tx_ca_pd_vc0,       // VC0 For Posted - Data
   output wire [8:0]         tx_ca_nph_vc0,      // VC0 For Non-posted - Header
   output wire [12:0]        tx_ca_npd_vc0,      // VC0 For Non-posted - Data
   output wire [8:0]         tx_ca_cplh_vc0,     // VC0 For Completion - Header
   output wire [12:0]        tx_ca_cpld_vc0,     // VC0 For Completion - Data

   // To RX User Interface
   output wire [15:0]        rx_data_vc0,        // VC0 Receive data
   output wire               rx_st_vc0,          // VC0 Receive data start
   output wire               rx_end_vc0,         // VC0 Receive data end
   output wire               rx_pois_tlp_vc0 ,   // VC0 poisoned tlp received  
   output wire               rx_malf_tlp_vc0 ,   // VC0 malformed TLP in received data 


   // FROM DLL
   output wire [7:0]        dll_status,     // DLL status bus
                                            // [0] - DL_Up, Data link layer is ready
                                            // [1] - DL_init, DLL is in DL_Init state. 
                                            // [2] - DL_inact, DLL is in DL_Inact state. 
                                            // [3] - Bad_dllp, DLL receivced a bad DLLP.
                                            // [4] - DL error, DLL protocol error
                                            // [5] - Bad TLP,  DLL receivced a bad TLP
                                            // [6] - rply_tout, DLL replay timeout indication
                                            // [7] - rnum_rlor, replay number roll over in DLL

   // FROM PHY
   output wire [2:0]         phy_cfgln_sum,      // Number of Configured lanes
   output wire               phy_pol_compliance, // Polling compliance 
   output wire [3:0]         phy_ltssm_state,    // Indicates the states of the ltssm 
   output wire [2:0]         phy_ltssm_substate, // sub-states of the ltssm_state

   // FROM TRN
   output wire               inta_n ,            // INTA interrupt
   output wire               intb_n ,            // INTB interrupt
   output wire               intc_n ,            // INTC interrupt
   output wire               intd_n ,            // INTD interrupt
   output wire               ftl_err_msg ,       // Fata error message received
   output wire               nftl_err_msg ,      // non-Fatal error message received
   output wire               cor_err_msg         // Correctable error message received

   )/* synthesis black_box_pad_pin = "HDINP0, HDINN0, HDOUTP0, HDOUTN0, REFCLKP, REFCLKN" */;
// =============================================================================
// Define Wires & Regs
// =============================================================================
reg   [19:0]             rstn_cnt;
reg                      core_rst_n; 
wire                     irst_n ;

wire  [1:0]              power_down;  
wire                     reset_n;
wire                     tx_detect_rx_lb;
wire                     phy_status;

wire  [7:0]              txp_data;
wire                     txp_data_k;
wire                     txp_elec_idle;
wire                     txp_compliance;

wire  [7:0]              rxp_data;
wire                     rxp_data_k;
wire                     rxp_valid;
wire                     rxp_polarity;
wire                     rxp_elec_idle;
wire  [2:0]              rxp_status;

wire                     pclk;           //250MHz clk from PCS PIPE for 8 bit data
wire [3:0]               phy_cfgln;
wire                     phy_l0;   

assign phy_l0         = (phy_ltssm_state == 'd3) ;

// =============================================================================
// Reset management
// =============================================================================
always @(posedge sys_clk_125 or negedge rst_n) begin
   if (!rst_n) begin
       rstn_cnt   <= 20'd0 ;
       core_rst_n <= 1'b0 ;
   end
   else begin
      if (rstn_cnt[19])            // 4ms in real hardware
         core_rst_n <= 1'b1 ;
      // synthesis translate_off
         else if (rstn_cnt[7])     // 128 clocks 
            core_rst_n <= 1'b1 ;
      // synthesis translate_on
      else 
         rstn_cnt <= rstn_cnt + 1'b1 ;
   end
end

GSR GSR_INST (.GSR(rst_n));
PUR PUR_INST (.PUR(1'b1));

// Connect rst_n pin to GSR, pipe wrapper, core and user logic
// assign irst_n = rst_n ;            
// Connect rst_n pin to pipe wrapper, 4ms delayed rst_n to core and user logic
assign irst_n = core_rst_n ; 

// =============================================================================
// SERDES/PCS instantiation in PIPE mode
// =============================================================================
//pcs_pipe u1_pcs_pipe (
rc_pcs_pipe_top u1_pcs_pipe (
        .refclkp              ( refclkp ), 
        .refclkn              ( refclkn ), 
        .RESET_n              ( rst_n ),
        .ffc_quad_rst         ( ~rst_n ), 
        .PowerDown            ( power_down ), 
        .TxDetectRx_Loopback  ( tx_detect_rx_lb ), 
        .PCLK                 ( pclk ),
        .PCLK_by_2            ( sys_clk_125 ),
        .PhyStatus            ( phy_status ), 
        .ffs_plol             ( ), 

        .hdinp0               ( hdinp0 ), 
        .hdinn0               ( hdinn0 ), 
        .hdoutp0              ( hdoutp0 ), 
        .hdoutn0              ( hdoutn0 ), 

        .TxData_0             ( txp_data ), 
        .TxDataK_0            ( txp_data_k ), 
        .TxCompliance_0       ( txp_compliance ), 
        .TxElecIdle_0         ( txp_elec_idle ), 
        .RxPolarity_0         ( rxp_polarity ), 
        .scisel_0             ( 1'b0 ),
        .scien_0              ( 1'b0 ),   
        .RxData_0             ( rxp_data ), 
        .RxDataK_0            ( rxp_data_k ), 
        .RxValid_0            ( rxp_valid ), 
        .RxElecIdle_0         ( rxp_elec_idle ), 
        .RxStatus_0           ( rxp_status ), 
        .ffs_rlol_ch0         ( ), 

        .sciwritedata         ( 8'h0 ),
        .sciaddress           ( 6'h0 ),
        .scienaux             ( 1'b0 ),
        .sciselaux            ( 1'b0 ),
        .scird                ( 1'b0 ),
        .sciwstn              ( 1'b0 ),
        .scireaddata          (  ),
        
        .phy_l0               ( phy_l0 ), 
        .phy_cfgln            ( 4'b0000 ), 
        .ctc_disable          ( 1'b0 ),
        .flip_lanes           ( 1'b0 ) 
        );

// =============================================================================
// PCI Express Core
// =============================================================================
pcierc_test u1_dut(
   // Clock and Reset
   .sys_clk_250                ( pclk ) ,
   .sys_clk_125                ( sys_clk_125 ) ,
   .rst_n                      ( irst_n ),

   .phy_force_cntl             ( phy_force_cntl ),
   .phy_ltssm_cntl             ( phy_ltssm_cntl ),

   // Power Management Interface
   .tx_dllp_val                ( tx_dllp_val ),
   .tx_pmtype                  ( tx_pmtype ),
   .tx_vsd_data                ( tx_vsd_data ),

   .tx_req_vc0                 ( tx_req_vc0 ),    
   .tx_data_vc0                ( tx_data_vc0 ),    
   .tx_st_vc0                  ( tx_st_vc0 ), 
   .tx_end_vc0                 ( tx_end_vc0 ), 
   .tx_nlfy_vc0                ( tx_nlfy_vc0 ), 
   .ph_buf_status_vc0          ( ph_buf_status_vc0 ),
   .pd_buf_status_vc0          ( pd_buf_status_vc0 ),
   .nph_buf_status_vc0         ( nph_buf_status_vc0 ),
   .npd_buf_status_vc0         ( npd_buf_status_vc0 ),
   .cplh_buf_status_vc0        ( cplh_buf_status_vc0 ),
   .cpld_buf_status_vc0        ( cpld_buf_status_vc0 ),
   .ph_processed_vc0           ( ph_processed_vc0 ),
   .pd_processed_vc0           ( pd_processed_vc0 ),
   .nph_processed_vc0          ( nph_processed_vc0 ),
   .npd_processed_vc0          ( npd_processed_vc0 ),
   .cplh_processed_vc0         ( cplh_processed_vc0 ),
   .cpld_processed_vc0         ( cpld_processed_vc0 ),
   .pd_num_vc0                 ( pd_num_vc0 ),
   .npd_num_vc0                ( npd_num_vc0 ),
   .cpld_num_vc0               ( cpld_num_vc0 ),


    // From  External PHY (PIPE I/F)
   .rxp_data               ( rxp_data ),            
   .rxp_data_k             ( rxp_data_k ),          
   .rxp_valid              ( rxp_valid ),         
   .rxp_elec_idle          ( rxp_elec_idle ),    
   .rxp_status             ( rxp_status ),      

   .phy_status                 ( phy_status),    

   // User Loop back data
   .tx_lbk_data                ( tx_lbk_data ),
   .tx_lbk_kcntl               ( tx_lbk_kcntl ),
   .tx_lbk_rdy                 ( tx_lbk_rdy ),
   .rx_lbk_data                ( rx_lbk_data ),
   .rx_lbk_kcntl               ( rx_lbk_kcntl ),

   // Power Management
   .tx_dllp_sent               ( tx_dllp_sent ),
   .rxdp_pmd_type              ( rxdp_pmd_type ),
   .rxdp_vsd_data              ( rxdp_vsd_data ),
   .rxdp_dllp_val              ( rxdp_dllp_val ),

   //-------- Outputs
   // To External PHY (PIPE I/F)
   .txp_data               ( txp_data ),
   .txp_data_k             ( txp_data_k ),
   .txp_elec_idle          ( txp_elec_idle ), 
   .txp_compliance         ( txp_compliance ),  
   .rxp_polarity           ( rxp_polarity ),   

   .txp_detect_rx_lb           ( tx_detect_rx_lb ),    
   .reset_n                    ( reset_n ),            
   .power_down                 ( power_down ),        

   // To TX User Interface
   //.tx_val                     ( tx_val ),   
   .tx_rdy_vc0                 ( tx_rdy_vc0),  
   .tx_ca_ph_vc0               ( tx_ca_ph_vc0),
   .tx_ca_pd_vc0               ( tx_ca_pd_vc0),
   .tx_ca_nph_vc0              ( tx_ca_nph_vc0),
   .tx_ca_npd_vc0              ( tx_ca_npd_vc0), 
   .tx_ca_cplh_vc0             ( tx_ca_cplh_vc0),
   .tx_ca_cpld_vc0             ( tx_ca_cpld_vc0),

   .rx_data_vc0                ( rx_data_vc0),    
   .rx_st_vc0                  ( rx_st_vc0),     
   .rx_end_vc0                 ( rx_end_vc0),   
   .rx_pois_tlp_vc0            ( rx_pois_tlp_vc0 ), 
   .rx_malf_tlp_vc0            ( rx_malf_tlp_vc0 ), 

   // From TRN
   .inta_n                     ( inta_n ) , 
   .intb_n                     ( intb_n ) , 
   .intc_n                     ( intc_n ) , 
   .intd_n                     ( intd_n ) , 
   .ftl_err_msg                ( ftl_err_msg ) ,
   .nftl_err_msg               ( nftl_err_msg ) ,
   .cor_err_msg                ( cor_err_msg ) ,

   // From DLL
   .dll_status                 ( dll_status ),

   // From PHY
   .phy_cfgln_sum              ( phy_cfgln_sum ),   
   .phy_pol_compliance         ( phy_pol_compliance ),   
   .phy_ltssm_state            ( phy_ltssm_state ),     
   .phy_ltssm_substate         ( phy_ltssm_substate )     
   );

endmodule

