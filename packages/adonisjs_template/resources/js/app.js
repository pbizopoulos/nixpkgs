import Alpine from "alpinejs";
import "../css/app.css";
window.Alpine = Alpine;
Alpine.data("starterSpotlight", () => ({
  active: "hypermedia",
  setActive(panel) {
    this.active = panel;
  },
}));
Alpine.start();
document.documentElement.dataset.app = "adonisjs-hypermedia-starter";
