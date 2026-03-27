import { beforeEach, describe, expect, it, vi } from "vitest";
type QueryState = {
  deleteCalls: string[];
  firstResults: unknown[];
  insertCalls: Array<Record<string, unknown>>;
  whereCalls: Array<{ column: string; value: unknown }>;
};
function createDbMock(state: QueryState) {
  const createQueryBuilder = () => ({
    select: vi.fn().mockReturnThis(),
    where: vi.fn((column: string, value: unknown) => {
      state.whereCalls.push({ column, value });
      return createQueryBuilder();
    }),
    first: vi.fn(async () => state.firstResults.shift()),
    delete: vi.fn(async () => {
      const lastWhere = state.whereCalls.at(-1);
      state.deleteCalls.push(String(lastWhere?.value ?? ""));
      return 1;
    }),
  });
  return {
    from: vi.fn(() => createQueryBuilder()),
    table: vi.fn(() => ({
      insert: vi.fn(async (payload: Record<string, unknown>) => {
        state.insertCalls.push(payload);
      }),
    })),
  };
}
function createHttpContext(username: unknown) {
  return {
    params: { username },
    request: {
      input: vi.fn(() => username),
    },
    response: {
      status: vi.fn(),
    },
  };
}
async function loadController(state: QueryState) {
  vi.resetModules();
  vi.doMock("@adonisjs/lucid/services/db", () => ({
    default: createDbMock(state),
  }));
  return import("../../app/controllers/users_controller.js");
}
describe("UsersController", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });
  it("rejects invalid usernames before touching the database", async () => {
    const state: QueryState = {
      deleteCalls: [],
      firstResults: [],
      insertCalls: [],
      whereCalls: [],
    };
    const { default: UsersController } = await loadController(state);
    const context = createHttpContext("AB");
    const result = await new UsersController().store(context as never);
    expect(context.response.status).toHaveBeenCalledWith(422);
    expect(result).toEqual({
      error: "username must be a valid lowercase slug",
    });
    expect(state.whereCalls).toHaveLength(0);
    expect(state.insertCalls).toHaveLength(0);
  });
  it("returns a conflict when the username already exists", async () => {
    const state: QueryState = {
      deleteCalls: [],
      firstResults: [{ id: 1, username: "starter-user" }],
      insertCalls: [],
      whereCalls: [],
    };
    const { default: UsersController } = await loadController(state);
    const context = createHttpContext("starter-user");
    const result = await new UsersController().store(context as never);
    expect(context.response.status).toHaveBeenCalledWith(409);
    expect(result).toEqual({ error: "username already exists" });
    expect(state.insertCalls).toHaveLength(0);
  });
  it("creates and returns a new username", async () => {
    const state: QueryState = {
      deleteCalls: [],
      firstResults: [undefined, { id: 2, username: "starter-user" }],
      insertCalls: [],
      whereCalls: [],
    };
    const { default: UsersController } = await loadController(state);
    const context = createHttpContext("starter-user");
    const result = await new UsersController().store(context as never);
    expect(context.response.status).toHaveBeenCalledWith(201);
    expect(state.insertCalls).toEqual([{ username: "starter-user" }]);
    expect(result).toEqual({ user: { id: 2, username: "starter-user" } });
  });
  it("rejects invalid usernames during deletion", async () => {
    const state: QueryState = {
      deleteCalls: [],
      firstResults: [],
      insertCalls: [],
      whereCalls: [],
    };
    const { default: UsersController } = await loadController(state);
    const context = createHttpContext(42);
    const result = await new UsersController().destroy(context as never);
    expect(context.response.status).toHaveBeenCalledWith(422);
    expect(result).toEqual({
      error: "username must be a valid lowercase slug",
    });
    expect(state.deleteCalls).toHaveLength(0);
  });
  it("returns not found when deleting a missing username", async () => {
    const state: QueryState = {
      deleteCalls: [],
      firstResults: [undefined],
      insertCalls: [],
      whereCalls: [],
    };
    const { default: UsersController } = await loadController(state);
    const context = createHttpContext("starter-user");
    const result = await new UsersController().destroy(context as never);
    expect(context.response.status).toHaveBeenCalledWith(404);
    expect(result).toEqual({ error: "user not found" });
    expect(state.deleteCalls).toHaveLength(0);
  });
  it("deletes an existing username", async () => {
    const state: QueryState = {
      deleteCalls: [],
      firstResults: [{ id: 3 }],
      insertCalls: [],
      whereCalls: [],
    };
    const { default: UsersController } = await loadController(state);
    const context = createHttpContext("starter-user");
    const result = await new UsersController().destroy(context as never);
    expect(state.deleteCalls).toEqual(["starter-user"]);
    expect(result).toEqual({ deleted: true, username: "starter-user" });
  });
});
