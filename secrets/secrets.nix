let
  developer = builtins.readFile ../prm/developer.pub;
  host = builtins.readFile ../prm/adonisjs_template.pub;
in
{
  "secrets.age".publicKeys = [
    developer
    host
  ];
}
