#!/usr/bin/bash
#
#Created by Daniel Maixner <xskipy@gmail.com>
#  	Under GNU GENERAL PUBLIC LICENSE
#
#
#
#set -x

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
				lsb testlog
---------------------------------------------------------" >> $LOGFILE

date >> $LOGFILE
for INITNAME in $(ls --ignore "functions" --ignore "README")
do
	is_ignored_file
	printf "Testing init %s : \n" "$INITNAME"
	lsb_start=$(grep "Default-Start" $ROOT/etc/rc.d/init.d/"$INITNAME")
	lsb_stop=$(grep "Default-Stop" $ROOT/etc/rc.d/init.d/"$INITNAME")
	#RUNLEVELS=$(echo "$chkconfigSettings" | awk '{printf $3}') 	#RUNLEVEL VARIABLE INITIALIZATION..
	#printf "$lsb_start /n$lsb_stop /n" >> $LOGFILE
	#printf "%s" $RUNLEVELS
	ok=true
	compatible=false
	for i in $(seq 3 1 6); do
		STA=$(echo "$lsb_start" | awk "{printf \$$i}")
		END=$(echo "$lsb_stop" | awk "{printf \$$i}")

		if [ "$STA" == '' ]; then
			STA=-1
	  fi
		if [ "$END" == '' ]; then
			END=-1
		fi

		for n in $(seq 0 1 6); do
			if [ $n == $STA ]; then
				if [ -e $ROOT/etc/rc.d/rc$n.d/S*$INITNAME ]; then
					echo "$( ls $ROOT/etc/rc.d/rc$n.d/ | grep "***$INITNAME" ) found in $ROOT/etc/rc.d/rc$n.d/" >> $LOGFILE
					compatible=true
				else
					echo "$( ls $ROOT/etc/rc.d/rc$n.d/ | grep "***$INITNAME" ) NOT FOUND!!! in $ROOT/etc/rc.d/rc$n.d/"  >> $LOGFILE
					compatible=true
					ok=false
				fi
			fi

			if [ $n == $END ]; then
				if [ -e $ROOT/etc/rc.d/rc$n.d/K*$INITNAME ]; then
					echo "$( ls $ROOT/etc/rc.d/rc$n.d/ | grep "***$INITNAME" ) found in $ROOT/etc/rc.d/rc$n.d/" >> $LOGFILE
					compatible=true
				else
					echo "$( ls $ROOT/etc/rc.d/rc$n.d/ | grep "***$INITNAME" )NOT FOUND!!! in $ROOT/etc/rc.d/rc$n.d/"  >> $LOGFILE
					compatible=true
					ok=false
				fi
			fi
		done
	done

	#printf "%s /n" "$chkconfigSettings"
	#printf "/n"
  if [ $compatible = true ]; then
		if [ $ok = true ]; then
					echo "Init $INITNAME is ok.
Checking dependencies.." >>  $LOGFILE
					echo "Ok.."
					dep=3
					dependencies=$(grep "Required-Start" $ROOT/etc/rc.d/init.d/$INITNAME)
					if [ "$(echo "$dependencies" | awk "{printf \$$dep}")" == '' ]; then
						echo "Ok.. " >> $LOGFILE
						echo "Ok.."
					fi
					while [ ! $(echo "$dependencies" | awk "{printf \$$dep}") == '' ]; do
							dependencies=$(echo "$dependencies" | awk "{printf \$$dep}")
							STA=$(echo "$lsb_start" | awk "{printf \$3}")
							cd /etc/rc.d/rc$STA.d/
						  InitFile=$( dir | grep "S*$INITNAME" )
							IForder=${InitFile:1:2}
							DepFile=$( dir | grep "***$dependencies" )
							DForder=${DepFile:1:2}
							if [ $IForder -lt $DForder ]; then
								echo "Init $INITNAME is starting after required $dependencies.... Ok" >> $LOGFILE
								echo "$INITNAME is starting after required $dependencies.. ok"
							else
								echo "Init $INITNAME is starting BEFORE required $dependencies.... FAIL!!!" >> $LOGFILE
								echo "$INITNAME is starting BEFORE required $dependencies.. FAIL!!!"
							fi
							dep=$(($dep+1))
					done
		else
					echo "Init $INITNAME is NOT OK, see log^." >> $LOGFILE
					echo "Dependencies were not tested.
					" >> $LOGFILE
					echo "Fail..
Dependencies were not tested."
		fi
	else
		echo "Init $INITNAME is not compatible with lsb." >> $LOGFILE
		echo "Not compatible with lsb.."
	fi
	echo "
" >> $LOGFILE
done

echo "Log file created at.. $LOGFILE"
