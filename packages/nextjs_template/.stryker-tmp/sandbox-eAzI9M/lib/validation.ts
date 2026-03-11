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
export const SLUG_MAX_LENGTH = 39;
export function isValidUsername(username: string): boolean {
  if (stryMutAct_9fa48("515")) {
    {}
  } else {
    stryCov_9fa48("515");
    if (stryMutAct_9fa48("518") ? false : stryMutAct_9fa48("517") ? true : stryMutAct_9fa48("516") ? username : (stryCov_9fa48("516", "517", "518"), !username)) return stryMutAct_9fa48("519") ? true : (stryCov_9fa48("519"), false);
    if (stryMutAct_9fa48("522") ? username.length < 3 && username.length > SLUG_MAX_LENGTH : stryMutAct_9fa48("521") ? false : stryMutAct_9fa48("520") ? true : (stryCov_9fa48("520", "521", "522"), (stryMutAct_9fa48("525") ? username.length >= 3 : stryMutAct_9fa48("524") ? username.length <= 3 : stryMutAct_9fa48("523") ? false : (stryCov_9fa48("523", "524", "525"), username.length < 3)) || (stryMutAct_9fa48("528") ? username.length <= SLUG_MAX_LENGTH : stryMutAct_9fa48("527") ? username.length >= SLUG_MAX_LENGTH : stryMutAct_9fa48("526") ? false : (stryCov_9fa48("526", "527", "528"), username.length > SLUG_MAX_LENGTH)))) return stryMutAct_9fa48("529") ? true : (stryCov_9fa48("529"), false);
    return (stryMutAct_9fa48("533") ? /^[^a-z0-9-]+$/ : stryMutAct_9fa48("532") ? /^[a-z0-9-]$/ : stryMutAct_9fa48("531") ? /^[a-z0-9-]+/ : stryMutAct_9fa48("530") ? /[a-z0-9-]+$/ : (stryCov_9fa48("530", "531", "532", "533"), /^[a-z0-9-]+$/)).test(username);
  }
}