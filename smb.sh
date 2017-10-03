#!/bin/sh

# test usr host process
# a script to test network performance while sending files.
# measures and logs CPU, memory, and time while sending different files across
# to a specified host. (username@host/IP)

# also takes in the name of a process to monitor

TIMESTAMP=$(date +%T%d%m)
ARGS=$#

if [ $ARGS -ne 5 ]
then
  echo "5 arguments required."
  exit $E_WRONGARGS
fi

# user and share to access
USR=$1
SHARE=$2

# file to fetch
FILE=$3

# encryption?
ENC=$4

# smb3 flag?
SMB3=$5

# create the logfiles
mkdir ./$TIMESTAMP
touch ./$TIMESTAMP/band_log
LOG_BAND=./$TIMESTAMP/band_log

touch ./$TIMESTAMP/stats_log
LOG_STATS=./$TIMESTAMP/stats_log

# start the tests

# flags for future reference:
#  -i : ignore idle or zombie processes in top
#  -b : batch mode for better writing to file
#  -d : delay (set to 1 second right now)

# the upshot of -i is that if there is no significant CPU usage going on (as
# in small file copies, for instance), top will print no processes to the file.
# if, however, there is CPU activity (as in some medium and certainly all large
# file transfers, top will return those active processes.)
# had to change this implementation because of differences in VPN implementations.
# also i have no idea why but if i don't put "nohup" there it doesn't work correctly.
nohup top -i -b -d 1 >> $LOG_STATS &

# track bandwidth as well. this should capture all the interfaces, regardless of
# whether the VPN makes a new one.
# no idea if the same issues exist here as with top and nohup vs no nohup, but
# i am not taking any chances.
nohup ifstat -t -T 1 >> $LOG_BAND &

if [ $ENC -eq 1 ]
then
  if [ $SMB3 -eq 1 ]
  then
    smbclient $SHARE -U $USR -e -mSMB3 -c "get $FILE dummy.l"
  else
    smbclient $SHARE -U $USR -e -c "get $FILE dummy.l"
  fi
else
  smbclient $SHARE -U $USR -c "get $FILE dummy.l"
fi

#make sure everything ends
kill $(pidof top)
kill $(pidof ifstat)

echo Finished! Log is at: $LOG_STATS and $LOG_BAND
