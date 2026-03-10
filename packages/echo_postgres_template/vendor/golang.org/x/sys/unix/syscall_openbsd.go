// Copyright 2009,2010 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
// OpenBSD system calls.
// This file is compiled as ordinary Go code,
// but it is also input to mksyscall,
// which parses the //sys lines and generates system call stubs.
// Note that sometimes we use a lowercase //sys name and wrap
// it in our own nicer implementation, either here or in
// syscall_bsd.go or syscall_unix.go.
package unix
import (
	"sort"
	"syscall"
	"unsafe"
)
// SockaddrDatalink implements the Sockaddr interface for AF_LINK type sockets.
type SockaddrDatalink struct {
	Len    uint8
	Family uint8
	Index  uint16
	Type   uint8
	Nlen   uint8
	Alen   uint8
	Slen   uint8
	Data   [24]int8
	raw    RawSockaddrDatalink
}
func anyToSockaddrGOOS(fd int, rsa *RawSockaddrAny) (Sockaddr, error) {
	return nil, EAFNOSUPPORT
}
func Syscall9(trap, a1, a2, a3, a4, a5, a6, a7, a8, a9 uintptr) (r1, r2 uintptr, err syscall.Errno)
func nametomib(name string) (mib []_C_int, err error) {
	i := sort.Search(len(sysctlMib), func(i int) bool {
		return sysctlMib[i].ctlname >= name
	})
	if i < len(sysctlMib) && sysctlMib[i].ctlname == name {
		return sysctlMib[i].ctloid, nil
	}
	return nil, EINVAL
}
func direntIno(buf []byte) (uint64, bool) {
	return readInt(buf, unsafe.Offsetof(Dirent{}.Fileno), unsafe.Sizeof(Dirent{}.Fileno))
}
func direntReclen(buf []byte) (uint64, bool) {
	return readInt(buf, unsafe.Offsetof(Dirent{}.Reclen), unsafe.Sizeof(Dirent{}.Reclen))
}
func direntNamlen(buf []byte) (uint64, bool) {
	return readInt(buf, unsafe.Offsetof(Dirent{}.Namlen), unsafe.Sizeof(Dirent{}.Namlen))
}
func SysctlUvmexp(name string) (*Uvmexp, error) {
	mib, err := sysctlmib(name)
	if err != nil {
		return nil, err
	}
	n := uintptr(SizeofUvmexp)
	var u Uvmexp
	if err := sysctl(mib, (*byte)(unsafe.Pointer(&u)), &n, nil, 0); err != nil {
		return nil, err
	}
	if n != SizeofUvmexp {
		return nil, EIO
	}
	return &u, nil
}
func Pipe(p []int) (err error) {
	return Pipe2(p, 0)
}
//sysnb	pipe2(p *[2]_C_int, flags int) (err error)
func Pipe2(p []int, flags int) error {
	if len(p) != 2 {
		return EINVAL
	}
	var pp [2]_C_int
	err := pipe2(&pp, flags)
	if err == nil {
		p[0] = int(pp[0])
		p[1] = int(pp[1])
	}
	return err
}
//sys	Getdents(fd int, buf []byte) (n int, err error)
func Getdirentries(fd int, buf []byte, basep *uintptr) (n int, err error) {
	n, err = Getdents(fd, buf)
	if err != nil || basep == nil {
		return
	}
	var off int64
	off, err = Seek(fd, 0, 1 )
	if err != nil {
		*basep = ^uintptr(0)
		return
	}
	*basep = uintptr(off)
	if unsafe.Sizeof(*basep) == 8 {
		return
	}
	if off>>32 != 0 {
		err = EIO
	}
	return
}
//sys	Getcwd(buf []byte) (n int, err error) = SYS___GETCWD
func Sendfile(outfd int, infd int, offset *int64, count int) (written int, err error) {
	if raceenabled {
		raceReleaseMerge(unsafe.Pointer(&ioSync))
	}
	return sendfile(outfd, infd, offset, count)
}
// TODO
func sendfile(outfd int, infd int, offset *int64, count int) (written int, err error) {
	return -1, ENOSYS
}
func Getfsstat(buf []Statfs_t, flags int) (n int, err error) {
	var bufptr *Statfs_t
	var bufsize uintptr
	if len(buf) > 0 {
		bufptr = &buf[0]
		bufsize = unsafe.Sizeof(Statfs_t{}) * uintptr(len(buf))
	}
	return getfsstat(bufptr, bufsize, flags)
}
//sysnb	getresuid(ruid *_C_int, euid *_C_int, suid *_C_int)
//sysnb	getresgid(rgid *_C_int, egid *_C_int, sgid *_C_int)
func Getresuid() (ruid, euid, suid int) {
	var r, e, s _C_int
	getresuid(&r, &e, &s)
	return int(r), int(e), int(s)
}
func Getresgid() (rgid, egid, sgid int) {
	var r, e, s _C_int
	getresgid(&r, &e, &s)
	return int(r), int(e), int(s)
}
//sys	ioctl(fd int, req uint, arg uintptr) (err error)
//sys	ioctlPtr(fd int, req uint, arg unsafe.Pointer) (err error) = SYS_IOCTL
//sys	sysctl(mib []_C_int, old *byte, oldlen *uintptr, new *byte, newlen uintptr) (err error) = SYS___SYSCTL
//sys	fcntl(fd int, cmd int, arg int) (n int, err error)
//sys	fcntlPtr(fd int, cmd int, arg unsafe.Pointer) (n int, err error) = SYS_FCNTL
// FcntlInt performs a fcntl syscall on fd with the provided command and argument.
func FcntlInt(fd uintptr, cmd, arg int) (int, error) {
	return fcntl(int(fd), cmd, arg)
}
// FcntlFlock performs a fcntl syscall for the F_GETLK, F_SETLK or F_SETLKW command.
func FcntlFlock(fd uintptr, cmd int, lk *Flock_t) error {
	_, err := fcntlPtr(int(fd), cmd, unsafe.Pointer(lk))
	return err
}
//sys	ppoll(fds *PollFd, nfds int, timeout *Timespec, sigmask *Sigset_t) (n int, err error)
func Ppoll(fds []PollFd, timeout *Timespec, sigmask *Sigset_t) (n int, err error) {
	if len(fds) == 0 {
		return ppoll(nil, 0, timeout, sigmask)
	}
	return ppoll(&fds[0], len(fds), timeout, sigmask)
}
func Uname(uname *Utsname) error {
	mib := []_C_int{CTL_KERN, KERN_OSTYPE}
	n := unsafe.Sizeof(uname.Sysname)
	if err := sysctl(mib, &uname.Sysname[0], &n, nil, 0); err != nil {
		return err
	}
	mib = []_C_int{CTL_KERN, KERN_HOSTNAME}
	n = unsafe.Sizeof(uname.Nodename)
	if err := sysctl(mib, &uname.Nodename[0], &n, nil, 0); err != nil {
		return err
	}
	mib = []_C_int{CTL_KERN, KERN_OSRELEASE}
	n = unsafe.Sizeof(uname.Release)
	if err := sysctl(mib, &uname.Release[0], &n, nil, 0); err != nil {
		return err
	}
	mib = []_C_int{CTL_KERN, KERN_VERSION}
	n = unsafe.Sizeof(uname.Version)
	if err := sysctl(mib, &uname.Version[0], &n, nil, 0); err != nil {
		return err
	}
	for i, b := range uname.Version {
		if b == '\n' || b == '\t' {
			if i == len(uname.Version)-1 {
				uname.Version[i] = 0
			} else {
				uname.Version[i] = ' '
			}
		}
	}
	mib = []_C_int{CTL_HW, HW_MACHINE}
	n = unsafe.Sizeof(uname.Machine)
	if err := sysctl(mib, &uname.Machine[0], &n, nil, 0); err != nil {
		return err
	}
	return nil
}
