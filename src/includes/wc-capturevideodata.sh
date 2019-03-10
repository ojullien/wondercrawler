#!/bin/bash

#************************************************#
#               capturevideodata.sh              #
#                   28.02.2012                   #
#                                                #
# Capture video data.                            #
#************************************************#

#------------------------------------#
# Define                             #
#------------------------------------#
declare -r m_DIRWC=$(/usr/bin/dirname $(/bin/readlink -f $0))
source "${m_DIRWC}/../wc.cfg"
declare -r DQUOTE='"'
declare -r SEP='";"'

#------------------------------------#
# Declaration                        #
#------------------------------------#
# Order in the csv file: Category;Sub-Category;Categories;Grade;Rating;Views;Publish-date;Title;Description;Duration;Link;Keywords;Host;Creator
# Assume this order in the html file: Duration,Description,Publish-date,Grade,Title,Rating,Views,Keywords,Category,Host,Creator,Link
declare -a m_aTAG
declare -a m_aPATTERN
m_aPATTERN[0]='<meta[[:blank:]]name=\"duration\"[[:blank:]]content=\"([[:digit:]]+)\"'
m_aPATTERN[1]='<meta[[:blank:]]name=\"description\"[[:blank:]]content=\"(.*)\"'
m_aPATTERN[2]='<meta[[:blank:]]name=\"publish-date\"[[:blank:]]content=\"(.*)\"'
m_aPATTERN[3]='<meta[[:blank:]]name=\"external-data\"[[:blank:]]content=\"(.*)\"'
m_aPATTERN[4]='<meta[[:blank:]]name=\"title\"[[:blank:]]content=\"(.*)\"'
m_aPATTERN[5]='<meta[[:blank:]]name=\"rating\"[[:blank:]]content=\"(.*)\"'
m_aPATTERN[6]='<meta[[:blank:]]name=\"views\"[[:blank:]]content=\"(.*)\"'
m_aPATTERN[7]='<meta[[:blank:]]name=\"keywords\"[[:blank:]]content=\"(.*),how[[:blank:]]to'
m_aPATTERN[8]='<meta[[:blank:]]name=\"category\"[[:blank:]]content=\"(.*)\"'
m_aPATTERN[9]='[H|h]osted by.*nofollow\">(.*)</a>'
m_aPATTERN[10]='id=\"video[C|c]reator[S|s]ite\"><a.*\">(.*)</a>'
m_aPATTERN[11]='(Video May Contain Mature Content)'
m_aPATTERN[12]='<embed[[:blank:]]src=\\\"http://([^&|\\]+)'
m_aPATTERN[13]='<embed[[:blank:]].*src=\"http://([^\"]+)'
m_aPATTERN[14]='<embed[[:blank:]].*src=\\\"http://([^\"]+)'
m_aPATTERN[15]='<iframe[[:blank:]].*src=\"http://([^\"]+)'
m_aPATTERN[16]='<iframe[[:blank:]].*src=\\\"http://([^\"]+)'
m_aPATTERN[17]='<param[[:blank:]]name=\\\"flashVars\\\"[[:blank:]]value=\\\"source=http://([^&|\\]+)'
m_aPATTERN[18]='([O|o]ffsite[[:blank:]]video[[:blank:]]plays[[:blank:]]on:.*)$'
m_aPATTERN[19]='param[[:blank:]]name=\\\"movie\\\"[[:blank:]]value=\\\"http://([^\\]+)'
m_aPATTERN[20]="document.write\('(.*</object>)'\);"
declare -a m_iCSVOrder=(8 3 5 6 2 4 1 0 11 7 9 10)
declare -a m_aData
declare -i m_iIndex=0
for iI in {0..20}
do
    m_aTAG[$iI]=0
done

#------------------------------------#
# Functions                          #
#------------------------------------#
source "${m_DIRWC}/function.inc"
FileError () {
    if [ -n "$1" -a -n "$2" -a -n "$3" ]; then
        local m_sOut="$3.$1.$2"
        local m_sDate=$(date +%s)
        m_sOut=$m_sOut.$m_sDate
        cp "$3" "$m_sOut"
        if [ $? -eq 0 ]; then
            Display "...... source file saved: $m_sOut"
        else
            DisplayE "...... source file not saved!"
        fi
    fi
    return 0
}
#Display "The PID for `basename $0` process is:$$"

