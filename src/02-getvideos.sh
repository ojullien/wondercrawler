#!/bin/sh

#************************************************#
#                  getvideos.sh                  #
#                   28.02.2012                   #
#                                                #
# Download and parse category pages.             #
#************************************************#

#------------------------------------#
# Define                             #
#------------------------------------#
m_DIRWC=$(/usr/bin/dirname $(/bin/readlink -f $0))
. "${m_DIRWC}/wc.cfg"
m_DIRDOWNL="${m_DIRWC}/${wc_DOWNLDIRNAME}"
m_DIRCACHE="${m_DIRWC}/${wc_CACHEDIRNAME}"
m_DIRVIDEO="${m_DIRCACHE}/${wc_VIDEODIRNAME}"
m_FILECAT="${m_DIRCACHE}/${wc_FILECATNAME}"
m_FILEWEB="${m_DIRDOWNL}/current.htm"
m_FILECNT="${m_DIRCACHE}/current.cnt"
m_FILEVID="${m_DIRCACHE}/current.lst"
m_PAGE="${wc_PAGE}"
m_PAGEPOST="/how-to-videos/by-newest/"
m_MODESPIDER=0
m_MODECHECKALL=0
m_MODEUPDATE=0

#------------------------------------#
# Functions                          #
#------------------------------------#
. "${m_DIRWC}/includes/function.inc"

#------------------------------------#
# Optional arguments                 #
#------------------------------------#
while getopts :asu m_sOption; do
    case $m_sOption in
    a)
        m_MODECHECKALL=1
        Display "Check all the pages."
        ;;
    u)
        m_MODEUPDATE=1
        Display "Update only already downloaded categories."
        ;;
    s)
        m_MODESPIDER=1
        Display "Mode spider is ON."
        ;;
    \?)
        Display "Usage: `/usr/bin/basename $0` [options]"
        Display "\t-a\tall option. Download all the page. By default, the current category download is stopped when we found a page without new video."
        Display "\t-s\tspider mode. Do not download the web page."
        Display "\t-u\tupdate option. Update only already downloaded categories. Do not download new categories."
        exit 1
        ;;
    esac
done

#------------------------------------#
# Process number                     #
#------------------------------------#
Display "The PID for `/usr/bin/basename $0` process is:${COLORGREEN}$$${COLORRESET}"

#------------------------------------#
# Read categories list               #
#------------------------------------#
if [ ! -f "$m_FILECAT" -o ! -r "$m_FILECAT" ]; then
    DisplayE "Error: $m_FILECAT is not a file or can not be read."
    exit 1
fi
while IFS=  read -r m_Ligne; do

    #------------------------------------#
    # Update mode                        #
    #------------------------------------#
    if [ $m_MODEUPDATE -eq 1 ]; then
        m_sCategoryName="${m_Ligne%/*}"
        if [ ! -d "${m_DIRVIDEO}/${m_sCategoryName}" ]; then
            continue
        fi
    fi

    #------------------------------------#
    # Initialize                         #
    #------------------------------------#
    Display "Processing ${COLORGREEN}$m_Ligne${COLORRESET} ..."
    m_iVideoTotal=0
    m_iVideoCount=-1
    m_iIndex=1

    #------------------------------------#
    # Compute all the pages              #
    #------------------------------------#
    while [ $m_iVideoCount -lt $m_iVideoTotal ]; do

        #------------------------------------#
        # Remove tmp files                   #
        #------------------------------------#
        if [ $m_MODESPIDER -eq 0 ]; then
            Delete "$m_FILEWEB"
            Delete "$m_FILECNT"
            Delete "$m_FILEVID"
        fi
        m_sErrorMessage="downloading pages for $m_Ligne"
        Display "\tDownloading page ${COLORGREEN}$m_iIndex${COLORRESET}."

        #------------------------------------#
        # Download the page                  #
        #------------------------------------#
        m_sBuffer="$m_PAGE$m_Ligne$m_PAGEPOST"
        if [ $m_iIndex -gt 1 ]; then
            m_sBuffer="$m_sBuffer$m_iIndex/"
        fi
        if [ $m_MODESPIDER -eq 0 ]; then
            ./includes/wc-wget.sh "$m_sBuffer" "$m_FILEWEB" "--quiet"
        else
            Display "\tDo not download the pages when spider mode is ON."
        fi
        if [ $? -gt 0 ]; then
            DisplayE "Abort $m_sErrorMessage."
            break 2
        fi

        #------------------------------------#
        # Count the videos for the category  #
        #------------------------------------#
        if [ $m_iVideoTotal -eq 0 ]; then
            m_iVideoCount=0
            ./includes/wc-capturevideocount.sh "$m_FILEWEB" "$m_FILECNT"
            if [ $? -gt 0 ]; then
                DisplayE "Abort $m_sErrorMessage."
                break 2
            fi
            if [ -s "$m_FILECNT" -a -r "$m_FILECNT" ]; then
                m_iVideoTotal=`/usr/bin/head --lines=1 $m_FILECNT`
            else
                DisplayE "No video found. Abort $m_sErrorMessage."
                break 2
            fi
        fi

        #------------------------------------#
        # Capture video links in this page   #
        #------------------------------------#
        if [ $m_MODESPIDER -eq 0 ]; then
            ./includes/wc-capturevideolinks.sh "$m_FILEWEB" "$m_FILEVID"
            if [ $? -gt 0 ]; then
                DisplayE "Abort $m_sErrorMessage."
                break 2
            fi
        else
            Display "\tdo not capture the links when spider mode is on."
        fi

        #------------------------------------#
        # Count captured links in this page  #
        #------------------------------------#
        if [ -s "$m_FILEVID" -a -r "$m_FILEVID" ]; then
            m_iVideoCountPage=`grep -v '^\W*$' $m_FILEVID | wc -l`
        else
            DisplayE "No video found. Abort $m_sErrorMessage."
            break 2
        fi
        if [ $m_iVideoCountPage -gt 0 ]; then
            Display "\t\tfound ${COLORGREEN}$m_iVideoCountPage${COLORRESET} video link(s) in this page."
        else
            Display "\t\tfound ${COLORRED}$m_iVideoCountPage${COLORRESET} video link in this page."
            break 1
        fi
        m_iVideoCount=$(($m_iVideoCount+$m_iVideoCountPage))

        #------------------------------------#
        # Capture the videos                 #
        #------------------------------------#
        ./includes/wc-capturevideos.sh "$m_PAGE" "$m_Ligne" "$m_FILEVID" "$m_DIRCACHE" "$m_DIRDOWNL" "$m_MODESPIDER"
        m_iReturn=$?
        if [ $m_iReturn -eq 1 ]; then
            DisplayE "Abort $m_sErrorMessage."
            break 1
        fi
        if [ $m_iReturn -eq 2 -a $m_MODECHECKALL -eq 0 ]; then
            # No video captured in this page. Do not download the others page
            Display "\t\tNo video captured in this page. Do not download the other pages."
            break 1
        fi

        #------------------------------------#
        # stop the process                   #
        #------------------------------------#
        m_iIndex=$(($m_iIndex+1))
        if [ -f "$m_DIRWC/stop" ]; then
            Display "Stop $m_sErrorMessage."
            break
        fi

    done

    #------------------------------------#
    # stop the process                   #
    #------------------------------------#
    if [ -f "$m_DIRWC/stop" ]; then
        Display "Stop downloading categories."
        break
    fi

done < "$m_FILECAT"

exit 0
