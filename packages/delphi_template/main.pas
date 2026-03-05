program main;
{$MODE DELPHI}
uses sysutils;
var
  debug: string;
begin
  debug := GetEnvironmentVariable('DEBUG');
  if debug = '1' then
    writeln('test ... ok')
  else
    writeln('Hello Delphi!');
end.
