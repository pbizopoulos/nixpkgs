export function getAvatarColor(str: string): string {
  let hash = 0;
  for (let charIndex = 0; charIndex < str.length; charIndex++) {
    hash = str.charCodeAt(charIndex) + ((hash << 5) - hash);
  }
  const hue = Math.abs(hash % 360);
  return `hsl(${hue}, 70%, 50%)`;
}

interface UserAvatarProps {
  username?: string | null;
  size?: number;
  className?: string;
}

export default function UserAvatar({
  username,
  size = 32,
  className = "",
}: UserAvatarProps) {
  const initials = username?.slice(0, 2).toUpperCase();
  const bgColor = username ? getAvatarColor(username) : "#e5e5e5";

  return (
    <div
      className={className}
      style={{
        width: size,
        height: size,
        backgroundColor: bgColor,
        borderRadius: "50%",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        overflow: "hidden",
        flexShrink: 0,
      }}
    >
      {username ? (
        <span
          style={{
            color: "#fff",
            fontWeight: "500",
            fontSize: "0.75rem",
            lineHeight: 1,
          }}
        >
          {initials}
        </span>
      ) : (
        <div
          style={{ backgroundColor: "#f3f4f6", width: "100%", height: "100%" }}
        />
      )}
    </div>
  );
}
