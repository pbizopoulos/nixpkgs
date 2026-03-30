import vine from "@vinejs/vine";
export const SLUG_MAX_LENGTH = 39;
/**
 * Validates the username creation action
 */
export const createUsernameValidator = vine.compile(
  vine.object({
    username: vine
      .string()
      .trim()
      .minLength(3)
      .maxLength(SLUG_MAX_LENGTH)
      .regex(/^[a-z0-9-]+$/),
  }),
);
