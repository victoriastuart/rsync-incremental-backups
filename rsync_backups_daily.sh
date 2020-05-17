#!/bin/bash
# vim: set filetype=sh :
# vim: syntax=sh
export LANG=C.UTF-8
# =============================================================================
#          file: /home/victoria/backups/rsync/rsync_backups_daily.sh
#         title: HOURLY rsync backup script
#       created: 2020-04-29
#       version: 02
# last modified: 2020-05-12 08:15:21 -0700 (PST)
#      versions:
#         * v01: inaugural
#         * v02: 
#      see also: /home/victoria/backups/rsync/__readme-victoria-custom_rsync_backups.txt
# add. comments: backups/rsync/rsync_backups_hourly.sh
# =============================================================================

# ----------------------------------------
## SCHEDULE (/etc/crontab):

# /home/victoria/backups/rsync/rsync_backups_hourly.sh
#    hourly.x : 4 am | 6 pm | midnight {hourly.0 | hourly.1 | hourly.2}
#               hourly.0 always the most recent hourly.x; hourly.2 always the oldest hourly.x

# /home/victoria/backups/rsync/rsync_backups_daily.sh
#     daily.x : 3 am daily (daily.0 .. daily.6)

# /home/victoria/backups/rsync/rsync_backups_weekly.sh
#    weekly.x : 2 am each Mon (weekly.0 .. weekly.3)

# /home/victoria/backups/rsync/rsync_backups_monthly.sh
#   monthly.x : 1 am first day of each month (monthly.00 .. monthly.11)

# /home/victoria/backups/rsync/rsync_backups_yearly.sh
#   yearly.x :  midnight Dec 31 (minute 0 on Jan 01) (yearly.00 .. yearly.10)

# ----------------------------------------------------------------------------
# /etc/crontab
# https://crontab.guru/

# m   h          dom    mon    dow    user        nice          command
# Midnight Dec 31 (at minute 0 on Jan 01, annually):
# 0   0          1      1      *      root        nice -n 19    /home/victoria/backups/rsync/rsync_backups_yearly.sh
# 1 am (01:00 on day 1 of every month, Jan-Dec):
# 0   1          1      1-12   *      root        nice -n 19    /home/victoria/backups/rsync/rsync_backups_monthly.sh
# 2 am (02:00 each Monday):
# 0   2          *      *      1      root        nice -n 19    /home/victoria/backups/rsync/rsync_backups_weekly.sh
# 3 am each day:
# 0   3          *      *      *      root        nice -n 19    /home/victoria/backups/rsync/rsync_backups_daily.sh
# 4 am, noon, 6 pm (3x) daily:
# 0   4,12,18    *      *      *      root        nice -n 19    /home/victoria/backups/rsync/rsync_backups_hourly.sh
# ============================================================================

# ----------------------------------------------------------------------------
## LOGFILE:

# https://stackoverflow.com/questions/25833676/redirect-echo-output-in-shell-script-to-logfile
exec >> /home/victoria/backups/rsync/rsync.log 2>&1

echo '=============================================================================='
echo '/home/victoria/backups/rsync/rsync.log'
printf "`date +'%Y-%m-%d (%H:%M:%S)'`: START DAILY\n"

# INCREMENT:
printf "`date +'%Y-%m-%d (%H:%M:%S)'`: cp daily.x --> daily.x+1\n"
rm -fr /mnt/Backups/rsync_backups/daily.6
mv 2>/dev/null /mnt/Backups/rsync_backups/daily.5/ /mnt/Backups/rsync_backups/daily.6
mv 2>/dev/null /mnt/Backups/rsync_backups/daily.4/ /mnt/Backups/rsync_backups/daily.5
mv 2>/dev/null /mnt/Backups/rsync_backups/daily.3/ /mnt/Backups/rsync_backups/daily.4
mv 2>/dev/null /mnt/Backups/rsync_backups/daily.2/ /mnt/Backups/rsync_backups/daily.3
mv 2>/dev/null /mnt/Backups/rsync_backups/daily.1/ /mnt/Backups/rsync_backups/daily.2
mv 2>/dev/null /mnt/Backups/rsync_backups/daily.0/ /mnt/Backups/rsync_backups/daily.1

# COPY:
printf "`date +'%Y-%m-%d (%H:%M:%S)'`: cp hourly.2 --> daily.0\n"
## https://stackoverflow.com/questions/1529946/linux-copy-and-create-destination-dir-if-it-does-not-exist 
# mkdir -p /mnt/Backups/rsync_backups/daily.0 && cp 2>/dev/null -al /mnt/Backups/rsync_backups/hourly.2/ /mnt/Backups/rsync_backups/daily.0
cp 2>/dev/null -al /mnt/Backups/rsync_backups/hourly.2/ /mnt/Backups/rsync_backups/daily.0

printf "`date +'%Y-%m-%d (%H:%M:%S)'`: END DAILY\n"

# printf '%s----------------------------------------\nCumulative disk use:\n'
# Sort by size (sort -h)
# Sort by path (sort):
# du 2>/dev/null -h -d 1 /mnt/Backups/rsync_backups/ | sort
# df -h /mnt/Backups/rsync_backups/
# printf '%s----------------------------------------\n'

# ============================================================================

