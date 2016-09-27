#!/usr/bin/bash
#
#Created by Daniel Maixner <xskipy@gmail.com>
#  	Under GNU GENERAL PUBLIC LICENSE
#
#
#
#set -x
cd /etc/rc.d/init.d
touch /home/$USER/testlog.txt
echo "
				lsb testlog
---------------------------------------------------------" >> /home/$USER/testlog.txt

date >> /home/$USER/testlog.txt
for INITNAME in $(ls --ignore "functions" --ignore "README")
do
	printf "Testing init %s : \n" "$INITNAME"
	lsb_start=$(grep "Default-Start" /etc/rc.d/init.d/"$INITNAME")
	lsb_stop=$(grep "Default-Stop" /etc/rc.d/init.d/"$INITNAME")
	#RUNLEVELS=$(echo "$chkconfigSettings" | awk '{printf $3}') 	#RUNLEVEL VARIABLE INITIALIZATION..
	#printf "$lsb_start /n$lsb_stop /n" >> /home/$USER/testlog.txt
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
				if [ -e /etc/rc.d/rc$n.d/S*$INITNAME ]; then
					echo "$( ls /etc/rc.d/rc$n.d/ | grep "***$INITNAME" ) found in /etc/rc.d/rc$n.d/" >> /home/$USER/testlog.txt
					compatible=true
				else
					echo "$( ls /etc/rc.d/rc$n.d/ | grep "***$INITNAME" ) NOT FOUND!!! in /etc/rc.d/rc$n.d/"  >> /home/$USER/testlog.txt
					compatible=true
					ok=false
				fi
			fi

			if [ $n == $END ]; then
				if [ -e /etc/rc.d/rc$n.d/K*$INITNAME ]; then
					echo "$( ls /etc/rc.d/rc$n.d/ | grep "***$INITNAME" ) found in /etc/rc.d/rc$n.d/" >> /home/$USER/testlog.txt
					compatible=true
				else
					echo "$( ls /etc/rc.d/rc$n.d/ | grep "***$INITNAME" )NOT FOUND!!! in /etc/rc.d/rc$n.d/"  >> /home/$USER/testlog.txt
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
Checking dependencies.." >>  /home/$USER/testlog.txt
					echo "Ok.."
					dep=3
					dependencies=$(grep "Required-Start" /etc/rc.d/init.d/$INITNAME)
					if [ "$(echo "$dependencies" | awk "{printf \$$dep}")" == '' ]; then
						echo "Ok.. " >> /home/$USER/testlog.txt
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
								echo "Init $INITNAME is starting after required $dependencies.... Ok" >> /home/$USER/testlog.txt
								echo "$INITNAME is starting after required $dependencies.. ok"
							else
								echo "Init $INITNAME is starting BEFORE required $dependencies.... FAIL!!!" >> /home/$USER/testlog.txt
								echo "$INITNAME is starting BEFORE required $dependencies.. FAIL!!!"
							fi
							dep=$(($dep+1))
					done
		else
					echo "Init $INITNAME is NOT OK, see log^." >> /home/$USER/testlog.txt
					echo "Dependencies were not tested.
					" >> /home/$USER/testlog.txt
					echo "Fail..
Dependencies were not tested."
		fi
	else
		echo "Init $INITNAME is not compatible with lsb." >> /home/$USER/testlog.txt
		echo "Not compatible with lsb.."
	fi
	echo "
" >> /home/$USER/testlog.txt
done

echo "Log file created at.. /home/$USER/testlog.txt"
