#!/usr/bin/perl
#
# @author Gerhard Steinbeis (info [at] tinned-software [dot] net)
# @copyright Copyright (c) 2002 - 2013
$version_2 = ".10";
# @license http://opensource.org/licenses/GPL-3.0 GNU General Public License, version 3
# @package backup
#

#$cmd_sendmail = "/usr/lib/sendmail";
$cmd_sendmail = "/usr/sbin/sendmail";

######################################
##                                  ##
## ERROR MESSAGES                   ##
##                                  ##
######################################
if($version_check eq "1") {return $version_2;}
if($ARGV[0] eq "-v"){
    print "\n";
    print "Backup Error Handling\n";
    print "   Version 0$version_2\n";
    print "   Copyright 2000-2013 by Gerhard Steinbeis\n";
    return true;
}

# $err_text

#################################
# Error message and mail        #
#################################
$line = "\n\nERROR:$err_txt\n\n\n";
$mail = $mail.$line;
print $line;
print LOGFILE "$line";
Script_Exec("start");
open (MAIL, "| $cmd_sendmail -t");
print MAIL "From: $from_email\n";
print MAIL "To: $email\n";
print MAIL "Subject: ALERT: Backup_$date_$hostname\n";
print MAIL "Content-Type: text/plain\n";
print MAIL "MIME-Version: 1.0\n";
print MAIL "X-Mailer: Backup script\n";
print MAIL "X-Priority: 1 (Highest)\n\n";
print MAIL "Backup Dir: $backup_dir\n\n";
print MAIL "Script printout:\n\n$mail";
print MAIL "\n\n<<<<<<<<<<>>>>>>>>>><<<<<<<<<<>>>>>>>>>><<<<<<<<<<>>>>>>>>>>\n\n";
foreach $key (sort keys %ENV) {
    print MAIL "$key = $ENV{$key}\n";
}
print MAIL "\r\n.\r\n";
close MAIL;

# Debug mail sending
print LOGFILE "OPEN \"| $cmd_sendmail -t\" ... \n";
print LOGFILE "From: $from_email\n";
print LOGFILE "To: $email\n";
print LOGFILE "Subject: ALERT: Backup_$date_$hostname\n";
print LOGFILE "Content-Type: text/plain\n";
print LOGFILE "MIME-Version: 1.0\n";
print LOGFILE "X-Mailer: Backup script\n";
print LOGFILE "X-Priority: 1 (Highest)\n\n";
print LOGFILE "Backup Dir: $backup_dir\n\n";
print LOGFILE "Script printout:\n\n$mail";
print LOGFILE "\n\n<<<<<<<<<<>>>>>>>>>><<<<<<<<<<>>>>>>>>>><<<<<<<<<<>>>>>>>>>>\n\n";
foreach $key (sort keys %ENV) {
    print LOGFILE "$key = $ENV{$key}\n";
}
print LOGFILE "\n.\n";

exit 1;

