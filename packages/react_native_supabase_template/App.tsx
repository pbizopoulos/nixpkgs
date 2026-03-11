import AsyncStorage from "@react-native-async-storage/async-storage";
import { StatusBar } from "expo-status-bar";
import { createClient } from "@supabase/supabase-js";
import { useEffect, useMemo, useState } from "react";
import {
  Button,
  StyleSheet,
  Text,
  TextInput,
  View,
} from "react-native";
export default function App() {
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [status, setStatus] = useState("Ready.");
  const [userEmail, setUserEmail] = useState<string | null>(null);
  const supabase = useMemo(() => {
    const url =
      process.env.EXPO_PUBLIC_SUPABASE_URL || "http://localhost:54321";
    const key =
      process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY || "build-placeholder";
    return createClient(url, key, {
      auth: {
        storage: AsyncStorage,
        autoRefreshToken: true,
        persistSession: true,
        detectSessionInUrl: false,
      },
    });
  }, []);
  useEffect(() => {
    const loadUser = async () => {
      const { data, error } = await supabase.auth.getUser();
      if (error) {
        setStatus(error.message);
        setUserEmail(null);
        return;
      }
      setUserEmail(data.user?.email ?? null);
    };
    loadUser();
  }, [supabase]);
  const signUp = async () => {
    setStatus("Signing up...");
    const { error } = await supabase.auth.signUp({
      email: email.trim(),
      password,
    });
    if (error) {
      setStatus(error.message);
      return;
    }
    setStatus("Check your email to confirm the account.");
  };
  const signIn = async () => {
    setStatus("Signing in...");
    const { data, error } = await supabase.auth.signInWithPassword({
      email: email.trim(),
      password,
    });
    if (error) {
      setStatus(error.message);
      return;
    }
    setUserEmail(data.user?.email ?? null);
    setStatus("Signed in.");
  };
  const signOut = async () => {
    setStatus("Signing out...");
    const { error } = await supabase.auth.signOut();
    if (error) {
      setStatus(error.message);
      return;
    }
    setUserEmail(null);
    setStatus("Signed out.");
  };
  return (
    <View style={styles.container}>
      <Text style={styles.title}>Hello World!</Text>
      <Text style={styles.subtitle}>Supabase Auth UI</Text>
      <TextInput
        style={styles.input}
        placeholder="Email"
        autoCapitalize="none"
        value={email}
        onChangeText={setEmail}
      />
      <TextInput
        style={styles.input}
        placeholder="Password"
        secureTextEntry
        value={password}
        onChangeText={setPassword}
      />
      <View style={styles.row}>
        <Button title="Sign up" onPress={signUp} />
        <Button title="Sign in" onPress={signIn} />
        <Button title="Sign out" onPress={signOut} />
      </View>
      <Text style={styles.status}>User: {userEmail ?? "none"}</Text>
      <Text style={styles.status}>{status}</Text>
      <StatusBar style="auto" />
    </View>
  );
}
const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: "#fff",
    alignItems: "center",
    justifyContent: "center",
    padding: 24,
  },
  title: {
    fontSize: 24,
    fontWeight: "600",
    marginBottom: 6,
  },
  subtitle: {
    fontSize: 16,
    marginBottom: 16,
  },
  input: {
    width: "100%",
    borderColor: "#cbd5f5",
    borderWidth: 1,
    borderRadius: 8,
    padding: 10,
    marginBottom: 10,
  },
  row: {
    flexDirection: "row",
    gap: 8,
    marginTop: 8,
  },
  status: {
    marginTop: 10,
    textAlign: "center",
  },
});
