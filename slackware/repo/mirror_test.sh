#!/bin/bash

# mirror_test.sh
# Originally written for Ubuntu by Lance Rushing <lance_rushing@hotmail.com>
# Dated 9/1/2006
# Taken from http://ubuntuforums.org/showthread.php?t=251398
# This script is covered under the GNU Public License: http://www.gnu.org/licenses/gpl.txt

# Modified for Slackware by Jeremy Brent Hansen <jebrhansen -at- gmail.com>
# Modified 2015/11/06

# Modified 2016/05/13 by Jose Bovet Derpich jose.bovet@gmail.com

#----------------------------------------------------------------
# Slackware64-current
#----------------------------------------------------------------
# Add or change mirrors from /etc/slackpkg/mirrors as desired (these are the US mirrors)
MIRRORS="https://slackware.zero.com.ar/slackware/slackware64-current/
https://slackware.mirror.digitalpacific.com.au/slackware64-current/
https://syd.mirror.rackspace.com/slackware/slackware64-current/
https://mirror.telepoint.bg/slackware/slackware64-current/
https://mirrors.linux-bulgaria.org/slackware/slackware64-current/
https://mirrors.netix.net/slackware/slackware64-current/
https://ftp.slackware-brasil.com.br/slackware64-current/
https://linorg.usp.br/slackware/slackware64-current/
https://mirrors.slackware.devl.club/slackware64-current/
https://slackjeff.com.br/slackware/slackware64-current/
https://mirror.csclub.uwaterloo.ca/slackware/slackware64-current/
https://mirror.its.dal.ca/slackware/slackware64-current/
https://mirrors.bfsu.edu.cn/slackware/slackware64-current/
https://mirrors.ucr.ac.cr/slackware/slackware64-current/
https://ftp6.gwdg.de/pub/linux/slackware/slackware64-current/
https://linux.rz.rub.de/slackware/slackware64-current/
https://mirror.de.leaseweb.net/slackware/slackware64-current/
https://mirror.netcologne.de/slackware/slackware64-current/
https://mirrors.dotsrc.org/slackware/slackware64-current/
https://mirror.cedia.org.ec/slackware/slackware64-current/
https://lon.mirror.rackspace.com/slackware/slackware64-current/
https://mirror.bytemark.co.uk/slackware/slackware64-current/
https://www.mirrorservice.org/sites/ftp.slackware.com/pub/slackware/slackware64-current/
https://ftp.cc.uoc.gr/mirrors/linux/slackware/slackware64-current/
https://hkg.mirror.rackspace.com/slackware/slackware64-current/
https://mirror-hk.koddos.net/slackware/slackware64-current/
https://quantum-mirror.hu/mirrors/pub/slackware/slackware64-current/
https://iso.ukdw.ac.id/slackware/slackware64-current/
https://repo.ukdw.ac.id/slackware/slackware64-current/
https://slackware.mirror.garr.it/slackware/slackware64-current/
https://mirror.slackware.jp/slackware/slackware64-current/
https://repo.jing.rocks/slackware/slackware64-current/
https://mirrors.atviras.lt/slackware/slackware64-current/
https://mirrors.qontinuum.space/slackware/slackware64-current/
https://mirror.ihost.md/slackware/slackware64-current/
https://mirror.lagoon.nc/slackware/slackware64-current/
https://ftp.nluug.nl/os/Linux/distr/slackware/slackware64-current/
https://mirror.koddos.net/slackware/slackware64-current/
https://mirror.nl.leaseweb.net/slackware/slackware64-current/
https://ftp.slackware.pl/pub/slackware/slackware64-current/
https://sunsite.icm.edu.pl/pub/Linux/slackware/slackware64-current/
https://ftp.rnl.tecnico.ulisboa.pt/pub/slackware/slackware64-current/
https://mirrors.nxthost.com/slackware/slackware64-current/
https://mirror1.sox.rs/slackware/slackware64-current/
https://mirror.tspu.edu.ru/slackware/slackware64-current/
https://mirror.yandex.ru/slackware/slackware64-current/
https://mirror.lyrahosting.com/slackware/slackware64-current/
https://ftp.acc.umu.se/mirror/slackware.com/slackware64-current/
https://ftpmirror.infania.net/slackware/slackware64-current/
https://mirror.wheel.sk/slackware/slackware64-current/
https://ifconfig.com.ua/slackware/slackware64-current/
https://dfw.mirror.rackspace.com/slackware/slackware64-current/
https://ftp.ussg.indiana.edu/linux/slackware/slackware64-current/
https://mirror.cs.princeton.edu/pub/mirrors/slackware/slackware64-current/
https://mirror.fcix.net/slackware/slackware64-current/
https://mirror.slackbuilds.org/slackware/slackware64-current/
https://mirror2.sandyriver.net/pub/slackware/slackware64-current/
https://mirrors.kernel.org/slackware/slackware64-current/
https://mirrors.ocf.berkeley.edu/slackware/slackware64-current/
https://mirrors.syringanetworks.net/slackware/slackware64-current/
https://mirrors.xmission.com/slackware/slackware64-current/
https://plug-mirror.rcac.purdue.edu/slackware/slackware64-current/"

# Use any adequetly sized file to test the speed. This is ~7MB.
# The location should be based on the relative location within
# the slackware64-current tree. I originally tried a smaller 
# file (FILELIST.TXT ~1MB), but I was seeing slower speed results
# since it didn't have time to fully max my connection. Depending
# on your internet speed, you may want to try different sized files.
FILE="kernels/huge.s/bzImage"

# Number of seconds before the test is considered a failure
TIMEOUT="5"

# String to store results in
RESULTS=""

# Set color variables to make results and echo statements cleaner
RED="\e[31m"
GREEN="\e[32m"
NC="\e[0m"  #No color

for MIRROR in $MIRRORS ; do
    
    echo -n "Testing ${MIRROR} "    
    URL="${MIRROR}${FILE}"
    SPEED=$(curl --max-time $TIMEOUT --silent --output /dev/null --write-out %{speed_download} $URL)

    if (( $(echo "$SPEED < 10000.000" | bc -l) )) ; then
        echo -e "${RED}Fail${NC}";
    else 
        SPEED="$(numfmt --to=iec-i --suffix=B --padding=7 $SPEED)ps"
        echo -e "${GREEN}$SPEED${NC}"
        RESULTS="${RESULTS}\t${SPEED}\t${MIRROR}\n";
    fi

done;
echo -e "\nResults:"
echo -e $RESULTS | sort -hr  

