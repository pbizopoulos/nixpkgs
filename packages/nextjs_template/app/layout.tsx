import type { Metadata } from "next";
import type React from "react";
import "./globals.css";
import localFont from "next/font/local";
import AuthModal from "../components/AuthModal";
import { AuthProvider } from "../components/AuthProvider";
import Header from "../components/Header";

const inter = localFont({
  src: "./Inter.ttf",
  variable: "--font-inter",
});

const robotoMono = localFont({
  src: "./RobotoMono.ttf",
  variable: "--font-roboto-mono",
});

export const metadata: Metadata = {
  metadataBase: new URL("http://localhost:3000"),
  title: {
    default: "Minimal App",
    template: "%s | Minimal App",
  },
  description: "A simple Next.js and Supabase boilerplate.",
  openGraph: {
    title: "Minimal App",
    description: "A simple Next.js and Supabase boilerplate.",
    url: "http://localhost:3000",
    siteName: "Minimal App",
    locale: "en_US",
    type: "website",
  },
  twitter: {
    card: "summary_large_image",
    title: "Minimal App",
    description: "A simple Next.js and Supabase boilerplate.",
  },
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="en">
      <body className={`${inter.variable} ${robotoMono.variable}`}>
        <AuthProvider>
          <Header />
          <AuthModal />
          {children}
        </AuthProvider>
      </body>
    </html>
  );
}
