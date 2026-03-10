// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: © 2015 LabStack LLC and Echo contributors
package echo
import (
	"fmt"
	"io/fs"
	"net/http"
	"net/url"
	"os"
	"path/filepath"
	"strings"
)
type filesystem struct {
	// prefix for directory path. This is necessary as `//go:embed assets/images` embeds files with paths
	Filesystem fs.FS
}
func createFilesystem() filesystem {
	return filesystem{
		Filesystem: newDefaultFS(),
	}
}
// Static registers a new route with path prefix to serve static files from the provided root directory.
func (e *Echo) Static(pathPrefix, fsRoot string) *Route {
	subFs := MustSubFS(e.Filesystem, fsRoot)
	return e.Add(
		http.MethodGet,
		pathPrefix+"*",
		StaticDirectoryHandler(subFs, false),
	)
}
// StaticFS registers a new route with path prefix to serve static files from the provided file system.
//
// When dealing with `embed.FS` use `fs := echo.MustSubFS(fs, "rootDirectory") to create sub fs which uses necessary
// prefix for directory path. This is necessary as `//go:embed assets/images` embeds files with paths
// including `assets/images` as their prefix.
func (e *Echo) StaticFS(pathPrefix string, filesystem fs.FS) *Route {
	return e.Add(
		http.MethodGet,
		pathPrefix+"*",
		StaticDirectoryHandler(filesystem, false),
	)
}
// StaticDirectoryHandler creates handler function to serve files from provided file system
// When disablePathUnescaping is set then file name from path is not unescaped and is served as is.
func StaticDirectoryHandler(fileSystem fs.FS, disablePathUnescaping bool) HandlerFunc {
	return func(c Context) error {
		p := c.Param("*")
		if !disablePathUnescaping { 
			tmpPath, err := url.PathUnescape(p)
			if err != nil {
				return fmt.Errorf("failed to unescape path variable: %w", err)
			}
			p = tmpPath
		}
		name := filepath.ToSlash(filepath.Clean(strings.TrimPrefix(p, "/")))
		fi, err := fs.Stat(fileSystem, name)
		if err != nil {
			return ErrNotFound
		}
		p = c.Request().URL.Path 
		if fi.IsDir() && len(p) > 0 && p[len(p)-1] != '/' {
			return c.Redirect(http.StatusMovedPermanently, sanitizeURI(p+"/"))
		}
		return fsFile(c, name, fileSystem)
	}
}
// FileFS registers a new route with path to serve file from the provided file system.
func (e *Echo) FileFS(path, file string, filesystem fs.FS, m ...MiddlewareFunc) *Route {
	return e.GET(path, StaticFileHandler(file, filesystem), m...)
}
// StaticFileHandler creates handler function to serve file from provided file system
func StaticFileHandler(file string, filesystem fs.FS) HandlerFunc {
	return func(c Context) error {
		return fsFile(c, file, filesystem)
	}
}
// defaultFS exists to preserve pre v4.7.0 behaviour where files were open by `os.Open`.
// v4.7 introduced `echo.Filesystem` field which is Go1.16+ `fs.Fs` interface.
// Difference between `os.Open` and `fs.Open` is that FS does not allow opening path that start with `.`, `..` or `/`
// etc. For example previously you could have `../images` in your application but `fs := os.DirFS("./")` would not
// allow you to use `fs.Open("../images")` and this would break all old applications that rely on being able to
// traverse up from current executable run path.
// NB: private because you really should use fs.FS implementation instances
type defaultFS struct {
	fs     fs.FS
	prefix string
}
func newDefaultFS() *defaultFS {
	dir, _ := os.Getwd()
	return &defaultFS{
		prefix: dir,
		fs:     nil,
	}
}
func (fs defaultFS) Open(name string) (fs.File, error) {
	if fs.fs == nil {
		return os.Open(name)
	}
	return fs.fs.Open(name)
}
func subFS(currentFs fs.FS, root string) (fs.FS, error) {
	root = filepath.ToSlash(filepath.Clean(root)) 
	if dFS, ok := currentFs.(*defaultFS); ok {
		if !filepath.IsAbs(root) {
			root = filepath.Join(dFS.prefix, root)
		}
		return &defaultFS{
			prefix: root,
			fs:     os.DirFS(root),
		}, nil
	}
	return fs.Sub(currentFs, root)
}
// MustSubFS creates sub FS from current filesystem or panic on failure.
// Panic happens when `fsRoot` contains invalid path according to `fs.ValidPath` rules.
//
// MustSubFS is helpful when dealing with `embed.FS` because for example `//go:embed assets/images` embeds files with
// paths including `assets/images` as their prefix. In that case use `fs := echo.MustSubFS(fs, "rootDirectory") to
// create sub fs which uses necessary prefix for directory path.
func MustSubFS(currentFs fs.FS, fsRoot string) fs.FS {
	subFs, err := subFS(currentFs, fsRoot)
	if err != nil {
		panic(fmt.Errorf("can not create sub FS, invalid root given, err: %w", err))
	}
	return subFs
}
func sanitizeURI(uri string) string {
	if len(uri) > 1 && (uri[0] == '\\' || uri[0] == '/') && (uri[1] == '\\' || uri[1] == '/') {
		uri = "/" + strings.TrimLeft(uri, `/\`)
	}
	return uri
}
