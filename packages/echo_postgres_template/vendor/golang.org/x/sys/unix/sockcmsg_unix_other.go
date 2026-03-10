// Copyright 2019 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//go:build aix || darwin || freebsd || linux || netbsd || openbsd || solaris || zos
package unix
import (
	"runtime"
)
// Round the length of a raw sockaddr up to align it properly.
func cmsgAlignOf(salen int) int {
	salign := SizeofPtr
	switch runtime.GOOS {
	case "aix":
		salign = 1
	case "darwin", "ios", "illumos", "solaris":
		// NOTE: It seems like 64-bit Darwin, Illumos and Solaris
		if SizeofPtr == 8 {
			salign = 4
		}
	case "netbsd", "openbsd":
		if runtime.GOARCH == "arm" {
			salign = 8
		}
		if runtime.GOOS == "netbsd" && runtime.GOARCH == "arm64" {
			salign = 16
		}
	case "zos":
		salign = SizeofInt
	}
	return (salen + salign - 1) & ^(salign - 1)
}
