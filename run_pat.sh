#!/bin/bash

# Starts up rigctld, then Ardopc, then Pat.
# Make sure before running that you don't have anything else running (e.g. js8call) that is using your tranceiver.

# Drive level into rig. Adjust if neccessary to get the ALC meter on your rig at around 30%.
OUTPUT_VOL='59%'

RIG='373' # IC-7300 (& IC-705, but change the CI-V address in your 705 to 94.
# run `rigctl -l` to find a list of other radio models and swap the 373 here with that number.
# Note that this script was writtin for and currently only supports the IC-705.
# You'll need to additionally update your Ardop config and also your ~/.wl2k/config.json file to use a different rig.

BAUD=9600

echo 'Initiating connection with rig...';
rigctl -m ${RIG} -r /dev/ttyACM0 -s ${BAUD} f >/dev/null 2>&1
if [ "$?" -ne "0" ]; then
  echo 'Could not initiate connection with rig on /dev/ttyACM0. Quitting.';
  exit;
fi
rigctld -m ${RIG} -r /dev/ttyACM0 -s ${BAUD} > /tmp/rigctl.log &
sleep 1;

echo 'Initiating Ardop TNC...';
AUDIOCARD=$(aplay -l |grep 'USB Audio CODEC' |grep -o 'card [0-9]*')
if [ "$(echo ${AUDIOCARD} |wc -l)" -lt "1" ]; then
  echo 'Problem detecting USB audio card. Is the device plugged in?';
  echo 'Exiting.';
  exit
fi
CARDNUM=$(echo ${AUDIOCARD} |cut -d' ' -f2)
echo 'Setting appropriate output volume level. If you find this is not driving your rig at the';
echo 'right level (should be about 30% on your rigs ALC meter) use alsamixer to adjust accordingly.';
echo 'You can also edit the OUTPUT_VOL variable at the top of this script for future runs.';
amixer -c ${CARDNUM} set PCM ${OUTPUT_VOL} > /dev/null
ardopc > /tmp/ardopc.log &
sleep 1;

echo;
uimode=1
if [ "$#" -lt "1" ]; then
  echo 'Start Pat with web GUI or interactive text mode?';
  echo '1) Web GUI (port 8080) [default]';
  echo '2) Command line interface';
  echo '3) Quit and clean up';
  read -p '#? ' uimode;
else
  if [ "$1" == "cli" ]; then
    echo 'Launching Pat in CLI mode.';
    uimode=2
  else
    echo 'Launching Pat web GUI...';
  fi
fi

if [ "${uimode}" -eq "2" ]; then
  pat interactive;
elif [ "${uimode}" -eq "3" ]; then
  echo -n 'Okay. ';
else
  pat http > /tmp/pat.log &
  #pat http -a 0.0.0.0:8080 & #comment out the above line and uncomment this if you want to expose pat to the rest of the network. INSECURE!
  #sensible-browser --user-data-dir='/tmp/pat-web-browser' --app='http://127.0.0.1:8080'; #really, the --user-data-dir is a chromium-browser flag...
  sensible-browser --app='http://localhost:8080' > /dev/null 2>&1 &
  echo;
  echo "Pat web GUI has launched. If you don't see it, it may have opened in an existing browser window.";
  echo 'When finished, hit Enter or close this terminal window.';
  read k;
fi

echo 'Cleaning up...';
#rm -rf /tmp/pat-web-browser;
killall pat;
killall ardopc;
killall rigctld;
rigctl -m ${RIG} -r /dev/ttyACM0 -s ${BAUD} T 0 #ensure we stop TX if it got stuck

