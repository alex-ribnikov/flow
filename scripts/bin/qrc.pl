#!/usr/bin/perl -w
use strict;
my $version = 0.1;

###########################################################################################################################
###	Function													###
###		this perl process setup tcl file and create qrc command script						###
###															###
###	Create Date 	: 03-02-2021											###
###	Create By 	: Roy Leibovich											###
###															###
###	avriable for the script are:											###
###  		-design_name 	-	design name.									###
###  		-setup <file>	-	setup.tcl file.									###
###   		-command <file> -	command reference file.								###
###  		-verbose	-	Verbose.									###
###															###
###															###
###########################################################################################################################
if($#ARGV < 0 ||$ARGV[0] eq -help) {
&help;
}
my $setup_file = "";
my $command_file = "";
my $design_name = "";
my $verbose = 0;

for (my $i = 0;$i <= $#ARGV; $i=$i+1) {
	if ( $ARGV[$i] eq "-setup") {
		$i=$i+1;
		if ($ARGV[$i] =~ m/^-/) {print "Error. $ARGV[$i - 1] need to have file name\n";&help;}
		$setup_file = $ARGV[$i];
	} elsif ( $ARGV[$i] eq "-command") {
		$i=$i+1;
		if ($ARGV[$i] =~ m/^-/) {print "Error. $ARGV[$i - 1] need to have file name\n";&help;}
		$command_file = $ARGV[$i];
	} elsif ( $ARGV[$i] eq "-design_name") {
		$i=$i+1;
		if ($ARGV[$i] =~ m/^-/) {print "Error. $ARGV[$i - 1] need to have desing name\n";&help;}
		$design_name = $ARGV[$i];
	} elsif ( $ARGV[$i] eq "-verbose") {
		$verbose = 1;
	} else {
		print "Error. unknown command $ARGV[$i]\n";
		&help;
	}
}
my $flag = 0;
my $LEF_FILE_LIST = "";
my $MACRO_GDS_FILE_LIST = "";
my $CORNER_DEFS = "";
my $GLOBAL_NETS = "";

if ($design_name eq "") {
	print "Error. missing design name .\n";
	$flag = 1;
}
if ($setup_file eq "") {
	print "Error. missing setup file .\n";
	$flag = 1;
}
if ($command_file eq "") {
	print "Error. missing comman file .\n";
	$flag = 1;
}

if ($flag) {&help;}

