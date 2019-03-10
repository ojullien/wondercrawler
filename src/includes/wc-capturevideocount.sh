#!/bin/sh

#************************************************#
#              capturevideocount.sh              #
#                   28.02.2012                   #
#                                                #
# Capture video count in a page.                 #
#************************************************#

#------------------------------------#
# Define                             #
#------------------------------------#
m_DIRWC=$(/usr/bin/dirname $(/bin/readlink -f $0))
. "${m_DIRWC}/../wc.cfg"
m_PATTERN="<h6[[:blank:]]class=\"headline\">([[:digit:],]+)[[:blank:]]Videos</h6>"

#------------------------------------#
# Functions                          #
#------------------------------------#
. "${m_DIRWC}/function.inc"

#------------------------------------#
# Parameters                         #
#------------------------------------#
if [ $# -lt 2 -o -z "$1" -o -z "$2" ]; then
    DisplayE "Usage: `/usr/bin/basename $0` <HTML FILE> <COUNT FILE>"
    exit 1
fi
m_sFileWeb=$1
m_sFileCount=$2
if [ ! -s "$m_sFileWeb" -o ! -r "$m_sFileWeb" ]; then
    DisplayE "Error: $m_sFileWeb is not a file or can not be read."
    exit 1
fi
if [ ! -f "$m_sFileCount" -o ! -w "$m_sFileCount" ]; then
    DisplayE "Error: $m_sFileCount is not a file or can not be written."
    exit 1
fi

#------------------------------------#
# Capture                            #
#------------------------------------#
./includes/wc-capture.sh $m_PATTERN "$m_sFileWeb" "$m_sFileCount" "--quiet"
if [ $? -gt 0 ]; then
    exit 1
fi

#------------------------------------#
# Save the new video count           #
#------------------------------------#
m_iVideoCount=`/usr/bin/head --lines=1 $m_sFileCount`
m_iVideoCount=$(echo $m_iVideoCount|/bin/sed 's/,//g')
echo $m_iVideoCount > $m_sFileCount
if [ $m_iVideoCount -gt 0 ]; then
    m_sBuffer="${COLORGREEN}$m_iVideoCount${COLORRESET}"
else
    m_sBuffer="${COLORRED}$m_iVideoCount${COLORRESET}"
fi
Display "\t\tlooking for $m_sBuffer video(s)."

exit 0
