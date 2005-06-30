#!/usr/bin/perl

##############################################################################

#########################################
#--- set directories
#
$cti_www       = '/data/mat/www/mt_cti/';
$cti_www       = '/data/mta/www/mta_cti/Test2/';

$house_keeping = '/house_keeping/';

$exc_dir       = '/data/mta/Script/ACIS/CTI/Exc/';
$exc_dir       = '/data/mta/Script/ACIS/CTI/Temp/';

$bin_dir       = '/data/mta4/MTA/bin';
$bin_dir       = '/data/mta/Script/ACIS/CTI/Temp/Script';

$ftools        = '/home/ascds/DS.release/otsbin/';

#
#########################################

#
#--- create a directoy infromation file to be read by all perl script
#

open(OUT, '>./dir_list');
print OUT "$cti_www\n";		#a directory where all output go
print OUT "$house_keeping\n";	#a directory where records are kept
print OUT "$exc_dir\n";		#a directory where computations are done	
print OUT "$bin_dir\n";		#a directory where scripts are kept
print OUT "$ftools\n";		#a directory where ftools are kept
close(OUT);

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
system("perl $bin_dir/acis_cti_find_new_entry.perl");

system("perl $bin_dir/acis_cti_get_data.perl ");
#
#--- check a focal plane temp so that we can discreminate cti depending on temp
#
system("perl $bin_dir/acis_cti_find_time_temp_range.perl");
#
#--- recmpute cti according to temperature difference
#
system("perl $bin_dir/acis_cti_manual_cti.perl ");
#
#--- compute detrending factor
#
system("perl $bin_dir/acis_cti_detrend_factor.perl");
#
#--- create several data sets (e.g. temperature and/or time)
#
system("perl $bin_dir/acis_cti_adjust_cti.perl ");
#
#--- compute adjustment factor for temeprature depended cti
#
system("perl $bin_dir/acis_cti_comp_adjusted_cti.perl ");

#
#--- cti plottings start here
#
system("perl $bin_dir/acis_cti_find_outlayer.perl 	Data119");
system("perl $bin_dir/acis_cti_plot_only.perl 		Data119");

system("perl $bin_dir/acis_cti_find_outlayer.perl 	Data2000");
system("perl $bin_dir/acis_cti_plot_only.perl 		Data2000");

system("perl $bin_dir/acis_cti_find_outlayer.perl 	Data7000");
system("perl $bin_dir/acis_cti_plot_only.perl 		Data7000");

system("perl $bin_dir/acis_cti_find_outlayer.perl 	Data_adjust");
system("perl $bin_dir/acis_cti_plot_only.perl 		Data_adjust");

system("perl $bin_dir/acis_cti_find_outlayer.perl 	Data_cat_adjust");
system("perl $bin_dir/acis_cti_plot_only.perl 		Data_cat_adjust");


#
#--- create detrended data set
#

system("perl $bin_dir/acis_cti_make_detrend_data.perl");

system("perl $bin_dir/acis_cti_det_adjust_cti.perl ");

system("perl $bin_dir/acis_cti_det_comp_adjusted_cti.perl ");

#
#--- detrended cti plots start here
#

system("perl $bin_dir/acis_cti_find_outlayer.perl 	Det_Data119");
system("perl $bin_dir/acis_cti_det_plot_only.perl 	Det_Data119");

system("perl $bin_dir/acis_cti_find_outlayer.perl 	Det_Data2000");
system("perl $bin_dir/acis_cti_det_plot_only.perl 	Det_Data2000");

system("perl $bin_dir/acis_cti_find_outlayer.perl 	Det_Data7000");
system("perl $bin_dir/acis_cti_det_plot_only.perl 	Det_Data7000");

system("perl $bin_dir/acis_cti_find_outlayer.perl 	Det_Data_adjust");
system("perl $bin_dir/acis_cti_det_plot_only.perl 	Det_Data_adjust");

system("perl $bin_dir/acis_cti_find_outlayer.perl 	Det_Data_cat_adjust");
system("perl $bin_dir/acis_cti_det_plot_only.perl 	Det_Data_cat_adjust");

#
#--- slightly different plottings
#

system("perl $bin_dir/acis_cti_new_plot_only.perl");
system("perl $bin_dir/acis_cti_new_det_plot_only.perl");
system("perl $bin_dir/acis_cti_new_det_plot_only_part.perl");

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

system("cat $cti_www/$house_keeping/cti_page.html $exc_dir/Working_dir/date_file >> $cti_www/cti_page.html");

#
#--- cleaning up
#

system("rm ./dir_list");
system("rm -rf $exc_dir/Working_dir");
