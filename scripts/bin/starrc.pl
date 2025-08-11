#!/usr/bin/perl -w
use strict;
use warnings;

my $version = 0.2;

###########################################################################################################################
###	Function													###
###		this perl process setup tcl file and create starrc command script					###
###															###
###	Create Date 	: 14-10-2021											###
###	Create By 	: Roy Leibovich											###
###															###
###	avriable for the script are:											###
###  		-design_name 	-	design name.									###
###  		-setup <file>	-	setup.tcl file.									###
###   		-command <file> -	command reference file.								###
###  		-verbose	-	Verbose.									###
###															###
###															###
###	 Var	date of change	owner	comment										###
###	----	--------------	-------	---------------------------------------------------------------			###
###	0.1	    01/03/2021		Roy		initial								###
###	0.2	    19/12/2021		Ory		remove LEF insertion . it will be done using tclsh		###
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
my %RC_CORNER;
my $RC = "";

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
my $STREAM_LAYER_MAP_FILE = "";
my $TECHNOLOGY_LAYER_MAP = "";

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
	
	if ($line =~ m/STREAM_FILE_LIST/ && $gds_flag == 1) {
		if ($verbose) {print LOG "adding to STREAM_FILE_LIST \n"};
		$gds_flag = 2;
	}
	
	if ($line =~ m/DESIGN_NAME.*$design_name/) {
		$lef_flag = 0;
		$gds_flag = 1;
	}
	#----------------------------------------------------------------------------
	#   process qrc tech file
	#----------------------------------------------------------------------------
	if ($line =~ m/rc_corner\((\w+),nxtgrd\)\s+(\S+)/) {
		if ($verbose) {print LOG "line: $line "};
		if ($verbose) {print LOG "1:  $1  2: $2 \n"};
		$RC = $1;
		$RC_CORNER{$1}{TCAD_GRD_FILE} = $2;
		$RC_CORNER{$1}{TCAD_GRD_FILE} =~ s/"//g;
		if ($verbose) {print LOG "TCAD_GRD_FILE is $RC_CORNER{$RC}{TCAD_GRD_FILE} \n"};
	}
	
	if ($line =~ m/rc_corner\(${RC}.*spef_(\S+)\)/ ) {
	  	$RC_CORNER{$RC}{OPERATING_TEMPERATURE} .= "$1 ";
		if ($verbose) {print LOG "OPERATING_TEMPERATURE is $RC_CORNER{$RC}{OPERATING_TEMPERATURE} \n"};
		
	}
	if ($line =~ m/STREAM_LAYER_MAP_FILE/) {
		my @line_a = split(' ', $line); 
		if ($verbose) {print LOG "setting STREAM_LAYER_MAP_FILE: $line_a[-1]   \n"};
		$STREAM_LAYER_MAP_FILE .= "$line_a[-1]";
	}
	if ($line =~ m/TECHNOLOGY_LAYER_MAP/) {
		my @line_a = split(' ', $line); 
		if ($verbose) {print LOG "setting TECHNOLOGY_LAYER_MAP: $line_a[-1]   \n"};
		$TECHNOLOGY_LAYER_MAP .= "$line_a[-1]";
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

#foreach (@lines) {
#	if ($MACRO_GDS_FILE_LIST eq "") {
#		if ($verbose) {print LOG "MACRO_GDS_FILE_LIST is empty\n"};
#		$_ =~ s/(.*MACRO_GDS_FILE_LIST)/#$1/;
#	} else {
#		$_ =~ s/MACRO_GDS_FILE_LIST/ \\\n$MACRO_GDS_FILE_LIST\n/;
#	}
#	$_ =~ s/LEF_FILE_LIST/ \\\n$LEF_FILE_LIST\n/;
#	$_ =~ s/GLOBAL_NETS/$GLOBAL_NETS/;
#	$_ =~ s/DESIGN_NAME/$design_name/;
#}

if ($verbose) {print LOG "############################################################################################"};
if ($verbose) {print LOG "update MAP FILE"};
if ($verbose) {print LOG "############################################################################################"};
foreach (@lines) {
	s/TECHNOLOGY_LAYER_MAP/$TECHNOLOGY_LAYER_MAP/;
	s/STREAM_LAYER_MAP_FILE/$STREAM_LAYER_MAP_FILE/;
}


if ($verbose) {print LOG "############################################################################################"};
if ($verbose) {print LOG "adding LEF files to command file"};
if ($verbose) {print LOG "############################################################################################"};

foreach my $lef_file_name (split('\n', $LEF_FILE_LIST)) {
	if ($lef_file_name =~ m/^\\/) {
		if ($verbose) {print LOG "exclude lef file name: $lef_file_name\n"};
	} else {
		if ($verbose) {print LOG "lef file name: $lef_file_name\n"};
		$lef_file_name =~ s/\\//;
## 19/12/2021 RoyL: adding lef files using tclsh.
#		push(@lines, "LEF_FILE: $lef_file_name\n");
	}
}

print "  --- write command file: $command_file\n";
open (COMMAND, "> $command_file")  or die "$! error trying to open $command_file";
print COMMAND @lines;
close (COMMAND);
#
if ($verbose) {print LOG "############################################################################################"};
if ($verbose) {print LOG "adding corners.smc"};
if ($verbose) {print LOG "############################################################################################"};
foreach my $rc_name (keys %RC_CORNER) {
	if ($RC_CORNER{$rc_name}{TCAD_GRD_FILE} =~ /^$/ || $RC_CORNER{$rc_name}{TCAD_GRD_FILE} =~ /""/) {
		if ($verbose) {print LOG "TCAD_GRD_FILE is empty\n"};
	} else {
		if ($verbose) {print LOG "OPERATING_TEMPERATURE: $RC_CORNER{$rc_name}{OPERATING_TEMPERATURE}\n"};
		my @TEMPERATURE = split(' ', $RC_CORNER{$rc_name}{OPERATING_TEMPERATURE});
		foreach my $temp (@TEMPERATURE) {
			$CORNER_DEFS .= "CORNER_NAME: ${rc_name}_$temp\n";
			$CORNER_DEFS .= "TCAD_GRD_FILE: $RC_CORNER{$rc_name}{TCAD_GRD_FILE}\n";
			$CORNER_DEFS .= "OPERATING_TEMPERATURE: $temp \n\n";
		}
	}
}

print "  --- write corner file : corners.smc\n";
open (CORNER, "> corners.smc")  or die "$! error trying to open corner.defs";
print CORNER $CORNER_DEFS;
close (CORNER);




close (LOG);

###########################################################################################
###	print Help data to screen
###########################################################################################

sub help {
 print "\n\nUsage: perl $0 [OPTIONS]
 update StarRC command script \n
  [OPTIONS]
   -design_name \tdesign name.
   -setup <file>\tsetup.tcl file.
   -command <file>\tcommand reference file.
   -verbose\t\tVerbose.
 \n\n";
 exit(1);
}

