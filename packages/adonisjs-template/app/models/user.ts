import { withAuthFinder } from "@adonisjs/auth/mixins/lucid";
import hash from "@adonisjs/core/services/hash";
import { BaseModel, column } from "@adonisjs/lucid/orm";
import type { DateTime } from "luxon";
const AuthFinder = withAuthFinder(() => hash.use(), {
  passwordColumnName: "password",
  uids: ["email", "username"],
});
export default class User extends AuthFinder(BaseModel) {
  @column({ isPrimary: true })
  declare id: number;
  @column()
  declare username: string;
  @column()
  declare email: string;
  @column({ serializeAs: null })
  declare password: string;
  @column.dateTime({ autoCreate: true })
  declare createdAt: DateTime;
  @column.dateTime({ autoCreate: true, autoUpdate: true })
  declare updatedAt: DateTime;
}
