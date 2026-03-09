with Ada.Text_IO; use Ada.Text_IO;
with Ada.Environment_Variables; use Ada.Environment_Variables;
procedure Main is
   procedure Run_Tests is
   begin
      if 1 + 1 = 2 then
         Put_Line ("test ... ok");
      else
         Put_Line ("test ... failed");
      end if;
   end Run_Tests;
begin
   if Exists ("DEBUG") and then Value ("DEBUG") = "1" then
      Run_Tests;
   else
      Put_Line ("Hello World");
   end if;
end Main;
