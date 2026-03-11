"use client";

import { useRouter, useSearchParams } from "next/navigation";
import { Suspense, useState } from "react";
import { isValidUsername, SLUG_MAX_LENGTH } from "../lib/validation";
import { useAuth } from "./AuthProvider";

interface AuthFormProps {
  onSuccess?: () => void;
}

export default function AuthForm({ onSuccess }: AuthFormProps) {
  return (
    <Suspense fallback={<div>Loading...</div>}>
      <AuthFormContent {...(onSuccess ? { onSuccess } : {})} />
    </Suspense>
  );
}

function AuthFormContent({ onSuccess }: AuthFormProps) {
  const [mode, setMode] = useState<"signin" | "signup">("signin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [name, setName] = useState("");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{
    type: "success" | "error";
    text: string;
  } | null>(null);
  const searchParams = useSearchParams();
  const router = useRouter();
  const redirect = searchParams.get("redirect") || "/";

  const { supabase } = useAuth();

  const handleAuth = async (event: React.FormEvent) => {
    event.preventDefault();
    setLoading(true);
    setMessage(null);

    if (mode === "signup") {
      if (!isValidUsername(name)) {
        setMessage({
          type: "error",
          text: `Invalid username: must be a valid slug between 3 and ${SLUG_MAX_LENGTH} characters`,
        });
        setLoading(false);
        return;
      }

      const { error, data } = await supabase.auth.signUp({
        email,
        password,
        options: {
          data: { username: name },
          emailRedirectTo: `${window.location.origin}/auth/callback`,
        },
      });

      if (error) {
        setMessage({ type: "error", text: error.message });
      } else if (data.user && !data.session) {
        setMessage({
          type: "success",
          text: "Please check your email to verify your account.",
        });
        setLoading(false);
      } else {
        setMessage({ type: "success", text: "Account created successfully!" });
        onSuccess ? onSuccess() : router.push(redirect);
      }
    } else {
      const { error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });
      if (error) {
        setMessage({ type: "error", text: error.message });
        setLoading(false);
      } else {
        setMessage({ type: "success", text: "Logged in successfully!" });
        onSuccess ? onSuccess() : router.push(redirect);
      }
    }
    setLoading(false);
  };

  return (
    <div data-testid="auth-form">
      <h1>{mode === "signin" ? "Sign In" : "Sign Up"}</h1>
      <p>{mode === "signin" ? "Welcome back" : "Create a new account"}</p>

      {message && (
        <div
          style={{
            padding: "0.75rem",
            borderRadius: "0.5rem",
            marginBottom: "1.5rem",
            fontSize: "0.875rem",
            backgroundColor: message.type === "error" ? "#fef2f2" : "#f0fdf4",
            color: message.type === "error" ? "#dc2626" : "#16a34a",
            border: `1px solid ${message.type === "error" ? "#fee2e2" : "#dcfce7"}`,
          }}
        >
          {message.text}
        </div>
      )}

      <form
        onSubmit={handleAuth}
        style={{ display: "flex", flexDirection: "column", gap: "1rem" }}
      >
        {mode === "signup" && (
          <div>
            <label
              htmlFor="name"
              style={{
                display: "block",
                fontSize: "0.75rem",
                fontWeight: "500",
                marginBottom: "0.25rem",
              }}
            >
              Username
            </label>
            <input
              id="name"
              type="text"
              required
              value={name}
              onChange={(e) => {
                const sanitizedUsername = e.target.value
                  .toLowerCase()
                  .replace(/[^a-z0-9-]/g, "");
                setName(sanitizedUsername);
              }}
              placeholder="username"
            />
          </div>
        )}
        <div>
          <label
            htmlFor="email"
            style={{
              display: "block",
              fontSize: "0.75rem",
              fontWeight: "500",
              marginBottom: "0.25rem",
            }}
          >
            Email
          </label>
          <input
            id="email"
            type="email"
            required
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            placeholder="you@example.com"
          />
        </div>
        <div>
          <label
            htmlFor="password"
            style={{
              display: "block",
              fontSize: "0.75rem",
              fontWeight: "500",
              marginBottom: "0.25rem",
            }}
          >
            Password
          </label>
          <input
            id="password"
            type="password"
            required
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            placeholder="••••••••"
          />
        </div>

        <button
          type="submit"
          data-testid="auth-submit"
          disabled={loading}
          style={{
            backgroundColor: "#000",
            color: "#fff",
            border: "none",
            padding: "0.5rem",
            borderRadius: "0.25rem",
            opacity: loading ? 0.5 : 1,
          }}
        >
          {loading
            ? "Processing..."
            : mode === "signin"
              ? "Sign In"
              : "Create Account"}
        </button>
      </form>

      <div
        style={{
          marginTop: "1.5rem",
          textAlign: "center",
          fontSize: "0.875rem",
        }}
      >
        <button
          type="button"
          onClick={() => {
            setMode(mode === "signin" ? "signup" : "signin");
          }}
          style={{
            background: "none",
            border: "none",
            textDecoration: "underline",
            color: "#6b7280",
          }}
        >
          {mode === "signin"
            ? "Don't have an account? Sign Up"
            : "Already have an account? Sign In"}
        </button>
      </div>
    </div>
  );
}
