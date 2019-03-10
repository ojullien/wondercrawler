#!/bin/bash

#************************************************#
#                 wc-capture.sh                  #
#                   28.02.2012                   #
#                                                #
# Find and capture the results of an regular     #
# expression test.                               #
#************************************************#

#------------------------------------#
# Define                             #
#------------------------------------#
declare -r m_DIRWC=$(/usr/bin/dirname $(/bin/readlink -f $0))
source "${m_DIRWC}/../wc.cfg"

#------------------------------------#
# Functions                          #
#------------------------------------#
source "${m_DIRWC}/function.inc"

#------------------------------------#
# Parameters                         #
#------------------------------------#
if [ $# -lt 3 -o -z "$1" -o -z "$2" -o -z "$3" ]; then
    DisplayE "Usage: `/usr/bin/basename $0` <PATTERN> <INPUT> <CAPTURE> [--quiet]"
    exit 1
fi
declare -r m_PATTERN=$1
declare -r m_INPUT=$2
declare -r m_CAPTURE=$3
if [ -n "$4" ]; then
    m_QUIET=1
else
    m_QUIET=0
fi
if [ ! -s "$m_INPUT" -o ! -r "$m_INPUT" ]; then
    DisplayE "Error: $m_INPUT is not a file or can not be read."
    exit 1
fi
if [ ! -f "$m_CAPTURE" -o ! -w "$m_CAPTURE" ]; then
    DisplayE "Error: $m_CAPTURE is not a file or cannot be write."
    exit 1
fi

#------------------------------------#
# Read the input                     #
#------------------------------------#
declare -i m_iCaptureCount=0
declare -i m_iLineCount=0
while IFS=  read -r m_Ligne; do
    if [[ $m_Ligne =~ $m_PATTERN ]]; then
        declare -i m_iIndex=1
        declare -i m_iCount=${#BASH_REMATCH[*]}
        while [ $m_iIndex -lt $m_iCount ]
        do
            echo "${BASH_REMATCH[$m_iIndex]}" >> $m_CAPTURE
            m_iCaptureCount=$(($m_iCaptureCount+1))
            m_iIndex=$(($m_iIndex+1))
        done
    fi
    m_iLineCount=$(($m_iLineCount+1))
done < "$m_INPUT"

if [ $m_iCaptureCount -gt 0 ]; then
    m_sBuffer=${COLORGREEN}$m_iCaptureCount${COLORRESET}
else
    m_QUIET=0
    m_sBuffer=${COLORRED}$m_iCaptureCount${COLORRESET}
fi
if [ $m_QUIET -eq 0 ]; then
    Display "Found $m_sBuffer capture(s) over ${COLORGREEN}$m_iLineCount${COLORRESET} line(s) in ${COLORGREEN}`/usr/bin/basename $m_INPUT`${COLORRESET} file."
fi

exit 0
