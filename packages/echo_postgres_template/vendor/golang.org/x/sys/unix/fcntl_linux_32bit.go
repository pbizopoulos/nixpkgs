// Copyright 2014 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//go:build (linux && 386) || (linux && arm) || (linux && mips) || (linux && mipsle) || (linux && ppc)
package unix
func init() {
	fcntl64Syscall = SYS_FCNTL64
}
