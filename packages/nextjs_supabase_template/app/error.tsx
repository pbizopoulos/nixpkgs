"use client";

import { useEffect } from "react";

export default function ErrorPage({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error(error);
  }, [error]);

  return (
    <div
      style={{
        minHeight: "100vh",
        backgroundColor: "#fff",
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        padding: "1rem",
      }}
    >
      <div style={{ textAlign: "center", maxWidth: "28rem" }}>
        <div
          style={{
            backgroundColor: "#fef2f2",
            width: "4rem",
            height: "4rem",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            borderRadius: "50%",
            marginBottom: "1rem",
            margin: "0 auto",
          }}
        >
          <span
            style={{ fontSize: "1.5rem", fontWeight: "bold", color: "#ef4444" }}
          >
            !
          </span>
        </div>
        <h2
          style={{
            fontSize: "1.5rem",
            fontWeight: "bold",
            marginBottom: "1rem",
          }}
        >
          Something went wrong!
        </h2>
        <p style={{ color: "#6b7280", marginBottom: "2rem" }}>
          We apologize for the inconvenience. An unexpected error has occurred.
        </p>
        <button
          type="button"
          onClick={() => reset()}
          style={{
            padding: "0.5rem 1rem",
            backgroundColor: "#111827",
            color: "#fff",
            borderRadius: "0.5rem",
            border: "none",
            cursor: "pointer",
          }}
        >
          Try again
        </button>
      </div>
    </div>
  );
}
