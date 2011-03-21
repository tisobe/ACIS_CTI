#!/usr/bin/perl

#########################################################################################
#											#
#	find_new_entry.perl: find newly logged data from 				#
#			/data/mta/www/mp_reports/photons/acis/cti/6*			#
#		and	/data/mta/www/mp_reports/photons/acis/cti/5*			#
#											#
#	author: t. isobe (tisobe@cfa.harvard.edu)					#
#	last update: Mar 09, 2011							#
#		copied from an old script						#
#											#
#########################################################################################

#########################################
#--- set directories
#
open(FH, "/data/mta/Script/ACIS/CTI/house_keeping/dir_list");
@dir_list = ();
OUTER:
while(<FH>){
        if($_ =~ /#/){
                next OUTER;
        }
        chomp $_;
        push(@dir_list, $_);
}
close(FH);

$bin_dir       = $dir_list[0];
$bin_data      = $dir_list[1];
$cti_www       = $dir_list[2];
$data_dir      = $dir_list[3];
$house_keeping = $dir_list[4];
$exc_dir       = $dir_list[5];

#
#########################################

#
#--- get a list of entires from the report dir
#

system("ls -rd /data/mta/www/mp_reports/photons/acis/cti/6*_* >  $exc_dir/Working_dir/temp_list");
system("ls -rd /data/mta/www/mp_reports/photons/acis/cti/5*_* >> $exc_dir/Working_dir/temp_list");
system("cp $house_keeping/input_list $house_keeping/input_list~");

@temp_list  = ();
@input_list = ();
open(FH, "$exc_dir/Working_dir/temp_list");
while(<FH>) {
        chomp $_;
        @atemp = split(/cti\//, $_);
        @btemp = split(/_/,$atemp[1]);
        if($btemp[0] =~ /\d/) {
                push(@temp_list, $_);
        }
}
close(FH);

#
#---- get a list of the last entries
#

open(FH,"$house_keeping/input_list");
while(<FH>) {
        chomp $_;
        push(@input_list, $_);
}
close(FH);

OUTER:
foreach $comp (@temp_list) {            # find out which data is new
        @atemp = split(/cti\//,$comp);
        foreach $dir (@input_list) {
                @btemp = split(/cti\//,$dir);
                if($btemp[1] =~ /$atemp[1]/) {
                        next OUTER;
                }
        }
        push(@new_list, $comp);
}

foreach $new (@new_list) {
        push(@input_list, $new);        # append new data to the old one
}

open(RENE, ">$house_keeping/input_list");

foreach $dir (@input_list) {
        print RENE "$dir\n";            # update the input_list
}
close(RENE);

open(FH, "$house_keeping/keep_entry");
while(<FH>){
	chomp $_;
	push(@keep_entry, $_);
}
close(FH);

#
#---- make a file with the new entries for the next script
#

open(RENE, ">$exc_dir/Working_dir/new_entry");

foreach $dir (@new_list){
	@atemp = split(/\//, $dir);
	@btemp = split(/_/, $atemp[8]);
	print RENE "$btemp[0]\n";
}
foreach $ent (@keep_entry){
	print RENE "$ent\n";
}

close(RENE);

