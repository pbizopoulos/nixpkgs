import { beforeEach, describe, expect, it, vi } from "vitest";
type TestState = {
  deleteCalls: string[];
  findResults: unknown[];
  createCalls: Array<Record<string, unknown>>;
};
function createState(findResults: unknown[] = []): TestState {
  return {
    deleteCalls: [],
    findResults,
    createCalls: [],
  };
}
function createUserMock(state: TestState) {
  return {
    findBy: vi.fn(async (_field: string, value: string) => {
      const result = state.findResults.shift();
      if (result) {
        return {
          ...result,
          delete: vi.fn(async () => {
            state.deleteCalls.push(value);
          }),
        };
      }
      return null;
    }),
    create: vi.fn(async (payload: Record<string, unknown>) => {
      state.createCalls.push(payload);
      return { id: 2, ...payload };
    }),
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
async function loadController(state: TestState) {
  vi.resetModules();
  vi.doMock("#models/user", () => ({
    default: createUserMock(state),
  }));
  return import("../../app/controllers/users_controller.js");
}
async function setupStore(username: unknown, findResults: unknown[] = []) {
  const state = createState(findResults);
  const { default: UsersController } = await loadController(state);
  const context = createHttpContext(username);
  const result = await new UsersController().store(context as never);
  return { context, result, state };
}
async function setupDestroy(username: unknown, findResults: unknown[] = []) {
  const state = createState(findResults);
  const { default: UsersController } = await loadController(state);
  const context = createHttpContext(username);
  const result = await new UsersController().destroy(context as never);
  return { context, result, state };
}
function expectInvalidUsernameResult(
  context: ReturnType<typeof createHttpContext>,
  result: unknown,
  state: TestState,
) {
  expect(context.response.status).toHaveBeenCalledWith(422);
  expect(result).toEqual({
    error: "username must be a valid lowercase slug",
  });
  expect(state.createCalls).toHaveLength(0);
}
describe("UsersController", () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });
  it("rejects invalid usernames before touching the database", async () => {
    const { context, result, state } = await setupStore("AB");
    expectInvalidUsernameResult(context, result, state);
  });
  it("rejects non-string usernames before touching the database", async () => {
    const { context, result, state } = await setupStore(42);
    expectInvalidUsernameResult(context, result, state);
  });
  it("returns a conflict when the username already exists", async () => {
    const { context, result, state } = await setupStore("starter-user", [
      { id: 1, username: "starter-user" },
    ]);
    expect(context.response.status).toHaveBeenCalledWith(409);
    expect(result).toEqual({ error: "username already exists" });
    expect(state.createCalls).toHaveLength(0);
  });
  it("creates and returns a new username", async () => {
    const { context, result, state } = await setupStore("starter-user", [null]);
    expect(context.response.status).toHaveBeenCalledWith(201);
    expect(state.createCalls).toEqual([{ username: "starter-user" }]);
    expect(result).toEqual({ user: { id: 2, username: "starter-user" } });
  });
  it("rejects invalid usernames during deletion", async () => {
    const { context, result, state } = await setupDestroy(42);
    expect(context.response.status).toHaveBeenCalledWith(422);
    expect(result).toEqual({
      error: "username must be a valid lowercase slug",
    });
    expect(state.deleteCalls).toHaveLength(0);
  });
  it("returns not found when deleting a missing username", async () => {
    const { context, result, state } = await setupDestroy("starter-user", [
      null,
    ]);
    expect(context.response.status).toHaveBeenCalledWith(404);
    expect(result).toEqual({ error: "user not found" });
    expect(state.deleteCalls).toHaveLength(0);
  });
  it("deletes an existing username", async () => {
    const { result, state } = await setupDestroy("starter-user", [{ id: 3 }]);
    expect(state.deleteCalls).toEqual(["starter-user"]);
    expect(result).toEqual({ deleted: true, username: "starter-user" });
  });
});
