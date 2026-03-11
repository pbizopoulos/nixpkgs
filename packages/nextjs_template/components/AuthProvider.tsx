"use client";

import { createBrowserClient } from "@supabase/ssr";
import type { SupabaseClient, User } from "@supabase/supabase-js";
import { createContext, useContext, useEffect, useState } from "react";

type Profile = {
  username: string | null;
};

type AuthContextType = {
  user: User | null;
  profile: Profile | null;
  loading: boolean;
  supabase: SupabaseClient;
  signOut: () => Promise<void>;
  isAuthModalOpen: boolean;
  authModalRedirectPath: string | null;
  openAuthModal: (redirectPath?: string) => void;
  closeAuthModal: () => void;
};

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: React.ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [profile, setProfile] = useState<Profile | null>(null);
  const [loading, setLoading] = useState(true);
  const [isAuthModalOpen, setIsAuthModalOpen] = useState(false);
  const [authModalRedirectPath, setAuthModalRedirectPath] = useState<
    string | null
  >(null);

  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || "";
  const supabaseKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "";

  const [supabase] = useState(() =>
    createBrowserClient(supabaseUrl, supabaseKey, {
      global: {
        fetch: (url, options) => {
          const headers = options?.headers
            ? options.headers instanceof Headers
              ? options.headers
              : new Headers(options.headers as any)
            : new Headers();
          const auth = headers.get("Authorization");
          if (auth?.startsWith("Bearer ")) {
            const token = auth.substring(7);
            if (!token.includes(".") || token.split(".").length !== 3) {
              headers.delete("Authorization");
            }
          }
          const apikey = headers.get("apikey");
          if (
            apikey &&
            (!apikey.includes(".") || apikey.split(".").length !== 3)
          ) {
            headers.delete("apikey");
          }
          const newOptions = { ...options, headers };
          return fetch(url, newOptions);
        },
      },
      cookies: {
        get(name: string) {
          if (typeof document === "undefined") return "";
          const cookie = document.cookie
            .split("; ")
            .find((row) => row.startsWith(`${name}=`));
          return cookie ? cookie.split("=")[1] : "";
        },
        set(name: string, value: string, options: any) {
          if (typeof document === "undefined") return;
          let cookieString = `${name}=${value}`;
          if (options.path) cookieString += `; path=${options.path}`;
          if (options.maxAge) cookieString += `; max-age=${options.maxAge}`;
          if (options.domain) cookieString += `; domain=${options.domain}`;
          if (options.sameSite)
            cookieString += `; samesite=${options.sameSite}`;
          if (options.secure && window.location.protocol === "https:") {
            cookieString += "; secure";
          }
          document.cookie = cookieString;
        },
        remove(name: string, options: any) {
          if (typeof document === "undefined") return;
          let cookieString = `${name}=; max-age=0`;
          if (options.path) cookieString += `; path=${options.path}`;
          if (options.domain) cookieString += `; domain=${options.domain}`;
          document.cookie = cookieString;
        },
      },
    }),
  );

  useEffect(() => {
    let isMounted = true;

    const fetchProfile = async (userId: string) => {
      const { data: profileData } = await supabase
        .from("users")
        .select("username")
        .eq("auth_id", userId)
        .maybeSingle();
      if (isMounted && profileData) {
        setProfile(profileData);
      }
    };

    const initUser = async () => {
      try {
        const {
          data: { user },
        } = await supabase.auth.getUser();
        if (isMounted) {
          setUser(user);
          setLoading(false);
          if (user) {
            fetchProfile(user.id);
          }
        }
      } catch (error) {
        console.error("Error fetching user:", error);
        if (isMounted) {
          setLoading(false);
        }
      }
    };

    initUser();

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange(async (_event, session) => {
      const currentUser = session?.user ?? null;
      if (isMounted) {
        setUser(currentUser);
        if (currentUser) {
          fetchProfile(currentUser.id);
        } else {
          setProfile(null);
        }
        setLoading(false);
      }
    });

    return () => {
      isMounted = false;
      subscription.unsubscribe();
    };
  }, [supabase]);

  const signOut = async () => {
    await supabase.auth.signOut();
    setUser(null);
    setProfile(null);
  };

  const openAuthModal = (redirectPath?: string) => {
    setAuthModalRedirectPath(redirectPath || null);
    setIsAuthModalOpen(true);
  };
  const closeAuthModal = () => {
    setIsAuthModalOpen(false);
    setAuthModalRedirectPath(null);
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        profile,
        loading,
        supabase,
        signOut,
        isAuthModalOpen,
        authModalRedirectPath,
        openAuthModal,
        closeAuthModal,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error("useAuth must be used within an AuthProvider");
  }
  return context;
}