#------------------------------------#
# Parameters                         #
#------------------------------------#
if [ $# -lt 4 -o -z "$1" -o -z "$2" -o -z "$3" -o -z "$4" ]; then
    DisplayE "Usage: `/usr/bin/basename $0` <WEB FILE> <CSV FILE> <CATEGORY> <SUB-CATEGORY>"
    exit 1
fi
declare -r m_FILEWEB=$1
if [ ! -s "$m_FILEWEB" -o ! -r "$m_FILEWEB" ]; then
    DisplayE "Error: $m_FILEWEB is not a file or can not be read."
    exit 1
fi
declare -r m_FILECSV="$2"
if [ ! -f "$m_FILECSV" -o ! -w "$m_FILECSV" ]; then
    DisplayE "Error: $m_FILECSV is not a file or can not be written."
    exit 1
fi
declare -r m_sCategory=$3
declare -r m_sSubCategory=$4

#------------------------------------#
# Read video page                    #
#------------------------------------#
while IFS=  read -r m_Ligne; do

    #------------------------------------#
    # Looking for meta tags              #
    #------------------------------------#
    m_iIndex=0
    while [ $m_iIndex -lt ${#m_aPATTERN[@]} ]
    do
        # Look for pattern not found yet
        if [ ${m_aTAG[$m_iIndex]} -eq 0 ]; then
            if [[ $m_Ligne =~ ${m_aPATTERN[$m_iIndex]} ]]; then

                # Pattern matches
                if [ ${#BASH_REMATCH[@]} -gt 1 ]; then
                    # Save the value
                    m_aData[$m_iIndex]="${BASH_REMATCH[1]}"
                fi
                # Error case: more matches
                if [ ${#BASH_REMATCH[@]} -gt 2 ]; then
                    DisplayE "Found ${#BASH_REMATCH[*]} captures for '${BASH_REMATCH[0]}'"
                    exit 1
                fi

                # Do not look for this pattern anymore
                m_aTAG[$m_iIndex]=1

                # Link case: update 8 offsets
                if [ $m_iIndex -gt 10 ]; then
                    for iI in {11..20}
                    do
                        m_aTAG[$iI]=1
                        m_aData[$iI]=${m_aData[$m_iIndex]}
                    done
                fi

                # Exit the loop. Assuming only one line contains the pattern.
                break

            fi
        fi

        m_iIndex=$(($m_iIndex+1))

    done

    # Stop if everything is captured
    if [[ ! ${m_aTAG[*]} =~ 0 ]]; then
        break
    fi

done < "$m_FILEWEB"

#------------------------------------#
# Error case: one tag is missing     #
#------------------------------------#
if [[ ${m_aTAG[*]} =~ 0 ]]; then
    DisplayE "Error: a tag can not be found. Stack: ${m_aTAG[*]}"
    FileError "$m_sCategory" "$m_sSubCategory" "$m_FILEWEB"
    exit 1
fi

#------------------------------------#
# Write the line in the file         #
#------------------------------------#
# Begin line
m_sCSVLine="$DQUOTE"
# Add category
m_sCSVLine="$m_sCSVLine$m_sCategory"
# Add sub-category
m_sCSVLine="$m_sCSVLine$SEP$m_sDQuote$m_sSubCategory"
# Add data
m_iIndex=0
while [ $m_iIndex -lt ${#m_iCSVOrder[@]} ]
do
    # Get the data
    m_sBuffer=${m_aData[${m_iCSVOrder[$m_iIndex]}]}
    # Double the quote
    m_sQuoted=$(echo "$m_sBuffer"|/bin/sed 's/"/""/g')
    # Add the data
    m_sCSVLine="$m_sCSVLine$SEP$m_sDQuote$m_sQuoted"
    m_iIndex=$(($m_iIndex+1))
done
# End line
m_sCSVLine="$m_sCSVLine$DQUOTE"
# Write
echo "$m_sCSVLine" >> $m_FILECSV

exit 0
