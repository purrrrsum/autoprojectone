/** @type {import('next').NextConfig} */
const nextConfig = {
  // Enable SWC minification for smaller bundles
  swcMinify: true,
  
  // Bundle analyzer
  ...(process.env.ANALYZE === 'true' && {
    webpack: (config) => {
      config.plugins.push(
        new (require('@next/bundle-analyzer'))({
          enabled: true,
        })
      );
      return config;
    },
  }),

  // Performance optimizations
  compress: true,
  poweredByHeader: false,
  
  // Image optimization disabled (no images allowed)
  images: {
    unoptimized: true,
  },

  // Security headers
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
          {
            key: 'Permissions-Policy',
            value: 'camera=(), microphone=(), geolocation=()',
          },
        ],
      },
    ];
  },

  // Bundle size budget and optimizations
  webpack: (config, { dev, isServer }) => {
    if (!dev && !isServer) {
      // Bundle size budget enforcement - 300KB limit
      config.performance = {
        maxEntrypointSize: 300 * 1024,
        maxAssetSize: 300 * 1024,
        hints: 'error',
      };

      // Aggressive tree shaking
      config.optimization.usedExports = true;
      config.optimization.sideEffects = false;
      config.optimization.providedExports = true;

      // Optimize bundle splitting
      config.optimization.splitChunks = {
        chunks: 'all',
        cacheGroups: {
          default: false,
          vendors: false,
          framework: {
            name: 'framework',
            chunks: 'all',
            test: /[\\/]node_modules[\\/](react|react-dom|next)[\\/]/,
            priority: 40,
            enforce: true,
          },
          lib: {
            test: /[\\/]node_modules[\\/]/,
            priority: 30,
            chunks: 'all',
            name(module) {
              const packageName = module.context.match(
                /[\\/]node_modules[\\/](.*?)([\\/]|$)/
              )[1];
              return `npm.${packageName.replace('@', '')}`;
            },
          },
        },
      };

      // Remove unused code
      config.optimization.minimize = true;
    }
    return config;
  },
};

module.exports = nextConfig; 