"use client";

import { usePathname, useRouter } from "next/navigation";
import { useEffect, useRef } from "react";
import AuthForm from "./AuthForm";
import { useAuth } from "./AuthProvider";

export default function AuthModal() {
  const { isAuthModalOpen, closeAuthModal, user, authModalRedirectPath } =
    useAuth();
  const modalRef = useRef<HTMLDivElement>(null);
  const pathname = usePathname();
  const router = useRouter();

  const handleClose = () => {
    closeAuthModal();
    const isProtectedRoute = pathname.endsWith("/edit");
    if (isProtectedRoute && !user) {
      router.push("/");
    }
  };

  const handleSuccess = () => {
    closeAuthModal();
    if (authModalRedirectPath) {
      router.push(authModalRedirectPath);
    }
  };

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (
        modalRef.current &&
        !modalRef.current.contains(event.target as Node)
      ) {
        handleClose();
      }
    };

    const handleEscape = (event: KeyboardEvent) => {
      if (event.key === "Escape") {
        handleClose();
      }
    };

    if (isAuthModalOpen) {
      document.addEventListener("mousedown", handleClickOutside);
      document.addEventListener("keydown", handleEscape);
      document.body.style.overflow = "hidden";
    }

    return () => {
      document.removeEventListener("mousedown", handleClickOutside);
      document.removeEventListener("keydown", handleEscape);
      document.body.style.overflow = "unset";
    };
  }, [isAuthModalOpen, handleClose]);

  if (!isAuthModalOpen) return null;

  return (
    <div
      style={{
        position: "fixed",
        inset: 0,
        zIndex: 50,
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        padding: "1rem",
        backgroundColor: "rgba(0,0,0,0.5)",
      }}
    >
      <div
        ref={modalRef}
        style={{
          position: "relative",
          width: "100%",
          maxWidth: "24rem",
          backgroundColor: "#fff",
          borderRadius: "1rem",
          padding: "2rem",
          boxShadow: "0 25px 50px -12px rgba(0,0,0,0.25)",
        }}
      >
        <button
          type="button"
          onClick={handleClose}
          style={{
            position: "absolute",
            top: "1rem",
            right: "1rem",
            background: "none",
            border: "none",
            fontSize: "1.5rem",
            cursor: "pointer",
            color: "#9ca3af",
          }}
          aria-label="Close modal"
        >
          ×
        </button>
        <AuthForm onSuccess={handleSuccess} />
      </div>
    </div>
  );
}
