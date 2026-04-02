import "@adonisjs/core/types/http";
type ParamValue = string | number | bigint | boolean;
export type ScannedRoutes = {
  ALL: {
    home: { paramsTuple?: []; params?: {} };
    "register.show": { paramsTuple?: []; params?: {} };
    "register.store": { paramsTuple?: []; params?: {} };
    "login.show": { paramsTuple?: []; params?: {} };
    "login.store": { paramsTuple?: []; params?: {} };
    logout: { paramsTuple?: []; params?: {} };
    "account.delete": { paramsTuple?: []; params?: {} };
    "dashboard.show": { paramsTuple?: []; params?: {} };
    health: { paramsTuple?: []; params?: {} };
  };
  GET: {
    home: { paramsTuple?: []; params?: {} };
    "register.show": { paramsTuple?: []; params?: {} };
    "login.show": { paramsTuple?: []; params?: {} };
    "dashboard.show": { paramsTuple?: []; params?: {} };
    health: { paramsTuple?: []; params?: {} };
  };
  HEAD: {
    home: { paramsTuple?: []; params?: {} };
    "register.show": { paramsTuple?: []; params?: {} };
    "login.show": { paramsTuple?: []; params?: {} };
    "dashboard.show": { paramsTuple?: []; params?: {} };
    health: { paramsTuple?: []; params?: {} };
  };
  POST: {
    "register.store": { paramsTuple?: []; params?: {} };
    "login.store": { paramsTuple?: []; params?: {} };
    logout: { paramsTuple?: []; params?: {} };
    "account.delete": { paramsTuple?: []; params?: {} };
  };
};
declare module "@adonisjs/core/types/http" {
  export interface RoutesList extends ScannedRoutes {}
}
