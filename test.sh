#!/usr/bin/bash
#set -x
cd /etc/rc.d/init.d
touch /home/$USER/testlog.txt
echo "
" >> /home/$USER/testlog.txt
date >> /home/$USER/testlog.txt
for INITNAME in $(ls --ignore "functions" --ignore "README")
do
	#printf "Init %s : \n" "$INITNAME"	#COLOR THIS LINE
	chkconfigSettings=$(grep "chkconfig" /etc/rc.d/init.d/"$INITNAME")
	#printf "%s \n" "$chkconfigSettings" 
	RUNLEVELS=$(echo "$chkconfigSettings" | awk '{printf $3}') 	#RUNLEVEL VARIABLE INITIALIZATION..
	STA=$(echo "$chkconfigSettings" | awk '{printf $4}')
	END=$(echo "$chkconfigSettings" | awk '{printf $5}')
	#printf "%s" $RUNLEVELS
	if [ ! $RUNLEVELS == "-" ]; then 
		for i in $(seq 0 1 ${#RUNLEVELS}); do		# I - position in string RUNLEVELS
			n=${RUNLEVELS:$i:1}
			printf "%s " $n
			printf "%s " $RUNLEVELS
			printf "%s " $INITNAME
			printf "%s \n" $i	
			set -x
			for control in $(seq 0 1 6); do
				if [ "$control" -eq $n ]; then
					if [ -e /etc/rc.d/rc$control.d/S$STA$INITNAME ]; then
						echo "S$STA$INITNAME found in /etc/rc.d/rc$control.d/" >> /home/$USER/testlog.txt
					else
						echo "S$STA$INITNAME NOT FOUND!!! in /etc/rc.d/rc$control.d/"  >> /home/$USER/testlog.txt
					fi
				else
					if [ -e /etc/rc.d/rc$control.d/K$END$INITNAME ]; then
						echo "K$END$INITNAME found in /etc/rc.d/rc$control.d/" >> /home/$USER/testlog.txt
					else
						echo "K$END$INITNAME NOT FOUND!!! in /etc/rc.d/rc$control.d/" >> /home/$USER/testlog.txt
					fi
				fi
			#echo "/etc/rc.d/rc$n.d/S$STA$INITNAME" >> /home/$USER/testlog.txt
			done
		done
	else
		for k in $(seq 0 1 6); do
			if [ -e /etc/rc.d/rc$k.d/K$END$INITNAME ]; then
				echo "K$END$INITNAME found in /etc/rc.d/rc$k.d/" >> /home/$USER/testlog.txt
			else
				echo "K$END$INITNAME NOT FOUND!!! in /etc/rc.d/rc$ck.d/" >> /home/$USER/testlog.txt
			fi
		done
	fi
	#printf "%s \n" "$chkconfigSettings"
	#printf "\n"
done
