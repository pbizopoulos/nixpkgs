import { Component } from '@angular/core';
import { createClient } from "@supabase/supabase-js";

@Component({
  selector: 'app-root',
  standalone: true,
  templateUrl: './app.component.html',
})
export class AppComponent {
  title = 'Hello, Angular with Supabase!';
  private _supabase = createClient('', '');
}
