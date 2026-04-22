{
  inputs,
  pkgs,
  ...
}:
pkgs.runCommand "host_django_template"
  {
    nativeBuildInputs = [
      inputs.self.nixosConfigurations."django-template".config.system.build.vm
    ];
  }
  ''
    touch "$out"
  ''
