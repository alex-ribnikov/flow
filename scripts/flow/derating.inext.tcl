############################################################################################################
# OR YAGEV - Added ff 720 125 to vt and temperature arrays for NXT 008 using ff 825 125 numbers
# OR YAGEV - Added ss 670 125 to vt and temperature arrays for NXT 008 using ss 675 125 numbers
# TODO - Once BRCM give full data - update this
############################################################################################################

global delta_voltage_derate_tt delta_voltage_derate_ff delta_temperature_derate
global extra_setup_clock_derate_early extra_setup_clock_derate_late extra_setup_data_derate_late extra_hold_clock_derate_early extra_hold_data_derate_early extra_hold_clock_derate_late
global extra_memory_min_derate extra_memory_max_derate extra_ip_min_derate extra_ip_max_derate
global extra_memory_setup_margin extra_memory_hold_margin extra_ip_setup_margin extra_ip_hold_margin

# Delta voltage for timing derate (mV)
# Possible values for slow corners 3.4, 6.8, 10.1, 13.5, 16.9, 33.8, 50.6, 67.5
# Possible values for typical corners 3.8, 7.5, 11.3, 15.0, 18.8, 37.5, 56.3, 75.0
# Possible values for fast corners 3.7, 7.5, 11.2, 15.0, 18.7, 37.5, 56.2, 75.0
set delta_voltage_derate_ss 10.1
set delta_voltage_derate_tt 18.8
set delta_voltage_derate_ff 18.7

# Delta temperature for timing derate (degre)
# It must be a multiple of 10.
set delta_temperature_derate 20

# Add extra derating on clock paths
set extra_setup_clock_derate_early -0.02
set extra_setup_clock_derate_late 0.02
set extra_setup_data_derate_late 0.00
set extra_hold_clock_derate_early -0.03
set extra_hold_data_derate_early -0.03
set extra_hold_clock_derate_late 0.03

# Add extra derating on memory cell delay (signoff model)
set extra_memory_min_derate -0.03
set extra_memory_max_derate 0.05

# Add extra derating on IP cell delay (signoff model)
set extra_ip_min_derate 0.00
set extra_ip_max_derate 0.00

# Add extra margin (ns) for memories (signoff model + MBIST)
set extra_memory_setup_margin [expr 0.020 + 0.030]
set extra_memory_hold_margin [expr 0.010 + 0.015]

# Add extra margin (ns) for IPs (signoff model)
set extra_ip_setup_margin 0.00
set extra_ip_hold_margin 0.00

##############################################################################



