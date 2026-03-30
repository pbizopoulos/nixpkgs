import type User from "#models/user";
export function serializeUser(user: User) {
  return {
    id: user.id,
    username: user.username,
    createdAt: user.createdAt.toISO(),
  };
}
