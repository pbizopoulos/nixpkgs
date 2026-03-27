import { BaseModel, column } from "@adonisjs/lucid/orm";
export default class User extends BaseModel {
  @column({ isPrimary: true })
  declare id: number;
  @column()
  declare username: string;
  @column.dateTime({ autoCreate: true })
  declare createdAt: any;
}
