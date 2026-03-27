import { BaseSeeder } from "@adonisjs/lucid/seeders";
import { UserFactory } from "../factories/user_factory.js";
export default class extends BaseSeeder {
  async run() {
    await UserFactory.createMany(10);
  }
}
