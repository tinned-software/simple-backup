#!/usr/bin/perl
#
# @author Gerhard Steinbeis (info [at] tinned-software [dot] net)
# @copyright Copyright (c) 2002 - 2013
$version_0 = "1.1";
# @license http://opensource.org/licenses/GPL-3.0 GNU General Public License, version 3
# @package backup
#

#################################
# Get script path               #
#################################
$script = $0;
@path_parts = split("\/",$script);
$path_parts[$#path_parts] = "";
$path = join("\/",@path_parts);
$script = "";
undef @path_parts;

$cmd_chmod = "/bin/chmod";
$cmd_chown = "/bin/chown";
$cmd_hostname = "/bin/hostname";
$cmd_find = "/usr/bin/find";
$cmd_rm = "/bin/rm";
$cmd_ls = "/bin/ls";
$cmd_date = "/bin/date";

$backup_function = $path."backup_function.pl";
$backup_error = $path."backup_error.pl";
$backup_user_archive = $path."backup_user_archive.pl";
$backup_help = $path."backup_help.txt";
$backup_config = $path."backup.conf";

######################################
##                                  ##
## PREPAIRING FOR BACKUP            ##
##                                  ##
######################################

#################################
# version information           #
#################################
if($ARGV[0] eq "-v"){
    print "\n";
    print "Backup Executeable\n";
    print "   Version $version_0\n";
    print "   Copyright 2000-2014 by Gerhard Steinbeis\n";
    require("$backup_function");
    require("$backup_error");
    require("$backup_user_archive");
    print "\nVERSION: $version_0$version_1$version_2$version_3\n";
    print "----------------------------------------------\n\n";
    open(FILE,"< $backup_help");
    while(<FILE>){
        print $_;
    }
    close FILE;
    print "\n\n";
    exit;
}


#################################
# copyrigth and version         #
#################################
$version_check = "1";
$version_1 = require("$backup_function");
$version_2 = require("$backup_error");
$version_3 = require("$backup_user_archive");
$version_check = "0";
$version_string =  "\nBackup script copyright 2000-2004 by Gerhard Steinbeis\n";
$version_string .=  "Backup script version: $version_0$version_1$version_2$version_3\n\n";
$line = $version_string;
$mail = $mail.$line;    ### mail_content
print $line;

#################################
# enviorement variables         #
#################################
if($ARGV[0] eq "-e"){
    foreach $key (sort keys %ENV) {
        print "$key = $ENV{$key}\n";
    }
    exit;
}



require("$backup_user_archive");
require("$backup_config");
open(STDERR, "> /dev/null");    #redirect error out
$exec_time_start = time;
$hostname =`$cmd_hostname`;
chop($hostname);


#################################
# Opening logfiles         #
#################################
$shell = `$cmd_date "+%Y_%m_%d_%H"`;
chop($shell);
$date = $shell.".log";
print "Opening Logfile \"$log_dir"."backup_$date\"\n\n";
open(LOGFILE,"> $log_dir"."backup_$date");
print LOGFILE "STARTING LOGFILE \n";


#################################
# get nr of backups             #
#################################
$nr = @source_dir;
$nr_a = @archive_name;
if ($nr_a ne $nr){
    $err_txt = "config error:\n   Error in configuration file.\n   number of source_dir and archiv_name not equal.";
    do($backup_error);
}
$nr = $nr - 1;


#################################
# execute scripts with "stop"   #
#################################
if ($scripts eq "1"){
    Script_Exec("stop");
}


#################################
# get date                      #
#################################
$shell = `$cmd_date "+%Y_%m_%d"`;
chop($shell);
$date = $shell."_";
$shell = `$cmd_date "+%H"`;
chop($shell);
$hour = $shell."_";
$shell = `$cmd_date "+%Y_%m"`;
chop($shell);
$month = $shell;


#################################
# get start time                #
#################################
$shell_t = `$cmd_date "+%H:%M:%S"`;
$shell_d = `$cmd_date "+%d.%m.%Y"`;
chop($shell_t);
chop($shell_d);
$line = "\n----$shell_d----$shell_t------------------------------------------\n";
$mail = $mail.$line;    ### mail_content
print $line;
print LOGFILE "$line";


#################################
# Debug Functio: ERROR          #
#################################
if($ARGV[0] eq "-err"){
    $err_txt = "Debug Function --> backup.pl -err";
    do($backup_error);
}


######################################
##                                  ##
## STARTING THE BACKUP              ##
##                                  ##
######################################
$i = 0;
$sub_dir = $month."/";
while($i <= $nr){
    $part_nr = 1 + $i."/";
    $part_nr2 = 1 + $nr;
    $part_nr = $part_nr.$part_nr2;
    $line = "\nPart: $part_nr ->  $source_dir[$i]\n";
    $mail = $mail.$line;        ### mail_content
    print $line;
	print LOGFILE "$line";
    mkdir($backup_dir.$sub_dir);
    $filename = $date.$hour.$archive_name[$i];
    do($backup_function);
   $i = $i +1;
}


#################################
# change owner of archives      #
#################################
$chown = "$cmd_chown -R $user $backup_dir*";
$shell = `$chown`;
$exit_value  = $? >> 8;
if($exit_value){
    $err_txt = "chown error:\n   $chown\n";
    do($backup_error);
}

#################################
# change chmod of archives      #
#################################
$chmod = "$cmd_chmod -R $permission $backup_dir*";
$shell = `$chmod`;
$exit_value  = $? >> 8;
if($exit_value){
    $err_txt = "chmod error:\n   $chmod\n";
    do($backup_error);
}

#################################
# change owner of md5 files      #
#################################
$chown = "$cmd_chown -R $user $md5_dir*";
$shell = `$chown`;
$exit_value  = $? >> 8;
if($exit_value){
    $err_txt = "chown error:\n   $chown\n";
    do($backup_error);
}


#################################
# change owner of logfiles      #
#################################
$chown = "$cmd_chown -R $user $log_dir*";
$shell = `$chown`;
$exit_value  = $? >> 8;
if($exit_value){
    $err_txt = "chown error:\n   $chown\n";
    do($backup_error);
}



#################################
# get stop time                 #
#################################
$shell_t = `$cmd_date "+%H:%M:%S"`;
$shell_d = `$cmd_date "+%d.%m.%Y"`;
chop($shell_t);
chop($shell_d);
$line = "\n---$shell_d---$shell_t------------------------------------------\n\n";
$mail = $mail.$line;    ### mail_content
print $line;
print LOGFILE "$line";


#################################
# delete old backup             #
#################################
if($rm_old eq "1"){
    ($year,$month,$day) = split ("_", $date);
    ($dec,$trash) = split("", $day);
    $dec_now = $dec;
    
    #print "checking for remove\n  date=$date  day=$day dec=$dec dec_now=$dec_now\n";
    
    if($date =~ /_\d\d\_\d0/){
        chdir "$backup_dir";
        $line = "Removing old backup ... \n";
        $mail = $mail.$line;            ### mail_content
        print $line;
	    print LOGFILE "$line";
        ### get the month and decade for deleting

        ### Decade 1
        $line = "";
        if ($dec == 1){
            $dec = "2";
            $month = $month - 1;
            if ($month == 0){ 
		$month = 12; 
		$year = $year - 1;
	    }
            if (length($month) < 2){ $month = "0$month"; }
            $date_rm = $year."_".$month."_".$dec;
            ### generate delete filelist
            $rm_list_command = "$cmd_find $backup_dir -maxdepth 2 | grep -E \"$date_rm\[123456789\]+.*\"";
            $rm_list = `$rm_list_command`;
            if($debug){ $line .= $rm_list_command."\n"; }
            
            ### if the month befor didnt have 30 days
            $dec = "1";
            $month = $month;
            if ($month == 0){ 
		$month = 12; 
		$year = $year - 1;
	    }
            if (length($month) < 2){ $month = "0$month"; }
            $date_rm = $year."_".$month."_".$dec;
            ### generate delete filelist
            $rm_list_command = "$cmd_find $backup_dir -maxdepth 2 | grep -E \"$date_rm\[123456789\]+.*\"";
            $rm_list .= `$rm_list_command`; 
            if($debug){ $line .= $rm_list_command."\n"; }
            $dec = "";
        }
        
        ### Decade 2
        if ($dec == 2){
            $dec = "3";
            $month = $month - 1;
            if ($month == 0){ 
		$month = 12; 
		$year = $year - 1;
	    }
            if (length($month) < 2){ $month = "0$month"; }
            $date_rm = $year."_".$month."_".$dec;
            ### generate delete filelist
            $rm_list_command = "$cmd_find $backup_dir -maxdepth 2 | grep -E \"$date_rm\[123456789\]+.*\"";
            $rm_list = `$rm_list_command`;
            if($debug){ $line .= $rm_list_command."\n"; }
            
            $dec = "0";
            $month = $month + 1;
            if ($month == 0){ 
		$month = 12; 
		$year = $year - 1;
	    }
            if (length($month) < 2){ $month = "0$month"; }
            $date_rm = $year."_".$month."_".$dec;
            ### generate delete filelist
            $rm_list_command = "$cmd_find $backup_dir -maxdepth 2 | grep -E \"$date_rm\[123456789\]+.*\"";
            $rm_list .= `$rm_list_command`;
            if($debug){ $line .= $rm_list_command."\n"; }
            $dec = "";
        }
        
        ### Decade 3
        if ($dec == 3){
            $dec = "1";
            $month = $month;
            if(length($month) < 2){ $month = "0$month"; }
            $date_rm = $year."_".$month."_".$dec;
            ### generate delete filelist
            $rm_list_command = "$cmd_find $backup_dir -maxdepth 2 | grep -E \"$date_rm\[123456789\]+.*\"";
            $rm_list .= `$rm_list_command`;
            if($debug){ $line .= $rm_list_command."\n"; }
            $dec = "";
        }
        
        $line .= $rm_list;
        $mail = $mail.$line;            ### mail_content
        print $line;
		print LOGFILE "$line";
		
			$exit_value  = $? >> 8;
        $rm_list =~ s/\n/ /g;
        if($rm_list =~ /$backup_dir/i){
            $rm_shell = "$cmd_rm $rm_list";
            if(!$debug){ $shell = `$rm_shell`; }
            $exit_value  = $? >> 8;
            if($exit_value){
                $err_txt = "rm error:\n   $rm_shell\n";
                do($backup_error);
            }
            $line = "done.\n\n";
            $mail = $mail.$line;            ### mail_content
			print $line;
		    print LOGFILE "$line";
        }
        else{
            $line = "No files to remove.\n\n";
            $mail = $mail.$line;            ### mail_content
            print $line;
		    print LOGFILE "$line";
        }
    }
}


#################################
# printing directory content    #
#################################
if($dir_content == "1"){
    $ll = "$cmd_ls -l $backup_dir";
    $shell_ll = `$ll`;
    $exit_value  = $? >> 8;
    if($exit_value){
        $err_txt = "ll error:\n   $ll\n";
        do($backup_error);
    }
    $ll = "$cmd_ls -l $backup_dir$sub_dir";
    $shell_ll2 = `$ll`;
    $exit_value  = $? >> 8;
    if($exit_value){
        $err_txt = "ll error:\n   $ll\n";
        do($backup_error);
    }
    $line =  "\n------------------------------------------------------------------\n";
    $line = $line."$shell_ll\n$shell_ll2\n------------------------------------------------------------------\n";
    $mail = $mail.$line;            ### mail_content
    print $line;
    print LOGFILE "$line";
}

#################################
# execute scripts with "start"  #
#################################
if ($scripts eq "1"){
    Script_Exec("start");
}



#################################
# calculate execution time      #
#################################
$exec_time_stop = time;
$exec_ime = $exec_time_stop - $exec_time_start;
($sec,$min,$hour) = gmtime($exec_ime);
$line = "\nEXECUTION: without errors in ";
if($hour < 10){ $line = $line."0"; }
$line = $line."$hour:";
if($min < 10){ $line = $line."0"; }
$line = $line."$min:";
if($sec < 10){ $line = $line."0"; }
$line = $line."$sec\n";
$mail = $mail.$line;    ### mail_content
print $line;
print LOGFILE "$line";


#################################
# copyrigth and version         #
#################################
$line = $version_string;
$mail = $mail.$line;    ### mail_content
print $line;
print LOGFILE "$line";


#################################
# sending notification mail     #
#################################
if($send_mail > 0){
    if($date =~ /_\d\d\_\d0/i || $send_mail > 1){
        open (MAIL, "| /usr/lib/sendmail -t");
        print MAIL "To: $email\n";
        print MAIL "From: $from_email\n";
        print MAIL "Subject: Backup_$date_$hostname\n\n";
        print MAIL "Backup Dir: $backup_dir\n\n";
        print MAIL "Script printout:\n\n$mail";
        print MAIL "-------------------------------------------------------------\n";
        close MAIL;
    }
}


close STDERR;    #redirect error out
#$rm_ErrOut = `rm dev_null`; #delete STDERR redirect file

#################################
# Script Execution function     #
#################################
sub Script_Exec {
   my $mode = shift;
   $line = "--- EXECUTING SCRIPTS WITH $mode ---------------------------------\n";
   foreach $command (@commands){
      if($j) { $line = $line."\n------------------------------------------------------------------\n";}
      $line = $line."EXEC: $command $mode\n";
      $shell = `$command $mode`;
      $line = $line.$shell;
      $j = 1;
   }
   $line = $line."\n------------------------------------------------------------------\n";
   $mail = $mail.$line;
   print $line;
   print LOGFILE "$line";
}


