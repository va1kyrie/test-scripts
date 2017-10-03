#!/bin/sh

# test usr host process
# a script to test network performance while sending files.
# measures and logs CPU, memory, and time while sending different files across
# to a specified host. (username@host/IP)

# also takes in the name of a process to monitor

TIMESTAMP=$(date +%T%d%m)
ARGS=$#

if [ $ARGS -lt 2 ]
then
  echo "At least 2 arguments required."
  exit $E_WRONGARGS
fi

# what processes are you watching
P_SCP="scp"
if [ $ARGS -eq 3 ]
then
  P_MON=$3
fi

# user and host to send files to
USR=$1
HOST=$2

NAME="$1@$2"

# create the logfile
#touch ./steps_log.$TIMESTAMP
#LOG_STEPS=./steps_log.$TIMESTAMP

touch ./stats_log.$TIMESTAMP
LOG_STATS=./stats_log.$TIMESTAMP

# files to send
echo "Large file to send (>1GIG): "
read ISO

echo "Small file to send (KB): "
read SM

echo "Medium file to send (MB): "
read MED

# start the tests
if [ $ARGS -eq 3 ]
then
  nohup top -p $(pidof $P_MON) -p $(pidof $P_SCP) -b -d 1 >> $LOG_STATS &
else
    nohup top -p$(pidof $P_SCP) -b -d 1 >> $LOG_STATS &
fi

echo "\n\nSmall File Transfer - $(date +%T)\n\n" >> $LOG_STATS
scp $SM $NAME:./
echo "\n\nSmall File Transfer Finished - $(date +%T)\n\n" >> $LOG_STATS

# start the tests again
kill $(pidof top)
if [ $ARGS -eq 3 ]
then
  nohup top -p $(pidof $P_MON) -p $(pidof $P_SCP) -b -d 1 >> $LOG_STATS &
else
  nohup top -p $(pidof $P_SCP) -b -d 1 >> $LOG_STATS &
fi

echo "\n\nMedium File Transfer - $(date +%T)\n\n" >> $LOG_STATS
scp $MED $NAME:./
echo "\n\nMedium File Transfer Finished - $(date +%T)\n\n" >> $LOG_STATS

# start the tests again
kill $(pidof top)
if [ $ARGS -eq 3 ]
then
  nohup top -p $(pidof $P_MON) -p $(pidof $P_SCP) -b -d 1 >> $LOG_STATS &
else
    nohup top -p$(pidof $P_SCP) -b -d 1 >> $LOG_STATS &
fi

echo "\n\nLarge File Transfer - $(date +%T)\n\n" >> $LOG_STATS
scp $ISO $NAME:./
echo "\n\nLarge File Transfer Finished - $(date +%T)\n\n" >> $LOG_STATS

#make sure top ends
kill $(pidof top)

echo Finished! Log is at: $LOG_STATS
