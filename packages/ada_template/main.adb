with Ada.Text_IO; use Ada.Text_IO;
with Ada.Environment_Variables; use Ada.Environment_Variables;
procedure Main is
   RED   : constant String := ASCII.ESC & "[31m";
   GREEN : constant String := ASCII.ESC & "[32m";
   BLUE  : constant String := ASCII.ESC & "[34m";
   RESET : constant String := ASCII.ESC & "[0m";
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
      for I in 1 .. 100 loop
         if I mod 15 = 0 then
            Put_Line (RED & "FizzBuzz" & RESET);
         elsif I mod 3 = 0 then
            Put_Line (GREEN & "Fizz" & RESET);
         elsif I mod 5 = 0 then
            Put_Line (BLUE & "Buzz" & RESET);
         else
            Put_Line (Integer'Image (I));
         end if;
      end loop;
   end if;
end Main;
