source /space/users/ory/user/be_scripts/nxt_007_tools/place_pins_procs.tcl

#set_db [get_db ports *] .place_status unplaced
#delete_obj [get_db port_shapes -if {.name != V*}]

#- Center (3 main clock pins)
##############

# We could use the design width and height to place these 3 pins in the middle.
# However these pins are placed in M14 and hence they should be placed in between power/group horinztail stripes.
edit_pin -pin grid_clk     -layer M14 -pin_depth 0.5 -pin_width 0.45 -assign {235.296 866.4} -fixed_pin -fix_overlap 0 -side inside -snap mgrid
edit_pin -pin grid_tor_clk -layer M14 -pin_depth 0.5 -pin_width 0.45 -assign {240.768 870.96} -fixed_pin -fix_overlap 0 -side inside -snap mgrid
edit_pin -pin grid_mng_clk -layer M14 -pin_depth 0.5 -pin_width 0.45 -assign {246.24 875.52} -fixed_pin -fix_overlap 0 -side inside -snap mgrid
#- Top side (from left to right)
##############

# A[0~31] : gcu_fe_ingress_*_u
# B[0~15] : tor_data_groups_north_egress_*_u
# C[0~7]  : tor_data_groups_south_ingress_*_u
# D[0~3]  : gmu_tor_req_north_egress_*_u
# E[0~3]  : gmu_tor_rsp_north_egress_*_u
# F[0~3]  : gmu_tor_req_south_ingress_*_u
# G[0~3]  : gmu_tor_rsp_south_ingress_*_u
# H[1~0]  : tor_fctl_north_egress_*_u
# I[1~0]  : tor_fctl_south_ingress_*_u
# J       : dft_grid_cluster_*_u
# K       : cfg_p_cluster_row_id_u
# L       : ijtag_tck
# M       : ijtag_ue
# N       : ijtag_ce
# O       : ijtag_se
# P       : grid_mng_rst_n_u
# Q       : grid_rst_n_u
# R       : bisr_clk
# S       : bisr_shift_en
# T       : bisr_disable_u

#   A0 A1 A2 A3          A4 A5 A6 A7                      A8 A9 A10 A11                      A12 A13 A14 A15                       A16 A17 A18 A19                      A20 A21 A22 A23                        A24 A25 A26 A27             A28 A29 A30 A31 
#               B0 B1                B2 B3                              B4 B5                                B6 B7                                 B8 B9                                B10 B11                                B12 B13                    B14 B15
#                     C0                   C1                                 C2                                   C3                                    C4                                     C5                                     C6                         C7
#                                             D0 E0 F0 G0                        D1 E1 F1 G1                                                                D2 E2 F2 G2                            D3 E3 F3 G3        
#                                                                                                                     H0 I0 H1 I1 J0 K0 L0 M0 N0 O0 P0 Q0 R0 S0 T0                                                                                                                                  
#                                                                                                                                 

