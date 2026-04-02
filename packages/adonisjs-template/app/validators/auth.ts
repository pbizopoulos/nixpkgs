import vine from "@vinejs/vine";
import { usernameSchemaRules } from "#database/schema_rules";
const usernameField = vine
  .string()
  .trim()
  .minLength(usernameSchemaRules.minLength)
  .maxLength(usernameSchemaRules.maxLength)
  .regex(usernameSchemaRules.pattern);
export const registerUserValidator = vine.create({
  username: usernameField,
  email: vine.string().trim().email(),
  password: vine.string().minLength(8).maxLength(72),
  passwordConfirmation: vine.string().minLength(8).maxLength(72),
});
export const loginValidator = vine.create({
  login: vine.string().trim(),
  password: vine.string().minLength(8).maxLength(72),
});
