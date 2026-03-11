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
import { notFound } from "next/navigation";
import { createClient } from "../../lib/supabase";
export const dynamic = stryMutAct_9fa48("0") ? "" : (stryCov_9fa48("0"), "force-dynamic");
export default async function Page({
  params
}: {
  params: Promise<{
    username: string;
  }>;
}) {
  if (stryMutAct_9fa48("1")) {
    {}
  } else {
    stryCov_9fa48("1");
    const {
      username
    } = await params;
    const supabase = await createClient();
    const {
      data: userProfile
    } = await supabase.from(stryMutAct_9fa48("2") ? "" : (stryCov_9fa48("2"), "users")).select(stryMutAct_9fa48("3") ? "" : (stryCov_9fa48("3"), "id, username, full_name")).eq(stryMutAct_9fa48("4") ? "" : (stryCov_9fa48("4"), "username"), username).maybeSingle();
    if (stryMutAct_9fa48("7") ? false : stryMutAct_9fa48("6") ? true : stryMutAct_9fa48("5") ? userProfile : (stryCov_9fa48("5", "6", "7"), !userProfile)) {
      if (stryMutAct_9fa48("8")) {
        {}
      } else {
        stryCov_9fa48("8");
        notFound();
        return null;
      }
    }
    return <div style={stryMutAct_9fa48("9") ? {} : (stryCov_9fa48("9"), {
      padding: stryMutAct_9fa48("10") ? "" : (stryCov_9fa48("10"), "2rem"),
      maxWidth: stryMutAct_9fa48("11") ? "" : (stryCov_9fa48("11"), "64rem"),
      margin: stryMutAct_9fa48("12") ? "" : (stryCov_9fa48("12"), "0 auto")
    })}>
      <div style={stryMutAct_9fa48("13") ? {} : (stryCov_9fa48("13"), {
        display: stryMutAct_9fa48("14") ? "" : (stryCov_9fa48("14"), "flex"),
        alignItems: stryMutAct_9fa48("15") ? "" : (stryCov_9fa48("15"), "center"),
        gap: stryMutAct_9fa48("16") ? "" : (stryCov_9fa48("16"), "1.5rem"),
        marginBottom: stryMutAct_9fa48("17") ? "" : (stryCov_9fa48("17"), "2rem"),
        paddingBottom: stryMutAct_9fa48("18") ? "" : (stryCov_9fa48("18"), "2rem"),
        borderBottom: stryMutAct_9fa48("19") ? "" : (stryCov_9fa48("19"), "1px solid #f3f4f6")
      })}>
        <div style={stryMutAct_9fa48("20") ? {} : (stryCov_9fa48("20"), {
          width: stryMutAct_9fa48("21") ? "" : (stryCov_9fa48("21"), "5rem"),
          height: stryMutAct_9fa48("22") ? "" : (stryCov_9fa48("22"), "5rem"),
          backgroundColor: stryMutAct_9fa48("23") ? "" : (stryCov_9fa48("23"), "#f3f4f6"),
          borderRadius: stryMutAct_9fa48("24") ? "" : (stryCov_9fa48("24"), "50%"),
          display: stryMutAct_9fa48("25") ? "" : (stryCov_9fa48("25"), "flex"),
          alignItems: stryMutAct_9fa48("26") ? "" : (stryCov_9fa48("26"), "center"),
          justifyContent: stryMutAct_9fa48("27") ? "" : (stryCov_9fa48("27"), "center"),
          fontSize: stryMutAct_9fa48("28") ? "" : (stryCov_9fa48("28"), "1.5rem"),
          fontWeight: stryMutAct_9fa48("29") ? "" : (stryCov_9fa48("29"), "bold"),
          color: stryMutAct_9fa48("30") ? "" : (stryCov_9fa48("30"), "#9ca3af")
        })}>
          {stryMutAct_9fa48("33") ? userProfile.username[0]?.toUpperCase() : stryMutAct_9fa48("32") ? userProfile.username?.[0].toUpperCase() : stryMutAct_9fa48("31") ? userProfile.username?.[0]?.toLowerCase() : (stryCov_9fa48("31", "32", "33"), userProfile.username?.[0]?.toUpperCase())}
        </div>
        <div>
          <h1 style={stryMutAct_9fa48("34") ? {} : (stryCov_9fa48("34"), {
            fontSize: stryMutAct_9fa48("35") ? "" : (stryCov_9fa48("35"), "1.875rem"),
            fontWeight: stryMutAct_9fa48("36") ? "" : (stryCov_9fa48("36"), "bold")
          })}>
            {userProfile.username}
          </h1>
          {stryMutAct_9fa48("39") ? userProfile.full_name || <p style={{
            color: "#6b7280"
          }}>{userProfile.full_name}</p> : stryMutAct_9fa48("38") ? false : stryMutAct_9fa48("37") ? true : (stryCov_9fa48("37", "38", "39"), userProfile.full_name && <p style={stryMutAct_9fa48("40") ? {} : (stryCov_9fa48("40"), {
            color: stryMutAct_9fa48("41") ? "" : (stryCov_9fa48("41"), "#6b7280")
          })}>{userProfile.full_name}</p>)}
        </div>
      </div>

      <div style={stryMutAct_9fa48("42") ? {} : (stryCov_9fa48("42"), {
        backgroundColor: stryMutAct_9fa48("43") ? "" : (stryCov_9fa48("43"), "#f9fafb"),
        borderRadius: stryMutAct_9fa48("44") ? "" : (stryCov_9fa48("44"), "1rem"),
        padding: stryMutAct_9fa48("45") ? "" : (stryCov_9fa48("45"), "2rem"),
        border: stryMutAct_9fa48("46") ? "" : (stryCov_9fa48("46"), "1px solid #f3f4f6")
      })}>
        <p style={stryMutAct_9fa48("47") ? {} : (stryCov_9fa48("47"), {
          color: stryMutAct_9fa48("48") ? "" : (stryCov_9fa48("48"), "#6b7280"),
          textAlign: stryMutAct_9fa48("49") ? "" : (stryCov_9fa48("49"), "center"),
          fontStyle: stryMutAct_9fa48("50") ? "" : (stryCov_9fa48("50"), "italic")
        })}>
          This is a minimal profile page.
        </p>
      </div>
    </div>;
  }
}