# Add VT derates
proc add_vt_derates {delayCorner} {
  global delta_voltage_derate_ss delta_voltage_derate_tt delta_voltage_derate_ff delta_temperature_derate
  set flag 0
  # 
  # set_timing_derate -cell_delay -add <V & T flat OCV>
  #
  # lookup table for VT derating values
  # (taken from TSMC signoff document)
  # -----------------------------------
  array set user_voltage_derate {
    ssgnp_0p675v_m40c,8,svt,3.4   0.017     ssgnp_0p675v_m40c,8,svt,6.8   0.033     ssgnp_0p675v_m40c,8,svt,10.1   0.048     ssgnp_0p675v_m40c,8,svt,13.5   0.064     ssgnp_0p675v_m40c,8,svt,16.9   0.079     ssgnp_0p675v_m40c,8,svt,33.8   0.145     ssgnp_0p675v_m40c,8,svt,50.6   0.202     ssgnp_0p675v_m40c,8,svt,67.5   0.252 
    ssgnp_0p675v_m40c,8,lvt,3.4   0.012     ssgnp_0p675v_m40c,8,lvt,6.8   0.023     ssgnp_0p675v_m40c,8,lvt,10.1   0.034     ssgnp_0p675v_m40c,8,lvt,13.5   0.044     ssgnp_0p675v_m40c,8,lvt,16.9   0.054     ssgnp_0p675v_m40c,8,lvt,33.8   0.103     ssgnp_0p675v_m40c,8,lvt,50.6   0.145     ssgnp_0p675v_m40c,8,lvt,67.5   0.183 
    ssgnp_0p675v_m40c,8,ulvt,3.4  0.009     ssgnp_0p675v_m40c,8,ulvt,6.8  0.017     ssgnp_0p675v_m40c,8,ulvt,10.1  0.026     ssgnp_0p675v_m40c,8,ulvt,13.5  0.034     ssgnp_0p675v_m40c,8,ulvt,16.9  0.042     ssgnp_0p675v_m40c,8,ulvt,33.8  0.079     ssgnp_0p675v_m40c,8,ulvt,50.6  0.113     ssgnp_0p675v_m40c,8,ulvt,67.5  0.143

    ssgnp_0p675v_0c,8,svt,3.4     0.016     ssgnp_0p675v_0c,8,svt,6.8     0.031     ssgnp_0p675v_0c,8,svt,10.1     0.045     ssgnp_0p675v_0c,8,svt,13.5     0.059     ssgnp_0p675v_0c,8,svt,16.9     0.073     ssgnp_0p675v_0c,8,svt,33.8     0.136     ssgnp_0p675v_0c,8,svt,50.6     0.190     ssgnp_0p675v_0c,8,svt,67.5     0.237 
    ssgnp_0p675v_0c,8,lvt,3.4     0.011     ssgnp_0p675v_0c,8,lvt,6.8     0.021     ssgnp_0p675v_0c,8,lvt,10.1     0.032     ssgnp_0p675v_0c,8,lvt,13.5     0.042     ssgnp_0p675v_0c,8,lvt,16.9     0.051     ssgnp_0p675v_0c,8,lvt,33.8     0.097     ssgnp_0p675v_0c,8,lvt,50.6     0.137     ssgnp_0p675v_0c,8,lvt,67.5     0.174 
    ssgnp_0p675v_0c,8,ulvt,3.4    0.008     ssgnp_0p675v_0c,8,ulvt,6.8    0.016     ssgnp_0p675v_0c,8,ulvt,10.1    0.024     ssgnp_0p675v_0c,8,ulvt,13.5    0.032     ssgnp_0p675v_0c,8,ulvt,16.9    0.039     ssgnp_0p675v_0c,8,ulvt,33.8    0.075     ssgnp_0p675v_0c,8,ulvt,50.6    0.107     ssgnp_0p675v_0c,8,ulvt,67.5    0.136 

    ssgnp_0p675v_125c,8,svt,3.4   0.012     ssgnp_0p675v_125c,8,svt,6.8   0.024     ssgnp_0p675v_125c,8,svt,10.1   0.036     ssgnp_0p675v_125c,8,svt,13.5   0.047     ssgnp_0p675v_125c,8,svt,16.9   0.058     ssgnp_0p675v_125c,8,svt,33.8   0.109     ssgnp_0p675v_125c,8,svt,50.6   0.155     ssgnp_0p675v_125c,8,svt,67.5   0.196 
    ssgnp_0p675v_125c,8,lvt,3.4   0.009     ssgnp_0p675v_125c,8,lvt,6.8   0.018     ssgnp_0p675v_125c,8,lvt,10.1   0.026     ssgnp_0p675v_125c,8,lvt,13.5   0.034     ssgnp_0p675v_125c,8,lvt,16.9   0.042     ssgnp_0p675v_125c,8,lvt,33.8   0.080     ssgnp_0p675v_125c,8,lvt,50.6   0.115     ssgnp_0p675v_125c,8,lvt,67.5   0.146 
    ssgnp_0p675v_125c,8,ulvt,3.4  0.007     ssgnp_0p675v_125c,8,ulvt,6.8  0.013     ssgnp_0p675v_125c,8,ulvt,10.1  0.020     ssgnp_0p675v_125c,8,ulvt,13.5  0.026     ssgnp_0p675v_125c,8,ulvt,16.9  0.032     ssgnp_0p675v_125c,8,ulvt,33.8  0.062     ssgnp_0p675v_125c,8,ulvt,50.6  0.089     ssgnp_0p675v_125c,8,ulvt,67.5  0.113 

    tt_0p75_85c,8,svt,3.8         0.010     tt_0p75_85c,8,svt,7.5         0.019     tt_0p75_85c,8,svt,11.3         0.029     tt_0p75_85c,8,svt,15.0         0.039     tt_0p75_85c,8,svt,18.8         0.048     tt_0p75_85c,8,svt,37.5         0.097     tt_0p75_85c,8,svt,56.3         0.146     tt_0p75_85c,8,svt,75.0         0.195 
    tt_0p75_85c,8,lvt,3.8         0.007     tt_0p75_85c,8,lvt,7.5         0.014     tt_0p75_85c,8,lvt,11.3         0.021     tt_0p75_85c,8,lvt,15.0         0.028     tt_0p75_85c,8,lvt,18.8         0.036     tt_0p75_85c,8,lvt,37.5         0.071     tt_0p75_85c,8,lvt,56.3         0.107     tt_0p75_85c,8,lvt,75.0         0.144 
    tt_0p75_85c,8,ulvt,3.8        0.006     tt_0p75_85c,8,ulvt,7.5        0.011     tt_0p75_85c,8,ulvt,11.3        0.017     tt_0p75_85c,8,ulvt,15.0        0.022     tt_0p75_85c,8,ulvt,18.8        0.028     tt_0p75_85c,8,ulvt,37.5        0.055     tt_0p75_85c,8,ulvt,56.3        0.083     tt_0p75_85c,8,ulvt,75.0        0.110 

    tt_0p75_25c,8,svt,3.8         0.011     tt_0p75_25c,8,svt,7.5         0.021     tt_0p75_25c,8,svt,11.3         0.032     tt_0p75_25c,8,svt,15.0         0.042     tt_0p75_25c,8,svt,18.8         0.053     tt_0p75_25c,8,svt,37.5         0.105     tt_0p75_25c,8,svt,56.3         0.159     tt_0p75_25c,8,svt,75.0         0.213 
    tt_0p75_25c,8,lvt,3.8         0.008     tt_0p75_25c,8,lvt,7.5         0.015     tt_0p75_25c,8,lvt,11.3         0.023     tt_0p75_25c,8,lvt,15.0         0.031     tt_0p75_25c,8,lvt,18.8         0.039     tt_0p75_25c,8,lvt,37.5         0.077     tt_0p75_25c,8,lvt,56.3         0.116     tt_0p75_25c,8,lvt,75.0         0.155 
    tt_0p75_25c,8,ulvt,3.8        0.006     tt_0p75_25c,8,ulvt,7.5        0.012     tt_0p75_25c,8,ulvt,11.3        0.018     tt_0p75_25c,8,ulvt,15.0        0.024     tt_0p75_25c,8,ulvt,18.8        0.030     tt_0p75_25c,8,ulvt,37.5        0.060     tt_0p75_25c,8,ulvt,56.3        0.090     tt_0p75_25c,8,ulvt,75.0        0.120 

    ffgnp_0p825v_m40c,8,svt,3.7   0.007     ffgnp_0p825v_m40c,8,svt,7.5   0.015     ffgnp_0p825v_m40c,8,svt,11.2   0.023     ffgnp_0p825v_m40c,8,svt,15.0   0.030     ffgnp_0p825v_m40c,8,svt,18.7   0.038     ffgnp_0p825v_m40c,8,svt,37.5   0.081     ffgnp_0p825v_m40c,8,svt,56.2   0.129     ffgnp_0p825v_m40c,8,svt,75.0   0.183 
    ffgnp_0p825v_m40c,8,lvt,3.7   0.005     ffgnp_0p825v_m40c,8,lvt,7.5   0.011     ffgnp_0p825v_m40c,8,lvt,11.2   0.017     ffgnp_0p825v_m40c,8,lvt,15.0   0.023     ffgnp_0p825v_m40c,8,lvt,18.7   0.029     ffgnp_0p825v_m40c,8,lvt,37.5   0.060     ffgnp_0p825v_m40c,8,lvt,56.2   0.095     ffgnp_0p825v_m40c,8,lvt,75.0   0.134 
    ffgnp_0p825v_m40c,8,ulvt,3.7  0.004     ffgnp_0p825v_m40c,8,ulvt,7.5  0.009     ffgnp_0p825v_m40c,8,ulvt,11.2  0.013     ffgnp_0p825v_m40c,8,ulvt,15.0  0.018     ffgnp_0p825v_m40c,8,ulvt,18.7  0.023     ffgnp_0p825v_m40c,8,ulvt,37.5  0.048     ffgnp_0p825v_m40c,8,ulvt,56.2  0.075     ffgnp_0p825v_m40c,8,ulvt,75.0  0.106 

    ffgnp_0p825v_0c,8,svt,3.7     0.007     ffgnp_0p825v_0c,8,svt,7.5     0.014     ffgnp_0p825v_0c,8,svt,11.2     0.022     ffgnp_0p825v_0c,8,svt,15.0     0.029     ffgnp_0p825v_0c,8,svt,18.7     0.037     ffgnp_0p825v_0c,8,svt,37.5     0.078     ffgnp_0p825v_0c,8,svt,56.2     0.124     ffgnp_0p825v_0c,8,svt,75.0     0.175 
    ffgnp_0p825v_0c,8,lvt,3.7     0.005     ffgnp_0p825v_0c,8,lvt,7.5     0.011     ffgnp_0p825v_0c,8,lvt,11.2     0.016     ffgnp_0p825v_0c,8,lvt,15.0     0.022     ffgnp_0p825v_0c,8,lvt,18.7     0.027     ffgnp_0p825v_0c,8,lvt,37.5     0.058     ffgnp_0p825v_0c,8,lvt,56.2     0.091     ffgnp_0p825v_0c,8,lvt,75.0     0.129 
    ffgnp_0p825v_0c,8,ulvt,3.7    0.004     ffgnp_0p825v_0c,8,ulvt,7.5    0.009     ffgnp_0p825v_0c,8,ulvt,11.2    0.013     ffgnp_0p825v_0c,8,ulvt,15.0    0.017     ffgnp_0p825v_0c,8,ulvt,18.7    0.022     ffgnp_0p825v_0c,8,ulvt,37.5    0.046     ffgnp_0p825v_0c,8,ulvt,56.2    0.072     ffgnp_0p825v_0c,8,ulvt,75.0    0.100 

    ffgnp_0p825v_125c,8,svt,3.7   0.006     ffgnp_0p825v_125c,8,svt,7.5   0.013     ffgnp_0p825v_125c,8,svt,11.2   0.019     ffgnp_0p825v_125c,8,svt,15.0   0.026     ffgnp_0p825v_125c,8,svt,18.7   0.032     ffgnp_0p825v_125c,8,svt,37.5   0.068     ffgnp_0p825v_125c,8,svt,56.2   0.106     ffgnp_0p825v_125c,8,svt,75.0   0.150 
    ffgnp_0p825v_125c,8,lvt,3.7   0.005     ffgnp_0p825v_125c,8,lvt,7.5   0.009     ffgnp_0p825v_125c,8,lvt,11.2   0.014     ffgnp_0p825v_125c,8,lvt,15.0   0.019     ffgnp_0p825v_125c,8,lvt,18.7   0.024     ffgnp_0p825v_125c,8,lvt,37.5   0.050     ffgnp_0p825v_125c,8,lvt,56.2   0.079     ffgnp_0p825v_125c,8,lvt,75.0   0.111 
    ffgnp_0p825v_125c,8,ulvt,3.7  0.004     ffgnp_0p825v_125c,8,ulvt,7.5  0.007     ffgnp_0p825v_125c,8,ulvt,11.2  0.011     ffgnp_0p825v_125c,8,ulvt,15.0  0.015     ffgnp_0p825v_125c,8,ulvt,18.7  0.019     ffgnp_0p825v_125c,8,ulvt,37.5  0.039     ffgnp_0p825v_125c,8,ulvt,56.2  0.062     ffgnp_0p825v_125c,8,ulvt,75.0  0.086 

    ssgnp_0p675v_m40c,11,svt,3.4  0.018     ssgnp_0p675v_m40c,11,svt,6.8  0.035     ssgnp_0p675v_m40c,11,svt,10.1  0.052     ssgnp_0p675v_m40c,11,svt,13.5  0.068     ssgnp_0p675v_m40c,11,svt,16.9  0.084     ssgnp_0p675v_m40c,11,svt,33.8  0.154     ssgnp_0p675v_m40c,11,svt,50.6  0.214     ssgnp_0p675v_m40c,11,svt,67.5  0.266 
    ssgnp_0p675v_m40c,11,lvt,3.4  0.013     ssgnp_0p675v_m40c,11,lvt,6.8  0.025     ssgnp_0p675v_m40c,11,lvt,10.1  0.036     ssgnp_0p675v_m40c,11,lvt,13.5  0.048     ssgnp_0p675v_m40c,11,lvt,16.9  0.059     ssgnp_0p675v_m40c,11,lvt,33.8  0.110     ssgnp_0p675v_m40c,11,lvt,50.6  0.155     ssgnp_0p675v_m40c,11,lvt,67.5  0.196 
    ssgnp_0p675v_m40c,11,ulvt,3.4 0.010     ssgnp_0p675v_m40c,11,ulvt,6.8 0.019     ssgnp_0p675v_m40c,11,ulvt,10.1 0.028     ssgnp_0p675v_m40c,11,ulvt,13.5 0.036     ssgnp_0p675v_m40c,11,ulvt,16.9 0.045     ssgnp_0p675v_m40c,11,ulvt,33.8 0.085     ssgnp_0p675v_m40c,11,ulvt,50.6 0.121     ssgnp_0p675v_m40c,11,ulvt,67.5 0.154

    ssgnp_0p675v_0c,11,svt,3.4    0.017     ssgnp_0p675v_0c,11,svt,6.8    0.033     ssgnp_0p675v_0c,11,svt,10.1    0.048     ssgnp_0p675v_0c,11,svt,13.5    0.063     ssgnp_0p675v_0c,11,svt,16.9    0.077     ssgnp_0p675v_0c,11,svt,33.8    0.144     ssgnp_0p675v_0c,11,svt,50.6    0.200     ssgnp_0p675v_0c,11,svt,67.5    0.250 
    ssgnp_0p675v_0c,11,lvt,3.4    0.012     ssgnp_0p675v_0c,11,lvt,6.8    0.023     ssgnp_0p675v_0c,11,lvt,10.1    0.034     ssgnp_0p675v_0c,11,lvt,13.5    0.045     ssgnp_0p675v_0c,11,lvt,16.9    0.055     ssgnp_0p675v_0c,11,lvt,33.8    0.104     ssgnp_0p675v_0c,11,lvt,50.6    0.147     ssgnp_0p675v_0c,11,lvt,67.5    0.185 
    ssgnp_0p675v_0c,11,ulvt,3.4   0.009     ssgnp_0p675v_0c,11,ulvt,6.8   0.018     ssgnp_0p675v_0c,11,ulvt,10.1   0.026     ssgnp_0p675v_0c,11,ulvt,13.5   0.034     ssgnp_0p675v_0c,11,ulvt,16.9   0.043     ssgnp_0p675v_0c,11,ulvt,33.8   0.081     ssgnp_0p675v_0c,11,ulvt,50.6   0.115     ssgnp_0p675v_0c,11,ulvt,67.5   0.146 

    ssgnp_0p675v_125c,11,svt,3.4  0.013     ssgnp_0p675v_125c,11,svt,6.8  0.026     ssgnp_0p675v_125c,11,svt,10.1  0.037     ssgnp_0p675v_125c,11,svt,13.5  0.049     ssgnp_0p675v_125c,11,svt,16.9  0.061     ssgnp_0p675v_125c,11,svt,33.8  0.115     ssgnp_0p675v_125c,11,svt,50.6  0.162     ssgnp_0p675v_125c,11,svt,67.5  0.205 
    ssgnp_0p675v_125c,11,lvt,3.4  0.009     ssgnp_0p675v_125c,11,lvt,6.8  0.019     ssgnp_0p675v_125c,11,lvt,10.1  0.028     ssgnp_0p675v_125c,11,lvt,13.5  0.036     ssgnp_0p675v_125c,11,lvt,16.9  0.045     ssgnp_0p675v_125c,11,lvt,33.8  0.086     ssgnp_0p675v_125c,11,lvt,50.6  0.122     ssgnp_0p675v_125c,11,lvt,67.5  0.155 
    ssgnp_0p675v_125c,11,ulvt,3.4 0.007     ssgnp_0p675v_125c,11,ulvt,6.8 0.014     ssgnp_0p675v_125c,11,ulvt,10.1 0.021     ssgnp_0p675v_125c,11,ulvt,13.5 0.028     ssgnp_0p675v_125c,11,ulvt,16.9 0.035     ssgnp_0p675v_125c,11,ulvt,33.8 0.067     ssgnp_0p675v_125c,11,ulvt,50.6 0.096     ssgnp_0p675v_125c,11,ulvt,67.5 0.123 

    tt_0p75_85c,11,svt,3.8        0.010     tt_0p75_85c,11,svt,7.5        0.020     tt_0p75_85c,11,svt,11.3        0.031     tt_0p75_85c,11,svt,15.0        0.041     tt_0p75_85c,11,svt,18.8        0.051     tt_0p75_85c,11,svt,37.5        0.102     tt_0p75_85c,11,svt,56.3        0.154     tt_0p75_85c,11,svt,75.0        0.206 
    tt_0p75_85c,11,lvt,3.8        0.008     tt_0p75_85c,11,lvt,7.5        0.015     tt_0p75_85c,11,lvt,11.3        0.023     tt_0p75_85c,11,lvt,15.0        0.030     tt_0p75_85c,11,lvt,18.8        0.038     tt_0p75_85c,11,lvt,37.5        0.076     tt_0p75_85c,11,lvt,56.3        0.115     tt_0p75_85c,11,lvt,75.0        0.154 
    tt_0p75_85c,11,ulvt,3.8       0.006     tt_0p75_85c,11,ulvt,7.5       0.012     tt_0p75_85c,11,ulvt,11.3       0.018     tt_0p75_85c,11,ulvt,15.0       0.024     tt_0p75_85c,11,ulvt,18.8       0.030     tt_0p75_85c,11,ulvt,37.5       0.060     tt_0p75_85c,11,ulvt,56.3       0.091     tt_0p75_85c,11,ulvt,75.0       0.121 

    tt_0p75_25c,11,svt,3.8        0.011     tt_0p75_25c,11,svt,7.5        0.022     tt_0p75_25c,11,svt,11.3        0.033     tt_0p75_25c,11,svt,15.0        0.044     tt_0p75_25c,11,svt,18.8        0.056     tt_0p75_25c,11,svt,37.5        0.111     tt_0p75_25c,11,svt,56.3        0.168     tt_0p75_25c,11,svt,75.0        0.225 
    tt_0p75_25c,11,lvt,3.8        0.008     tt_0p75_25c,11,lvt,7.5        0.016     tt_0p75_25c,11,lvt,11.3        0.025     tt_0p75_25c,11,lvt,15.0        0.033     tt_0p75_25c,11,lvt,18.8        0.041     tt_0p75_25c,11,lvt,37.5        0.083     tt_0p75_25c,11,lvt,56.3        0.125     tt_0p75_25c,11,lvt,75.0        0.167 
    tt_0p75_25c,11,ulvt,3.8       0.007     tt_0p75_25c,11,ulvt,7.5       0.013     tt_0p75_25c,11,ulvt,11.3       0.020     tt_0p75_25c,11,ulvt,15.0       0.026     tt_0p75_25c,11,ulvt,18.8       0.033     tt_0p75_25c,11,ulvt,37.5       0.065     tt_0p75_25c,11,ulvt,56.3       0.098     tt_0p75_25c,11,ulvt,75.0       0.131 

    ffgnp_0p825v_m40c,11,svt,3.7  0.008     ffgnp_0p825v_m40c,11,svt,7.5  0.016     ffgnp_0p825v_m40c,11,svt,11.2  0.024     ffgnp_0p825v_m40c,11,svt,15.0  0.032     ffgnp_0p825v_m40c,11,svt,18.7  0.041     ffgnp_0p825v_m40c,11,svt,37.5  0.086     ffgnp_0p825v_m40c,11,svt,56.2  0.137     ffgnp_0p825v_m40c,11,svt,75.0  0.196 
    ffgnp_0p825v_m40c,11,lvt,3.7  0.006     ffgnp_0p825v_m40c,11,lvt,7.5  0.012     ffgnp_0p825v_m40c,11,lvt,11.2  0.018     ffgnp_0p825v_m40c,11,lvt,15.0  0.025     ffgnp_0p825v_m40c,11,lvt,18.7  0.031     ffgnp_0p825v_m40c,11,lvt,37.5  0.066     ffgnp_0p825v_m40c,11,lvt,56.2  0.104     ffgnp_0p825v_m40c,11,lvt,75.0  0.146 
    ffgnp_0p825v_m40c,11,ulvt,3.7 0.005     ffgnp_0p825v_m40c,11,ulvt,7.5 0.010     ffgnp_0p825v_m40c,11,ulvt,11.2 0.015     ffgnp_0p825v_m40c,11,ulvt,15.0 0.020     ffgnp_0p825v_m40c,11,ulvt,18.7 0.025     ffgnp_0p825v_m40c,11,ulvt,37.5 0.053     ffgnp_0p825v_m40c,11,ulvt,56.2 0.083     ffgnp_0p825v_m40c,11,ulvt,75.0 0.116 

    ffgnp_0p825v_0c,11,svt,3.7    0.007     ffgnp_0p825v_0c,11,svt,7.5    0.015     ffgnp_0p825v_0c,11,svt,11.2    0.023     ffgnp_0p825v_0c,11,svt,15.0    0.031     ffgnp_0p825v_0c,11,svt,18.7    0.039     ffgnp_0p825v_0c,11,svt,37.5    0.083     ffgnp_0p825v_0c,11,svt,56.2    0.132     ffgnp_0p825v_0c,11,svt,75.0    0.187 
    ffgnp_0p825v_0c,11,lvt,3.7    0.006     ffgnp_0p825v_0c,11,lvt,7.5    0.012     ffgnp_0p825v_0c,11,lvt,11.2    0.018     ffgnp_0p825v_0c,11,lvt,15.0    0.024     ffgnp_0p825v_0c,11,lvt,18.7    0.030     ffgnp_0p825v_0c,11,lvt,37.5    0.063     ffgnp_0p825v_0c,11,lvt,56.2    0.099     ffgnp_0p825v_0c,11,lvt,75.0    0.140 
    ffgnp_0p825v_0c,11,ulvt,3.7   0.005     ffgnp_0p825v_0c,11,ulvt,7.5   0.009     ffgnp_0p825v_0c,11,ulvt,11.2   0.014     ffgnp_0p825v_0c,11,ulvt,15.0   0.019     ffgnp_0p825v_0c,11,ulvt,18.7   0.024     ffgnp_0p825v_0c,11,ulvt,37.5   0.050     ffgnp_0p825v_0c,11,ulvt,56.2   0.079     ffgnp_0p825v_0c,11,ulvt,75.0   0.111 

    ffgnp_0p825v_125c,11,svt,3.7  0.006     ffgnp_0p825v_125c,11,svt,7.5  0.013     ffgnp_0p825v_125c,11,svt,11.2  0.020     ffgnp_0p825v_125c,11,svt,15.0  0.027     ffgnp_0p825v_125c,11,svt,18.7  0.034     ffgnp_0p825v_125c,11,svt,37.5  0.071     ffgnp_0p825v_125c,11,svt,56.2  0.113     ffgnp_0p825v_125c,11,svt,75.0  0.159 
    ffgnp_0p825v_125c,11,lvt,3.7  0.005     ffgnp_0p825v_125c,11,lvt,7.5  0.010     ffgnp_0p825v_125c,11,lvt,11.2  0.015     ffgnp_0p825v_125c,11,lvt,15.0  0.021     ffgnp_0p825v_125c,11,lvt,18.7  0.026     ffgnp_0p825v_125c,11,lvt,37.5  0.055     ffgnp_0p825v_125c,11,lvt,56.2  0.086     ffgnp_0p825v_125c,11,lvt,75.0  0.120 
    ffgnp_0p825v_125c,11,ulvt,3.7 0.004     ffgnp_0p825v_125c,11,ulvt,7.5 0.008     ffgnp_0p825v_125c,11,ulvt,11.2 0.012     ffgnp_0p825v_125c,11,ulvt,15.0 0.017     ffgnp_0p825v_125c,11,ulvt,18.7 0.021     ffgnp_0p825v_125c,11,ulvt,37.5 0.044     ffgnp_0p825v_125c,11,ulvt,56.2 0.068     ffgnp_0p825v_125c,11,ulvt,75.0 0.095 

    ffgnp_0p720v_125c,8,svt,3.7   0.006     ffgnp_0p720v_125c,8,svt,7.5   0.013     ffgnp_0p720v_125c,8,svt,11.2   0.019     ffgnp_0p720v_125c,8,svt,15.0   0.026     ffgnp_0p720v_125c,8,svt,18.7   0.032     ffgnp_0p720v_125c,8,svt,37.5   0.068     ffgnp_0p720v_125c,8,svt,56.2   0.106     ffgnp_0p720v_125c,8,svt,75.0   0.150 
    ffgnp_0p720v_125c,8,lvt,3.7   0.005     ffgnp_0p720v_125c,8,lvt,7.5   0.009     ffgnp_0p720v_125c,8,lvt,11.2   0.014     ffgnp_0p720v_125c,8,lvt,15.0   0.019     ffgnp_0p720v_125c,8,lvt,18.7   0.024     ffgnp_0p720v_125c,8,lvt,37.5   0.050     ffgnp_0p720v_125c,8,lvt,56.2   0.079     ffgnp_0p720v_125c,8,lvt,75.0   0.111 
    ffgnp_0p720v_125c,8,ulvt,3.7  0.004     ffgnp_0p720v_125c,8,ulvt,7.5  0.007     ffgnp_0p720v_125c,8,ulvt,11.2  0.011     ffgnp_0p720v_125c,8,ulvt,15.0  0.015     ffgnp_0p720v_125c,8,ulvt,18.7  0.019     ffgnp_0p720v_125c,8,ulvt,37.5  0.039     ffgnp_0p720v_125c,8,ulvt,56.2  0.062     ffgnp_0p720v_125c,8,ulvt,75.0  0.086 

    ffgnp_0p720v_125c,11,svt,3.7  0.006     ffgnp_0p720v_125c,11,svt,7.5  0.013     ffgnp_0p720v_125c,11,svt,11.2  0.020     ffgnp_0p720v_125c,11,svt,15.0  0.027     ffgnp_0p720v_125c,11,svt,18.7  0.034     ffgnp_0p720v_125c,11,svt,37.5  0.071     ffgnp_0p720v_125c,11,svt,56.2  0.113     ffgnp_0p720v_125c,11,svt,75.0  0.159 
    ffgnp_0p720v_125c,11,lvt,3.7  0.005     ffgnp_0p720v_125c,11,lvt,7.5  0.010     ffgnp_0p720v_125c,11,lvt,11.2  0.015     ffgnp_0p720v_125c,11,lvt,15.0  0.021     ffgnp_0p720v_125c,11,lvt,18.7  0.026     ffgnp_0p720v_125c,11,lvt,37.5  0.055     ffgnp_0p720v_125c,11,lvt,56.2  0.086     ffgnp_0p720v_125c,11,lvt,75.0  0.120 
    ffgnp_0p720v_125c,11,ulvt,3.7 0.004     ffgnp_0p720v_125c,11,ulvt,7.5 0.008     ffgnp_0p720v_125c,11,ulvt,11.2 0.012     ffgnp_0p720v_125c,11,ulvt,15.0 0.017     ffgnp_0p720v_125c,11,ulvt,18.7 0.021     ffgnp_0p720v_125c,11,ulvt,37.5 0.044     ffgnp_0p720v_125c,11,ulvt,56.2 0.068     ffgnp_0p720v_125c,11,ulvt,75.0 0.095 
    
    ssgnp_0p670v_125c,8,svt,3.4   0.012     ssgnp_0p670v_125c,8,svt,6.8   0.024     ssgnp_0p670v_125c,8,svt,10.1   0.036     ssgnp_0p670v_125c,8,svt,13.5   0.047     ssgnp_0p670v_125c,8,svt,16.9   0.058     ssgnp_0p670v_125c,8,svt,33.8   0.109     ssgnp_0p670v_125c,8,svt,50.6   0.155     ssgnp_0p670v_125c,8,svt,67.5   0.196 
    ssgnp_0p670v_125c,8,lvt,3.4   0.009     ssgnp_0p670v_125c,8,lvt,6.8   0.018     ssgnp_0p670v_125c,8,lvt,10.1   0.026     ssgnp_0p670v_125c,8,lvt,13.5   0.034     ssgnp_0p670v_125c,8,lvt,16.9   0.042     ssgnp_0p670v_125c,8,lvt,33.8   0.080     ssgnp_0p670v_125c,8,lvt,50.6   0.115     ssgnp_0p670v_125c,8,lvt,67.5   0.146 
    ssgnp_0p670v_125c,8,ulvt,3.4  0.007     ssgnp_0p670v_125c,8,ulvt,6.8  0.013     ssgnp_0p670v_125c,8,ulvt,10.1  0.020     ssgnp_0p670v_125c,8,ulvt,13.5  0.026     ssgnp_0p670v_125c,8,ulvt,16.9  0.032     ssgnp_0p670v_125c,8,ulvt,33.8  0.062     ssgnp_0p670v_125c,8,ulvt,50.6  0.089     ssgnp_0p670v_125c,8,ulvt,67.5  0.113     

    ssgnp_0p670v_125c,11,svt,3.4  0.013     ssgnp_0p670v_125c,11,svt,6.8  0.026     ssgnp_0p670v_125c,11,svt,10.1  0.037     ssgnp_0p670v_125c,11,svt,13.5  0.049     ssgnp_0p670v_125c,11,svt,16.9  0.061     ssgnp_0p670v_125c,11,svt,33.8  0.115     ssgnp_0p670v_125c,11,svt,50.6  0.162     ssgnp_0p670v_125c,11,svt,67.5  0.205 
    ssgnp_0p670v_125c,11,lvt,3.4  0.009     ssgnp_0p670v_125c,11,lvt,6.8  0.019     ssgnp_0p670v_125c,11,lvt,10.1  0.028     ssgnp_0p670v_125c,11,lvt,13.5  0.036     ssgnp_0p670v_125c,11,lvt,16.9  0.045     ssgnp_0p670v_125c,11,lvt,33.8  0.086     ssgnp_0p670v_125c,11,lvt,50.6  0.122     ssgnp_0p670v_125c,11,lvt,67.5  0.155 
    ssgnp_0p670v_125c,11,ulvt,3.4 0.007     ssgnp_0p670v_125c,11,ulvt,6.8 0.014     ssgnp_0p670v_125c,11,ulvt,10.1 0.021     ssgnp_0p670v_125c,11,ulvt,13.5 0.028     ssgnp_0p670v_125c,11,ulvt,16.9 0.035     ssgnp_0p670v_125c,11,ulvt,33.8 0.067     ssgnp_0p670v_125c,11,ulvt,50.6 0.096     ssgnp_0p670v_125c,11,ulvt,67.5 0.123 
  }

  array set user_temperature_derate {
    ssgnp_0p675v_m40c,8,svt,10   0.006
    ssgnp_0p675v_m40c,8,lvt,10   0.002
    ssgnp_0p675v_m40c,8,ulvt,10  0.000

    ssgnp_0p675v_0c,8,svt,10     0.006
    ssgnp_0p675v_0c,8,lvt,10     0.002
    ssgnp_0p675v_0c,8,ulvt,10    0.000

    ssgnp_0p675v_125c,8,svt,10   0.004
    ssgnp_0p675v_125c,8,lvt,10   0.000
    ssgnp_0p675v_125c,8,ulvt,10  0.004

    tt_0p75_85c,8,svt,10         0.001
    tt_0p75_85c,8,lvt,10         0.003
    tt_0p75_85c,8,ulvt,10        0.005

    tt_0p75_25c,8,svt,10         0.000
    tt_0p75_25c,8,lvt,10         0.002
    tt_0p75_25c,8,ulvt,10        0.004

    ffgnp_0p825v_m40c,8,svt,10   0.003
    ffgnp_0p825v_m40c,8,lvt,10   0.004
    ffgnp_0p825v_m40c,8,ulvt,10  0.005

    ffgnp_0p825v_0c,8,svt,10     0.003
    ffgnp_0p825v_0c,8,lvt,10     0.004
    ffgnp_0p825v_0c,8,ulvt,10    0.006

    ffgnp_0p825v_125c,8,svt,10   0.005
    ffgnp_0p825v_125c,8,lvt,10   0.006
    ffgnp_0p825v_125c,8,ulvt,10  0.009

    ssgnp_0p675v_m40c,11,svt,10  0.006
    ssgnp_0p675v_m40c,11,lvt,10  0.002
    ssgnp_0p675v_m40c,11,ulvt,10 0.001

    ssgnp_0p675v_0c,11,svt,10    0.006
    ssgnp_0p675v_0c,11,lvt,10    0.002
    ssgnp_0p675v_0c,11,ulvt,10   0.001

    ssgnp_0p675v_125c,11,svt,10  0.004
    ssgnp_0p675v_125c,11,lvt,10  0.000
    ssgnp_0p675v_125c,11,ulvt,10 0.003

    tt_0p75_85c,11,svt,10        0.001
    tt_0p75_85c,11,lvt,10        0.003
    tt_0p75_85c,11,ulvt,10       0.005

    tt_0p75_25c,11,svt,10        0.000
    tt_0p75_25c,11,lvt,10        0.002
    tt_0p75_25c,11,ulvt,10       0.004

    ffgnp_0p825v_m40c,11,svt,10  0.004
    ffgnp_0p825v_m40c,11,lvt,10  0.005
    ffgnp_0p825v_m40c,11,ulvt,10 0.006

    ffgnp_0p825v_0c,11,svt,10    0.004
    ffgnp_0p825v_0c,11,lvt,10    0.005
    ffgnp_0p825v_0c,11,ulvt,10   0.006

    ffgnp_0p825v_125c,11,svt,10  0.005
    ffgnp_0p825v_125c,11,lvt,10  0.007
    ffgnp_0p825v_125c,11,ulvt,10 0.008
    
    ffgnp_0p720v_125c,8,svt,10   0.005
    ffgnp_0p720v_125c,8,lvt,10   0.006
    ffgnp_0p720v_125c,8,ulvt,10  0.009    
    
    ffgnp_0p720v_125c,11,svt,10  0.005
    ffgnp_0p720v_125c,11,lvt,10  0.007
    ffgnp_0p720v_125c,11,ulvt,10 0.008    

    ssgnp_0p670v_125c,8,svt,10   0.004
    ssgnp_0p670v_125c,8,lvt,10   0.000
    ssgnp_0p670v_125c,8,ulvt,10  0.004

    ssgnp_0p670v_125c,11,svt,10  0.004
    ssgnp_0p670v_125c,11,lvt,10  0.000
    ssgnp_0p670v_125c,11,ulvt,10 0.003
    
  }

  # Set delta volatge
  set delta_v_derate_ss $delta_voltage_derate_ss
  set delta_v_derate_tt $delta_voltage_derate_tt
  set delta_v_derate_ff $delta_voltage_derate_ff

  # Set delta temparature (specify x times 10 degres). For example, 2 means 2*10 degres = 20 degres
  set delta_t_derate    [expr $delta_temperature_derate / 10 ]

  ##################################################
  #
  # WARNING : Use only SS delay corners for setup
  #           For hold, specific hold delay corner should be defined for all SS delay corners (derating applied differently).
  #
  ##################################################

  ##################################################
  # 1. all ss delay corners @ 125 degrees
  ##################################################
  # ssgnp_0p675v_125c

  if {[regexp ssgnp_0p675v_125c $delayCorner]} {
    puts "-I- delayCorner $delayCorner match ss_0p675v_125c"
    set flag 1
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_125c,8,svt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_125c,8,svt,10)]]]   [get_lib_cells *H8P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_125c,8,lvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_125c,8,lvt,10)]]]   [get_lib_cells *H8P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_125c,8,ulvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_125c,8,ulvt,10)]]] [get_lib_cells *H8P57PDULVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_125c,11,svt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_125c,11,svt,10)]]]   [get_lib_cells *H11P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_125c,11,lvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_125c,11,lvt,10)]]]   [get_lib_cells *H11P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_125c,11,ulvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_125c,11,ulvt,10)]]] [get_lib_cells *H11P57PDULVT*] -delay_corner $delayCorner
  }

  if {[regexp ssgnp_0p670v_125c $delayCorner]} {
    puts "-I- delayCorner $delayCorner match ss_0p670v_125c"
    set flag 1
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p670v_125c,8,svt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p670v_125c,8,svt,10)]]]     [get_lib_cells P6S8*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p670v_125c,8,lvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p670v_125c,8,lvt,10)]]]     [get_lib_cells P6L8*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p670v_125c,8,ulvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p670v_125c,8,ulvt,10)]]]   [get_lib_cells P6U8*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p670v_125c,11,svt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p670v_125c,11,svt,10)]]]   [get_lib_cells P6S11*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p670v_125c,11,lvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p670v_125c,11,lvt,10)]]]   [get_lib_cells P6L11*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p670v_125c,11,ulvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p670v_125c,11,ulvt,10)]]] [get_lib_cells P6U11*] -delay_corner $delayCorner
  }
  

  ##################################################
  # 2. all ss delay corners @ 0 degrees
  ##################################################
  # ssgnp_0p675v_0c

  if {[regexp ssgnp_0p675v_0c $delayCorner]} {
    puts "-I- delayCorner $delayCorner match ss_0p675v_0c"
    set flag 1
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_0c,8,svt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_0c,8,svt,10)]]]   [get_lib_cells *H8P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_0c,8,lvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_0c,8,lvt,10)]]]   [get_lib_cells *H8P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_0c,8,ulvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_0c,8,ulvt,10)]]] [get_lib_cells *H8P57PDULVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_0c,11,svt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_0c,11,svt,10)]]]   [get_lib_cells *H11P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_0c,11,lvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_0c,11,lvt,10)]]]   [get_lib_cells *H11P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_0c,11,ulvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_0c,11,ulvt,10)]]] [get_lib_cells *H11P57PDULVT*] -delay_corner $delayCorner
  }

  ##################################################
  # 3. all tt delay corners @ 25 degrees
  ##################################################
  # tt_0p75_25c

  if {[regexp tt_0p75v_25c $delayCorner]} {
    puts "-I- delayCorner $delayCorner match tt_0p75v_25c"
    set flag 1
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_25c,8,svt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_25c,8,svt,10)]]]   [get_lib_cells *H8P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_25c,8,lvt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_25c,8,lvt,10)]]]   [get_lib_cells *H8P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_25c,8,ulvt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_25c,8,ulvt,10)]]] [get_lib_cells *H8P57PDULVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_25c,11,svt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_25c,11,svt,10)]]]   [get_lib_cells *H11P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_25c,11,lvt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_25c,11,lvt,10)]]]   [get_lib_cells *H11P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_25c,11,ulvt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_25c,11,ulvt,10)]]] [get_lib_cells *H11P57PDULVT*] -delay_corner $delayCorner
  }

  ##################################################
  # 4. all tt delay corners @ 85 degrees
  ##################################################
  # tt_0p75_85c

  if {[regexp tt_0p75v_85c $delayCorner]} {
    puts "-I- delayCorner $delayCorner match tt_0p75v_85c"
    set flag 1
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_85c,8,svt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_85c,8,svt,10)]]]   [get_lib_cells *H8P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_85c,8,lvt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_85c,8,lvt,10)]]]   [get_lib_cells *H8P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_85c,8,ulvt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_85c,8,ulvt,10)]]] [get_lib_cells *H8P57PDULVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_85c,11,svt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_85c,11,svt,10)]]]   [get_lib_cells *H11P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_85c,11,lvt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_85c,11,lvt,10)]]]   [get_lib_cells *H11P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_85c,11,ulvt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_85c,11,ulvt,10)]]] [get_lib_cells *H11P57PDULVT*] -delay_corner $delayCorner
  }

  ##################################################
  # 5. all ff delay corners @ 125 degrees
  ##################################################
  # ffgnp_0p825v_125c

  if {[regexp ffgnp_0p825v_125c $delayCorner]} {
    puts "-I- delayCorner $delayCorner match ff_0p825v_125c"
    set flag 1
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_125c,8,svt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_125c,8,svt,10)]]]   [get_lib_cells *H8P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_125c,8,lvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_125c,8,lvt,10)]]]   [get_lib_cells *H8P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_125c,8,ulvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_125c,8,ulvt,10)]]] [get_lib_cells *H8P57PDULVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_125c,11,svt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_125c,11,svt,10)]]]   [get_lib_cells *H11P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_125c,11,lvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_125c,11,lvt,10)]]]   [get_lib_cells *H11P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_125c,11,ulvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_125c,11,ulvt,10)]]] [get_lib_cells *H11P57PDULVT*] -delay_corner $delayCorner
  }
  
  if {[regexp ffgnp_0p720v_125c $delayCorner]} {
    puts "-I- delayCorner $delayCorner match ff_0p720v_125c"
    set flag 1
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p720v_125c,8,svt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p720v_125c,8,svt,10)]]]      [get_lib_cells P6S8*]  -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p720v_125c,8,lvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p720v_125c,8,lvt,10)]]]      [get_lib_cells P6L8*]  -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p720v_125c,8,ulvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p720v_125c,8,ulvt,10)]]]    [get_lib_cells P6U8*]  -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p720v_125c,11,svt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p720v_125c,11,svt,10)]]]    [get_lib_cells P6S11*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p720v_125c,11,lvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p720v_125c,11,lvt,10)]]]    [get_lib_cells P6L11*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p720v_125c,11,ulvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p720v_125c,11,ulvt,10)]]]  [get_lib_cells P6U11*] -delay_corner $delayCorner
  }  

  ##################################################
  # 6. all ff delay corners @ 0 degrees
  ##################################################
  # ffgnp_0p825v_0c

  if {[regexp ffgnp_0p825v_0c $delayCorner]} {
    puts "-I- delayCorner $delayCorner match ff_0p825v_0c"
    set flag 1
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_0c,8,svt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_0c,8,svt,10)]]]   [get_lib_cells *H8P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_0c,8,lvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_0c,8,lvt,10)]]]   [get_lib_cells *H8P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_0c,8,ulvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_0c,8,ulvt,10)]]] [get_lib_cells *H8P57PDULVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_0c,11,svt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_0c,11,svt,10)]]]   [get_lib_cells *H11P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_0c,11,lvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_0c,11,lvt,10)]]]   [get_lib_cells *H11P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_0c,11,ulvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_0c,11,ulvt,10)]]] [get_lib_cells *H11P57PDULVT*] -delay_corner $delayCorner
  }
  if { $flag == 0} {
  	puts "-E- delayCorner $delayCorner does not have any match"
  }
}

