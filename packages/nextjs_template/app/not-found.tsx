import Link from "next/link";

export default function NotFound() {
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        justifyContent: "center",
        minHeight: "50vh",
        padding: "0 1rem",
        textAlign: "center",
      }}
    >
      <div
        style={{
          backgroundColor: "#f3f4f6",
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
          style={{ fontSize: "1.5rem", fontWeight: "bold", color: "#6b7280" }}
        >
          ?
        </span>
      </div>
      <h2
        style={{
          fontSize: "1.5rem",
          fontWeight: "bold",
          color: "#111827",
          marginBottom: "0.5rem",
        }}
      >
        Page Not Found
      </h2>
      <p
        style={{ color: "#4b5563", marginBottom: "1.5rem", maxWidth: "28rem" }}
      >
        The page you are looking for does not exist or has been moved.
      </p>
      <Link
        href="/"
        style={{
          padding: "0.5rem 1rem",
          backgroundColor: "#111827",
          color: "#fff",
          borderRadius: "0.5rem",
          textDecoration: "none",
        }}
      >
        Return Home
      </Link>
    </div>
  );
}
