#!/bin/sh

sleep 3

LOGFILE="/tmp/ambicam.log"    # Log file in /tmp path
export TZ='GMT-5:30'
sleep 1

ln -sn /mny/mtd/ipc/ambicam/libpaho-mqtt3cs.so.1.3.14 /mny/mtd/ipc/ambicam/libpaho-mqtt3cs.so.1

sleep 1

ln -sn /usr/lib/libcrypto.so.3 /mny/mtd/ipc/ambicam/libcrypto.so.1.1
sleep 1
ln -sn /usr/lib/libssl.so.3 /mny/mtd/ipc/ambicam/libssl.so.1.1

sleep 1
ln -sn /mny/mtd/ipc/ambicam/libcurl.so.4.8.0 /mny/mtd/ipc/ambicam/libcurl.so.4

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOGFILE"
}

# Function to set LD_LIBRARY_PATH with continuous retry
set_ld_library_path() {
    while true; do
        export LD_LIBRARY_PATH="/mny/mtd/ipc/ambicam/"
        if [ "$LD_LIBRARY_PATH" = "/mny/mtd/ipc/ambicam/" ]; then
            log_message "LD_LIBRARY_PATH set to $LD_LIBRARY_PATH"
            break
        else
            log_message "Failed to set LD_LIBRARY_PATH, retrying..."
            sleep 1
        fi
    done
}

# Function to check internet connectivity with continuous retry
check_internet() {
    log_message "Checking internet connection..."
    while true; do
        if ping -c 1 -W 1 8.8.8.8 > /dev/null 2>&1; then
            log_message "Internet is available."
            return 0
        else
            log_message "No internet connection. Retrying..."
            sleep 5
        fi
    done
}

# Set the environment path with continuous retry
set_ld_library_path

# Wait until internet connection is available
check_internet

/mny/mtd/ipc/ambicam/MQTT_vcamclient_Augentix &
sleep 5
/mny/mtd/ipc/ambicam/P2Pambicam -c /etc/jffs2/ambicam/P2Pambicam_min.ini -f -d 7 

