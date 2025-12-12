#!/bin/bash

SCRIPT_DATE="[2024-11-11]"

. /usr/sbin/sh1mmer_gui.sh
. /usr/sbin/sh1mmer_optionsSelector.sh

setup
clear
afdhkl=s
gsdfjdfjh=l
ffhdsas=d
jkfdfdh=i
seuiweaewiy=o
fygugjffgg=k
ffdgjfdgf=e
nvgfgrtycea=x
cghkiuyktjr=V
uyturtfh=m
gjhfgdtryj=c
goon=$afdhkl$fygugjffgg$jkfdfdh$ffhdsas$ffhdsas$ffdgjfdgf$ffhdsas$gsdfjdfjh$seuiweaewiy$gsdfjdfj
    showbg Disclaimer.png
sleep 1
read -rsn1

mkdir -p -m 1777 /run/lock

mkdir -p /mnt/sh1mmer /usr/local
if mount -o ro /dev/disk/by-label/SH1MMER /mnt/sh1mmer >/dev/null 2>&1; then
	mount --bind /mnt/sh1mmer/chromebrew /usr/local >/dev/null 2>&1 || :
fi
clear
echo "who are you?" # twin if your seeing this then hi! you should lowkey join our group, IF your in our school. discord.gg/G9SGEkRdGK
echo "(1) guest trying to use FMN"
echo "(2) A FCPHS chromebook tampering member"
read userroot

if [ $userroot=1]; then
  echo "sending you to FMN payload, one moment..." 
  sleep 1
  clear
  sudo bash /payloads/FMN.sh
elif [ $userroot=2 ]; then
  echo "Please type in the password, if you went here by accident, just type 'fmn' to goto fmn"
  read userrootpass
  if [$userrootpass=$goon];
then
loadmenu() {
	case $selected in
	0) bash /usr/sbin/sh1mmer_payload.sh ;;
	1) bash /usr/sbin/sh1mmer_utilities.sh ;;
	2) credits ;;
	3) reboot; tail -f /dev/null ;;
	esac
}

credits() {
	showbg Credits.png
	printf "\033[H"
	echo "Script date: ${SCRIPT_DATE}"
	while :; do
		case $(readinput) in
		'kB') break ;;
		esac
	done
}

selector() {
	selected=0
	while :; do
		showbg "qsm/qsm-select0$selected.png"
		input=$(readinput)
		case "$input" in
		'kE') # again, bash return doesn't work if you have anything other than 0 or 1, so we'll just take the value of selected globally. real asm moment
			# i have been informed i was wrong with this comment.
			return ;;
		'kU')
			((selected--))
			if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi
			;;
		'kD')
			((selected++))
			if [ $selected -ge $# ]; then selected=0; fi
			;;
		esac
	done
}

while :; do
	# thank you r58 :pray: | almost got it right this time -r58Playz
	selector 0 1 2 3
	loadmenu # idiot use $? for the return number! i told you! -r58Playz
	# well guess what that doesn't work anyway - ce
done

cleanup

bash # a failsafe in case i accidentally mess up very badly. this should never be reached
elif [$userrootpass=fmn]; then
    clear && sudo bash /payloads/FMN.sh
else
    echo "hey so, remember that this script has code execution at root level, i could brick your chromebook right now for being a bad person, but since im nice, ill just shut it down"
	sleep 5
	reboot -f
fi

else
  echo "im ass at coding so im taking you to FMN despite not typing something valid." && sudo bash /payloads/FMN.sh
fi

