#-- Set common variables and aliases

set synopsys_path [getenv SYNOPSYS]


##nramani- Check if you want to increase nworst value here
alias report_timing_alias_full {report_timing -path full -nosplit -nets -nworst 10  -trans -cap -derate -significant_digits 3 -input_pins -max_paths 10000}
alias report_timing_alias_summary {report_timing -trans -cap -derate -significant_digits 3 -input_pins -nosplit -slack_lesser_than 0 -max_paths 1000000}
alias report_timing_alias_short {report_timing -significant_digits 3 -nosplit -slack_lesser_than 0 -max_paths 10000}
alias report_power_alias {report_power -nosplit -analysis_effort medium }
alias report_area_alias {report_area -nosplit}

set report_default_significant_digits 4

##nramani - default is true, explicitly needed??
set case_analysis_with_logic_constants true

define_design_lib WORK -path ./work

