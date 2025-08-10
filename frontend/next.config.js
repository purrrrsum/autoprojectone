/** @type {import('next').NextConfig} */
const nextConfig = {
  // Enable SWC minification for smaller bundles
  swcMinify: true,
  
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

  // Output optimizations
  output: 'export',
  trailingSlash: true,
  generateEtags: false,
};

module.exports = nextConfig; 