program Main;
{$IFDEF FPC}{$MODE DELPHI}{$ENDIF}
uses
  SysUtils;
procedure RunTests;
begin
  if 1 + 1 = 2 then
    writeln('test ... ok')
  else
  begin
    writeln('test math failed');
    Halt(1);
  end;
end;
var
  debug: string;
begin
  debug := GetEnvironmentVariable('DEBUG');
  if debug = '1' then
    RunTests
  else
    writeln('Hello World');
end.
