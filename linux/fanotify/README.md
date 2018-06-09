# fanotify - efficient file system monitoring

A golang API to [fanotify](http://man7.org/linux/man-pages/man7/fanotify.7.html) which allows for monitoring of entire file system mountpoints with a single
'mark' call. A simple monitoring example is provided that be run by:

```
$ sudo go run fsmon.go /
```

This illustrates using fanotify to observe filesystem access events for an entire
mounted filesystem. It also illustrates fanotify's inability to observe
events that affect directories (eg. unlink) that don't access the directory
using the filesystem. This is a known limitation of the current fanotify
implementation that will hopefully be rectified in the future.

The various CPP constants required for the go API are extracted from a linux
system using the script ```update-fanotify-linux-definitions.sh```.
