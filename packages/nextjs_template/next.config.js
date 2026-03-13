const nextConfig = {
  allowedDevOrigins: ["127.0.0.1", "localhost"],
  compress: true,
  experimental: {
    optimizePackageImports: ["@supabase/ssr"],
  },
};
export default nextConfig;