# Add extra derates
proc add_extra_derates {delayCorner} {
  global extra_setup_clock_derate_early extra_setup_clock_derate_late extra_setup_data_derate_late extra_hold_clock_derate_early extra_hold_data_derate_early extra_hold_clock_derate_late
  set flag 0
  if {[ regexp {ssgnp[_a-z0-9]+_s} $delayCorner]} {
     puts "-I- delayCorner $delayCorner match ss\[_a-z0-9\]+_setup"
     set flag 1
     set_timing_derate -add -cell_delay -clock -early -delay_corner $delayCorner $extra_setup_clock_derate_early
     set_timing_derate -add -cell_delay -clock -late -delay_corner $delayCorner $extra_setup_clock_derate_late
     set_timing_derate -add -cell_delay -data -late -delay_corner $delayCorner $extra_setup_data_derate_late
  }
  if {[regexp {^ff} $delayCorner] || [regexp {^tt} $delayCorner] || [ regexp {ssgnp[_a-z0-9]+_hold} $delayCorner]} {
     puts "-I- delayCorner $delayCorner match ss\[_a-z0-9\]+_hold or tt or ff"
     set flag 1
     set_timing_derate -add -cell_delay -clock -early -delay_corner $delayCorner $extra_hold_clock_derate_early
     set_timing_derate -add -cell_delay -data -early -delay_corner $delayCorner $extra_hold_data_derate_early
     set_timing_derate -add -cell_delay -clock -late -delay_corner $delayCorner $extra_hold_clock_derate_late
  }
  if { $flag == 0} {
  	puts "-E- delayCorner $delayCorner does not have any match"
  }
}

