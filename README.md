# pat-on-a-pi
## Easy-mode setup of Pat Winlink client on a Raspberry Pi

This started off as a way to replicate my functioning Pat setup on a friend's identical station (Raspberry Pi 4, Pat, and an IC-705).

_(Disclaimer: These scripts come with no warranty, liability, or support. They'll most likely work for you on an up-to-date Raspberry Pi (has been tested on a 4 and a ZeroW) with an IC-705.)_

I'll try to add support for other radio models/sound cards soon.

### How to install:
Run the following in a terminal window on the Pi:

`curl https://raw.githubusercontent.com/CarpeNoctem/pat-on-a-pi/gpsd_test/setup_pat.sh > /tmp/setup_pat.sh; bash /tmp/setup_pat.sh`

This will install Pat and its prerequisites, a desktop icon, and a helper script for launching rig control and an ARDOP TNC when running Pat. It will also prompt you for your grid square and Winlink credentials to put into the Pat configuration. (In the future, it may ask you to select a rig and detect USB audio interface.)
