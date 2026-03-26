# Start the database and run migrations:
nix develop .#adonisjs_template -c npm run dev:full
# For subsequent runs:
nix develop .#adonisjs_template -c npm run dev
# Upgrade npm packages:
nix develop .#adonisjs_template -c npx npm-check-updates -u
