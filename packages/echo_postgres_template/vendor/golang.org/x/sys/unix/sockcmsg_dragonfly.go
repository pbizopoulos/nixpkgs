// Copyright 2019 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
package unix
// Round the length of a raw sockaddr up to align it properly.
func cmsgAlignOf(salen int) int {
	salign := SizeofPtr
	if SizeofPtr == 8 && !supportsABI(_dragonflyABIChangeVersion) {
		salign = 4
	}
	return (salen + salign - 1) & ^(salign - 1)
}