# Define memories extra derating
proc add_memories_extra_derate {delayCorner} {
  global extra_memory_max_derate extra_memory_min_derate
  foreach _mem [concat [get_db base_cells .base_name sa*] [get_db base_cells .base_name as*]] {
     set flag 0
     if {[ regexp {ssgnp[_a-z0-9]+_setup} $delayCorner]} {
        puts "-I- $_mem delayCorner $delayCorner match ss\[_a-z0-9\]+_setup"
        set flag 1
        set_timing_derate -add -cell_delay -late -delay_corner $delayCorner $extra_memory_max_derate $_mem
     }
     if {[regexp {^ff} $delayCorner] || [regexp {^tt} $delayCorner] || [ regexp {ssgnp[_a-z0-9]+_hold} $delayCorner]} {
        puts "-I-  $_mem delayCorner $delayCorner match ss\[_a-z0-9\]+_hold or tt or ff"
        set flag 1
        set_timing_derate -add -cell_delay -early -delay_corner $delayCorner $extra_memory_min_derate $_mem
     }
     if { $flag == 0} {
  	puts "-E-  $_mem delayCorner $delayCorner does not have any match"
     }
  }
}

# Define memories extra derating - workaround for DSTA CUI
proc add_memories_extra_derate_dsta {delayCorner} {
  global extra_memory_max_derate extra_memory_min_derate
  eval_legacy {
  set _list_mem_cells [open /tmp/list_mem_cells.txt w]
  foreach _mem [concat [dbGet -u head.libCells.name sa*] [dbGet -u head.libCells.name as*]] {
     if { $_mem != 0x0 } {
        puts $_list_mem_cells $_mem
     }
  }
  close $_list_mem_cells
  }
  set _list_mem_cells [open /tmp/list_mem_cells.txt r]
  while {![eof $_list_mem_cells]} {
     set _mem [gets $_list_mem_cells]
     if { $_mem != "" } {
        if {[ regexp {ssgnp[_a-z0-9]+_setup} $delayCorner]} {
           set_timing_derate -add -cell_delay -late -delay_corner $delayCorner $extra_memory_max_derate $_mem
        }
        if {[regexp {^ff} $delayCorner] || [regexp {^tt} $delayCorner] || [ regexp {ssgnp[_a-z0-9]+_hold} $delayCorner]} {
           set_timing_derate -add -cell_delay -early -delay_corner $delayCorner $extra_memory_min_derate $_mem
        }
     }
  }
  close $_list_mem_cells
  file delete /tmp/list_mem_cells.txt
} 

