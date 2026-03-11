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
import { createBrowserClient } from "@supabase/ssr";
import type { SupabaseClient, User } from "@supabase/supabase-js";
import { createContext, useContext, useEffect, useState } from "react";
type Profile = {
  username: string | null;
};
type AuthContextType = {
  user: User | null;
  profile: Profile | null;
  loading: boolean;
  supabase: SupabaseClient;
  signOut: () => Promise<void>;
  isAuthModalOpen: boolean;
  authModalRedirectPath: string | null;
  openAuthModal: (redirectPath?: string) => void;
  closeAuthModal: () => void;
};
const AuthContext = createContext<AuthContextType | undefined>(undefined);
export function AuthProvider({
  children
}: {
  children: React.ReactNode;
}) {
  if (stryMutAct_9fa48("298")) {
    {}
  } else {
    stryCov_9fa48("298");
    const [user, setUser] = useState<User | null>(null);
    const [profile, setProfile] = useState<Profile | null>(null);
    const [loading, setLoading] = useState(stryMutAct_9fa48("299") ? false : (stryCov_9fa48("299"), true));
    const [isAuthModalOpen, setIsAuthModalOpen] = useState(stryMutAct_9fa48("300") ? true : (stryCov_9fa48("300"), false));
    const [authModalRedirectPath, setAuthModalRedirectPath] = useState<string | null>(null);
    const supabaseUrl = stryMutAct_9fa48("303") ? process.env.NEXT_PUBLIC_SUPABASE_URL && "" : stryMutAct_9fa48("302") ? false : stryMutAct_9fa48("301") ? true : (stryCov_9fa48("301", "302", "303"), process.env.NEXT_PUBLIC_SUPABASE_URL || (stryMutAct_9fa48("304") ? "Stryker was here!" : (stryCov_9fa48("304"), "")));
    const supabaseKey = stryMutAct_9fa48("307") ? process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY && "" : stryMutAct_9fa48("306") ? false : stryMutAct_9fa48("305") ? true : (stryCov_9fa48("305", "306", "307"), process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || (stryMutAct_9fa48("308") ? "Stryker was here!" : (stryCov_9fa48("308"), "")));
    const [supabase] = useState(stryMutAct_9fa48("309") ? () => undefined : (stryCov_9fa48("309"), () => createBrowserClient(supabaseUrl, supabaseKey, stryMutAct_9fa48("310") ? {} : (stryCov_9fa48("310"), {
      global: stryMutAct_9fa48("311") ? {} : (stryCov_9fa48("311"), {
        fetch: (url, options) => {
          if (stryMutAct_9fa48("312")) {
            {}
          } else {
            stryCov_9fa48("312");
            const headers = (stryMutAct_9fa48("313") ? options.headers : (stryCov_9fa48("313"), options?.headers)) ? options.headers instanceof Headers ? options.headers : new Headers(options.headers as any) : new Headers();
            const auth = headers.get(stryMutAct_9fa48("314") ? "" : (stryCov_9fa48("314"), "Authorization"));
            if (stryMutAct_9fa48("318") ? auth.startsWith("Bearer ") : stryMutAct_9fa48("317") ? auth?.endsWith("Bearer ") : stryMutAct_9fa48("316") ? false : stryMutAct_9fa48("315") ? true : (stryCov_9fa48("315", "316", "317", "318"), auth?.startsWith(stryMutAct_9fa48("319") ? "" : (stryCov_9fa48("319"), "Bearer ")))) {
              if (stryMutAct_9fa48("320")) {
                {}
              } else {
                stryCov_9fa48("320");
                const token = stryMutAct_9fa48("321") ? auth : (stryCov_9fa48("321"), auth.substring(7));
                if (stryMutAct_9fa48("324") ? !token.includes(".") && token.split(".").length !== 3 : stryMutAct_9fa48("323") ? false : stryMutAct_9fa48("322") ? true : (stryCov_9fa48("322", "323", "324"), (stryMutAct_9fa48("325") ? token.includes(".") : (stryCov_9fa48("325"), !token.includes(stryMutAct_9fa48("326") ? "" : (stryCov_9fa48("326"), ".")))) || (stryMutAct_9fa48("328") ? token.split(".").length === 3 : stryMutAct_9fa48("327") ? false : (stryCov_9fa48("327", "328"), token.split(stryMutAct_9fa48("329") ? "" : (stryCov_9fa48("329"), ".")).length !== 3)))) {
                  if (stryMutAct_9fa48("330")) {
                    {}
                  } else {
                    stryCov_9fa48("330");
                    headers.delete(stryMutAct_9fa48("331") ? "" : (stryCov_9fa48("331"), "Authorization"));
                  }
                }
              }
            }
            const apikey = headers.get(stryMutAct_9fa48("332") ? "" : (stryCov_9fa48("332"), "apikey"));
            if (stryMutAct_9fa48("335") ? apikey || !apikey.includes(".") || apikey.split(".").length !== 3 : stryMutAct_9fa48("334") ? false : stryMutAct_9fa48("333") ? true : (stryCov_9fa48("333", "334", "335"), apikey && (stryMutAct_9fa48("337") ? !apikey.includes(".") && apikey.split(".").length !== 3 : stryMutAct_9fa48("336") ? true : (stryCov_9fa48("336", "337"), (stryMutAct_9fa48("338") ? apikey.includes(".") : (stryCov_9fa48("338"), !apikey.includes(stryMutAct_9fa48("339") ? "" : (stryCov_9fa48("339"), ".")))) || (stryMutAct_9fa48("341") ? apikey.split(".").length === 3 : stryMutAct_9fa48("340") ? false : (stryCov_9fa48("340", "341"), apikey.split(stryMutAct_9fa48("342") ? "" : (stryCov_9fa48("342"), ".")).length !== 3)))))) {
              if (stryMutAct_9fa48("343")) {
                {}
              } else {
                stryCov_9fa48("343");
                headers.delete(stryMutAct_9fa48("344") ? "" : (stryCov_9fa48("344"), "apikey"));
              }
            }
            const newOptions = stryMutAct_9fa48("345") ? {} : (stryCov_9fa48("345"), {
              ...options,
              headers
            });
            return fetch(url, newOptions);
          }
        }
      }),
      cookies: stryMutAct_9fa48("346") ? {} : (stryCov_9fa48("346"), {
        get(name: string) {
          if (stryMutAct_9fa48("347")) {
            {}
          } else {
            stryCov_9fa48("347");
            if (stryMutAct_9fa48("350") ? typeof document !== "undefined" : stryMutAct_9fa48("349") ? false : stryMutAct_9fa48("348") ? true : (stryCov_9fa48("348", "349", "350"), typeof document === (stryMutAct_9fa48("351") ? "" : (stryCov_9fa48("351"), "undefined")))) return stryMutAct_9fa48("352") ? "Stryker was here!" : (stryCov_9fa48("352"), "");
            const cookie = document.cookie.split(stryMutAct_9fa48("353") ? "" : (stryCov_9fa48("353"), "; ")).find(stryMutAct_9fa48("354") ? () => undefined : (stryCov_9fa48("354"), row => stryMutAct_9fa48("355") ? row.endsWith(`${name}=`) : (stryCov_9fa48("355"), row.startsWith(stryMutAct_9fa48("356") ? `` : (stryCov_9fa48("356"), `${name}=`)))));
            return cookie ? cookie.split(stryMutAct_9fa48("357") ? "" : (stryCov_9fa48("357"), "="))[1] : stryMutAct_9fa48("358") ? "Stryker was here!" : (stryCov_9fa48("358"), "");
          }
        },
        set(name: string, value: string, options: any) {
          if (stryMutAct_9fa48("359")) {
            {}
          } else {
            stryCov_9fa48("359");
            if (stryMutAct_9fa48("362") ? typeof document !== "undefined" : stryMutAct_9fa48("361") ? false : stryMutAct_9fa48("360") ? true : (stryCov_9fa48("360", "361", "362"), typeof document === (stryMutAct_9fa48("363") ? "" : (stryCov_9fa48("363"), "undefined")))) return;
            let cookieString = stryMutAct_9fa48("364") ? `` : (stryCov_9fa48("364"), `${name}=${value}`);
            if (stryMutAct_9fa48("366") ? false : stryMutAct_9fa48("365") ? true : (stryCov_9fa48("365", "366"), options.path)) cookieString += stryMutAct_9fa48("367") ? `` : (stryCov_9fa48("367"), `; path=${options.path}`);
            if (stryMutAct_9fa48("369") ? false : stryMutAct_9fa48("368") ? true : (stryCov_9fa48("368", "369"), options.maxAge)) cookieString += stryMutAct_9fa48("370") ? `` : (stryCov_9fa48("370"), `; max-age=${options.maxAge}`);
            if (stryMutAct_9fa48("372") ? false : stryMutAct_9fa48("371") ? true : (stryCov_9fa48("371", "372"), options.domain)) cookieString += stryMutAct_9fa48("373") ? `` : (stryCov_9fa48("373"), `; domain=${options.domain}`);
            if (stryMutAct_9fa48("375") ? false : stryMutAct_9fa48("374") ? true : (stryCov_9fa48("374", "375"), options.sameSite)) cookieString += stryMutAct_9fa48("376") ? `` : (stryCov_9fa48("376"), `; samesite=${options.sameSite}`);
            if (stryMutAct_9fa48("379") ? options.secure || window.location.protocol === "https:" : stryMutAct_9fa48("378") ? false : stryMutAct_9fa48("377") ? true : (stryCov_9fa48("377", "378", "379"), options.secure && (stryMutAct_9fa48("381") ? window.location.protocol !== "https:" : stryMutAct_9fa48("380") ? true : (stryCov_9fa48("380", "381"), window.location.protocol === (stryMutAct_9fa48("382") ? "" : (stryCov_9fa48("382"), "https:")))))) {
              if (stryMutAct_9fa48("383")) {
                {}
              } else {
                stryCov_9fa48("383");
                cookieString += stryMutAct_9fa48("384") ? "" : (stryCov_9fa48("384"), "; secure");
              }
            }
            document.cookie = cookieString;
          }
        },
        remove(name: string, options: any) {
          if (stryMutAct_9fa48("385")) {
            {}
          } else {
            stryCov_9fa48("385");
            if (stryMutAct_9fa48("388") ? typeof document !== "undefined" : stryMutAct_9fa48("387") ? false : stryMutAct_9fa48("386") ? true : (stryCov_9fa48("386", "387", "388"), typeof document === (stryMutAct_9fa48("389") ? "" : (stryCov_9fa48("389"), "undefined")))) return;
            let cookieString = stryMutAct_9fa48("390") ? `` : (stryCov_9fa48("390"), `${name}=; max-age=0`);
            if (stryMutAct_9fa48("392") ? false : stryMutAct_9fa48("391") ? true : (stryCov_9fa48("391", "392"), options.path)) cookieString += stryMutAct_9fa48("393") ? `` : (stryCov_9fa48("393"), `; path=${options.path}`);
            if (stryMutAct_9fa48("395") ? false : stryMutAct_9fa48("394") ? true : (stryCov_9fa48("394", "395"), options.domain)) cookieString += stryMutAct_9fa48("396") ? `` : (stryCov_9fa48("396"), `; domain=${options.domain}`);
            document.cookie = cookieString;
          }
        }
      })
    }))));
    useEffect(() => {
      if (stryMutAct_9fa48("397")) {
        {}
      } else {
        stryCov_9fa48("397");
        let isMounted = stryMutAct_9fa48("398") ? false : (stryCov_9fa48("398"), true);
        const fetchProfile = async (userId: string) => {
          if (stryMutAct_9fa48("399")) {
            {}
          } else {
            stryCov_9fa48("399");
            const {
              data: profileData
            } = await supabase.from(stryMutAct_9fa48("400") ? "" : (stryCov_9fa48("400"), "users")).select(stryMutAct_9fa48("401") ? "" : (stryCov_9fa48("401"), "username")).eq(stryMutAct_9fa48("402") ? "" : (stryCov_9fa48("402"), "auth_id"), userId).maybeSingle();
            if (stryMutAct_9fa48("405") ? isMounted || profileData : stryMutAct_9fa48("404") ? false : stryMutAct_9fa48("403") ? true : (stryCov_9fa48("403", "404", "405"), isMounted && profileData)) {
              if (stryMutAct_9fa48("406")) {
                {}
              } else {
                stryCov_9fa48("406");
                setProfile(profileData);
              }
            }
          }
        };
        const initUser = async () => {
          if (stryMutAct_9fa48("407")) {
            {}
          } else {
            stryCov_9fa48("407");
            try {
              if (stryMutAct_9fa48("408")) {
                {}
              } else {
                stryCov_9fa48("408");
                const {
                  data: {
                    user
                  }
                } = await supabase.auth.getUser();
                if (stryMutAct_9fa48("410") ? false : stryMutAct_9fa48("409") ? true : (stryCov_9fa48("409", "410"), isMounted)) {
                  if (stryMutAct_9fa48("411")) {
                    {}
                  } else {
                    stryCov_9fa48("411");
                    setUser(user);
                    setLoading(stryMutAct_9fa48("412") ? true : (stryCov_9fa48("412"), false));
                    if (stryMutAct_9fa48("414") ? false : stryMutAct_9fa48("413") ? true : (stryCov_9fa48("413", "414"), user)) {
                      if (stryMutAct_9fa48("415")) {
                        {}
                      } else {
                        stryCov_9fa48("415");
                        fetchProfile(user.id);
                      }
                    }
                  }
                }
              }
            } catch (error) {
              if (stryMutAct_9fa48("416")) {
                {}
              } else {
                stryCov_9fa48("416");
                console.error(stryMutAct_9fa48("417") ? "" : (stryCov_9fa48("417"), "Error fetching user:"), error);
                if (stryMutAct_9fa48("419") ? false : stryMutAct_9fa48("418") ? true : (stryCov_9fa48("418", "419"), isMounted)) {
                  if (stryMutAct_9fa48("420")) {
                    {}
                  } else {
                    stryCov_9fa48("420");
                    setLoading(stryMutAct_9fa48("421") ? true : (stryCov_9fa48("421"), false));
                  }
                }
              }
            }
          }
        };
        initUser();
        const {
          data: {
            subscription
          }
        } = supabase.auth.onAuthStateChange(async (_event, session) => {
          if (stryMutAct_9fa48("422")) {
            {}
          } else {
            stryCov_9fa48("422");
            const currentUser = stryMutAct_9fa48("423") ? session?.user && null : (stryCov_9fa48("423"), (stryMutAct_9fa48("424") ? session.user : (stryCov_9fa48("424"), session?.user)) ?? null);
            if (stryMutAct_9fa48("426") ? false : stryMutAct_9fa48("425") ? true : (stryCov_9fa48("425", "426"), isMounted)) {
              if (stryMutAct_9fa48("427")) {
                {}
              } else {
                stryCov_9fa48("427");
                setUser(currentUser);
                if (stryMutAct_9fa48("429") ? false : stryMutAct_9fa48("428") ? true : (stryCov_9fa48("428", "429"), currentUser)) {
                  if (stryMutAct_9fa48("430")) {
                    {}
                  } else {
                    stryCov_9fa48("430");
                    fetchProfile(currentUser.id);
                  }
                } else {
                  if (stryMutAct_9fa48("431")) {
                    {}
                  } else {
                    stryCov_9fa48("431");
                    setProfile(null);
                  }
                }
                setLoading(stryMutAct_9fa48("432") ? true : (stryCov_9fa48("432"), false));
              }
            }
          }
        });
        return () => {
          if (stryMutAct_9fa48("433")) {
            {}
          } else {
            stryCov_9fa48("433");
            isMounted = stryMutAct_9fa48("434") ? true : (stryCov_9fa48("434"), false);
            subscription.unsubscribe();
          }
        };
      }
    }, stryMutAct_9fa48("435") ? [] : (stryCov_9fa48("435"), [supabase]));
    const signOut = async () => {
      if (stryMutAct_9fa48("436")) {
        {}
      } else {
        stryCov_9fa48("436");
        await supabase.auth.signOut();
        setUser(null);
        setProfile(null);
      }
    };
    const openAuthModal = (redirectPath?: string) => {
      if (stryMutAct_9fa48("437")) {
        {}
      } else {
        stryCov_9fa48("437");
        setAuthModalRedirectPath(stryMutAct_9fa48("440") ? redirectPath && null : stryMutAct_9fa48("439") ? false : stryMutAct_9fa48("438") ? true : (stryCov_9fa48("438", "439", "440"), redirectPath || null));
        setIsAuthModalOpen(stryMutAct_9fa48("441") ? false : (stryCov_9fa48("441"), true));
      }
    };
    const closeAuthModal = () => {
      if (stryMutAct_9fa48("442")) {
        {}
      } else {
        stryCov_9fa48("442");
        setIsAuthModalOpen(stryMutAct_9fa48("443") ? true : (stryCov_9fa48("443"), false));
        setAuthModalRedirectPath(null);
      }
    };
    return <AuthContext.Provider value={stryMutAct_9fa48("444") ? {} : (stryCov_9fa48("444"), {
      user,
      profile,
      loading,
      supabase,
      signOut,
      isAuthModalOpen,
      authModalRedirectPath,
      openAuthModal,
      closeAuthModal
    })}>
      {children}
    </AuthContext.Provider>;
  }
}
export function useAuth() {
  if (stryMutAct_9fa48("445")) {
    {}
  } else {
    stryCov_9fa48("445");
    const context = useContext(AuthContext);
    if (stryMutAct_9fa48("448") ? context !== undefined : stryMutAct_9fa48("447") ? false : stryMutAct_9fa48("446") ? true : (stryCov_9fa48("446", "447", "448"), context === undefined)) {
      if (stryMutAct_9fa48("449")) {
        {}
      } else {
        stryCov_9fa48("449");
        throw new Error(stryMutAct_9fa48("450") ? "" : (stryCov_9fa48("450"), "useAuth must be used within an AuthProvider"));
      }
    }
    return context;
  }
}