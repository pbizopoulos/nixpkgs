program main;
uses sysutils;
var
  debug: string;
begin
  debug := GetEnvironmentVariable('DEBUG');
  if debug = '1' then
    writeln('test math ... ok')
  else
    writeln('Hello Pascal!');
end.
