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

---

**Update 1/2** [2020-09-27]

* I've been running these scripts fot ~4 months now with no issues.  A months ago I changed hourly backups to 04:00 (4 am), 12:00 (noon), 18:00 (6 pm) -- thus capturing morning work (04:00 - 12:00), afternoon work (12:00-18:00), and evening work (18:00-04:00).

* While useful for testing, the `du` (disk use) utility is time-consuming, especially on large volumes (e.g. 5 TB HDD), so I commented it out.

* Here are the backups, to date (parent-level directories only, shown here).

```bash
[victoria@victoria rsync_backups]$ date; pwd; ls -l

  Sun Sep 27 09:55:10 AM PDT 2020
  /mnt/Backups/rsync_backups

  total 68
  drwxr-xr-x 6 root root 4096 Sep 26 04:05 daily.0
  drwxr-xr-x 6 root root 4096 Sep 25 04:05 daily.1
  drwxr-xr-x 6 root root 4096 Sep 24 04:05 daily.2
  drwxr-xr-x 6 root root 4096 Sep 23 04:06 daily.3
  drwxr-xr-x 6 root root 4096 Sep 22 04:05 daily.4
  drwxr-xr-x 6 root root 4096 Sep 21 04:10 daily.5
  drwxr-xr-x 6 root root 4096 Sep 20 04:09 daily.6
  drwxr-xr-x 6 root root 4096 Sep 27 04:07 hourly.0
  drwxr-xr-x 6 root root 4096 Sep 26 18:07 hourly.1
  drwxr-xr-x 6 root root 4096 Sep 26 12:08 hourly.2
  drwxr-xr-x 6 root root 4096 Aug  2 04:09 monthly.00
  drwxr-xr-x 6 root root 4096 Jun 28 04:09 monthly.01
  drwxr-xr-x 6 root root 4096 May 31 04:09 monthly.02
  drwxr-xr-x 6 root root 4096 Sep 13 04:09 weekly.0
  drwxr-xr-x 6 root root 4096 Sep  6 04:09 weekly.1
  drwxr-xr-x 6 root root 4096 Aug 30 04:09 weekly.2
  drwxr-xr-x 6 root root 4096 Aug 23 04:09 weekly.3

[victoria@victoria rsync_backups]$ df -h /mnt/Backups/

  Filesystem      Size  Used Avail Use% Mounted on
  /dev/sda1       4.6T  1.5T  2.9T  34% /mnt/Backups

[victoria@victoria rsync_backups]$

# ----------------------------------------------------------------------------

[victoria@victoria rsync_backups]$ ls -ltr

  total 68
  drwxr-xr-x 6 root root 4096 May 31 04:09 monthly.02
  drwxr-xr-x 6 root root 4096 Jun 28 04:09 monthly.01
  drwxr-xr-x 6 root root 4096 Aug  2 04:09 monthly.00
  drwxr-xr-x 6 root root 4096 Aug 23 04:09 weekly.3
  drwxr-xr-x 6 root root 4096 Aug 30 04:09 weekly.2
  drwxr-xr-x 6 root root 4096 Sep  6 04:09 weekly.1
  drwxr-xr-x 6 root root 4096 Sep 13 04:09 weekly.0
  drwxr-xr-x 6 root root 4096 Sep 20 04:09 daily.6
  drwxr-xr-x 6 root root 4096 Sep 21 04:10 daily.5
  drwxr-xr-x 6 root root 4096 Sep 22 04:05 daily.4
  drwxr-xr-x 6 root root 4096 Sep 23 04:06 daily.3
  drwxr-xr-x 6 root root 4096 Sep 24 04:05 daily.2
  drwxr-xr-x 6 root root 4096 Sep 25 04:05 daily.1
  drwxr-xr-x 6 root root 4096 Sep 26 04:05 daily.0
  drwxr-xr-x 6 root root 4096 Sep 26 18:07 hourly.2
  drwxr-xr-x 6 root root 4096 Sep 27 04:07 hourly.1
  drwxr-xr-x 6 root root 4096 Sep 27 12:10 hourly.0

---

**Update 2/2** [2021-02-17]

At the end of January 2021 I had a catastrophic failure of my (2014 vintage) 5 TB Western Digital hard disk drive (HDD), the one I use for non-system work, data, no-system apps (cloned GitHub repos; ...).

I was unable to repair the failed HDD (`fsck` | `testdisk` | ...).  I bought a new 6 TB replacement HDD and the restoration of the data (note trailing slash / on the source directory and the lack of a slash on the destination directory) proceeded without incident (it took a few hours due to the volume of data).

  ```time sudo rsync -aq /mnt/Backups/rsync_backups/hourly.0/mnt/Vancouver/ /mnt/Vancouver```

Since that time (after editing my `/etc/fstab` to reflect the new drive/partition) I have been operating normally with the new HDD / restored data.

Despite the complexities (learning curve) in learning about / implementing a rsync-based backup system (setup | unit tests are crucial as are occassional checks of the backups to verify they are working properly), when needed those backups are essential for data recovery.
