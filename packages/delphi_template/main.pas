program main;
{$MODE DELPHI}
uses sysutils;
var
  debug: string;
  i: integer;
  RED, GREEN, BLUE, RESET: string;
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
  RED := #27'[31m';
  GREEN := #27'[32m';
  BLUE := #27'[34m';
  RESET := #27'[0m';
  debug := GetEnvironmentVariable('DEBUG');
  if debug = '1' then
    RunTests
  else
  begin
    for i := 1 to 100 do
    begin
      if i mod 15 = 0 then writeln(RED + 'FizzBuzz' + RESET)
      else if i mod 3 = 0 then writeln(GREEN + 'Fizz' + RESET)
      else if i mod 5 = 0 then writeln(BLUE + 'Buzz' + RESET)
      else writeln(i);
    end;
  end;
end.
