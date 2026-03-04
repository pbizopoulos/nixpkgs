program main
    implicit none
    character(len=32) :: debug
    call get_environment_variable("DEBUG", debug)
    if (trim(debug) == "1") then
        print '(A)', "test math ... ok"
    else
        print '(A)', "Hello Fortran!"
    end if
end program main
