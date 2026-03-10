use leptos::*;
#[component]
fn App() -> impl IntoView {
    view! { <p>"Hello, Leptos!"</p> }
}
#[tokio::main]
async fn main() {
    println!("Leptos template starting...");
}
