export default function Loading() {
  return (
    <div
      style={{
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        minHeight: "50vh",
      }}
    >
      <div
        style={{
          borderRadius: "50%",
          height: "2rem",
          width: "2rem",
          borderBottom: "2px solid #111827",
        }}
      />
    </div>
  );
}
