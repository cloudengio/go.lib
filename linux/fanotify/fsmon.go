// Copyright 2018 Cosmos Nicolaou. All rights reserved.
// Use of this source code is governed by the Apache-2.0
// license that can be found in the LICENSE file.

// +build ignore

package main

import (
	"flag"
	"fmt"
	"os"
	"os/signal"

	"github.com/cosnicolaou/go/fsmon/linux/fanotify"
)

var (
	root string
)

func init() {
	flag.StringVar(&root, "root", ".", "directory to monitor")
}

func main() {
	flag.Parse()

	sigch := make(chan os.Signal, 1)
	ch := make(chan fanotify.Event, 1000)

	eq, err := fanotify.NewQueue("fsmon", fanotify.FAN_CLASS_NOTIF, fanotify.O_RDONLY, ch)
	if err != nil {
		panic(fmt.Sprintf("New: %v", err))
	}

	eq.SetOptions(fanotify.EventOptions{IncludeFileDescriptor: true})
	go func() {
		sig := <-sigch
		fmt.Printf("signal: %v\n", sig)
		eq.Close()
	}()

	signal.Notify(sigch, os.Interrupt)

	err = eq.Mark(fanotify.FAN_MARK_ADD|fanotify.FAN_MARK_MOUNT, fanotify.FAN_OPEN|fanotify.FAN_ONDIR, root)
	if err != nil {
		panic(fmt.Sprintf("Mark: %v", err))
	}

	for event := range ch {
		fmt.Println(event)
		if err := eq.Respond(&event, true); err != nil {
			fmt.Fprintf(os.Stderr, "respns: %v\n", err)
		}
	}
}