set A [list gcu_fe_ingress_*_u                          doublebus       dec      pins_exception]
set B [list tor_data_north_egress_*_u                   doublebus       dec      no]
set C [list tor_data_south_ingress_*_u                  doublebus       dec      no]
set D [list gmu_tor_req_north_egress_*_u                doublebus       bin      no]
set E [list gmu_tor_rsp_north_egress_*_u                doublebus       bin      no]
set F [list gmu_tor_req_south_ingress_*_u               doublebus       bin      no]
set G [list gmu_tor_rsp_south_ingress_*_u               doublebus       bin      no]
set H [list tor_fctl_north_egress_*_u                   doublebus       dec      no]
set I [list tor_fctl_south_ingress_*_u                  doublebus       dec      no]
set J [list dft_grid_cluster_*_u                        no              no       no]
set K [list {cfg_p_cluster_row_id_u\[*}                 no              no       no]
set L [list ijtag_tck                                   no              no       no]
set M [list ijtag_ue                                    no              no       no]
set N [list ijtag_ce                                    no              no       no]
set O [list ijtag_se                                    no              no       no]
set P [list grid_mng_rst_n_u                            no              no       no]
set Q [list grid_rst_n_u                                no              no       no]
set R [list bisr_clk                                    no              no       no]
set S [list bisr_shift_en                               no              no       no]
set T [list bisr_disable_u                              no              no       no]

set top_scheme [list A0 A1 A2 A3 B0 B1 C0 A4 A5 A6 A7 B2 B3 C1 D0 E0 F0 G0 A8 A9 A10 A11 B4 B5 C2 D1 E1 F1 G1 A12 A13 A14 A15 B6 B7 C3 H0 I0 H1 I1 J0 K0 L0 M0 N0 O0 P0 Q0 R0 S0 T0 A16 A17 A18 A19 B8 B9 C4 D2 E2 F2 G2 A20 A21 A22 A23 B10 B11 C5 D3 E3 F3 G3 A24 A25 A26 A27 B12 B13 C6 A28 A29 A30 A31 B14 B15 C7]
set top_layers [list M5 M7 M9]
set top_edge 1
set top_offset_start 2
set top_offset_end 2

place_pins $top_scheme $top_layers $top_edge $top_offset_start $top_offset_end clockwise


#- Bottom side (from left to right)
##############

# A[0~31] : gcu_fe_ingress_*_d
# B[0~15] : tor_data_groups_north_ingress_*_d
# C[0~7]  : tor_data_groups_south_egress_*_d
# D[0~3]  : gmu_tor_req_north_ingress_*_d
# E[0~3]  : gmu_tor_rsp_north_ingress_*_d
# F[0~3]  : gmu_tor_req_south_egress_*_d
# G[0~3]  : gmu_tor_rsp_south_egress_*_d
# H[1~0]  : tor_fctl_north_egress_*_d
# I[1~0]  : tor_fctl_south_ingress_*_d
# J       : dft_grid_cluster_*_d
# K       : cfg_p_cluster_row_id_inc_d
# L       : ijtag_tck_d
# M       : ijtag_ue_d
# N       : ijtag_ce_d
# O       : ijtag_se_d
# P       : grid_mng_rst_n_ft_d
# Q       : grid_rst_n_ft_d
# R       : bisr_clk_d
# S       : bisr_shift_en_d
# T       : bisr_disable_ft_d

#   A0 A1 A2 A3          A4 A5 A6 A7                      A8 A9 A10 A11                      A12 A13 A14 A15                       A16 A17 A18 A19                      A20 A21 A22 A23                        A24 A25 A26 A27             A28 A29 A30 A31 
#               B0 B1                B2 B3                              B4 B5                                B6 B7                                 B8 B9                                B10 B11                                B12 B13                    B14 B15
#                     C0                   C1                                 C2                                   C3                                    C4                                     C5                                     C6                         C7
#                                             D0 E0 F0 G0                        D1 E1 F1 G1                                                                D2 E2 F2 G2                            D3 E3 F3 G3        
#                                                                                                                     H0 I0 H1 I1 J0 K0 L0 M0 N0 O0 P0 Q0 R0 S0 T0                                                                                                                                   
#                                                                                                                                 

set A [list gcu_fe_egress_*_d                           doublebus       dec      pins_exception]
set B [list tor_data_north_ingress_*_d                  doublebus       dec      no]
set C [list tor_data_south_egress_*_d                   doublebus       dec      no]
set D [list gmu_tor_req_north_ingress_*_d               doublebus       bin      no]
set E [list gmu_tor_rsp_north_ingress_*_d               doublebus       bin      no]
set F [list gmu_tor_req_south_egress_*_d                doublebus       bin      no]
set G [list gmu_tor_rsp_south_egress_*_d                doublebus       bin      no]
set H [list tor_fctl_north_ingress_*_d                  doublebus       dec      no]
set I [list tor_fctl_south_egress_*_d                   doublebus       dec      no]
set J [list dft_grid_cluster_*_d                        no              no       no]
set K [list {cfg_p_cluster_row_id_inc_d\[*}             no              no       no]
set L [list ijtag_tck_d                                 no              no       no]
set M [list ijtag_ue_d                                  no              no       no]
set N [list ijtag_ce_d                                  no              no       no]
set O [list ijtag_se_d                                  no              no       no]
set P [list grid_mng_rst_n_ft_d                         no              no       no]
set Q [list grid_rst_n_ft_d                             no              no       no]
set R [list bisr_clk_d                                  no              no       no]
set S [list bisr_shift_en_d                             no              no       no]
set T [list bisr_disable_ft_d                           no              no       no]

set bottom_scheme [list A0 A1 A2 A3 B0 B1 C0 A4 A5 A6 A7 B2 B3 C1 D0 E0 F0 G0 A8 A9 A10 A11 B4 B5 C2 D1 E1 F1 G1 A12 A13 A14 A15 B6 B7 C3 H0 I0 H1 I1 J0 K0 L0 M0 N0 O0 P0 Q0 R0 S0 T0 A16 A17 A18 A19 B8 B9 C4 D2 E2 F2 G2 A20 A21 A22 A23 B10 B11 C5 D3 E3 F3 G3 A24 A25 A26 A27 B12 B13 C6 A28 A29 A30 A31 B14 B15 C7]
set bottom_layers [list M5 M7 M9]
set bottom_edge 3
set bottom_offset_start 2
set bottom_offset_end 2

place_pins $bottom_scheme $bottom_layers $bottom_edge $bottom_offset_start $bottom_offset_end counterclockwise


#- Left side (from top to bottom)
############

set A [list gcu_mng_*_i*                                no              no       no]
set B [list sw_*                                        doublebus       dec      pins_exception]
set C [list nw_*                                        doublebus       dec      pins_exception]
set D [list *gcu_pt_*_l                                 no              no       no]
set tempA [list DFT_sdi_*                               no              no       no]
set tempB [list scan_en                                 no              no       no]
set tempC [list shift_en                                no              no       no]
set E [list dl_east_ingress_*_l_0*                      no              no       no]
set F [list dl_west_egress_*_l_0*                       no              no       no]
set G [list gmu_tor_rsp_west_egress*_l_1                doublebus       dec      no]
set H [list gmu_tor_rsp_east_ingress*_l_1               doublebus       dec      no]
set I [list gmu_tor_req_west_egress*_l_1                doublebus       dec      no]
set J [list gmu_tor_req_east_ingress*_l_1               doublebus       dec      no]
set K [list gmu_tor_rsp_west_egress*_l_0                doublebus       dec      no]
set L [list gmu_tor_rsp_east_ingress*_l_0               doublebus       dec      no]
set M [list gmu_tor_req_west_egress*_l_0                doublebus       dec      no]
set N [list gmu_tor_req_east_ingress*_l_0               doublebus       dec      no]
set O [list {cfg_p_*_l\[*}                              no              no       no]
set P [list gmu_mng_*_i*                                no              no       no]
set Q [list dl_east_ingress_*_l_1*                      no              no       no]
set R [list dl_west_egress_*_l_1*                       no              no       no]
set S [list dft_grid_cluster_cfg_*_l*                   no              no       no]
set T [list dft_grid_*edt_*_l*                          no              no       no]
set U [list ijtag_reset                                 no              no       no]
set V [list ijtag_sel                                   no              no       no]
set W [list ijtag_si                                    no              no       no]
set X [list dft_grid_cluster_ijtag_rvrs_data_l*         no              no       no]
set Y [list bisr_mem_chain_select                       no              no       no]
set Z [list bisr_mem_disable                            no              no       no]
set AA [list bisr_reset                                 no              no       no]
set AB [list bisr_si                                    no              no       no]
set AC [list dft_grid_cluster_bisr_rvrs_data_l*         no              no       no]
set AD [list gsu_mng_*_i*                               no              no       no]
set AE [list wr_master_i_credit*                        doublebus       dec      pins_exception]
set AF [list direct_ing_fe*                             doublebus       dec      pins_exception]
set AG [list tor_data_west_egress_*_l                   doublebus       dec      pins_exception]
set AH [list tor_data_east_ingress_*_l                  doublebus       dec      pins_exception]
set AI [list qt_master_w_i_dcid*                        doublebus       dec      pins_exception]
set AJ [list qt_master_w_o_dcid*                        doublebus       dec      pins_exception]
set AK [list tor_fctl_west_egress_*_l                   doublebus       dec      pins_exception]
set AL [list tor_fctl_east_ingress_*_l                  doublebus       dec      pins_exception]

set left_scheme_part1 [list \
                     A0  B0   C0   B1   C1   B2   C2   B3   C3   B4   C4   B5   C5   B6   C6   B7   C7   B8   C8   B9   C9   \
	             B10  C10  B11  C11  B12  C12  B13  C13  B14  C14  B15  C15  B16  C16  B17  C17  B18  C18  B19  C19  \
	             B20  C20  B21  C21  B22  C22  B23  C23  B24  C24  B25  C25  B26  C26  B27  C27]
		    
set left_scheme_part2 [list \
		     B28  C28  B29  C29  \
	             B30  C30  B31  C31  B32  C32  B33  C33  B34  C34  B35  C35  B36  C36  B37  C37  B38  C38  B39  C39  \
	             B40  C40  B41  C41  B42  C42  B43  C43  B44  C44  B45  C45  B46  C46  B47  C47  B48  C48  B49  C49  \
	             B50  C50  B51  C51  B52  C52  B53  C53  B54  C54  B55  C55  B56  C56  B57  C57  B58  C58  B59  C59  \
	             B60  C60  B61  C61  B62  C62  B63  C63]
		    
set left_scheme_part3 [list \
	        D0   B64  C64  B65  C65  B66  C66  B67  C67  B68  C68  B69  C69  \
	             B70  C70  B71  C71  B72  C72  B73  C73  B74  C74  B75  C75  B76  C76  B77  C77  B78  C78  B79  C79  \
	             B80  C80  B81  C81  B82  C82  B83  C83  B84  C84  B85  C85  B86  C86  B87  C87  B88  C88  B89  C89  \
	             B90  C90  B91  C91  B92  C92  B93  C93  B94  C94  B95  C95  B96  C96  B97  C97  B98  C98  B99  C99  \
	             B100 C100 B101 C101 B102 C102 B103 C103 B104 C104 B105 C105 B106 C106 B107 C107]
		    
		    
set left_scheme_part4 [list \
		     B108 C108 B109 C109 B110 C110 B111 C111 B112 C112 B113 C113 B114 C114 B115 C115]

# Cadence inserted DFT
set left_scheme_part_tempA [list tempA0 tempB0 tempC0]

set left_scheme_part5 [list \
                     E0 F0]

set left_scheme_part6 [list \
		     G0 H0 G1 H1 G2 H2 G3 H3 G4 H4 G5 H5 \
		     O0 \
		     I0 J0 I1 J1 I2 J2 I3 J3 I4 J4 I5 J5 \
		     K0 L0 K1 L1 K2 L2 \
		     P0 \
		     K3 L3 K4 L4 K5 L5 \
		     M0 N0 M1 N1 M2 N2 M3 N3 M4 N4 M5 N5 \
               ]

set left_scheme_part7 [list \
                     Q0 R0 S0 T0 U0 V0 W0 X0 Y0 Z0 AA0 AB0 AC0]

set left_scheme_part8 [list \
		     AD0 \
                     AE0 AE1 AE2 AE3 AE4 AE5 AE6 AE7 AE8 AE9 AE10 AE11 AE12 AE13 AE14 AE15 \
                     AF0 AG0 AH0 AF1 AG1 AH1 AF2 AG2 AH2 AF3 AG3 AH3 AF4 AG4 AH4 AF5 AG5 AH5 \
		     AI0 AJ0 AI1 AJ1 AI2 AJ2 AI3 AJ3 \
                     AF6 AG6 AH6 AF7 AG7 AH7 AK0 AL0 AK1 AL1 AK2 AL2 AK3 AL3 AF8 AG8 AH8 \
               ]

set left_scheme_part9 [list \
                     AF9 AG9 AH9 AF10 AG10 AH10 AF11 AG11 AH11 AF12 AG12 AH12 AF13 AG13 AH13 AF14 AG14 AH14 AF15 AG15 AH15 \
               ]

set left_layers [list M4 M6 M8]

#          Pins scheme             Pins layers    Edge number   Offset start    Offset end     Spread direction
place_pins $left_scheme_part1      $left_layers        0              2             272         counterclockwise
place_pins $left_scheme_part2      $left_layers        0            215               2         counterclockwise
place_pins $left_scheme_part3      $left_layers        0              1               1         counterclockwise
#place_pins $left_scheme_part4      $left_layers        2              1             770         counterclockwise
#place_pins $left_scheme_part_tempA $left_layers        2             48             705         counterclockwise
#place_pins $left_scheme_part5      $left_layers        2            114             645         counterclockwise
#place_pins $left_scheme_part6      $left_layers        2            174             306         counterclockwise
#place_pins $left_scheme_part7      $left_layers        2            512             240         counterclockwise
#place_pins $left_scheme_part8      $left_layers        2            580              90         counterclockwise
#place_pins $left_scheme_part9      $left_layers        2            740               2         counterclockwise

set left_scheme_edge2 [concat $left_scheme_part4 $left_scheme_part_tempA $left_scheme_part5 $left_scheme_part6 $left_scheme_part7 $left_scheme_part8 $left_scheme_part9]

place_pins $left_scheme_edge2      $left_layers        0              1                1         counterclockwise

#- Right side (from top to bottom)
############

set A [list gcu_mng_*_o*                                no              no       no]
set B [list se_*                                        doublebus       dec      pins_exception]
set C [list ne_*                                        doublebus       dec      pins_exception]
set D [list *gcu_pt_*_r                                 no              no       no]
set tempA [list DFT_sdo_*                               no              no       no]
#set tempB [list scan_en                                 no              no       no]
#set tempC [list shift_en                                no              no       no]
set E [list dl_east_egress_*_r_0*                       no              no       no]
set F [list dl_west_ingress_*_r_0*                      no              no       no]
set G [list gmu_tor_rsp_west_ingress*_r_1               doublebus       dec      no]
set H [list gmu_tor_rsp_east_egress*_r_1                doublebus       dec      no]
set I [list gmu_tor_req_west_ingress*_r_1               doublebus       dec      no]
set J [list gmu_tor_req_east_egress*_r_1                doublebus       dec      no]
set K [list gmu_tor_rsp_west_ingress*_r_0               doublebus       dec      no]
set L [list gmu_tor_rsp_east_egress*_r_0                doublebus       dec      no]
set M [list gmu_tor_req_west_ingress*_r_0               doublebus       dec      no]
set N [list gmu_tor_req_east_egress*_r_0                doublebus       dec      no]
set O [list {cfg_p_*_r\[*}                              no              no       no]
set P [list gmu_mng_*_o*                                no              no       no]
set Q [list dl_east_egress_*_r_1*                       no              no       no]
set R [list dl_west_ingress_*_r_1*                      no              no       no]
set S [list dft_grid_cluster_cfg_*_r*                   no              no       no]
set T [list dft_grid_*edt_*_r*                          no              no       no]
set U [list ijtag_reset_r                               no              no       no]
set V [list ijtag_sel_r                                 no              no       no]
set W [list ijtag_so                                    no              no       no]
set X [list dft_grid_cluster_ijtag_rvrs_data_r*         no              no       no]
set Y [list bisr_mem_chain_select_r                     no              no       no]
set Z [list bisr_mem_disable_r                          no              no       no]
set AA [list bisr_reset_r                               no              no       no]
set AB [list bisr_so                                    no              no       no]
set AC [list dft_grid_cluster_bisr_rvrs_data_r*         no              no       no]
set AD [list gsu_mng_*_o*                               no              no       no]
set AE [list wr_master_o_credit*                        doublebus       dec      pins_exception]
set AF [list direct_egr_fe*                             doublebus       dec      pins_exception]
set AG [list tor_data_west_ingress_*_r                  doublebus       dec      pins_exception]
set AH [list tor_data_east_egress_*_r                   doublebus       dec      pins_exception]
set AI [list qt_master_e_o_dcid*                        doublebus       dec      pins_exception]
set AJ [list qt_master_e_i_dcid*                        doublebus       dec      pins_exception]
set AK [list tor_fctl_west_ingress_*_r                  doublebus       dec      pins_exception]
set AL [list tor_fctl_east_egress_*_r                   doublebus       dec      pins_exception]

set right_scheme_part1 [list \
                     A0  B0   C0   B1   C1   B2   C2   B3   C3   B4   C4   B5   C5   B6   C6   B7   C7   B8   C8   B9   C9   \
	             B10  C10  B11  C11  B12  C12  B13  C13  B14  C14  B15  C15  B16  C16  B17  C17  B18  C18  B19  C19  \
	             B20  C20  B21  C21  B22  C22  B23  C23  B24  C24  B25  C25  B26  C26  B27  C27]
		    
set right_scheme_part2 [list \
		     B28  C28  B29  C29  \
	             B30  C30  B31  C31  B32  C32  B33  C33  B34  C34  B35  C35  B36  C36  B37  C37  B38  C38  B39  C39  \
	             B40  C40  B41  C41  B42  C42  B43  C43  B44  C44  B45  C45  B46  C46  B47  C47  B48  C48  B49  C49  \
	             B50  C50  B51  C51  B52  C52  B53  C53  B54  C54  B55  C55  B56  C56  B57  C57  B58  C58  B59  C59  \
	             B60  C60  B61  C61  B62  C62  B63  C63]
		    
set right_scheme_part3 [list \
	        D0   B64  C64  B65  C65  B66  C66  B67  C67  B68  C68  B69  C69  \
	             B70  C70  B71  C71  B72  C72  B73  C73  B74  C74  B75  C75  B76  C76  B77  C77  B78  C78  B79  C79  \
	             B80  C80  B81  C81  B82  C82  B83  C83  B84  C84  B85  C85  B86  C86  B87  C87  B88  C88  B89  C89  \
	             B90  C90  B91  C91  B92  C92  B93  C93  B94  C94  B95  C95  B96  C96  B97  C97  B98  C98  B99  C99  \
	             B100 C100 B101 C101 B102 C102 B103 C103 B104 C104 B105 C105 B106 C106 B107 C107]
		    
		    
set right_scheme_part4 [list \
		     B108 C108 B109 C109 B110 C110 B111 C111 B112 C112 B113 C113 B114 C114 B115 C115]

# Cadence inserted DFT
set right_scheme_part_tempA [list tempA0]

set right_scheme_part5 [list \
                     E0 F0]

set right_scheme_part6 [list \
		     G0 H0 G1 H1 G2 H2 G3 H3 G4 H4 G5 H5 \
		     O0 \
		     I0 J0 I1 J1 I2 J2 I3 J3 I4 J4 I5 J5 \
		     K0 L0 K1 L1 K2 L2 \
		     P0 \
		     K3 L3 K4 L4 K5 L5 \
		     M0 N0 M1 N1 M2 N2 M3 N3 M4 N4 M5 N5 \
               ]

set right_scheme_part7 [list \
                     Q0 R0 S0 T0 U0 V0 W0 X0 Y0 Z0 AA0 AB0 AC0]

set right_scheme_part8 [list \
		     AD0 \
                     AE0 AE1 AE2 AE3 AE4 AE5 AE6 AE7 AE8 AE9 AE10 AE11 AE12 AE13 AE14 AE15 \
                     AF0 AG0 AH0 AF1 AG1 AH1 AF2 AG2 AH2 AF3 AG3 AH3 AF4 AG4 AH4 AF5 AG5 AH5 \
		     AI0 AJ0 AI1 AJ1 AI2 AJ2 AI3 AJ3 \
                     AF6 AG6 AH6 AF7 AG7 AH7 AK0 AL0 AK1 AL1 AK2 AL2 AK3 AL3 AF8 AG8 AH8 \
               ]

set right_scheme_part9 [list \
                     AF9 AG9 AH9 AF10 AG10 AH10 AF11 AG11 AH11 AF12 AG12 AH12 AF13 AG13 AH13 AF14 AG14 AH14 AF15 AG15 AH15 \
               ]

set right_layers [list M4 M6 M8]

#          Pins scheme              Pins layers      Edge number     Offset start  Offset end       Spread direction
place_pins $right_scheme_part1      $right_layers        2              2             272          counterclockwise
place_pins $right_scheme_part2      $right_layers        2            215               2          counterclockwise
place_pins $right_scheme_part3      $right_layers        2              1               1          counterclockwise
#place_pins $right_scheme_part4      $right_layers        24              1             770          counterclockwise
#place_pins $right_scheme_part_tempA $right_layers        24             48             705          counterclockwise
#place_pins $right_scheme_part5      $right_layers        24            114             645          counterclockwise
#place_pins $right_scheme_part6      $right_layers        24            174             306          counterclockwise
#place_pins $right_scheme_part7      $right_layers        24            512             240          counterclockwise
#place_pins $right_scheme_part8      $right_layers        24            580              90          counterclockwise
#place_pins $right_scheme_part9      $right_layers        24            740               2          counterclockwise

set right_scheme_edge24 [concat $right_scheme_part4 $right_scheme_part_tempA $right_scheme_part5 $right_scheme_part6 $right_scheme_part7 $right_scheme_part8 $right_scheme_part9]

place_pins $right_scheme_edge24     $right_layers         2             1                1          counterclockwise
