let
  host = builtins.readFile ../prm/adonisjs_template.pub;
  developer = builtins.readFile ../prm/developer.pub;
in
{
  "secrets.age".publicKeys = [
    host
    developer
  ];
}
