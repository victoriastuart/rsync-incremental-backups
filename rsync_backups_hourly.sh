#!/bin/bash
# vim: set filetype=sh :
# vim: syntax=sh autoindent tabstop=4 shiftwidth=4 expandtab softtabstop=4 textwidth=220
export LANG=C.UTF-8
# =============================================================================
#          file: /home/victoria/backups/backups/rsync/rsync_backups_hourly.sh
#         title: HOURLY rsync backup script
#       created: 2020-04-27
#       version: 05
# last modified: 2020-05-17 08:46:17 -0700 (PST)
#      versions:
#         * v01: inaugural
#         * v02: debugging; added rsync PID concurrency check (mutt notification if existing rsync process)
#         * v02: switched from mv to rsync for moving previous backups: issue was nested (recursive) copies;
#                see https://superuser.com/questions/623392/replace-existing-folder-with-mv-command
#         * v03: debugging (cp -rfl), incremental copies, still nested; addressed in "rsync_backups_hourly-v04.sh"
#                based on "/home/victoria/backups/rsync/old, bak/rsync.log.2020.04.30"
#         * v04: rm -fr oldest backup then incrementally mv older back in all except hourly (where I rsync, here
#                only) system files to hourly.0 (on other scripts: daily, weekly, monthly, yearly) I "cp -al ..."
#                the oldest preceding backup (e.g. hourly.2 to daily.0; daily.6 to weekly.0; ...).
#         * v05: 
#      see also: /home/victoria/backups/rsync/__readme-victoria-custom_rsync_backups.txt
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

# ----------------------------------------
## REFERENCE

# List of standard rsync exit codes
# https://lxadm.com/Rsync_exit_codes

# rsync
# https://wiki.archlinux.org/index.php/Rsync

# ----------------------------------------
## COMMAND ARGUMENTS:

# 2>/dev/null :
#   send errors to /dev/null

# cp (use -al not -fR):
#   -fR : complete copy [SLOW; LARGE footprint (du)]
#   -al : archive as links [FAST; SMALL footprint (du)]
#   -a  : --archive | same as -dR --preserve=all
#   -l  : --link : hard link files instead of copying

# mkdir -p
#   -p, --parents : make parent directories as needed (no error if exists)
#     https://stackoverflow.com/questions/793858/how-to-mkdir-only-if-a-dir-does-not-already-exist
#     https://stackoverflow.com/questions/1529946/linux-copy-and-create-destination-dir-if-it-does-not-exist

# If needed (break command over lines; note: "break," "\",  before "&&"):
#   https://unix.stackexchange.com/questions/281309/shell-syntax-how-to-correctly-use-to-break-lines
#
#   mkdir -p /mnt/Backups/rsync_backups/hourly.0 \
#     && rsync 2>/dev/null -a \
#     --exclude-from=/home/victoria/backups/rsync/rsync_excludes.txt \
#     / /mnt/Backups/rsync_backups/hourly.0 

# rsync :
#   -a  : --archive : equivalent to -rlptgoD (no -H,-A,-X)
#                     It is a quick way of saying you want recursion and want to
#                     preserve almost everything (with  -H  being  a notable omission).  The only exception
#                     to the above equivalence is when --files-from is specified, in which case -r is not implied.
#                     Note that -a does not preserve hardlinks, because finding multiply-linked files is expensive.
#                     You must separately specify -H.
#       -r, --recursive     recurse into directories
#       -l, --links         copy symlinks as symlinks
#       -p, --perms         preserve permissions
#       -t, --times         preserve modification times
#       -g, --group         preserve group
#       -o, --owner         preserve owner (super-user only)
#       -D                  same as --devices --specials
#
#       -H, --hard-links    reserve hard links
#       -A, --acls          preserve ACLs (implies -p)
#       -X, --xattrs        preserve extended attributes
# -q, --quiet         suppress non-error messages
# -v, --verbose       increase verbosity
#     --info=FLAGS    fine-grained informational verbosity
#     --debug=FLAGS   fine-grained debug verbosity
#     --msgs2stderr   special output handling for debugging
# --exclude-from=FILE	: read exclude patterns from FILE

# time :
#   -f : format, --format=format | specify output format
#   %E : elapsed real time (in [hours:]minutes:seconds)
# However: can't use 'time ...' in a script (terminal only); e.g. this causes the entire line to fail:
#   time -f %E /usr/bin/mv 2>/dev/null /mnt/Backups/rsync_backups/hourly.1/ /mnt/Backups/rsync_backups/hourly.2

# ----------------------------------------
## DELETE?

