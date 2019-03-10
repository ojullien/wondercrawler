#!/bin/sh

#************************************************#
#              capturevideolinks.sh              #
#                   28.02.2012                   #
#                                                #
# Capture video links in a page.                 #
#************************************************#

#------------------------------------#
# Define                             #
#------------------------------------#
m_DIRWC=$(/usr/bin/dirname $(/bin/readlink -f $0))
. "${m_DIRWC}/../wc.cfg"
m_PATTERN="[[:blank:]+]<h3><a[[:blank:]]href=\"http://www.___.com/([[:alnum:]_-]+)/\"[[:blank:]]class=\"onCC"

#------------------------------------#
# Functions                          #
#------------------------------------#
. "${m_DIRWC}/function.inc"

#------------------------------------#
# Parameters                         #
#------------------------------------#
if [ $# -lt 2 -o -z "$1" -o -z "$2" ]; then
    DisplayE "Usage: `/usr/bin/basename $0` <HTML FILE> <VIDEOS FILE>"
    exit 1
fi
m_sFileWeb=$1
m_sFileVideo=$2
if [ ! -s "$m_sFileWeb" -o ! -r "$m_sFileWeb" ]; then
    DisplayE "Error: $m_sFileWeb is not a file or can not be read."
    exit 1
fi
if [ ! -f "$m_sFileVideo" -o ! -w "$m_sFileVideo" ]; then
    DisplayE "Error: $m_sFileVideo is not a file or can not be written."
    exit 1
fi

#------------------------------------#
# Capture                            #
#------------------------------------#
./includes/wc-capture.sh $m_PATTERN "$m_sFileWeb" "$m_sFileVideo" "--quiet"
if [ $? -gt 0 ]; then
    exit 1
fi

exit 0
