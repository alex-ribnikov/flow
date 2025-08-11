#!/usr/bin/perl -w

if($#ARGV < 0 || $ARGV[0] eq -help) {
&help;
}

$in = $ARGV[$#ARGV];
open (LOG ,"> log.log") or die "$! error trying to open log";
open (MEM_B, "< $in")  or die "$! error trying to open $in";

%modules = ();
@file_name = split(/\//, $in);
@name = split(/\./, $file_name[$#file_name]);
print "$name[0]\n";
open (OUTPUT,"> $file_name[$#file_name].uniq")  or die "$! error trying to open $file_name[$#file_name].uniq";

$count = 0;
foreach $line (<MEM_B>) {
	chomp $line;
	$count = $count + 1;
	if ( $line =~ m/module\s+/i && $line !~ m/$name[0]/i) { ## && $line !~ m/cmos_switch_PGA_BUF|LNA_matchAmp/i) { 
		$line =~ s/^\s+//;
		@sub =split(/ /, $line);
		if ( $sub[1] !~ m/$name[0]_\S+/ )  {
			$modules{$sub[1]} = "$name[0]_$sub[1]_$count"  ;
			print LOG "$count new key: $sub[1] change to $modules{$sub[1]}\n";
		} else {
			print LOG "$count module $sub[1] is uniq\n";
		}
	}
	
}
close(MEM_B);

print LOG "#########################################################################################################################################################################\n";
print LOG "### ending module mapping.\n";
print LOG "### \n";
print LOG "### open verilog for updating modules name\n";
print LOG "### \n";

close (LOG);
exit(0);


open (MEM_B, "< $in")  or die "$! error trying to open $in";
$line_number = 0;
foreach $line (<MEM_B>) {
	$line_number++;
	$line =~ s/\s*\n$/\n/;
	foreach $key (keys (%modules)) {
		if ( $line =~ m/module\s+$key(\W|$)/ && $line !~ m/module $modules{$key}/) {
				print LOG "$line_number line has $key\n";
				$line =~ s/module\s+$key(\W|$)/module $modules{$key}$1/ig;
		} elsif ($line =~ m/^\s*$key\s/) {
				print LOG "$line_number\t$line\n\t line has $key --> $modules{$key} --> 2\n";
				$line =~ s/$key/$modules{$key}/ig;
		} 
	}		
	print OUTPUT "$line";
}
close(MEM_B);
close(OUTPUT);
close (LOG);

sub help {
 print "\nUniquify the module of verilog file. top module name is file name before first dot.\n
 Usage:
 perl $0 <inputs module file> \n\n";
 exit(1);
}

