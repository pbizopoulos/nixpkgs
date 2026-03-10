// SPDX-License-Identifier: MIT
// SPDX-FileCopyrightText: © 2015 LabStack LLC and Echo contributors
package echo
import (
	"bytes"
	"fmt"
	"net/http"
)
// Router is the registry of all registered routes for an `Echo` instance for
// request matching and URL path parameter parsing.
type Router struct {
	tree   *node
	routes map[string]*Route
	echo   *Echo
}
type node struct {
	methods    *routeMethods
	parent     *node
	paramChild *node
	anyChild   *node
	notFoundHandler *routeMethod
	prefix          string
	originalPath    string
	staticChildren  children
	paramsCount     int
	label           byte
	kind            kind
	isLeaf bool
	isHandler bool
}
type (
	kind     uint8
	children []*node
)
type routeMethod struct {
	handler HandlerFunc
	ppath   string
	pnames  []string
}
type routeMethods struct {
	connect     *routeMethod
	delete      *routeMethod
	get         *routeMethod
	head        *routeMethod
	options     *routeMethod
	patch       *routeMethod
	post        *routeMethod
	propfind    *routeMethod
	put         *routeMethod
	trace       *routeMethod
	report      *routeMethod
	anyOther    map[string]*routeMethod
	allowHeader string
}
const (
	staticKind kind = iota
	paramKind
	anyKind
	paramLabel = byte(':')
	anyLabel   = byte('*')
)
func (m *routeMethods) isHandler() bool {
	return m.connect != nil ||
		m.delete != nil ||
		m.get != nil ||
		m.head != nil ||
		m.options != nil ||
		m.patch != nil ||
		m.post != nil ||
		m.propfind != nil ||
		m.put != nil ||
		m.trace != nil ||
		m.report != nil ||
		len(m.anyOther) != 0
}
func (m *routeMethods) updateAllowHeader() {
	buf := new(bytes.Buffer)
	buf.WriteString(http.MethodOptions)
	if m.connect != nil {
		buf.WriteString(", ")
		buf.WriteString(http.MethodConnect)
	}
	if m.delete != nil {
		buf.WriteString(", ")
		buf.WriteString(http.MethodDelete)
	}
	if m.get != nil {
		buf.WriteString(", ")
		buf.WriteString(http.MethodGet)
	}
	if m.head != nil {
		buf.WriteString(", ")
		buf.WriteString(http.MethodHead)
	}
	if m.patch != nil {
		buf.WriteString(", ")
		buf.WriteString(http.MethodPatch)
	}
	if m.post != nil {
		buf.WriteString(", ")
		buf.WriteString(http.MethodPost)
	}
	if m.propfind != nil {
		buf.WriteString(", PROPFIND")
	}
	if m.put != nil {
		buf.WriteString(", ")
		buf.WriteString(http.MethodPut)
	}
	if m.trace != nil {
		buf.WriteString(", ")
		buf.WriteString(http.MethodTrace)
	}
	if m.report != nil {
		buf.WriteString(", REPORT")
	}
	for method := range m.anyOther { 
		buf.WriteString(", ")
		buf.WriteString(method)
	}
	m.allowHeader = buf.String()
}
// NewRouter returns a new Router instance.
func NewRouter(e *Echo) *Router {
	return &Router{
		tree: &node{
			methods: new(routeMethods),
		},
		routes: map[string]*Route{},
		echo:   e,
	}
}
// Routes returns the registered routes.
func (r *Router) Routes() []*Route {
	routes := make([]*Route, 0, len(r.routes))
	for _, v := range r.routes {
		routes = append(routes, v)
	}
	return routes
}
// Reverse generates a URL from route name and provided parameters.
func (r *Router) Reverse(name string, params ...interface{}) string {
	uri := new(bytes.Buffer)
	ln := len(params)
	n := 0
	for _, route := range r.routes {
		if route.Name == name {
			for i, l := 0, len(route.Path); i < l; i++ {
				hasBackslash := route.Path[i] == '\\'
				if hasBackslash && i+1 < l && route.Path[i+1] == ':' {
					i++ 
				}
				if n < ln && (route.Path[i] == '*' || (!hasBackslash && route.Path[i] == ':')) {
					for ; i < l && route.Path[i] != '/'; i++ {
					}
					uri.WriteString(fmt.Sprintf("%v", params[n]))
					n++
				}
				if i < l {
					uri.WriteByte(route.Path[i])
				}
			}
			break
		}
	}
	return uri.String()
}
func normalizePathSlash(path string) string {
	if path == "" {
		path = "/"
	} else if path[0] != '/' {
		path = "/" + path
	}
	return path
}
func (r *Router) add(method, path, name string, h HandlerFunc) *Route {
	path = normalizePathSlash(path)
	r.insert(method, path, h)
	route := &Route{
		Method: method,
		Path:   path,
		Name:   name,
	}
	r.routes[method+path] = route
	return route
}
// Add registers a new route for method and path with matching handler.
func (r *Router) Add(method, path string, h HandlerFunc) {
	r.insert(method, normalizePathSlash(path), h)
}
func (r *Router) insert(method, path string, h HandlerFunc) {
	path = normalizePathSlash(path)
	pnames := []string{} 
	ppath := path        
	if h == nil && r.echo.Logger != nil {
		// FIXME: in future we should return error
		r.echo.Logger.Errorf("Adding route without handler function: %v:%v", method, path)
	}
	for i, lcpIndex := 0, len(path); i < lcpIndex; i++ {
		if path[i] == ':' {
			if i > 0 && path[i-1] == '\\' {
				path = path[:i-1] + path[i:]
				i--
				lcpIndex--
				continue
			}
			j := i + 1
			r.insertNode(method, path[:i], staticKind, routeMethod{})
			for ; i < lcpIndex && path[i] != '/'; i++ {
			}
			pnames = append(pnames, path[j:i])
			path = path[:j] + path[i:]
			i, lcpIndex = j, len(path)
			if i == lcpIndex {
				r.insertNode(method, path[:i], paramKind, routeMethod{ppath: ppath, pnames: pnames, handler: h})
			} else {
				r.insertNode(method, path[:i], paramKind, routeMethod{})
			}
		} else if path[i] == '*' {
			r.insertNode(method, path[:i], staticKind, routeMethod{})
			pnames = append(pnames, "*")
			r.insertNode(method, path[:i+1], anyKind, routeMethod{ppath: ppath, pnames: pnames, handler: h})
		}
	}
	r.insertNode(method, path, staticKind, routeMethod{ppath: ppath, pnames: pnames, handler: h})
}
func (r *Router) insertNode(method, path string, t kind, rm routeMethod) {
	paramLen := len(rm.pnames)
	if *r.echo.maxParam < paramLen {
		*r.echo.maxParam = paramLen
	}
	currentNode := r.tree 
	if currentNode == nil {
		panic("echo: invalid method")
	}
	search := path
	for {
		searchLen := len(search)
		prefixLen := len(currentNode.prefix)
		lcpLen := 0
		max := prefixLen
		if searchLen < max {
			max = searchLen
		}
		for ; lcpLen < max && search[lcpLen] == currentNode.prefix[lcpLen]; lcpLen++ {
		}
		if lcpLen == 0 {
			currentNode.label = search[0]
			currentNode.prefix = search
			if rm.handler != nil {
				currentNode.kind = t
				currentNode.addMethod(method, &rm)
				currentNode.paramsCount = len(rm.pnames)
				currentNode.originalPath = rm.ppath
			}
			currentNode.isLeaf = currentNode.staticChildren == nil && currentNode.paramChild == nil && currentNode.anyChild == nil
		} else if lcpLen < prefixLen {
			n := newNode(
				currentNode.kind,
				currentNode.prefix[lcpLen:],
				currentNode,
				currentNode.staticChildren,
				currentNode.originalPath,
				currentNode.methods,
				currentNode.paramsCount,
				currentNode.paramChild,
				currentNode.anyChild,
				currentNode.notFoundHandler,
			)
			for _, child := range currentNode.staticChildren {
				child.parent = n
			}
			if currentNode.paramChild != nil {
				currentNode.paramChild.parent = n
			}
			if currentNode.anyChild != nil {
				currentNode.anyChild.parent = n
			}
			currentNode.kind = staticKind
			currentNode.label = currentNode.prefix[0]
			currentNode.prefix = currentNode.prefix[:lcpLen]
			currentNode.staticChildren = nil
			currentNode.originalPath = ""
			currentNode.methods = new(routeMethods)
			currentNode.paramsCount = 0
			currentNode.paramChild = nil
			currentNode.anyChild = nil
			currentNode.isLeaf = false
			currentNode.isHandler = false
			currentNode.notFoundHandler = nil
			currentNode.addStaticChild(n)
			if lcpLen == searchLen {
				currentNode.kind = t
				if rm.handler != nil {
					currentNode.addMethod(method, &rm)
					currentNode.paramsCount = len(rm.pnames)
					currentNode.originalPath = rm.ppath
				}
			} else {
				n = newNode(t, search[lcpLen:], currentNode, nil, "", new(routeMethods), 0, nil, nil, nil)
				if rm.handler != nil {
					n.addMethod(method, &rm)
					n.paramsCount = len(rm.pnames)
					n.originalPath = rm.ppath
				}
				currentNode.addStaticChild(n)
			}
			currentNode.isLeaf = currentNode.staticChildren == nil && currentNode.paramChild == nil && currentNode.anyChild == nil
		} else if lcpLen < searchLen {
			search = search[lcpLen:]
			c := currentNode.findChildWithLabel(search[0])
			if c != nil {
				currentNode = c
				continue
			}
			n := newNode(t, search, currentNode, nil, rm.ppath, new(routeMethods), 0, nil, nil, nil)
			if rm.handler != nil {
				n.addMethod(method, &rm)
				n.paramsCount = len(rm.pnames)
			}
			switch t {
			case staticKind:
				currentNode.addStaticChild(n)
			case paramKind:
				currentNode.paramChild = n
			case anyKind:
				currentNode.anyChild = n
			}
			currentNode.isLeaf = currentNode.staticChildren == nil && currentNode.paramChild == nil && currentNode.anyChild == nil
		} else {
			if rm.handler != nil {
				currentNode.addMethod(method, &rm)
				currentNode.paramsCount = len(rm.pnames)
				currentNode.originalPath = rm.ppath
			}
		}
		return
	}
}
func newNode(
	t kind,
	pre string,
	p *node,
	sc children,
	originalPath string,
	methods *routeMethods,
	paramsCount int,
	paramChildren,
	anyChildren *node,
	notFoundHandler *routeMethod,
) *node {
	return &node{
		kind:            t,
		label:           pre[0],
		prefix:          pre,
		parent:          p,
		staticChildren:  sc,
		originalPath:    originalPath,
		methods:         methods,
		paramsCount:     paramsCount,
		paramChild:      paramChildren,
		anyChild:        anyChildren,
		isLeaf:          sc == nil && paramChildren == nil && anyChildren == nil,
		isHandler:       methods.isHandler(),
		notFoundHandler: notFoundHandler,
	}
}
func (n *node) addStaticChild(c *node) {
	n.staticChildren = append(n.staticChildren, c)
}
func (n *node) findStaticChild(l byte) *node {
	for _, c := range n.staticChildren {
		if c.label == l {
			return c
		}
	}
	return nil
}
func (n *node) findChildWithLabel(l byte) *node {
	if c := n.findStaticChild(l); c != nil {
		return c
	}
	if l == paramLabel {
		return n.paramChild
	}
	if l == anyLabel {
		return n.anyChild
	}
	return nil
}
func (n *node) addMethod(method string, h *routeMethod) {
	switch method {
	case http.MethodConnect:
		n.methods.connect = h
	case http.MethodDelete:
		n.methods.delete = h
	case http.MethodGet:
		n.methods.get = h
	case http.MethodHead:
		n.methods.head = h
	case http.MethodOptions:
		n.methods.options = h
	case http.MethodPatch:
		n.methods.patch = h
	case http.MethodPost:
		n.methods.post = h
	case PROPFIND:
		n.methods.propfind = h
	case http.MethodPut:
		n.methods.put = h
	case http.MethodTrace:
		n.methods.trace = h
	case REPORT:
		n.methods.report = h
	case RouteNotFound:
		n.notFoundHandler = h
		return 
	default:
		if n.methods.anyOther == nil {
			n.methods.anyOther = make(map[string]*routeMethod)
		}
		if h.handler == nil {
			delete(n.methods.anyOther, method)
		} else {
			n.methods.anyOther[method] = h
		}
	}
	n.methods.updateAllowHeader()
	n.isHandler = true
}
func (n *node) findMethod(method string) *routeMethod {
	switch method {
	case http.MethodConnect:
		return n.methods.connect
	case http.MethodDelete:
		return n.methods.delete
	case http.MethodGet:
		return n.methods.get
	case http.MethodHead:
		return n.methods.head
	case http.MethodOptions:
		return n.methods.options
	case http.MethodPatch:
		return n.methods.patch
	case http.MethodPost:
		return n.methods.post
	case PROPFIND:
		return n.methods.propfind
	case http.MethodPut:
		return n.methods.put
	case http.MethodTrace:
		return n.methods.trace
	case REPORT:
		return n.methods.report
	default: 
		return n.methods.anyOther[method]
	}
}
func optionsMethodHandler(allowMethods string) func(c Context) error {
	return func(c Context) error {
		c.Response().Header().Add(HeaderAllow, allowMethods)
		return c.NoContent(http.StatusNoContent)
	}
}
// Find lookup a handler registered for method and path. It also parses URL for path
// parameters and load them into context.
//
// For performance:
//
// - Get context from `Echo#AcquireContext()`
// - Reset it `Context#Reset()`
// - Return it `Echo#ReleaseContext()`.
func (r *Router) Find(method, path string, c Context) {
	ctx := c.(*context)
	currentNode := r.tree // Current node as root
	var (
		previousBestMatchNode *node
		matchedRouteMethod    *routeMethod
		search      = path
		searchIndex = 0
		paramIndex  int           
		paramValues = ctx.pvalues 
	)
	backtrackToNextNodeKind := func(fromKind kind) (nextNodeKind kind, valid bool) {
		previous := currentNode
		currentNode = previous.parent
		valid = currentNode != nil
		if previous.kind == anyKind {
			nextNodeKind = staticKind
		} else {
			nextNodeKind = previous.kind + 1
		}
		if fromKind == staticKind {
			return
		}
		if previous.kind == staticKind {
			searchIndex -= len(previous.prefix)
		} else {
			paramIndex--
			searchIndex -= len(paramValues[paramIndex])
			paramValues[paramIndex] = ""
		}
		search = path[searchIndex:]
		return
	}
	for {
		prefixLen := 0 
		lcpLen := 0    
		if currentNode.kind == staticKind {
			searchLen := len(search)
			prefixLen = len(currentNode.prefix)
			max := prefixLen
			if searchLen < max {
				max = searchLen
			}
			for ; lcpLen < max && search[lcpLen] == currentNode.prefix[lcpLen]; lcpLen++ {
			}
		}
		if lcpLen != prefixLen {
			nk, ok := backtrackToNextNodeKind(staticKind)
			if !ok {
				return 
			} else if nk == paramKind {
				goto Param
				// NOTE: this case (backtracking from static node to previous any node) can not happen by current any matching logic. Any node is end of search currently
			} else {
				break
			}
		}
		search = search[lcpLen:]
		searchIndex = searchIndex + lcpLen
		if search == "" {
			if currentNode.isHandler {
				if previousBestMatchNode == nil {
					previousBestMatchNode = currentNode
				}
				if h := currentNode.findMethod(method); h != nil {
					matchedRouteMethod = h
					break
				}
			} else if currentNode.notFoundHandler != nil {
				matchedRouteMethod = currentNode.notFoundHandler
				break
			}
		}
		if search != "" {
			if child := currentNode.findStaticChild(search[0]); child != nil {
				currentNode = child
				continue
			}
		}
	Param:
		if child := currentNode.paramChild; search != "" && child != nil {
			currentNode = child
			i := 0
			l := len(search)
			if currentNode.isLeaf {
				i = l
			} else {
				for ; i < l && search[i] != '/'; i++ {
				}
			}
			paramValues[paramIndex] = search[:i]
			paramIndex++
			search = search[i:]
			searchIndex = searchIndex + i
			continue
		}
	Any:
		if child := currentNode.anyChild; child != nil {
			currentNode = child
			paramValues[currentNode.paramsCount-1] = search
			paramIndex++
			searchIndex += +len(search)
			search = ""
			if h := currentNode.findMethod(method); h != nil {
				matchedRouteMethod = h
				break
			}
			if previousBestMatchNode == nil {
				previousBestMatchNode = currentNode
			}
			if currentNode.notFoundHandler != nil {
				matchedRouteMethod = currentNode.notFoundHandler
				break
			}
		}
		nk, ok := backtrackToNextNodeKind(anyKind)
		if !ok {
			break 
		} else if nk == paramKind {
			goto Param
		} else if nk == anyKind {
			goto Any
		} else {
			break
		}
	}
	if currentNode == nil && previousBestMatchNode == nil {
		return 
	}
	// matchedHandler could be method+path handler that we matched or notFoundHandler from node with matching path
	// user provided not found (404) handler has priority over generic method not found (405) handler or global 404 handler
	var rPath string
	var rPNames []string
	if matchedRouteMethod != nil {
		rPath = matchedRouteMethod.ppath
		rPNames = matchedRouteMethod.pnames
		ctx.handler = matchedRouteMethod.handler
	} else {
		currentNode = previousBestMatchNode
		rPath = currentNode.originalPath
		rPNames = nil 
		ctx.handler = NotFoundHandler
		if currentNode.notFoundHandler != nil {
			rPath = currentNode.notFoundHandler.ppath
			rPNames = currentNode.notFoundHandler.pnames
			ctx.handler = currentNode.notFoundHandler.handler
		} else if currentNode.isHandler {
			ctx.Set(ContextKeyHeaderAllow, currentNode.methods.allowHeader)
			ctx.handler = MethodNotAllowedHandler
			if method == http.MethodOptions {
				ctx.handler = optionsMethodHandler(currentNode.methods.allowHeader)
			}
		}
	}
	ctx.path = rPath
	ctx.pnames = rPNames
}
