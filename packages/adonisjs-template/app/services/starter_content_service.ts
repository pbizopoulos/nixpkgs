export default class StarterContentService {
  getHomePageCopy() {
    return {
      eyebrow: "Hypermedia starter",
      title: "Build the app, not the scaffold.",
      body:
        "This template now uses the conventional AdonisJS v7 web stack: Edge views, sessions, Shield, auth, limiter, mail, Vite, and a Lucid user model with real credentials.",
      stack: ["Sessions", "Auth", "Shield", "Limiter", "Mail", "Vite + Alpine"],
    };
  }
}
