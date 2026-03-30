import { BaseSeeder } from "@adonisjs/lucid/seeders";
import { UserFactory } from "../factories/user_factory.js";
export default class extends BaseSeeder {
  async run() {
    await UserFactory.merge({
      email: "demo@example.com",
      password: "password123",
      username: "demo-user",
    }).create();
    await UserFactory.createMany(4);
  }
}