# Sometimes you might want to delete extra files in your backups. The "-- delete" option
# tells rsync to delete files in the DEST directory that is not also present in the SRC directory.
#   #   rsync -a --delete --exclude-from=...
#
# I've thought about this:
#   (a) synchronized backups (--delete) are simply mirror copies of SRC; if you delete (accidentally otherwise)
#       a file on SRC, then those deletions incrementally (silently) propagate through the backups;
#   (b) asynchronous backups are better from a safety / accidental deletions viewpoint, but they may bloat,
#       somewhat, over time as the depth of the backups progresses.
# I toyed with the idea of a (e.g.) once-weekly "--delete" backup,
#
#   # Once a week "clean" hourly.0 to delete files in hourly.0 not present on SRC:
#   # [the rest of the week 
#     if [ "$day" == "Sunday" ] ;then
#      rsync 2>/dev/null -a --delete --exclude-from=/home/victoria/backups/rsync/rsync_excludes.txt / /mnt/Backups/rsync_backups/hourly.0
#    else
#      rsync 2>/dev/null -a --exclude-from=/home/victoria/backups/rsync/rsync_excludes.txt / /mnt/Backups/rsync_backups/hourly.0
#    fi
#
# or (probably better) scheduling an occasional "--delete" backup via crontab, but the issues here are:
#   (a) without tagging those backups, e.g. "monthly.0.synchronised", it would be difficult to follow those
#       synchronize backups, as they incrementally propagate down the backups stack;
#   (b) if you schedule (e.g. crontab) a named synchronized backup, e.g. "monthly.0.synchronised", this
#       would result in de novo copies of the regularly scheduled backups, effectively at the full system (rsync'd)
#       disk space, for each of those synchronized backups (e.g., doing once would ~double the space of
#       all of the backups).
#   (c) An option (?) -- test, 2020-05-08, /etc/crontab:
#         rsync 2>/dev/null -a --delete --exclude-from=/home/victoria/backups/rsync/rsync_excludes.txt /mnt/Backups/rsync_backups/daily.4/ /mnt/Backups/rsync_backups/daily.4.synchronized
#       09:10 today:
#         rsync 2>/dev/null -a --delete --exclude-from=/home/victoria/backups/rsync/rsync_excludes.txt \
#           /mnt/Backups/rsync_backups/daily.4/ \
#           /mnt/Backups/rsync_backups/daily.4.synchronized
#       There are two rsync "test" files in
#         /mnt/Backups/rsync_backups/daily.4/
#           /mnt/Backups/rsync_backups/daily.4/home/victoria/.delete_me.txt
#           /mnt/Backups/rsync_backups/daily.4/mnt/Vancouver/z_rsync_deletion_test_file-2020-04-29-vic_to_vanc_may_01.txt
#       that are no longer on my system (SRC), so those should be deleted in
#         /mnt/Backups/rsync_backups/daily.4.synchronized/
# ----------------------------------------
# 2020-05-08: I tried this but it took a long time to run (hours) and the backup size was that of a
#             full (de novo) backup, so I manually terminated it and deleted daily.4.synchronized
# 28    10    *    *    *    root    nice -n 19    rsync 2>/dev/null -a --delete --exclude-from=/home/victoria/backups/rsync/rsync_excludes.txt /mnt/Backups/rsync_backups/daily.4/ /mnt/Backups/rsync_backups/daily.4.synchronized

# ----------------------------------------
# MOVE vs. COPY?

# USE MOVE (mv)!
#   https://unix.stackexchange.com/questions/454318/why-is-mv-so-much-faster-than-cp-how-do-i-recover-from-an-incorrect-mv-command
#     If a directory is moved within the same filesystem (the same partition), then all
#     that is needed is to rename the file path of the directory.  No data apart from
#     the directory entry for the directory itself has to be altered.
#     When copying directories, the data for each and every file needs to be duplicated.
#     This involves reading all the source data and writing it at the destination.
#   https://serverfault.com/questions/360905/whats-faster-for-copying-files-from-one-drive-to-another

# ----------------------------------------
## USEFUL COMMANDS:

#   * disk use:
#       cd /home/victoria/backups/rsync
#       du 2>/dev/null -h -d 1 /mnt/Backups/rsync_backups/ | sort -h ; beep     ## beep (~/.bashrc alias): aplay PHASER.WAV 3x to signal completion
#   * delete dir:
#       sudo rm -fr /mnt/Backups/rsync_backups/hourly.1
#   * this backup script:
#       /home/victoria/backups/rsync/rsync_backups_hourly.sh
#   * examine logfile:
#       tail -n 100 /home/victoria/backups/rsync/rsync.log
#   * progress bar [great in terminal (updates inplace) BUT writes WAY too many transfer status lines to logfile]:
#       /usr/bin/rsync 2>/dev/null -a --info=progress2 --exclude-from=/home/victoria/backups/rsync/rsync_excludes.txt / /mnt/Backups/rsync_backups/hourly.0 