# Define IPs extra derating
proc add_ips_extra_derate {delayCorner} {
  global extra_ip_max_derate extra_ip_min_derate
  foreach _ip [get_db base_cells -if {.class == block}] {
     set flag 0
     if {![regexp "^sa" [get_db $_ip .base_name]] && ![regexp "^as" [get_db $_ip .base_name]]} {
        if {[ regexp {ssgnp[_a-z0-9]+_setup} $delayCorner]} {
          puts "-I- $_ip delayCorner $delayCorner match ssgnp\[_a-z0-9\]+_setup"
          set flag 1
          set_timing_derate -add -cell_delay -late -delay_corner $delayCorner $extra_ip_max_derate $_ip
        }
        if {[regexp {^ff} $delayCorner] || [regexp {^tt} $delayCorner] || [ regexp {ssgnp[_a-z0-9]+_hold} $delayCorner]} {
          puts "-I- $_ip delayCorner $delayCorner match ssgnp\[_a-z0-9\]+_hold or tt or ff"
          set flag 1
           set_timing_derate -add -cell_delay -early -delay_corner $delayCorner $extra_ip_min_derate $_ip
        }
        if { $flag == 0} {
     	   puts "-E- $_ip delayCorner $delayCorner does not have any match"
        }
     }
  }
} 

