#!/bin/bash

DVD="/dev/dvd"
DVDBACKUP="/usr/bin/dvdbackup -i ${DVD}"
RIP_DVD=1
ENC_DVD=1

echo "~~{ Welcome to DEXTER }~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"


## Rip DVD
    echo "analysing dvd......"
    dvd_info=$(${DVDBACKUP} -I 2>/dev/null )

    dvd_title=$(echo "${dvd_info}" | grep "DVD-Video information of the DVD with title" | sed -n 's/.* DVD with title "\(.*\)"$/\1/p')
    echo " - Title: ${dvd_title}"

    # dvd_titleset=$(echo "${dvd_info}" | grep "Title set containing the main feature is" | sed -n 's/.* main feature is \(.*\)$/\1/p')
    # echo " - Titleset: ${dvd_titleset} "

if [ ${RIP_DVD} -gt 0 ]; then
    echo "ripping dvd......."
    cat /dev/dvd > "${HOME}/dexter/movie.iso"
    if [ $? -gt 0 ]; then
        echo "Failed to rip dvd iso"
        exit 1
    fi
fi

# eject /dev/dvd/

if [ ${ENC_DVD} -gt 0 ]; then
    echo "encoding dvd........."
    /usr/bin/HandBrakeCLI --main-feature -m -v0 -i "${HOME}/dexter/movie.iso" -o "${HOME}/dexter/movie.mp4"
    if [ $? -gt 0 ]; then
        echo "Failed to encode movie"
        exit 2
    fi
fi

if [ -f  "${HOME}/dexter/movie.mp4" ]; then
    final_name="${HOME}/dexter/done/${dvd_title}.mp4"
    if [ -f ${final_name} ]; then 
        final_name="${HOME}/dexter/done/$(date +%s)-${dvd_title}.mp4"
    fi
    mv "${HOME}/dexter/movie.mp4" "${final_name}"
    rm -f "${HOME}/dexter/movie.iso"
fi

eject /dev/dvd

