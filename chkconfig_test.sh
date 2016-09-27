#!/usr/bin/bash
#
#Created by Daniel Maixner <xskipy@gmail.com>
#  	Under GNU GENERAL PUBLIC LICENSE
#
#
#
#
cd /etc/rc.d/init.d
touch /home/$USER/testlog.txt
echo "
				chkconfig testlog
---------------------------------------------------------" >> /home/$USER/testlog.txt

date >> /home/$USER/testlog.txt
for INITNAME in $(ls --ignore "functions" --ignore "README")
do
	printf "Testing init %s : \n" "$INITNAME"
	chkconfigSettings=$(grep "chkconfig" /etc/rc.d/init.d/"$INITNAME")
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
						if [ -e /etc/rc.d/rc$n.d/S$STA$INITNAME ]; then
							echo "S$STA$INITNAME found in /etc/rc.d/rc$lev.d/" >> /home/$USER/testlog.txt
							first=$(($n+1))
							continue 2

						else
							echo "S$STA$INITNAME NOT FOUND!!! in /etc/rc.d/rc$lev.d/"  >> /home/$USER/testlog.txt
							first=$(($n+1))
							ok=false
							continue 2
						fi
					else
						if [ -e /etc/rc.d/rc$lev.d/K$END$INITNAME ]; then
							echo "K$END$INITNAME found in /etc/rc.d/rc$lev.d/" >> /home/$USER/testlog.txt
						else
							echo "K$END$INITNAME NOT FOUND!!! in /etc/rc.d/rc$lev.d/"  >> /home/$USER/testlog.txt
							ok=false
						fi
					fi
				done
			fi
		done
	else
		for k in $(seq 0 1 6); do
			if [ -e /etc/rc.d/rc$k.d/K$END$INITNAME ]; then
				echo "K$END$INITNAME found in /etc/rc.d/rc$k.d/" >> /home/$USER/testlog.txt
			else
				echo "K$END$INITNAME NOT FOUND!!! in /etc/rc.d/rc$k.d/"  >> /home/$USER/testlog.txt
				ok=false
			fi
		done
	fi
	#printf "%s \n" "$chkconfigSettings"
	#printf "\n"

	if [ $ok = true ]; then
				printf "Init $INITNAME is ok." >>  /home/$USER/testlog.txt
				echo "Ok.."

		else
				printf "Init $INITINAME is NOT OK, see log^." >> /home/$USER/testlog.txt
				echo "Fail.."
	fi
	echo "
" >> /home/$USER/testlog.txt
done
echo "Log file created at.. /home/$USER/testlog.txt"
