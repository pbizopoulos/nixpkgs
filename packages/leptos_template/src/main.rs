use axum::{response::Html, routing::get, Router};
use leptos::*;
use std::net::SocketAddr;

fn app_view() -> impl IntoView {
    view! {
        <div>
            <p>"Hello, Leptos!"</p>
            <p><a href="/auth.html">"Open Supabase Auth UI"</a></p>
        </div>
    }
}

async fn index() -> Html<String> {
    Html(leptos::ssr::render_to_string(app_view))
}

async fn auth() -> Html<&'static str> {
    Html(include_str!("../auth.html"))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn renders_home_with_auth_link() {
        let html = leptos::ssr::render_to_string(app_view);
        assert!(html.contains("Hello, Leptos!"));
        assert!(html.contains("/auth.html"));
    }

    #[test]
    fn auth_page_contains_supabase_ui() {
        let html = include_str!("../auth.html");
        assert!(html.contains("Supabase Auth UI"));
    }
}

#[tokio::main]
async fn main() {
    let port = std::env::var("PORT").unwrap_or_else(|_| "3000".to_string());
    let addr: SocketAddr = format!("0.0.0.0:{port}")
        .parse()
        .expect("invalid PORT");
    let app = Router::new()
        .route("/", get(index))
        .route("/auth.html", get(auth));
    println!("Leptos template starting on http://{addr}");
    let listener = tokio::net::TcpListener::bind(addr)
        .await
        .expect("failed to bind");
    axum::serve(listener, app).await.expect("server failed");
}