# Define memories extra margins
proc add_memories_extra_margin {} {
  global extra_memory_setup_margin extra_memory_hold_margin
  set memId 0
  foreach _mem [concat [get_db base_cells .base_name sa*] [get_db base_cells .base_name as*]] {
     foreach _inst_mem [get_db insts -if {.base_cell.name == $_mem}] {
        if {[get_db program_short_name] == "genus"} {
	   foreach _setup_view [get_db analysis_views -if {.is_setup == true}] {
	      puts "-I- setup view $_setup_view"
	      set_path_adjust -delay [expr 1000 * -$extra_memory_setup_margin] -to $_inst_mem -view [get_db $_setup_view .name]
           }
        } else {
           set_path_adjust_group -name toMem${memId} -to $_inst_mem
	   foreach _setup_view [get_db analysis_views -if {.is_setup == true}] {
	      puts "-I- setup view $_setup_view"
	      set_path_adjust -$extra_memory_setup_margin -path_adjust_group toMem${memId} -view [get_db $_setup_view .name]
           }
	   foreach _hold_view [get_db analysis_views -if {.is_hold == true}] {
	      puts "-I- hold view $_hold_view"
	      set_path_adjust -$extra_memory_hold_margin -path_adjust_group toMem${memId} -view [get_db $_hold_view .name]
           }
	}
	incr memId
     }
  }
}