# ============================================================================
## SCRIPT

# While ostensively there is no need to run this script as "sudo" since the ownership of "/mnt/Backups/" is "victoria:root",
# to enable backups of non-excluded system files (e.g., "/etc/crontab") and directories, schedule this script / other rsync
# backup scripts (daily | weekly | monthly | yearly) to run as root in /etc/crontab.
# [Of course, the ownership of those backups, executed by crontab as sudo, will be "root:root".]

# ----------------------------------------------------------------------------
# APPROACH:
#   * move (mv) all but newest backup to older backups
#   * copy (cp -al) *.0 backup to *.1
#   * backup (rsync) SRC --> DEST (*.0)

# ----------------------------------------------------------------------------
## REFERENCE:
# /home/victoria/backups/rsync/old, bak/rsnapshot.log.2020-04 [EXCERPTED HERE]
#     /usr/bin/rm -rf /mnt/Backups/rsnapshot_backups/hourly.2/
#     mv /mnt/Backups/rsnapshot_backups/hourly.2/ /mnt/Backups/rsnapshot_backups/hourly.3/
#     mv /mnt/Backups/rsnapshot_backups/hourly.1/ /mnt/Backups/rsnapshot_backups/hourly.2/
#     /usr/bin/cp -al /mnt/Backups/rsnapshot_backups/hourly.0 /mnt/Backups/rsnapshot_backups/hourly.1
# ----------------------------------------
## VICTORIA -- I believe this would cascade deletions through all older backups as they are pushed backward.
##             If you want to have backups that have material that was LATER deleted (intentionally or intentionally)
##             on the SRC (system), then delete this line:
#     /usr/bin/rsync -a --delete --numeric-ids /mnt/Backups/rsnapshot_backups/hourly.0/ /mnt/Backups/rsnapshot_backups/hourly.1/
# ----------------------------------------
#     /usr/bin/rsync -a --delete --exclude-from=/home/victoria/backups/rsync/rsync_excludes.txt --filter=-/_/mnt/Backups/rsnapshot_backups / /mnt/Backups/rsnapshot_backups/hourly.0/snapshot_root
#     ## --filter=-/_/mnt/Backups/rsnapshot_backups : see notes in /etc/rsnapshot.conf

# ----------------------------------------------------------------------------
## LOGFILE:

# https://stackoverflow.com/questions/25833676/redirect-echo-output-in-shell-script-to-logfile
exec >> /home/victoria/backups/rsync/rsync.log 2>&1

## https://stackoverflow.com/questions/17840322/how-to-undo-exec-dev-null-in-bash
## Undo echo to logfile:
# exec >/dev/tty

mkdir -p /mnt/Backups/rsync_backups

echo '========================================'
echo '/home/victoria/backups/rsync/rsync.log'
printf "`date +'%Y-%m-%d (%H:%M:%S)'`: START HOURLY\n"

# ----------------------------------------------------------------------------
# INCREMENT:
# https://unix.stackexchange.com/questions/9899/how-to-overwrite-target-files-with-mv
#   https://unix.stackexchange.com/a/182155/135372
# cp -l option creates hard links to files rather than copying their data to new files.

printf "`date +'%Y-%m-%d (%H:%M:%S)'`: cp hourly.x --> hourly.x+1\n"
rm -fr /mnt/Backups/rsync_backups/hourly.2
mv 2>/dev/null /mnt/Backups/rsync_backups/hourly.1/ /mnt/Backups/rsync_backups/hourly.2

# In (only) this hourly script, I need to keep a copy of hourly.0 for the rsync (SRC --> hourly.0) backup.

cp 2>/dev/null -al /mnt/Backups/rsync_backups/hourly.0/ /mnt/Backups/rsync_backups/hourly.1

# In the daily | weekly | monthly | yearly backup scripts, (here) I move (mv)/increment ALL the
# older backups (rm -fr daily.6; mv daily.5 --> daily.6 ... daily.0 --> daily.1), then
# cp -al hourly.2 --> daily.1; cp -al daily.6 --> weekly.0; ...

# ----------------------------------------------------------------------------
# RSYNC:

# Sanity check for silently halted/"spinning" rsync processes (somewhat easier than lockfiles):
# https://shapeshed.com/unix-exit-codes/
# https://linuxize.com/post/bash-if-else-statement/
RSYNC_PID=$(pgrep rsync | head -n1)

# if pgrep rsync; then echo 'rsync is running'; else echo 'rsync is not running'; fi
# tested with: /home/victoria/backups/rsync/hourly-test_no_backup.sh
# : = "pass"
# exit code 1 = general error

if  [[ "$RSYNC_PID"='' ]]
then
  # echo 'rsync is not running'
  # exit if statement
  :
