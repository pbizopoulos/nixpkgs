import { AuthPage, RefineThemes, ThemedLayoutV2 } from "@refinedev/antd";
import {
  Authenticated,
  ErrorComponent,
  NavigateToResource,
  Refine,
} from "@refinedev/core";
import { routerProvider } from "@refinedev/react-router";
import { dataProvider, type SupabaseClient } from "@refinedev/supabase";
import { ConfigProvider } from "antd";
import { BrowserRouter, Route, Routes } from "react-router-dom";
import { authProvider } from "./authProvider";
import { PostList } from "./pages/posts/list";
import { supabaseClient } from "./utility/supabaseClient";

const supabaseDataProvider = dataProvider(supabaseClient as SupabaseClient);
export default function App() {
  return (
    <BrowserRouter>
      <ConfigProvider theme={RefineThemes.Blue}>
        <Refine
          dataProvider={supabaseDataProvider}
          authProvider={authProvider}
          routerProvider={routerProvider}
          resources={[
            {
              name: "posts",
              list: "/posts",
            },
          ]}
          options={{
            syncWithLocation: true,
            warnWhenUnsavedChanges: true,
          }}
        >
          <Routes>
            <Route
              element={
                <Authenticated
                  key="protected"
                  fallback={<AuthPage type="login" />}
                >
                  <ThemedLayoutV2>
                    <Routes>
                      <Route path="/posts" element={<PostList />} />
                      <Route
                        path="/"
                        element={<NavigateToResource resource="posts" />}
                      />
                    </Routes>
                  </ThemedLayoutV2>
                </Authenticated>
              }
            >
              <Route index element={<NavigateToResource resource="posts" />} />
            </Route>
            <Route path="/login" element={<AuthPage type="login" />} />
            <Route path="/register" element={<AuthPage type="register" />} />
            <Route path="*" element={<ErrorComponent />} />
          </Routes>
        </Refine>
      </ConfigProvider>
    </BrowserRouter>
  );
}
