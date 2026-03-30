import { BaseMail } from "@adonisjs/mail";
import type User from "#models/user";
import { serializeUser } from "../transformers/user_transformer.js";
export default class WelcomeMail extends BaseMail {
  constructor(private readonly user: User) {
    super();
  }
  prepare() {
    const publicUser = serializeUser(this.user);
    this.message
      .to(this.user.email)
      .subject(`Welcome to ${this.user.username}'s AdonisJS starter`)
      .htmlView("emails/welcome", {
        user: publicUser,
      });
  }
}
