#!/bin/sh

# test usr host process
# a script to test network performance while sending files.
# measures and logs CPU, memory, time, and bandwidth while sending different
# files across to a specified host. (username@host/IP)

TIMESTAMP=$(date +%T%d%m)
ARGS=$#

if [ $ARGS -ne 2 ]
then
  echo "2 arguments required."
  exit $E_WRONGARGS
fi

# user and host to send files to
USR=$1
HOST=$2

NAME="$1@$2"

# create the logfile
mkdir ./$TIMESTAMP
touch ./$TIMESTAMP/band_log
LOG_BAND=./$TIMESTAMP/band_log

touch ./$TIMESTAMP/stats_log
LOG_STATS=./$TIMESTAMP/stats_log

echo "Running Basic SCP Tests"
echo "Running Basic SCP Tests" >> $LOG_STATS
echo "Running Basic SCP Tests" >> $LOG_BAND

# files to send
echo "Large file to send (>1GIG): "
read ISO

echo "Small file to send (KB): "
read SM

echo "Medium file to send (MB): "
read MED

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
nohup ifstat -t -T >> $LOG_BAND &

echo "\n\nSmall File Transfer - $(date +%T)\n\n" >> $LOG_STATS
scp $SM $NAME:./
echo "\n\nSmall File Transfer Finished - $(date +%T)\n\n" >> $LOG_STATS

echo "\n\nMedium File Transfer - $(date +%T)\n\n" >> $LOG_STATS
scp $MED $NAME:./
echo "\n\nMedium File Transfer Finished - $(date +%T)\n\n" >> $LOG_STATS

echo "\n\nLarge File Transfer - $(date +%T)\n\n" >> $LOG_STATS
scp $ISO $NAME:./
echo "\n\nLarge File Transfer Finished - $(date +%T)\n\n" >> $LOG_STATS

#make sure everything ends
kill $(pidof top)
kill $(pidof ifstat)

echo "Finished! Log is at: $LOG_STATS and $LOG_BAND"
