import vine from "@vinejs/vine";
import { usernameSchemaRules } from "../../database/schema_rules.js";
export const SLUG_MAX_LENGTH = usernameSchemaRules.maxLength;
/**
 * Validates the username creation action
 */
export const createUsernameValidator = vine.compile(
  vine.object({
    username: vine
      .string()
      .trim()
      .minLength(usernameSchemaRules.minLength)
      .maxLength(usernameSchemaRules.maxLength)
      .regex(usernameSchemaRules.pattern),
  }),
);
