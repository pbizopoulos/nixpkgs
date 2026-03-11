"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { useEffect, useRef, useState } from "react";
import { useAuth } from "./AuthProvider";
import UserAvatar from "./UserAvatar";

export default function Header() {
  const router = useRouter();
  const { user, profile, signOut, openAuthModal } = useAuth();
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const handleClickOutside = (e: MouseEvent) => {
      if (
        dropdownRef.current &&
        !dropdownRef.current.contains(e.target as Node)
      ) {
        setDropdownOpen(false);
      }
    };
    document.addEventListener("mousedown", handleClickOutside);
    return () => document.removeEventListener("mousedown", handleClickOutside);
  }, []);

  const handleSignOut = async () => {
    setDropdownOpen(false);
    await signOut();
    router.push("/");
  };

  const [mounted, setMounted] = useState(false);

  useEffect(() => {
    setMounted(true);
  }, []);

  if (!mounted) {
    return (
      <header>
        <div>
          <div>
            <span>Minimal Application</span>
          </div>
        </div>
        <div>
          <div />
        </div>
      </header>
    );
  }

  return (
    <header>
      <div>
        <Link href="/" aria-label="Home">
          <span>Minimal App</span>
        </Link>
      </div>

      <div>
        {user ? (
          <div ref={dropdownRef}>
            <button
              type="button"
              onClick={() => setDropdownOpen(!dropdownOpen)}
              aria-label="Open user menu"
              aria-expanded={dropdownOpen}
              aria-haspopup="true"
            >
              <UserAvatar username={profile?.username ?? null} size={28} />
            </button>

            {dropdownOpen && (
              <div role="menu">
                <div>
                  Signed in as <br />
                  <span>{profile?.username}</span>
                </div>
                <button type="button" onClick={handleSignOut} role="menuitem">
                  Sign Out
                </button>
              </div>
            )}
          </div>
        ) : (
          <button
            type="button"
            onClick={() => openAuthModal()}
            aria-label="Sign in to your account"
          >
            Sign In
          </button>
        )}
      </div>
    </header>
  );
}
