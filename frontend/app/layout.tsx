import type { Metadata } from 'next';
import { Analytics } from '@vercel/analytics/next';

export const metadata: Metadata = {
  title: 'Chat Application',
  description: 'A simple chat application',
  keywords: ['chat', 'messaging', 'communication'],
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="antialiased bg-gray-50 min-h-screen">
        {children}
        <Analytics />
      </body>
    </html>
  );
} 