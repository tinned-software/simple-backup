#!/bin/bash
#
# @author Gerhard Steinbeis (info [at] tinned-software [dot] net)
# @copyright Copyright (c) 2002 - 2013
version=0.3
# @license http://opensource.org/licenses/GPL-3.0 GNU General Public License, version 3
# @package backup
#

#
# Parse all parameters
#
EXTRACT="0"
HELP=0
while [ $# -gt 0 ]; do
	case $1 in
    	# General parameter
        -h|--help)
			HELP=1
			shift
            ;;
        -v|--version)
            echo "`basename $0` version $version"
            exit 0
            ;;

        --extract)
            EXTRACT="1"
            shift
            ;;

        *)
			SEARCH=$1
			shift
			;;
    esac
done

if [[ -z "${SEARCH}" ]]; then
	HELP=1
fi

# show help message
if [ "$HELP" -eq "1" ]; then
	echo 
	echo "This script is searching the given pattern in the file list of all "
	echo "\"*.tar.gz\" archives in the current directory. The search pattern "
	echo "has to be compliant with the \"grep\" pattern. The search finds the "
	echo "pattern in the filename or file path. The matching lines from the "
	echo "file list are shown to the console."
	echo 
	echo "Usage: `basename $0` [-hv] search_pattern"
  	echo "  -h  --help         print this usage and exit"
	echo "  -v  --version      print version information and exit"
	echo "      --extract      extract the found files from archives"
	echo 
	exit 1
fi



# get the list of all .tar.gz files
FILE_LIST=`find . -type f -name '*.tar.gz'`
for FILE in $FILE_LIST
do
    # search the archive using tar
    echo -n "*** Search for "$SEARCH" in archive $FILE ... "
    SEARCH_RESULT=`tar -tzf $FILE | grep $SEARCH`
    if [ "$SEARCH_RESULT" == "" ] 
    then
        echo "Nothing Found"
    else
        echo "Found"
        echo "$SEARCH_RESULT"
        if [[ "$EXTRACT" == "1" ]]; then
        	echo -n "*** Extract files from archive $FILE ... "
    	    EXTRACT_RESULT=`tar -xzvf $FILE $SEARCH_RESULT 2>&1`
    	    echo "Done"
    	    echo "$EXTRACT_RESULT"
        fi
    fi
done

echo "Finished search!"
