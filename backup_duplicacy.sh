#!/bin/bash

# assumes binary is named "duplicacy" and is in the PATH of the user running the script
# logging displays stderr and stdout to console and appends both to the log file

# space separated list of folders to back up
backup_paths=( "/home/user/" "/home/user2" )

# where to put logs
log_folder="/home/user/backup_logs/"
log_file_name="duplicacy.log"
log_path=${log_folder}${log_file_name}

# size in bytes to roll over log
log_max_size=5242880  # default 5 megabytes 



rollover_logs () {

    # create log file if it's missing
    if [ ! -f "$log_path" ]
    then
        echo "Log file missing.  Creating..." 2>&1 | tee $log_path
        touch ${log_path}      
    fi
    
    log_size=$(wc -c < "$log_path")
    echo "Current log size is: "${log_size}
    
    #roll over log if max size exceeded
    if [ $log_size -gt $log_max_size ]
    then
        echo "Log exceeds max size of "${log_max_size}".  Rolling over log..."
        mv $log_path ${log_path}.$(date -Iseconds)
    fi


}

rollover_logs


for path in "${backup_paths[@]}" 
do 
    echo "running backups for "${path}" at $(date -Iseconds)" 2>&1 | tee -a ${log_path}
    cd ${path}
    if [ ! $? -eq 0 ]
    then
        echo "ERROR: Problem switching to path "${path}".  Skipping this backup location..." 2>&1 | tee -a ${log_path}
        # error is not fatal--we'll skip this one and try the other locations
        continue
    fi
    duplicacy prune -keep 0:360 -keep 30:180 -keep 7:30 -keep 1:7 2>&1 | tee -a ${log_path}
    duplicacy backup -stats 2>&1 | tee -a ${log_path}
    duplicacy prune --delete-only 2>&1 | tee -a ${log_path}
    # duplicacy prune -keep 0:360 -keep 30:180 -keep 7:30 -keep 1:7 -storage b2 2>&1 | tee -a ${log_path}
    # duplicacy copy -to b2 -threads 10 2>&1 | tee -a ${log_path}
    # duplicacy prune --delete-only -storage b2 2>&1 | tee -a ${log_path}
    echo "completed backups and pruning for "${path}" at $(date -Iseconds)" 2>&1 | tee -a ${log_path}
done