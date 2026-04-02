import vine from "@vinejs/vine";
import { usernameSchemaRules } from "#database/schema_rules";
export const SLUG_MAX_LENGTH = usernameSchemaRules.maxLength;
/**
 * Validates the username creation action
 */
const usernameField = () =>
  vine
    .string()
    .trim()
    .minLength(usernameSchemaRules.minLength)
    .maxLength(usernameSchemaRules.maxLength)
    .regex(usernameSchemaRules.pattern);
export const createUserValidator = vine.create({
  username: usernameField(),
});
export const deleteUserValidator = vine.create({
  params: vine.object({
    username: usernameField(),
  }),
});
