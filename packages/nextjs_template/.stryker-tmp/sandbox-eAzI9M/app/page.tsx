// @ts-nocheck
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
import { createClient } from "../lib/supabase";
export const dynamic = stryMutAct_9fa48("51") ? "" : (stryCov_9fa48("51"), "force-dynamic");
export default async function Page() {
  if (stryMutAct_9fa48("52")) {
    {}
  } else {
    stryCov_9fa48("52");
    const supabase = await createClient();
    const {
      data: {
        user
      }
    } = await supabase.auth.getUser();
    return <main>
      <div style={stryMutAct_9fa48("53") ? {} : (stryCov_9fa48("53"), {
        textAlign: stryMutAct_9fa48("54") ? "" : (stryCov_9fa48("54"), "center"),
        padding: stryMutAct_9fa48("55") ? "" : (stryCov_9fa48("55"), "5rem 0")
      })}>
        <h1>Welcome to the Minimal Application</h1>
        <p>A simple Next.js and Supabase boilerplate.</p>
        {user ? <div style={stryMutAct_9fa48("56") ? {} : (stryCov_9fa48("56"), {
          backgroundColor: stryMutAct_9fa48("57") ? "" : (stryCov_9fa48("57"), "#f9fafb"),
          padding: stryMutAct_9fa48("58") ? "" : (stryCov_9fa48("58"), "2rem"),
          borderRadius: stryMutAct_9fa48("59") ? "" : (stryCov_9fa48("59"), "1rem"),
          border: stryMutAct_9fa48("60") ? "" : (stryCov_9fa48("60"), "1px solid #f3f4f6")
        })}>
            <p style={stryMutAct_9fa48("61") ? {} : (stryCov_9fa48("61"), {
            fontWeight: stryMutAct_9fa48("62") ? "" : (stryCov_9fa48("62"), "500")
          })}>
              You are logged in as {user.email}
            </p>
          </div> : <p style={stryMutAct_9fa48("63") ? {} : (stryCov_9fa48("63"), {
          color: stryMutAct_9fa48("64") ? "" : (stryCov_9fa48("64"), "#9ca3af")
        })}>
            Please sign in to access your dashboard.
          </p>}
      </div>
    </main>;
  }
}