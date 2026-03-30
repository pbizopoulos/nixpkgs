import type UserRegistered from "../events/user_registered.js";
export default class LogUserRegistration {
  async handle(event: UserRegistered) {
    /**
     * Logic to perform when a user is registered.
     * For example: Logging, sending a welcome email, etc.
     */
    console.log(`User registered: ${event.user.username}`);
  }
}
