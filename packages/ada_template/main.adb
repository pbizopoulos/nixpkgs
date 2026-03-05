with Ada.Text_IO; use Ada.Text_IO;
with Ada.Environment_Variables; use Ada.Environment_Variables;
procedure Main is
begin
   if Exists ("DEBUG") and then Value ("DEBUG") = "1" then
      Put_Line ("test ... ok");
   else
      Put_Line ("Hello Ada!");
   end if;
end Main;
