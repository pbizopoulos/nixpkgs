import type { AuthBindings } from "@refinedev/core";
import { supabaseClient } from "./utility/supabaseClient";

export const authProvider: AuthBindings = {
  login: async ({ email, password }) => {
    const { error } = await supabaseClient.auth.signInWithPassword({
      email,
      password,
    });
    if (error) {
      return {
        success: false,
        error,
      };
    }
    return {
      success: true,
      redirectTo: "/",
    };
  },
  register: async ({ email, password }) => {
    const { error } = await supabaseClient.auth.signUp({
      email,
      password,
    });
    if (error) {
      return {
        success: false,
        error,
      };
    }
    return {
      success: true,
      redirectTo: "/",
    };
  },
  logout: async () => {
    const { error } = await supabaseClient.auth.signOut();
    if (error) {
      return {
        success: false,
        error,
      };
    }
    return {
      success: true,
      redirectTo: "/login",
    };
  },
  check: async () => {
    const { data, error } = await supabaseClient.auth.getUser();
    if (error || !data.user) {
      return {
        authenticated: false,
        redirectTo: "/login",
      };
    }
    return {
      authenticated: true,
    };
  },
  getIdentity: async () => {
    const { data } = await supabaseClient.auth.getUser();
    if (!data.user) return null;
    return {
      id: data.user.id,
      name: data.user.email ?? data.user.id,
    };
  },
  onError: async (error) => {
    if (error?.code === "PGRST301") {
      return {
        logout: true,
      };
    }
    return { error };
  },
};
