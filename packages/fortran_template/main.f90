program main
   implicit none
   character(len=32) :: debug
   call get_environment_variable("DEBUG", debug)
   if (trim(debug) == "1") then
      call run_tests()
   else
      print *, "Hello World"
   end if
contains
   subroutine run_tests()
      if (1 + 1 == 2) then
         print *, "test ... ok"
      else
         print *, "test math failed"
         call exit(1)
      end if
   end subroutine run_tests
end program main
