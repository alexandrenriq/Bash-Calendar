#!/bin/bash

# TODO: support for flags (show the calendar of a month and year)

CGREEN="\033[0;32m"
BGREEN="\033[0;102m"
BGREEN_CBLACK="\033[0;30;102m"

NOCOLOR="\033[0m"
C_MONTH=$(date +%b)
C_YEAR=$(date +%Y)
C_DAY=$(date +%d)
M_ARRAY=('Jan:1' 'Feb:2' 'Mar:3' 'Apr:4' 'May:5' 'Jun:6'
         'Jul:7' 'Aug:8' 'Sep:9' 'Oct:10' 'Nov:11' 'Dec:12')
N_DAYS=('31' '28' '31' '30' '31' '30' '31' '31' '30' '31' '30' '31')

get_month_number() {
    m=$1
    for month in "${M_ARRAY[@]}" ; do
        KEY="${month%%:*}"
        VALUE="${month##*:}"
        if [[ $KEY == $m ]]
        then
            echo $(($VALUE-1))
            return
        fi
    done
}
last_day_month() {
    month=$(get_month_number $C_MONTH)
    if [ $month -ne 2 ]; then
        echo ${N_DAYS[$month]}
        return
    fi
    leap=0
    if [ $(($C_YEAR%4)) == 0 ]; then
        leap=1
    elif [ $(($C_YEAR%100)) == 0 ] && [ $(($C_YEAR%400)) == 0 ]; then
        leap=1
    fi
    days=28
    if [ $leap == 1 ]; then
        days=29
    fi
    echo $days
}
get_julian_day() {
    year=$1
    month=$2
    day=$3
    jd=$((day - 32075 + 1461 * (year + 4800 - (14 - month) / 12) / 4
        + 367 * (month - 2 + ((14 - month) / 12) * 12) / 12 - 3 *
        ((year + 4900 - (14 - month) / 12) / 100) / 4))
    echo $jd
}
get_day_of_week() {
    jd=$1
    ((day=(jd+4)%7))
    echo $day
}
print_month() {
    if [ "$1" == "-h " ]; then
        echo "Hola"
        exit 0
    fi
    wdays=('Su' 'Mo' 'Tu' 'We' 'Th' 'Fr' 'Sa')
    echo -e "${CGREEN}\c"
    printf "%0.s " {1..6}
    echo -e "$C_MONTH $C_YEAR"
    for d in "${wdays[@]}"; do
        echo -e "$d \c"
    done
    echo -e "${NOCOLOR}"

    fd=$(get_day_of_week $(get_julian_day $C_YEAR $(get_month_number $C_MONTH) 1))
    ld=$(get_day_of_week $(get_julian_day $C_YEAR $(get_month_number $C_MONTH) $(last_day_month)))
    if [ $fd != 1 ]; then
        for i in `eval echo {1..$((3*($fd-1)))}`; do echo -e " \c"; done
    fi

    day_of_week_counter=$fd
    for d in `eval echo {1..$(($(last_day_month)))}`
    do
        echo -e "${BGREEN_CBLACK}\c"
        if [ $d -ne $((C_DAY)) ]
        then
            echo -e "${NOCOLOR}\c"
        fi
        if [ $d -lt 10 ]
        then
            echo -e "0\c"
        fi
        echo -e "$d\c"
        echo -e "${NOCOLOR} \c"
        
        if [ $day_of_week_counter -eq 7 ]
        then
            day_of_week_counter=0
            echo -e ""
        fi
        day_of_week_counter=$((day_of_week_counter+1))
    done
    echo ""
}
print_month


# if [ ! -e calendar.dat ]; then
#     echo  > calendar.dat
# else
#     echo  >> calendar.dat
# fi
# filename="calendar.dat"
# n=1
# while read line; do
# #echo "Linea No. $n : $line"
# n=$((n+1))
# done < $filename
