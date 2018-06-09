#!/bin/bash
# Copyright 2018 Cosmos Nicolaou. All rights reserved.
# Use of this source code is governed by the Apache-2.0
# license that can be found in the LICENSE file.

# NOTE - the version of bash needs to support assocatiave arrays.

package="$1"
output="$2"

# Read the definitions into a map
declare -A definitions

IFS_OLD=$IFS
IFS='	' # tab.
while read key value; do
  definitions[$key]=$value
done < linux-defines.txt
IFS=$IFS_OLD

gen_consts() {
	local type="$1"
	local prefix="$2"
	shift; shift
	[[ ! -z $type ]] && echo "type $type int"
	echo "const ("
  	for k in $*; do
		echo "	${prefix}${k} ${type} = ${definitions[$k]}"
	done
	echo ")"
	echo
}

gen_stringer() {
	local type="$1"
	local prefix="$2"
	shift; shift
	echo "func (s ${type}) String() string {"
	echo "buf := bytes.NewBuffer(make([]byte, 0, 128))"
  	for k in $*; do
  		echo "if (s & ${prefix}${k}) != 0 {"
		echo "	buf.WriteString(\"${prefix}${k},\")"
		echo "}"
	done
	echo "return strings.TrimSuffix(buf.String(), \",\")"
	echo "}"
	echo
}


INIT_DEFINES="FAN_CLASS_PRE_CONTENT
FAN_CLASS_CONTENT
FAN_CLASS_NOTIF
FAN_CLOEXEC
FAN_NONBLOCK
FAN_UNLIMITED_QUEUE
FAN_UNLIMITED_MARKS
"

EVENT_DEFINES="O_RDONLY
O_WRONLY
O_RDWR
O_CLOEXEC
O_APPEND
O_DSYNC
O_NOATIME
O_NONBLOCK
O_SYNC
"

MARK_DEFINES="FAN_MARK_ADD
FAN_MARK_REMOVE
FAN_MARK_FLUSH
FAN_MARK_DONT_FOLLOW
FAN_MARK_ONLYDIR
FAN_MARK_MOUNT
FAN_MARK_IGNORED_MASK
FAN_MARK_IGNORED_SURV_MODIFY
"

MASK_DEFINES="FAN_ACCESS
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
"

EVENT_MASK_DEFINES="FAN_ACCESS
FAN_OPEN
FAN_MODIFY
FAN_CLOSE_WRITE
FAN_CLOSE_NOWRITE
FAN_Q_OVERFLOW
FAN_ACCESS_PERM
FAN_OPEN_PERM
FAN_CLOSE
"

SYSCALL_DEFINES="SYS_fanotify_init
SYS_fanotify_mark
AT_FDCWD
FAN_NOFD
EPOLLIN
EPOLL_CTL_ADD
FAN_ALLOW
FAN_DENY
SizeofFanotifyResponse
SizeofFanotifyEventMetadata
"
(
cat <<!
// Copyright 2018 Cosmos Nicolaou. All rights reserved.
// Use of this source code is governed by the Apache-2.0
// license that can be found in the LICENSE file.


package $package

!
gen_consts FAN_GROUP_FLAGS "" $INIT_DEFINES
gen_consts FAN_EVENT_FLAGS "" $EVENT_DEFINES
gen_consts FAN_MARK_FLAGS "" $MARK_DEFINES
gen_consts FAN_MASK_FLAGS "" $MASK_DEFINES
gen_consts FAN_EVENT_MASK "EVENT_" $EVENT_MASK_DEFINES
gen_stringer FAN_EVENT_MASK "EVENT_" $EVENT_MASK_DEFINES
gen_consts "" "priv_" $SYSCALL_DEFINES
) | goimports > $output
