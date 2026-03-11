export const SLUG_MAX_LENGTH = 39;

export function isValidUsername(username: string): boolean {
  if (!username) return false;
  if (username.length < 3 || username.length > SLUG_MAX_LENGTH) return false;
  return /^[a-z0-9-]+$/.test(username);
}