if ($verbose) {
	open (LOG ,"> log.log") or die "$! error trying to open log";
	print LOG "setup file: $setup_file\ncommand file: $command_file\ndesign_name :$design_name\n";
	print LOG "###################################################\n";
}
###########################################################################################
### 	parsing the setting files
###########################################################################################
my $tech_lef_flag = 0;
my $lef_flag = 0;
my $gds_flag = 0;
if ($verbose) {print LOG "  --- reading setting file: $setup_file\n"};
if ($verbose) {print LOG "**************************************************************\n"};
print "  --- reading setup file: $setup_file\n";
open (SETUP, "< $setup_file")  or die "$! error trying to open $setup_file";
foreach my $line (<SETUP>) {
	#----------------------------------------------------------------------------
	#   process LEF/GDS file
	#----------------------------------------------------------------------------
	if ($line =~ m/^\s*"/ && $tech_lef_flag==1) {
		if ($verbose) {print LOG "end of variable for TECH LEF FILE LIST\n"};
		$tech_lef_flag = 2;	
	} elsif ($tech_lef_flag == 1) {
		if ($verbose) {print LOG "adding to TECH LEF_FILE_LIST $line"};
		$LEF_FILE_LIST .= $line;
	} 
	if ($line =~ m/set TECH_LEF/ ) {
		if ($line =~ m/\\$/ ) {
			if ($verbose) {print LOG "adding TECH_LEF to LEF_FILE_LIST \n"};
			$tech_lef_flag = 1;
		} else {
			$line =~ s/\"//g;
			my @line_a = split(' ', $line); 
			if ($verbose) {print LOG "adding TECH_LEF: $line_a[-1]  to LEF_FILE_LIST \n"};
			$LEF_FILE_LIST .= "$line_a[-1] \\\n";
		}
	}
	if ($line =~ m/^\s*"/ && $lef_flag==1) {
		if ($verbose) {print LOG "end of variable for LEF FILE LIST\n"};
		$lef_flag = 2;	
	} elsif ($lef_flag == 1) {
		if ($verbose) {print LOG "adding to LEF_FILE_LIST $line"};
		$LEF_FILE_LIST .= $line;
	} 
	
	if ($line =~ m/LEF_FILE_LIST/ && $lef_flag < 2) {
		if ($verbose) {print LOG "adding to LEF_FILE_LIST \n"};
		$lef_flag = 1;
	}
	
	if ($line =~ m/^\s*"/ && $gds_flag==2) {
		if ($verbose) {print LOG "end of variable for MACRO GDS FILE LIST\n"};
		$gds_flag = 3;	
	} elsif ($gds_flag==2) {
		if ($verbose) {print LOG "adding to MACRO_GDS_FILE_LIST $line"};
		$MACRO_GDS_FILE_LIST .= $line;
	} 
	
	if ($line =~ m/GDS_FILE_LIST/ && $gds_flag == 1) {
		if ($verbose) {print LOG "adding to MACRO_GDS_FILE_LIST \n"};
		$gds_flag = 2;
	}
	
	if ($line =~ m/DESIGN_NAME.*$design_name/) {
		$lef_flag = 0;
		$gds_flag = 1;
	}
	#----------------------------------------------------------------------------
	#   process qrc tech file
	#----------------------------------------------------------------------------
	if ($line =~ m/rc_corner\((\w+)\)\s+(\S+)/) {
        $line =~ s/.tch//g;
        $line =~ s/.qrcTechFile//g;
        $line =~ m/rc_corner\((\w+)\)\s+(\S+)/;
		$CORNER_DEFS .= "DEFINE $1 \t$2\n"
	}
	#----------------------------------------------------------------------------
	#   process P/G NETS
	#----------------------------------------------------------------------------
	if ($line =~ m/PWR_NET/ || $line =~ m/GND_NET/) {
		chomp $line;
		$line =~ s/\{|\}|\[|\]|list|set|PWR_NET|GND_NET//g;
		$line =~ s/\s+/ /g;
		$GLOBAL_NETS .= $line;
	}
	
}
close (SETUP);

###########################################################################################
### 	put results in command file
###########################################################################################

print "  --- reading command file: $command_file\n";
open (COMMAND, "< $command_file")  or die "$! error trying to open $command_file";
my @lines = <COMMAND>;
close (COMMAND);

foreach (@lines) {
	if ($MACRO_GDS_FILE_LIST eq "") {
		if ($verbose) {print LOG "MACRO_GDS_FILE_LIST is empty\n"};
		$_ =~ s/(.*MACRO_GDS_FILE_LIST)/#$1/;
	} else {
		$_ =~ s/MACRO_GDS_FILE_LIST/ \\\n$MACRO_GDS_FILE_LIST\n/;
	}
	$_ =~ s/LEF_FILE_LIST/ \\\n$LEF_FILE_LIST\n/;
	$_ =~ s/GLOBAL_NETS/$GLOBAL_NETS/;
	$_ =~ s/DESIGN_NAME/$design_name/;
}
print "  --- write command file: $command_file\n";
open (COMMAND, "> $command_file")  or die "$! error trying to open $command_file";
print COMMAND @lines;
close (COMMAND);

print "  --- write corner file : corner.defs\n";
open (CORNER, "> corner.defs")  or die "$! error trying to open corner.defs";
print CORNER $CORNER_DEFS;
close (CORNER);




close (LOG);

###########################################################################################
###	print Help data to screen
###########################################################################################

sub help {
 print "\n\nUsage: perl $0 [OPTIONS]
 create QRC command script \n
  [OPTIONS]
   -design_name \tdesign name.
   -setup <file>\tsetup.tcl file.
   -command <file>\tcommand reference file.
   -verbose\t\tVerbose.
 \n\n";
 exit(1);
}