# Define memories extra margins - workaround for DSTA CUI
proc add_memories_extra_margin_dsta {} {
  global extra_memory_setup_margin extra_memory_hold_margin
  eval_legacy {
  set _list_mem [open /tmp/list_mem.txt w]
  foreach _mem [concat [dbGet -u head.libCells.name sa*] [dbGet -u head.libCells.name as*]] {
     if { $_mem != 0x0 } {
        foreach _inst_mem_id [dbGet -p2 top.insts.cell.name $_mem] {
           if { $_inst_mem_id != 0x0 } {
	      set _inst_mem [dbGet $_inst_mem_id.name]
              puts $_list_mem $_inst_mem
           }
	}
     }
  }
  close $_list_mem
  }
  set memId 0
  set _list_mem [open /tmp/list_mem.txt r]
  while {![eof $_list_mem]} {
     set _inst_mem [gets $_list_mem]
     if { $_inst_mem != "" } {
        set_path_adjust_group -name toMem${memId} -to $_inst_mem
	   foreach _setup_view [get_db analysis_views -if {.is_setup == true}] {
	      set_path_adjust -$extra_memory_setup_margin -path_adjust_group toMem${memId} -view [get_db $_setup_view .name]
           }
	   foreach _hold_view [get_db analysis_views -if {.is_hold == true}] {
	      set_path_adjust -$extra_memory_hold_margin -path_adjust_group toMem${memId} -view [get_db $_hold_view .name]
           }
        incr memId
     }
  }
  close $_list_mem
  file delete /tmp/list_mem.txt
}

