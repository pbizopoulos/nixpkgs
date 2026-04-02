let
  developer = builtins.readFile ../prm/developer.pub;
  host = builtins.readFile ../prm/adonisjs-template.pub;
in
{
  "secrets.age".publicKeys = [
    developer
    host
  ];
}
