import type { Metadata } from 'next';
import './globals.css';

export const metadata: Metadata = {
  title: 'Rant.Zone - Anonymous Ephemeral Chat',
  description: 'Anonymous ephemeral chat platform where users are randomly paired based on interests',
  viewport: 'width=device-width, initial-scale=1',
  robots: 'noindex, nofollow',
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className="antialiased">
        {children}
      </body>
    </html>
  );
} 