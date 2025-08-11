#!/usr/bin/perl -w
use strict;
use warnings;

my $version = 0.1;

###########################################################################################################################
###	Function													###
###		this perl process split lines in cadence timing report							###
###															###
###	Create Date 	: 27-10-2021											###
###	Create By 	: Roy Leibovich											###
###															###
###	avriable for the script are:											###
###  		-file <file>	-	timing report file.								###
###  		-out <file>	-	output result file.								###
###  		-match_synopsys	-	rearrange table to match synopsys timing reports.				###
###  		-nosplit	-	Do not split lines when columns overflow.					###
###  		-verbose	-	Verbose.									###
###															###
###															###
###########################################################################################################################
if($#ARGV < 0 ||$ARGV[0] eq -help) {
&help;
}

my $report_file = "";
my $out_file = "";
my $nosplit = 0;
my $out_to_screen = 1;
my $verbose = 0;
my $flag = 0;
my $match_synopsys = 1;
my %timing_fields;
my @timing_fields_order = {};

for (my $i = 0;$i <= $#ARGV; $i=$i+1) {
	if ( $ARGV[$i] eq "-file") {
		$i=$i+1;
		if ($ARGV[$i] =~ m/^-/) {print "Error. $ARGV[$i - 1] need to have file name\n";&help;}
		$report_file = $ARGV[$i];
	} elsif ( $ARGV[$i] eq "-out") {
		$i=$i+1;
		if ($ARGV[$i] =~ m/^-/) {print "Error. $ARGV[$i - 1] need to have file name\n";&help;}
		$out_file = $ARGV[$i];
	} elsif ( $ARGV[$i] eq "-nosplit") {
		$nosplit = 1;
	} elsif ( $ARGV[$i] eq "-verbose") {
		$verbose = 1;
	} else {
		print "Error. unknown command $ARGV[$i]\n";
		&help;
	}
}
if ($report_file eq "") {
	print "Error. missing report file .\n";
	$flag = 1;
}

if ($flag) {&help;}

if ($verbose) {
	open (LOG ,"> log.log") or die "$! error trying to open log";
	print LOG "report file: $report_file\nout file: $out_file\n";
	print LOG "###################################################\n";
}
###########################################################################################
### 	reading report file
###########################################################################################
if ($verbose) {print LOG "  --- reading report file: $report_file\n"};
if ($verbose) {print LOG "**************************************************************\n"};
print "  --- reading report file: $report_file\n";
open (REPORT, "< $report_file")  or die "$! error trying to open $report_file";
my $first = 0;
my $ttt = "";
foreach my $line (<REPORT>) {
	$line =~ s/Timing Point/Timing_Point/;
	$line =~ s/Total Derate/Total_Derate/;
	my $shrink_line = $line;
	$shrink_line =~ s/\s+/ /g;
	my @fields = split(/ /, $shrink_line);


	if ($match_synopsys) {
		if ($shrink_line =~ m/Annotation/) {	$line = "#\t\t\t\t\t\t\t(pf)\t(ns)\t\t\t(ns)\t(ns)\t\tAnnotation\n"}
	}
	if ($#fields > 9 && $line !~ m/^#  Command/ && $line !~ m/^\s*Net/) {
		
		$line  = "";
		$first = 0;
		if ($match_synopsys) {
			if ($shrink_line !~ m/^#/) {
				foreach (my $i= 1; $i < $#fields ; $i++) {
					$timing_fields{$timing_fields_order[$i]} = $fields[$i];
				}
				if ($timing_fields{Timing_Point}) {	$line .= "  $timing_fields{Timing_Point}\t"};
				if ($timing_fields{Cell}) 	  {
					if ($nosplit) {
							$line .= "($timing_fields{Cell})\t\t"
					} else {
						if (length($timing_fields{Timing_Point}) < 20) {
							$line .= "($timing_fields{Cell})\t\t"
						} else {
							$line .= "($timing_fields{Cell})\n                                           "
						}
					}
				};
				if ($timing_fields{Fanout}) 	  {	$line .= "$timing_fields{Fanout}\t\t"};
				if ($timing_fields{Load}) 	  {	$line .= "$timing_fields{Load}\t"};
				if ($timing_fields{Trans}) 	  {	$line .= "$timing_fields{Trans}\t"};
				if ($timing_fields{Total_Derate}) {
					if ($timing_fields{Total_Derate} =~ m/-/) {
						$line .= "$timing_fields{Total_Derate}\t\t"
					} else {
						$line .= "$timing_fields{Total_Derate}\t"
					}
				};
				if ($timing_fields{Delay}) 	  {	$line .= "$timing_fields{Delay}\t"};
				if ($timing_fields{Arrival}) 	  {	$line .= "$timing_fields{Arrival}\t"};
				if ($timing_fields{Edge}) 	  {	$line .= "$timing_fields{Edge}\t"};
				if ($timing_fields{Arc}) 	  {	$line .= "$timing_fields{Arc}\t"};
				
			} else {
				foreach (my $i= 1; $i < $#fields ; $i++) {
					$timing_fields_order[$i] = $fields[$i];
					$timing_fields{$timing_fields_order[$i]} = $fields[$i];
				}
				
				if ($timing_fields{Timing_Point}) {	$line .= "# $timing_fields{Timing_Point}\t"};
				if ($timing_fields{Cell}) 	  {	$line .= "$timing_fields{Cell}\t\t\t"};
				if ($timing_fields{Fanout}) 	  {	$line .= "$timing_fields{Fanout}\t\t"};
				if ($timing_fields{Load}) 	  {	$line .= "$timing_fields{Load}\t"};
				if ($timing_fields{Trans}) 	  {	$line .= "$timing_fields{Trans}\t"};
				if ($timing_fields{Total_Derate}) {	$line .= "$timing_fields{Total_Derate}\t"};
				if ($timing_fields{Delay}) 	  {	$line .= "$timing_fields{Delay}\t"};
				if ($timing_fields{Arrival}) 	  {	$line .= "$timing_fields{Arrival}\t"};
				if ($timing_fields{Edge}) 	  {	$line .= "$timing_fields{Edge}\t"};
				if ($timing_fields{Arc}) 	  {	$line .= "$timing_fields{Arc}\t"};
				
			}
			$line .= "\n";
			
		} else {
			foreach my $field (@fields) {
				$first++;
				if (($first == "4" && $field eq "Cell") || ($first == "3" && $field ne "Point")) {
					if ($shrink_line =~ m/^#/) {
						$line .= "$field\n#                                           ";
					} else {
						$line .= "$field\n                                           ";
					}
				} else {
					$line .= "$field\t";
				}
			}
			$line .= "\n";
		}
		
	}
	$line =~ s/Timing_Point/Timing Point/;
	$line =~ s/Total_Derate/Total Derate/;
	$line =~ s/\(\(/(/;
	$line =~ s/\)\)/)/;
	$line =~ s/----------------------------------------/-------------------/g;
	
	if ($out_to_screen == 1) {
		print $line;
	}
}
close (REPORT);


###########################################################################################
###	print Help data to screen
###########################################################################################

sub help {
 print "\n\nUsage: perl $0 [OPTIONS]
 split lines in Cadence timing reports \n
  [OPTIONS]
   -file <file>\ttiming report file.
   -out <file>\toutput result file.
   -nosplit \tDo not split lines when columns overflow.
   -match_synopsys\trearrange reports fields to match synopsys timing report.
   -verbose\t\tVerbose.
 \n\n";
 exit(1);
}
