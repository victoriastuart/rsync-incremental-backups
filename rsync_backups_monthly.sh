#!/bin/bash
# vim: set filetype=sh :
# vim: syntax=sh
export LANG=C.UTF-8
# =============================================================================
#          file: /home/victoria/backups/rsync/rsync_backups_monthly.sh
#         title: HOURLY rsync backup script
#       created: 2020-04-29
#       version: 02
# last modified: 2020-05-12 08:15:07 -0700 (PST)
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
## SCRIPT

# ----------------------------------------------------------------------------
## LOGFILE:

# https://stackoverflow.com/questions/25833676/redirect-echo-output-in-shell-script-to-logfile
exec >> /home/victoria/backups/rsync/rsync.log 2>&1

## https://stackoverflow.com/questions/17840322/how-to-undo-exec-dev-null-in-bash
## Undo echo to logfile:
# exec >/dev/tty

echo '=============================================================================='
echo '/home/victoria/backups/rsync/rsync.log'
printf "`date +'%Y-%m-%d (%H:%M:%S)'`: START MONTHLY\n"

# INCREMENT:
printf "`date +'%Y-%m-%d (%H:%M:%S)'`: cp monthly.x --> monthly.x+1\n"
rm -fr /mnt/Backups/rsync_backups/monthly.11
mv 2>/dev/null /mnt/Backups/rsync_backups/monthly.10/ /mnt/Backups/rsync_backups/monthly.11
mv 2>/dev/null /mnt/Backups/rsync_backups/monthly.09/ /mnt/Backups/rsync_backups/monthly.10
mv 2>/dev/null /mnt/Backups/rsync_backups/monthly.08/ /mnt/Backups/rsync_backups/monthly.09
mv 2>/dev/null /mnt/Backups/rsync_backups/monthly.07/ /mnt/Backups/rsync_backups/monthly.08
mv 2>/dev/null /mnt/Backups/rsync_backups/monthly.06/ /mnt/Backups/rsync_backups/monthly.07
mv 2>/dev/null /mnt/Backups/rsync_backups/monthly.05/ /mnt/Backups/rsync_backups/monthly.06
mv 2>/dev/null /mnt/Backups/rsync_backups/monthly.04/ /mnt/Backups/rsync_backups/monthly.05
mv 2>/dev/null /mnt/Backups/rsync_backups/monthly.03/ /mnt/Backups/rsync_backups/monthly.04
mv 2>/dev/null /mnt/Backups/rsync_backups/monthly.02/ /mnt/Backups/rsync_backups/monthly.03
mv 2>/dev/null /mnt/Backups/rsync_backups/monthly.01/ /mnt/Backups/rsync_backups/monthly.02
mv 2>/dev/null /mnt/Backups/rsync_backups/monthly.00/ /mnt/Backups/rsync_backups/monthly.01

# COPY:
printf "`date +'%Y-%m-%d (%H:%M:%S)'`: cp weekly.3 --> monthly.00\n"
# https://stackoverflow.com/questions/1529946/linux-copy-and-create-destination-dir-if-it-does-not-exist
cp 2>/dev/null -al /mnt/Backups/rsync_backups/weekly.3/ /mnt/Backups/rsync_backups/monthly.00

printf "`date +'%Y-%m-%d (%H:%M:%S)'`: END MONTHLY\n"

# printf '%s----------------------------------------\nCumulative disk use:\n'
# Sort by size (sort -h)
# Sort by path (sort):
# du 2>/dev/null -h -d 1 /mnt/Backups/rsync_backups/ | sort
# df -h /mnt/Backups/rsync_backups/
# printf '%s----------------------------------------\n'

# ============================================================================