# Define IPs extra margins
proc add_ips_extra_margin {} {
  global extra_ip_setup_margin extra_ip_hold_margin
  set IPId 0
  foreach _ip [get_db base_cells -if {.class == block}] {
     if {![regexp "^sa" [get_db $_ip .base_name]] && ![regexp "^as" [get_db $_ip .base_name]]} {
        foreach _inst_ip [get_db insts -if {.base_cell.name == $_ip}] {
           if {[get_db program_short_name] == "genus"} {
	      foreach _setup_view [get_db analysis_views -if {.is_setup == true}] {
	         puts "-I- setup view $_setup_view"
	         set_path_adjust -delay [expr 1000 * -$extra_ip_setup_margin] -to $_inst_ip -view [get_db $_setup_view .name]
              }
           } else {
              set_path_adjust_group -name toIP${IPId} -to $_inst_ip
	      foreach _setup_view [get_db analysis_views -if {.is_setup == true}] {
	         puts "-I- setup view $_setup_view"
	         set_path_adjust -$extra_ip_setup_margin -path_adjust_group toIP${IPId} -view [get_db $_setup_view .name]
              }
	      foreach _hold_view [get_db analysis_views -if {.is_hold == true}] {
	         puts "-I- hold view $_hold_view"
	         set_path_adjust -$extra_ip_hold_margin -path_adjust_group toIP${IPId} -view [get_db $_hold_view .name]
              }
	   }
	incr IPId
        }
     }
  }
}

# Apply all deratings and extra margins
if {[get_db program_short_name] != "genus"} {
  reset_timing_derate
}
foreach delayCorner [get_db delay_corners .name] {
  puts "-I- add_vt_derates $delayCorner"
  add_vt_derates $delayCorner
  puts "-I- add_extra_derates $delayCorner"
  add_extra_derates $delayCorner
  puts "-I- add_memories_extra_derate $delayCorner"
  add_memories_extra_derate $delayCorner
  puts "-I- add_ips_extra_derate $delayCorner"
  add_ips_extra_derate $delayCorner
}




if {[info command distribute_partition] == ""} {
  # Check if DSTA
  puts "-I- add_memories_extra_margin"
  add_memories_extra_margin
  # Extra margin for IPs only work when LEF are loaded (using LEF CLASS)
  # However the extra margin is null for signoff model
puts "-I- add_ips_extra_margin"
  add_ips_extra_margin
} else {
  # DSTA - workaround for memory margin
  # No extra margin for IPs - no LEF
  # However the IP extra margin is null for signoff model
  puts "-I- add_ips_extra_margin"
  add_memories_extra_margin_dsta
}
