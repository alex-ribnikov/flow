#!/usr/bin/perl

#print @ARGV;
 $argv = "@ARGV";
if ($argv =~ s/\s*-ref\s+(\S+)\s*//) {
 $ref_file = $1;
}
$file = $argv;
# print "F $file\nREF $ref_file\n";

# exit

print "openning $file ...\n";
 if ($file =~ /\.gz$/) {
        open(F, "gunzip -c $file |") || die "can't open pipe to $file";
        $file =~ s/\.gz$//;
    }
else {open(F, "<$file") ;}
while (<F>) {
 $line = $_;
 if ($line =~ /Genus/) {$GN =1}
 if ($line=~/^\s*(Start|Begin)point:/ ) {
  $pn++;
  if  ($rec{$n} !~ /(P|p)ath.*(VIO|MET)/) {  
   $line = "Path $pn: $line";
  }
 }
 if ($line =~ /^(p|P)ath\s+(\d+):/) {$n = $2; $eb = "";} 
 $rec{$n} .= "$line";
 if ($line=~/(Start|Begin)point:\s+\(*(R|F)*\)*([^\(]+)/) {
  $beg = $3; 
  if (/edge of\s.(\S+)./) {
   $bclk = $1; 
 }
  $b = 1;
 }
 if ($b & /clocked by (\S+)\)/) {
    $bclk = $1;
    $clkby++;
 }
 if ($line=~/Endpoint:\s+\(*(R|F)*\)*([^\(]+)/) {
  $end = $2;
  $e = 1;
  if (/edge of\s.(\S+\).)/) {
   $eclk = $1;
  }
 }
 if ($clkby & /clocked by (\S+)\)/) {
    $eclk = $1;
    $clkby = 0;
 }
 if ($b & $e) {
     $b =0; $e = 0;
     $p = "$beg\t$end";
     $p =~ s/_\d+/_*/g;
     $p =~ s/CG_HIER_INST\d+/CG_HIER_INST*/g;
     $p =~ s/\[\d+\]/\[*\]/g;
     $p =~ s/Q\d+/Q\*/g;
     $p =~ s/D\d+/D\*/g;
     $p =~ s/q\d+/q\*/g;
     $p =~ s/d\d+/d\*/g;
     $p =~ s/\((\^|v)\)\s*//g;
     $beg =~ s%(.*)/[^/]+%$1%;
     $p =~ s/^(\s+|\t+)//g;
     $p =~ s/(\s+\t*|\t+\s*)/GGG/g;
     $p =~ s/GGG/\t/g;
     $path_name = $p;
     $p =~ s/__/_/g;
     $p =~ s/CDN_MBIT_\S+_MB_//g;
     $p =~ s%/\w+\**\s*$%%g;
     $p =~ s%/\w+(\s+|\t+)%$1%g;
     $path{$p} = $path_name;


     # print "P $p\n";
 }
  if ($line =~ /(^\s+Slack\s*:=|Slack Time|slack\s+\(\S+.*\))\s+(-*\S+)p*s*/)  {
    $m = $2; 
    if ($line =~ /slack\s+\(\S+.*\)\s+.*\s(\S+)\s*$/) {
     $m = $1; 
    }
    $m =~ s/ps//;
#  print "M $m $p\n";
     if ($m < 0) {$c{$p}++;}
     if (($vio{$p} > $m) || (!defined($vio{$p}))) {
      $vio{$p} = $m;
      $id{$p} = $n;
      $grp{$p} = "$g $eclk $bclk";
      $aview{$p} = $av;
     }
 }

 if ($line =~ /(SPEF|\/[oqOQ(sum)(carry)]\s+\S+.*\s+[RFz\#\*\&]*\s*).*/ && $line !~ /\(net\).*/ && $line !~ /\(arrival\).*/ && $line !~ /(CTS|USKC|clk_gate).*/) {$cell_cnt{$n}++; }
 if (($line =~ /(BUF|INV).*SPEF/ ||  $line =~ /\/[oO]\s+\S*(BUF|INV)\S*.*\s+[RFz\#\*\&]*\s*.*/) && $line !~ /(CTS|USKC|clk_gate).*/) {$buf_cnt{$n}++; }
 if (($line =~ /[oqOQ(sum)(carry)]\s+.*(F6U|F6E|E\dU|E\dE)/) &&  $line !~ /(CTS|USKC|clk_gate).*/) {$uvt_cnt{$n}++; }
 if ($line =~ /Clock:\s+\S+\s+(\S+)/) {$clk{$n} .= " $1"}
 if ($line =~ /->/) {
  @row = split (" ",$line);
     if ($line =~ /\s+$beg\/*/) {
      $beg_clk{$n} = $row[7] - $row[6];
      $begin_point{$n} = "Starting pint Arrival Time\t$beg_clk{$n}\n"
     }
  if (($row[5] =~ /BUF_|INV_/) && (!($line =~ /CTS/))) {$buf_cnt{$n}++}
  if (!($line =~ /.*CTS.*|.*clock_gating_latch.*\/Q|.*clone.*|.*RC_CG.*\/|.*termi\/.*|.*\/yi\/.*/)) {
  
   $cell_cnt{$n}++;
   $btn_cell = $row[16];
   $delay{$btn_cell} = $row[6];
   $ref{$btn_cell} = $row[5];
   $btn_cnt{$btn_cell}++;
   $btn_tns{$btn_cell} = $btn_tns{$btn_cell} + $m;
   if ($btn_wns{$btn_cell} > $m) {$btn_wns{$btn_cell} = $m}
  } 
  if ($row[$#row-1] =~ /\((\d+\.\d+)\,/) {
   $x0 = $x;
   if (!defined($d)) {
   $d = 0;
   $x = $1;
   } 
  }
  if ($row[$#row] =~ /(\d+\.\d+)\)/) {$y = $1;}
  # print "$x $y\n";
 }
 if ($line =~ /Group\s*:\s+(\S+)\s*/) {$g = $1} 
 if ($line =~ /Path Groups:\s+\{\s*(\S+)\}\s*/) {$g = $1} 
 #if ($line =~ /^Start-point\s*:\s+(\S+)/) {$s = $1} 
 if ($line =~ /(View:|Scenario:)\s+(\S+)/) {$av = $2;}
 #if ($line =~ /Endpoint:/) {$se =1} 
 if ($se) {
  $eb .= $line;
 }
 
 if ($line =~ /^End-point\s*:\s+(\S+)/) {
#  print "$n $g $m $s $e\n";
  $e = $1;
  $p = "$s $e";
  $p =~ s/_\d+/_*/g;
  $p =~ s/\[\d+\]/\[*\]/g;
  $p =~ s/(\w+)\d+$/$1\*/g;
  $c{$p}++;
  if (($vio{$p} > $m) || (!defined($vio{$p}))) {
   $vio{$p} = $m;
   $id{$p} = $n;
   $grp{$p} = $g;
   $aview{$p} = $av;
  }
 } 
 
 
}

close(F);

foreach $pp (keys %vio) {
 $nn = $id{$pp};
 if ($c{$pp} == 0) {$c{$pp} = "-";}
 if ($cell_cnt{$nn} == 0) {$cell_cnt{$nn} = "-";}
 if ($buf_cnt{$nn} == 0) {$buf_cnt{$nn} = "-";}
 if ($uvt_cnt{$nn} == 0) {$uvtp_cnt{$nn} = "-";} 
 else {
    $uvtp_cnt{$nn} = $uvt_cnt{$nn}/$cell_cnt{$nn};   
    $uvtp_cnt{$nn} =~ s/(\.\d\d)\d+/$1/;
 }
 $filter .= "$vio{$pp}\t$id{$pp}\t$grp{$pp} $clk{$nn}\t\t$c{$pp}\t$cell_cnt{$nn}\t$buf_cnt{$nn}\t$uvtp_cnt{$nn}\t\t$path{$pp}\t\t\t$aview{$pp}\n";
}


$outfile = "tmp.rpt"; 
        open OUTFILE, ">$outfile" or do { warn  "Couldn't open '$file': $!\n"; return undef};
        print OUTFILE $filter;
        close(OUTFILE) or do { warn  "Error closing $file: $!"; return undef };
$sort = "Slack\tNum\tGroup\t\t\t\t\tCount\tCell #\tBuf/Inv #\tUVT usage\tPath\t\t\tView\n";
$sort .= `sort -n tmp.rpt`;
$sort_csv = $sort;
$sort_csv =~ s/Path/Startpoint,Endpoint/;
$sort_csv =~ s/\t+/,/g;
`/bin/rm -rf tmp.rpt`;
$outfile = "$file.filtered.rpt"; 
        open OUTFILE, ">$outfile" or do { warn  "Couldn't open '$file': $!\n"; return undef};
        print OUTFILE $sort;
        close(OUTFILE) or do { warn  "Error closing $file: $!"; return undef };
$outfile = "$file.filtered.csv"; 
        open OUTFILE, ">$outfile" or do { warn  "Couldn't open '$file': $!\n"; return undef};
        print OUTFILE $sort_csv;
        close(OUTFILE) or do { warn  "Error closing $file: $!"; return undef };


my @nums = sort { $a <=> $b } values %id;
for ($i = 0; $i <= $#nums; $i++) {
 $nn = $nums[$i];
 $rec{$nn} =~ s/(Other End Arrival Time)/$begin_point{$nn}$1/;
 $sort .= "\n$rec{$nn}";
}
$outfile = "$file.mini.rpt"; 
        open OUTFILE, ">$outfile" or do { warn  "Couldn't open '$file': $!\n"; return undef};
        print OUTFILE $sort;
        close(OUTFILE) or do { warn  "Error closing $file: $!"; return undef };

#if ($GN == 0) {
#foreach $pp (keys %btn_tns) {
# $btn .= "$pp $ref{$pp} $delay{$pp} $btn_cnt{$pp} $btn_wns{$pp} $btn_tns{$pp}\n";
#}
#$outfile = "tmp.rpt"; 
#        open OUTFILE, ">$outfile" or do { warn  "Couldn't open '$file': $!\n"; return undef};
#        print OUTFILE $btn;
#        close(OUTFILE) or do { warn  "Error closing $file: $!"; return undef };
#$sort = "Pin\t\t\t\t\t\t\tCell Name\tDelay\tCNT\tWNS\tTNS\n";
#$sort .= `sort -n -k 6 tmp.rpt`;
# $outfile = "$file.bottleneck.rpt"; 
#         open OUTFILE, ">$outfile" or do { warn  "Couldn't open '$file': $!\n"; return undef};
#         print OUTFILE $sort;
#`/bin/rm -rf tmp.rpt`;
#}


if ($ref_file =~ /\S+/) {
print "openning $ref_file ...\n";
 open(F, "<$ref_file"); 
 while (<F>) {
  $line = $_;
  @row = split (" ",$line);
  $p_ref = "$row[9]GGG$row[10]";
  $p_ref =~ s/GGG/\t/g;
  $p_ref =~ s/__/_/g;
  $p_ref =~ s/CDN_MBIT_(\S+)_MB_//g;
  $p_ref =~ s%/\w+\**\s*$%%g;
  $p_ref =~ s%/\w+\**(\s+|\t+)%$1%g;
  # print "PREF1 $p_ref\n";
  $p_ref =~ s/(\s+\t+|\t+\s+)/\t/g;
  $path_ref{$p_ref} = "$row[9]\t$row[10]";
  # print "PREF  $p_ref\n";
  $vio_ref{$p_ref} 	 = $row[0];
  $id_ref{$p_ref}  	 = $row[1];
  $grp_ref{$p_ref} 	 = $row[2];
  $clk_ref{$p_ref}  	 = "$row[3] $row[4]";
  $c_ref{$p_ref}      = $row[5];
  $cell_cnt_ref{$p_ref}  = $row[6];
  $buf_cnt_ref{$p_ref}   = $row[7];
  $uvtp_cnt_ref{$p_ref}  = $row[8];
  $aview_ref{$p_ref} 	 = $row[11];
  #  print "$line\n$vio_ref{$p_ref} $id_ref{$p_ref}  $grp_ref{$p_ref} $c_ref{$p_ref} $cell_cnt_ref{$p_ref}  $buf_cnt_ref{$p_ref} $p_ref \n";
 }
 close(F);

 foreach $pp (keys %vio) {
  $nn = $id{$pp};
  if ($c{$pp} == 0) {$c{$pp} = "-";}
  # print "$vio{$pp}ps $vio_ref{$pp}ps\t$id{$pp} $id_ref{$pp}\t$grp{$pp}\t\t$c{$pp} $c_ref{$pp}\t$pp\t\t\t$aview{$pp}\n";
   if (!($vio_ref{$pp} =~ /\S+/)) {$vio_ref{$pp} = "-"}
   if (!($id_ref{$pp} =~ /\S+/)) {$id_ref{$pp} = "-"}
   if (!($c_ref{$pp} =~ /\S+/)) {$c_ref{$pp} = "-"}
   if (!($cell_cnt_ref{$pp} =~ /\S+/)) {$cell_cnt_ref{$pp} = "-"}
   if (!($buf_cnt_ref{$pp} =~ /\S+/)) {$buf_cnt_ref{$pp} = "-"}
   if (!($uvtp_cnt_ref{$pp} =~ /\S+/)) {$uvtp_cnt_ref{$pp} = "-"}
   $filter_ref .= "$vio{$pp}   $vio_ref{$pp}\t\t$id{$pp}   $id_ref{$pp}\t\t$grp{$pp}\t\t$clk{$pp}\t\t$c{$pp} $c_ref{$pp}\t$cell_cnt{$nn} $cell_cnt_ref{$pp}\t$buf_cnt{$nn} $buf_cnt_ref{$pp}\t$uvtp_cnt{$nn} $uvtp_cnt_ref{$pp}\t\t$path{$pp}\t\t\t$aview{$pp}\n";
 }
 $outfile = "tmp.rpt"; 
        open OUTFILE, ">$outfile" or do { warn  "Couldn't open '$file': $!\n"; return undef};
        print OUTFILE $filter_ref;
        close(OUTFILE) or do { warn  "Error closing $file: $!"; return undef };
 $sort_ref = "Slack\t\t\tNum\t\tGroup\t\t\t\t\tCount\tCell #\tBuf/Inv #\tUVT usage\tPath\t\t\tView\n";
 $sort_ref .= `sort -n tmp.rpt`;
 $sort_csv_ref = $sort_ref;
 $sort_csv_ref =~ s/Path/Startpoint,Endpoint/;
 $sort_csv_ref =~ s/\t+/,/g;
 `/bin/rm -rf tmp.rpt`;
 $outfile = "$file.filtered.compared.rpt"; 
        open OUTFILE, ">$outfile" or do { warn  "Couldn't open '$file': $!\n"; return undef};
        print OUTFILE $sort_ref;
        close(OUTFILE) or do { warn  "Error closing $file: $!"; return undef };
 $outfile = "$file.filtered.compared.csv"; 
        open OUTFILE, ">$outfile" or do { warn  "Couldn't open '$file': $!\n"; return undef};
        print OUTFILE $sort_csv_ref;
        close(OUTFILE) or do { warn  "Error closing $file: $!"; return undef };


}



