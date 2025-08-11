proc user_report_ff {report_name} {

  set tmp_report ".tmp_seqs.rpt"

  report_sequential -hier > $tmp_report
  if { [catch { exec grep flop .tmp_seqs.rpt | sort > $report_name } res] } { puts "-W- grep exited abnormally" }

  file delete $tmp_report
  
}
