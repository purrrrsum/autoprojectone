/** @type {import('next').NextConfig} */
const nextConfig = {
  // Enable SWC minification for smaller bundles
  swcMinify: true,
  
  // Experimental optimizations
  experimental: {
    optimizeCss: true,
    optimizePackageImports: ['preact', 'zustand'],
    turbo: {
      rules: {
        '*.svg': {
          loaders: ['@svgr/webpack'],
          as: '*.js',
        },
      },
    },
  },

  // Use Preact instead of React with advanced optimizations
  webpack: (config, { dev, isServer }) => {
    if (!dev && !isServer) {
      // Bundle size budget enforcement - 250KB limit (reduced from 300KB)
      config.performance = {
        maxEntrypointSize: 250 * 1024,
        maxAssetSize: 250 * 1024,
        hints: 'error',
      };

      // Advanced tree shaking
      config.optimization.usedExports = true;
      config.optimization.sideEffects = false;
      config.optimization.providedExports = true;
      config.optimization.innerGraph = true;
      config.optimization.mangleExports = 'deterministic';

      // Optimize bundle splitting
      config.optimization.splitChunks = {
        chunks: 'all',
        minSize: 20000,
        maxSize: 100000,
        cacheGroups: {
          default: false,
          vendors: false,
          framework: {
            name: 'framework',
            chunks: 'all',
            test: /[\\/]node_modules[\\/](preact|next)[\\/]/,
            priority: 40,
            enforce: true,
            reuseExistingChunk: true,
          },
          lib: {
            test: /[\\/]node_modules[\\/]/,
            priority: 30,
            chunks: 'all',
            reuseExistingChunk: true,
            name(module) {
              const packageName = module.context.match(
                /[\\/]node_modules[\\/](.*?)([\\/]|$)/
              )[1];
              return `npm.${packageName.replace('@', '')}`;
            },
          },
          shared: {
            name: 'shared',
            minChunks: 2,
            priority: 20,
            reuseExistingChunk: true,
          },
        },
      };

      // Advanced code splitting
      config.optimization.runtimeChunk = 'single';
      config.optimization.moduleIds = 'deterministic';
      config.optimization.chunkIds = 'deterministic';

      // Remove unused code
      config.optimization.minimize = true;
      
      // Remove console logs in production
      config.optimization.minimizer.push(
        new (require('terser-webpack-plugin'))({
          terserOptions: {
            compress: {
              drop_console: true,
              drop_debugger: true,
            },
          },
        })
      );
    }

    // Preact aliases with optimizations
    config.resolve.alias = {
      ...config.resolve.alias,
      'react': 'preact/compat',
      'react-dom': 'preact/compat',
      'react/jsx-runtime': 'preact/jsx-runtime',
      'preact/hooks': 'preact/hooks/dist/hooks.module.js',
    };

    // Module resolution optimizations
    config.resolve.modules = ['node_modules'];
    config.resolve.extensions = ['.js', '.jsx', '.ts', '.tsx'];
    config.resolve.symlinks = false;

    return config;
  },

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

  // Security headers with performance optimizations
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
          {
            key: 'Cache-Control',
            value: 'public, max-age=31536000, immutable',
          },
          {
            key: 'X-DNS-Prefetch-Control',
            value: 'on',
          },
        ],
      },
    ];
  },

  // Output optimizations
  output: 'standalone',
  trailingSlash: false,
  generateEtags: false,
};

module.exports = nextConfig; 