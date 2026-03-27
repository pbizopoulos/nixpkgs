import Factory from "@adonisjs/lucid/factories";
import User from "#models/user";
export const UserFactory = Factory.define(User, async ({ faker }) => {
  return {
    username: faker.internet
      .username()
      .toLowerCase()
      .replaceAll(/[^a-z0-9-]/g, "-"),
  };
}).build();
