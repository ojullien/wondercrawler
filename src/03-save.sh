#!/bin/sh

#************************************************#
#                     save.sh                    #
#                   28.02.2012                   #
#                                                #
# Compress and save downloaded data.             #
#************************************************#

#------------------------------------#
# Define                             #
#------------------------------------#
m_DIRWC=$(/usr/bin/dirname $(/bin/readlink -f $0))
. "${m_DIRWC}/wc.cfg"
m_DIRCSV="${wc_CSVDIRNAME}"
m_DIRCACHE="${wc_CACHEDIRNAME}"
m_DIRVIDEO="${m_DIRCACHE}/${wc_VIDEODIRNAME}"
m_DIRDEST="/mnt/sharedfolder/wondercrawler"
m_DIRDESTCSV="${m_DIRDEST}/${wc_CSVDIRNAME}"
m_DIRDESTCACHE="${m_DIRDEST}/${wc_CACHEDIRNAME}"

#------------------------------------#
# Functions                          #
#------------------------------------#
. "${m_DIRWC}/includes/function.inc"

#------------------------------------#
# Check destination folders          #
#------------------------------------#
if [ ! -d ${m_DIRDESTCSV} ]; then
    DisplayE "${m_DIRDESTCSV} is not a folder."
fi
if [ ! -d ${m_DIRDESTCACHE} ]; then
    DisplayE "${m_DIRDESTCACHE} is not a folder."
fi

#------------------------------------#
# Process number                     #
#------------------------------------#
Display "The PID for `/usr/bin/basename $0` process is:${COLORGREEN}$$${COLORRESET}"

#------------------------------------#
# For each processed category        #
#------------------------------------#
m_iLineCount=0
for m_sFullPath in $( find ${m_DIRVIDEO} -maxdepth 1 -type d | sort )
do

    #------------------------------------#
    # Get the category name              #
    #------------------------------------#
    if [ $m_iLineCount -eq 0 ]; then
        m_iLineCount=$(($m_iLineCount+1))
    else

        #------------------------------------#
        # Initialize                         #
        #------------------------------------#
        m_sCategory="${m_sFullPath##*/}" # Strip longest match of */ from the beginning
        Display "Processing ${COLORGREEN}${m_sCategory}${COLORRESET} ..."

        #------------------------------------#
        # CSV file should exist              #
        #------------------------------------#
        m_sFileCSV="${m_DIRCSV}/${m_sCategory}.csv"
        if [ ! -f "${m_sFileCSV}" ]; then
            DisplayE "\t${m_sFileCSV} doesn't exist."
            continue
        fi

        #------------------------------------#
        # tar and save cache                 #
        #------------------------------------#
        /bin/tar cjf "${m_DIRDESTCACHE}/${m_sCategory}.tar.bz2" "${m_sFullPath}/"
        if [ $? -gt 0 ]; then
            DisplayE "Cannot tar ${m_sFullPath}."
            continue
        fi

        #------------------------------------#
        # tar and save csv                   #
        #------------------------------------#
        /bin/tar cjf "${m_DIRDESTCSV}/${m_sCategory}.tar.bz2" "${m_DIRCSV}/${m_sCategory}.csv"
        if [ $? -gt 0 ]; then
            DisplayE "Cannot tar ${m_DIRCSV}/${m_sCategory}.csv."
            continue
        fi

    fi

done

exit 0
