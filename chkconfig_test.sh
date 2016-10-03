#!/usr/bin/bash
#
#Created by Daniel Maixner <xskipy@gmail.com>
#  	Under GNU GENERAL PUBLIC LICENSE
#
#
#
#

is_ignored_file() {
    case "$1" in
	*~ | *.bak | *.orig | *.rpmnew | *.rpmorig | *.rpmsave)
	    return 0
	    ;;
    esac
    return 1
}

LOGFILE="/dev/stdout"
ROOT="/"
while [ "$1" != "${1##[-+]}" ]; do
        case $1 in
        --logfile)
                LOGFILE=$2
                shift 2
        ;;
        --root)
                ROOT=$2
                shift 2
        ;;
        *)
                echo "Wrong args"
                exit 1;;
    esac
done

cd $ROOT/etc/rc.d/init.d
touch $LOGFILE
echo "
				chkconfig testlog
---------------------------------------------------------" >> $LOGFILE

date >> $LOGFILE
for INITNAME in $(ls --ignore "functions" --ignore "README")
do
	is_ignored_file
	printf "Testing init %s : \n" "$INITNAME"
	chkconfigSettings=$(grep "chkconfig" $ROOT/etc/rc.d/init.d/"$INITNAME")
	RUNLEVELS=$(echo "$chkconfigSettings" | awk '{printf $3}') 	#RUNLEVEL VARIABLE INITIALIZATION..
	printf "On run levels.. %s \n" "$RUNLEVELS"
	STA=$(echo "$chkconfigSettings" | awk '{printf $4}')
	END=$(echo "$chkconfigSettings" | awk '{printf $5}')
	#printf "%s" $RUNLEVELS
	ok=true
	first=0
	if [ ! $RUNLEVELS == "-" ]; then
		for i in $(seq 0 1 ${#RUNLEVELS}); do		# I - position in string RUNLEVELS
			n=${RUNLEVELS:$i:1}
			if [ ! "$n" == '' ]; then
				for lev in $(seq $first 1 6); do
					if [ $lev == $n ]; then
						if [ -e $ROOT/etc/rc.d/rc$n.d/S$STA$INITNAME ]; then
							echo "S$STA$INITNAME found in $ROOT/etc/rc.d/rc$lev.d/" >> $LOGFILE
							first=$(($n+1))
							continue 2

						else
							echo "S$STA$INITNAME NOT FOUND!!! in $ROOT/etc/rc.d/rc$lev.d/"  >> $LOGFILE
							first=$(($n+1))
							ok=false
							continue 2
						fi
					else
						if [ -e $ROOT/etc/rc.d/rc$lev.d/K$END$INITNAME ]; then
							echo "K$END$INITNAME found in /etc/rc.d/rc$lev.d/" >> $LOGFILE
						else
							echo "K$END$INITNAME NOT FOUND!!! in /etc/rc.d/rc$lev.d/"  >> $LOGFILE
							ok=false
						fi
					fi
				done
			fi
		done
	else
		for k in $(seq 0 1 6); do
			if [ -e $ROOT/etc/rc.d/rc$k.d/K$END$INITNAME ]; then
				echo "K$END$INITNAME found in /etc/rc.d/rc$k.d/" >> $LOGFILE
			else
				echo "K$END$INITNAME NOT FOUND!!! in /etc/rc.d/rc$k.d/"  >> $LOGFILE
				ok=false
			fi
		done
	fi
	#printf "%s \n" "$chkconfigSettings"
	#printf "\n"

	if [ $ok = true ]; then
				printf "Init $INITNAME is ok." >>  $LOGFILE
				echo "Ok.."

		else
				printf "Init $INITINAME is NOT OK, see log^." >> $LOGFILE
				echo "Fail.."
	fi
	echo "
" >> $LOGFILE
done
echo "Log file created at.. $LOGFILE"
