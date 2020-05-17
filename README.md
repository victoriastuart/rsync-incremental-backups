# rsync-incremental-backups

**Background**

I had been using `rsnapshot` for years, but it recently stopped working, for unknown reasons.  I therefore crafted my own, easier-to-follow (understand) alternative.

See the comments im `hourly.sh` to understand the code and configuration (paths; crontab; ...).  I included a copy of my `rsync` "excludes" file, also for your reference (efit per your backup specifications).

Here is an example of the logfile output.

```
...
==============================================================================
/home/victoria/backups/rsync/rsync.log
2020-05-17 (03:00:01): START DAILY
2020-05-17 (03:00:01): cp daily.x --> daily.x+1
2020-05-17 (03:04:12): cp hourly.2 --> daily.0
2020-05-17 (03:09:20): END DAILY
========================================
/home/victoria/backups/rsync/rsync.log
2020-05-17 (04:00:01): START HOURLY
2020-05-17 (04:00:01): cp hourly.x --> hourly.x+1
2020-05-17 (04:06:29): updating (via rsync: system --> /mnt/Backups/rsync_backups/) hourly.0
2020-05-17 (04:08:39): END HOURLY
----------------------------------------
Cumulative disk use:
1.2G	/mnt/Backups/rsync_backups/daily.0
1.2G	/mnt/Backups/rsync_backups/daily.1
1.2G	/mnt/Backups/rsync_backups/daily.2
1.2G	/mnt/Backups/rsync_backups/daily.3
1.2G	/mnt/Backups/rsync_backups/daily.4
1.2G	/mnt/Backups/rsync_backups/daily.6
1.4T	/mnt/Backups/rsync_backups/
1.4T	/mnt/Backups/rsync_backups/hourly.0
1.5G	/mnt/Backups/rsync_backups/daily.5
798M	/mnt/Backups/rsync_backups/hourly.1
929M	/mnt/Backups/rsync_backups/hourly.2
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       4.6T  1.4T  3.0T  32% /mnt/Backups
```


