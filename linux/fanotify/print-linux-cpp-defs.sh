#!/bin/bash
# Copyright 2018 Cosmos Nicolaou. All rights reserved.
# Use of this source code is governed by the Apache-2.0
# license that can be found in the LICENSE file.

# Run this script on an appropriate linux system to get the values
# of the constants required.
values() {
	local headers="$1"
	local defines="$2"
	local format="$3"
	local file="$4"
 	shift; shift; shift; shift
local includes="#include <stdio.h>"
for h in $headers; do
	includes="$includes
#include <$h>"
done
local body=""
for d in $defines; do
	body="$body
printf(\"$d\t${format}\n\", $d);"
done
	cat > $file <<!
$includes

int main() {
$body

}
!
gcc -o generated $file $flags $* && ./generated && rm generated $file
}

structSizes() {
	local headers="$1"
	local structs="$2"
	local format="$3"
	local file="$4"
 	shift; shift; shift; shift
local includes="#include <stdio.h>"
for h in $headers; do
	includes="$includes
#include <$h>"
done
local body=""
for d in $structs; do
	cc=$(echo "sizeof_$d" | sed -r 's/(^|-|_)(\w)/\U\2/g')
	body="$body
printf(\"${cc}\t${format}\n\", sizeof(struct $d));"
done
	cat > $file <<!
$includes

int main() {
$body

}
!
gcc -o generated $file $flags $* && ./generated && rm generated $file
}


HEADERS="fcntl.h sys/fanotify.h"
DEFINES="
FAN_CLASS_PRE_CONTENT
FAN_CLASS_CONTENT
FAN_CLASS_NOTIF
FAN_CLOEXEC
FAN_NONBLOCK
FAN_UNLIMITED_QUEUE
FAN_UNLIMITED_MARKS
FAN_MARK_ADD
FAN_MARK_REMOVE
FAN_MARK_FLUSH
FAN_MARK_DONT_FOLLOW
FAN_MARK_ONLYDIR
FAN_MARK_MOUNT
FAN_MARK_IGNORED_MASK
FAN_MARK_IGNORED_SURV_MODIFY
FAN_ACCESS
FAN_MODIFY
FAN_CLOSE_WRITE
FAN_CLOSE_NOWRITE
FAN_OPEN
FAN_Q_OVERFLOW
FAN_OPEN_PERM
FAN_ACCESS_PERM
FAN_ONDIR
FAN_EVENT_ON_CHILD
FAN_CLOSE
FAN_NOFD
FAN_ALLOW
FAN_DENY
"


values "$HEADERS" "$DEFINES" '0x%.8x' fanotify.c -D=_GNU_SOURCE


HEADERS="sys/types.h sys/stat.h fcntl.h"
DEFINES="
O_RDONLY
O_WRONLY
O_RDWR
O_CLOEXEC
O_APPEND
O_DSYNC
O_NOATIME
O_NONBLOCK
O_SYNC
"

values "$HEADERS" "$DEFINES" '0x%.8x' open.c -D=_GNU_SOURCE


HEADERS="sys/epoll.h fcntl.h syscall.h"

DEFINES="SYS_fanotify_init SYS_fanotify_mark AT_FDCWD EPOLLIN EPOLL_CTL_ADD"

values "$HEADERS" "$DEFINES" '%d' syscalls.c -D=_GNU_SOURCE

HEADERS="sys/fanotify.h"

STRUCTS="
fanotify_response
fanotify_event_metadata
"

structSizes "$HEADERS" "$STRUCTS" "%ld" sizes.c -D=_GNU_SOURCE

