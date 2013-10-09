#!/usr/bin/perl
#
# @author Gerhard Steinbeis (info [at] tinned-software [dot] net)
# @copyright Copyright (c) 2002 - 2013
$version_1 = ".18";
# @license http://opensource.org/licenses/GPL-3.0 GNU General Public License, version 3
# @package backup
#

######################################
##                                  ##
## BACKUP CHANGED FILES             ##
##                                  ##
######################################

#
$cmd_md5 = "/usr/bin/md5sum";
#$cmd_md5 = "/sbin/md5 -r";      ### use -r option for MacOSX
$cmd_find = "/usr/bin/find";
$cmd_grep = "/bin/grep";
$sys_MacOSX = 1;                ### Set if MacOSX is used. (tar bug)
$cmd_tar = "/bin/tar";

if($version_check eq "1") {return $version_1;}
if($ARGV[0] eq "-v"){
    print "\n";
    print "Backup Changed Files\n";
    print "   Version 0$version_1\n";
    print "   Copyright 2000-2013 by Gerhard Steinbeis\n";
    return true;
}

# $filename, $backup_dir, $source_dir[$i], $archive_name[$i]

#################################
# get list of backuped files    #
#################################
$line = "getting old backup list ... ";
$file_list_md5 = "$md5_dir$archive_name[$i].md5";
$file_list_pk = "$md5_dir$archive_name[$i].pklist";
$mail = $mail.$line;		### mail_content
print $line;
print LOGFILE "$line";
undef @file_list;
undef @file_names;
open(FILE,"< $file_list_md5");
while(<FILE>){
    chop($_);
    push @file_list, $_;
    ($file_md5,$file_name) = split (" ",$_);
    push @file_names, $file_name;
}
close FILE;
$line = 1 + $#file_list." files.\n";
$mail = $mail.$line;		### mail_content
print $line;
print LOGFILE "$line";


#################################
# get files or backup           #
#################################
$line = "finding files ... ";
$mail = $mail.$line;		### mail_content
print $line;
print LOGFILE "$line";
$find = "$cmd_find $source_dir[$i] -type f";
if($ignore_pattern[$i] ne ""){
    $find = $find." | $cmd_grep -v -E \"/".$ignore_pattern[$i]."\"";
}
$shell_find = `$find`;
$exit_value  = $? >> 8;
if($exit_value){
    $err_txt = "find error:\n   $find\n";
    do($backup_error);
}
@files = split("\n",$shell_find);
$line = 1 + $#files." found.\n";
$mail = $mail.$line;		### mail_content
print $line;
print LOGFILE "$line";


#################################
# finding changed files         #
#################################
$line = "checking for changed files ... ";
$mail = $mail.$line;		### mail_content
print $line;
print LOGFILE "$line";
undef @backup_files;
undef @new_list;
LOOP:foreach $file (@files){
    if($debug == "3"){ next LOOP; }
    $file =~ s/\\/\\\\/i;
    $md5 = "$cmd_md5 \"$file\"";
    $shell_md5 = `$md5`;
    $exit_value  = $? >> 8;
    if($exit_value){
        $err_txt = "md5 error:\n   $md5\n";
        do($backup_error);
    }
    chop($shell_md5);
    push @new_list, $shell_md5;
    $found = 0;

    # check if complete backup has to be made
    if($date !~ /_\d\d\_\d0/i || !$dec_complete){
        for($nr_b=0; $nr_b<=$#file_list; $nr_b++){
            # remove braekets as they are used in bsd's md5
            $file_names[$nr_b] =~ s/^\s*\(//i;
            $file_names[$nr_b] =~ s/\)\s*$//i;
            # compare filenames
            #if($debug == "2"){ print "     - Compare: $file == $file_names[$nr_b] ($nr_b) \n"; }            
            if($file eq $file_names[$nr_b] && $file_names[$nr_b] ne "" ){
                if($shell_md5 ne $file_list[$nr_b]){
                    push @backup_files, $file;
                    if($debug == "2"){ print "CHANGED: $nr_b / $#file_list -- $#backup_files -- $shell_md5\n$file_list[$nr_b]\n"; }
                    $found = 1;
                    next LOOP;
                }
                $found = 1;
                if($debug == "2"){ print "OK: $nr_b / $#file_list -- $shell_md5\n"; }
                next LOOP;
            }
        }
    }
    if($found == 0){
        push @backup_files, $file;
        if($debug == "2"){ print "NEW: -- $#backup_files -- $shell_md5\n"; }
    }
}
$line = 1 + $#backup_files." changed files.\n";
$mail = $mail.$line;		### mail_content
print $line;
print LOGFILE "$line";


#################################
# writing md5 list file         #
#################################
$line = "writing new backup list ... ";
$mail = $mail.$line;		### mail_content
print $line;
print LOGFILE "$line";
if(!$debug){ 
    open(FILE,"> $file_list_md5");
    for($j=0; $new_list[$j]; $j++){
        print FILE "$new_list[$j]\n";
    }
    close FILE;
}
$line = 1 + $#new_list." files.\n";
$mail = $mail.$line;		### mail_content
print $line;
print LOGFILE "$line";


#################################
# writing packing list file     #
#################################
$line = "writing packing list ... ";
$mail = $mail.$line;		### mail_content
print $line;
print LOGFILE "$line";
if(!$debug){ 
    open(FILE,"> $file_list_pk");
    for($j=0; $backup_files[$j]; $j++){
        print FILE "$backup_files[$j]\n";
    }
    print FILE "$file_list_md5\n";
    print FILE "$file_list_pk\n";
    close FILE;
}
$line = 1 + $#backup_files." files.\n";
$mail = $mail.$line;		### mail_content
print $line;
print LOGFILE "$line";


#################################
# Adding files to archive       #
#################################
$line = "adding files to archive ... ";
$mail = $mail.$line;		### mail_content
print $line;
print LOGFILE "$line";
$fcount = 0;
open(STDERR, "<", \$errout);
$tar = "$cmd_tar -czf ".$backup_dir.$sub_dir.$filename.".tar.gz -T $file_list_pk";
if(!$debug){ $shell_tar = `$tar`; }
$exit_value  = $? >> 8;
if($exit_value){
    #
    # Only for MacOSX port of tar
    # However it still sets return code 2 for some infrequent conditions even 
    # with --ignore-failed-read option. This results in thinking the total 
    # archive is bad, and drops the complete archive. Those conditions are very 
    # rare on a quiet filesystem.
    #
    if($sys_MacOSX ne 1 || ($sys_MacOSX eq 1 && $exit_value ne 2)){
        $err_txt = "tar error ($exit_value):\n   $tar\n$shell_tar\n";
        do($backup_error);
    }
}
else{
    
}
close(STDERR);
$line = 1 + $#backup_files." files added.\n";
$mail = $mail.$line;		### mail_content
print $line;
print LOGFILE "$line";



