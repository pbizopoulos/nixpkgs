/**
 * This file mirrors validator-facing constraints derived from the database
 * schema so validators can import them from the documented `database/` layer.
 */
export const usernameSchemaRules = {
  maxLength: 39,
  minLength: 3,
  pattern: /^[a-z0-9-]+$/,
} as const;
