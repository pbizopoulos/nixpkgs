import { BaseSchema } from "@adonisjs/lucid/schema";
export default class extends BaseSchema {
  protected tableName = "users";
  async up() {
    this.schema.createTable(this.tableName, (table: any) => {
      table.increments("id").notNullable();
      table.string("username", 39).notNullable().unique();
      table.timestamp("created_at").notNullable().defaultTo(this.now());
    });
  }
  async down() {
    this.schema.dropTable(this.tableName);
  }
}
