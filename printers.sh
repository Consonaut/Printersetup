#!/bin/sh
#
# Author: Constantin Heine <it@staedelschule.de> 2018
# Download the install script and chmod +x it, cause I'm dumb
#

DL_path="https://FILEHOST/student_printers.sh"

set -eu
printf "Downloading the setup script. This will only work if your account has admin rights...\n"
curl -sO $DL_path
chmod +x student_printers.sh
printf "Enter your password:\n"
sudo ./student_printers.sh
