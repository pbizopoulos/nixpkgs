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
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useRef, useState } from "react";
import { useAuth } from "./AuthProvider";
import UserAvatar from "./UserAvatar";
export default function Header() {
  if (stryMutAct_9fa48("451")) {
    {}
  } else {
    stryCov_9fa48("451");
    const router = useRouter();
    const {
      user,
      profile,
      signOut,
      openAuthModal
    } = useAuth();
    const [dropdownOpen, setDropdownOpen] = useState(stryMutAct_9fa48("452") ? true : (stryCov_9fa48("452"), false));
    const dropdownRef = useRef<HTMLDivElement>(null);
    useEffect(() => {
      if (stryMutAct_9fa48("453")) {
        {}
      } else {
        stryCov_9fa48("453");
        const handleClickOutside = (e: MouseEvent) => {
          if (stryMutAct_9fa48("454")) {
            {}
          } else {
            stryCov_9fa48("454");
            if (stryMutAct_9fa48("457") ? dropdownRef.current || !dropdownRef.current.contains(e.target as Node) : stryMutAct_9fa48("456") ? false : stryMutAct_9fa48("455") ? true : (stryCov_9fa48("455", "456", "457"), dropdownRef.current && (stryMutAct_9fa48("458") ? dropdownRef.current.contains(e.target as Node) : (stryCov_9fa48("458"), !dropdownRef.current.contains(e.target as Node))))) {
              if (stryMutAct_9fa48("459")) {
                {}
              } else {
                stryCov_9fa48("459");
                setDropdownOpen(stryMutAct_9fa48("460") ? true : (stryCov_9fa48("460"), false));
              }
            }
          }
        };
        document.addEventListener(stryMutAct_9fa48("461") ? "" : (stryCov_9fa48("461"), "mousedown"), handleClickOutside);
        return stryMutAct_9fa48("462") ? () => undefined : (stryCov_9fa48("462"), () => document.removeEventListener(stryMutAct_9fa48("463") ? "" : (stryCov_9fa48("463"), "mousedown"), handleClickOutside));
      }
    }, stryMutAct_9fa48("464") ? ["Stryker was here"] : (stryCov_9fa48("464"), []));
    const handleSignOut = async () => {
      if (stryMutAct_9fa48("465")) {
        {}
      } else {
        stryCov_9fa48("465");
        setDropdownOpen(stryMutAct_9fa48("466") ? true : (stryCov_9fa48("466"), false));
        await signOut();
        router.push(stryMutAct_9fa48("467") ? "" : (stryCov_9fa48("467"), "/"));
      }
    };
    const [mounted, setMounted] = useState(stryMutAct_9fa48("468") ? true : (stryCov_9fa48("468"), false));
    useEffect(() => {
      if (stryMutAct_9fa48("469")) {
        {}
      } else {
        stryCov_9fa48("469");
        setMounted(stryMutAct_9fa48("470") ? false : (stryCov_9fa48("470"), true));
      }
    }, stryMutAct_9fa48("471") ? ["Stryker was here"] : (stryCov_9fa48("471"), []));
    if (stryMutAct_9fa48("474") ? false : stryMutAct_9fa48("473") ? true : stryMutAct_9fa48("472") ? mounted : (stryCov_9fa48("472", "473", "474"), !mounted)) {
      if (stryMutAct_9fa48("475")) {
        {}
      } else {
        stryCov_9fa48("475");
        return <header>
        <div>
          <div>
            <span>Minimal Application</span>
          </div>
        </div>
        <div>
          <div />
        </div>
      </header>;
      }
    }
    return <header>
      <div>
        <Link href="/" aria-label="Home">
          <span>Minimal App</span>
        </Link>
      </div>

      <div>
        {user ? <div ref={dropdownRef}>
            <button type="button" onClick={stryMutAct_9fa48("476") ? () => undefined : (stryCov_9fa48("476"), () => setDropdownOpen(stryMutAct_9fa48("477") ? dropdownOpen : (stryCov_9fa48("477"), !dropdownOpen)))} aria-label="Open user menu" aria-expanded={dropdownOpen} aria-haspopup="true">
              <UserAvatar username={stryMutAct_9fa48("478") ? profile?.username && null : (stryCov_9fa48("478"), (stryMutAct_9fa48("479") ? profile.username : (stryCov_9fa48("479"), profile?.username)) ?? null)} size={28} />
            </button>

            {stryMutAct_9fa48("482") ? dropdownOpen || <div role="menu">
                <div>
                  Signed in as <br />
                  <span>{profile?.username}</span>
                </div>
                <button type="button" onClick={handleSignOut} role="menuitem">
                  Sign Out
                </button>
              </div> : stryMutAct_9fa48("481") ? false : stryMutAct_9fa48("480") ? true : (stryCov_9fa48("480", "481", "482"), dropdownOpen && <div role="menu">
                <div>
                  Signed in as <br />
                  <span>{stryMutAct_9fa48("483") ? profile.username : (stryCov_9fa48("483"), profile?.username)}</span>
                </div>
                <button type="button" onClick={handleSignOut} role="menuitem">
                  Sign Out
                </button>
              </div>)}
          </div> : <button type="button" onClick={stryMutAct_9fa48("484") ? () => undefined : (stryCov_9fa48("484"), () => openAuthModal())} aria-label="Sign in to your account">
            Sign In
          </button>}
      </div>
    </header>;
  }
}