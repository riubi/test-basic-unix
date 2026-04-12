#!/bin/bash
set -euo pipefail

export HISTFILE=/root/.hw_history
export HISTSIZE=500
set +o history
history -c

STUD="M2551076"
PROJ="/dir-$STUD"

do_cmd() {
	history -s "$1"
	eval "$1"
}

do_cmd 'groupadd -g 5500 team'
do_cmd 'groupadd -g 4444 curators'
do_cmd 'useradd -m -u 5501 -g team user1'
do_cmd 'useradd -m -u 5502 -g team user2'
do_cmd 'useradd -m -u 5503 -g team user3'
do_cmd 'useradd -m -G curators curator1'
do_cmd 'useradd -m -G curators curator2'
do_cmd "mkdir $PROJ"
do_cmd "chown root:team $PROJ"
do_cmd "chmod 2770 $PROJ"
do_cmd "setfacl -m g:curators:rx,o::--- $PROJ"
do_cmd "setfacl -d -m g::rwx,g:curators:r-x,o::--- $PROJ"

OUT=/root/report.txt
{
	history
	printf '\n'
	cat /etc/passwd

	printf '\n'
	cat /etc/group

	printf '\n%s\n' 'проверка:'
	su - user1 -c "echo u1 > $PROJ/t1.txt"
	su - user2 -c "echo u2 >> $PROJ/t1.txt"
	su - user2 -c "mkdir $PROJ/sub && echo nested > $PROJ/sub/f"
	if su - curator1 -c "cat $PROJ/t1.txt" >/dev/null; then echo curator1 read ok; else echo curator1 read FAIL; exit 1; fi
	if su - curator1 -c "echo x >> $PROJ/t1.txt" 2>/dev/null; then echo curator write FAIL; exit 1; else echo curator write blocked ok; fi
	if su - curator1 -c "cat $PROJ/sub/f" >/dev/null; then echo curator sub read ok; else echo curator sub FAIL; exit 1; fi
	if su -s /bin/sh nobody -c "ls $PROJ" 2>/dev/null; then echo other access FAIL; exit 1; else echo other blocked ok; fi
} > "$OUT"
