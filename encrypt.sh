#!/bin/sh

# automate encryption testing of files

# takes in an openssl encryption command, a file, and a number of times to run.

# logs everything, of course.

TIMESTAMP=$(date +%T%d%m)
ARGS=$#

if [ $ARGS -ne 3 ]
then
  echo "3 arguments required."
  exit $E_WRONGARGS
fi

ENC=$1
FILE=$2
REPS=$3

E_FILE="$FILE.enc"

# create the logfile
touch ./stats_log.$TIMESTAMP
LOG_STATS=./stats_log.$TIMESTAMP

echo "Running Encryption Tests with $ENC"
echo "Running Encryption Tests with $ENC\n\n" >> $LOG_STATS

# starting tests

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

# for small files change the delay to .1
# by small, i mean MB large, not GB large. (the 74MB dummy file needs .1, for instance)
nohup top -i -b -d 1 >> $LOG_STATS &

for COUNT in `seq $REPS`
do
  echo "$COUNT test of encryption - $(date +%T)\n\n" >> $LOG_STATS
  openssl $ENC -a -in $FILE -out $E_FILE
  echo "\n\n$COUNT test finished - $(date +%T)\n\n" >> $LOG_STATS
  rm $E_FILE
done

# make sure everything finishes
kill $(pidof top)

echo "Finished! Log is at $LOG_STATS"
