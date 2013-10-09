#!/bin/bash
#
# @author Gerhard Steinbeis (info [at] tinned-software [dot] net)
# @copyright Copyright (c) 2002 - 2013
# @version 0.5
# @license http://opensource.org/licenses/GPL-3.0 GNU General Public License, version 3
# @package backup
#  

# configure installation path
INSTALLPATH=/usr/backup

# copy files to the root directory
mkdir $INSTALLPATH
cp -f -v *.pl $INSTALLPATH/
cp -f -v *.sh $INSTALLPATH/
chmod a+x $INSTALLPATH/*.pl
chmod a+x $INSTALLPATH/*.sh
cp -f -v *.txt $INSTALLPATH/
cp -f -v backup_example.conf $INSTALLPATH/backup_example.conf
chown root:root $INSTALLPATH/*


