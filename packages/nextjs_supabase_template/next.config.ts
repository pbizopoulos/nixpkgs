import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  allowedDevOrigins: ["127.0.0.1", "localhost"],
  compress: true,
  experimental: {
    optimizePackageImports: ["@supabase/ssr"],
  },
};

export default nextConfig;
