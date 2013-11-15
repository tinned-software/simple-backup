## Simple-Backup

The Simple-Backup is written in perl and was created by me around 2002. I used it quite a lot in the last year and maybe it is as useful for you as it is for me.

This Simple-Backup script aims to backup the configured directories into tar gz archives. The list of functionality includes the following:

*     Backup of multiple configured directories into individual archives
*     Date stamped archive name with year, month, day and hour. This allows hourly backups
*     Backups organised in monthly folders
*     Incremental backups to save disc space where the initial backup is a full backup
*     Automatic full backups every 10. and 20. and 30. of the month to be able to cleanup incremental backups
*     Automatic deletion of incremental backups between the last full backup and the full backup before
*     Execution of scripts before the backup procedure with stop parameter and afterwards with start which can be used to stop services before backup if necessary
*     Excluding files from the backup using regular expression
*     Email notification after backup which can be configured to be sent always or only on error
*     Individual log-files for each backup run


### Download & Installation

![image](http://www.tinned-software.net/images/icons/download.png) **[Download Download Simple-Backup from Github](https://github.com/tinned-software/simple-backup)**

To install the the script download it from Github and upload it to your server. Copy the file "**backup_example.conf**" to "**backup.conf**" and change its configuration values. The configuration file contains a description for its configuration items. To start a backup run execute the "backup.pl" file.

### Description

This Simple-Backup script is configured with a configuration file currently located in the same directory as the script itself. The configuration file contains a number of configuration items which are documented directly in the configuration file. You can configure a list of directories to backup. When the backup script is running it will check the files in this directory and create a md5 checksum of each file. The checksum of every file is compared to the checksum from the last backup run. If it is different, the file will be marked for backup. At the end of the compare process the list with the new md5 sums as well as a list of files to backup is written and archived together with the files itself.

The configuration allows you to define if you want to create incremental backups or not as well as the possibility to create a full backup every 10. 20 and 30. of the month. If you define it, the backup script can delete incremental backups. Deleting of the backups works like that. If the script runs on the 30. the incremental backups from the 11. to the 19. are deleted. That procedure allows you to always having the full backups and at least the last 10 days of incremental backups.
