#************************************************#
#                   function.sh                  #
#                   28.02.2012                   #
#                                                #
# Usefull functions.                             #
#************************************************#
DisplayE () {
    if [ -n "$1" ]; then
        echo "${COLORRED}$@${COLORRESET}"
    fi
    return 0
}
Display () {
    if [ -n "$1" ]; then
        echo "$@"
    fi
    return 0
}
Delete () {
    if [ -n "$1" ]; then
        if [ -f "$1" ]; then
            /bin/rm -f "$1"
        fi
        /usr/bin/touch "$1"
    fi
}
