# Duplicacy Backups 

This is a document about setting up and running duplicacy for automated backups to local and cloud destinations on Windows.  

The script here will run automated backups--you'll need to make some simple modifications to it.  The tasks you need to do are:

1. Install [duplicacy](https://duplicacy.com) and add it to your path
2. Modify script with your own backup destinations, log file paths, duplicacy executable, etc.
3. Open an account with a cloud backup provider (this document assumes backblaze b2)
4. Initialize the backup locations per this document
5. Run a backup manually per this document, if using encryption (the first time you run a backup for a location you're asked to type your encryption key--after that it's saved in the duplicacy config folder)
6. Create a windows scheduled task to run at some interval with elevated privileges
7. If you're backing up a user profile on Windows, see the "filter" section below.  

These are "plug and chug" instructions for making encrypted backups to a local folder, and then copying those to a cloud storage provider.  

## Initialize a backup location

### Local Backup

```
cd c:\users\myuser
duplicacy init local_C N:\_duplicacy_backup -e
```

(you'll be asked for an encryption password--type it manually)

This will:

* make c:\users\myuser the folder that is backed up
* give these backups the name local_C (to distinguish them from other backups in the same location)
* set the backup destination to \N:\_duplicacy_backup
* encrypt the backups with the password you specify

### Remote Backup



```
cd c:\users\myuser
duplicacy add -copy default b2 local_C b2://duplicacybucket1234
```

(you'll be prompted for your backblaze B2 credentials)

This will:

* make the new storage location compatible with the existing one (-copy default)
* give the new storage location the friendly name 'b2' (used when operating on it with certain commands)
* give these backups the name local_C (to distinguish them from other backups in the same remote location)
* specify the remote backup destination as a Backblaze B2 bucket with the name 'duplicacybucket1234'
* my testing indicates not specifying -e here means your cloud backups are not encrypted, even if your local backups are encrypted.  Not sure how/why that works just yet.  

to run remote backup

duplicacy copy -to b2 -threads 10

(copies local storage to b2)


## To backup

The script will handle this, but it's good to be able to run a manual backup and to understand what's happening

To run the local backup:

```
cd c:\users\myuser
duplicacy backup -stats -vss
```

This will:

* Run backups for c:\users\myuser
* Use the Windows Volume Shadow Copy Service (VSS) to back up open files.  Note you need be running an administrator command prompt to use the vss option.  
* Display stats on what is happening

To run the remote backup:

```
cd c:\users\myuser
duplicacy copy -to b2 -threads 10
```

This will:

* Copy the backups for c:\users\myuser from your local storage to the remote storage 'b2' you added earlier.  
* Use 10 separate threads for uploading files (you might use more or less depending on your computer and connection capabilities)


## Prune

The following statements will, roughly:

* delete backups over a year old, 
* keep 1 snapshot a month for the last year
* keep 1 snapshot a week for the last month
* keep 1 snapshot a day for the last week

```
duplicacy prune -keep 0:365 -keep 30:30 -keep 7:7
duplicacy prune -keep 0:365 -keep 30:30 -keep 7:7 -storage b2
duplicacy prune
duplicacy prune -storage b2
```

(UPDATE:  This appears to actually keep one backup a day for the last 30 days)

The pruning process collects things to be deleted on the first run, and then actually deletes them when its run again.  Although it seems like the second run is frequently hesitant to delete things--I guess that's better than the alternative.  

To prune a specific snapshot:

```duplicacy prune -r 45 -exclusive```

This will:

* prune snapshot 45

## Restoring

If restoring to a different folder (say on a new computer), then in the folder you want to restore to:

```
cd c:\myrestore
duplicacy init local_C N:\_duplicacy_backup -e 
```

(supply your encryption password)

OR you could init your remote storage:

```
duplicacy init local_C b2://duplicacybucket1234
```

(supply your encryption password and API credentials.  If your remote was initialized with -e, you must include it here again)


Then:

```duplicacy list```  

This will show a list of snapshots

to restore:

```duplicacy restore -r 10``` 

This will restore snapshot 10 from default (local) storage

```duplicacy restore -r 10 -storage b2```   

This will restore from storage called b2, if available

## Filtering

Windows profiles contain a lot of stuff that doesn't really need to be backed up.  This repository includes a filter file that can help with that.  

Put the "filters" file in the duplicacy config folder in the root of your profile (c:\users\myuser\.duplicacy).  This has a number of exclusions for temporary and generally useless files.  Note:  A number of the exclusions are drawn from the list of exclusions that Code42 published for the now defunct Crashplan Home service (https://support.code42.com/CrashPlan/4/Troubleshooting/What_is_not_backing_up).  

Make sure the filters are appropriate for your purposes--they may be too aggressive for some people.  

## Miscellaneous

To verify a specific snapshot:

```duplicacy check -r 88 -files -stats```

This will:

* verify all existing backup files referenced by snapshot 88
* display what's happening
* verify the integrity of each backup file (chunk) by downloading it and recomputing file hashes.  

You could also do: 

```duplicacy check -r 88 -files -stats -storage b2```

To run the check on your remote storage.  Since this downloads each chunk, you will generally incur some sort of added cost from your remote storage provider.  As a point of reference, when I did this for one of my backups on Backblaxe B2, it downloaded 60GB and produced about 31,000 class B transactions.  The cost for this as of 2019-04-10 was approximately. 0.60 US dollars.  

## Using the Backup Script

* The log file location needs to be created manually
* Run a backup manually per this document, if using encryption.  The first time you run a backup for a location you're asked to type your encryption key (the script doesn't do this)--after that it's saved in the duplicacy config folder.  
* The script assumes you are backing up to a local drive and then to a remote location.  It may need some light editing if you only do local or remote backups.  
