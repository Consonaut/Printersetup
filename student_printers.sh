#!/bin/sh
#
# Author: Constantin Heine <it@staedelschule.de> 2018
# Download necessary printer files and setup printers
#

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

D1_link="https://FILEHOST/canon_ps3.tar.gz"
D1_filename="canon_ps3.tar.gz"
D2_link="https://FILEHOST/canon_cupsps2.tar.gz"
D2_filename="canon_cupsps2.tar.gz"
D3_link="https://FILEHOST/CNMCIRAC3325S2.ppd.gz"
D3_filename="CNMCIRAC3325S2.ppd.gz"

P1_link="https://FILEHOST/Printshop.ppd"
P1_filename="Printshop.ppd"
P1_name="Printshop"
P1_location="Printshop"
P1_queue="lpd://PRINTER_IP/QUEUENAME"
P1_options="-o printer-is-shared=false -o EFFinisher=Booklet -o EFPaperDeckOpt=Option3 -o EFDestination=Mailbox"

P2_link="https://FILEHOST/Computerpool.ppd"
P2_filename="Computerpool.ppd"
P2_name="Computerpool"
P2_location="Computerpool"
P2_queue="lpd://PRINTER_IP/QUEUENAME"
P2_options="-o printer-is-shared=false -o CNJobExecMode=store -o CNDuplex=None -o CNColorMode=mono -o ColorModel=Gray"

P3_link="https://FILEHOST/Bibliothek.ppd"
P3_filename="Library.ppd"
P3_name="Library"
P3_location="Library"
P3_queue="lpd://PRINTER_IP/QUEUENAME"
P3_options="-o printer-is-shared=false -o CNJobExecMode=store -o CNDuplex=None -o CNColorMode=mono -o ColorModel=Gray"

PPDS_link="https://FILEHOST/ppds.tar.gz"
PPDS_filename="ppds.tar.gz"

set -u
if [[ $(id -u) -ne 0 ]] ; then
    echo "${RED}Please run as root or with 'sudo ./student_printers.sh'"
    exit 1
else
    printf "${NC}Creating temp directory at /tmp/printsetup......... "
    mkdir -p /tmp/printsetup || exit 3
    if [ $? = 3 ] ; then
        printf "[${RED}ERROR${NC}]\n"
        exit 1
    else
        printf "[${GREEN}OK${NC}]\n"
    fi
    printf "${NC}Downloading files for printer $P1_name............ "
    curl -sSo /tmp/printsetup/$D1_filename $D1_link &> /tmp/printsetup/install.log
    tar -xzf /tmp/printsetup/$D1_filename -C /Library/Printers/ &> /tmp/printsetup/install.log
    if [ $? != 0 ] ; then
        printf "[${RED}ERROR${NC}]\n"
        printf "Failed to download or unpack $D1_filename. Aborting.\n"
        exit 1
    fi
    curl -so /tmp/printsetup/$PPDS_filename $PPDS_link &> /tmp/printsetup/install.log
    tar -xzf /tmp/printsetup/$PPDS_filename -C /Library/Printers/ &> /tmp/printsetup/install.log
    if [ $? != 0 ] ; then
        printf "[${RED}ERROR${NC}]\n"
        printf "Failed to download or unpack $PPDS_filename. Aborting.\n"
        exit 1
    fi
    curl -so /tmp/printsetup/$P1_filename $P1_link &> /tmp/printsetup/install.log
    printf "[${GREEN}OK${NC}]\n"
    printf "${NC}Adding printer $P1_name........................... "
    lpadmin -p $P1_name -L $P1_location -E -v $P1_queue -P /tmp/printsetup/$P1_filename $P1_options  &> /tmp/printsetup/install.log || exit 3
    if [ $? = 3 ] ; then
        printf "[${RED}ERROR${NC}]\n"
        printf "Failed to add printer $P1_name. Aborting.\n"
        exit 1
    else
        printf "[${GREEN}OK${NC}]\n"
    fi
    printf "${NC}Downloading files for printer $P2_name......... "
    curl -so /tmp/printsetup/$D2_filename $D2_link &> /tmp/printsetup/install.log
    tar -xzf /tmp/printsetup/$D2_filename -C /Library/Printers/ &> /tmp/printsetup/install.log
    if [ $? != 0 ] ; then
        printf "[${RED}ERROR${NC}]\n"
        printf "Failed to download or unpack $D2_filename. Aborting.\n"
        exit 1
    fi
    curl -so /tmp/printsetup/$D3_filename $D3_link &> /tmp/printsetup/install.log
    cp /tmp/printsetup/$D3_filename /Library/Printers/PPDs/
    if [ $? != 0 ] ; then
        printf "[${RED}ERROR${NC}]\n"
        printf "Failed to download or copy $D3_filename. Aborting.\n"
        exit 1
    fi
    curl -so /tmp/printsetup/$P2_filename $P2_link &> /tmp/printsetup/install.log
    printf "[${GREEN}OK${NC}]\n"
    printf "${NC}Adding printer $P2_name........................ "
    lpadmin -p $P2_name -L $P2_location -E -v $P2_queue -P "/tmp/printsetup/$P2_filename" $P2_options &> /tmp/printsetup/install.log || exit 3
    if [ $? = 3 ] ; then
        printf "[${RED}ERROR${NC}]\n"
        printf "Failed to add printer $P2_name. Aborting.\n"
        exit 1
    fi
    curl -so /tmp/printsetup/$P3_filename $P3_link &> /tmp/printsetup/install.log
    printf "[${GREEN}OK${NC}]\n"
    printf "${NC}Adding printer $P3_name................ "
    lpadmin -p $P3_name -L $P3_location -E -v $P3_queue -P "/tmp/printsetup/$P3_filename" $P3_options &> /tmp/printsetup/install.log || exit 3
    if [ $? = 3 ] ; then
        printf "[${RED}ERROR${NC}]\n"
        printf "Failed to add printer $P3_name. Aborting.\n"
        exit 1
    else
        printf "[${GREEN}OK${NC}]\n"
    fi
    printf "${NC}Cleaning up........................................ "
    rm -rf /tmp/printsetup/ &> /tmp/printsetup/install.log || exit 3
    if [ $? = 3 ] ; then
        printf "[${RED}ERROR${NC}]\n"
        printf "Failed to delete temporary files at /tmp/printsetup/. Check log file for errors.\n"
        exit 1
    else
        printf "[${GREEN}OK${NC}]\n"
    fi
    rm student_printers.sh || exit 3
    printf "${NC}Done.\n"
fi
