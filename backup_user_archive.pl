#!/usr/bin/perl
#
# @author Gerhard Steinbeis (info [at] tinned-software [dot] net)
# @copyright Copyright (c) 2014
$version_3 = ".01";
# @license http://opensource.org/licenses/GPL-3.0 GNU General Public License, version 3
# @package backup
#

# Return version information
if($version_check eq "1") {return $version_1;}
if($ARGV[0] eq "-v"){
    print "\n";
    print "Backup User Archive Config\n";
    print "   Version 0$version_3\n";
    print "   Copyright 2014 by Gerhard Steinbeis\n";
    return true;
}

# create archive for each user directory
#
# This subroutine will generate a seperate configuration item for each 
# directory under /home/. This result in seperate archives for each users. 
# Just call the subroutine from within the "Backup directories" section.
#
# user_archives();
#
sub user_archives {
    # get the directories of the users
    $shell_find = `find /home/* -maxdepth 0 -type d`;
    $exit_value  = $? >> 8;
    if($exit_value){
        $err_txt = "(config) find error:\n   $find\n";
        do($backup_error);
    }
    
    #Create configuration details fro each home directory
    @folders = split("\n",$shell_find);
    foreach $directory (@folders){
        $bc                     = $bc + 1;
        $source_dir[$bc]        = $directory;
        $directory =~ s/\//_/g;
        $directory =~ s/^_//;
        $archive_name[$bc]      = $directory;
        $ignore_pattern[$bc]    = "";
    }
}

1;
