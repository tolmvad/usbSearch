#!/bin/bash

LOGO="
               __     _______                            __         {v.1.0}
.--.--..-----.|  |--.|     __|.-----..---.-..----..----.|  |--.
|  |  ||__ --||  _  ||__     ||  -__||  _  ||   _||  __||     |
|_____||_____||_____||_______||_____||___._||__|  |____||__|__|     https://github.com/tolmvad/usbSearch
"
LOG_PATH=/var/log/
# Alternative options: kern.log, syslog, messages
LOG_BASE=kern.log
LOG_LIST=$(find $LOG_PATH -type "f" -name "$LOG_BASE*")

# Run
clear
echo -e "\e[1;32m$LOGO\e[0;0m"

for doc in $LOG_LIST
do
    echo -e "\e[1;34m--------------------- File $doc ---------------------\e[0;0m"
    if [[ "${doc##*.}" == "gz" ]]
    then
        CMD=zgrep
    else
        CMD=grep
    fi
    $CMD -E 'New USB device found|Product:|Manufacturer:|SerialNumber:|USB Mass Storage' $doc | \
    awk '{
    idx=1
    while ($idx != "New" &&
            $idx != "Product:" &&
            $idx != "Manufacturer:" &&
            $idx != "SerialNumber:" &&
            $idx != "Mass" && idx != NF) {
        idx++
    }
    if ($idx == "New") {
        print("\033[35m-----------------------------------------------------------\033[0m")
    }
    if ($idx == "Mass") {
        printf("\033[1;33m")
    }
    printf("Дата: %s %s %s | ", $1, $2, $3)
    if ($idx == "New") {
        printf("VID:%s PID:%s\n", substr($(idx + 4), 10, 4), substr($(idx + 5), 11, 4))
    } else if ($idx == "Mass") {
        printf("USB Mass Storage device\n\033[0;0m")
    } else {
        while ($(idx-1) != $NF) {
            printf("%s ", $idx)
            idx++
        }
        printf("\n")
    }
}'
done
