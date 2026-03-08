use ply_engine::prelude::*;
fn main() {
    ply_engine::run(|ui| {
        ui.element()
            .width(grow!())
            .height(grow!())
            .background_color(0x1A1A1A)
            .layout(|l| l.center())
            .children(|ui| {
                ui.text("Hello, Ply + Supabase!", |t| {
                    t.font_size(48.0).color(0xFFFFFF)
                });
            });
    });
}
#[cfg(test)]
mod tests {
    #[test]
    fn it_works() {
        assert_eq!(2 + 2, 4);
    }
}
