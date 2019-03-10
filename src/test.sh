#!/bin/bash

if [ ! -f "/usr/bin/tput" ]; then echo "/usr/bin/tput is missing."; exit 1; fi

#------------------------------------#
# Define                             #
#------------------------------------#
declare -r COLORRED="$(/usr/bin/tput setaf 1)"
declare -r COLORGREEN="$(/usr/bin/tput setaf 2)"
declare -r COLORRESET="$(/usr/bin/tput sgr0)"

#------------------------------------#
# Declaration                        #
#------------------------------------#
declare -a m_aPATTERN
m_aPATTERN[0]='<embed[[:blank:]]src=\\\"http://([^&|\\]+)'
m_aPATTERN[1]='<param[[:blank:]]name=\\\"flashVars\\\"[[:blank:]]value=\\\"source=http://([^&|\\]+)'
m_aPATTERN[2]='([O|o]ffsite[[:blank:]]video[[:blank:]]plays[[:blank:]]on:.*)$'
m_aPATTERN[3]='param[[:blank:]]name=\\\"movie\\\"[[:blank:]]value=\\\"http://([^\\]+)'
m_aPATTERN[4]="document.write\('(.*</object>)'\);"
m_aPATTERN[5]='<embed[[:blank:]].*[[:blank:]]src=\"http://([^\"]+)'
m_aPATTERN[6]='(Video May Contain Mature Content)'
m_aPATTERN[7]='<iframe[[:blank:]].*src=\"http://([^\"]+)'
m_aPATTERN[8]='<iframe[[:blank:]].*src=\\\"http://([^\"]+)'
m_aPATTERN[9]="document.write\('<iframe[[:blank:]].*[[:blank:]]src=\"http://([^\"]+)"
declare -a m_aData
m_aData[0]='<embed src=\"http://www.5min.com/Embeded/82680618/&sid=309&cbCustomID=vaCompanion&autoStart=false\" type=\"application/x-shockwave-flash\" width=\"644\" height=\"393\" allowfullscreen=\"true\" wmode=\"transparent\" allowscriptaccess=\"always\"></embed>'
m_aData[1]='<embed src=\"http://sclipo.com/outer_flvplayer_new.swf?file=CWK2T9G6O7\" type=\"application/x-shockwave-flash\" wmode=\"transparent\" width=\"644\" height=\"396\"></embed>'
m_aData[2]='<embed src=\"http://www.youtube.com/v/VHq7VcBJrYU&autoplay=0&rel=0&vq=2&fs=1\"</embed>'
m_aData[3]='<embed src=\"http://www.vivecoolcity.com/episodes-700kbs/EP285-HOW-TO-MAKE-PRUNO-PT1.mp4\" qtsrc=\"http://www.vivecoolcity.com/episodes-700kbs/EP285-HOW-TO-MAKE-PRUNO-PT1.mp4\" width=\"644\" height=\"387\" scale=\"aspect\" kioskmode=\"true\" autoplay=\"false\" loop=\"false\" controller=\"true\"</embed>'
m_aData[4]='<embed src=\"http://www.metacafe.com/fplayer/1591146/redirect.swf\" width=\"644\" height=\"394\" wmode=\"transparent\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\"</embed>'
m_aData[5]='<object id=\"KPlayer\" width=\"644\" height=\"388\" classid=\"clsid:D27CDB6E-AE6D-11cf-96B8-444553540000\"><param name=\"movie\" value=\"http://www.monkeysee.com/play/KPShare.swf?videoId=328&clipId=2229&autoplay=false\"/><param name=\"wmode\" value=\"opaque\"/><param name=\"AllowScriptAccess\" value=\"always\"/><param name=\"AllowFullScreen\" value=\"true\"/><embed allowscriptaccess=\"always\" allowfullscreen=\"true\" wmode=\"opaque\" src=\"http://www.monkeysee.com/play/KPShare.swf?videoId=328&clipId=2229&autoplay=false\" width=\"644\" height=\"388\" type=\"application/x-shockwave-flash\"></embed></object>'
m_aData[6]="document.write('<object type=\"application/x-shockwave-flash\" data=\"http://blip.tv/scripts/flash/showplayer.swf?autostart=false&brandname=WatchMojo.com&brandlink=http%3A//www.WatchMojo.com&file=http%3A//blip.tv/rss/flash/598353&showplayerpath=http%3A//blip.tv/scripts/flash/showplayer.swf&lightcolor=0x557722&backcolor=0x00000&frontcolor=0xCCCCCC&tabType2=guide&tabTitle2=WatchMojo%20episodes&tabUrl2=http%3A//WatchMojo.blip.tv/rss/flash&tabType1=details&tabTitle1=About\" width=\"644\" height=\"392\" allowfullscreen=\"true\" id=\"showplayer\"> <param name=\"movie\" value=\"http://blip.tv/scripts/flash/showplayer.swf?autostart=false&brandname=WatchMojo.com&brandlink=http%3A//www.WatchMojo.com&&file=http%3A//blip.tv/rss/flash/598353&showplayerpath=http%3A//blip.tv/scripts/flash/showplayer.swf&lightcolor=0x557722&backcolor=0x00000&frontcolor=0xCCCCCC&tabType2=guide&tabTitle2=WatchMojo%20episodes&tabUrl2=http%3A//WatchMojo.blip.tv/rss/flash&tabType1=details&tabTitle1=About\" /> <param name=\"quality\" value=\"best\" /></object>');//]]>"
m_aData[7]="document.write('<embed width=\"644\" height=\"389\" id=\"VideoPlayback\" type=\"application/x-shockwave-flash\" src=\"http://video.google.com/googleplayer.swf?docId=835434607440861066\" wmode=\"transparent\"></embed>');//]]>"
m_aData[8]='Video May Contain Mature Content'
m_aData[9]="document.write('<embed width=\"644\" height=\"387\" src=\"http://www.veoh.com/videodetails2.swf?permalinkId=v70771532kQbD7YP&player=videodetailsembedded&videoAutoPlay=0\" allowFullScreen=\"true\" wmode=\"transparent\" type=\"application/x-shockwave-flash\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\"></embed>');//]]>"
m_aData[10]="document.write('<embed width=\"644\" height=\"389\" id=\"VideoPlayback\" type=\"application/x-shockwave-flash\" src=\"http://video.google.com/googleplayer.swf?docId=-3226475432499847608\" wmode=\"transparent\"></embed>');//]]>"
m_aData[11]="document.write('<embed width=\"644\" height=\"392\" src=\"http://www.ifilm.com/efp\" flashvars=\"flvbaseclip=2880024\" quality=\"high\" name=\"efp\" align=\"middle\" type=\"application/x-shockwave-flash\" pluginspage=\"http://www.macromedia.com/go/getflashplayer\" wmode=\"transparent\"></embed>');//]]>"
m_aData[12]="document.write('<iframe align=\"center\" src=\"http://media.funmansion.com/funmansion/player/player.php?url=http://media.funmansion.com/content/flv/d7262007/soda_can_refill_illusion.flv\" width=\"644\" height=\"387\" scrolling=\"no\" align=\"center\" frameborder=\"0\"></iframe>');//]]>"

declare -i m_iIndexData=0
declare -i m_iIndexPattern=0
declare -i m_bFound=0
while [ $m_iIndexData -lt ${#m_aData[*]} ]
do
    m_bFound=0
    m_iIndexPattern=0
    while [ $m_iIndexPattern -lt ${#m_aPATTERN[*]} ]
    do
        if [[ ${m_aData[$m_iIndexData]} =~ ${m_aPATTERN[$m_iIndexPattern]} ]]; then
            echo "Data $m_iIndexData ${COLORGREEN}matches${COLORRESET} with pattern $m_iIndexPattern."
            echo "Capture is: ${BASH_REMATCH[1]}"
            echo ""
            m_bFound=1
        fi
        m_iIndexPattern=$(($m_iIndexPattern+1))
    done
    if [ $m_bFound -eq 0 ]; then echo "Data $m_iIndexData ${COLORRED}does not match${COLORRESET} any pattern."; fi
    m_iIndexData=$(($m_iIndexData+1))
done

exit 0
