program main
   implicit none
   character(len=32) :: debug
   character(len=5) :: RED = char(27)//'[31m'
   character(len=5) :: GREEN = char(27)//'[32m'
   character(len=5) :: BLUE = char(27)//'[34m'
   character(len=4) :: RESET = char(27)//'[0m'
   integer :: i
   call get_environment_variable("DEBUG", debug)
   if (trim(debug) == "1") then
      print '(A)', "test ... ok"
   else
      do i = 1, 100
         if (mod(i, 15) == 0) then
            print '(A,A,A)', trim(RED), "FizzBuzz", trim(RESET)
         else if (mod(i, 3) == 0) then
            print '(A,A,A)', trim(GREEN), "Fizz", trim(RESET)
         else if (mod(i, 5) == 0) then
            print '(A,A,A)', trim(BLUE), "Buzz", trim(RESET)
         else
            print '(I0)', i
         end if
      end do
   end if
end program main
