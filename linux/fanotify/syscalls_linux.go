// Copyright 2018 Cosmos Nicolaou. All rights reserved.
// Use of this source code is governed by the Apache-2.0
// license that can be found in the LICENSE file.

package fanotify

import (
	"syscall"
	"unsafe"
)

func fanotify_init(groupFlags FAN_GROUP_FLAGS, eventFlags FAN_EVENT_FLAGS) (int, syscall.Errno) {
	fd, _, errno := syscall.Syscall(priv_SYS_fanotify_init,
		uintptr(groupFlags), uintptr(eventFlags), uintptr(0))
	return int(fd), errno
}

func fanotify_mark(fd int, markFlags FAN_MARK_FLAGS, mask FAN_MASK_FLAGS, dirFD int, path string) syscall.Errno {
	_, _, errno := syscall.Syscall6(priv_SYS_fanotify_mark,
		uintptr(fd),
		uintptr(markFlags),
		uintptr(mask),
		uintptr(dirFD),
		uintptr(unsafe.Pointer(syscall.StringBytePtr(path))), 0)
	return errno
}
