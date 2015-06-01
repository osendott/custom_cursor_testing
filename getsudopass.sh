#!/bin/bash
usrPassword=$(dialog --backtitle "testomg" --passwordbox "Please enter sudo password..." 8 40 2>&1 >/dev/tty)

echo -e $usrPassword | sudo -S cp ~/Desktop/password.sh ~/Desktop/password2.sh
