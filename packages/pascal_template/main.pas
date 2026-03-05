program main;
uses sysutils;
var
  debug: string;
procedure RunTests;
begin
  if 1 + 1 = 2 then
    writeln('test ... ok')
  else
  begin
    writeln('test ... failed');
    halt(1);
  end;
end;
begin
  debug := GetEnvironmentVariable('DEBUG');
  if debug = '1' then
    RunTests
  else
    writeln('Hello Pascal!');
end.
