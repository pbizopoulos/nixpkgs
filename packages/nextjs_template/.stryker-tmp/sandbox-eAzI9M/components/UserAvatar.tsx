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
export function getAvatarColor(str: string): string {
  if (stryMutAct_9fa48("485")) {
    {}
  } else {
    stryCov_9fa48("485");
    let hash = 0;
    for (let charIndex = 0; stryMutAct_9fa48("488") ? charIndex >= str.length : stryMutAct_9fa48("487") ? charIndex <= str.length : stryMutAct_9fa48("486") ? false : (stryCov_9fa48("486", "487", "488"), charIndex < str.length); stryMutAct_9fa48("489") ? charIndex-- : (stryCov_9fa48("489"), charIndex++)) {
      if (stryMutAct_9fa48("490")) {
        {}
      } else {
        stryCov_9fa48("490");
        hash = stryMutAct_9fa48("491") ? str.charCodeAt(charIndex) - ((hash << 5) - hash) : (stryCov_9fa48("491"), str.charCodeAt(charIndex) + (stryMutAct_9fa48("492") ? (hash << 5) + hash : (stryCov_9fa48("492"), (hash << 5) - hash)));
      }
    }
    const hue = Math.abs(stryMutAct_9fa48("493") ? hash * 360 : (stryCov_9fa48("493"), hash % 360));
    return stryMutAct_9fa48("494") ? `` : (stryCov_9fa48("494"), `hsl(${hue}, 70%, 50%)`);
  }
}
interface UserAvatarProps {
  username?: string | null;
  size?: number;
  className?: string;
}
export default function UserAvatar({
  username,
  size = 32,
  className = stryMutAct_9fa48("495") ? "Stryker was here!" : (stryCov_9fa48("495"), "")
}: UserAvatarProps) {
  if (stryMutAct_9fa48("496")) {
    {}
  } else {
    stryCov_9fa48("496");
    const initials = stryMutAct_9fa48("499") ? username.slice(0, 2).toUpperCase() : stryMutAct_9fa48("498") ? username.toUpperCase() : stryMutAct_9fa48("497") ? username?.slice(0, 2).toLowerCase() : (stryCov_9fa48("497", "498", "499"), username?.slice(0, 2).toUpperCase());
    const bgColor = username ? getAvatarColor(username) : stryMutAct_9fa48("500") ? "" : (stryCov_9fa48("500"), "#e5e5e5");
    return <div className={className} style={stryMutAct_9fa48("501") ? {} : (stryCov_9fa48("501"), {
      width: size,
      height: size,
      backgroundColor: bgColor,
      borderRadius: stryMutAct_9fa48("502") ? "" : (stryCov_9fa48("502"), "50%"),
      display: stryMutAct_9fa48("503") ? "" : (stryCov_9fa48("503"), "flex"),
      alignItems: stryMutAct_9fa48("504") ? "" : (stryCov_9fa48("504"), "center"),
      justifyContent: stryMutAct_9fa48("505") ? "" : (stryCov_9fa48("505"), "center"),
      overflow: stryMutAct_9fa48("506") ? "" : (stryCov_9fa48("506"), "hidden"),
      flexShrink: 0
    })}>
      {username ? <span style={stryMutAct_9fa48("507") ? {} : (stryCov_9fa48("507"), {
        color: stryMutAct_9fa48("508") ? "" : (stryCov_9fa48("508"), "#fff"),
        fontWeight: stryMutAct_9fa48("509") ? "" : (stryCov_9fa48("509"), "500"),
        fontSize: stryMutAct_9fa48("510") ? "" : (stryCov_9fa48("510"), "0.75rem"),
        lineHeight: 1
      })}>
          {initials}
        </span> : <div style={stryMutAct_9fa48("511") ? {} : (stryCov_9fa48("511"), {
        backgroundColor: stryMutAct_9fa48("512") ? "" : (stryCov_9fa48("512"), "#f3f4f6"),
        width: stryMutAct_9fa48("513") ? "" : (stryCov_9fa48("513"), "100%"),
        height: stryMutAct_9fa48("514") ? "" : (stryCov_9fa48("514"), "100%")
      })} />}
    </div>;
  }
}