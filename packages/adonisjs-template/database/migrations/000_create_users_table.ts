import { BaseSchema } from "@adonisjs/lucid/schema";
export default class extends BaseSchema {
  protected tableName = "users";
  async up() {
    this.schema.createTable(this.tableName, (table) => {
      table.increments("id").notNullable();
      table.string("email", 255).notNullable().unique();
      table.string("password", 255).notNullable();
      table.string("username", 39).notNullable().unique();
      table.timestamp("created_at").notNullable().defaultTo(this.now());
      table.timestamp("updated_at").notNullable().defaultTo(this.now());
    });
  }
  async down() {
    this.schema.dropTable(this.tableName);
  }
}
