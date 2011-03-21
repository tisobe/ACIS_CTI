#!/opt/local/bin/perl

#################################################################################
#										#
#	acis_cti_run_all_script.perl: this is a control script for cti comp	#
#										#
#	author: t. isobe (tiosbe@cfa.harvard.edu)				#
#										#
#	last update: Mar 09, 2011						#
#										#
#################################################################################

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

#########################################


#
#--- check whether Working dir exist or not, and if not, create one.
#

$chk = `ls -d $exc_dir`;
if($chk !~ /Working_dir/){
        system("mkdir $exc_dir/Working_dir");
}

#
#--- a list of cti obsrvations are obtained from Jim's cti computation
#

system("/opt/local/bin/perl $bin_dir/acis_cti_find_new_entry.perl");
system("/opt/local/bin/perl $bin_dir/acis_cti_get_data.perl ");

#
#--- check a focal plane temp so that we can discreminate cti depending on temp
#

system("/opt/local/bin/perl $bin_dir/acis_cti_find_time_temp_range.perl");

#
#--- recmpute cti according to temperature difference
#

system("/opt/local/bin/perl $bin_dir/acis_cti_manual_cti.perl ");

#
#--- compute detrending factor
#

system("/opt/local/bin/perl $bin_dir/acis_cti_detrend_factor.perl");

#
#--- create several data sets (e.g. temperature and/or time)
#

system("/opt/local/bin/perl $bin_dir/acis_cti_adjust_cti.perl ");

#
#--- compute adjustment factor for temeprature depended cti
#

system("/opt/local/bin/perl $bin_dir/acis_cti_comp_adjusted_cti.perl ");

#
#--- cti plottings start here
#

system("/opt/local/bin/perl $bin_dir/acis_cti_find_outlayer.perl 	Data119");
system("/opt/local/bin/perl $bin_dir/acis_cti_plot_only.perl 		Data119");

system("/opt/local/bin/perl $bin_dir/acis_cti_find_outlayer.perl 	Data2000");
system("/opt/local/bin/perl $bin_dir/acis_cti_plot_only.perl 		Data2000");

system("/opt/local/bin/perl $bin_dir/acis_cti_find_outlayer.perl 	Data7000");
system("/opt/local/bin/perl $bin_dir/acis_cti_plot_only.perl 		Data7000");

system("/opt/local/bin/perl $bin_dir/acis_cti_find_outlayer.perl 	Data_adjust");
system("/opt/local/bin/perl $bin_dir/acis_cti_plot_only.perl 		Data_adjust");

system("/opt/local/bin/perl $bin_dir/acis_cti_find_outlayer.perl 	Data_cat_adjust");
system("/opt/local/bin/perl $bin_dir/acis_cti_plot_only.perl 		Data_cat_adjust");


#
#--- create detrended data set
#

system("/opt/local/bin/perl $bin_dir/acis_cti_make_detrend_data.perl");

system("/opt/local/bin/perl $bin_dir/acis_cti_det_adjust_cti.perl ");

system("/opt/local/bin/perl $bin_dir/acis_cti_det_comp_adjusted_cti.perl ");

#
#--- detrended cti plots start here
#

system("/opt/local/bin/perl $bin_dir/acis_cti_find_outlayer.perl 	Det_Data119");
system("/opt/local/bin/perl $bin_dir/acis_cti_det_plot_only.perl 	Det_Data119");

system("/opt/local/bin/perl $bin_dir/acis_cti_find_outlayer.perl 	Det_Data2000");
system("/opt/local/bin/perl $bin_dir/acis_cti_det_plot_only.perl 	Det_Data2000");

system("/opt/local/bin/perl $bin_dir/acis_cti_find_outlayer.perl 	Det_Data7000");
system("/opt/local/bin/perl $bin_dir/acis_cti_det_plot_only.perl 	Det_Data7000");

system("/opt/local/bin/perl $bin_dir/acis_cti_find_outlayer.perl 	Det_Data_adjust");
system("/opt/local/bin/perl $bin_dir/acis_cti_det_plot_only.perl 	Det_Data_adjust");

system("/opt/local/bin/perl $bin_dir/acis_cti_find_outlayer.perl 	Det_Data_cat_adjust");
system("/opt/local/bin/perl $bin_dir/acis_cti_det_plot_only.perl 	Det_Data_cat_adjust");

#
#--- slightly different plottings
#

system("/opt/local/bin/perl $bin_dir/acis_cti_new_plot_only.perl");
system("/opt/local/bin/perl $bin_dir/acis_cti_new_det_plot_only.perl");
system("/opt/local/bin/perl $bin_dir/acis_cti_new_det_plot_only_part.perl");

#
#----  update the html page
#

($usec, $umin, $uhour, $umday, $umon, $uyear, $uwday, $uyday, $uisdst)= localtime(time);

$year  = 1900   + $uyear;
$month = $umon  + 1;

$line = "<br><br><H3> Last Update: $month/$umday/$year</H3><br>";

open(OUT, ">$exc_dir/Working_dir/date_file");
print OUT "\n$line\n";
close(OUT);

system("cat $house_keeping/cti_page.html $exc_dir/Working_dir/date_file > $cti_www/cti_page.html");

#
#--- cleaning up
#

system("rm -rf $exc_dir/*");
