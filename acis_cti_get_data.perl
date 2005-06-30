#!/usr/bin/perl

#################################################################################
#										#
#	get_data.perl: obtain data for unprocessed data from the previous run	#
#										#
#	author: t. isobe (tisobe@cfa.harvard.edu)				#
#	last update: Jun 14, 2005						#
#			modified to fit into a new directory system		#
#										#
#################################################################################


#########################################
#--- set directories
#
$in_list  = `cat ./dir_list`;
@dir_list = split(/\s+/, $in_list);

$cti_www       = $dir_list[0];

$house_keeping = $dir_list[1];

$exc_dir       = $dir_list[2];

$bin_dir       = $dir_list[3];

$ftools        = $dir_list[4];
#
#########################################

$bin_data = '/data/mta4/MTA/data/';

$dare   =`cat $bin_data/.dare`;
$hakama =`cat $bin_data/.hakama`;
chomp $dare;
chomp $hakama;

system("rm $cti_www/$house_keeping/keep_entry");
open(FH, "$exc_dir/Working_dir/new_entry");
while(<FH>){
	chomp $_;
	@atemp = split(/\s+/, $_);
	$obsid = $atemp[0];
       	open(OUT, ">$exc_dir/Working_dir/input_line");
        print OUT "operation=retrieve\n";
        print OUT "dataset=flight\n";
        print OUT "detector=acis\n";
        print OUT "level=1\n";
        print OUT "version=last\n";
        print OUT "filetype=evt1\n";
        print OUT "obsid=$obsid\n";
        print OUT "go\n";
        close(OUT);

        `echo $hakama  |/home/ascds/DS.release/bin/arc4gl -U$dare -Sarcocc -i$exc_dir/Working_dir/input_line`; # here is the arc4gl
        `gzip -d *gz`;
	
	$name = '*'."$obsid".'*fits';
	system("ls $name > $exc_dir/Working_dir/zfits_test");
	open(IN, "$exc_dir/Working_dir/zfits_test");
	$chk = 0;
	OUTER:
	while(<IN>){
		chomp $_;
		if($_ =~ /\w/){
			$chk++;
			if($chk > 1){
				system("rm $_");
			}
		}
	}
	close(IN);
	if($chk == 0){
		open(OUT2, ">> $exc_dir/$house_keeping/keep_entry");
		print OUT2 "$obsid\n";
		close(OUT2);
	}
}
close(FH);

system("rm $exc_dir/Working_dir/*fits");
system("mv *.fits $exc_dir/Working_dir/");
system("rm $exc_dir/Working_dir/input_line");
system("rm $exc_dir/Working_dir/zfits_test");
