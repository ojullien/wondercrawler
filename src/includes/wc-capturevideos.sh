#!/bin/bash

#************************************************#
#                capturevideos.sh                #
#                   28.02.2012                   #
#                                                #
# Download and capture video pages.              #
#************************************************#

#------------------------------------#
# Define                             #
#------------------------------------#
declare -r m_DIRWC=$(/usr/bin/dirname $(/bin/readlink -f $0))
source "${m_DIRWC}/../wc.cfg"
declare -r m_DIRCSV="${m_DIRWC}/../${wc_CSVDIRNAME}"
declare -r m_FILEWEBNAME="video.htm"
declare -r m_CSVHEADER="Category;Sub-Category;Categories;Grade;Rating;Views;Publish-date;Title;Description;Duration;Link;Keywords;Host;Creator"
declare -r m_PATTERNCAT="([[:alnum:]_-]+)/([[:alnum:]_-]+)-video"
declare -i m_MODESPIDER=0

#------------------------------------#
# Functions                          #
#------------------------------------#
source "${m_DIRWC}/function.inc"

#------------------------------------#
# Parameters                         #
#------------------------------------#
if [ $# -lt 5 -o -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" -o -z "$5" ]; then
    DisplayE "Usage: `/usr/bin/basename $0` <DOMAIN> <CATEGORY> <VIDEOS FILE> <CACHE DIR> <DOWNLOAD DIR> [SPIDER MODE]"
    exit 1
fi
declare -r m_DOMAIN=$1
declare -r m_CATEGORIES=$2
declare -r m_FILEVID=$3
if [ ! -s "$m_FILEVID" -o ! -r "$m_FILEVID" ]; then
    DisplayE "Error: $m_FILEVID is not a file or can not be read."
    exit 1
fi
declare -r m_DIRVIDEO="$4/${wc_VIDEODIRNAME}"
if [ ! -d "$m_DIRVIDEO" ]; then
    DisplayE "Error: $m_DIRVIDEO is not a directory."
    exit 1
fi
declare -r m_FILEWEB="$5/$m_FILEWEBNAME"
if [ -n "$6" ]; then
    m_MODESPIDER="$6"
fi

if [ $m_MODESPIDER -eq 0 ]; then
    Delete "$m_FILEWEB"
fi

#------------------------------------#
# Capture category and sub category  #
#------------------------------------#
m_sCategory=""
m_sSubCategory=""
if [[ $m_CATEGORIES =~ $m_PATTERNCAT ]]; then
    if [ ${#BASH_REMATCH[*]} -eq 3 ]; then
        m_sCategory=${BASH_REMATCH[1]}
        m_sSubCategory=${BASH_REMATCH[2]}
    fi
fi
if [ -z "$m_sCategory" -o -z "$m_sSubCategory" ]; then
    DisplayE "                can not capture category and sub-category from $m_CATEGORIES."
    exit 1
fi

#------------------------------------#
# Create cache directory             #
#------------------------------------#
if [ ! -d "$m_DIRVIDEO/$m_sCategory" ]; then
    /bin/mkdir "$m_DIRVIDEO/$m_sCategory"
fi

#------------------------------------#
# Create csv file                    #
#------------------------------------#
declare -r m_sFileCSV="$m_DIRCSV/$m_sCategory.csv"
if [ ! -f "$m_sFileCSV" ]; then
    echo "$m_CSVHEADER" > "$m_sFileCSV"
fi

#------------------------------------#
# Read video list                    #
#------------------------------------#
declare -i m_iVideoCount=0
declare -i m_iVideoTotal=`/bin/grep -v '^\W*$' $m_FILEVID | /usr/bin/wc -l`
while IFS=  read -r m_Ligne; do

    m_sErrorMessage="downloading video pages"

    if [ $m_MODESPIDER -eq 0 ]; then

        #------------------------------------#
        # Download only video new video      #
        #------------------------------------#
        if [ -f "$m_DIRVIDEO/$m_sCategory/$m_Ligne" ]; then continue; fi

        #------------------------------------#
        # Download                           #
        #------------------------------------#
        ./includes/wc-wget.sh "$m_DOMAIN$m_Ligne/" "$m_FILEWEB" "--quiet"
        if [ $? -gt 0 ]; then
            DisplayE "Abort $m_sErrorMessage."
            break
        fi

    else
        Display "                do not download video page when spider mode is on."
    fi

    #------------------------------------#
    # Capture                            #
    #------------------------------------#
    ./includes/wc-capturevideodata.sh "$m_FILEWEB" "$m_sFileCSV" "$m_sCategory" "$m_sSubCategory"
    if [ $? -gt 0 ]; then
        DisplayE "Abort $m_sErrorMessage."
        break
    fi

    #------------------------------------#
    # Create cache file                  #
    #------------------------------------#
    /usr/bin/touch "$m_DIRVIDEO/$m_sCategory/$m_Ligne"
    m_iVideoCount=$(($m_iVideoCount+1))

done < "$m_FILEVID"

Display "                capture ${COLORGREEN}$m_iVideoCount${COLORRESET} new video(s) in this page."

#------------------------------------#
# Exit case                          #
#------------------------------------#
# Default
declare -i m_iExit=0
# No video found
if [ $m_iVideoCount -eq 0 ]; then
    m_iExit=2
fi

exit ${m_iExit}
