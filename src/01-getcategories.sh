#!/bin/sh

#************************************************#
#                getcategories.sh                #
#                   28.02.2012                   #
#                                                #
# Download and parse the categories page.        #
#************************************************#

#------------------------------------#
# Define                             #
#------------------------------------#
m_DIRWC=$(/usr/bin/dirname $(/bin/readlink -f $0))
. "${m_DIRWC}/wc.cfg"
m_DIRDOWNL="${m_DIRWC}/${wc_DOWNLDIRNAME}"
m_DIRCACHE="${m_DIRWC}/${wc_CACHEDIRNAME}"
m_FILECAT="${m_DIRCACHE}/${wc_FILECATNAME}"
m_PAGE="${wc_PAGE}categories/"
m_PATTERN="<a[[:blank:]]href=\"http://www.___.com/([[:alnum:]_-]+/[[:alnum:]_-]+-video)/\">"
m_FILEWEB="${m_DIRDOWNL}/categories.html"
m_MODESPIDER=0

#------------------------------------#
# Functions                          #
#------------------------------------#
. "${m_DIRWC}/includes/function.inc"

#------------------------------------#
# Optional arguments                 #
#------------------------------------#
while getopts :s m_sOption; do
    case $m_sOption in
    s)
        m_MODESPIDER=1
        ;;
    \?)
        Display "Usage: `/usr/bin/basename $0` [options]"
        Display "\t-s\tspider mode. do not download the web page."
        exit 1
        ;;
    esac
done

#------------------------------------#
# Process number                     #
#------------------------------------#
Display "The PID for `/usr/bin/basename $0` process is:${COLORGREEN}$$${COLORRESET}"

#------------------------------------#
# Download the page                  #
#------------------------------------#
if [ "$m_MODESPIDER" -lt 1 ]; then
    ./includes/wc-wget.sh "$m_PAGE" "$m_FILEWEB" "--no-verbose"
    if [ $? -gt 0 ]; then
        DisplayE "Abort."
        exit 1
    fi
fi

#------------------------------------#
# Save the last number of downloaded #
# categories.                        #
#------------------------------------#
if [ -s "$m_FILECAT" -a -r "$m_FILECAT" ]; then
    m_iCategoriesCountOld=`/bin/grep -v '^\W*$' $m_FILECAT | /usr/bin/wc -l`
    /bin/rm -f "$m_FILECAT"
else
    m_iCategoriesCountOld=0
fi
/usr/bin/touch "$m_FILECAT"

#------------------------------------#
# Capture                            #
#------------------------------------#
./includes/wc-capture.sh $m_PATTERN "$m_FILEWEB" "$m_FILECAT" "--quiet"

#------------------------------------#
# Count the new number of downloaded #
# categories.                        #
#------------------------------------#
if [ $? -gt 0 ]; then
    DisplayE "An error occures while capturing the categories. Abort."
    exit 1
else
    m_iCategoriesCountNew=`/bin/grep -v '^\W*$' $m_FILECAT | /usr/bin/wc -l`
    m_iDiff=$(($m_iCategoriesCountNew-$m_iCategoriesCountOld))
    if [ $m_iDiff -lt 0 ]; then
        Display "Found less ${COLORRED}($m_iDiff)${COLORRESET} categories than expected."
    else
        Display "Found more ${COLORGREEN}(+$m_iDiff)${COLORRESET} categories."
    fi
fi

exit 0
