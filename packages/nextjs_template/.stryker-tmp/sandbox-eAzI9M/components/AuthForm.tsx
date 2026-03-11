// @ts-nocheck
"use client";

function stryNS_9fa48() {
  var g = typeof globalThis === 'object' && globalThis && globalThis.Math === Math && globalThis || new Function("return this")();
  var ns = g.__stryker__ || (g.__stryker__ = {});
  if (ns.activeMutant === undefined && g.process && g.process.env && g.process.env.__STRYKER_ACTIVE_MUTANT__) {
    ns.activeMutant = g.process.env.__STRYKER_ACTIVE_MUTANT__;
  }
  function retrieveNS() {
    return ns;
  }
  stryNS_9fa48 = retrieveNS;
  return retrieveNS();
}
stryNS_9fa48();
function stryCov_9fa48() {
  var ns = stryNS_9fa48();
  var cov = ns.mutantCoverage || (ns.mutantCoverage = {
    static: {},
    perTest: {}
  });
  function cover() {
    var c = cov.static;
    if (ns.currentTestId) {
      c = cov.perTest[ns.currentTestId] = cov.perTest[ns.currentTestId] || {};
    }
    var a = arguments;
    for (var i = 0; i < a.length; i++) {
      c[a[i]] = (c[a[i]] || 0) + 1;
    }
  }
  stryCov_9fa48 = cover;
  cover.apply(null, arguments);
}
function stryMutAct_9fa48(id) {
  var ns = stryNS_9fa48();
  function isActive(id) {
    if (ns.activeMutant === id) {
      if (ns.hitCount !== void 0 && ++ns.hitCount > ns.hitLimit) {
        throw new Error('Stryker: Hit count limit reached (' + ns.hitCount + ')');
      }
      return true;
    }
    return false;
  }
  stryMutAct_9fa48 = isActive;
  return isActive(id);
}
import { useRouter, useSearchParams } from "next/navigation";
import { Suspense, useState } from "react";
import { isValidUsername, SLUG_MAX_LENGTH } from "../lib/validation";
import { useAuth } from "./AuthProvider";
interface AuthFormProps {
  onSuccess?: () => void;
}
export default function AuthForm({
  onSuccess
}: AuthFormProps) {
  if (stryMutAct_9fa48("65")) {
    {}
  } else {
    stryCov_9fa48("65");
    return <Suspense fallback={<div>Loading...</div>}>
      <AuthFormContent {...onSuccess ? stryMutAct_9fa48("66") ? {} : (stryCov_9fa48("66"), {
        onSuccess
      }) : {}} />
    </Suspense>;
  }
}
function AuthFormContent({
  onSuccess
}: AuthFormProps) {
  if (stryMutAct_9fa48("67")) {
    {}
  } else {
    stryCov_9fa48("67");
    const [mode, setMode] = useState<"signin" | "signup">(stryMutAct_9fa48("68") ? "" : (stryCov_9fa48("68"), "signin"));
    const [email, setEmail] = useState(stryMutAct_9fa48("69") ? "Stryker was here!" : (stryCov_9fa48("69"), ""));
    const [password, setPassword] = useState(stryMutAct_9fa48("70") ? "Stryker was here!" : (stryCov_9fa48("70"), ""));
    const [name, setName] = useState(stryMutAct_9fa48("71") ? "Stryker was here!" : (stryCov_9fa48("71"), ""));
    const [loading, setLoading] = useState(stryMutAct_9fa48("72") ? true : (stryCov_9fa48("72"), false));
    const [message, setMessage] = useState<{
      type: "success" | "error";
      text: string;
    } | null>(null);
    const searchParams = useSearchParams();
    const router = useRouter();
    const redirect = stryMutAct_9fa48("75") ? searchParams.get("redirect") && "/" : stryMutAct_9fa48("74") ? false : stryMutAct_9fa48("73") ? true : (stryCov_9fa48("73", "74", "75"), searchParams.get(stryMutAct_9fa48("76") ? "" : (stryCov_9fa48("76"), "redirect")) || (stryMutAct_9fa48("77") ? "" : (stryCov_9fa48("77"), "/")));
    const {
      supabase
    } = useAuth();
    const handleAuth = async (event: React.FormEvent) => {
      if (stryMutAct_9fa48("78")) {
        {}
      } else {
        stryCov_9fa48("78");
        event.preventDefault();
        setLoading(stryMutAct_9fa48("79") ? false : (stryCov_9fa48("79"), true));
        setMessage(null);
        if (stryMutAct_9fa48("82") ? mode !== "signup" : stryMutAct_9fa48("81") ? false : stryMutAct_9fa48("80") ? true : (stryCov_9fa48("80", "81", "82"), mode === (stryMutAct_9fa48("83") ? "" : (stryCov_9fa48("83"), "signup")))) {
          if (stryMutAct_9fa48("84")) {
            {}
          } else {
            stryCov_9fa48("84");
            if (stryMutAct_9fa48("87") ? false : stryMutAct_9fa48("86") ? true : stryMutAct_9fa48("85") ? isValidUsername(name) : (stryCov_9fa48("85", "86", "87"), !isValidUsername(name))) {
              if (stryMutAct_9fa48("88")) {
                {}
              } else {
                stryCov_9fa48("88");
                setMessage(stryMutAct_9fa48("89") ? {} : (stryCov_9fa48("89"), {
                  type: stryMutAct_9fa48("90") ? "" : (stryCov_9fa48("90"), "error"),
                  text: stryMutAct_9fa48("91") ? `` : (stryCov_9fa48("91"), `Invalid username: must be a valid slug between 3 and ${SLUG_MAX_LENGTH} characters`)
                }));
                setLoading(stryMutAct_9fa48("92") ? true : (stryCov_9fa48("92"), false));
                return;
              }
            }
            const {
              error,
              data
            } = await supabase.auth.signUp(stryMutAct_9fa48("93") ? {} : (stryCov_9fa48("93"), {
              email,
              password,
              options: stryMutAct_9fa48("94") ? {} : (stryCov_9fa48("94"), {
                data: stryMutAct_9fa48("95") ? {} : (stryCov_9fa48("95"), {
                  username: name
                }),
                emailRedirectTo: stryMutAct_9fa48("96") ? `` : (stryCov_9fa48("96"), `${window.location.origin}/auth/callback`)
              })
            }));
            if (stryMutAct_9fa48("98") ? false : stryMutAct_9fa48("97") ? true : (stryCov_9fa48("97", "98"), error)) {
              if (stryMutAct_9fa48("99")) {
                {}
              } else {
                stryCov_9fa48("99");
                setMessage(stryMutAct_9fa48("100") ? {} : (stryCov_9fa48("100"), {
                  type: stryMutAct_9fa48("101") ? "" : (stryCov_9fa48("101"), "error"),
                  text: error.message
                }));
              }
            } else if (stryMutAct_9fa48("104") ? data.user || !data.session : stryMutAct_9fa48("103") ? false : stryMutAct_9fa48("102") ? true : (stryCov_9fa48("102", "103", "104"), data.user && (stryMutAct_9fa48("105") ? data.session : (stryCov_9fa48("105"), !data.session)))) {
              if (stryMutAct_9fa48("106")) {
                {}
              } else {
                stryCov_9fa48("106");
                setMessage(stryMutAct_9fa48("107") ? {} : (stryCov_9fa48("107"), {
                  type: stryMutAct_9fa48("108") ? "" : (stryCov_9fa48("108"), "success"),
                  text: stryMutAct_9fa48("109") ? "" : (stryCov_9fa48("109"), "Please check your email to verify your account.")
                }));
                setLoading(stryMutAct_9fa48("110") ? true : (stryCov_9fa48("110"), false));
              }
            } else {
              if (stryMutAct_9fa48("111")) {
                {}
              } else {
                stryCov_9fa48("111");
                setMessage(stryMutAct_9fa48("112") ? {} : (stryCov_9fa48("112"), {
                  type: stryMutAct_9fa48("113") ? "" : (stryCov_9fa48("113"), "success"),
                  text: stryMutAct_9fa48("114") ? "" : (stryCov_9fa48("114"), "Account created successfully!")
                }));
                onSuccess ? onSuccess() : router.push(redirect);
              }
            }
          }
        } else {
          if (stryMutAct_9fa48("115")) {
            {}
          } else {
            stryCov_9fa48("115");
            const {
              error
            } = await supabase.auth.signInWithPassword(stryMutAct_9fa48("116") ? {} : (stryCov_9fa48("116"), {
              email,
              password
            }));
            if (stryMutAct_9fa48("118") ? false : stryMutAct_9fa48("117") ? true : (stryCov_9fa48("117", "118"), error)) {
              if (stryMutAct_9fa48("119")) {
                {}
              } else {
                stryCov_9fa48("119");
                setMessage(stryMutAct_9fa48("120") ? {} : (stryCov_9fa48("120"), {
                  type: stryMutAct_9fa48("121") ? "" : (stryCov_9fa48("121"), "error"),
                  text: error.message
                }));
                setLoading(stryMutAct_9fa48("122") ? true : (stryCov_9fa48("122"), false));
              }
            } else {
              if (stryMutAct_9fa48("123")) {
                {}
              } else {
                stryCov_9fa48("123");
                setMessage(stryMutAct_9fa48("124") ? {} : (stryCov_9fa48("124"), {
                  type: stryMutAct_9fa48("125") ? "" : (stryCov_9fa48("125"), "success"),
                  text: stryMutAct_9fa48("126") ? "" : (stryCov_9fa48("126"), "Logged in successfully!")
                }));
                onSuccess ? onSuccess() : router.push(redirect);
              }
            }
          }
        }
        setLoading(stryMutAct_9fa48("127") ? true : (stryCov_9fa48("127"), false));
      }
    };
    return <div data-testid="auth-form">
      <h1>{(stryMutAct_9fa48("130") ? mode !== "signin" : stryMutAct_9fa48("129") ? false : stryMutAct_9fa48("128") ? true : (stryCov_9fa48("128", "129", "130"), mode === (stryMutAct_9fa48("131") ? "" : (stryCov_9fa48("131"), "signin")))) ? stryMutAct_9fa48("132") ? "" : (stryCov_9fa48("132"), "Sign In") : stryMutAct_9fa48("133") ? "" : (stryCov_9fa48("133"), "Sign Up")}</h1>
      <p>{(stryMutAct_9fa48("136") ? mode !== "signin" : stryMutAct_9fa48("135") ? false : stryMutAct_9fa48("134") ? true : (stryCov_9fa48("134", "135", "136"), mode === (stryMutAct_9fa48("137") ? "" : (stryCov_9fa48("137"), "signin")))) ? stryMutAct_9fa48("138") ? "" : (stryCov_9fa48("138"), "Welcome back") : stryMutAct_9fa48("139") ? "" : (stryCov_9fa48("139"), "Create a new account")}</p>

      {stryMutAct_9fa48("142") ? message || <div style={{
        padding: "0.75rem",
        borderRadius: "0.5rem",
        marginBottom: "1.5rem",
        fontSize: "0.875rem",
        backgroundColor: message.type === "error" ? "#fef2f2" : "#f0fdf4",
        color: message.type === "error" ? "#dc2626" : "#16a34a",
        border: `1px solid ${message.type === "error" ? "#fee2e2" : "#dcfce7"}`
      }}>
          {message.text}
        </div> : stryMutAct_9fa48("141") ? false : stryMutAct_9fa48("140") ? true : (stryCov_9fa48("140", "141", "142"), message && <div style={stryMutAct_9fa48("143") ? {} : (stryCov_9fa48("143"), {
        padding: stryMutAct_9fa48("144") ? "" : (stryCov_9fa48("144"), "0.75rem"),
        borderRadius: stryMutAct_9fa48("145") ? "" : (stryCov_9fa48("145"), "0.5rem"),
        marginBottom: stryMutAct_9fa48("146") ? "" : (stryCov_9fa48("146"), "1.5rem"),
        fontSize: stryMutAct_9fa48("147") ? "" : (stryCov_9fa48("147"), "0.875rem"),
        backgroundColor: (stryMutAct_9fa48("150") ? message.type !== "error" : stryMutAct_9fa48("149") ? false : stryMutAct_9fa48("148") ? true : (stryCov_9fa48("148", "149", "150"), message.type === (stryMutAct_9fa48("151") ? "" : (stryCov_9fa48("151"), "error")))) ? stryMutAct_9fa48("152") ? "" : (stryCov_9fa48("152"), "#fef2f2") : stryMutAct_9fa48("153") ? "" : (stryCov_9fa48("153"), "#f0fdf4"),
        color: (stryMutAct_9fa48("156") ? message.type !== "error" : stryMutAct_9fa48("155") ? false : stryMutAct_9fa48("154") ? true : (stryCov_9fa48("154", "155", "156"), message.type === (stryMutAct_9fa48("157") ? "" : (stryCov_9fa48("157"), "error")))) ? stryMutAct_9fa48("158") ? "" : (stryCov_9fa48("158"), "#dc2626") : stryMutAct_9fa48("159") ? "" : (stryCov_9fa48("159"), "#16a34a"),
        border: stryMutAct_9fa48("160") ? `` : (stryCov_9fa48("160"), `1px solid ${(stryMutAct_9fa48("163") ? message.type !== "error" : stryMutAct_9fa48("162") ? false : stryMutAct_9fa48("161") ? true : (stryCov_9fa48("161", "162", "163"), message.type === (stryMutAct_9fa48("164") ? "" : (stryCov_9fa48("164"), "error")))) ? stryMutAct_9fa48("165") ? "" : (stryCov_9fa48("165"), "#fee2e2") : stryMutAct_9fa48("166") ? "" : (stryCov_9fa48("166"), "#dcfce7")}`)
      })}>
          {message.text}
        </div>)}

      <form onSubmit={handleAuth} style={stryMutAct_9fa48("167") ? {} : (stryCov_9fa48("167"), {
        display: stryMutAct_9fa48("168") ? "" : (stryCov_9fa48("168"), "flex"),
        flexDirection: stryMutAct_9fa48("169") ? "" : (stryCov_9fa48("169"), "column"),
        gap: stryMutAct_9fa48("170") ? "" : (stryCov_9fa48("170"), "1rem")
      })}>
        {stryMutAct_9fa48("173") ? mode === "signup" || <div>
            <label htmlFor="name" style={{
            display: "block",
            fontSize: "0.75rem",
            fontWeight: "500",
            marginBottom: "0.25rem"
          }}>
              Username
            </label>
            <input id="name" type="text" required value={name} onChange={e => {
            const sanitizedUsername = e.target.value.toLowerCase().replace(/[^a-z0-9-]/g, "");
            setName(sanitizedUsername);
          }} placeholder="username" />
          </div> : stryMutAct_9fa48("172") ? false : stryMutAct_9fa48("171") ? true : (stryCov_9fa48("171", "172", "173"), (stryMutAct_9fa48("175") ? mode !== "signup" : stryMutAct_9fa48("174") ? true : (stryCov_9fa48("174", "175"), mode === (stryMutAct_9fa48("176") ? "" : (stryCov_9fa48("176"), "signup")))) && <div>
            <label htmlFor="name" style={stryMutAct_9fa48("177") ? {} : (stryCov_9fa48("177"), {
            display: stryMutAct_9fa48("178") ? "" : (stryCov_9fa48("178"), "block"),
            fontSize: stryMutAct_9fa48("179") ? "" : (stryCov_9fa48("179"), "0.75rem"),
            fontWeight: stryMutAct_9fa48("180") ? "" : (stryCov_9fa48("180"), "500"),
            marginBottom: stryMutAct_9fa48("181") ? "" : (stryCov_9fa48("181"), "0.25rem")
          })}>
              Username
            </label>
            <input id="name" type="text" required value={name} onChange={e => {
            if (stryMutAct_9fa48("182")) {
              {}
            } else {
              stryCov_9fa48("182");
              const sanitizedUsername = stryMutAct_9fa48("183") ? e.target.value.toUpperCase().replace(/[^a-z0-9-]/g, "") : (stryCov_9fa48("183"), e.target.value.toLowerCase().replace(stryMutAct_9fa48("184") ? /[a-z0-9-]/g : (stryCov_9fa48("184"), /[^a-z0-9-]/g), stryMutAct_9fa48("185") ? "Stryker was here!" : (stryCov_9fa48("185"), "")));
              setName(sanitizedUsername);
            }
          }} placeholder="username" />
          </div>)}
        <div>
          <label htmlFor="email" style={stryMutAct_9fa48("186") ? {} : (stryCov_9fa48("186"), {
            display: stryMutAct_9fa48("187") ? "" : (stryCov_9fa48("187"), "block"),
            fontSize: stryMutAct_9fa48("188") ? "" : (stryCov_9fa48("188"), "0.75rem"),
            fontWeight: stryMutAct_9fa48("189") ? "" : (stryCov_9fa48("189"), "500"),
            marginBottom: stryMutAct_9fa48("190") ? "" : (stryCov_9fa48("190"), "0.25rem")
          })}>
            Email
          </label>
          <input id="email" type="email" required value={email} onChange={stryMutAct_9fa48("191") ? () => undefined : (stryCov_9fa48("191"), e => setEmail(e.target.value))} placeholder="you@example.com" />
        </div>
        <div>
          <label htmlFor="password" style={stryMutAct_9fa48("192") ? {} : (stryCov_9fa48("192"), {
            display: stryMutAct_9fa48("193") ? "" : (stryCov_9fa48("193"), "block"),
            fontSize: stryMutAct_9fa48("194") ? "" : (stryCov_9fa48("194"), "0.75rem"),
            fontWeight: stryMutAct_9fa48("195") ? "" : (stryCov_9fa48("195"), "500"),
            marginBottom: stryMutAct_9fa48("196") ? "" : (stryCov_9fa48("196"), "0.25rem")
          })}>
            Password
          </label>
          <input id="password" type="password" required value={password} onChange={stryMutAct_9fa48("197") ? () => undefined : (stryCov_9fa48("197"), e => setPassword(e.target.value))} placeholder="••••••••" />
        </div>

        <button type="submit" data-testid="auth-submit" disabled={loading} style={stryMutAct_9fa48("198") ? {} : (stryCov_9fa48("198"), {
          backgroundColor: stryMutAct_9fa48("199") ? "" : (stryCov_9fa48("199"), "#000"),
          color: stryMutAct_9fa48("200") ? "" : (stryCov_9fa48("200"), "#fff"),
          border: stryMutAct_9fa48("201") ? "" : (stryCov_9fa48("201"), "none"),
          padding: stryMutAct_9fa48("202") ? "" : (stryCov_9fa48("202"), "0.5rem"),
          borderRadius: stryMutAct_9fa48("203") ? "" : (stryCov_9fa48("203"), "0.25rem"),
          opacity: loading ? 0.5 : 1
        })}>
          {loading ? stryMutAct_9fa48("204") ? "" : (stryCov_9fa48("204"), "Processing...") : (stryMutAct_9fa48("207") ? mode !== "signin" : stryMutAct_9fa48("206") ? false : stryMutAct_9fa48("205") ? true : (stryCov_9fa48("205", "206", "207"), mode === (stryMutAct_9fa48("208") ? "" : (stryCov_9fa48("208"), "signin")))) ? stryMutAct_9fa48("209") ? "" : (stryCov_9fa48("209"), "Sign In") : stryMutAct_9fa48("210") ? "" : (stryCov_9fa48("210"), "Create Account")}
        </button>
      </form>

      <div style={stryMutAct_9fa48("211") ? {} : (stryCov_9fa48("211"), {
        marginTop: stryMutAct_9fa48("212") ? "" : (stryCov_9fa48("212"), "1.5rem"),
        textAlign: stryMutAct_9fa48("213") ? "" : (stryCov_9fa48("213"), "center"),
        fontSize: stryMutAct_9fa48("214") ? "" : (stryCov_9fa48("214"), "0.875rem")
      })}>
        <button type="button" onClick={() => {
          if (stryMutAct_9fa48("215")) {
            {}
          } else {
            stryCov_9fa48("215");
            setMode((stryMutAct_9fa48("218") ? mode !== "signin" : stryMutAct_9fa48("217") ? false : stryMutAct_9fa48("216") ? true : (stryCov_9fa48("216", "217", "218"), mode === (stryMutAct_9fa48("219") ? "" : (stryCov_9fa48("219"), "signin")))) ? stryMutAct_9fa48("220") ? "" : (stryCov_9fa48("220"), "signup") : stryMutAct_9fa48("221") ? "" : (stryCov_9fa48("221"), "signin"));
          }
        }} style={stryMutAct_9fa48("222") ? {} : (stryCov_9fa48("222"), {
          background: stryMutAct_9fa48("223") ? "" : (stryCov_9fa48("223"), "none"),
          border: stryMutAct_9fa48("224") ? "" : (stryCov_9fa48("224"), "none"),
          textDecoration: stryMutAct_9fa48("225") ? "" : (stryCov_9fa48("225"), "underline"),
          color: stryMutAct_9fa48("226") ? "" : (stryCov_9fa48("226"), "#6b7280")
        })}>
          {(stryMutAct_9fa48("229") ? mode !== "signin" : stryMutAct_9fa48("228") ? false : stryMutAct_9fa48("227") ? true : (stryCov_9fa48("227", "228", "229"), mode === (stryMutAct_9fa48("230") ? "" : (stryCov_9fa48("230"), "signin")))) ? stryMutAct_9fa48("231") ? "" : (stryCov_9fa48("231"), "Don't have an account? Sign Up") : stryMutAct_9fa48("232") ? "" : (stryCov_9fa48("232"), "Already have an account? Sign In")}
        </button>
      </div>
    </div>;
  }
}