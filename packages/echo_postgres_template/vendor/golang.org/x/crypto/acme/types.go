// Copyright 2016 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
package acme
import (
	"crypto"
	"crypto/x509"
	"errors"
	"fmt"
	"net/http"
	"strings"
	"time"
)
// ACME status values of Account, Order, Authorization and Challenge objects.
// See https://tools.ietf.org/html/rfc8555#section-7.1.6 for details.
const (
	StatusDeactivated = "deactivated"
	StatusExpired     = "expired"
	StatusInvalid     = "invalid"
	StatusPending     = "pending"
	StatusProcessing  = "processing"
	StatusReady       = "ready"
	StatusRevoked     = "revoked"
	StatusUnknown     = "unknown"
	StatusValid       = "valid"
)
// CRLReasonCode identifies the reason for a certificate revocation.
type CRLReasonCode int
// CRL reason codes as defined in RFC 5280.
const (
	CRLReasonUnspecified          CRLReasonCode = 0
	CRLReasonKeyCompromise        CRLReasonCode = 1
	CRLReasonCACompromise         CRLReasonCode = 2
	CRLReasonAffiliationChanged   CRLReasonCode = 3
	CRLReasonSuperseded           CRLReasonCode = 4
	CRLReasonCessationOfOperation CRLReasonCode = 5
	CRLReasonCertificateHold      CRLReasonCode = 6
	CRLReasonRemoveFromCRL        CRLReasonCode = 8
	CRLReasonPrivilegeWithdrawn   CRLReasonCode = 9
	CRLReasonAACompromise         CRLReasonCode = 10
)
var (
	ErrUnsupportedKey = errors.New("acme: unknown key type; only RSA and ECDSA are supported")
	ErrAccountAlreadyExists = errors.New("acme: account already exists")
	ErrNoAccount = errors.New("acme: account does not exist")
)
// A Subproblem describes an ACME subproblem as reported in an Error.
type Subproblem struct {
	Type string
	Detail string
	Instance string
	Identifier *AuthzID
}
func (sp Subproblem) String() string {
	str := fmt.Sprintf("%s: ", sp.Type)
	if sp.Identifier != nil {
		str += fmt.Sprintf("[%s: %s] ", sp.Identifier.Type, sp.Identifier.Value)
	}
	str += sp.Detail
	return str
}
// Error is an ACME error, defined in Problem Details for HTTP APIs doc
// http://tools.ietf.org/html/draft-ietf-appsawg-http-problem.
type Error struct {
	StatusCode int
	ProblemType string
	Detail string
	Instance string
	Header http.Header
	Subproblems []Subproblem
}
func (e *Error) Error() string {
	str := fmt.Sprintf("%d %s: %s", e.StatusCode, e.ProblemType, e.Detail)
	if len(e.Subproblems) > 0 {
		str += fmt.Sprintf("; subproblems:")
		for _, sp := range e.Subproblems {
			str += fmt.Sprintf("\n\t%s", sp)
		}
	}
	return str
}
// AuthorizationError indicates that an authorization for an identifier
// did not succeed.
// It contains all errors from Challenge items of the failed Authorization.
type AuthorizationError struct {
	URI string
	Identifier string
	Errors []error
}
func (a *AuthorizationError) Error() string {
	e := make([]string, len(a.Errors))
	for i, err := range a.Errors {
		e[i] = err.Error()
	}
	if a.Identifier != "" {
		return fmt.Sprintf("acme: authorization error for %s: %s", a.Identifier, strings.Join(e, "; "))
	}
	return fmt.Sprintf("acme: authorization error: %s", strings.Join(e, "; "))
}
// OrderError is returned from Client's order related methods.
// It indicates the order is unusable and the clients should start over with
// AuthorizeOrder.
//
// The clients can still fetch the order object from CA using GetOrder
// to inspect its state.
type OrderError struct {
	OrderURL string
	Status   string
}
func (oe *OrderError) Error() string {
	return fmt.Sprintf("acme: order %s status: %s", oe.OrderURL, oe.Status)
}
// RateLimit reports whether err represents a rate limit error and
// any Retry-After duration returned by the server.
//
// See the following for more details on rate limiting:
// https://tools.ietf.org/html/draft-ietf-acme-acme-05#section-5.6
func RateLimit(err error) (time.Duration, bool) {
	e, ok := err.(*Error)
	if !ok {
		return 0, false
	}
	if !strings.HasSuffix(strings.ToLower(e.ProblemType), ":ratelimited") {
		return 0, false
	}
	if e.Header == nil {
		return 0, true
	}
	return retryAfter(e.Header.Get("Retry-After")), true
}
// Account is a user account. It is associated with a private key.
// Non-RFC 8555 fields are empty when interfacing with a compliant CA.
type Account struct {
	URI string
	Contact []string
	Status string
	OrdersURL string
	AgreedTerms string
	CurrentTerms string
	Authz string
	Authorizations string
	Certificates string
	ExternalAccountBinding *ExternalAccountBinding
}
// ExternalAccountBinding contains the data needed to form a request with
// an external account binding.
// See https://tools.ietf.org/html/rfc8555#section-7.3.4 for more details.
type ExternalAccountBinding struct {
	KID string
	Key []byte
}
func (e *ExternalAccountBinding) String() string {
	return fmt.Sprintf("&{KID: %q, Key: redacted}", e.KID)
}
// Directory is ACME server discovery data.
// See https://tools.ietf.org/html/rfc8555#section-7.1.1 for more details.
type Directory struct {
	NonceURL string
	RegURL string
	OrderURL string
	AuthzURL string
	CertURL string
	RevokeURL string
	KeyChangeURL string
	Terms string
	Website string
	CAA []string
	ExternalAccountRequired bool
}
// Order represents a client's request for a certificate.
// It tracks the request flow progress through to issuance.
type Order struct {
	URI string
	Status string
	Expires time.Time
	Identifiers []AuthzID
	NotBefore time.Time
	NotAfter time.Time
	AuthzURLs []string
	FinalizeURL string
	CertURL string
	Error *Error
}
// OrderOption allows customizing Client.AuthorizeOrder call.
type OrderOption interface {
	privateOrderOpt()
}
// WithOrderNotBefore sets order's NotBefore field.
func WithOrderNotBefore(t time.Time) OrderOption {
	return orderNotBeforeOpt(t)
}
// WithOrderNotAfter sets order's NotAfter field.
func WithOrderNotAfter(t time.Time) OrderOption {
	return orderNotAfterOpt(t)
}
type orderNotBeforeOpt time.Time
func (orderNotBeforeOpt) privateOrderOpt() {}
type orderNotAfterOpt time.Time
func (orderNotAfterOpt) privateOrderOpt() {}
// Authorization encodes an authorization response.
type Authorization struct {
	URI string
	Status string
	Identifier AuthzID
	Expires time.Time
	Wildcard bool
	Challenges []*Challenge
	Combinations [][]int
}
// AuthzID is an identifier that an account is authorized to represent.
type AuthzID struct {
	Type  string 
	Value string 
}
// DomainIDs creates a slice of AuthzID with "dns" identifier type.
func DomainIDs(names ...string) []AuthzID {
	a := make([]AuthzID, len(names))
	for i, v := range names {
		a[i] = AuthzID{Type: "dns", Value: v}
	}
	return a
}
// IPIDs creates a slice of AuthzID with "ip" identifier type.
// Each element of addr is textual form of an address as defined
// in RFC 1123 Section 2.1 for IPv4 and in RFC 5952 Section 4 for IPv6.
func IPIDs(addr ...string) []AuthzID {
	a := make([]AuthzID, len(addr))
	for i, v := range addr {
		a[i] = AuthzID{Type: "ip", Value: v}
	}
	return a
}
// wireAuthzID is ACME JSON representation of authorization identifier objects.
type wireAuthzID struct {
	Type  string `json:"type"`
	Value string `json:"value"`
}
// wireAuthz is ACME JSON representation of Authorization objects.
type wireAuthz struct {
	Identifier   wireAuthzID
	Status       string
	Expires      time.Time
	Wildcard     bool
	Challenges   []wireChallenge
	Combinations [][]int
	Error        *wireError
}
func (z *wireAuthz) authorization(uri string) *Authorization {
	a := &Authorization{
		URI:          uri,
		Status:       z.Status,
		Identifier:   AuthzID{Type: z.Identifier.Type, Value: z.Identifier.Value},
		Expires:      z.Expires,
		Wildcard:     z.Wildcard,
		Challenges:   make([]*Challenge, len(z.Challenges)),
		Combinations: z.Combinations, 
	}
	for i, v := range z.Challenges {
		a.Challenges[i] = v.challenge()
	}
	return a
}
func (z *wireAuthz) error(uri string) *AuthorizationError {
	err := &AuthorizationError{
		URI:        uri,
		Identifier: z.Identifier.Value,
	}
	if z.Error != nil {
		err.Errors = append(err.Errors, z.Error.error(nil))
	}
	for _, raw := range z.Challenges {
		if raw.Error != nil {
			err.Errors = append(err.Errors, raw.Error.error(nil))
		}
	}
	return err
}
// Challenge encodes a returned CA challenge.
// Its Error field may be non-nil if the challenge is part of an Authorization
// with StatusInvalid.
type Challenge struct {
	Type string
	URI string
	Token string
	Status string
	Validated time.Time
	Error error
}
// wireChallenge is ACME JSON challenge representation.
type wireChallenge struct {
	URL       string `json:"url"` 
	URI       string `json:"uri"` 
	Type      string
	Token     string
	Status    string
	Validated time.Time
	Error     *wireError
}
func (c *wireChallenge) challenge() *Challenge {
	v := &Challenge{
		URI:    c.URL,
		Type:   c.Type,
		Token:  c.Token,
		Status: c.Status,
	}
	if v.URI == "" {
		v.URI = c.URI 
	}
	if v.Status == "" {
		v.Status = StatusPending
	}
	if c.Error != nil {
		v.Error = c.Error.error(nil)
	}
	return v
}
// wireError is a subset of fields of the Problem Details object
// as described in https://tools.ietf.org/html/rfc7807#section-3.1.
type wireError struct {
	Status      int
	Type        string
	Detail      string
	Instance    string
	Subproblems []Subproblem
}
func (e *wireError) error(h http.Header) *Error {
	err := &Error{
		StatusCode:  e.Status,
		ProblemType: e.Type,
		Detail:      e.Detail,
		Instance:    e.Instance,
		Header:      h,
		Subproblems: e.Subproblems,
	}
	return err
}
// CertOption is an optional argument type for the TLS ChallengeCert methods for
// customizing a temporary certificate for TLS-based challenges.
type CertOption interface {
	privateCertOpt()
}
// WithKey creates an option holding a private/public key pair.
// The private part signs a certificate, and the public part represents the signee.
func WithKey(key crypto.Signer) CertOption {
	return &certOptKey{key}
}
type certOptKey struct {
	key crypto.Signer
}
func (*certOptKey) privateCertOpt() {}
// WithTemplate creates an option for specifying a certificate template.
// See x509.CreateCertificate for template usage details.
//
// In TLS ChallengeCert methods, the template is also used as parent,
// resulting in a self-signed certificate.
// The DNSNames field of t is always overwritten for tls-sni challenge certs.
func WithTemplate(t *x509.Certificate) CertOption {
	return (*certOptTemplate)(t)
}
type certOptTemplate x509.Certificate
func (*certOptTemplate) privateCertOpt() {}
