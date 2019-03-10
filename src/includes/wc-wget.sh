#!/bin/sh

#************************************************#
#                   wc-wget.sh                   #
#                   28.02.2012                   #
#                                                #
# Download a page.                               #
#************************************************#

#------------------------------------#
# Define                             #
#------------------------------------#
m_DIRWC=$(/usr/bin/dirname $(/bin/readlink -f $0))
. "${m_DIRWC}/../wc.cfg"
m_AGENT='Opera/9.00 (Windows NT 5.1; U; en)'
m_OPTION=""

#------------------------------------#
# Functions                          #
#------------------------------------#
. "${m_DIRWC}/function.inc"

#------------------------------------#
# Parameters                         #
#------------------------------------#
if [ $# -lt 2 -o -z "$1" -o -z "$2" ]; then
    DisplayE "Usage: `/usr/bin/basename $0` <WEB PAGE> <OUTPUT FILE> [--quiet|--no-verbose]"
    exit 1
fi
m_PAGE=$1
m_FILE=$2
m_OPTION=$3

#------------------------------------#
# Download                           #
#------------------------------------#
/usr/bin/wget $m_OPTION --tries=20 --retry-connrefused --output-document="$m_FILE" --user-agent="$m_AGENT" "$m_PAGE"
m_iError=$?
case "$m_iError" in
1) DisplayE "A generic error occures while downloading $m_PAGE."
   ;;
2) DisplayE "A parse error occures while downloading $m_PAGE."
   ;;
3) DisplayE "A file I/O error occures while downloading $m_PAGE."
   ;;
4) DisplayE "A network error occures while downloading $m_PAGE."
   ;;
5) DisplayE "A SSL verification error occures while downloading $m_PAGE."
   ;;
6) DisplayE "A username/password authentication error occures while downloading $m_PAGE."
   ;;
7) DisplayE "A protocol error occures while downloading $m_PAGE."
   ;;
8) DisplayE "The server issued an error response while downloading $m_PAGE."
esac

exit ${m_iError}
