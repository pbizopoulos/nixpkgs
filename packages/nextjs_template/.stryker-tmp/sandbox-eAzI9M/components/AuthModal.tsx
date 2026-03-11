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
import { usePathname, useRouter } from "next/navigation";
import { useEffect, useRef } from "react";
import AuthForm from "./AuthForm";
import { useAuth } from "./AuthProvider";
export default function AuthModal() {
  if (stryMutAct_9fa48("233")) {
    {}
  } else {
    stryCov_9fa48("233");
    const {
      isAuthModalOpen,
      closeAuthModal,
      user,
      authModalRedirectPath
    } = useAuth();
    const modalRef = useRef<HTMLDivElement>(null);
    const pathname = usePathname();
    const router = useRouter();
    const handleClose = () => {
      if (stryMutAct_9fa48("234")) {
        {}
      } else {
        stryCov_9fa48("234");
        closeAuthModal();
        const isProtectedRoute = stryMutAct_9fa48("235") ? pathname.startsWith("/edit") : (stryCov_9fa48("235"), pathname.endsWith(stryMutAct_9fa48("236") ? "" : (stryCov_9fa48("236"), "/edit")));
        if (stryMutAct_9fa48("239") ? isProtectedRoute || !user : stryMutAct_9fa48("238") ? false : stryMutAct_9fa48("237") ? true : (stryCov_9fa48("237", "238", "239"), isProtectedRoute && (stryMutAct_9fa48("240") ? user : (stryCov_9fa48("240"), !user)))) {
          if (stryMutAct_9fa48("241")) {
            {}
          } else {
            stryCov_9fa48("241");
            router.push(stryMutAct_9fa48("242") ? "" : (stryCov_9fa48("242"), "/"));
          }
        }
      }
    };
    const handleSuccess = () => {
      if (stryMutAct_9fa48("243")) {
        {}
      } else {
        stryCov_9fa48("243");
        closeAuthModal();
        if (stryMutAct_9fa48("245") ? false : stryMutAct_9fa48("244") ? true : (stryCov_9fa48("244", "245"), authModalRedirectPath)) {
          if (stryMutAct_9fa48("246")) {
            {}
          } else {
            stryCov_9fa48("246");
            router.push(authModalRedirectPath);
          }
        }
      }
    };
    useEffect(() => {
      if (stryMutAct_9fa48("247")) {
        {}
      } else {
        stryCov_9fa48("247");
        const handleClickOutside = (event: MouseEvent) => {
          if (stryMutAct_9fa48("248")) {
            {}
          } else {
            stryCov_9fa48("248");
            if (stryMutAct_9fa48("251") ? modalRef.current || !modalRef.current.contains(event.target as Node) : stryMutAct_9fa48("250") ? false : stryMutAct_9fa48("249") ? true : (stryCov_9fa48("249", "250", "251"), modalRef.current && (stryMutAct_9fa48("252") ? modalRef.current.contains(event.target as Node) : (stryCov_9fa48("252"), !modalRef.current.contains(event.target as Node))))) {
              if (stryMutAct_9fa48("253")) {
                {}
              } else {
                stryCov_9fa48("253");
                handleClose();
              }
            }
          }
        };
        const handleEscape = (event: KeyboardEvent) => {
          if (stryMutAct_9fa48("254")) {
            {}
          } else {
            stryCov_9fa48("254");
            if (stryMutAct_9fa48("257") ? event.key !== "Escape" : stryMutAct_9fa48("256") ? false : stryMutAct_9fa48("255") ? true : (stryCov_9fa48("255", "256", "257"), event.key === (stryMutAct_9fa48("258") ? "" : (stryCov_9fa48("258"), "Escape")))) {
              if (stryMutAct_9fa48("259")) {
                {}
              } else {
                stryCov_9fa48("259");
                handleClose();
              }
            }
          }
        };
        if (stryMutAct_9fa48("261") ? false : stryMutAct_9fa48("260") ? true : (stryCov_9fa48("260", "261"), isAuthModalOpen)) {
          if (stryMutAct_9fa48("262")) {
            {}
          } else {
            stryCov_9fa48("262");
            document.addEventListener(stryMutAct_9fa48("263") ? "" : (stryCov_9fa48("263"), "mousedown"), handleClickOutside);
            document.addEventListener(stryMutAct_9fa48("264") ? "" : (stryCov_9fa48("264"), "keydown"), handleEscape);
            document.body.style.overflow = stryMutAct_9fa48("265") ? "" : (stryCov_9fa48("265"), "hidden");
          }
        }
        return () => {
          if (stryMutAct_9fa48("266")) {
            {}
          } else {
            stryCov_9fa48("266");
            document.removeEventListener(stryMutAct_9fa48("267") ? "" : (stryCov_9fa48("267"), "mousedown"), handleClickOutside);
            document.removeEventListener(stryMutAct_9fa48("268") ? "" : (stryCov_9fa48("268"), "keydown"), handleEscape);
            document.body.style.overflow = stryMutAct_9fa48("269") ? "" : (stryCov_9fa48("269"), "unset");
          }
        };
      }
    }, stryMutAct_9fa48("270") ? [] : (stryCov_9fa48("270"), [isAuthModalOpen, handleClose]));
    if (stryMutAct_9fa48("273") ? false : stryMutAct_9fa48("272") ? true : stryMutAct_9fa48("271") ? isAuthModalOpen : (stryCov_9fa48("271", "272", "273"), !isAuthModalOpen)) return null;
    return <div style={stryMutAct_9fa48("274") ? {} : (stryCov_9fa48("274"), {
      position: stryMutAct_9fa48("275") ? "" : (stryCov_9fa48("275"), "fixed"),
      inset: 0,
      zIndex: 50,
      display: stryMutAct_9fa48("276") ? "" : (stryCov_9fa48("276"), "flex"),
      alignItems: stryMutAct_9fa48("277") ? "" : (stryCov_9fa48("277"), "center"),
      justifyContent: stryMutAct_9fa48("278") ? "" : (stryCov_9fa48("278"), "center"),
      padding: stryMutAct_9fa48("279") ? "" : (stryCov_9fa48("279"), "1rem"),
      backgroundColor: stryMutAct_9fa48("280") ? "" : (stryCov_9fa48("280"), "rgba(0,0,0,0.5)")
    })}>
      <div ref={modalRef} style={stryMutAct_9fa48("281") ? {} : (stryCov_9fa48("281"), {
        position: stryMutAct_9fa48("282") ? "" : (stryCov_9fa48("282"), "relative"),
        width: stryMutAct_9fa48("283") ? "" : (stryCov_9fa48("283"), "100%"),
        maxWidth: stryMutAct_9fa48("284") ? "" : (stryCov_9fa48("284"), "24rem"),
        backgroundColor: stryMutAct_9fa48("285") ? "" : (stryCov_9fa48("285"), "#fff"),
        borderRadius: stryMutAct_9fa48("286") ? "" : (stryCov_9fa48("286"), "1rem"),
        padding: stryMutAct_9fa48("287") ? "" : (stryCov_9fa48("287"), "2rem"),
        boxShadow: stryMutAct_9fa48("288") ? "" : (stryCov_9fa48("288"), "0 25px 50px -12px rgba(0,0,0,0.25)")
      })}>
        <button type="button" onClick={handleClose} style={stryMutAct_9fa48("289") ? {} : (stryCov_9fa48("289"), {
          position: stryMutAct_9fa48("290") ? "" : (stryCov_9fa48("290"), "absolute"),
          top: stryMutAct_9fa48("291") ? "" : (stryCov_9fa48("291"), "1rem"),
          right: stryMutAct_9fa48("292") ? "" : (stryCov_9fa48("292"), "1rem"),
          background: stryMutAct_9fa48("293") ? "" : (stryCov_9fa48("293"), "none"),
          border: stryMutAct_9fa48("294") ? "" : (stryCov_9fa48("294"), "none"),
          fontSize: stryMutAct_9fa48("295") ? "" : (stryCov_9fa48("295"), "1.5rem"),
          cursor: stryMutAct_9fa48("296") ? "" : (stryCov_9fa48("296"), "pointer"),
          color: stryMutAct_9fa48("297") ? "" : (stryCov_9fa48("297"), "#9ca3af")
        })} aria-label="Close modal">
          ×
        </button>
        <AuthForm onSuccess={handleSuccess} />
      </div>
    </div>;
  }
}