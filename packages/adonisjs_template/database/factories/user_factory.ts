import Factory from "@adonisjs/lucid/factories";
import User from "#models/user";
export const UserFactory = Factory.define(User, async ({ faker }) => {
  return {
    email: faker.internet.email().toLowerCase(),
    password: "password123",
    username: faker.internet
      .username()
      .toLowerCase()
      .replaceAll(/[^a-z0-9-]/g, "-"),
  };
}).build();