else
  # echo 'rsync is running'
  # email notification of problem, then terminate script:
  printf "sudo /home/victoria/backups/rsync/rsync_backups_hourly.sh stalled?\n\nPerhaps due to locked system file(s) [e.g. due to system updates].\n\nCheck rsync PID status.\n\nReboot if needed.\n" | mutt -s "resync backup error" mail@VictoriasJourney.com
  exit 1
fi

# Comment (anecdotal): once when testing (scripts manually executed via crontab), I forgot to comment out
# the scheduled "hourly.sh" script; while another rsync version ("daily.sh" ?) was running. it appeared that
# the invocation of the normally-scheduled "hourly.sh" script was delayed, until the previously initiated
# ("testing" rsync) script had completed (or was manually terminated).  This, despite the fact that in any
# given scripted rsync process, it appears that multiple (threaded) rsync instances may be present.
# Without looking into this further, it may be the case that we may not need to be concerned with conflicting
# (concurrent) instances -- "hourly.sh"; "daily.sh"; ... -- provided those each complete in a timely manner?

# ----------------------------------------------------------------------------
# MAIN:

printf "`date +'%Y-%m-%d (%H:%M:%S)'`: updating (via rsync: system --> /mnt/Backups/rsync_backups/) hourly.0\n"

# "mkdir -p" creates dir if not found (command ignored if dir present)
mkdir -p /mnt/Backups/rsync_backups/hourly.0

# "rsync" can create a dir if not present
# running as "sudo" via "crontab", so full paths needed;

## https://www.unix.com/shell-programming-and-scripting/119353-run-commands-within-script-certain-days.html
## day=$(date +%A)                                                                                                     
## echo $day
##  Thursday

## Once a week "clean" hourly.0 to delete files in hourly.0 not present on SRC:
## [the rest of the week 
# if [ "$day" == "Sunday" ] ;then
#   rsync 2>/dev/null -a --delete --exclude-from=/home/victoria/backups/rsync/rsync_excludes.txt / /mnt/Backups/rsync_backups/hourly.0
# else
#   rsync 2>/dev/null -a --exclude-from=/home/victoria/backups/rsync/rsync_excludes.txt / /mnt/Backups/rsync_backups/hourly.0
# fi
rsync 2>/dev/null -a --exclude-from=/home/victoria/backups/rsync/rsync_excludes.txt / /mnt/Backups/rsync_backups/hourly.0

# "datetime" on the "hourly.0" folder was not updating to backup time, so do this (write/delete a file):
## https://stackoverflow.com/questions/23541421/how-to-change-modified-time-for-folder
## https://stackoverflow.com/questions/3451863/when-does-a-unix-directory-change-its-timestamp
touch /mnt/Backups/rsync_backups/hourly.0/.delete_me
echo 'Hello!' > /mnt/Backups/rsync_backups/hourly.0/.delete_me
echo `date` >> /mnt/Backups/rsync_backups/hourly.0/.delete_me
touch /mnt/Backups/rsync_backups/hourly.0/
# rm -f /mnt/Backups/rsync_backups/hourly.0/.delete_me

printf "`date +'%Y-%m-%d (%H:%M:%S)'`: END HOURLY\n"

# https://unix.stackexchange.com/questions/22764/dashes-in-printf
#   https://unix.stackexchange.com/a/22768/135372

printf '%s----------------------------------------\nCumulative disk use:\n'
# Sort by size (sort -h):
# du 2>/dev/null -h -d 1 /mnt/Backups/rsync_backups/ | sort -h
# Sort by path (sort):
du 2>/dev/null -h -d 1 /mnt/Backups/rsync_backups/ | sort
df -h /mnt/Backups/rsync_backups/
# printf '%s----------------------------------------\n'

<<COMMENT
  [victoria@victoria rsync]$ date
    Wed 29 Apr 2020 09:56:21 AM PDT

  [victoria@victoria rsync]$ du 2>/dev/null -h -d 1 /mnt/Backups/rsync_backups/ | sort -h 
    941M	/mnt/Backups/rsync_backups/hourly.2
    1.6G	/mnt/Backups/rsync_backups/hourly.1
    1.4T	/mnt/Backups/rsync_backups/
    1.4T	/mnt/Backups/rsync_backups/hourly.0

  [victoria@victoria rsync]$ du 2>/dev/null -h -d 1 /mnt/Backups/rsync_backups/ | sort
    1.4T	/mnt/Backups/rsync_backups/
    1.4T	/mnt/Backups/rsync_backups/hourly.0
    1.6G	/mnt/Backups/rsync_backups/hourly.1
    941M	/mnt/Backups/rsync_backups/hourly.2
COMMENT

## Undo echo to logfile:
# exec >/dev/tty
# tail -n 100 /home/victoria/backups/rsync/rsync.log
# pwd
# ============================================================================

