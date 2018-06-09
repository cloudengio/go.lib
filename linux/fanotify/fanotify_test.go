// Copyright 2018 Cosmos Nicolaou. All rights reserved.
// Use of this source code is governed by the Apache-2.0
// license that can be found in the LICENSE file.

// +build linux

package fanotify_test

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"runtime"
	"strings"
	"testing"

	"github.com/cosnicolaou/go/fsmon/linux/fanotify"
)

func fail(t *testing.T, depth int, err error) {
	if err != nil {
		_, file, line, _ := runtime.Caller(depth + 1)
		t.Fatalf("%v:%v: %v", filepath.Base(file), line, err)
	}
}

func TestSimple(t *testing.T) {
	if os.Geteuid() != 0 {
		t.Skipf("this test needs to be run as root")
		return
	}
	var err error
	assertSuccess := func() {
		fail(t, 1, err)
	}
	td, err := ioutil.TempDir("", "fanotify-")
	assertSuccess()
	defer os.RemoveAll(td)
	t.Logf("temp dir: %v\n", td)
	ch := make(chan fanotify.Event, 100)
	eq, err := fanotify.NewQueue("test", fanotify.FAN_CLASS_NOTIF, fanotify.O_RDONLY, ch)
	assertSuccess()
	eq.SetOptions(fanotify.EventOptions{ForwardSelfNotifications: true})
	events := fanotify.FAN_OPEN | fanotify.FAN_CLOSE
	err = eq.Mark(fanotify.FAN_MARK_ADD|fanotify.FAN_MARK_MOUNT, events, td)
	assertSuccess()

	tf := filepath.Join(td, "test")
	go func() {
		if err := ioutil.WriteFile(tf, []byte("hello"), 0666); err != nil {
			// t.Fatal doesn't like to be called from within a goroutine.
			panic(fmt.Sprintf("failed to write test file: %v", tf))
		}
	}()

	// This test will timeout if it never receives the appropriate event.
	for event := range ch {
		t.Logf("%v\n", event)
		if event.Path == tf {
			break
		}
	}
	eq.Close()
	event := <-ch
	if got, want := fanotify.IsTerminalError(event.Error), true; got != want {
		t.Errorf("got %v, want %v\n", got, want)
	}
	if got, want := event.Error.Error(), "event queue closed"; !strings.Contains(got, want) {
		t.Errorf("got %v, does not conta %v\n", got, want)
	}
}
