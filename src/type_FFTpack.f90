!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!     *                                                               *
!     *                  copyright (c) 2011 by UCAR                   *
!     *                                                               *
!     *       University Corporation for Atmospheric Research         *
!     *                                                               *
!     *                      all rights reserved                      *
!     *                                                               *
!     *                     FFTPACK  version 5.1                      *
!     *                                                               *
!     *                 A Fortran Package of Fast Fourier             *
!     *                                                               *
!     *                Subroutines and Example Programs               *
!     *                                                               *
!     *                             by                                *
!     *                                                               *
!     *               Paul Swarztrauber and Dick Valent               *
!     *                                                               *
!     *                             of                                *
!     *                                                               *
!     *         the National Center for Atmospheric Research          *
!     *                                                               *
!     *                Boulder, Colorado  (80307)  U.S.A.             *
!     *                                                               *
!     *                   which is sponsored by                       *
!     *                                                               *
!     *              the National Science Foundation                  *
!     *                                                               *
!     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
!
!
module type_FFTpack

    use, intrinsic :: iso_fortran_env, only: &
        wp => REAL64, &
        ip => INT32, &
        stderr => ERROR_UNIT

    ! Explicit typing only
    implicit none
    private
    public :: FFTpack

    type, public :: FFTpack
        !----------------------------------------------------------------------
        ! Class variables
        !----------------------------------------------------------------------
        real (wp), allocatable :: saved_workspace(:)
        real (wp), allocatable :: workspace(:)
        !----------------------------------------------------------------------
    contains
        !----------------------------------------------------------------------
        ! Class methods
        !----------------------------------------------------------------------
        procedure, nopass, public :: get_1d_saved_workspace_size
        procedure, nopass, public :: get_1d_saved_workspace
        procedure, nopass, public :: get_1d_workspace_size
        procedure, nopass, public :: get_1d_workspace
        procedure, nopass, public :: get_1d_sin_workspace_size
        procedure, nopass, public :: get_1d_sin_workspace
        procedure,         public :: destroy => destroy_fftpack
        !----------------------------------------------------------------------
        ! Complex transform routines
        !----------------------------------------------------------------------
        procedure, nopass, public :: cfft1i ! 1-d complex initialization
        procedure, nopass, public :: cfft1b ! 1-d complex backward
        procedure, nopass, public :: cfft1f ! 1-d complex forward
        procedure, nopass, public :: cfft2i ! 2-d complex initialization
        procedure, nopass, public :: cfft2b ! 2-d complex backward
        procedure, nopass, public :: cfft2f ! 2-d complex forward
        procedure, nopass, public :: cfftmi ! multiple complex initialization
        procedure, nopass, public :: cfftmb ! multiple complex backward
        procedure, nopass, public :: cfftmf ! multiple complex forward
        !----------------------------------------------------------------------
        ! Real transform routines
        !----------------------------------------------------------------------
        procedure, nopass, public :: rfft1i ! 1-d real initialization
        procedure, nopass, public :: rfft1b ! 1-d real backward
        procedure, nopass, public :: rfft1f ! 1-d real forward
        procedure, nopass, public :: rfft2i ! 2-d real initialization
        procedure, nopass, public :: rfft2b ! 2-d real backward
        procedure, nopass, public :: rfft2f ! 2-d real forward
        procedure, nopass, public :: rfftmi ! multiple real initialization
        procedure, nopass, public :: rfftmb ! multiple real backward
        procedure, nopass, public :: rfftmf ! multiple real forward
        !----------------------------------------------------------------------
        ! Real cosine transform routines
        !----------------------------------------------------------------------
        procedure, nopass, public :: cost1i ! 1-d real cosine initialization
        procedure, nopass, public :: cost1b ! 1-d real cosine backward
        procedure, nopass, public :: cost1f ! 1-d real cosine forward
        procedure, nopass, public :: costmi ! multiple real cosine initialization
        procedure, nopass, public :: costmb ! multiple real cosine backward
        procedure, nopass, public :: costmf ! multiple real cosine forward
        !----------------------------------------------------------------------
        ! Real sine transform routines
        !----------------------------------------------------------------------
        procedure, nopass, public :: sint1i ! 1-d real sine initialization
        procedure, nopass, public :: sint1b ! 1-d real sine backward
        procedure, nopass, public :: sint1f ! 1-d real sine forward
        procedure, nopass, public :: sintmi ! multiple real sine initialization
        procedure, nopass, public :: sintmb ! multiple real sine backward
        procedure, nopass, public :: sintmf ! multiple real sine forward
        !----------------------------------------------------------------------
        ! Real quarter-cosine transform routines
        !----------------------------------------------------------------------
        procedure, nopass, public :: cosq1i ! 1-d real quarter-cosine initialization
        procedure, nopass, public :: cosq1b ! 1-d real quarter-cosine backward
        procedure, nopass, public :: cosq1f ! 1-d real quarter-cosine forward
        procedure, nopass, public :: cosqmi ! multiple real quarter-cosine initialization
        procedure, nopass, public :: cosqmb ! multiple real quarter-cosine backward
        procedure, nopass, public :: cosqmf ! multiple real quarter-cosine forward
        !----------------------------------------------------------------------
        ! Real quarter-sine transform routines
        !----------------------------------------------------------------------
        procedure, nopass, public :: sinq1i ! 1-d real quarter-sine initialization
        procedure, nopass, public :: sinq1b ! 1-d real quarter-sine backward
        procedure, nopass, public :: sinq1f ! 1-d real quarter-sine forward
        procedure, nopass, public :: sinqmi ! multiple real quarter-sine initialization
        procedure, nopass, public :: sinqmb ! multiple real quarter-sine backward
        procedure, nopass, public :: sinqmf ! multiple real quarter-sine forward
        !----------------------------------------------------------------------
    end type FFTpack

contains

    subroutine destroy_fftpack(this)
        !------------------------------------------------------------------
        ! Dictionary: calling arguments
        !------------------------------------------------------------------
        class (FFTpack) , intent (in out) :: this
        !------------------------------------------------------------------

        !
        !==> Release memory
        !
        if (allocated(this%saved_workspace)) then
            deallocate( this%saved_workspace )
        end if

        if (allocated(this%workspace)) then
            deallocate( this%workspace )
        end if

    end subroutine destroy_fftpack


    pure function get_1d_saved_workspace_size(n) result (return_value)
        !------------------------------------------------------------------
        ! Dictionary: calling arguments
        !------------------------------------------------------------------
        integer (ip), intent (in) :: n
        integer (ip)              :: return_value
        !------------------------------------------------------------------
        real (wp) :: temp
        !------------------------------------------------------------------

        associate( lensav => return_value )

            temp = log(real(n, kind=wp))/log(2.0_wp)
            lensav = 2*n + int(temp, kind=ip) + 4

        end associate

    end function get_1d_saved_workspace_size


    pure function get_1d_saved_workspace(n) result (return_value)
        !------------------------------------------------------------------
        ! Dictionary: calling arguments
        !------------------------------------------------------------------
        integer (ip),           intent (in) :: n
        real (wp), allocatable              :: return_value(:)
        !------------------------------------------------------------------
        ! Dictionary: local variables
        !------------------------------------------------------------------
        integer (ip) :: lensav
        !------------------------------------------------------------------

        lensav = get_1d_saved_workspace_size(n)

        !
        !==> Allocate memory
        !
        allocate( return_value(lensav) )

    end function get_1d_saved_workspace



    pure function get_1d_workspace_size(n) result (return_value)
        !------------------------------------------------------------------
        ! Dictionary: calling arguments
        !------------------------------------------------------------------
        integer (ip), intent (in) :: n
        integer (ip)              :: return_value
        !------------------------------------------------------------------

        associate( lenwrk => return_value )

            lenwrk = 2*n

        end associate

    end function get_1d_workspace_size



    pure function get_1d_workspace(n) result (return_value)
        !------------------------------------------------------------------
        ! Dictionary: calling arguments
        !------------------------------------------------------------------
        integer (ip),           intent (in) :: n
        real (wp), allocatable              :: return_value(:)
        !------------------------------------------------------------------
        ! Dictionary: local variables
        !------------------------------------------------------------------
        integer (ip) :: lenwrk
        !------------------------------------------------------------------

        lenwrk = get_1d_workspace_size(n)

        !
        !==> Allocate memory
        !
        allocate( return_value(lenwrk) )

    end function get_1d_workspace



    pure function get_1d_sin_workspace_size(n) result (return_value)
        !------------------------------------------------------------------
        ! Dictionary: calling arguments
        !------------------------------------------------------------------
        integer (ip), intent (in) :: n
        integer (ip)              :: return_value
        !------------------------------------------------------------------

        associate( lenwrk => return_value )

            lenwrk = 2*n + 2

        end associate

    end function get_1d_sin_workspace_size



    pure function get_1d_sin_workspace(n) result (return_value)
        !------------------------------------------------------------------
        ! Dictionary: calling arguments
        !------------------------------------------------------------------
        integer (ip),           intent (in) :: n
        real (wp), allocatable              :: return_value(:)
        !------------------------------------------------------------------
        ! Dictionary: local variables
        !------------------------------------------------------------------
        integer (ip) :: lenwrk
        !------------------------------------------------------------------

        lenwrk = get_1d_sin_workspace_size(n)

        !
        !==> Allocate memory
        !
        allocate( return_value(lenwrk) )

    end function get_1d_sin_workspace



    subroutine cfft1i(n, wsave, lensav, ier)
        !
        ! cfft1i: initialization for cfft1b and cfft1f.
        !
        !  Purpose:
        !
        !  cfft1i initializes array wsave for use in its companion routines
        !  cfft1b and cfft1f. Routine cfft1i must be called before the first
        !  call to cfft1b or cfft1f, and after whenever the value of integer
        !  n changes.
        !
        !  Parameters:
        !
        !  input,
        !  n, the length of the sequence to be
        !  transformed.  the transform is most efficient when n is a product
        !  of small primes.
        !
        !  input
        !  lensav, the dimension of the wsave array.
        !  lensav must be at least 2*n + int(log(real(n))) + 4.
        !
        !  output,
        !  wsave(lensav), containing the prime factors
        !  of n and  also containing certain trigonometric values which will be used
        !  in routines cfft1b or cfft1f.
        !
        !  output
        !  ier, error flag.
        !  0, successful exit;
        !  2, input parameter lensav not big enough.
        !
        !--------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------
        integer (ip), intent (in)  :: n
        real (wp),    intent (out) :: wsave(lensav)
        integer (ip), intent (in)  :: lensav
        integer (ip), intent (out) :: ier
        !--------------------------------------------------------------

        if ( size(wsave) < get_1d_saved_workspace_size(n) ) then
            ier = 2
            call xerfft('cfftmi ', 3)
        else
            ier = 0
        end if

        if (n /= 1) then
            associate( iw1 => 2*n+1 )

                call mcfti1(n,wsave,wsave(iw1),wsave(iw1+1))

            end associate
        end if

    end subroutine cfft1i


    subroutine cfft1b(n, inc, complex_data, lenc, wsave, lensav, work, lenwrk, ier)
        !
        !  input
        !  n, the length of the sequence to be
        !  transformed.  the transform is most efficient when n is a product of
        !  small primes.
        !
        !  input
        !  inc, the increment between the locations, in
        !  array c, of two consecutive elements within the sequence to be transformed.
        !
        !  input/output,
        !  complex_data(lenc) containing the sequence to be
        !  transformed.
        !
        !  input
        !  lenc, the dimension of the complex_data array.
        !  lenc must be at least inc*(n-1) + 1.
        !
        !  input
        !  wsave(lensav). wsave's contents must be initialized with a call
        !  to cfft1i before the first call to routine cfft1f
        !  or cfft1b for a given transform length n.  wsave's contents may be
        !  re-used for subsequent calls to cfft1f and cfft1b with the same n.
        !
        !  input
        !  lensav, the dimension of the wsave array.
        !  lensav must be at least 2*n + int(log(real(n))) + 4.
        !
        !  workspace work(lenwrk).
        !
        !  input lenwrk, the dimension of the work array.
        !  lenwrk must be at least 2*n.
        !
        !  output, integer (ip) ier, error flag.
        !  0, successful exit;
        !  1, input parameter lenc not big enough;
        !  2, input parameter lensav not big enough;
        !  3, input parameter lenwrk not big enough;
        !  20, input error returned by lower level routine.
        !
        !--------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------
        integer (ip), intent (in)     :: n
        integer (ip), intent (in)     :: inc
        complex (wp), intent (in out) :: complex_data(lenc)
        integer (ip), intent (in)     :: lenc
        integer (ip), intent (in)     :: lensav
        integer (ip), intent (in)     :: lenwrk
        integer (ip), intent (out)    :: ier
        real (wp),    intent (in out) :: work(lenwrk)
        real (wp),    intent (in out) :: wsave(lensav)
        !--------------------------------------------------------------
        ! Dictionary: local variables
        !--------------------------------------------------------------
        integer (ip)           :: iw1
        real (wp), allocatable :: real_copy(:,:)
        !--------------------------------------------------------------

        !
        !==> Check validity of calling arguments
        !
        if (lenc < inc * ( n - 1 ) + 1) then
            ier = 1
            call xerfft( 'cfft1b ', 4)
        else if ( size(wsave) < get_1d_saved_workspace_size(n) ) then
            ier = 2
            call xerfft('cfft1b ', 6)
        else if ( size(work) < 2 * n) then
            ier = 3
            call xerfft('cfft1b ', 8)
        else
            ier = 0
        end if

        !
        !==> Perform transform
        !
        if ( n /= 1 ) then
            !
            !==> Allocate memory
            !
            allocate( real_copy(2,size(complex_data)) )

            !
            !==> Copy complex to real
            !
            real_copy(1,:) = real(complex_data)
            real_copy(2,:) = aimag(complex_data)

            iw1 = 2 * n + 1

            call c1fm1b(n, inc, real_copy, work, wsave, wsave(iw1), wsave(iw1+1) )

            !
            !==> Copy real to complex
            !
            complex_data =  cmplx(real_copy(1,:), real_copy(2,:), kind=wp)

            !
            !==> Release memory
            !
            deallocate( real_copy )
        end if


    end subroutine cfft1b


    subroutine c1fm1b(n, inc, c, ch, wa, fnf, fac)
        !----------------------------------------------------------------------
        ! Dictionary: calling arguments
        !----------------------------------------------------------------------
        integer (ip), intent (in)     :: n
        integer (ip), intent (in)     :: inc
        real (wp),    intent (in out) :: c(2, *)
        real (wp),    intent (in out) :: ch(*)
        real (wp),    intent (in out) :: wa(*)
        real (wp),    intent (in out) :: fnf
        real (wp),    intent (in out) :: fac(*)
        !----------------------------------------------------------------------
        ! Dictionary: calling arguments
        !----------------------------------------------------------------------
        integer (ip) :: ido, inc2, iip, iw
        integer (ip) :: k1, l1, l2, lid
        integer (ip) :: na, nbr, nf
        !----------------------------------------------------------------------

        inc2 = 2*inc
        nf = int(fnf, kind=ip)
        na = 0
        l1 = 1
        iw = 1

        do k1=1, nf
            iip = int(fac(k1), kind=ip)
            l2 = iip*l1
            ido = n/l2
            lid = l1*ido
            nbr = 1+na+2*min(iip-2, 4)
            select case (nbr)
                case (1)
                    call c1f2kb(ido, l1, na, c, inc2, ch, 2, wa(iw))
                case (2)
                    call c1f2kb(ido, l1, na, ch, 2, c, inc2, wa(iw))
                case (3)
                    call c1f3kb(ido, l1, na, c, inc2, ch, 2, wa(iw))
                case (4)
                    call c1f3kb(ido, l1, na, ch, 2, c, inc2, wa(iw))
                case (5)
                    call c1f4kb(ido, l1, na, c, inc2, ch, 2, wa(iw))
                case (6)
                    call c1f4kb(ido, l1, na, ch, 2, c, inc2, wa(iw))
                case (7)
                    call c1f5kb(ido, l1, na, c, inc2, ch, 2, wa(iw))
                case (8)
                    call c1f5kb(ido, l1, na, ch, 2, c, inc2, wa(iw))
                case (9)
                    call c1fgkb(ido, iip, l1, lid, na, c, c, inc2, ch, ch, 2, wa(iw))
                case (10)
                    call c1fgkb(ido, iip, l1, lid, na, ch, ch, 2, c, c, inc2, wa(iw))
            end select

            l1 = l2
            iw = iw+(iip-1)*(2*ido)

            if (iip <= 5) then
                na = 1-na
            end if
        end do

    contains

        subroutine c1f2kb(ido, l1, na, cc, in1, ch, in2, wa)
            !----------------------------------------------------------------------
            ! Dictionary: calling arguments
            !----------------------------------------------------------------------
            integer (ip), intent (in)   :: ido
            integer (ip), intent (in)   :: l1
            integer (ip), intent (in)   :: na
            real (wp),  intent (in out) :: cc(in1,l1,ido,2)
            integer (ip), intent (in)   :: in1
            real (wp),  intent (in out) :: ch(in2,l1,2,ido)
            integer (ip), intent (in)   :: in2
            real (wp),  intent (in out) :: wa(ido,1,2)
            !----------------------------------------------------------------------
            ! Dictionary: local variables
            !----------------------------------------------------------------------
            integer (ip)           :: i !! Counter
            real (wp), allocatable :: chold1(:), chold2(:)
            real (wp), allocatable :: ti2(:),  tr2(:)
            !----------------------------------------------------------------------

            if (ido <= 1 .and. na /= 1) then
                !
                !==> Allocate memory
                !
                allocate( chold1(l1) )
                allocate( chold2(l1) )

                chold1 = cc(1,:,1,1)+cc(1,:,1,2)
                cc(1,:,1,2) = cc(1,:,1,1)-cc(1,:,1,2)
                cc(1,:,1,1) = chold1
                chold2 = cc(2,:,1,1)+cc(2,:,1,2)
                cc(2,:,1,2) = cc(2,:,1,1)-cc(2,:,1,2)
                cc(2,:,1,1) = chold2
                !
                !==> Release memory
                !
                deallocate( chold1 )
                deallocate( chold2 )
            else
                ch(1,:,1,1) = cc(1,:,1,1)+cc(1,:,1,2)
                ch(1,:,2,1) = cc(1,:,1,1)-cc(1,:,1,2)
                ch(2,:,1,1) = cc(2,:,1,1)+cc(2,:,1,2)
                ch(2,:,2,1) = cc(2,:,1,1)-cc(2,:,1,2)
                !
                !==> Allocate memory
                !
                allocate( tr2(l1) )
                allocate( ti2(l1) )

                do i=2,ido
                    ch(1,:,1,i) = cc(1,:,i,1)+cc(1,:,i,2)
                    tr2 = cc(1,:,i,1)-cc(1,:,i,2)
                    ch(2,:,1,i) = cc(2,:,i,1)+cc(2,:,i,2)
                    ti2 = cc(2,:,i,1)-cc(2,:,i,2)
                    ch(2,:,2,i) = wa(i,1,1)*ti2+wa(i,1,2)*tr2
                    ch(1,:,2,i) = wa(i,1,1)*tr2-wa(i,1,2)*ti2
                end do
                !
                !==> Release memory
                !
                deallocate( tr2 )
                deallocate( ti2 )
            end if

        end subroutine c1f2kb

        subroutine c1f3kb(ido, l1, na, cc, in1, ch, in2, wa)
            !----------------------------------------------------------------------
            ! Dictionary: calling arguments
            !----------------------------------------------------------------------
            integer (ip), intent (in)     :: ido
            integer (ip), intent (in)     :: l1
            integer (ip), intent (in)     :: na
            real (wp),    intent (in out) :: cc(in1,l1,ido,3)
            integer (ip), intent (in)     :: in1
            real (wp),    intent (in out) :: ch(in2,l1,3,ido)
            integer (ip), intent (in)     :: in2
            real (wp),    intent (in)     :: wa(ido,2,2)
            !----------------------------------------------------------------------
            ! Dictionary: calling arguments
            !----------------------------------------------------------------------
            integer (ip)           :: i !! Counter
            real (wp), allocatable :: ci2(:), ci3(:)
            real (wp), allocatable :: cr2(:), cr3(:)
            real (wp), allocatable :: ti2(:), tr2(:)
            real (wp), parameter   :: TAUI = sqrt(3.0_wp)/2!0.866025403784439_wp
            real (wp), parameter   :: TAUR = -0.5_wp
            !----------------------------------------------------------------------

            !
            !==> Allocate memory
            !
            allocate( ci2(l1), ci3(l1) )
            allocate( cr2(l1), cr3(l1) )
            allocate( ti2(l1), tr2(l1) )

            if (.not.( 1 < ido .or. na == 1)) then
                tr2 = cc(1,:,1,2)+cc(1,:,1,3)
                cr2 = cc(1,:,1,1)+TAUR*tr2
                cc(1,:,1,1) = cc(1,:,1,1)+tr2
                ti2 = cc(2,:,1,2)+cc(2,:,1,3)
                ci2 = cc(2,:,1,1)+TAUR*ti2
                cc(2,:,1,1) = cc(2,:,1,1)+ti2
                cr3 = TAUI*(cc(1,:,1,2)-cc(1,:,1,3))
                ci3 = TAUI*(cc(2,:,1,2)-cc(2,:,1,3))
                cc(1,:,1,2) = cr2-ci3
                cc(1,:,1,3) = cr2+ci3
                cc(2,:,1,2) = ci2+cr3
                cc(2,:,1,3) = ci2-cr3
            else
                tr2 = cc(1,:,1,2)+cc(1,:,1,3)
                cr2 = cc(1,:,1,1)+TAUR*tr2
                ch(1,:,1,1) = cc(1,:,1,1)+tr2
                ti2 = cc(2,:,1,2)+cc(2,:,1,3)
                ci2 = cc(2,:,1,1)+TAUR*ti2
                ch(2,:,1,1) = cc(2,:,1,1)+ti2
                cr3 = TAUI*(cc(1,:,1,2)-cc(1,:,1,3))
                ci3 = TAUI*(cc(2,:,1,2)-cc(2,:,1,3))
                ch(1,:,2,1) = cr2-ci3
                ch(1,:,3,1) = cr2+ci3
                ch(2,:,2,1) = ci2+cr3
                ch(2,:,3,1) = ci2-cr3

                do i=2,ido
                    tr2 = cc(1,:,i,2)+cc(1,:,i,3)
                    cr2 = cc(1,:,i,1)+TAUR*tr2
                    ch(1,:,1,i) = cc(1,:,i,1)+tr2
                    ti2 = cc(2,:,i,2)+cc(2,:,i,3)
                    ci2 = cc(2,:,i,1)+TAUR*ti2
                    ch(2,:,1,i) = cc(2,:,i,1)+ti2
                    cr3 = TAUI*(cc(1,:,i,2)-cc(1,:,i,3))
                    ci3 = TAUI*(cc(2,:,i,2)-cc(2,:,i,3))
                    associate( &
                        dr2 => cr2-ci3, &
                        dr3 => cr2+ci3, &
                        di2 => ci2+cr3, &
                        di3 => ci2-cr3 &
                        )
                        ch(2,:,2,i) = wa(i,1,1)*di2+wa(i,1,2)*dr2
                        ch(1,:,2,i) = wa(i,1,1)*dr2-wa(i,1,2)*di2
                        ch(2,:,3,i) = wa(i,2,1)*di3+wa(i,2,2)*dr3
                        ch(1,:,3,i) = wa(i,2,1)*dr3-wa(i,2,2)*di3
                    end associate
                end do
            end if

            !
            !==> Release memory
            !
            deallocate( ci2, ci3 )
            deallocate( cr2, cr3 )
            deallocate( ti2, tr2 )

        end subroutine c1f3kb

        subroutine c1f4kb(ido, l1, na, cc, in1, ch, in2, wa)

            integer (ip) ido
            integer (ip) in1
            integer (ip) in2
            integer (ip) l1

            real (wp) cc(in1,l1,ido,4)
            real (wp) ch(in2,l1,4,ido)
            real (wp) ci2
            real (wp) ci3
            real (wp) ci4
            real (wp) cr2
            real (wp) cr3
            real (wp) cr4
            integer (ip) i
            integer (ip) k
            integer (ip) na
            real (wp) ti1
            real (wp) ti2
            real (wp) ti3
            real (wp) ti4
            real (wp) tr1
            real (wp) tr2
            real (wp) tr3
            real (wp) tr4
            real (wp) wa(ido,3,2)

            if (.not.(1 < ido .or. na == 1)) then
                do k=1,l1
                    ti1 = cc(2,k,1,1)-cc(2,k,1,3)
                    ti2 = cc(2,k,1,1)+cc(2,k,1,3)
                    tr4 = cc(2,k,1,4)-cc(2,k,1,2)
                    ti3 = cc(2,k,1,2)+cc(2,k,1,4)
                    tr1 = cc(1,k,1,1)-cc(1,k,1,3)
                    tr2 = cc(1,k,1,1)+cc(1,k,1,3)
                    ti4 = cc(1,k,1,2)-cc(1,k,1,4)
                    tr3 = cc(1,k,1,2)+cc(1,k,1,4)
                    cc(1,k,1,1) = tr2+tr3
                    cc(1,k,1,3) = tr2-tr3
                    cc(2,k,1,1) = ti2+ti3
                    cc(2,k,1,3) = ti2-ti3
                    cc(1,k,1,2) = tr1+tr4
                    cc(1,k,1,4) = tr1-tr4
                    cc(2,k,1,2) = ti1+ti4
                    cc(2,k,1,4) = ti1-ti4
                end do
            else
                do k=1,l1
                    ti1 = cc(2,k,1,1)-cc(2,k,1,3)
                    ti2 = cc(2,k,1,1)+cc(2,k,1,3)
                    tr4 = cc(2,k,1,4)-cc(2,k,1,2)
                    ti3 = cc(2,k,1,2)+cc(2,k,1,4)
                    tr1 = cc(1,k,1,1)-cc(1,k,1,3)
                    tr2 = cc(1,k,1,1)+cc(1,k,1,3)
                    ti4 = cc(1,k,1,2)-cc(1,k,1,4)
                    tr3 = cc(1,k,1,2)+cc(1,k,1,4)
                    ch(1,k,1,1) = tr2+tr3
                    ch(1,k,3,1) = tr2-tr3
                    ch(2,k,1,1) = ti2+ti3
                    ch(2,k,3,1) = ti2-ti3
                    ch(1,k,2,1) = tr1+tr4
                    ch(1,k,4,1) = tr1-tr4
                    ch(2,k,2,1) = ti1+ti4
                    ch(2,k,4,1) = ti1-ti4
                end do

                do i=2,ido
                    do k=1,l1
                        ti1 = cc(2,k,i,1)-cc(2,k,i,3)
                        ti2 = cc(2,k,i,1)+cc(2,k,i,3)
                        ti3 = cc(2,k,i,2)+cc(2,k,i,4)
                        tr4 = cc(2,k,i,4)-cc(2,k,i,2)
                        tr1 = cc(1,k,i,1)-cc(1,k,i,3)
                        tr2 = cc(1,k,i,1)+cc(1,k,i,3)
                        ti4 = cc(1,k,i,2)-cc(1,k,i,4)
                        tr3 = cc(1,k,i,2)+cc(1,k,i,4)
                        ch(1,k,1,i) = tr2+tr3
                        cr3 = tr2-tr3
                        ch(2,k,1,i) = ti2+ti3
                        ci3 = ti2-ti3
                        cr2 = tr1+tr4
                        cr4 = tr1-tr4
                        ci2 = ti1+ti4
                        ci4 = ti1-ti4
                        ch(1,k,2,i) = wa(i,1,1)*cr2-wa(i,1,2)*ci2
                        ch(2,k,2,i) = wa(i,1,1)*ci2+wa(i,1,2)*cr2
                        ch(1,k,3,i) = wa(i,2,1)*cr3-wa(i,2,2)*ci3
                        ch(2,k,3,i) = wa(i,2,1)*ci3+wa(i,2,2)*cr3
                        ch(1,k,4,i) = wa(i,3,1)*cr4-wa(i,3,2)*ci4
                        ch(2,k,4,i) = wa(i,3,1)*ci4+wa(i,3,2)*cr4
                    end do
                end do
            end if

        end subroutine c1f4kb



        subroutine c1f5kb(ido, l1, na, cc, in1, ch, in2, wa)

            integer (ip) ido
            integer (ip) in1
            integer (ip) in2
            integer (ip) l1

            real (wp) cc(in1,l1,ido,5)
            real (wp) ch(in2,l1,5,ido)
            real (wp) chold1
            real (wp) chold2
            real (wp) ci2
            real (wp) ci3
            real (wp) ci4
            real (wp) ci5
            real (wp) cr2
            real (wp) cr3
            real (wp) cr4
            real (wp) cr5
            real (wp) di2
            real (wp) di3
            real (wp) di4
            real (wp) di5
            real (wp) dr2
            real (wp) dr3
            real (wp) dr4
            real (wp) dr5
            integer (ip) i
            integer (ip) k
            integer (ip) na
            real (wp) ti2
            real (wp) ti3
            real (wp) ti4
            real (wp) ti5
            real (wp), parameter :: ti11 =  0.9510565162951536_wp
            real (wp), parameter :: ti12 =  0.5877852522924731_wp
            real (wp) tr2
            real (wp) tr3
            real (wp) tr4
            real (wp) tr5
            real (wp), parameter :: tr11 =  0.3090169943749474_wp
            real (wp), parameter :: tr12 = -0.8090169943749474_wp
            real (wp) wa(ido,4,2)

            if (.not.(1 < ido .or. na == 1)) then

                do k=1,l1
                    ti5 = cc(2,k,1,2)-cc(2,k,1,5)
                    ti2 = cc(2,k,1,2)+cc(2,k,1,5)
                    ti4 = cc(2,k,1,3)-cc(2,k,1,4)
                    ti3 = cc(2,k,1,3)+cc(2,k,1,4)
                    tr5 = cc(1,k,1,2)-cc(1,k,1,5)
                    tr2 = cc(1,k,1,2)+cc(1,k,1,5)
                    tr4 = cc(1,k,1,3)-cc(1,k,1,4)
                    tr3 = cc(1,k,1,3)+cc(1,k,1,4)
                    chold1 = cc(1,k,1,1)+tr2+tr3
                    chold2 = cc(2,k,1,1)+ti2+ti3
                    cr2 = cc(1,k,1,1)+tr11*tr2+tr12*tr3
                    ci2 = cc(2,k,1,1)+tr11*ti2+tr12*ti3
                    cr3 = cc(1,k,1,1)+tr12*tr2+tr11*tr3
                    ci3 = cc(2,k,1,1)+tr12*ti2+tr11*ti3
                    cc(1,k,1,1) = chold1
                    cc(2,k,1,1) = chold2
                    cr5 = ti11*tr5+ti12*tr4
                    ci5 = ti11*ti5+ti12*ti4
                    cr4 = ti12*tr5-ti11*tr4
                    ci4 = ti12*ti5-ti11*ti4
                    cc(1,k,1,2) = cr2-ci5
                    cc(1,k,1,5) = cr2+ci5
                    cc(2,k,1,2) = ci2+cr5
                    cc(2,k,1,3) = ci3+cr4
                    cc(1,k,1,3) = cr3-ci4
                    cc(1,k,1,4) = cr3+ci4
                    cc(2,k,1,4) = ci3-cr4
                    cc(2,k,1,5) = ci2-cr5
                end do
            else
                do k=1,l1
                    ti5 = cc(2,k,1,2)-cc(2,k,1,5)
                    ti2 = cc(2,k,1,2)+cc(2,k,1,5)
                    ti4 = cc(2,k,1,3)-cc(2,k,1,4)
                    ti3 = cc(2,k,1,3)+cc(2,k,1,4)
                    tr5 = cc(1,k,1,2)-cc(1,k,1,5)
                    tr2 = cc(1,k,1,2)+cc(1,k,1,5)
                    tr4 = cc(1,k,1,3)-cc(1,k,1,4)
                    tr3 = cc(1,k,1,3)+cc(1,k,1,4)
                    ch(1,k,1,1) = cc(1,k,1,1)+tr2+tr3
                    ch(2,k,1,1) = cc(2,k,1,1)+ti2+ti3
                    cr2 = cc(1,k,1,1)+tr11*tr2+tr12*tr3
                    ci2 = cc(2,k,1,1)+tr11*ti2+tr12*ti3
                    cr3 = cc(1,k,1,1)+tr12*tr2+tr11*tr3
                    ci3 = cc(2,k,1,1)+tr12*ti2+tr11*ti3
                    cr5 = ti11*tr5+ti12*tr4
                    ci5 = ti11*ti5+ti12*ti4
                    cr4 = ti12*tr5-ti11*tr4
                    ci4 = ti12*ti5-ti11*ti4
                    ch(1,k,2,1) = cr2-ci5
                    ch(1,k,5,1) = cr2+ci5
                    ch(2,k,2,1) = ci2+cr5
                    ch(2,k,3,1) = ci3+cr4
                    ch(1,k,3,1) = cr3-ci4
                    ch(1,k,4,1) = cr3+ci4
                    ch(2,k,4,1) = ci3-cr4
                    ch(2,k,5,1) = ci2-cr5
                end do

                do i=2,ido
                    do k=1,l1
                        ti5 = cc(2,k,i,2)-cc(2,k,i,5)
                        ti2 = cc(2,k,i,2)+cc(2,k,i,5)
                        ti4 = cc(2,k,i,3)-cc(2,k,i,4)
                        ti3 = cc(2,k,i,3)+cc(2,k,i,4)
                        tr5 = cc(1,k,i,2)-cc(1,k,i,5)
                        tr2 = cc(1,k,i,2)+cc(1,k,i,5)
                        tr4 = cc(1,k,i,3)-cc(1,k,i,4)
                        tr3 = cc(1,k,i,3)+cc(1,k,i,4)
                        ch(1,k,1,i) = cc(1,k,i,1)+tr2+tr3
                        ch(2,k,1,i) = cc(2,k,i,1)+ti2+ti3
                        cr2 = cc(1,k,i,1)+tr11*tr2+tr12*tr3
                        ci2 = cc(2,k,i,1)+tr11*ti2+tr12*ti3
                        cr3 = cc(1,k,i,1)+tr12*tr2+tr11*tr3
                        ci3 = cc(2,k,i,1)+tr12*ti2+tr11*ti3
                        cr5 = ti11*tr5+ti12*tr4
                        ci5 = ti11*ti5+ti12*ti4
                        cr4 = ti12*tr5-ti11*tr4
                        ci4 = ti12*ti5-ti11*ti4
                        dr3 = cr3-ci4
                        dr4 = cr3+ci4
                        di3 = ci3+cr4
                        di4 = ci3-cr4
                        dr5 = cr2+ci5
                        dr2 = cr2-ci5
                        di5 = ci2-cr5
                        di2 = ci2+cr5
                        ch(1,k,2,i) = wa(i,1,1)*dr2-wa(i,1,2)*di2
                        ch(2,k,2,i) = wa(i,1,1)*di2+wa(i,1,2)*dr2
                        ch(1,k,3,i) = wa(i,2,1)*dr3-wa(i,2,2)*di3
                        ch(2,k,3,i) = wa(i,2,1)*di3+wa(i,2,2)*dr3
                        ch(1,k,4,i) = wa(i,3,1)*dr4-wa(i,3,2)*di4
                        ch(2,k,4,i) = wa(i,3,1)*di4+wa(i,3,2)*dr4
                        ch(1,k,5,i) = wa(i,4,1)*dr5-wa(i,4,2)*di5
                        ch(2,k,5,i) = wa(i,4,1)*di5+wa(i,4,2)*dr5
                    end do
                end do
            end if

        end subroutine c1f5kb

        subroutine c1fgkb(ido, iip, l1, lid, na, cc, cc1, in1, ch, ch1, in2, wa)

            integer (ip) ido
            integer (ip) in1
            integer (ip) in2
            integer (ip) iip
            integer (ip) l1
            integer (ip) lid

            real (wp) cc(in1,l1,iip,ido)
            real (wp) cc1(in1,lid,iip)
            real (wp) ch(in2,l1,ido,iip)
            real (wp) ch1(in2,lid,iip)
            real (wp) chold1
            real (wp) chold2
            integer (ip) i
            integer (ip) idlj
            integer (ip) iipp2
            integer (ip) iipph
            integer (ip) j
            integer (ip) jc
            integer (ip) k
            integer (ip) ki
            integer (ip) l
            integer (ip) lc
            integer (ip) na
            real (wp) wa(ido,iip-1,2)
            real (wp) wai
            real (wp) war

            iipp2 = iip+2
            iipph = (iip+1)/2

            ch1(1,:,1) = cc1(1,:,1)
            ch1(2,:,1) = cc1(2,:,1)

            do j=2,iipph
                jc = iipp2-j
                ch1(1,:,j) =  cc1(1,:,j)+cc1(1,:,jc)
                ch1(1,:,jc) = cc1(1,:,j)-cc1(1,:,jc)
                ch1(2,:,j) =  cc1(2,:,j)+cc1(2,:,jc)
                ch1(2,:,jc) = cc1(2,:,j)-cc1(2,:,jc)
            end do

            do j=2,iipph
                cc1(1,:,1) = cc1(1,:,1)+ch1(1,:,j)
                cc1(2,:,1) = cc1(2,:,1)+ch1(2,:,j)
            end do

            do l=2,iipph
                lc = iipp2-l
                do ki=1,lid
                    cc1(1,ki,l) = ch1(1,ki,1)+wa(1,l-1,1)*ch1(1,ki,2)
                    cc1(1,ki,lc) = wa(1,l-1,2)*ch1(1,ki,iip)
                    cc1(2,ki,l) = ch1(2,ki,1)+wa(1,l-1,1)*ch1(2,ki,2)
                    cc1(2,ki,lc) = wa(1,l-1,2)*ch1(2,ki,iip)
                end do
                do j=3,iipph
                    jc = iipp2-j
                    idlj = mod((l-1)*(j-1),iip)
                    war = wa(1,idlj,1)
                    wai = wa(1,idlj,2)
                    do ki=1,lid
                        cc1(1,ki,l) = cc1(1,ki,l)+war*ch1(1,ki,j)
                        cc1(1,ki,lc) = cc1(1,ki,lc)+wai*ch1(1,ki,jc)
                        cc1(2,ki,l) = cc1(2,ki,l)+war*ch1(2,ki,j)
                        cc1(2,ki,lc) = cc1(2,ki,lc)+wai*ch1(2,ki,jc)
                    end do
                end do
            end do

            if (.not.(1 < ido .or. na == 1)) then

                do j=2,iipph
                    jc = iipp2-j
                    do ki=1,lid
                        chold1 = cc1(1,ki,j)-cc1(2,ki,jc)
                        chold2 = cc1(1,ki,j)+cc1(2,ki,jc)
                        cc1(1,ki,j) = chold1
                        cc1(2,ki,jc) = cc1(2,ki,j)-cc1(1,ki,jc)
                        cc1(2,ki,j) = cc1(2,ki,j)+cc1(1,ki,jc)
                        cc1(1,ki,jc) = chold2
                    end do
                end do
            else
                do ki=1,lid
                    ch1(1,ki,1) = cc1(1,ki,1)
                    ch1(2,ki,1) = cc1(2,ki,1)
                end do

                do j=2,iipph
                    jc = iipp2-j
                    do ki=1,lid
                        ch1(1,ki,j) = cc1(1,ki,j)-cc1(2,ki,jc)
                        ch1(1,ki,jc) = cc1(1,ki,j)+cc1(2,ki,jc)
                        ch1(2,ki,jc) = cc1(2,ki,j)-cc1(1,ki,jc)
                        ch1(2,ki,j) = cc1(2,ki,j)+cc1(1,ki,jc)
                    end do
                end do

                if (ido /= 1) then
                    do i=1,ido
                        do k=1,l1
                            cc(1,k,1,i) = ch(1,k,i,1)
                            cc(2,k,1,i) = ch(2,k,i,1)
                        end do
                    end do

                    do j=2,iip
                        do k=1,l1
                            cc(1,k,j,1) = ch(1,k,1,j)
                            cc(2,k,j,1) = ch(2,k,1,j)
                        end do
                    end do

                    do j=2,iip
                        do i=2,ido
                            do k=1,l1
                                cc(1,k,j,i) = wa(i,j-1,1)*ch(1,k,i,j) &
                                    -wa(i,j-1,2)*ch(2,k,i,j)
                                cc(2,k,j,i) = wa(i,j-1,1)*ch(2,k,i,j) &
                                    +wa(i,j-1,2)*ch(1,k,i,j)
                            end do
                        end do
                    end do
                end if
            end if

        end subroutine c1fgkb

    end subroutine c1fm1b

    subroutine c1fm1f(n, inc, c, ch, wa, fnf, fac)

        real (wp) c(2,*)
        real (wp) ch(*)
        real (wp) fac(*)
        real (wp) fnf
        integer (ip) ido
        integer (ip) inc
        integer (ip) inc2
        integer (ip) iip
        integer (ip) iw
        integer (ip) k1
        integer (ip) l1
        integer (ip) l2
        integer (ip) lid
        integer (ip) n
        integer (ip) na
        integer (ip) nbr
        integer (ip) nf
        real (wp) wa(*)

        inc2 = inc+inc
        nf = int(fnf, kind=ip)
        na = 0
        l1 = 1
        iw = 1

        do k1=1,nf
            iip = int(fac(k1), kind=ip)
            l2 = iip*l1
            ido = n/l2
            lid = l1*ido
            nbr = 1+na+2*min(iip-2,4)
            select case (nbr)
                case (1)
                    call c1f2kf(ido,l1,na,c,inc2,ch,2,wa(iw))
                case (2)
                    call c1f2kf(ido,l1,na,ch,2,c,inc2,wa(iw))
                case (3)
                    call c1f3kf(ido,l1,na,c,inc2,ch,2,wa(iw))
                case (4)
                    call c1f3kf(ido,l1,na,ch,2,c,inc2,wa(iw))
                case (5)
                    call c1f4kf(ido,l1,na,c,inc2,ch,2,wa(iw))
                case (6)
                    call c1f4kf(ido,l1,na,ch,2,c,inc2,wa(iw))
                case (7)
                    call c1f5kf(ido,l1,na,c,inc2,ch,2,wa(iw))
                case (8)
                    call c1f5kf(ido,l1,na,ch,2,c,inc2,wa(iw))
                case (9)
                    call c1fgkf(ido,iip,l1,lid,na,c,c,inc2,ch,ch,2,wa(iw))
                case (10)
                    call c1fgkf(ido,iip,l1,lid,na,ch,ch,2,c,c,inc2,wa(iw))
            end select

            l1 = l2
            iw = iw+(iip-1)*(2*ido)
            if(iip <= 5) then
                na = 1-na
            end if
        end do

    contains

        subroutine c1f2kf(ido, l1, na, cc, in1, ch, in2, wa)
            !----------------------------------------------------------------------
            ! Dictionary: calling arguments
            !----------------------------------------------------------------------
            integer (ip), intent (in)   :: ido
            integer (ip), intent (in)   :: l1
            integer (ip), intent (in)   :: na
            real (wp),  intent (in out) :: cc(in1,l1,ido,2)
            integer (ip), intent (in)   :: in1
            real (wp),  intent (in out) :: ch(in2,l1,2,ido)
            integer (ip), intent (in)   :: in2
            real (wp),  intent (in)   :: wa(ido,1,2)
            !----------------------------------------------------------------------
            ! Dictionary: local variables
            !----------------------------------------------------------------------
            integer (ip) :: i !! counter
            real (wp)  :: sn
            real (wp), allocatable :: temp1(:), temp2(:)
            real (wp), allocatable :: ti2(:), tr2(:)
            !----------------------------------------------------------------------

            if (1 >= ido) then
                sn = 1.0_wp/(2 * l1)
                if (na /= 1) then
                    !
                    !==> Allocate memory
                    !
                    allocate( temp1(l1) )
                    allocate( temp2(l1) )

                    temp1 = sn*(cc(1,:,1,1)+cc(1,:,1,2))
                    cc(1,:,1,2) = sn*(cc(1,:,1,1)-cc(1,:,1,2))
                    cc(1,:,1,1) = temp1
                    temp2 = sn*(cc(2,:,1,1)+cc(2,:,1,2))
                    cc(2,:,1,2) = sn*(cc(2,:,1,1)-cc(2,:,1,2))
                    cc(2,:,1,1) = temp2
                    !
                    !==> Release memory
                    !
                    deallocate( temp1 )
                    deallocate( temp2 )
                else
                    ch(1,:,1,1) = sn*(cc(1,:,1,1)+cc(1,:,1,2))
                    ch(1,:,2,1) = sn*(cc(1,:,1,1)-cc(1,:,1,2))
                    ch(2,:,1,1) = sn*(cc(2,:,1,1)+cc(2,:,1,2))
                    ch(2,:,2,1) = sn*(cc(2,:,1,1)-cc(2,:,1,2))
                end if
            else
                ch(1,:,1,1) = cc(1,:,1,1)+cc(1,:,1,2)
                ch(1,:,2,1) = cc(1,:,1,1)-cc(1,:,1,2)
                ch(2,:,1,1) = cc(2,:,1,1)+cc(2,:,1,2)
                ch(2,:,2,1) = cc(2,:,1,1)-cc(2,:,1,2)
                !
                !==> Allocate memory
                !
                allocate( tr2(l1) )
                allocate( ti2(l1) )

                do i=2,ido
                    ch(1,:,1,i) = cc(1,:,i,1)+cc(1,:,i,2)
                    tr2 = cc(1,:,i,1)-cc(1,:,i,2)
                    ch(2,:,1,i) = cc(2,:,i,1)+cc(2,:,i,2)
                    ti2 = cc(2,:,i,1)-cc(2,:,i,2)
                    ch(2,:,2,i) = wa(i,1,1)*ti2-wa(i,1,2)*tr2
                    ch(1,:,2,i) = wa(i,1,1)*tr2+wa(i,1,2)*ti2
                end do
                !
                !==> Release memory
                !
                deallocate( tr2 )
                deallocate( ti2 )
            end if

        end subroutine c1f2kf


        subroutine c1f3kf(ido, l1, na, cc, in1, ch, in2, wa)
            !----------------------------------------------------------------------
            ! Dictionary: calling arguments
            !----------------------------------------------------------------------
            integer (ip), intent (in)     :: ido
            integer (ip), intent (in)     :: l1
            integer (ip), intent (in)     :: na
            real (wp),    intent (in out) :: cc(in1,l1,ido,3)
            integer (ip), intent (in)     :: in1
            real (wp),    intent (in out) :: ch(in2,l1,3,ido)
            integer (ip), intent (in)     :: in2
            real (wp),    intent (in)     :: wa(ido,2,2)
            !----------------------------------------------------------------------
            ! Dictionary: calling arguments
            !----------------------------------------------------------------------
            integer (ip) :: i !! Counter
            real (wp), allocatable :: ci2(:), ci3(:)
            real (wp), allocatable :: cr2(:), cr3(:)
            real (wp), allocatable :: ti2(:), tr2(:)
            real (wp), parameter :: TAUI = -sqrt(3.0)/2!-0.866025403784439_wp
            real (wp), parameter :: TAUR = -0.5_wp
            real (wp)  :: sn
            !----------------------------------------------------------------------

            !
            !==> Allocate memory
            !
            allocate( ci2(l1), ci3(l1) )
            allocate( cr2(l1), cr3(l1) )
            allocate( ti2(l1), tr2(l1) )

            if ( 1 >= ido ) then
                sn = 1.0_wp/(3 * l1)
                if (na /= 1) then
                    tr2 = cc(1,:,1,2)+cc(1,:,1,3)
                    cr2 = cc(1,:,1,1)+TAUR*tr2
                    cc(1,:,1,1) = sn*(cc(1,:,1,1)+tr2)
                    ti2 = cc(2,:,1,2)+cc(2,:,1,3)
                    ci2 = cc(2,:,1,1)+TAUR*ti2
                    cc(2,:,1,1) = sn*(cc(2,:,1,1)+ti2)
                    cr3 = TAUI*(cc(1,:,1,2)-cc(1,:,1,3))
                    ci3 = TAUI*(cc(2,:,1,2)-cc(2,:,1,3))
                    cc(1,:,1,2) = sn*(cr2-ci3)
                    cc(1,:,1,3) = sn*(cr2+ci3)
                    cc(2,:,1,2) = sn*(ci2+cr3)
                    cc(2,:,1,3) = sn*(ci2-cr3)
                else
                    tr2 = cc(1,:,1,2)+cc(1,:,1,3)
                    cr2 = cc(1,:,1,1)+TAUR*tr2
                    ch(1,:,1,1) = sn*(cc(1,:,1,1)+tr2)
                    ti2 = cc(2,:,1,2)+cc(2,:,1,3)
                    ci2 = cc(2,:,1,1)+TAUR*ti2
                    ch(2,:,1,1) = sn*(cc(2,:,1,1)+ti2)
                    cr3 = TAUI*(cc(1,:,1,2)-cc(1,:,1,3))
                    ci3 = TAUI*(cc(2,:,1,2)-cc(2,:,1,3))
                    ch(1,:,2,1) = sn*(cr2-ci3)
                    ch(1,:,3,1) = sn*(cr2+ci3)
                    ch(2,:,2,1) = sn*(ci2+cr3)
                    ch(2,:,3,1) = sn*(ci2-cr3)
                end if
            else
                tr2 = cc(1,:,1,2)+cc(1,:,1,3)
                cr2 = cc(1,:,1,1)+TAUR*tr2
                ch(1,:,1,1) = cc(1,:,1,1)+tr2
                ti2 = cc(2,:,1,2)+cc(2,:,1,3)
                ci2 = cc(2,:,1,1)+TAUR*ti2
                ch(2,:,1,1) = cc(2,:,1,1)+ti2
                cr3 = TAUI*(cc(1,:,1,2)-cc(1,:,1,3))
                ci3 = TAUI*(cc(2,:,1,2)-cc(2,:,1,3))
                ch(1,:,2,1) = cr2-ci3
                ch(1,:,3,1) = cr2+ci3
                ch(2,:,2,1) = ci2+cr3
                ch(2,:,3,1) = ci2-cr3

                do i=2,ido
                    tr2 = cc(1,:,i,2)+cc(1,:,i,3)
                    cr2 = cc(1,:,i,1)+TAUR*tr2
                    ch(1,:,1,i) = cc(1,:,i,1)+tr2
                    ti2 = cc(2,:,i,2)+cc(2,:,i,3)
                    ci2 = cc(2,:,i,1)+TAUR*ti2
                    ch(2,:,1,i) = cc(2,:,i,1)+ti2
                    cr3 = TAUI*(cc(1,:,i,2)-cc(1,:,i,3))
                    ci3 = TAUI*(cc(2,:,i,2)-cc(2,:,i,3))
                    associate( &
                        dr2 => cr2-ci3, &
                        dr3 => cr2+ci3, &
                        di2 => ci2+cr3, &
                        di3 => ci2-cr3 &
                        )
                        ch(2,:,2,i) = wa(i,1,1)*di2-wa(i,1,2)*dr2
                        ch(1,:,2,i) = wa(i,1,1)*dr2+wa(i,1,2)*di2
                        ch(2,:,3,i) = wa(i,2,1)*di3-wa(i,2,2)*dr3
                        ch(1,:,3,i) = wa(i,2,1)*dr3+wa(i,2,2)*di3
                    end associate
                end do
            end if

            !
            !==> Release memory
            !
            deallocate( ci2, ci3 )
            deallocate( cr2, cr3 )
            deallocate( ti2, tr2 )

        end subroutine c1f3kf


        subroutine c1f4kf(ido, l1, na, cc, in1, ch, in2, wa)
            !----------------------------------------------------------------------
            ! Dictionary: calling arguments
            !----------------------------------------------------------------------
            integer (ip), intent (in)     :: ido
            integer (ip), intent (in)     :: l1
            integer (ip), intent (in)     :: na
            real (wp),    intent (in out) :: cc(in1,l1,ido,4)
            integer (ip), intent (in)     :: in1
            real (wp),    intent (in out) :: ch(in2,l1,4,ido)
            integer (ip), intent (in)     :: in2
            real (wp),    intent (in)     :: wa(ido,3,2)
            !----------------------------------------------------------------------
            ! Dictionary: calling arguments
            !----------------------------------------------------------------------
            integer (ip) :: i
            real (wp)    :: sn
            !----------------------------------------------------------------------

            if (1 >= ido) then
                sn = 1.0_wp/(4 * l1)
                if (na /= 1) then
                    associate(&
                        ti1 => cc(2,:,1,1)-cc(2,:,1,3), &
                        ti2 => cc(2,:,1,1)+cc(2,:,1,3), &
                        tr4 => cc(2,:,1,2)-cc(2,:,1,4), &
                        ti3 => cc(2,:,1,2)+cc(2,:,1,4), &
                        tr1 => cc(1,:,1,1)-cc(1,:,1,3), &
                        tr2 => cc(1,:,1,1)+cc(1,:,1,3), &
                        ti4 => cc(1,:,1,4)-cc(1,:,1,2), &
                        tr3 => cc(1,:,1,2)+cc(1,:,1,4) &
                        )
                        cc(1,:,1,1) = sn*(tr2+tr3)
                        cc(1,:,1,3) = sn*(tr2-tr3)
                        cc(2,:,1,1) = sn*(ti2+ti3)
                        cc(2,:,1,3) = sn*(ti2-ti3)
                        cc(1,:,1,2) = sn*(tr1+tr4)
                        cc(1,:,1,4) = sn*(tr1-tr4)
                        cc(2,:,1,2) = sn*(ti1+ti4)
                        cc(2,:,1,4) = sn*(ti1-ti4)
                    end associate
                else
                    associate( &
                        ti1 => cc(2,:,1,1)-cc(2,:,1,3), &
                        ti2 => cc(2,:,1,1)+cc(2,:,1,3), &
                        tr4 => cc(2,:,1,2)-cc(2,:,1,4), &
                        ti3 => cc(2,:,1,2)+cc(2,:,1,4), &
                        tr1 => cc(1,:,1,1)-cc(1,:,1,3), &
                        tr2 => cc(1,:,1,1)+cc(1,:,1,3), &
                        ti4 => cc(1,:,1,4)-cc(1,:,1,2), &
                        tr3 => cc(1,:,1,2)+cc(1,:,1,4) &
                        )
                        ch(1,:,1,1) = sn*(tr2+tr3)
                        ch(1,:,3,1) = sn*(tr2-tr3)
                        ch(2,:,1,1) = sn*(ti2+ti3)
                        ch(2,:,3,1) = sn*(ti2-ti3)
                        ch(1,:,2,1) = sn*(tr1+tr4)
                        ch(1,:,4,1) = sn*(tr1-tr4)
                        ch(2,:,2,1) = sn*(ti1+ti4)
                        ch(2,:,4,1) = sn*(ti1-ti4)
                    end associate
                end if
            else
                associate( &
                    ti1 => cc(2,:,1,1)-cc(2,:,1,3), &
                    ti2 => cc(2,:,1,1)+cc(2,:,1,3), &
                    tr4 => cc(2,:,1,2)-cc(2,:,1,4), &
                    ti3 => cc(2,:,1,2)+cc(2,:,1,4), &
                    tr1 => cc(1,:,1,1)-cc(1,:,1,3), &
                    tr2 => cc(1,:,1,1)+cc(1,:,1,3), &
                    ti4 => cc(1,:,1,4)-cc(1,:,1,2), &
                    tr3 => cc(1,:,1,2)+cc(1,:,1,4) &
                    )
                    ch(1,:,1,1) = tr2+tr3
                    ch(1,:,3,1) = tr2-tr3
                    ch(2,:,1,1) = ti2+ti3
                    ch(2,:,3,1) = ti2-ti3
                    ch(1,:,2,1) = tr1+tr4
                    ch(1,:,4,1) = tr1-tr4
                    ch(2,:,2,1) = ti1+ti4
                    ch(2,:,4,1) = ti1-ti4
                end associate
                do i=2,ido
                    associate( &
                        ti1 => cc(2,:,i,1)-cc(2,:,i,3), &
                        ti2 => cc(2,:,i,1)+cc(2,:,i,3), &
                        ti3 => cc(2,:,i,2)+cc(2,:,i,4), &
                        tr4 => cc(2,:,i,2)-cc(2,:,i,4), &
                        tr1 => cc(1,:,i,1)-cc(1,:,i,3), &
                        tr2 => cc(1,:,i,1)+cc(1,:,i,3), &
                        ti4 => cc(1,:,i,4)-cc(1,:,i,2), &
                        tr3 => cc(1,:,i,2)+cc(1,:,i,4) &
                        )
                        ch(1,:,1,i) = tr2+tr3
                        associate( cr3 => tr2-tr3 )
                            ch(2,:,1,i) = ti2+ti3
                            associate( &
                                ci3 => ti2-ti3, &
                                cr2 => tr1+tr4, &
                                cr4 => tr1-tr4, &
                                ci2 => ti1+ti4, &
                                ci4 => ti1-ti4 &
                                )
                                ch(1,:,2,i) = wa(i,1,1)*cr2+wa(i,1,2)*ci2
                                ch(2,:,2,i) = wa(i,1,1)*ci2-wa(i,1,2)*cr2
                                ch(1,:,3,i) = wa(i,2,1)*cr3+wa(i,2,2)*ci3
                                ch(2,:,3,i) = wa(i,2,1)*ci3-wa(i,2,2)*cr3
                                ch(1,:,4,i) = wa(i,3,1)*cr4+wa(i,3,2)*ci4
                                ch(2,:,4,i) = wa(i,3,1)*ci4-wa(i,3,2)*cr4
                            end associate
                        end associate
                    end associate
                end do
            end if

        end subroutine c1f4kf


        subroutine c1f5kf(ido, l1, na, cc, in1, ch, in2, wa)

            integer (ip) ido
            integer (ip) in1
            integer (ip) in2
            integer (ip) l1

            real (wp) cc(in1,l1,ido,5)
            real (wp) ch(in2,l1,5,ido)
            real (wp) chold1
            real (wp) chold2
            real (wp) ci2
            real (wp) ci3
            real (wp) ci4
            real (wp) ci5
            real (wp) cr2
            real (wp) cr3
            real (wp) cr4
            real (wp) cr5
            real (wp) di2
            real (wp) di3
            real (wp) di4
            real (wp) di5
            real (wp) dr2
            real (wp) dr3
            real (wp) dr4
            real (wp) dr5
            integer (ip) i
            integer (ip) k
            integer (ip) na
            real (wp) sn
            real (wp) ti2
            real (wp) ti3
            real (wp) ti4
            real (wp) ti5
            real (wp), parameter :: ti11 = -0.9510565162951536_wp
            real (wp), parameter :: ti12 = -0.5877852522924731_wp
            real (wp) tr2
            real (wp) tr3
            real (wp) tr4
            real (wp) tr5
            real (wp), parameter :: tr11 =  0.3090169943749474_wp
            real (wp), parameter :: tr12 = -0.8090169943749474_wp
            real (wp) wa(ido,4,2)

            if ( 1 >= ido ) then
                sn = 1.0_wp/(5 * l1)
                if (na /= 1) then
                    do k=1,l1
                        ti5 = cc(2,k,1,2)-cc(2,k,1,5)
                        ti2 = cc(2,k,1,2)+cc(2,k,1,5)
                        ti4 = cc(2,k,1,3)-cc(2,k,1,4)
                        ti3 = cc(2,k,1,3)+cc(2,k,1,4)
                        tr5 = cc(1,k,1,2)-cc(1,k,1,5)
                        tr2 = cc(1,k,1,2)+cc(1,k,1,5)
                        tr4 = cc(1,k,1,3)-cc(1,k,1,4)
                        tr3 = cc(1,k,1,3)+cc(1,k,1,4)
                        chold1 = sn*(cc(1,k,1,1)+tr2+tr3)
                        chold2 = sn*(cc(2,k,1,1)+ti2+ti3)
                        cr2 = cc(1,k,1,1)+tr11*tr2+tr12*tr3
                        ci2 = cc(2,k,1,1)+tr11*ti2+tr12*ti3
                        cr3 = cc(1,k,1,1)+tr12*tr2+tr11*tr3
                        ci3 = cc(2,k,1,1)+tr12*ti2+tr11*ti3
                        cc(1,k,1,1) = chold1
                        cc(2,k,1,1) = chold2
                        cr5 = ti11*tr5+ti12*tr4
                        ci5 = ti11*ti5+ti12*ti4
                        cr4 = ti12*tr5-ti11*tr4
                        ci4 = ti12*ti5-ti11*ti4
                        cc(1,k,1,2) = sn*(cr2-ci5)
                        cc(1,k,1,5) = sn*(cr2+ci5)
                        cc(2,k,1,2) = sn*(ci2+cr5)
                        cc(2,k,1,3) = sn*(ci3+cr4)
                        cc(1,k,1,3) = sn*(cr3-ci4)
                        cc(1,k,1,4) = sn*(cr3+ci4)
                        cc(2,k,1,4) = sn*(ci3-cr4)
                        cc(2,k,1,5) = sn*(ci2-cr5)
                    end do
                else
                    do k=1,l1
                        ti5 = cc(2,k,1,2)-cc(2,k,1,5)
                        ti2 = cc(2,k,1,2)+cc(2,k,1,5)
                        ti4 = cc(2,k,1,3)-cc(2,k,1,4)
                        ti3 = cc(2,k,1,3)+cc(2,k,1,4)
                        tr5 = cc(1,k,1,2)-cc(1,k,1,5)
                        tr2 = cc(1,k,1,2)+cc(1,k,1,5)
                        tr4 = cc(1,k,1,3)-cc(1,k,1,4)
                        tr3 = cc(1,k,1,3)+cc(1,k,1,4)
                        ch(1,k,1,1) = sn*(cc(1,k,1,1)+tr2+tr3)
                        ch(2,k,1,1) = sn*(cc(2,k,1,1)+ti2+ti3)
                        cr2 = cc(1,k,1,1)+tr11*tr2+tr12*tr3
                        ci2 = cc(2,k,1,1)+tr11*ti2+tr12*ti3
                        cr3 = cc(1,k,1,1)+tr12*tr2+tr11*tr3
                        ci3 = cc(2,k,1,1)+tr12*ti2+tr11*ti3
                        cr5 = ti11*tr5+ti12*tr4
                        ci5 = ti11*ti5+ti12*ti4
                        cr4 = ti12*tr5-ti11*tr4
                        ci4 = ti12*ti5-ti11*ti4
                        ch(1,k,2,1) = sn*(cr2-ci5)
                        ch(1,k,5,1) = sn*(cr2+ci5)
                        ch(2,k,2,1) = sn*(ci2+cr5)
                        ch(2,k,3,1) = sn*(ci3+cr4)
                        ch(1,k,3,1) = sn*(cr3-ci4)
                        ch(1,k,4,1) = sn*(cr3+ci4)
                        ch(2,k,4,1) = sn*(ci3-cr4)
                        ch(2,k,5,1) = sn*(ci2-cr5)
                    end do
                end if
            else
                do k=1,l1
                    ti5 = cc(2,k,1,2)-cc(2,k,1,5)
                    ti2 = cc(2,k,1,2)+cc(2,k,1,5)
                    ti4 = cc(2,k,1,3)-cc(2,k,1,4)
                    ti3 = cc(2,k,1,3)+cc(2,k,1,4)
                    tr5 = cc(1,k,1,2)-cc(1,k,1,5)
                    tr2 = cc(1,k,1,2)+cc(1,k,1,5)
                    tr4 = cc(1,k,1,3)-cc(1,k,1,4)
                    tr3 = cc(1,k,1,3)+cc(1,k,1,4)
                    ch(1,k,1,1) = cc(1,k,1,1)+tr2+tr3
                    ch(2,k,1,1) = cc(2,k,1,1)+ti2+ti3
                    cr2 = cc(1,k,1,1)+tr11*tr2+tr12*tr3
                    ci2 = cc(2,k,1,1)+tr11*ti2+tr12*ti3
                    cr3 = cc(1,k,1,1)+tr12*tr2+tr11*tr3
                    ci3 = cc(2,k,1,1)+tr12*ti2+tr11*ti3
                    cr5 = ti11*tr5+ti12*tr4
                    ci5 = ti11*ti5+ti12*ti4
                    cr4 = ti12*tr5-ti11*tr4
                    ci4 = ti12*ti5-ti11*ti4
                    ch(1,k,2,1) = cr2-ci5
                    ch(1,k,5,1) = cr2+ci5
                    ch(2,k,2,1) = ci2+cr5
                    ch(2,k,3,1) = ci3+cr4
                    ch(1,k,3,1) = cr3-ci4
                    ch(1,k,4,1) = cr3+ci4
                    ch(2,k,4,1) = ci3-cr4
                    ch(2,k,5,1) = ci2-cr5
                end do
                do i=2,ido
                    do k=1,l1
                        ti5 = cc(2,k,i,2)-cc(2,k,i,5)
                        ti2 = cc(2,k,i,2)+cc(2,k,i,5)
                        ti4 = cc(2,k,i,3)-cc(2,k,i,4)
                        ti3 = cc(2,k,i,3)+cc(2,k,i,4)
                        tr5 = cc(1,k,i,2)-cc(1,k,i,5)
                        tr2 = cc(1,k,i,2)+cc(1,k,i,5)
                        tr4 = cc(1,k,i,3)-cc(1,k,i,4)
                        tr3 = cc(1,k,i,3)+cc(1,k,i,4)
                        ch(1,k,1,i) = cc(1,k,i,1)+tr2+tr3
                        ch(2,k,1,i) = cc(2,k,i,1)+ti2+ti3
                        cr2 = cc(1,k,i,1)+tr11*tr2+tr12*tr3
                        ci2 = cc(2,k,i,1)+tr11*ti2+tr12*ti3
                        cr3 = cc(1,k,i,1)+tr12*tr2+tr11*tr3
                        ci3 = cc(2,k,i,1)+tr12*ti2+tr11*ti3
                        cr5 = ti11*tr5+ti12*tr4
                        ci5 = ti11*ti5+ti12*ti4
                        cr4 = ti12*tr5-ti11*tr4
                        ci4 = ti12*ti5-ti11*ti4
                        dr3 = cr3-ci4
                        dr4 = cr3+ci4
                        di3 = ci3+cr4
                        di4 = ci3-cr4
                        dr5 = cr2+ci5
                        dr2 = cr2-ci5
                        di5 = ci2-cr5
                        di2 = ci2+cr5
                        ch(1,k,2,i) = wa(i,1,1)*dr2+wa(i,1,2)*di2
                        ch(2,k,2,i) = wa(i,1,1)*di2-wa(i,1,2)*dr2
                        ch(1,k,3,i) = wa(i,2,1)*dr3+wa(i,2,2)*di3
                        ch(2,k,3,i) = wa(i,2,1)*di3-wa(i,2,2)*dr3
                        ch(1,k,4,i) = wa(i,3,1)*dr4+wa(i,3,2)*di4
                        ch(2,k,4,i) = wa(i,3,1)*di4-wa(i,3,2)*dr4
                        ch(1,k,5,i) = wa(i,4,1)*dr5+wa(i,4,2)*di5
                        ch(2,k,5,i) = wa(i,4,1)*di5-wa(i,4,2)*dr5
                    end do
                end do
            end if

        end subroutine c1f5kf


        subroutine c1fgkf(ido, iip, l1, lid, na, cc, cc1, in1, ch, ch1, in2, wa)

            integer (ip) ido
            integer (ip) in1
            integer (ip) in2
            integer (ip) iip
            integer (ip) l1
            integer (ip) lid

            real (wp) cc(in1,l1,iip,ido)
            real (wp) cc1(in1,lid,iip)
            real (wp) ch(in2,l1,ido,iip)
            real (wp) ch1(in2,lid,iip)
            real (wp) chold1
            real (wp) chold2
            integer (ip) i
            integer (ip) idlj
            integer (ip) iipp2
            integer (ip) iipph
            integer (ip) j
            integer (ip) jc
            integer (ip) k
            integer (ip) ki
            integer (ip) l
            integer (ip) lc
            integer (ip) na
            real (wp) sn
            real (wp) wa(ido,iip-1,2)
            real (wp) wai
            real (wp) war

            iipp2 = iip+2
            iipph = (iip+1)/2
            do ki=1,lid
                ch1(1,ki,1) = cc1(1,ki,1)
                ch1(2,ki,1) = cc1(2,ki,1)
            end do

            do j=2,iipph
                jc = iipp2-j
                do ki=1,lid
                    ch1(1,ki,j) =  cc1(1,ki,j)+cc1(1,ki,jc)
                    ch1(1,ki,jc) = cc1(1,ki,j)-cc1(1,ki,jc)
                    ch1(2,ki,j) =  cc1(2,ki,j)+cc1(2,ki,jc)
                    ch1(2,ki,jc) = cc1(2,ki,j)-cc1(2,ki,jc)
                end do
            end do

            do j=2,iipph
                do ki=1,lid
                    cc1(1,ki,1) = cc1(1,ki,1)+ch1(1,ki,j)
                    cc1(2,ki,1) = cc1(2,ki,1)+ch1(2,ki,j)
                end do
            end do

            do l=2,iipph
                lc = iipp2-l
                do ki=1,lid
                    cc1(1,ki,l) = ch1(1,ki,1)+wa(1,l-1,1)*ch1(1,ki,2)
                    cc1(1,ki,lc) = -wa(1,l-1,2)*ch1(1,ki,iip)
                    cc1(2,ki,l) = ch1(2,ki,1)+wa(1,l-1,1)*ch1(2,ki,2)
                    cc1(2,ki,lc) = -wa(1,l-1,2)*ch1(2,ki,iip)
                end do
                do j=3,iipph
                    jc = iipp2-j
                    idlj = mod((l-1)*(j-1),iip)
                    war = wa(1,idlj,1)
                    wai = -wa(1,idlj,2)
                    do ki=1,lid
                        cc1(1,ki,l) = cc1(1,ki,l)+war*ch1(1,ki,j)
                        cc1(1,ki,lc) = cc1(1,ki,lc)+wai*ch1(1,ki,jc)
                        cc1(2,ki,l) = cc1(2,ki,l)+war*ch1(2,ki,j)
                        cc1(2,ki,lc) = cc1(2,ki,lc)+wai*ch1(2,ki,jc)
                    end do
                end do
            end do

            if ( 1 >= ido )then
                sn = 1.0_wp/(iip * l1)
                if (na /= 1) then
                    do ki=1,lid
                        cc1(1,ki,1) = sn*cc1(1,ki,1)
                        cc1(2,ki,1) = sn*cc1(2,ki,1)
                    end do
                    do j=2,iipph
                        jc = iipp2-j
                        do ki=1,lid
                            chold1 = sn*(cc1(1,ki,j)-cc1(2,ki,jc))
                            chold2 = sn*(cc1(1,ki,j)+cc1(2,ki,jc))
                            cc1(1,ki,j) = chold1
                            cc1(2,ki,jc) = sn*(cc1(2,ki,j)-cc1(1,ki,jc))
                            cc1(2,ki,j) = sn*(cc1(2,ki,j)+cc1(1,ki,jc))
                            cc1(1,ki,jc) = chold2
                        end do
                    end do
                else
                    do ki=1,lid
                        ch1(1,ki,1) = sn*cc1(1,ki,1)
                        ch1(2,ki,1) = sn*cc1(2,ki,1)
                    end do
                    do j=2,iipph
                        jc = iipp2-j
                        do ki=1,lid
                            ch1(1,ki,j) = sn*(cc1(1,ki,j)-cc1(2,ki,jc))
                            ch1(2,ki,j) = sn*(cc1(2,ki,j)+cc1(1,ki,jc))
                            ch1(1,ki,jc) = sn*(cc1(1,ki,j)+cc1(2,ki,jc))
                            ch1(2,ki,jc) = sn*(cc1(2,ki,j)-cc1(1,ki,jc))
                        end do
                    end do
                end if
            else
                do ki=1,lid
                    ch1(1,ki,1) = cc1(1,ki,1)
                    ch1(2,ki,1) = cc1(2,ki,1)
                end do
                do j=2,iipph
                    jc = iipp2-j
                    do ki=1,lid
                        ch1(1,ki,j) = cc1(1,ki,j)-cc1(2,ki,jc)
                        ch1(2,ki,j) = cc1(2,ki,j)+cc1(1,ki,jc)
                        ch1(1,ki,jc) = cc1(1,ki,j)+cc1(2,ki,jc)
                        ch1(2,ki,jc) = cc1(2,ki,j)-cc1(1,ki,jc)
                    end do
                end do
                do i=1,ido
                    do k=1,l1
                        cc(1,k,1,i) = ch(1,k,i,1)
                        cc(2,k,1,i) = ch(2,k,i,1)
                    end do
                end do
                do j=2,iip
                    do k=1,l1
                        cc(1,k,j,1) = ch(1,k,1,j)
                        cc(2,k,j,1) = ch(2,k,1,j)
                    end do
                end do
                do j=2,iip
                    do i=2,ido
                        do k=1,l1
                            cc(1,k,j,i) = wa(i,j-1,1)*ch(1,k,i,j) &
                                +wa(i,j-1,2)*ch(2,k,i,j)
                            cc(2,k,j,i) = wa(i,j-1,1)*ch(2,k,i,j) &
                                -wa(i,j-1,2)*ch(1,k,i,j)
                        end do
                    end do
                end do
            end if

        end subroutine c1fgkf

    end subroutine c1fm1f


    subroutine cfft1f(n, inc, c_hack, lenc, wsave, lensav, work, lenwrk, ier)
        !
        ! CFFT1F: complex 64-bit precision forward fast Fourier transform, 1D.
        !
        !  Purpose:
        !
        !  CFFT1F computes the one-dimensional Fourier transform of a single
        !  periodic sequence within a complex array.  This transform is referred
        !  to as the forward transform or Fourier analysis, transforming the
        !  sequence from physical to spectral space.
        !
        !  This transform is normalized since a call to CFFT1F followed
        !  by a call to CFFT1B (or vice-versa) reproduces the original
        !  array within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer N, the length of the sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations, in
        !  array C, of two consecutive elements within the sequence to be transformed.
        !
        !  Input/output, complex (wp) C(LENC) containing the sequence to
        !  be transformed.
        !
        !  input, integer LENC, the dimension of the C array.
        !  LENC must be at least INC*(N-1) + 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to CFFT1I before the first call to routine CFFT1F
        !  or CFFT1B for a given transform length N.  WSAVE's contents may be re-used
        !  for subsequent calls to CFFT1F and CFFT1B with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least 2*N.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENC not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  20, input error returned by lower level routine.
        !


        integer (ip) lenc
        integer (ip) lensav
        integer (ip) lenwrk
        real (wp) c(2,lenc)
        complex (wp) c_hack(lenc)
        integer (ip) ier
        integer (ip) inc
        integer (ip) iw1
        integer (ip) n
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)

        ! Make copy
        c(1,:) = real(c_hack)
        c(2,:) = aimag(c_hack)

        ier = 0

        if (lenc < inc*(n-1) + 1) then
            ier = 1
            call xerfft('cfft1f ', 4)
        else if (lensav < 2*n + int(log( real(n, kind=wp) ) &
            /log(2.0_wp)) + 4) then
            ier = 2
            call xerfft('cfft1f ', 6)
        else if (lenwrk < 2*n) then
            ier = 3
            call xerfft('cfft1f ', 8)
        end if

        if (n /= 1) then
            iw1 = n+n+1
            call c1fm1f(n,inc,c,work,wsave,wsave(iw1),wsave(iw1+1))

            ! Make copy
            c_hack =  cmplx(c(1,:), c(2,:), kind=wp)
        end if

    end subroutine cfft1f

    subroutine cfft2b(ldim, l, m, c_hack, wsave, lensav, work, lenwrk, ier)
        !
        ! CFFT2B: complex 64-bit precision backward fast Fourier transform, 2D.
        !
        !  Purpose:
        !
        !  CFFT2B computes the two-dimensional discrete Fourier transform of a
        !  complex periodic array.  This transform is known as the backward
        !  transform or Fourier synthesis, transforming from spectral to
        !  physical space.  Routine CFFT2B is normalized, in that a call to
        !  CFFT2B followed by a call to CFFT2F (or vice-versa) reproduces the
        !  original array within roundoff error.
        !
        !  On 10 May 2010, this code was modified by changing the value
        !  of an index into the WSAVE array.
        !
        !  Parameters:
        !
        !  input, integer LDIM, the first dimension of C.
        !
        !  input, integer L, the number of elements to be transformed
        !  in the first dimension of the two-dimensional complex array C.  The value
        !  of L must be less than or equal to that of LDIM.  The transform is
        !  most efficient when L is a product of small primes.
        !
        !  input, integer M, the number of elements to be transformed in
        !  the second dimension of the two-dimensional complex array C.  The transform
        !  is most efficient when M is a product of small primes.
        !
        !  Input/output, complex (wp) C(LDIM,M), on intput, the array of
        !  two dimensions containing the (L,M) subarray to be transformed.  On
        !  output, the transformed data.
        !
        !  Input, real (wp) WSAVE(LENSAV). WSAVE's contents must be
        !  initialized with a call to CFFT2I before the first call to routine CFFT2F
        !  or CFFT2B with transform lengths L and M.  WSAVE's contents may be
        !  re-used for subsequent calls to CFFT2F and CFFT2B with the same
        !  transform lengths L and M.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*(L+M) + INT(LOG(REAL(L)))
        !  + INT(LOG(REAL(M))) + 8.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least 2*L*M.
        !
        !  Output, integer (ip) IER, the error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  5, input parameter LDIM < L;
        !  20, input error returned by lower level routine.
        !

        integer (ip) m
        integer (ip) ldim
        integer (ip) lensav
        integer (ip) lenwrk
        complex (wp) c_hack(ldim,m)
        integer (ip) ier
        integer (ip) ier1
        integer (ip) iw
        integer (ip) l
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) c(2,ldim,m)

        ! Make a copy
        c(1,:,:) = real(c_hack)
        c(2,:,:) = aimag(c_hack)

        ier = 0

        if ( ldim < l ) then
            ier = 5
            call xerfft('cfft2b', -2)
            return
        else if (lensav < 2*l + int(log( real ( l, kind=wp))/log(2.0_wp)) + &
            2*m + int(log( real ( m, kind=wp))/log(2.0_wp)) +8) then
            ier = 2
            call xerfft('cfft2b', 6)
            return
        else if (lenwrk < 2*l*m) then
            ier = 3
            call xerfft('cfft2b', 8)
            return
        end if
        !
        !  transform x lines of c array
        !
        iw = 2*l+int(log( real ( l, kind=wp) )/log(2.0_wp)) + 3

        call cfftmb(l, 1, m, ldim, c, (l-1) + ldim*(m-1) +1, &
            wsave(iw), 2*m + int(log( real ( m, kind=wp))/log(2.0_wp)) + 4, &
            work, 2*l*m, ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('cfft2b',-5)
            return
        end if
        !
        !  transform y lines of c array
        !
        iw = 1

        call cfftmb (m, ldim, l, 1, c, (m-1)*ldim + l, &
            wsave(iw), 2*l + int(log( real ( l, kind=wp) )/log(2.0_wp)) + 4, &
            work, 2*m*l, ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('cfft2b',-5)
        end if

        ! Make copy
        c_hack =  cmplx(c(1,:,:), c(2,:,:), kind=wp)

    end subroutine cfft2b



    subroutine cfft2f(ldim, l, m, c_hack, wsave, lensav, work, lenwrk, ier)


        !
        ! CFFT2F: complex 64-bit precision forward fast Fourier transform, 2D.
        !
        !  Purpose:
        !
        !  CFFT2F computes the two-dimensional discrete Fourier transform of
        !  a complex periodic array. This transform is known as the forward
        !  transform or Fourier analysis, transforming from physical to
        !  spectral space. Routine CFFT2F is normalized, in that a call to
        !  CFFT2F followed by a call to CFFT2B (or vice-versa) reproduces the
        !  original array within roundoff error.
        !
        !  On 10 May 2010, this code was modified by changing the value
        !  of an index into the WSAVE array.
        !
        !
        !  Parameters:
        !
        !  input, integer LDIM, the first dimension of the array C.
        !
        !  input, integer L, the number of elements to be transformed
        !  in the first dimension of the two-dimensional complex array C.  The value
        !  of L must be less than or equal to that of LDIM.  The transform is most
        !  efficient when L is a product of small primes.
        !
        !  input, integer M, the number of elements to be transformed
        !  in the second dimension of the two-dimensional complex array C.  The
        !  transform is most efficient when M is a product of small primes.
        !
        !  Input/output, complex (wp) C(LDIM,M), on input, the array of two
        !  dimensions containing the (L,M) subarray to be transformed.  On output, the
        !  transformed data.
        !
        !  Input, real (wp) WSAVE(LENSAV). WSAVE's contents must be
        !  initialized with a call to CFFT2I before the first call to routine CFFT2F
        !  or CFFT2B with transform lengths L and M.  WSAVE's contents may be re-used
        !  for subsequent calls to CFFT2F and CFFT2B having those same
        !  transform lengths.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*(L+M) + INT(LOG(REAL(L)))
        !  + INT(LOG(REAL(M))) + 8.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least 2*L*M.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  5, input parameter LDIM < L;
        !  20, input error returned by lower level routine.
        !

        integer (ip) m
        integer (ip) ldim
        integer (ip) lensav
        integer (ip) lenwrk

        complex (wp) c_hack(ldim,m)
        integer (ip) ier
        integer (ip) ier1
        integer (ip) iw
        integer (ip) l
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) c(2,ldim,m)

        ! Make a copy
        c(1,:,:)=real(c_hack)
        c(2,:,:)=aimag(c_hack)

        ier = 0

        if ( ldim < l ) then
            ier = 5
            call xerfft('cfft2f', -2)
            return
        else if (lensav < &
            2*l + int(log( real ( l, kind=wp))/log(2.0_wp)) + &
            2*m + int(log( real ( m, kind=wp))/log(2.0_wp)) +8) then
            ier = 2
            call xerfft('cfft2f', 6)
            return
        else if (lenwrk < 2*l*m) then
            ier = 3
            call xerfft('cfft2f', 8)
            return
        end if
        !
        !  transform x lines of c array
        !
        iw = 2*l+int(log( real ( l, kind=wp) )/log(2.0_wp)) + 3

        call cfftmf ( l, 1, m, ldim, c, (l-1) + ldim*(m-1) +1, &
            wsave(iw), &
            2*m + int(log( real ( m, kind=wp) )/log(2.0_wp)) + 4, &
            work, 2*l*m, ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('cfft2f',-5)
            return
        end if
        !
        !  transform y lines of c array
        !
        iw = 1
        call cfftmf (m, ldim, l, 1, c, (m-1)*ldim + l, &
            wsave(iw), 2*l + int(log( real ( l, kind=wp) )/log(2.0_wp)) + 4, &
            work, 2*m*l, ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('cfft2f',-5)
        end if

        ! Make copy
        c_hack =  cmplx(c(1,:,:), c(2,:,:), kind=wp)

    end subroutine cfft2f



    subroutine cfft2i(l, m, wsave, lensav, ier)
        !
        !! CFFT2I: initialization for CFFT2B and CFFT2F.
        !
        !  Purpose:
        !
        !  CFFT2I initializes real array WSAVE for use in its companion
        !  routines CFFT2F and CFFT2B for computing two-dimensional fast
        !  Fourier transforms of complex data.  Prime factorizations of L and M,
        !  together with tabulations of the trigonometric functions, are
        !  computed and stored in array WSAVE.
        !
        !  On 10 May 2010, this code was modified by changing the value
        !  of an index into the WSAVE array.
        !
        !  Parameters:
        !
        !  input, integer L, the number of elements to be transformed
        !  in the first dimension.  The transform is most efficient when L is a
        !  product of small primes.
        !
        !  input, integer M, the number of elements to be transformed
        !  in the second dimension.  The transform is most efficient when M is a
        !  product of small primes.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*(L+M) + INT(LOG(REAL(L)))
        !  + INT(LOG(REAL(M))) + 8.
        !
        !  Output, real (wp) WSAVE(LENSAV), contains the prime factors of L
        !  and M, and also certain trigonometric values which will be used in
        !  routines CFFT2B or CFFT2F.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough;
        !  20, input error returned by lower level routine.
        !


        integer (ip) lensav

        integer (ip) ier
        integer (ip) ier1

        integer (ip) l
        integer (ip) m
        real (wp) wsave(lensav)

        ier = 0

        if ( lensav < 2 * l + int(log(real( l, kind=wp) ) &
            / log(2.0_wp ) ) + 2 * m + int(log(real( m, kind=wp) ) &
            / log(2.0_wp ) ) + 8 ) then
            ier = 2
            call xerfft('cfft2i', 4)
            return
        end if

        call cfftmi(l, wsave(1), 2 * l + int(log(real( l, kind=wp) ) &
            / log(2.0_wp ) ) + 4, ier1 )

        if ( ier1 /= 0) then
            ier = 20
            call xerfft('cfft2i',-5)
            return
        end if

        call cfftmi ( m, &
            wsave(2*l+int(log( real ( l, kind=wp) )/log(2.0_wp)) + 3), &
            2*m + int(log( real ( m, kind=wp) )/log(2.0_wp)) + 4, ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('cfft2i',-5)
        end if

    end subroutine cfft2i



    subroutine cfftmb(lot, jump, n, inc, c, lenc, wsave, lensav, work, &
        lenwrk, ier)
        !
        !! CFFTMB: complex 64-bit precision backward FFT, 1D, multiple vectors.
        !
        !  Purpose:
        !
        !  CFFTMB computes the one-dimensional Fourier transform of multiple
        !  periodic sequences within a complex array.  This transform is referred
        !  to as the backward transform or Fourier synthesis, transforming the
        !  sequences from spectral to physical space.  This transform is
        !  normalized since a call to CFFTMF followed by a call to CFFTMB (or
        !  vice-versa) reproduces the original array within roundoff error.
        !
        !  The parameters INC, JUMP, N and LOT are consistent if equality
        !  I1*INC + J1*JUMP = I2*INC + J2*JUMP for I1,I2 < N and J1,J2 < LOT
        !  implies I1=I2 and J1=J2.  For multiple FFTs to execute correctly,
        !  input variables INC, JUMP, N and LOT must be consistent, otherwise
        !  at least one array element mistakenly is transformed more than once.
        !
        !  Parameters:
        !
        !  input, integer LOT, the number of sequences to be transformed
        !  within array C.
        !
        !  input, integer JUMP, the increment between the locations, in
        !  array C, of the first elements of two consecutive sequences to be
        !  transformed.
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations, in
        !  array C, of two consecutive elements within the same sequence to be
        !  transformed.
        !
        !  Input/output, complex (wp) C(LENC), an array containing LOT
        !  sequences, each having length N, to be transformed.  C can have any
        !  number of dimensions, but the total number of locations must be at least
        !  LENC.  On output, C contains the transformed sequences.
        !
        !  input, integer LENC, the dimension of the C array.
        !  LENC must be at least (LOT-1)*JUMP + INC*(N-1) + 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to CFFTMI before the first call to routine CFFTMF
        !  or CFFTMB for a given transform length N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least 2*LOT*N.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit
        !  1, input parameter LENC not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  4, input parameters INC, JUMP, N, LOT are not consistent.
        !


        integer (ip) lenc
        integer (ip) lensav
        integer (ip) lenwrk

        real (wp) c(2,lenc)
        !complex (wp) c(lenc)
        integer (ip) ier
        integer (ip) inc
        integer (ip) iw1
        integer (ip) jump
        integer (ip) lot
        integer (ip) n
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        !logical xercon

        ier = 0

        if (lenc < (lot-1)*jump + inc*(n-1) + 1) then
            ier = 1
            call xerfft('cfftmb ', 6)
        else if (lensav < 2*n + int(log( real(n, kind=wp)) &
            /log(2.0_wp)) + 4) then
            ier = 2
            call xerfft('cfftmb ', 8)
        else if (lenwrk < 2*lot*n) then
            ier = 3
            call xerfft('cfftmb ', 10)
        else if (.not. xercon(inc,jump,n,lot)) then
            ier = 4
            call xerfft('cfftmb ', -1)
        end if

        if (n == 1) then
            return
        end if

        iw1 = n+n+1

        call cmfm1b(lot,jump,n,inc,c,work,wsave,wsave(iw1),wsave(iw1+1))

        return
    end subroutine cfftmb
    subroutine cfftmf(lot, jump, n, inc, c, lenc, wsave, lensav, work, &
        lenwrk, ier)
        !
        !! CFFTMF: complex 64-bit precision forward FFT, 1D, multiple vectors.
        !
        !  Purpose:
        !
        !  CFFTMF computes the one-dimensional Fourier transform of multiple
        !  periodic sequences within a complex array. This transform is referred
        !  to as the forward transform or Fourier analysis, transforming the
        !  sequences from physical to spectral space. This transform is
        !  normalized since a call to CFFTMF followed by a call to CFFTMB
        !  (or vice-versa) reproduces the original array within roundoff error.
        !
        !  The parameters integers INC, JUMP, N and LOT are consistent if equality
        !  I1*INC + J1*JUMP = I2*INC + J2*JUMP for I1,I2 < N and J1,J2 < LOT
        !  implies I1=I2 and J1=J2. For multiple FFTs to execute correctly,
        !  input variables INC, JUMP, N and LOT must be consistent, otherwise
        !  at least one array element mistakenly is transformed more than once.
        !
        !  Parameters:
        !
        !  input, integer LOT, the number of sequences to be
        !  transformed within array C.
        !
        !  input, integer JUMP, the increment between the locations,
        !  in array C, of the first elements of two consecutive sequences to be
        !  transformed.
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations, in
        !  array C, of two consecutive elements within the same sequence to be
        !  transformed.
        !
        !  Input/output, complex (wp) C(LENC), array containing LOT sequences,
        !  each having length N, to be transformed.  C can have any number of
        !  dimensions, but the total number of locations must be at least LENC.
        !
        !  input, integer LENC, the dimension of the C array.
        !  LENC must be at least (LOT-1)*JUMP + INC*(N-1) + 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to CFFTMI before the first call to routine CFFTMF
        !  or CFFTMB for a given transform length N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least 2*LOT*N.
        !
        !  Output, integer (ip) IER, error flag.
        !  0 successful exit;
        !  1 input parameter LENC not big enough;
        !  2 input parameter LENSAV not big enough;
        !  3 input parameter LENWRK not big enough;
        !  4 input parameters INC, JUMP, N, LOT are not consistent.
        !


        integer (ip) lenc
        integer (ip) lensav
        integer (ip) lenwrk

        real(wp) c(2,lenc)
        !complex (wp) c(lenc)
        integer (ip) ier
        integer (ip) inc
        integer (ip) iw1
        integer (ip) jump
        integer (ip) lot
        integer (ip) n
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        !logical xercon

        ier = 0

        if (lenc < (lot-1)*jump + inc*(n-1) + 1) then
            ier = 1
            call xerfft('cfftmf ', 6)
        else if (lensav < 2*n + int(log( real(n, kind=wp) ) &
            /log(2.0_wp)) + 4) then
            ier = 2
            call xerfft('cfftmf ', 8)
        else if (lenwrk < 2*lot*n) then
            ier = 3
            call xerfft('cfftmf ', 10)
        else if (.not. xercon(inc,jump,n,lot)) then
            ier = 4
            call xerfft('cfftmf ', -1)
        end if

        if (n == 1) then
            return
        end if

        iw1 = n+n+1

        call cmfm1f(lot,jump,n,inc,c,work,wsave,wsave(iw1),wsave(iw1+1))

        return
    end subroutine cfftmf
    subroutine cfftmi(n, wsave, lensav, ier)


        !
        !! CFFTMI: initialization for CFFTMB and CFFTMF.
        !
        !  Purpose:
        !
        !  CFFTMI initializes array WSAVE for use in its companion routines
        !  CFFTMB and CFFTMF.  CFFTMI must be called before the first call
        !  to CFFTMB or CFFTMF, and after whenever the value of integer N changes.
        !
        !  Parameters:
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Output, real (wp) WSAVE(LENSAV), containing the prime factors
        !  of N and also containing certain trigonometric values which will be used in
        !  routines CFFTMB or CFFTMF.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough.
        !


        integer (ip) lensav

        integer (ip) ier
        integer (ip) iw1
        integer (ip) n
        real (wp) wsave(lensav)

        ier = 0

        if (lensav < 2*n + int(log( real(n, kind=wp) )/log(2.0_wp)) + 4) then
            ier = 2
            call xerfft('cfftmi ', 3)
        end if

        if (n /= 1) then
            iw1 = n+n+1
            call mcfti1 (n,wsave,wsave(iw1),wsave(iw1+1))
        end if

    end subroutine cfftmi

    subroutine cmf2kb(lot, ido, l1, na, cc, im1, in1, ch, im2, in2, wa)

        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) l1

        real (wp) cc(2,in1,l1,ido,2)
        real (wp) ch(2,in2,l1,2,ido)
        real (wp) chold1
        real (wp) chold2
        integer (ip) i
        integer (ip) im1
        integer (ip) im2
        integer (ip) k
        integer (ip) lot
        integer (ip) m1
        integer (ip) m1d
        integer (ip) m2
        integer (ip) m2s
        integer (ip) na
        real (wp) ti2
        real (wp) tr2
        real (wp) wa(ido,1,2)

        m1d = (lot-1)*im1+1
        m2s = 1-im2

        if (.not.(1 < ido .or. na == 1)) then
            do k=1,l1
                do m1=1,m1d,im1
                    chold1 = cc(1,m1,k,1,1)+cc(1,m1,k,1,2)
                    cc(1,m1,k,1,2) = cc(1,m1,k,1,1)-cc(1,m1,k,1,2)
                    cc(1,m1,k,1,1) = chold1
                    chold2 = cc(2,m1,k,1,1)+cc(2,m1,k,1,2)
                    cc(2,m1,k,1,2) = cc(2,m1,k,1,1)-cc(2,m1,k,1,2)
                    cc(2,m1,k,1,1) = chold2
                end do
            end do
        else
            do k=1,l1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ch(1,m2,k,1,1) = cc(1,m1,k,1,1)+cc(1,m1,k,1,2)
                    ch(1,m2,k,2,1) = cc(1,m1,k,1,1)-cc(1,m1,k,1,2)
                    ch(2,m2,k,1,1) = cc(2,m1,k,1,1)+cc(2,m1,k,1,2)
                    ch(2,m2,k,2,1) = cc(2,m1,k,1,1)-cc(2,m1,k,1,2)
                end do
            end do

            do i=2,ido
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ch(1,m2,k,1,i) = cc(1,m1,k,i,1)+cc(1,m1,k,i,2)
                        tr2 = cc(1,m1,k,i,1)-cc(1,m1,k,i,2)
                        ch(2,m2,k,1,i) = cc(2,m1,k,i,1)+cc(2,m1,k,i,2)
                        ti2 = cc(2,m1,k,i,1)-cc(2,m1,k,i,2)
                        ch(2,m2,k,2,i) = wa(i,1,1)*ti2+wa(i,1,2)*tr2
                        ch(1,m2,k,2,i) = wa(i,1,1)*tr2-wa(i,1,2)*ti2
                    end do
                end do
            end do
        end if

    end subroutine cmf2kb



    subroutine cmf2kf(lot, ido, l1, na, cc, im1, in1, ch, im2, in2, wa)
        !--------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------
        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) l1
        real (wp) cc(2,in1,l1,ido,2)

        real (wp) ch(2,in2,l1,2,ido)
        real (wp) chold1
        real (wp) chold2

        integer (ip) i
        integer (ip) im1
        integer (ip) im2
        integer (ip) k

        integer (ip) lot
        integer (ip) m1
        integer (ip) m1d
        integer (ip) m2
        integer (ip) m2s

        integer (ip) na
        real (wp) sn
        real (wp) ti2
        real (wp) tr2
        real (wp) wa(ido,1,2)

        m1d = (lot-1)*im1+1
        m2s = 1-im2

        if ( 1 >= ido ) then
            sn = 1.0_wp/(2 * l1)
            if (na /= 1) then
                do k=1,l1
                    do m1=1,m1d,im1
                        chold1 = sn*(cc(1,m1,k,1,1)+cc(1,m1,k,1,2))
                        cc(1,m1,k,1,2) = sn*(cc(1,m1,k,1,1)-cc(1,m1,k,1,2))
                        cc(1,m1,k,1,1) = chold1
                        chold2 = sn*(cc(2,m1,k,1,1)+cc(2,m1,k,1,2))
                        cc(2,m1,k,1,2) = sn*(cc(2,m1,k,1,1)-cc(2,m1,k,1,2))
                        cc(2,m1,k,1,1) = chold2
                    end do
                end do
            else
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ch(1,m2,k,1,1) = sn*(cc(1,m1,k,1,1)+cc(1,m1,k,1,2))
                        ch(1,m2,k,2,1) = sn*(cc(1,m1,k,1,1)-cc(1,m1,k,1,2))
                        ch(2,m2,k,1,1) = sn*(cc(2,m1,k,1,1)+cc(2,m1,k,1,2))
                        ch(2,m2,k,2,1) = sn*(cc(2,m1,k,1,1)-cc(2,m1,k,1,2))
                    end do
                end do
            end if
        else
            do k=1,l1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ch(1,m2,k,1,1) = cc(1,m1,k,1,1)+cc(1,m1,k,1,2)
                    ch(1,m2,k,2,1) = cc(1,m1,k,1,1)-cc(1,m1,k,1,2)
                    ch(2,m2,k,1,1) = cc(2,m1,k,1,1)+cc(2,m1,k,1,2)
                    ch(2,m2,k,2,1) = cc(2,m1,k,1,1)-cc(2,m1,k,1,2)
                end do
            end do

            do i=2,ido
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ch(1,m2,k,1,i) = cc(1,m1,k,i,1)+cc(1,m1,k,i,2)
                        tr2 = cc(1,m1,k,i,1)-cc(1,m1,k,i,2)
                        ch(2,m2,k,1,i) = cc(2,m1,k,i,1)+cc(2,m1,k,i,2)
                        ti2 = cc(2,m1,k,i,1)-cc(2,m1,k,i,2)
                        ch(2,m2,k,2,i) = wa(i,1,1)*ti2-wa(i,1,2)*tr2
                        ch(1,m2,k,2,i) = wa(i,1,1)*tr2+wa(i,1,2)*ti2
                    end do
                end do
            end do
        end if

    end subroutine cmf2kf


    subroutine cmf3kb(lot, ido, l1, na, cc, im1, in1, ch, im2, in2, wa)

        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) l1

        real (wp) cc(2,in1,l1,ido,3)
        real (wp) ch(2,in2,l1,3,ido)
        real (wp) ci2
        real (wp) ci3
        real (wp) cr2
        real (wp) cr3
        real (wp) di2
        real (wp) di3
        real (wp) dr2
        real (wp) dr3
        integer (ip) i
        integer (ip) im1
        integer (ip) im2
        integer (ip) k
        integer (ip) lot
        integer (ip) m1
        integer (ip) m1d
        integer (ip) m2
        integer (ip) m2s
        integer (ip) na
        real (wp), parameter :: taui =  0.866025403784439_wp
        real (wp), parameter :: taur = -0.5_wp
        real (wp) ti2
        real (wp) tr2
        real (wp) wa(ido,2,2)

        m1d = (lot-1)*im1+1
        m2s = 1-im2

        if (.not.(1 < ido .or. na == 1)) then
            do k=1,l1
                do m1=1,m1d,im1
                    tr2 = cc(1,m1,k,1,2)+cc(1,m1,k,1,3)
                    cr2 = cc(1,m1,k,1,1)+taur*tr2
                    cc(1,m1,k,1,1) = cc(1,m1,k,1,1)+tr2
                    ti2 = cc(2,m1,k,1,2)+cc(2,m1,k,1,3)
                    ci2 = cc(2,m1,k,1,1)+taur*ti2
                    cc(2,m1,k,1,1) = cc(2,m1,k,1,1)+ti2
                    cr3 = taui*(cc(1,m1,k,1,2)-cc(1,m1,k,1,3))
                    ci3 = taui*(cc(2,m1,k,1,2)-cc(2,m1,k,1,3))
                    cc(1,m1,k,1,2) = cr2-ci3
                    cc(1,m1,k,1,3) = cr2+ci3
                    cc(2,m1,k,1,2) = ci2+cr3
                    cc(2,m1,k,1,3) = ci2-cr3
                end do
            end do
        else
            do k=1,l1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    tr2 = cc(1,m1,k,1,2)+cc(1,m1,k,1,3)
                    cr2 = cc(1,m1,k,1,1)+taur*tr2
                    ch(1,m2,k,1,1) = cc(1,m1,k,1,1)+tr2
                    ti2 = cc(2,m1,k,1,2)+cc(2,m1,k,1,3)
                    ci2 = cc(2,m1,k,1,1)+taur*ti2
                    ch(2,m2,k,1,1) = cc(2,m1,k,1,1)+ti2
                    cr3 = taui*(cc(1,m1,k,1,2)-cc(1,m1,k,1,3))
                    ci3 = taui*(cc(2,m1,k,1,2)-cc(2,m1,k,1,3))
                    ch(1,m2,k,2,1) = cr2-ci3
                    ch(1,m2,k,3,1) = cr2+ci3
                    ch(2,m2,k,2,1) = ci2+cr3
                    ch(2,m2,k,3,1) = ci2-cr3
                end do
            end do

            do i=2,ido
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        tr2 = cc(1,m1,k,i,2)+cc(1,m1,k,i,3)
                        cr2 = cc(1,m1,k,i,1)+taur*tr2
                        ch(1,m2,k,1,i) = cc(1,m1,k,i,1)+tr2
                        ti2 = cc(2,m1,k,i,2)+cc(2,m1,k,i,3)
                        ci2 = cc(2,m1,k,i,1)+taur*ti2
                        ch(2,m2,k,1,i) = cc(2,m1,k,i,1)+ti2
                        cr3 = taui*(cc(1,m1,k,i,2)-cc(1,m1,k,i,3))
                        ci3 = taui*(cc(2,m1,k,i,2)-cc(2,m1,k,i,3))
                        dr2 = cr2-ci3
                        dr3 = cr2+ci3
                        di2 = ci2+cr3
                        di3 = ci2-cr3
                        ch(2,m2,k,2,i) = wa(i,1,1)*di2+wa(i,1,2)*dr2
                        ch(1,m2,k,2,i) = wa(i,1,1)*dr2-wa(i,1,2)*di2
                        ch(2,m2,k,3,i) = wa(i,2,1)*di3+wa(i,2,2)*dr3
                        ch(1,m2,k,3,i) = wa(i,2,1)*dr3-wa(i,2,2)*di3
                    end do
                end do
            end do
        end if
    end subroutine cmf3kb

    subroutine cmf3kf(lot, ido, l1, na, cc, im1, in1, ch, im2, in2, wa)

        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) l1

        real (wp) cc(2,in1,l1,ido,3)
        real (wp) ch(2,in2,l1,3,ido)
        real (wp) ci2
        real (wp) ci3
        real (wp) cr2
        real (wp) cr3
        real (wp) di2
        real (wp) di3
        real (wp) dr2
        real (wp) dr3
        integer (ip) i
        integer (ip) im1
        integer (ip) im2
        integer (ip) k
        integer (ip) lot
        integer (ip) m1
        integer (ip) m1d
        integer (ip) m2
        integer (ip) m2s
        integer (ip) na
        real (wp) sn
        real (wp), parameter :: taui = -0.866025403784439_wp
        real (wp), parameter :: taur = -0.5_wp
        real (wp) ti2
        real (wp) tr2
        real (wp) wa(ido,2,2)

        m1d = (lot-1)*im1+1
        m2s = 1-im2

        if ( 1 >= ido ) then
            sn = 1.0_wp/(3 * l1)
            if (na /= 1) then
                do k=1,l1
                    do m1=1,m1d,im1
                        tr2 = cc(1,m1,k,1,2)+cc(1,m1,k,1,3)
                        cr2 = cc(1,m1,k,1,1)+taur*tr2
                        cc(1,m1,k,1,1) = sn*(cc(1,m1,k,1,1)+tr2)
                        ti2 = cc(2,m1,k,1,2)+cc(2,m1,k,1,3)
                        ci2 = cc(2,m1,k,1,1)+taur*ti2
                        cc(2,m1,k,1,1) = sn*(cc(2,m1,k,1,1)+ti2)
                        cr3 = taui*(cc(1,m1,k,1,2)-cc(1,m1,k,1,3))
                        ci3 = taui*(cc(2,m1,k,1,2)-cc(2,m1,k,1,3))
                        cc(1,m1,k,1,2) = sn*(cr2-ci3)
                        cc(1,m1,k,1,3) = sn*(cr2+ci3)
                        cc(2,m1,k,1,2) = sn*(ci2+cr3)
                        cc(2,m1,k,1,3) = sn*(ci2-cr3)
                    end do
                end do
            else
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        tr2 = cc(1,m1,k,1,2)+cc(1,m1,k,1,3)
                        cr2 = cc(1,m1,k,1,1)+taur*tr2
                        ch(1,m2,k,1,1) = sn*(cc(1,m1,k,1,1)+tr2)
                        ti2 = cc(2,m1,k,1,2)+cc(2,m1,k,1,3)
                        ci2 = cc(2,m1,k,1,1)+taur*ti2
                        ch(2,m2,k,1,1) = sn*(cc(2,m1,k,1,1)+ti2)
                        cr3 = taui*(cc(1,m1,k,1,2)-cc(1,m1,k,1,3))
                        ci3 = taui*(cc(2,m1,k,1,2)-cc(2,m1,k,1,3))
                        ch(1,m2,k,2,1) = sn*(cr2-ci3)
                        ch(1,m2,k,3,1) = sn*(cr2+ci3)
                        ch(2,m2,k,2,1) = sn*(ci2+cr3)
                        ch(2,m2,k,3,1) = sn*(ci2-cr3)
                    end do
                end do
            end if
        else
            do k=1,l1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    tr2 = cc(1,m1,k,1,2)+cc(1,m1,k,1,3)
                    cr2 = cc(1,m1,k,1,1)+taur*tr2
                    ch(1,m2,k,1,1) = cc(1,m1,k,1,1)+tr2
                    ti2 = cc(2,m1,k,1,2)+cc(2,m1,k,1,3)
                    ci2 = cc(2,m1,k,1,1)+taur*ti2
                    ch(2,m2,k,1,1) = cc(2,m1,k,1,1)+ti2
                    cr3 = taui*(cc(1,m1,k,1,2)-cc(1,m1,k,1,3))
                    ci3 = taui*(cc(2,m1,k,1,2)-cc(2,m1,k,1,3))
                    ch(1,m2,k,2,1) = cr2-ci3
                    ch(1,m2,k,3,1) = cr2+ci3
                    ch(2,m2,k,2,1) = ci2+cr3
                    ch(2,m2,k,3,1) = ci2-cr3
                end do
            end do
            do i=2,ido
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        tr2 = cc(1,m1,k,i,2)+cc(1,m1,k,i,3)
                        cr2 = cc(1,m1,k,i,1)+taur*tr2
                        ch(1,m2,k,1,i) = cc(1,m1,k,i,1)+tr2
                        ti2 = cc(2,m1,k,i,2)+cc(2,m1,k,i,3)
                        ci2 = cc(2,m1,k,i,1)+taur*ti2
                        ch(2,m2,k,1,i) = cc(2,m1,k,i,1)+ti2
                        cr3 = taui*(cc(1,m1,k,i,2)-cc(1,m1,k,i,3))
                        ci3 = taui*(cc(2,m1,k,i,2)-cc(2,m1,k,i,3))
                        dr2 = cr2-ci3
                        dr3 = cr2+ci3
                        di2 = ci2+cr3
                        di3 = ci2-cr3
                        ch(2,m2,k,2,i) = wa(i,1,1)*di2-wa(i,1,2)*dr2
                        ch(1,m2,k,2,i) = wa(i,1,1)*dr2+wa(i,1,2)*di2
                        ch(2,m2,k,3,i) = wa(i,2,1)*di3-wa(i,2,2)*dr3
                        ch(1,m2,k,3,i) = wa(i,2,1)*dr3+wa(i,2,2)*di3
                    end do
                end do
            end do
        end if

    end subroutine cmf3kf

    subroutine cmf4kb(lot, ido, l1, na, cc, im1, in1, ch, im2, in2, wa)

        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) l1

        real (wp) cc(2,in1,l1,ido,4)
        real (wp) ch(2,in2,l1,4,ido)
        real (wp) ci2
        real (wp) ci3
        real (wp) ci4
        real (wp) cr2
        real (wp) cr3
        real (wp) cr4
        integer (ip) i
        integer (ip) im1
        integer (ip) im2
        integer (ip) k
        integer (ip) lot
        integer (ip) m1
        integer (ip) m1d
        integer (ip) m2
        integer (ip) m2s
        integer (ip) na
        real (wp) ti1
        real (wp) ti2
        real (wp) ti3
        real (wp) ti4
        real (wp) tr1
        real (wp) tr2
        real (wp) tr3
        real (wp) tr4
        real (wp) wa(ido,3,2)

        m1d = (lot-1)*im1+1
        m2s = 1-im2

        if (.not.(1 < ido .or. na == 1)) then
            do k=1,l1
                do m1=1,m1d,im1
                    ti1 = cc(2,m1,k,1,1)-cc(2,m1,k,1,3)
                    ti2 = cc(2,m1,k,1,1)+cc(2,m1,k,1,3)
                    tr4 = cc(2,m1,k,1,4)-cc(2,m1,k,1,2)
                    ti3 = cc(2,m1,k,1,2)+cc(2,m1,k,1,4)
                    tr1 = cc(1,m1,k,1,1)-cc(1,m1,k,1,3)
                    tr2 = cc(1,m1,k,1,1)+cc(1,m1,k,1,3)
                    ti4 = cc(1,m1,k,1,2)-cc(1,m1,k,1,4)
                    tr3 = cc(1,m1,k,1,2)+cc(1,m1,k,1,4)
                    cc(1,m1,k,1,1) = tr2+tr3
                    cc(1,m1,k,1,3) = tr2-tr3
                    cc(2,m1,k,1,1) = ti2+ti3
                    cc(2,m1,k,1,3) = ti2-ti3
                    cc(1,m1,k,1,2) = tr1+tr4
                    cc(1,m1,k,1,4) = tr1-tr4
                    cc(2,m1,k,1,2) = ti1+ti4
                    cc(2,m1,k,1,4) = ti1-ti4
                end do
            end do
        else
            do k=1,l1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ti1 = cc(2,m1,k,1,1)-cc(2,m1,k,1,3)
                    ti2 = cc(2,m1,k,1,1)+cc(2,m1,k,1,3)
                    tr4 = cc(2,m1,k,1,4)-cc(2,m1,k,1,2)
                    ti3 = cc(2,m1,k,1,2)+cc(2,m1,k,1,4)
                    tr1 = cc(1,m1,k,1,1)-cc(1,m1,k,1,3)
                    tr2 = cc(1,m1,k,1,1)+cc(1,m1,k,1,3)
                    ti4 = cc(1,m1,k,1,2)-cc(1,m1,k,1,4)
                    tr3 = cc(1,m1,k,1,2)+cc(1,m1,k,1,4)
                    ch(1,m2,k,1,1) = tr2+tr3
                    ch(1,m2,k,3,1) = tr2-tr3
                    ch(2,m2,k,1,1) = ti2+ti3
                    ch(2,m2,k,3,1) = ti2-ti3
                    ch(1,m2,k,2,1) = tr1+tr4
                    ch(1,m2,k,4,1) = tr1-tr4
                    ch(2,m2,k,2,1) = ti1+ti4
                    ch(2,m2,k,4,1) = ti1-ti4
                end do
            end do

            do i=2,ido
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ti1 = cc(2,m1,k,i,1)-cc(2,m1,k,i,3)
                        ti2 = cc(2,m1,k,i,1)+cc(2,m1,k,i,3)
                        ti3 = cc(2,m1,k,i,2)+cc(2,m1,k,i,4)
                        tr4 = cc(2,m1,k,i,4)-cc(2,m1,k,i,2)
                        tr1 = cc(1,m1,k,i,1)-cc(1,m1,k,i,3)
                        tr2 = cc(1,m1,k,i,1)+cc(1,m1,k,i,3)
                        ti4 = cc(1,m1,k,i,2)-cc(1,m1,k,i,4)
                        tr3 = cc(1,m1,k,i,2)+cc(1,m1,k,i,4)
                        ch(1,m2,k,1,i) = tr2+tr3
                        cr3 = tr2-tr3
                        ch(2,m2,k,1,i) = ti2+ti3
                        ci3 = ti2-ti3
                        cr2 = tr1+tr4
                        cr4 = tr1-tr4
                        ci2 = ti1+ti4
                        ci4 = ti1-ti4
                        ch(1,m2,k,2,i) = wa(i,1,1)*cr2-wa(i,1,2)*ci2
                        ch(2,m2,k,2,i) = wa(i,1,1)*ci2+wa(i,1,2)*cr2
                        ch(1,m2,k,3,i) = wa(i,2,1)*cr3-wa(i,2,2)*ci3
                        ch(2,m2,k,3,i) = wa(i,2,1)*ci3+wa(i,2,2)*cr3
                        ch(1,m2,k,4,i) = wa(i,3,1)*cr4-wa(i,3,2)*ci4
                        ch(2,m2,k,4,i) = wa(i,3,1)*ci4+wa(i,3,2)*cr4
                    end do
                end do
            end do
        end if

    end subroutine cmf4kb

    subroutine cmf4kf(lot, ido, l1, na, cc, im1, in1, ch, im2, in2, wa)

        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) l1

        real (wp) cc(2,in1,l1,ido,4)
        real (wp) ch(2,in2,l1,4,ido)
        real (wp) ci2
        real (wp) ci3
        real (wp) ci4
        real (wp) cr2
        real (wp) cr3
        real (wp) cr4
        integer (ip) i
        integer (ip) im1
        integer (ip) im2
        integer (ip) k
        integer (ip) lot
        integer (ip) m1
        integer (ip) m1d
        integer (ip) m2
        integer (ip) m2s
        integer (ip) na
        real (wp) sn
        real (wp) ti1
        real (wp) ti2
        real (wp) ti3
        real (wp) ti4
        real (wp) tr1
        real (wp) tr2
        real (wp) tr3
        real (wp) tr4
        real (wp) wa(ido,3,2)

        m1d = (lot-1)*im1+1
        m2s = 1-im2

        if ( 1 >= ido ) then
            sn = 1.0_wp /(4 * l1)
            if (na /= 1) then
                do k=1,l1
                    do m1=1,m1d,im1
                        ti1 = cc(2,m1,k,1,1)-cc(2,m1,k,1,3)
                        ti2 = cc(2,m1,k,1,1)+cc(2,m1,k,1,3)
                        tr4 = cc(2,m1,k,1,2)-cc(2,m1,k,1,4)
                        ti3 = cc(2,m1,k,1,2)+cc(2,m1,k,1,4)
                        tr1 = cc(1,m1,k,1,1)-cc(1,m1,k,1,3)
                        tr2 = cc(1,m1,k,1,1)+cc(1,m1,k,1,3)
                        ti4 = cc(1,m1,k,1,4)-cc(1,m1,k,1,2)
                        tr3 = cc(1,m1,k,1,2)+cc(1,m1,k,1,4)
                        cc(1,m1,k,1,1) = sn*(tr2+tr3)
                        cc(1,m1,k,1,3) = sn*(tr2-tr3)
                        cc(2,m1,k,1,1) = sn*(ti2+ti3)
                        cc(2,m1,k,1,3) = sn*(ti2-ti3)
                        cc(1,m1,k,1,2) = sn*(tr1+tr4)
                        cc(1,m1,k,1,4) = sn*(tr1-tr4)
                        cc(2,m1,k,1,2) = sn*(ti1+ti4)
                        cc(2,m1,k,1,4) = sn*(ti1-ti4)
                    end do
                end do
            else
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ti1 = cc(2,m1,k,1,1)-cc(2,m1,k,1,3)
                        ti2 = cc(2,m1,k,1,1)+cc(2,m1,k,1,3)
                        tr4 = cc(2,m1,k,1,2)-cc(2,m1,k,1,4)
                        ti3 = cc(2,m1,k,1,2)+cc(2,m1,k,1,4)
                        tr1 = cc(1,m1,k,1,1)-cc(1,m1,k,1,3)
                        tr2 = cc(1,m1,k,1,1)+cc(1,m1,k,1,3)
                        ti4 = cc(1,m1,k,1,4)-cc(1,m1,k,1,2)
                        tr3 = cc(1,m1,k,1,2)+cc(1,m1,k,1,4)
                        ch(1,m2,k,1,1) = sn*(tr2+tr3)
                        ch(1,m2,k,3,1) = sn*(tr2-tr3)
                        ch(2,m2,k,1,1) = sn*(ti2+ti3)
                        ch(2,m2,k,3,1) = sn*(ti2-ti3)
                        ch(1,m2,k,2,1) = sn*(tr1+tr4)
                        ch(1,m2,k,4,1) = sn*(tr1-tr4)
                        ch(2,m2,k,2,1) = sn*(ti1+ti4)
                        ch(2,m2,k,4,1) = sn*(ti1-ti4)
                    end do
                end do
            end if
        else
            do k=1,l1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ti1 = cc(2,m1,k,1,1)-cc(2,m1,k,1,3)
                    ti2 = cc(2,m1,k,1,1)+cc(2,m1,k,1,3)
                    tr4 = cc(2,m1,k,1,2)-cc(2,m1,k,1,4)
                    ti3 = cc(2,m1,k,1,2)+cc(2,m1,k,1,4)
                    tr1 = cc(1,m1,k,1,1)-cc(1,m1,k,1,3)
                    tr2 = cc(1,m1,k,1,1)+cc(1,m1,k,1,3)
                    ti4 = cc(1,m1,k,1,4)-cc(1,m1,k,1,2)
                    tr3 = cc(1,m1,k,1,2)+cc(1,m1,k,1,4)
                    ch(1,m2,k,1,1) = tr2+tr3
                    ch(1,m2,k,3,1) = tr2-tr3
                    ch(2,m2,k,1,1) = ti2+ti3
                    ch(2,m2,k,3,1) = ti2-ti3
                    ch(1,m2,k,2,1) = tr1+tr4
                    ch(1,m2,k,4,1) = tr1-tr4
                    ch(2,m2,k,2,1) = ti1+ti4
                    ch(2,m2,k,4,1) = ti1-ti4
                end do
            end do
            do i=2,ido
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ti1 = cc(2,m1,k,i,1)-cc(2,m1,k,i,3)
                        ti2 = cc(2,m1,k,i,1)+cc(2,m1,k,i,3)
                        ti3 = cc(2,m1,k,i,2)+cc(2,m1,k,i,4)
                        tr4 = cc(2,m1,k,i,2)-cc(2,m1,k,i,4)
                        tr1 = cc(1,m1,k,i,1)-cc(1,m1,k,i,3)
                        tr2 = cc(1,m1,k,i,1)+cc(1,m1,k,i,3)
                        ti4 = cc(1,m1,k,i,4)-cc(1,m1,k,i,2)
                        tr3 = cc(1,m1,k,i,2)+cc(1,m1,k,i,4)
                        ch(1,m2,k,1,i) = tr2+tr3
                        cr3 = tr2-tr3
                        ch(2,m2,k,1,i) = ti2+ti3
                        ci3 = ti2-ti3
                        cr2 = tr1+tr4
                        cr4 = tr1-tr4
                        ci2 = ti1+ti4
                        ci4 = ti1-ti4
                        ch(1,m2,k,2,i) = wa(i,1,1)*cr2+wa(i,1,2)*ci2
                        ch(2,m2,k,2,i) = wa(i,1,1)*ci2-wa(i,1,2)*cr2
                        ch(1,m2,k,3,i) = wa(i,2,1)*cr3+wa(i,2,2)*ci3
                        ch(2,m2,k,3,i) = wa(i,2,1)*ci3-wa(i,2,2)*cr3
                        ch(1,m2,k,4,i) = wa(i,3,1)*cr4+wa(i,3,2)*ci4
                        ch(2,m2,k,4,i) = wa(i,3,1)*ci4-wa(i,3,2)*cr4
                    end do
                end do
            end do
        end if

    end subroutine cmf4kf

    subroutine cmf5kb(lot, ido, l1, na, cc, im1, in1, ch, im2, in2, wa)

        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) l1

        real (wp) cc(2,in1,l1,ido,5)
        real (wp) ch(2,in2,l1,5,ido)
        real (wp) chold1
        real (wp) chold2
        real (wp) ci2
        real (wp) ci3
        real (wp) ci4
        real (wp) ci5
        real (wp) cr2
        real (wp) cr3
        real (wp) cr4
        real (wp) cr5
        real (wp) di2
        real (wp) di3
        real (wp) di4
        real (wp) di5
        real (wp) dr2
        real (wp) dr3
        real (wp) dr4
        real (wp) dr5
        integer (ip) i
        integer (ip) im1
        integer (ip) im2
        integer (ip) k
        integer (ip) lot
        integer (ip) m1
        integer (ip) m1d
        integer (ip) m2
        integer (ip) m2s
        integer (ip) na
        real (wp) ti2
        real (wp) ti3
        real (wp) ti4
        real (wp) ti5
        real (wp), parameter :: ti11 =  0.9510565162951536_wp
        real (wp), parameter :: ti12 =  0.5877852522924731_wp
        real (wp) tr2
        real (wp) tr3
        real (wp) tr4
        real (wp) tr5
        real (wp), parameter :: tr11 =  0.3090169943749474_wp
        real (wp), parameter :: tr12 = -0.8090169943749474_wp
        real (wp) wa(ido,4,2)

        m1d = (lot-1)*im1+1
        m2s = 1-im2

        if (.not.(1 < ido .or. na == 1)) then
            do k=1,l1
                do m1=1,m1d,im1
                    ti5 = cc(2,m1,k,1,2)-cc(2,m1,k,1,5)
                    ti2 = cc(2,m1,k,1,2)+cc(2,m1,k,1,5)
                    ti4 = cc(2,m1,k,1,3)-cc(2,m1,k,1,4)
                    ti3 = cc(2,m1,k,1,3)+cc(2,m1,k,1,4)
                    tr5 = cc(1,m1,k,1,2)-cc(1,m1,k,1,5)
                    tr2 = cc(1,m1,k,1,2)+cc(1,m1,k,1,5)
                    tr4 = cc(1,m1,k,1,3)-cc(1,m1,k,1,4)
                    tr3 = cc(1,m1,k,1,3)+cc(1,m1,k,1,4)
                    chold1 = cc(1,m1,k,1,1)+tr2+tr3
                    chold2 = cc(2,m1,k,1,1)+ti2+ti3
                    cr2 = cc(1,m1,k,1,1)+tr11*tr2+tr12*tr3
                    ci2 = cc(2,m1,k,1,1)+tr11*ti2+tr12*ti3
                    cr3 = cc(1,m1,k,1,1)+tr12*tr2+tr11*tr3
                    ci3 = cc(2,m1,k,1,1)+tr12*ti2+tr11*ti3
                    cc(1,m1,k,1,1) = chold1
                    cc(2,m1,k,1,1) = chold2
                    cr5 = ti11*tr5+ti12*tr4
                    ci5 = ti11*ti5+ti12*ti4
                    cr4 = ti12*tr5-ti11*tr4
                    ci4 = ti12*ti5-ti11*ti4
                    cc(1,m1,k,1,2) = cr2-ci5
                    cc(1,m1,k,1,5) = cr2+ci5
                    cc(2,m1,k,1,2) = ci2+cr5
                    cc(2,m1,k,1,3) = ci3+cr4
                    cc(1,m1,k,1,3) = cr3-ci4
                    cc(1,m1,k,1,4) = cr3+ci4
                    cc(2,m1,k,1,4) = ci3-cr4
                    cc(2,m1,k,1,5) = ci2-cr5
                end do
            end do
        else
            do k=1,l1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ti5 = cc(2,m1,k,1,2)-cc(2,m1,k,1,5)
                    ti2 = cc(2,m1,k,1,2)+cc(2,m1,k,1,5)
                    ti4 = cc(2,m1,k,1,3)-cc(2,m1,k,1,4)
                    ti3 = cc(2,m1,k,1,3)+cc(2,m1,k,1,4)
                    tr5 = cc(1,m1,k,1,2)-cc(1,m1,k,1,5)
                    tr2 = cc(1,m1,k,1,2)+cc(1,m1,k,1,5)
                    tr4 = cc(1,m1,k,1,3)-cc(1,m1,k,1,4)
                    tr3 = cc(1,m1,k,1,3)+cc(1,m1,k,1,4)
                    ch(1,m2,k,1,1) = cc(1,m1,k,1,1)+tr2+tr3
                    ch(2,m2,k,1,1) = cc(2,m1,k,1,1)+ti2+ti3
                    cr2 = cc(1,m1,k,1,1)+tr11*tr2+tr12*tr3
                    ci2 = cc(2,m1,k,1,1)+tr11*ti2+tr12*ti3
                    cr3 = cc(1,m1,k,1,1)+tr12*tr2+tr11*tr3
                    ci3 = cc(2,m1,k,1,1)+tr12*ti2+tr11*ti3
                    cr5 = ti11*tr5+ti12*tr4
                    ci5 = ti11*ti5+ti12*ti4
                    cr4 = ti12*tr5-ti11*tr4
                    ci4 = ti12*ti5-ti11*ti4
                    ch(1,m2,k,2,1) = cr2-ci5
                    ch(1,m2,k,5,1) = cr2+ci5
                    ch(2,m2,k,2,1) = ci2+cr5
                    ch(2,m2,k,3,1) = ci3+cr4
                    ch(1,m2,k,3,1) = cr3-ci4
                    ch(1,m2,k,4,1) = cr3+ci4
                    ch(2,m2,k,4,1) = ci3-cr4
                    ch(2,m2,k,5,1) = ci2-cr5
                end do
            end do

            do i=2,ido
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ti5 = cc(2,m1,k,i,2)-cc(2,m1,k,i,5)
                        ti2 = cc(2,m1,k,i,2)+cc(2,m1,k,i,5)
                        ti4 = cc(2,m1,k,i,3)-cc(2,m1,k,i,4)
                        ti3 = cc(2,m1,k,i,3)+cc(2,m1,k,i,4)
                        tr5 = cc(1,m1,k,i,2)-cc(1,m1,k,i,5)
                        tr2 = cc(1,m1,k,i,2)+cc(1,m1,k,i,5)
                        tr4 = cc(1,m1,k,i,3)-cc(1,m1,k,i,4)
                        tr3 = cc(1,m1,k,i,3)+cc(1,m1,k,i,4)
                        ch(1,m2,k,1,i) = cc(1,m1,k,i,1)+tr2+tr3
                        ch(2,m2,k,1,i) = cc(2,m1,k,i,1)+ti2+ti3
                        cr2 = cc(1,m1,k,i,1)+tr11*tr2+tr12*tr3
                        ci2 = cc(2,m1,k,i,1)+tr11*ti2+tr12*ti3
                        cr3 = cc(1,m1,k,i,1)+tr12*tr2+tr11*tr3
                        ci3 = cc(2,m1,k,i,1)+tr12*ti2+tr11*ti3
                        cr5 = ti11*tr5+ti12*tr4
                        ci5 = ti11*ti5+ti12*ti4
                        cr4 = ti12*tr5-ti11*tr4
                        ci4 = ti12*ti5-ti11*ti4
                        dr3 = cr3-ci4
                        dr4 = cr3+ci4
                        di3 = ci3+cr4
                        di4 = ci3-cr4
                        dr5 = cr2+ci5
                        dr2 = cr2-ci5
                        di5 = ci2-cr5
                        di2 = ci2+cr5
                        ch(1,m2,k,2,i) = wa(i,1,1)*dr2-wa(i,1,2)*di2
                        ch(2,m2,k,2,i) = wa(i,1,1)*di2+wa(i,1,2)*dr2
                        ch(1,m2,k,3,i) = wa(i,2,1)*dr3-wa(i,2,2)*di3
                        ch(2,m2,k,3,i) = wa(i,2,1)*di3+wa(i,2,2)*dr3
                        ch(1,m2,k,4,i) = wa(i,3,1)*dr4-wa(i,3,2)*di4
                        ch(2,m2,k,4,i) = wa(i,3,1)*di4+wa(i,3,2)*dr4
                        ch(1,m2,k,5,i) = wa(i,4,1)*dr5-wa(i,4,2)*di5
                        ch(2,m2,k,5,i) = wa(i,4,1)*di5+wa(i,4,2)*dr5
                    end do
                end do
            end do
        end if

    end subroutine cmf5kb

    subroutine cmf5kf(lot, ido, l1, na, cc, im1, in1, ch, im2, in2, wa)

        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) l1

        real (wp) cc(2,in1,l1,ido,5)
        real (wp) ch(2,in2,l1,5,ido)
        real (wp) chold1
        real (wp) chold2
        real (wp) ci2
        real (wp) ci3
        real (wp) ci4
        real (wp) ci5
        real (wp) cr2
        real (wp) cr3
        real (wp) cr4
        real (wp) cr5
        real (wp) di2
        real (wp) di3
        real (wp) di4
        real (wp) di5
        real (wp) dr2
        real (wp) dr3
        real (wp) dr4
        real (wp) dr5
        integer (ip) i
        integer (ip) im1
        integer (ip) im2
        integer (ip) k
        integer (ip) lot
        integer (ip) m1
        integer (ip) m1d
        integer (ip) m2
        integer (ip) m2s
        integer (ip) na
        real (wp) sn
        real (wp) ti2
        real (wp) ti3
        real (wp) ti4
        real (wp) ti5
        real (wp), parameter :: ti11 = -0.9510565162951536_wp
        real (wp), parameter :: ti12 = -0.5877852522924731_wp
        real (wp) tr2
        real (wp) tr3
        real (wp) tr4
        real (wp) tr5
        real (wp), parameter :: tr11 =  0.3090169943749474_wp
        real (wp), parameter :: tr12 = -0.8090169943749474_wp
        real (wp) wa(ido,4,2)

        m1d = (lot-1)*im1+1
        m2s = 1-im2

        if ( 1 >= ido ) then
            sn = 1.0_wp/(5 * l1)
            if (na /= 1) then
                do k=1,l1
                    do m1=1,m1d,im1
                        ti5 = cc(2,m1,k,1,2)-cc(2,m1,k,1,5)
                        ti2 = cc(2,m1,k,1,2)+cc(2,m1,k,1,5)
                        ti4 = cc(2,m1,k,1,3)-cc(2,m1,k,1,4)
                        ti3 = cc(2,m1,k,1,3)+cc(2,m1,k,1,4)
                        tr5 = cc(1,m1,k,1,2)-cc(1,m1,k,1,5)
                        tr2 = cc(1,m1,k,1,2)+cc(1,m1,k,1,5)
                        tr4 = cc(1,m1,k,1,3)-cc(1,m1,k,1,4)
                        tr3 = cc(1,m1,k,1,3)+cc(1,m1,k,1,4)
                        chold1 = sn*(cc(1,m1,k,1,1)+tr2+tr3)
                        chold2 = sn*(cc(2,m1,k,1,1)+ti2+ti3)
                        cr2 = cc(1,m1,k,1,1)+tr11*tr2+tr12*tr3
                        ci2 = cc(2,m1,k,1,1)+tr11*ti2+tr12*ti3
                        cr3 = cc(1,m1,k,1,1)+tr12*tr2+tr11*tr3
                        ci3 = cc(2,m1,k,1,1)+tr12*ti2+tr11*ti3
                        cc(1,m1,k,1,1) = chold1
                        cc(2,m1,k,1,1) = chold2
                        cr5 = ti11*tr5+ti12*tr4
                        ci5 = ti11*ti5+ti12*ti4
                        cr4 = ti12*tr5-ti11*tr4
                        ci4 = ti12*ti5-ti11*ti4
                        cc(1,m1,k,1,2) = sn*(cr2-ci5)
                        cc(1,m1,k,1,5) = sn*(cr2+ci5)
                        cc(2,m1,k,1,2) = sn*(ci2+cr5)
                        cc(2,m1,k,1,3) = sn*(ci3+cr4)
                        cc(1,m1,k,1,3) = sn*(cr3-ci4)
                        cc(1,m1,k,1,4) = sn*(cr3+ci4)
                        cc(2,m1,k,1,4) = sn*(ci3-cr4)
                        cc(2,m1,k,1,5) = sn*(ci2-cr5)
                    end do
                end do
            else
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ti5 = cc(2,m1,k,1,2)-cc(2,m1,k,1,5)
                        ti2 = cc(2,m1,k,1,2)+cc(2,m1,k,1,5)
                        ti4 = cc(2,m1,k,1,3)-cc(2,m1,k,1,4)
                        ti3 = cc(2,m1,k,1,3)+cc(2,m1,k,1,4)
                        tr5 = cc(1,m1,k,1,2)-cc(1,m1,k,1,5)
                        tr2 = cc(1,m1,k,1,2)+cc(1,m1,k,1,5)
                        tr4 = cc(1,m1,k,1,3)-cc(1,m1,k,1,4)
                        tr3 = cc(1,m1,k,1,3)+cc(1,m1,k,1,4)
                        ch(1,m2,k,1,1) = sn*(cc(1,m1,k,1,1)+tr2+tr3)
                        ch(2,m2,k,1,1) = sn*(cc(2,m1,k,1,1)+ti2+ti3)
                        cr2 = cc(1,m1,k,1,1)+tr11*tr2+tr12*tr3
                        ci2 = cc(2,m1,k,1,1)+tr11*ti2+tr12*ti3
                        cr3 = cc(1,m1,k,1,1)+tr12*tr2+tr11*tr3
                        ci3 = cc(2,m1,k,1,1)+tr12*ti2+tr11*ti3
                        cr5 = ti11*tr5+ti12*tr4
                        ci5 = ti11*ti5+ti12*ti4
                        cr4 = ti12*tr5-ti11*tr4
                        ci4 = ti12*ti5-ti11*ti4
                        ch(1,m2,k,2,1) = sn*(cr2-ci5)
                        ch(1,m2,k,5,1) = sn*(cr2+ci5)
                        ch(2,m2,k,2,1) = sn*(ci2+cr5)
                        ch(2,m2,k,3,1) = sn*(ci3+cr4)
                        ch(1,m2,k,3,1) = sn*(cr3-ci4)
                        ch(1,m2,k,4,1) = sn*(cr3+ci4)
                        ch(2,m2,k,4,1) = sn*(ci3-cr4)
                        ch(2,m2,k,5,1) = sn*(ci2-cr5)
                    end do
                end do
            end if
        else
            do k=1,l1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ti5 = cc(2,m1,k,1,2)-cc(2,m1,k,1,5)
                    ti2 = cc(2,m1,k,1,2)+cc(2,m1,k,1,5)
                    ti4 = cc(2,m1,k,1,3)-cc(2,m1,k,1,4)
                    ti3 = cc(2,m1,k,1,3)+cc(2,m1,k,1,4)
                    tr5 = cc(1,m1,k,1,2)-cc(1,m1,k,1,5)
                    tr2 = cc(1,m1,k,1,2)+cc(1,m1,k,1,5)
                    tr4 = cc(1,m1,k,1,3)-cc(1,m1,k,1,4)
                    tr3 = cc(1,m1,k,1,3)+cc(1,m1,k,1,4)
                    ch(1,m2,k,1,1) = cc(1,m1,k,1,1)+tr2+tr3
                    ch(2,m2,k,1,1) = cc(2,m1,k,1,1)+ti2+ti3
                    cr2 = cc(1,m1,k,1,1)+tr11*tr2+tr12*tr3
                    ci2 = cc(2,m1,k,1,1)+tr11*ti2+tr12*ti3
                    cr3 = cc(1,m1,k,1,1)+tr12*tr2+tr11*tr3
                    ci3 = cc(2,m1,k,1,1)+tr12*ti2+tr11*ti3
                    cr5 = ti11*tr5+ti12*tr4
                    ci5 = ti11*ti5+ti12*ti4
                    cr4 = ti12*tr5-ti11*tr4
                    ci4 = ti12*ti5-ti11*ti4
                    ch(1,m2,k,2,1) = cr2-ci5
                    ch(1,m2,k,5,1) = cr2+ci5
                    ch(2,m2,k,2,1) = ci2+cr5
                    ch(2,m2,k,3,1) = ci3+cr4
                    ch(1,m2,k,3,1) = cr3-ci4
                    ch(1,m2,k,4,1) = cr3+ci4
                    ch(2,m2,k,4,1) = ci3-cr4
                    ch(2,m2,k,5,1) = ci2-cr5
                end do
            end do
            do i=2,ido
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ti5 = cc(2,m1,k,i,2)-cc(2,m1,k,i,5)
                        ti2 = cc(2,m1,k,i,2)+cc(2,m1,k,i,5)
                        ti4 = cc(2,m1,k,i,3)-cc(2,m1,k,i,4)
                        ti3 = cc(2,m1,k,i,3)+cc(2,m1,k,i,4)
                        tr5 = cc(1,m1,k,i,2)-cc(1,m1,k,i,5)
                        tr2 = cc(1,m1,k,i,2)+cc(1,m1,k,i,5)
                        tr4 = cc(1,m1,k,i,3)-cc(1,m1,k,i,4)
                        tr3 = cc(1,m1,k,i,3)+cc(1,m1,k,i,4)
                        ch(1,m2,k,1,i) = cc(1,m1,k,i,1)+tr2+tr3
                        ch(2,m2,k,1,i) = cc(2,m1,k,i,1)+ti2+ti3
                        cr2 = cc(1,m1,k,i,1)+tr11*tr2+tr12*tr3
                        ci2 = cc(2,m1,k,i,1)+tr11*ti2+tr12*ti3
                        cr3 = cc(1,m1,k,i,1)+tr12*tr2+tr11*tr3
                        ci3 = cc(2,m1,k,i,1)+tr12*ti2+tr11*ti3
                        cr5 = ti11*tr5+ti12*tr4
                        ci5 = ti11*ti5+ti12*ti4
                        cr4 = ti12*tr5-ti11*tr4
                        ci4 = ti12*ti5-ti11*ti4
                        dr3 = cr3-ci4
                        dr4 = cr3+ci4
                        di3 = ci3+cr4
                        di4 = ci3-cr4
                        dr5 = cr2+ci5
                        dr2 = cr2-ci5
                        di5 = ci2-cr5
                        di2 = ci2+cr5
                        ch(1,m2,k,2,i) = wa(i,1,1)*dr2+wa(i,1,2)*di2
                        ch(2,m2,k,2,i) = wa(i,1,1)*di2-wa(i,1,2)*dr2
                        ch(1,m2,k,3,i) = wa(i,2,1)*dr3+wa(i,2,2)*di3
                        ch(2,m2,k,3,i) = wa(i,2,1)*di3-wa(i,2,2)*dr3
                        ch(1,m2,k,4,i) = wa(i,3,1)*dr4+wa(i,3,2)*di4
                        ch(2,m2,k,4,i) = wa(i,3,1)*di4-wa(i,3,2)*dr4
                        ch(1,m2,k,5,i) = wa(i,4,1)*dr5+wa(i,4,2)*di5
                        ch(2,m2,k,5,i) = wa(i,4,1)*di5-wa(i,4,2)*dr5
                    end do
                end do
            end do
        end if

    end subroutine cmf5kf

    subroutine cmfgkb(lot, ido, iip, l1, lid, na, cc, cc1, im1, in1, &
        ch, ch1, im2, in2, wa)

        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) iip
        integer (ip) l1
        integer (ip) lid

        real (wp) cc(2,in1,l1,iip,ido)
        real (wp) cc1(2,in1,lid,iip)
        real (wp) ch(2,in2,l1,ido,iip)
        real (wp) ch1(2,in2,lid,iip)
        real (wp) chold1
        real (wp) chold2
        integer (ip) i
        integer (ip) idlj
        integer (ip) im1
        integer (ip) im2
        integer (ip) iipp2
        integer (ip) iipph
        integer (ip) j
        integer (ip) jc
        integer (ip) k
        integer (ip) ki
        integer (ip) l
        integer (ip) lc
        integer (ip) lot
        integer (ip) m1
        integer (ip) m1d
        integer (ip) m2
        integer (ip) m2s
        integer (ip) na
        real (wp) wa(ido,iip-1,2)
        real (wp) wai
        real (wp) war

        m1d = (lot-1)*im1+1
        m2s = 1-im2
        iipp2 = iip+2
        iipph = (iip+1)/2

        do ki=1,lid
            m2 = m2s
            do m1=1,m1d,im1
                m2 = m2+im2
                ch1(1,m2,ki,1) = cc1(1,m1,ki,1)
                ch1(2,m2,ki,1) = cc1(2,m1,ki,1)
            end do
        end do

        do j=2,iipph
            jc = iipp2-j
            do ki=1,lid
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ch1(1,m2,ki,j) =  cc1(1,m1,ki,j)+cc1(1,m1,ki,jc)
                    ch1(1,m2,ki,jc) = cc1(1,m1,ki,j)-cc1(1,m1,ki,jc)
                    ch1(2,m2,ki,j) =  cc1(2,m1,ki,j)+cc1(2,m1,ki,jc)
                    ch1(2,m2,ki,jc) = cc1(2,m1,ki,j)-cc1(2,m1,ki,jc)
                end do
            end do
        end do

        do j=2,iipph
            do ki=1,lid
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    cc1(1,m1,ki,1) = cc1(1,m1,ki,1)+ch1(1,m2,ki,j)
                    cc1(2,m1,ki,1) = cc1(2,m1,ki,1)+ch1(2,m2,ki,j)
                end do
            end do
        end do

        do l=2,iipph
            lc = iipp2-l
            do ki=1,lid
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    cc1(1,m1,ki,l) = ch1(1,m2,ki,1)+wa(1,l-1,1)*ch1(1,m2,ki,2)
                    cc1(1,m1,ki,lc) = wa(1,l-1,2)*ch1(1,m2,ki,iip)
                    cc1(2,m1,ki,l) = ch1(2,m2,ki,1)+wa(1,l-1,1)*ch1(2,m2,ki,2)
                    cc1(2,m1,ki,lc) = wa(1,l-1,2)*ch1(2,m2,ki,iip)
                end do
            end do
            do j=3,iipph
                jc = iipp2-j
                idlj = mod((l-1)*(j-1),iip)
                war = wa(1,idlj,1)
                wai = wa(1,idlj,2)
                do ki=1,lid
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        cc1(1,m1,ki,l) = cc1(1,m1,ki,l)+war*ch1(1,m2,ki,j)
                        cc1(1,m1,ki,lc) = cc1(1,m1,ki,lc)+wai*ch1(1,m2,ki,jc)
                        cc1(2,m1,ki,l) = cc1(2,m1,ki,l)+war*ch1(2,m2,ki,j)
                        cc1(2,m1,ki,lc) = cc1(2,m1,ki,lc)+wai*ch1(2,m2,ki,jc)
                    end do
                end do
            end do
        end do

        if (.not.(1 < ido .or. na == 1)) then
            do j=2,iipph
                jc = iipp2-j
                do ki=1,lid
                    do m1=1,m1d,im1
                        chold1 = cc1(1,m1,ki,j)-cc1(2,m1,ki,jc)
                        chold2 = cc1(1,m1,ki,j)+cc1(2,m1,ki,jc)
                        cc1(1,m1,ki,j) = chold1
                        cc1(2,m1,ki,jc) = cc1(2,m1,ki,j)-cc1(1,m1,ki,jc)
                        cc1(2,m1,ki,j) = cc1(2,m1,ki,j)+cc1(1,m1,ki,jc)
                        cc1(1,m1,ki,jc) = chold2
                    end do
                end do
            end do
        else
            do ki=1,lid
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ch1(1,m2,ki,1) = cc1(1,m1,ki,1)
                    ch1(2,m2,ki,1) = cc1(2,m1,ki,1)
                end do
            end do

            do j=2,iipph
                jc = iipp2-j
                do ki=1,lid
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ch1(1,m2,ki,j) = cc1(1,m1,ki,j)-cc1(2,m1,ki,jc)
                        ch1(1,m2,ki,jc) = cc1(1,m1,ki,j)+cc1(2,m1,ki,jc)
                        ch1(2,m2,ki,jc) = cc1(2,m1,ki,j)-cc1(1,m1,ki,jc)
                        ch1(2,m2,ki,j) = cc1(2,m1,ki,j)+cc1(1,m1,ki,jc)
                    end do
                end do
            end do

            if (ido /= 1) then
                do i=1,ido
                    do k=1,l1
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            cc(1,m1,k,1,i) = ch(1,m2,k,i,1)
                            cc(2,m1,k,1,i) = ch(2,m2,k,i,1)
                        end do
                    end do
                end do

                do j=2,iip
                    do k=1,l1
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            cc(1,m1,k,j,1) = ch(1,m2,k,1,j)
                            cc(2,m1,k,j,1) = ch(2,m2,k,1,j)
                        end do
                    end do
                end do

                do j=2,iip
                    do i=2,ido
                        do k=1,l1
                            m2 = m2s
                            do m1=1,m1d,im1
                                m2 = m2+im2
                                cc(1,m1,k,j,i) = wa(i,j-1,1)*ch(1,m2,k,i,j) &
                                    -wa(i,j-1,2)*ch(2,m2,k,i,j)
                                cc(2,m1,k,j,i) = wa(i,j-1,1)*ch(2,m2,k,i,j) &
                                    +wa(i,j-1,2)*ch(1,m2,k,i,j)
                            end do
                        end do
                    end do
                end do
            end if
        end if

    end subroutine cmfgkb

    subroutine cmfgkf(lot, ido, iip, l1, lid, na, cc, cc1, im1, in1, &
        ch, ch1, im2, in2, wa)

        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) iip
        integer (ip) l1
        integer (ip) lid

        real (wp) cc(2,in1,l1,iip,ido)
        real (wp) cc1(2,in1,lid,iip)
        real (wp) ch(2,in2,l1,ido,iip)
        real (wp) ch1(2,in2,lid,iip)
        real (wp) chold1
        real (wp) chold2
        integer (ip) i
        integer (ip) idlj
        integer (ip) im1
        integer (ip) im2
        integer (ip) iipp2
        integer (ip) iipph
        integer (ip) j
        integer (ip) jc
        integer (ip) k
        integer (ip) ki
        integer (ip) l
        integer (ip) lc
        integer (ip) lot
        integer (ip) m1
        integer (ip) m1d
        integer (ip) m2
        integer (ip) m2s
        integer (ip) na
        real (wp) sn
        real (wp) wa(ido,iip-1,2)
        real (wp) wai
        real (wp) war

        m1d = (lot-1)*im1+1
        m2s = 1-im2
        iipp2 = iip+2
        iipph = (iip+1)/2

        do  ki=1,lid
            m2 = m2s
            do m1=1,m1d,im1
                m2 = m2+im2
                ch1(1,m2,ki,1) = cc1(1,m1,ki,1)
                ch1(2,m2,ki,1) = cc1(2,m1,ki,1)
            end do
        end do

        do j=2,iipph
            jc = iipp2-j
            do ki=1,lid
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ch1(1,m2,ki,j) =  cc1(1,m1,ki,j)+cc1(1,m1,ki,jc)
                    ch1(1,m2,ki,jc) = cc1(1,m1,ki,j)-cc1(1,m1,ki,jc)
                    ch1(2,m2,ki,j) =  cc1(2,m1,ki,j)+cc1(2,m1,ki,jc)
                    ch1(2,m2,ki,jc) = cc1(2,m1,ki,j)-cc1(2,m1,ki,jc)
                end do
            end do
        end do

        do j=2,iipph
            do ki=1,lid
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    cc1(1,m1,ki,1) = cc1(1,m1,ki,1)+ch1(1,m2,ki,j)
                    cc1(2,m1,ki,1) = cc1(2,m1,ki,1)+ch1(2,m2,ki,j)
                end do
            end do
        end do

        do l=2,iipph
            lc = iipp2-l
            do ki=1,lid
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    cc1(1,m1,ki,l) = ch1(1,m2,ki,1)+wa(1,l-1,1)*ch1(1,m2,ki,2)
                    cc1(1,m1,ki,lc) = -wa(1,l-1,2)*ch1(1,m2,ki,iip)
                    cc1(2,m1,ki,l) = ch1(2,m2,ki,1)+wa(1,l-1,1)*ch1(2,m2,ki,2)
                    cc1(2,m1,ki,lc) = -wa(1,l-1,2)*ch1(2,m2,ki,iip)
                end do
            end do
            do j=3,iipph
                jc = iipp2-j
                idlj = mod((l-1)*(j-1),iip)
                war = wa(1,idlj,1)
                wai = -wa(1,idlj,2)
                do ki=1,lid
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        cc1(1,m1,ki,l) = cc1(1,m1,ki,l)+war*ch1(1,m2,ki,j)
                        cc1(1,m1,ki,lc) = cc1(1,m1,ki,lc)+wai*ch1(1,m2,ki,jc)
                        cc1(2,m1,ki,l) = cc1(2,m1,ki,l)+war*ch1(2,m2,ki,j)
                        cc1(2,m1,ki,lc) = cc1(2,m1,ki,lc)+wai*ch1(2,m2,ki,jc)
                    end do
                end do
            end do
        end do

        if ( 1 >= ido ) then
            sn = 1.0_wp /(iip * l1)
            if (na /= 1) then
                do ki=1,lid
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        cc1(1,m1,ki,1) = sn*cc1(1,m1,ki,1)
                        cc1(2,m1,ki,1) = sn*cc1(2,m1,ki,1)
                    end do
                end do
                do j=2,iipph
                    jc = iipp2-j
                    do ki=1,lid
                        do m1=1,m1d,im1
                            chold1 = sn*(cc1(1,m1,ki,j)-cc1(2,m1,ki,jc))
                            chold2 = sn*(cc1(1,m1,ki,j)+cc1(2,m1,ki,jc))
                            cc1(1,m1,ki,j) = chold1
                            cc1(2,m1,ki,jc) = sn*(cc1(2,m1,ki,j)-cc1(1,m1,ki,jc))
                            cc1(2,m1,ki,j) = sn*(cc1(2,m1,ki,j)+cc1(1,m1,ki,jc))
                            cc1(1,m1,ki,jc) = chold2
                        end do
                    end do
                end do
            else
                do ki=1,lid
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ch1(1,m2,ki,1) = sn*cc1(1,m1,ki,1)
                        ch1(2,m2,ki,1) = sn*cc1(2,m1,ki,1)
                    end do
                end do
                do j=2,iipph
                    jc = iipp2-j
                    do ki=1,lid
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            ch1(1,m2,ki,j) = sn*(cc1(1,m1,ki,j)-cc1(2,m1,ki,jc))
                            ch1(2,m2,ki,j) = sn*(cc1(2,m1,ki,j)+cc1(1,m1,ki,jc))
                            ch1(1,m2,ki,jc) = sn*(cc1(1,m1,ki,j)+cc1(2,m1,ki,jc))
                            ch1(2,m2,ki,jc) = sn*(cc1(2,m1,ki,j)-cc1(1,m1,ki,jc))
                        end do
                    end do
                end do
            end if
        else
            do ki=1,lid
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ch1(1,m2,ki,1) = cc1(1,m1,ki,1)
                    ch1(2,m2,ki,1) = cc1(2,m1,ki,1)
                end do
            end do
            do j=2,iipph
                jc = iipp2-j
                do ki=1,lid
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ch1(1,m2,ki,j) = cc1(1,m1,ki,j)-cc1(2,m1,ki,jc)
                        ch1(2,m2,ki,j) = cc1(2,m1,ki,j)+cc1(1,m1,ki,jc)
                        ch1(1,m2,ki,jc) = cc1(1,m1,ki,j)+cc1(2,m1,ki,jc)
                        ch1(2,m2,ki,jc) = cc1(2,m1,ki,j)-cc1(1,m1,ki,jc)
                    end do
                end do
            end do
            do i=1,ido
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        cc(1,m1,k,1,i) = ch(1,m2,k,i,1)
                        cc(2,m1,k,1,i) = ch(2,m2,k,i,1)
                    end do
                end do
            end do
            do j=2,iip
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        cc(1,m1,k,j,1) = ch(1,m2,k,1,j)
                        cc(2,m1,k,j,1) = ch(2,m2,k,1,j)
                    end do
                end do
            end do
            do j=2,iip
                do i=2,ido
                    do k=1,l1
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            cc(1,m1,k,j,i) = wa(i,j-1,1)*ch(1,m2,k,i,j) &
                                +wa(i,j-1,2)*ch(2,m2,k,i,j)
                            cc(2,m1,k,j,i) = wa(i,j-1,1)*ch(2,m2,k,i,j) &
                                -wa(i,j-1,2)*ch(1,m2,k,i,j)
                        end do
                    end do
                end do
            end do
        end if

    end subroutine cmfgkf

    subroutine cmfm1b(lot, jump, n, inc, c, ch, wa, fnf, fac)

        real (wp) c(2,*)
        real (wp) ch(*)
        real (wp) fac(*)
        real (wp) fnf
        integer (ip) ido
        integer (ip) inc
        integer (ip) iip
        integer (ip) iw
        integer (ip) jump
        integer (ip) k1
        integer (ip) l1
        integer (ip) l2
        integer (ip) lid
        integer (ip) lot
        integer (ip) n
        integer (ip) na
        integer (ip) nbr
        integer (ip) nf
        real (wp) wa(*)

        nf = int(fnf, kind=ip)
        na = 0
        l1 = 1
        iw = 1
        do k1=1,nf
            iip = int(fac(k1), kind=ip)
            l2 = iip*l1
            ido = n/l2
            lid = l1*ido
            nbr = 1+na+2*min(iip-2,4)

            select case (nbr)
                case (1)
                    call cmf2kb(lot,ido,l1,na,c,jump,inc,ch,1,lot,wa(iw))
                case (2)
                    call cmf2kb(lot,ido,l1,na,ch,1,lot,c,jump,inc,wa(iw))
                case (3)
                    call cmf3kb(lot,ido,l1,na,c,jump,inc,ch,1,lot,wa(iw))
                case (4)
                    call cmf3kb(lot,ido,l1,na,ch,1,lot,c,jump,inc,wa(iw))
                case (5)
                    call cmf4kb(lot,ido,l1,na,c,jump,inc,ch,1,lot,wa(iw))
                case (6)
                    call cmf4kb(lot,ido,l1,na,ch,1,lot,c,jump,inc,wa(iw))
                case (7)
                    call cmf5kb(lot,ido,l1,na,c,jump,inc,ch,1,lot,wa(iw))
                case (8)
                    call cmf5kb(lot,ido,l1,na,ch,1,lot,c,jump,inc,wa(iw))
                case (9)
                    call cmfgkb(lot,ido,iip,l1,lid,na,c,c,jump,inc,ch,ch,1,lot,wa(iw))
                case (10)
                    call cmfgkb(lot,ido,iip,l1,lid,na,ch,ch,1,lot,c,c, &
                        jump,inc,wa(iw))
            end select

            l1 = l2
            iw = iw+(iip-1)*(2*ido)

            if(iip <= 5) then
                na = 1-na
            end if

        end do

    end subroutine cmfm1b

    subroutine cmfm1f(lot, jump, n, inc, c, ch, wa, fnf, fac)

        real (wp) c(2,*)
        real (wp) ch(*)
        real (wp) fac(*)
        real (wp) fnf
        integer (ip) ido
        integer (ip) inc
        integer (ip) iip
        integer (ip) iw
        integer (ip) jump
        integer (ip) k1
        integer (ip) l1
        integer (ip) l2
        integer (ip) lid
        integer (ip) lot
        integer (ip) n
        integer (ip) na
        integer (ip) nbr
        integer (ip) nf
        real (wp) wa(*)

        nf = int(fnf, kind=ip)
        na = 0
        l1 = 1
        iw = 1

        do k1=1,nf
            iip = int(fac(k1), kind=ip)
            l2 = iip*l1
            ido = n/l2
            lid = l1*ido
            nbr = 1+na+2*min(iip-2,4)
            select case (nbr)
                case (1)
                    call cmf2kf(lot,ido,l1,na,c,jump,inc,ch,1,lot,wa(iw))
                case (2)
                    call cmf2kf(lot,ido,l1,na,ch,1,lot,c,jump,inc,wa(iw))
                case (3)
                    call cmf3kf(lot,ido,l1,na,c,jump,inc,ch,1,lot,wa(iw))
                case (4)
                    call cmf3kf(lot,ido,l1,na,ch,1,lot,c,jump,inc,wa(iw))
                case (5)
                    call cmf4kf(lot,ido,l1,na,c,jump,inc,ch,1,lot,wa(iw))
                case (6)
                    call cmf4kf(lot,ido,l1,na,ch,1,lot,c,jump,inc,wa(iw))
                case (7)
                    call cmf5kf(lot,ido,l1,na,c,jump,inc,ch,1,lot,wa(iw))
                case (8)
                    call cmf5kf(lot,ido,l1,na,ch,1,lot,c,jump,inc,wa(iw))
                case (9)
                    call cmfgkf(lot,ido,iip,l1,lid,na,c,c,jump,inc,ch,ch,1,lot,wa(iw))
                case (10)
                    call cmfgkf(lot,ido,iip,l1,lid,na,ch,ch,1,lot,c,c, &
                        jump,inc,wa(iw))
            end select

            l1 = l2
            iw = iw+(iip-1)*(2*ido)

            if(iip <= 5) then
                na = 1-na
            end if
        end do

    end subroutine cmfm1f

    subroutine cosq1b(n, inc, x, lenx, wsave, lensav, work, lenwrk, ier)
        !
        ! Purpose:
        !
        ! COSQ1B: 64-bit float precision backward cosine quarter wave transform, 1D.
        !
        !  Purpose:
        !
        !  COSQ1B computes the one-dimensional Fourier transform of a sequence
        !  which is a cosine series with odd wave numbers.  This transform is
        !  referred to as the backward transform or Fourier synthesis, transforming
        !  the sequence from spectral to physical space.
        !
        !  This transform is normalized since a call to COSQ1B followed
        !  by a call to COSQ1F (or vice-versa) reproduces the original
        !  array  within roundoff error.
        !
        !  input, integer N, the number of elements to be transformed
        !  in the sequence.  The transform is most efficient when N is a
        !  product of small primes.
        !
        !  input, integer INC, the increment between the locations,
        !  in array R, of two consecutive elements within the sequence.
        !
        !  Input/output, real (wp) R(LENR); on input, containing the sequence
        !  to be transformed, and on output, containing the transformed sequence.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least INC*(N-1)+ 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to COSQ1I before the first call to routine COSQ1F
        !  or COSQ1B for a given transform length N.  WSAVE's contents may be
        !  re-used for subsequent calls to COSQ1F and COSQ1B with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least N.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  20, input error returned by lower level routine.
        !


        integer (ip) inc
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) ier1
        integer (ip) lenx
        integer (ip) n
        real (wp) ssqrt2
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) x(inc,*)
        real (wp) x1

        ier = 0

        if (lenx < inc*(n-1) + 1) then
            ier = 1
            call xerfft('cosq1b', 6)
            return
        else if (lensav < get_1d_saved_workspace_size(n) ) then
            ier = 2
            call xerfft('cosq1b', 8)
            return
        else if (lenwrk < n) then
            ier = 3
            call xerfft('cosq1b', 10)
            return
        end if

        if(n-2 < 0) then
            return
        else if (n-2 == 0) then
            ssqrt2 = 1.0_wp / sqrt ( 2.0_wp )
            x1 = x(1,1)+x(1,2)
            x(1,2) = ssqrt2*(x(1,1)-x(1,2))
            x(1,1) = x1
        else
            call cosqb1(n,inc,x,wsave,work,ier1)
            if (ier1 /= 0) then
                ier = 20
                call xerfft('cosq1b',-5)
            end if
        end if

    end subroutine cosq1b


    subroutine cosq1f(n, inc, x, lenx, wsave, lensav, work, lenwrk, ier)
        !
        !! COSQ1F: 64-bit float precision forward cosine quarter wave transform, 1D.
        !
        !  Purpose:
        !
        !  COSQ1F computes the one-dimensional Fourier transform of a sequence
        !  which is a cosine series with odd wave numbers.  This transform is
        !  referred to as the forward transform or Fourier analysis, transforming
        !  the sequence from physical to spectral space.
        !
        !  This transform is normalized since a call to COSQ1F followed
        !  by a call to COSQ1B (or vice-versa) reproduces the original
        !  array  within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer N, the number of elements to be transformed
        !  in the sequence.  The transform is most efficient when N is a
        !  product of small primes.
        !
        !  input, integer INC, the increment between the locations,
        !  in array R, of two consecutive elements within the sequence.
        !
        !  Input/output, real (wp) R(LENR); on input, containing the sequence
        !  to be transformed, and on output, containing the transformed sequence.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least INC*(N-1)+ 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to COSQ1I before the first call to routine COSQ1F
        !  or COSQ1B for a given transform length N.  WSAVE's contents may be
        !  re-used for subsequent calls to COSQ1F and COSQ1B with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least N.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  20, input error returned by lower level routine.
        !


        integer (ip) inc
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) ier1
        integer (ip) n
        integer (ip) lenx
        real (wp) ssqrt2
        real (wp) tsqx
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) x(inc,*)

        ier = 0

        if (lenx < inc*(n-1) + 1) then
            ier = 1
            call xerfft('cosq1f', 6)
            return
        else if (lensav < get_1d_saved_workspace_size(n) ) then
            ier = 2
            call xerfft('cosq1f', 8)
            return
        else if (lenwrk < n) then
            ier = 3
            call xerfft('cosq1f', 10)
            return
        end if

        if(n-2< 0) then
            goto 102
        else if(n-2 == 0) then
            goto 101
        else
            goto 103
        end if
101     ssqrt2 = 1.0_wp / sqrt ( 2.0_wp )
        tsqx = ssqrt2*x(1,2)
        x(1,2) = 0.5_wp *x(1,1)-tsqx
        x(1,1) = 0.5_wp *x(1,1)+tsqx
102     return
103     call cosqf1 (n,inc,x,wsave,work,ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('cosq1f',-5)
        end if

        return
    end subroutine cosq1f
    subroutine cosq1i(n, wsave, lensav, ier)


        !
        !! COSQ1I: initialization for COSQ1B and COSQ1F.
        !
        !  Purpose:
        !
        !  COSQ1I initializes array WSAVE for use in its companion routines
        !  COSQ1F and COSQ1B.  The prime factorization of N together with a
        !  tabulation of the trigonometric functions are computed and stored
        !  in array WSAVE.  Separate WSAVE arrays are required for different
        !  values of N.
        !
        !  Parameters:
        !
        !  input, integer N, the length of the sequence to be
        !  transformed.  The transform is most efficient when N is a product
        !  of small primes.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Output, real (wp) WSAVE(LENSAV), containing the prime factors of N
        !  and also containing certain trigonometric values which will be used
        !  in routines COSQ1B or COSQ1F.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough;
        !  20, input error returned by lower level routine.
        !


        integer (ip) lensav

        real (wp) dt
        real (wp) fk
        integer (ip) ier
        integer (ip) ier1
        integer (ip) k
        integer (ip) lnsv
        integer (ip) n
        real (wp) pih
        real (wp) wsave(lensav)

        ier = 0

        if (lensav < get_1d_saved_workspace_size(n) ) then
            ier = 2
            call xerfft('cosq1i', 3)
            return
        end if

        pih = 2.0_wp * atan ( 1.0_wp )
        dt = pih / real (n, kind=wp)
        fk = 0.0_wp

        do k=1,n
            fk = fk + 1.0_wp
            wsave(k) = cos(fk*dt)
        end do

        lnsv = n + int(log( real(n, kind=wp) )/log(2.0_wp)) +4
        call rfft1i(n, wsave(n+1), lnsv, ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('cosq1i',-5)
        end if

    end subroutine cosq1i


    subroutine cosqb1(n, inc, x, wsave, work, ier)

        integer (ip) inc

        integer (ip) i
        integer (ip) ier
        integer (ip) ier1
        integer (ip) k
        integer (ip) kc
        integer (ip) lenx
        integer (ip) lnsv
        integer (ip) lnwk
        integer (ip) modn
        integer (ip) n
        integer (ip) np2
        integer (ip) ns2
        real (wp) work(*)
        real (wp) wsave(*)
        real (wp) x(inc,*)
        real (wp) xim1

        ier = 0
        ns2 = (n+1)/2
        np2 = n+2

        do i=3,n,2
            xim1 = x(1,i-1)+x(1,i)
            x(1,i) = 0.5_wp * (x(1,i-1)-x(1,i))
            x(1,i-1) = 0.5_wp * xim1
        end do

        x(1,1) = 0.5_wp * x(1,1)
        modn = mod(n,2)

        if (modn == 0 ) then
            x(1,n) = 0.5_wp * x(1,n)
        end if

        lenx = inc*(n-1)  + 1
        lnsv = n + int(log( real(n, kind=wp) )/log(2.0_wp)) + 4
        lnwk = n

        call rfft1b(n,inc,x,lenx,wsave(n+1),lnsv,work,lnwk,ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('cosqb1',-5)
            return
        end if

        do k=2,ns2
            kc = np2-k
            work(k) = wsave(k-1)*x(1,kc)+wsave(kc-1)*x(1,k)
            work(kc) = wsave(k-1)*x(1,k)-wsave(kc-1)*x(1,kc)
        end do

        if (modn == 0) then
            x(1,ns2+1) = wsave(ns2)*(x(1,ns2+1)+x(1,ns2+1))
        end if

        do k=2,ns2
            kc = np2-k
            x(1,k) = work(k)+work(kc)
            x(1,kc) = work(k)-work(kc)
        end do

        x(1,1) = x(1,1)+x(1,1)

    end subroutine cosqb1


    subroutine cosqf1(n, inc, x, wsave, work, ier)

        integer (ip) inc

        integer (ip) i
        integer (ip) ier
        integer (ip) ier1
        integer (ip) k
        integer (ip) kc
        integer (ip) lenx
        integer (ip) lnsv
        integer (ip) lnwk
        integer (ip) modn
        integer (ip) n
        integer (ip) np2
        integer (ip) ns2
        real (wp) work(*)
        real (wp) wsave(*)
        real (wp) x(inc,*)
        real (wp) xim1

        ier = 0
        ns2 = (n+1)/2
        np2 = n+2

        do k=2,ns2
            kc = np2-k
            work(k)  = x(1,k)+x(1,kc)
            work(kc) = x(1,k)-x(1,kc)
        end do

        modn = mod(n,2)

        if (modn == 0) then
            work(ns2+1) = x(1,ns2+1)+x(1,ns2+1)
        end if

        do k=2,ns2
            kc = np2-k
            x(1,k)  = wsave(k-1)*work(kc)+wsave(kc-1)*work(k)
            x(1,kc) = wsave(k-1)*work(k) -wsave(kc-1)*work(kc)
        end do

        if (modn == 0) then
            x(1,ns2+1) = wsave(ns2)*work(ns2+1)
        end if

        lenx = inc*(n-1)  + 1
        lnsv = n + int(log( real(n, kind=wp) )/log(2.0_wp)) + 4
        lnwk = n

        call rfft1f(n,inc,x,lenx,wsave(n+1),lnsv,work,lnwk,ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('cosqf1',-5)
            return
        end if

        do i=3,n,2
            xim1 = 0.5_wp * (x(1,i-1)+x(1,i))
            x(1,i) = 0.5_wp * (x(1,i-1)-x(1,i))
            x(1,i-1) = xim1
        end do

        return
    end subroutine cosqf1
    subroutine cosqmb(lot, jump, n, inc, x, lenx, wsave, lensav, work, lenwrk, &
        ier )
        ! COSQMB: 64-bit float precision backward cosine quarter wave, multiple vectors.
        !
        !  Purpose:
        !
        !  COSQMB computes the one-dimensional Fourier transform of multiple
        !  sequences, each of which is a cosine series with odd wave numbers.
        !  This transform is referred to as the backward transform or Fourier
        !  synthesis, transforming the sequences from spectral to physical space.
        !
        !  This transform is normalized since a call to COSQMB followed
        !  by a call to COSQMF (or vice-versa) reproduces the original
        !  array within roundoff error.
        !
        !  input, integer LOT, the number of sequences to be transformed
        !  within array R.
        !
        !  input, integer JUMP, the increment between the locations,
        !  in array R, of the first elements of two consecutive sequences to be
        !  transformed.
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations,
        !  in array R, of two consecutive elements within the same sequence.
        !
        !  Input/output, real (wp) R(LENR), array containing LOT sequences,
        !  each having length N.  R can have any number of dimensions, but the total
        !  number of locations must be at least LENR.  On input, R contains the data
        !  to be transformed, and on output, the transformed data.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least (LOT-1)*JUMP + INC*(N-1)+ 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to COSQMI before the first call to routine COSQMF
        !  or COSQMB for a given transform length N.  WSAVE's contents may be re-used
        !  for subsequent calls to COSQMF and COSQMB with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least LOT*N.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  4, input parameters INC,JUMP,N,LOT are not consistent;
        !  20, input error returned by lower level routine.
        !


        integer (ip) inc
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) ier1
        integer (ip) jump
        integer (ip) lenx
        integer (ip) lj
        integer (ip) lot
        integer (ip) m
        integer (ip) n
        real (wp) ssqrt2
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) x(inc,*)
        real (wp) x1
        !logical xercon

        ier = 0

        if (lenx < (lot-1)*jump + inc*(n-1) + 1) then
            ier = 1
            call xerfft('cosqmb', 6)
            return
        else if (lensav < &
            2*n + int(log( real(n, kind=wp) )/log(2.0_wp)) +4) then
            ier = 2
            call xerfft('cosqmb', 8)
            return
        else if (lenwrk < lot*n) then
            ier = 3
            call xerfft('cosqmb', 10)
            return
        else if (.not. xercon(inc,jump,n,lot)) then
            ier = 4
            call xerfft('cosqmb', -1)
            return
        end if

        lj = (lot-1)*jump+1
        if(n-2< 0) then
            goto 101
        else if(n-2 == 0) then
            goto 102
        else
            goto 103
        end if
        101  do m=1,lj,jump
            x(m,1) = x(m,1)
        end do
        return
102     ssqrt2 = 1.0_wp / sqrt ( 2.0_wp )
        do m=1,lj,jump
            x1 = x(m,1)+x(m,2)
            x(m,2) = ssqrt2*(x(m,1)-x(m,2))
            x(m,1) = x1
        end do
        return

103     call mcsqb1(lot,jump,n,inc,x,wsave,work,ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('cosqmb',-5)
        end if

        return
    end subroutine cosqmb
    subroutine cosqmf(lot, jump, n, inc, x, lenx, wsave, lensav, work, &
        lenwrk, ier)
        ! COSQMF: 64-bit float precision forward cosine quarter wave, multiple vectors.
        !
        !  Purpose:
        !
        !  COSQMF computes the one-dimensional Fourier transform of multiple
        !  sequences within a real array, where each of the sequences is a
        !  cosine series with odd wave numbers.  This transform is referred to
        !  as the forward transform or Fourier synthesis, transforming the
        !  sequences from spectral to physical space.
        !
        !  This transform is normalized since a call to COSQMF followed
        !  by a call to COSQMB (or vice-versa) reproduces the original
        !  array within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer LOT, the number of sequences to be transformed
        !  within array R.
        !
        !  input, integer JUMP, the increment between the locations, in
        !  array R, of the first elements of two consecutive sequences to be
        !  transformed.
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations,
        !  in array R, of two consecutive elements within the same sequence.
        !
        !  Input/output, real (wp) R(LENR), array containing LOT sequences,
        !  each having length N.  R can have any number of dimensions, but the total
        !  number of locations must be at least LENR.  On input, R contains the data
        !  to be transformed, and on output, the transformed data.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least (LOT-1)*JUMP + INC*(N-1)+ 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to COSQMI before the first call to routine COSQMF
        !  or COSQMB for a given transform length N.  WSAVE's contents may be re-used
        !  for subsequent calls to COSQMF and COSQMB with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least LOT*N.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  4, input parameters INC,JUMP,N,LOT are not consistent;
        !  20, input error returned by lower level routine.
        !


        integer (ip) inc
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) ier1
        integer (ip) jump
        integer (ip) lenx
        integer (ip) lj
        integer (ip) lot
        integer (ip) m
        integer (ip) n
        real (wp) ssqrt2
        real (wp) tsqx
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) x(inc,*)
        !logical xercon

        ier = 0

        if (lenx < (lot-1)*jump + inc*(n-1) + 1) then
            ier = 1
            call xerfft('cosqmf', 6)
            return
        else if (lensav < &
            2*n + int(log( real(n, kind=wp) )/log(2.0_wp)) +4) then
            ier = 2
            call xerfft('cosqmf', 8)
            return
        else if (lenwrk < lot*n) then
            ier = 3
            call xerfft('cosqmf', 10)
            return
        else if (.not. xercon(inc,jump,n,lot)) then
            ier = 4
            call xerfft('cosqmf', -1)
            return
        end if

        lj = (lot-1)*jump+1

        if(n-2< 0) then
            goto 102
        else if(n-2 == 0) then
            goto 101
        else
            goto 103
        end if
101     ssqrt2 = 1.0_wp / sqrt ( 2.0_wp )

        do m=1,lj,jump
            tsqx = ssqrt2*x(m,2)
            x(m,2) = 0.5_wp * x(m,1)-tsqx
            x(m,1) = 0.5_wp * x(m,1)+tsqx
        end do

102     return

103     call mcsqf1(lot,jump,n,inc,x,wsave,work,ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('cosqmf',-5)
        end if

        return
    end subroutine cosqmf
    subroutine cosqmi(n, wsave, lensav, ier)


        !
        !! COSQMI: initialization for COSQMB and COSQMF.
        !
        !  Purpose:
        !
        !  COSQMI initializes array WSAVE for use in its companion routines
        !  COSQMF and COSQMB.  The prime factorization of N together with a
        !  tabulation of the trigonometric functions are computed and stored
        !  in array WSAVE.  Separate WSAVE arrays are required for different
        !  values of N.
        !
        !  Parameters:
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Output, real (wp) WSAVE(LENSAV), containing the prime factors of
        !  N and also containing certain trigonometric values which will be used
        !  in routines COSQMB or COSQMF.
        !
        !  input, integer IER, error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough;
        !  20, input error returned by lower level routine.
        !


        integer (ip) lensav

        real (wp) dt
        real (wp) fk
        integer (ip) ier
        integer (ip) ier1
        integer (ip) k
        integer (ip) lnsv
        integer (ip) n
        real (wp) pih
        real (wp) wsave(lensav)

        ier = 0

        if (lensav < 2*n + int(log( real(n, kind=wp) )/log(2.0_wp)) +4) then
            ier = 2
            call xerfft('cosqmi', 3)
            return
        end if

        pih = 2.0_wp * atan ( 1.0_wp )
        dt = pih/real(n, kind=wp)
        fk = 0.0_wp

        do k=1,n
            fk = fk + 1.0_wp
            wsave(k) = cos(fk*dt)
        end do

        lnsv = n + int(log( real(n, kind=wp) )/log(2.0_wp)) +4

        call rfftmi(n, wsave(n+1), lnsv, ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('cosqmi',-5)
        end if

        return
    end subroutine cosqmi
    subroutine cost1b(n, inc, x, lenx, wsave, lensav, work, lenwrk, ier)


        !
        !! COST1B: 64-bit float precision backward cosine transform, 1D.
        !
        !  Purpose:
        !
        !  COST1B computes the one-dimensional Fourier transform of an even
        !  sequence within a real array.  This transform is referred to as
        !  the backward transform or Fourier synthesis, transforming the sequence
        !  from spectral to physical space.
        !
        !  This transform is normalized since a call to COST1B followed
        !  by a call to COST1F (or vice-versa) reproduces the original array
        !  within roundoff error.
        !
        !
        !  Parameters:
        !
        !  input, integer N, the length of the sequence to be
        !  transformed.  The transform is most efficient when N-1 is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations,
        !  in array R, of two consecutive elements within the sequence.
        !
        !  Input/output, real (wp) R(LENR), containing the sequence to
        !   be transformed.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least INC*(N-1)+ 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to COST1I before the first call to routine COST1F
        !  or COST1B for a given transform length N.  WSAVE's contents may be re-used
        !  for subsequent calls to COST1F and COST1B with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least N-1.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  20, input error returned by lower level routine.
        !


        integer (ip) inc
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) ier1
        integer (ip) lenx
        integer (ip) n
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) x(inc,*)

        ier = 0

        if (lenx < inc*(n-1) + 1) then
            ier = 1
            call xerfft('cost1b', 6)
            return
        else if (lensav < 2*n + int(log( real(n, kind=wp) ) &
            /log(2.0_wp)) +4) then
            ier = 2
            call xerfft('cost1b', 8)
            return
        else if (lenwrk < n-1) then
            ier = 3
            call xerfft('cost1b', 10)
            return
        end if

        if (n == 1) then
            return
        end if

        call costb1 (n,inc,x,wsave,work,ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('cost1b',-5)
        end if

        return
    end subroutine cost1b
    subroutine cost1f(n, inc, x, lenx, wsave, lensav, work, lenwrk, ier)


        !
        !! COST1F: 64-bit float precision forward cosine transform, 1D.
        !
        !  Purpose:
        !
        !  COST1F computes the one-dimensional Fourier transform of an even
        !  sequence within a real array.  This transform is referred to as the
        !  forward transform or Fourier analysis, transforming the sequence
        !  from  physical to spectral space.
        !
        !  This transform is normalized since a call to COST1F followed by a call
        !  to COST1B (or vice-versa) reproduces the original array within
        !  roundoff error.
        !
        !  Parameters:
        !
        !  input, integer N, the length of the sequence to be
        !  transformed.  The transform is most efficient when N-1 is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations,
        !  in array R, of two consecutive elements within the sequence.
        !
        !  Input/output, real (wp) R(LENR), containing the sequence to
        !  be transformed.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least INC*(N-1)+ 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to COST1I before the first call to routine COST1F
        !  or COST1B for a given transform length N.  WSAVE's contents may be re-used
        !  for subsequent calls to COST1F and COST1B with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least N-1.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  20, input error returned by lower level routine.
        !


        integer (ip) inc
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) ier1
        integer (ip) lenx
        integer (ip) n
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) x(inc,*)

        ier = 0

        if (lenx < inc*(n-1) + 1) then
            ier = 1
            call xerfft('cost1f', 6)
            return
        else if (lensav < 2*n + int(log( real(n, kind=wp) ) &
            /log(2.0_wp)) +4) then
            ier = 2
            call xerfft('cost1f', 8)
            return
        else if (lenwrk < n-1) then
            ier = 3
            call xerfft('cost1f', 10)
            return
        end if

        if (n == 1) then
            return
        end if

        call costf1(n,inc,x,wsave,work,ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('cost1f',-5)
        end if

    end subroutine cost1f



    subroutine cost1i(n, wsave, lensav, ier)
        !
        !! COST1I: initialization for COST1B and COST1F.
        !
        !  Purpose:
        !
        !  COST1I initializes array WSAVE for use in its companion routines
        !  COST1F and COST1B.  The prime factorization of N together with a
        !  tabulation of the trigonometric functions are computed and stored
        !  in array WSAVE.  Separate WSAVE arrays are required for different
        !  values of N.
        !
        !  Parameters:
        !
        !  input, integer N, the length of the sequence to be
        !  transformed.  The transform is most efficient when N-1 is a product
        !  of small primes.
        !
        !  input, integer LENSAV, dimension of WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Output, real (wp) WSAVE(LENSAV), containing the prime factors of
        !  N and also containing certain trigonometric values which will be used in
        !  routines COST1B or COST1F.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough;
        !  20, input error returned by lower level routine.
        !


        integer (ip) lensav

        real (wp) dt
        real (wp) fk
        integer (ip) ier
        integer (ip) ier1
        integer (ip) k
        integer (ip) kc
        integer (ip) lnsv
        integer (ip) n
        integer (ip) nm1
        integer (ip) np1
        integer (ip) ns2
        real (wp) pi
        real (wp) wsave(lensav)

        ier = 0

        if (lensav < 2*n + int(log( real(n, kind=wp) )/log(2.0_wp)) +4) then
            ier = 2
            call xerfft('cost1i', 3)
            return
        end if

        if ( n <= 3 ) then
            return
        end if

        nm1 = n-1
        np1 = n+1
        ns2 = n/2
        pi = acos(-1.0_wp)
        dt = pi/ real ( nm1, kind=wp)
        fk = 0.0_wp

        do k=2,ns2
            kc = np1-k
            fk = fk + 1.0_wp
            wsave(k) = 2.0_wp * sin(fk*dt)
            wsave(kc) = 2.0_wp * cos(fk*dt)
        end do

        lnsv = nm1 + int(log( real ( nm1, kind=wp) )/log(2.0_wp)) +4

        call rfft1i (nm1, wsave(n+1), lnsv, ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('cost1i',-5)
        end if

        return
    end subroutine cost1i

    subroutine costb1(n, inc, x, wsave, work, ier)

        integer (ip) inc
        real (wp) dsum
        real (wp) fnm1s2
        real (wp) fnm1s4
        integer (ip) i
        integer (ip) ier
        integer (ip) ier1
        integer (ip) k
        integer (ip) kc
        integer (ip) lenx
        integer (ip) lnsv
        integer (ip) lnwk
        integer (ip) modn
        integer (ip) n
        integer (ip) nm1
        integer (ip) np1
        integer (ip) ns2
        real (wp) t1
        real (wp) t2
        real (wp) work(*)
        real (wp) wsave(*)
        real (wp) x(inc,*)
        real (wp) x1h
        real (wp) x1p3
        real (wp) x2
        real (wp) xi

        ier = 0

        nm1 = n-1
        np1 = n+1
        ns2 = n/2

        if(n-2 < 0) then
            return
        else if(n-2 == 0) then
            x1h = x(1,1)+x(1,2)
            x(1,2) = x(1,1)-x(1,2)
            x(1,1) = x1h
        else
            if ( 3 >= n ) then
                x1p3 = x(1,1)+x(1,3)
                x2 = x(1,2)
                x(1,2) = x(1,1)-x(1,3)
                x(1,1) = x1p3+x2
                x(1,3) = x1p3-x2
            else
                x(1,1) = x(1,1)+x(1,1)
                x(1,n) = x(1,n)+x(1,n)
                dsum = x(1,1)-x(1,n)
                x(1,1) = x(1,1)+x(1,n)

                do k=2,ns2
                    kc = np1-k
                    t1 = x(1,k)+x(1,kc)
                    t2 = x(1,k)-x(1,kc)
                    dsum = dsum+wsave(kc)*t2
                    t2 = wsave(k)*t2
                    x(1,k) = t1-t2
                    x(1,kc) = t1+t2
                end do

                modn = mod(n,2)

                if (modn /= 0) then
                    x(1,ns2+1) = x(1,ns2+1)+x(1,ns2+1)
                end if

                lenx = inc*(nm1-1) + 1
                lnsv = nm1 + int(log(real(nm1, kind=wp))/log(2.0_wp), kind=ip) + 4
                lnwk = nm1

                call rfft1f(nm1,inc,x,lenx,wsave(n+1),lnsv,work,lnwk,ier1)

                if (ier1 /= 0) then
                    ier = 20
                    call xerfft('costb1',-5)
                    return
                end if

                fnm1s2 = real(nm1, kind=wp)/2
                dsum = 0.5_wp * dsum
                x(1,1) = fnm1s2*x(1,1)

                if (mod(nm1,2) == 0) then
                    x(1,nm1) = x(1,nm1)+x(1,nm1)
                end if

                fnm1s4 = real ( nm1, kind=wp) / 4.0_wp

                do i=3,n,2
                    xi = fnm1s4*x(1,i)
                    x(1,i) = fnm1s4*x(1,i-1)
                    x(1,i-1) = dsum
                    dsum = dsum+xi
                end do

                if (modn /= 0) then
                    return
                end if

                x(1,n) = dsum
            end if
        end if

    end subroutine costb1

    subroutine costf1(n, inc, x, wsave, work, ier)

        integer (ip) inc
        real (wp) dsum
        integer (ip) i
        integer (ip) ier
        integer (ip) ier1
        integer (ip) k
        integer (ip) kc
        integer (ip) lenx
        integer (ip) lnsv
        integer (ip) lnwk
        integer (ip) modn
        integer (ip) n
        integer (ip) nm1
        integer (ip) np1
        integer (ip) ns2
        real (wp) snm1
        real (wp) t1
        real (wp) t2
        real (wp) tx2
        real (wp) work(*)
        real (wp) wsave(*)
        real (wp) x(inc,*)
        real (wp) x1h
        real (wp) x1p3
        real (wp) xi

        ier = 0

        nm1 = n-1
        np1 = n+1
        ns2 = n/2

        if (n-2 < 0) then
            return
        else if (n-2 == 0) then
            x1h = x(1,1)+x(1,2)
            x(1,2) = 0.5_wp * (x(1,1)-x(1,2))
            x(1,1) = 0.5_wp * x1h
        else
            if ( 3 >= n ) then
                x1p3 = x(1,1)+x(1,3)
                tx2 = x(1,2)+x(1,2)
                x(1,2) = 0.5_wp * (x(1,1)-x(1,3))
                x(1,1) = 0.25_wp *(x1p3+tx2)
                x(1,3) = 0.25_wp *(x1p3-tx2)
            else
                dsum = x(1,1)-x(1,n)
                x(1,1) = x(1,1)+x(1,n)
                do k=2,ns2
                    kc = np1-k
                    t1 = x(1,k)+x(1,kc)
                    t2 = x(1,k)-x(1,kc)
                    dsum = dsum+wsave(kc)*t2
                    t2 = wsave(k)*t2
                    x(1,k) = t1-t2
                    x(1,kc) = t1+t2
                end do

                modn = mod(n,2)

                if (modn /= 0) then
                    x(1,ns2+1) = x(1,ns2+1)+x(1,ns2+1)
                end if

                lenx = inc*(nm1-1)  + 1
                lnsv = nm1 + int(log( real ( nm1, kind=wp) )/log(2.0_wp)) + 4
                lnwk = nm1

                call rfft1f(nm1,inc,x,lenx,wsave(n+1),lnsv,work,lnwk,ier1)

                if (ier1 /= 0) then
                    ier = 20
                    call xerfft('costf1',-5)
                    return
                end if

                snm1 = 1.0_wp /nm1
                dsum = snm1*dsum

                if (mod(nm1,2) == 0) then
                    x(1,nm1) = x(1,nm1)+x(1,nm1)
                end if

                do i=3,n,2
                    xi = 0.5_wp * x(1,i)
                    x(1,i) = 0.5_wp * x(1,i-1)
                    x(1,i-1) = dsum
                    dsum = dsum+xi
                end do

                if (modn == 0) then
                    x(1,n) = dsum
                end if

                x(1,1) = 0.5_wp * x(1,1)
                x(1,n) = 0.5_wp * x(1,n)
            end if
        end if

    end subroutine costf1

    subroutine costmb(lot, jump, n, inc, x, lenx, wsave, lensav, work, &
        lenwrk, ier)


        !
        !! COSTMB: 64-bit float precision backward cosine transform, multiple vectors.
        !
        !  Purpose:
        !
        !  COSTMB computes the one-dimensional Fourier transform of multiple
        !  even sequences within a real array.  This transform is referred to
        !  as the backward transform or Fourier synthesis, transforming the
        !  sequences from spectral to physical space.
        !
        !  This transform is normalized since a call to COSTMB followed
        !  by a call to COSTMF (or vice-versa) reproduces the original
        !  array  within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer LOT, the number of sequences to be transformed
        !  within array R.
        !
        !  input, integer JUMP, the increment between the locations, in
        !  array R, of the first elements of two consecutive sequences to be
        !  transformed.
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N-1 is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations, in
        !  array R, of two consecutive elements within the same sequence.
        !
        !  Input/output, real (wp) R(LENR), array containing LOT sequences,
        !  each having length N.  On input, the data to be transformed; on output,
        !  the transormed data.  R can have any number of dimensions, but the total
        !  number of locations must be at least LENR.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least (LOT-1)*JUMP + INC*(N-1)+ 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to COSTMI before the first call to routine COSTMF
        !  or COSTMB for a given transform length N.  WSAVE's contents may be re-used
        !  for subsequent calls to COSTMF and COSTMB with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least LOT*(N+1).
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  4, input parameters INC,JUMP,N,LOT are not consistent;
        !  20, input error returned by lower level routine.
        !


        integer (ip) inc
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) ier1
        integer (ip) iw1
        integer (ip) jump
        integer (ip) lenx
        integer (ip) lot
        integer (ip) n
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) x(inc,*)
        !logical xercon

        ier = 0

        if (lenx < (lot-1)*jump + inc*(n-1) + 1) then
            ier = 1
            call xerfft('costmb', 6)
            return
        else if (lensav < &
            2*n + int(log( real(n, kind=wp) )/log(2.0_wp)) +4) then
            ier = 2
            call xerfft('costmb', 8)
            return
        else if (lenwrk < lot*(n+1)) then
            ier = 3
            call xerfft('costmb', 10)
            return
        else if (.not. xercon(inc,jump,n,lot)) then
            ier = 4
            call xerfft('costmb', -1)
            return
        end if

        iw1 = lot+lot+1
        call mcstb1(lot,jump,n,inc,x,wsave,work,work(iw1),ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('costmb',-5)
        end if

        return
    end subroutine costmb
    subroutine costmf(lot, jump, n, inc, x, lenx, wsave, lensav, work, &
        lenwrk, ier)


        !
        !! COSTMF: 64-bit float precision forward cosine transform, multiple vectors.
        !
        !  Purpose:
        !
        !  COSTMF computes the one-dimensional Fourier transform of multiple
        !  even sequences within a real array.  This transform is referred to
        !  as the forward transform or Fourier analysis, transforming the
        !  sequences from physical to spectral space.
        !
        !  This transform is normalized since a call to COSTMF followed
        !  by a call to COSTMB (or vice-versa) reproduces the original
        !  array within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer LOT, the number of sequences to be transformed
        !  within array R.
        !
        !  input, integer JUMP, the increment between the locations,
        !  in array R, of the first elements of two consecutive sequences to
        !  be transformed.
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N-1 is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations,
        !  in array R, of two consecutive elements within the same sequence.
        !
        !  Input/output, real (wp) R(LENR), array containing LOT sequences,
        !  each having length N.  On input, the data to be transformed; on output,
        !  the transormed data.  R can have any number of dimensions, but the total
        !  number of locations must be at least LENR.
        !
        !  input, integer LENR, the dimension of the  R array.
        !  LENR must be at least (LOT-1)*JUMP + INC*(N-1)+ 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to COSTMI before the first call to routine COSTMF
        !  or COSTMB for a given transform length N.  WSAVE's contents may be re-used
        !  for subsequent calls to COSTMF and COSTMB with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least LOT*(N+1).
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  4, input parameters INC,JUMP,N,LOT are not consistent;
        !  20, input error returned by lower level routine.
        !


        integer (ip) inc
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) ier1
        integer (ip) iw1
        integer (ip) jump
        integer (ip) lenx
        integer (ip) lot
        integer (ip) n
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) x(inc,*)
        !!logical xercon

        ier = 0

        if (lenx < (lot-1)*jump + inc*(n-1) + 1) then
            ier = 1
            call xerfft('costmf', 6)
            return
        else if (lensav < 2*n + int(log( real(n, kind=wp) ) &
            /log(2.0_wp)) +4) then
            ier = 2
            call xerfft('costmf', 8)
            return
        else if (lenwrk < lot*(n+1)) then
            ier = 3
            call xerfft('costmf', 10)
            return
        else if (.not. xercon(inc,jump,n,lot)) then
            ier = 4
            call xerfft('costmf', -1)
            return
        end if

        iw1 = lot+lot+1

        call mcstf1(lot,jump,n,inc,x,wsave,work,work(iw1),ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('costmf',-5)
        end if

        return
    end subroutine costmf
    subroutine costmi(n, wsave, lensav, ier)


        !
        !! COSTMI: initialization for COSTMB and COSTMF.
        !
        !  Purpose:
        !
        !  COSTMI initializes array WSAVE for use in its companion routines
        !  COSTMF and COSTMB.  The prime factorization of N together with a
        !  tabulation of the trigonometric functions are computed and stored
        !  in array WSAVE.  Separate WSAVE arrays are required for different
        !  values of N.
        !
        !  Parameters:
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4
        !
        !  Output, real (wp) WSAVE(LENSAV), containing the prime factors of N
        !  and also containing certain trigonometric values which will be used
        !  in routines COSTMB or COSTMF.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough;
        !  20, input error returned by lower level routine.
        !


        integer (ip) lensav

        real (wp) dt
        real (wp) fk
        integer (ip) ier
        integer (ip) ier1
        integer (ip) k
        integer (ip) kc
        integer (ip) lnsv
        integer (ip) n
        integer (ip) nm1
        integer (ip) np1
        integer (ip) ns2
        real (wp) pi
        real (wp) wsave(lensav)

        ier = 0

        if (lensav < 2*n + int(log( real(n, kind=wp) )/log(2.0_wp)) +4) then
            ier = 2
            call xerfft('costmi', 3)
            return
        end if

        if (n <= 3) then
            return
        end if

        nm1 = n-1
        np1 = n+1
        ns2 = n/2
        pi = acos(-1.0_wp)
        dt = pi/ real ( nm1, kind=wp)
        fk = 0.0_wp

        do k=2,ns2
            kc = np1-k
            fk = fk + 1.0_wp
            wsave(k) = 2.0_wp * sin(fk*dt)
            wsave(kc) = 2.0_wp * cos(fk*dt)
        end do

        lnsv = nm1 + int(log( real ( nm1, kind=wp) )/log(2.0_wp)) +4

        call rfftmi (nm1, wsave(n+1), lnsv, ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('costmi',-5)
        end if

    end subroutine costmi


    subroutine mcsqb1(lot,jump,n,inc,x,wsave,work,ier)

        integer (ip) inc
        integer (ip) lot

        integer (ip) i
        integer (ip) ier
        integer (ip) ier1
        integer (ip) jump
        integer (ip) k
        integer (ip) kc
        integer (ip) lenx
        integer (ip) lj
        integer (ip) lnsv
        integer (ip) lnwk
        integer (ip) m
        integer (ip) m1
        integer (ip) modn
        integer (ip) n
        integer (ip) np2
        integer (ip) ns2
        real (wp) work(lot,*)
        real (wp) wsave(*)
        real (wp) x(inc,*)
        real (wp) xim1

        ier = 0
        lj = (lot-1)*jump+1
        ns2 = (n+1)/2
        np2 = n+2

        do i=3,n,2
            do m=1,lj,jump
                xim1 = x(m,i-1)+x(m,i)
                x(m,i) = 0.5_wp * (x(m,i-1)-x(m,i))
                x(m,i-1) = 0.5_wp * xim1
            end do
        end do

        do m=1,lj,jump
            x(m,1) = 0.5_wp * x(m,1)
        end do

        modn = mod(n,2)
        if (modn == 0) then
            do m=1,lj,jump
                x(m,n) = 0.5_wp * x(m,n)
            end do
        end if

        lenx = (lot-1)*jump + inc*(n-1)  + 1
        lnsv = n + int(log( real(n, kind=wp) )/log(2.0_wp)) + 4
        lnwk = lot*n

        call rfftmb(lot,jump,n,inc,x,lenx,wsave(n+1),lnsv,work,lnwk,ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('mcsqb1',-5)
            return
        end if

        do k=2,ns2
            kc = np2-k
            m1 = 0
            do m=1,lj,jump
                m1 = m1 + 1
                work(m1,k) = wsave(k-1)*x(m,kc)+wsave(kc-1)*x(m,k)
                work(m1,kc) = wsave(k-1)*x(m,k)-wsave(kc-1)*x(m,kc)
            end do
        end do

        if (modn == 0) then
            do m=1,lj,jump
                x(m,ns2+1) = wsave(ns2)*(x(m,ns2+1)+x(m,ns2+1))
            end do
        end if

        do k=2,ns2
            kc = np2-k
            m1 = 0
            do m=1,lj,jump
                m1 = m1 + 1
                x(m,k) = work(m1,k)+work(m1,kc)
                x(m,kc) = work(m1,k)-work(m1,kc)
            end do
        end do

        do m=1,lj,jump
            x(m,1) = x(m,1)+x(m,1)
        end do

        return
    end subroutine mcsqb1

    subroutine mcsqf1(lot,jump,n,inc,x,wsave,work,ier)

        integer (ip) inc
        integer (ip) lot
        integer (ip) i
        integer (ip) ier
        integer (ip) ier1
        integer (ip) jump
        integer (ip) k
        integer (ip) kc
        integer (ip) lenx
        integer (ip) lnsv
        integer (ip) lnwk
        integer (ip) lj
        integer (ip) m
        integer (ip) m1
        integer (ip) modn
        integer (ip) n
        integer (ip) np2
        integer (ip) ns2
        real (wp) work(lot,*)
        real (wp) wsave(*)
        real (wp) x(inc,*)
        real (wp) xim1

        ier = 0

        lj = (lot-1)*jump+1
        ns2 = (n+1)/2
        np2 = n+2

        do k=2,ns2
            kc = np2-k
            m1 = 0
            do m=1,lj,jump
                m1 = m1 + 1
                work(m1,k) = x(m,k)+x(m,kc)
                work(m1,kc) = x(m,k)-x(m,kc)
            end do
        end do

        modn = mod(n,2)

        if (modn == 0) then
            m1 = 0
            do m=1,lj,jump
                m1 = m1 + 1
                work(m1,ns2+1) = x(m,ns2+1)+x(m,ns2+1)
            end do
        end if

        do k=2,ns2
            kc = np2-k
            m1 = 0
            do m=1,lj,jump
                m1 = m1 + 1
                x(m,k)  = wsave(k-1)*work(m1,kc)+wsave(kc-1)*work(m1,k)
                x(m,kc) = wsave(k-1)*work(m1,k) -wsave(kc-1)*work(m1,kc)
            end do
        end do

        if (modn == 0) then
            m1 = 0
            do m=1,lj,jump
                m1 = m1 + 1
                x(m,ns2+1) = wsave(ns2)*work(m1,ns2+1)
            end do
        end if

        lenx = (lot-1)*jump + inc*(n-1)  + 1
        lnsv = n + int(log(real(n, kind=wp) )/log(2.0_wp)) + 4
        lnwk = lot*n

        call rfftmf(lot,jump,n,inc,x,lenx,wsave(n+1),lnsv,work,lnwk,ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('mcsqf1',-5)
            return
        end if

        do i=3,n,2
            do m=1,lj,jump
                xim1 = 0.5_wp * (x(m,i-1)+x(m,i))
                x(m,i) = 0.5_wp * (x(m,i-1)-x(m,i))
                x(m,i-1) = xim1
            end do
        end do

    end subroutine mcsqf1

    subroutine mcstb1(lot,jump,n,inc,x,wsave,dsum,work,ier)

        integer (ip) inc
        real (wp) dsum(*)
        real (wp) fnm1s2
        real (wp) fnm1s4
        integer (ip) i
        integer (ip) ier
        integer (ip) ier1
        integer (ip) jump
        integer (ip) k
        integer (ip) kc
        integer (ip) lenx
        integer (ip) lj
        integer (ip) lnsv
        integer (ip) lnwk
        integer (ip) lot
        integer (ip) m
        integer (ip) m1
        integer (ip) modn
        integer (ip) n
        integer (ip) nm1
        integer (ip) np1
        integer (ip) ns2
        real (wp) t1
        real (wp) t2
        real (wp) work(*)
        real (wp) wsave(*)
        real (wp) x(inc,*)
        real (wp) x1h
        real (wp) x1p3
        real (wp) x2
        real (wp) xi

        ier = 0

        nm1 = n-1
        np1 = n+1
        ns2 = n/2
        lj = (lot-1)*jump+1

        if(n-2 < 0) then
            return
        else if(n-2 == 0) then
            do m=1,lj,jump
                x1h = x(m,1)+x(m,2)
                x(m,2) = x(m,1)-x(m,2)
                x(m,1) = x1h
            end do
        else
            if ( 3 >= n ) then
                do m=1,lj,jump
                    x1p3 = x(m,1)+x(m,3)
                    x2 = x(m,2)
                    x(m,2) = x(m,1)-x(m,3)
                    x(m,1) = x1p3+x2
                    x(m,3) = x1p3-x2
                end do
            else
                do m=1,lj,jump
                    x(m,1) = x(m,1)+x(m,1)
                    x(m,n) = x(m,n)+x(m,n)
                end do

                m1 = 0

                do m=1,lj,jump
                    m1 = m1+1
                    dsum(m1) = x(m,1)-x(m,n)
                    x(m,1) = x(m,1)+x(m,n)
                end do

                do k=2,ns2
                    m1 = 0
                    do m=1,lj,jump
                        m1 = m1+1
                        kc = np1-k
                        t1 = x(m,k)+x(m,kc)
                        t2 = x(m,k)-x(m,kc)
                        dsum(m1) = dsum(m1)+wsave(kc)*t2
                        t2 = wsave(k)*t2
                        x(m,k) = t1-t2
                        x(m,kc) = t1+t2
                    end do
                end do

                modn = mod(n,2)

                if (modn /= 0) then
                    do m=1,lj,jump
                        x(m,ns2+1) = x(m,ns2+1)+x(m,ns2+1)
                    end do
                end if

                lenx = (lot-1)*jump + inc*(nm1-1)  + 1
                lnsv = nm1 + int(log(real(nm1, kind=wp))/log(2.0_wp)) + 4
                lnwk = lot*nm1

                call rfftmf(lot,jump,nm1,inc,x,lenx,wsave(n+1),lnsv,work,lnwk,ier1)

                if (ier1 /= 0) then
                    ier = 20
                    call xerfft('mcstb1',-5)
                    return
                end if

                fnm1s2 = real(nm1, kind=wp)/2
                m1 = 0

                do m=1,lj,jump
                    m1 = m1+1
                    dsum(m1) = 0.5_wp * dsum(m1)
                    x(m,1) = fnm1s2 * x(m,1)
                end do

                if(mod(nm1,2) == 0) then
                    do m=1,lj,jump
                        x(m,nm1) = x(m,nm1)+x(m,nm1)
                    end do
                end if

                fnm1s4 = real(nm1, kind=wp)/4

                do i=3,n,2
                    m1 = 0
                    do m=1,lj,jump
                        m1 = m1+1
                        xi = fnm1s4*x(m,i)
                        x(m,i) = fnm1s4*x(m,i-1)
                        x(m,i-1) = dsum(m1)
                        dsum(m1) = dsum(m1)+xi
                    end do
                end do
                if (modn == 0) then
                    m1 = 0
                    do m=1,lj,jump
                        m1 = m1+1
                        x(m,n) = dsum(m1)
                    end do
                end if
            end if
        end if

    end subroutine mcstb1

    subroutine mcstf1(lot,jump,n,inc,x,wsave,dsum,work,ier)

        integer (ip) inc
        real (wp) dsum(*)
        integer (ip) i
        integer (ip) ier
        integer (ip) ier1
        integer (ip) jump
        integer (ip) k
        integer (ip) kc
        integer (ip) lenx
        integer (ip) lj
        integer (ip) lnsv
        integer (ip) lnwk
        integer (ip) lot
        integer (ip) m
        integer (ip) m1
        integer (ip) modn
        integer (ip) n
        integer (ip) nm1
        integer (ip) np1
        integer (ip) ns2
        real (wp) snm1
        real (wp) t1
        real (wp) t2
        real (wp) tx2
        real (wp) work(*)
        real (wp) wsave(*)
        real (wp) x(inc,*)
        real (wp) x1h
        real (wp) x1p3
        real (wp) xi

        ier = 0

        nm1 = n-1
        np1 = n+1
        ns2 = n/2
        lj = (lot-1)*jump+1

        if (n-2 < 0) then
            return
        else if (n-2 == 0) then
            do m=1,lj,jump
                x1h = x(m,1)+x(m,2)
                x(m,2) = 0.5_wp * (x(m,1)-x(m,2))
                x(m,1) = 0.5_wp * x1h
            end do
        else
            if ( 3 >= n ) then
                do m=1,lj,jump
                    x1p3 = x(m,1)+x(m,3)
                    tx2 = x(m,2)+x(m,2)
                    x(m,2) = 0.5_wp * (x(m,1)-x(m,3))
                    x(m,1) = 0.25_wp * (x1p3+tx2)
                    x(m,3) = 0.25_wp * (x1p3-tx2)
                end do
            else
                m1 = 0
                do m=1,lj,jump
                    m1 = m1+1
                    dsum(m1) = x(m,1)-x(m,n)
                    x(m,1) = x(m,1)+x(m,n)
                end do
                do k=2,ns2
                    m1 = 0
                    do m=1,lj,jump
                        m1 = m1+1
                        kc = np1-k
                        t1 = x(m,k)+x(m,kc)
                        t2 = x(m,k)-x(m,kc)
                        dsum(m1) = dsum(m1)+wsave(kc)*t2
                        t2 = wsave(k)*t2
                        x(m,k) = t1-t2
                        x(m,kc) = t1+t2
                    end do
                end do

                modn = mod(n,2)

                if (modn /= 0) then
                    do m=1,lj,jump
                        x(m,ns2+1) = x(m,ns2+1)+x(m,ns2+1)
                    end do
                end if

                lenx = (lot-1)*jump + inc*(nm1-1)  + 1
                lnsv = nm1 + int(log(real(nm1, kind=wp))/log(2.0_wp)) + 4
                lnwk = lot*nm1

                call rfftmf(lot,jump,nm1,inc,x,lenx,wsave(n+1),lnsv,work,lnwk,ier1)

                if (ier1 /= 0) then
                    ier = 20
                    call xerfft('mcstf1',-5)
                    return
                end if

                snm1 = 1.0_wp/nm1

                do m=1,lot
                    dsum(m) = snm1*dsum(m)
                end do

                if ( mod(nm1,2) == 0) then
                    do m=1,lj,jump
                        x(m,nm1) = x(m,nm1)+x(m,nm1)
                    end do
                end if

                do i=3,n,2
                    m1 = 0
                    do m=1,lj,jump
                        m1 = m1+1
                        xi = 0.5_wp * x(m,i)
                        x(m,i) = 0.5_wp * x(m,i-1)
                        x(m,i-1) = dsum(m1)
                        dsum(m1) = dsum(m1)+xi
                    end do
                end do

                if (modn == 0) then
                    m1 = 0
                    do m=1,lj,jump
                        m1 = m1+1
                        x(m,n) = dsum(m1)
                    end do
                end if

                do m=1,lj,jump
                    x(m,1) = 0.5_wp * x(m,1)
                    x(m,n) = 0.5_wp * x(m,n)
                end do
            end if
        end if

    end subroutine mcstf1


    subroutine mrftb1(m,im,n,in,c,ch,wa,fac)

        integer (ip) in
        integer (ip) m
        integer (ip) n

        real (wp) c(in,*)
        real (wp) ch(m,*)
        real (wp) fac(15)
        real (wp) half
        real (wp) halfm
        integer (ip) i
        integer (ip) idl1
        integer (ip) ido
        integer (ip) im
        integer (ip) iip
        integer (ip) iw
        integer (ip) ix2
        integer (ip) ix3
        integer (ip) ix4
        integer (ip) j
        integer (ip) k1
        integer (ip) l1
        integer (ip) l2
        integer (ip) m2
        integer (ip) modn
        integer (ip) na
        integer (ip) nf
        integer (ip) nl
        real (wp) wa(n)

        nf = int(fac(2), kind=ip)
        na = 0

        do k1=1,nf
            iip = int(fac(k1+2), kind=ip)
            na = 1-na
            if (iip <= 5) then
                cycle
            end if
            if(k1 == nf) then
                cycle
            end if
            na = 1-na
        end do

        half = 0.5_wp
        halfm = -0.5_wp
        modn = mod(n,2)

        if(modn /= 0) then
            nl = n-1
        else
            nl = n-2
        end if

        if (na /= 0) then
            m2 = 1-im
            do i=1,m
                m2 = m2+im
                ch(i,1) = c(m2,1)
                ch(i,n) = c(m2,n)
            end do
            do j=2,nl,2
                m2 = 1-im
                do i=1,m
                    m2 = m2+im
                    ch(i,j) = half*c(m2,j)
                    ch(i,j+1) = halfm*c(m2,j+1)
                end do
            end do
        else
            do j=2,nl,2
                m2 = 1-im
                do i=1,m
                    m2 = m2+im
                    c(m2,j) = half*c(m2,j)
                    c(m2,j+1) = halfm*c(m2,j+1)
                end do
            end do
        end if

        l1 = 1
        iw = 1
        do k1=1,nf
            iip = int(fac(k1+2), kind=ip)
            l2 = iip*l1
            ido = n/l2
            idl1 = ido*l1

            select case (iip)
                case (2)
                    if (na == 0) then
                        call mradb2 (m,ido,l1,c,im,in,ch,1,m,wa(iw))
                    else
                        call mradb2 (m,ido,l1,ch,1,m,c,im,in,wa(iw))
                    end if
                    na = 1-na
                case (3)
                    ix2 = iw+ido
                    if (na == 0) then
                        call mradb3(m,ido,l1,c,im,in,ch,1,m,wa(iw),wa(ix2))
                    else
                        call mradb3(m,ido,l1,ch,1,m,c,im,in,wa(iw),wa(ix2))
                    end if
                    na = 1-na
                case(4)
                    ix2 = iw+ido
                    ix3 = ix2+ido
                    if (na == 0) then
                        call mradb4 (m,ido,l1,c,im,in,ch,1,m,wa(iw),wa(ix2),wa(ix3))
                    else
                        call mradb4 (m,ido,l1,ch,1,m,c,im,in,wa(iw),wa(ix2),wa(ix3))
                    end if
                    na = 1-na
                case (5)
                    ix2 = iw+ido
                    ix3 = ix2+ido
                    ix4 = ix3+ido
                    if (na == 0) then
                        call mradb5 (m,ido,l1,c,im,in,ch,1,m,wa(iw),wa(ix2),wa(ix3),wa(ix4))
                    else
                        call mradb5 (m,ido,l1,ch,1,m,c,im,in,wa(iw),wa(ix2),wa(ix3),wa(ix4))
                    end if
                    na = 1-na
                case default
                    if (na == 0) then
                        call mradbg (m,ido,iip,l1,idl1,c,c,c,im,in,ch,ch,1,m,wa(iw))
                    else
                        call mradbg (m,ido,iip,l1,idl1,ch,ch,ch,1,m,c,c,im,in,wa(iw))
                    end if
                    if (ido == 1) then
                        na = 1-na
                    end if
            end select
            l1 = l2
            iw = iw+(iip-1)*ido
        end do

    contains

        subroutine mradb2(m,ido,l1,cc,im1,in1,ch,im2,in2,wa1)

            integer (ip) ido
            integer (ip) in1
            integer (ip) in2
            integer (ip) l1

            real (wp) cc(in1,ido,2,l1)
            real (wp) ch(in2,ido,l1,2)
            integer (ip) i
            integer (ip) ic
            integer (ip) idp2
            integer (ip) im1
            integer (ip) im2
            integer (ip) k
            integer (ip) m
            integer (ip) m1
            integer (ip) m1d
            integer (ip) m2
            integer (ip) m2s
            real (wp) wa1(ido)

            m1d = (m-1)*im1+1
            m2s = 1-im2

            do k=1,l1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ch(m2,1,k,1) = cc(m1,1,1,k)+cc(m1,ido,2,k)
                    ch(m2,1,k,2) = cc(m1,1,1,k)-cc(m1,ido,2,k)
                end do
            end do

            if (ido-2 < 0) then
                return
            else if (ido-2 == 0) then
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ch(m2,ido,k,1) = cc(m1,ido,1,k)+cc(m1,ido,1,k)
                        ch(m2,ido,k,2) = -(cc(m1,1,2,k)+cc(m1,1,2,k))
                    end do
                end do
            else
                idp2 = ido+2
                do k=1,l1
                    do i=3,ido,2
                        ic = idp2-i
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            ch(m2,i-1,k,1) = cc(m1,i-1,1,k)+cc(m1,ic-1,2,k)
                            ch(m2,i,k,1) = cc(m1,i,1,k)-cc(m1,ic,2,k)
                            ch(m2,i-1,k,2) = wa1(i-2)*(cc(m1,i-1,1,k)-cc(m1,ic-1,2,k)) &
                                -wa1(i-1)*(cc(m1,i,1,k)+cc(m1,ic,2,k))

                            ch(m2,i,k,2) = wa1(i-2)*(cc(m1,i,1,k)+cc(m1,ic,2,k))+wa1(i-1) &
                                *(cc(m1,i-1,1,k)-cc(m1,ic-1,2,k))
                        end do
                    end do
                end do
                if (mod(ido,2) /= 1) then
                    do k=1,l1
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            ch(m2,ido,k,1) = cc(m1,ido,1,k)+cc(m1,ido,1,k)
                            ch(m2,ido,k,2) = -(cc(m1,1,2,k)+cc(m1,1,2,k))
                        end do
                    end do
                end if
            end if

        end subroutine mradb2

        subroutine mradb3 (m,ido,l1,cc,im1,in1,ch,im2,in2,wa1,wa2)

            integer (ip) ido
            integer (ip) in1
            integer (ip) in2
            integer (ip) l1


            real (wp) cc(in1,ido,3,l1)
            real (wp) ch(in2,ido,l1,3)
            integer (ip) i
            integer (ip) ic
            integer (ip) idp2
            integer (ip) im1
            integer (ip) im2
            integer (ip) k
            integer (ip) m
            integer (ip) m1
            integer (ip) m1d
            integer (ip) m2
            integer (ip) m2s
            real (wp) wa1(ido)
            real (wp) wa2(ido)
            real (wp), parameter :: TWO_PI = 2.0_wp * acos(-1.0_wp)
            real (wp), parameter :: ARG= TWO_PI/3
            real (wp), parameter :: TAUI = cos(ARG)
            real (wp), parameter :: TAUR = sin(ARG)

            m1d = (m-1)*im1+1
            m2s = 1-im2

            do k=1,l1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ch(m2,1,k,1) = cc(m1,1,1,k)+ 2.0_wp *cc(m1,ido,2,k)
                    ch(m2,1,k,2) = cc(m1,1,1,k)+( 2.0_wp *TAUR)*cc(m1,ido,2,k) &
                        -( 2.0_wp *TAUI)*cc(m1,1,3,k)
                    ch(m2,1,k,3) = cc(m1,1,1,k)+( 2.0_wp *TAUR)*cc(m1,ido,2,k) &
                        + 2.0_wp *TAUI*cc(m1,1,3,k)
                end do
            end do

            if (ido /= 1) then
                idp2 = ido+2
                do k=1,l1
                    do i=3,ido,2
                        ic = idp2-i
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            ch(m2,i-1,k,1) = cc(m1,i-1,1,k)+(cc(m1,i-1,3,k)+cc(m1,ic-1,2,k))
                            ch(m2,i,k,1) = cc(m1,i,1,k)+(cc(m1,i,3,k)-cc(m1,ic,2,k))

                            ch(m2,i-1,k,2) = wa1(i-2)* &
                                ((cc(m1,i-1,1,k)+TAUR*(cc(m1,i-1,3,k)+cc(m1,ic-1,2,k)))- &
                                (TAUI*(cc(m1,i,3,k)+cc(m1,ic,2,k)))) &
                                -wa1(i-1)* &
                                ((cc(m1,i,1,k)+TAUR*(cc(m1,i,3,k)-cc(m1,ic,2,k)))+ &
                                (TAUI*(cc(m1,i-1,3,k)-cc(m1,ic-1,2,k))))

                            ch(m2,i,k,2) = wa1(i-2)* &
                                ((cc(m1,i,1,k)+TAUR*(cc(m1,i,3,k)-cc(m1,ic,2,k)))+ &
                                (TAUI*(cc(m1,i-1,3,k)-cc(m1,ic-1,2,k)))) &
                                +wa1(i-1)* &
                                ((cc(m1,i-1,1,k)+TAUR*(cc(m1,i-1,3,k)+cc(m1,ic-1,2,k)))- &
                                (TAUI*(cc(m1,i,3,k)+cc(m1,ic,2,k))))

                            ch(m2,i-1,k,3) = wa2(i-2)* &
                                ((cc(m1,i-1,1,k)+TAUR*(cc(m1,i-1,3,k)+cc(m1,ic-1,2,k)))+ &
                                (TAUI*(cc(m1,i,3,k)+cc(m1,ic,2,k)))) &
                                -wa2(i-1)* &
                                ((cc(m1,i,1,k)+TAUR*(cc(m1,i,3,k)-cc(m1,ic,2,k)))- &
                                (TAUI*(cc(m1,i-1,3,k)-cc(m1,ic-1,2,k))))

                            ch(m2,i,k,3) = wa2(i-2)* &
                                ((cc(m1,i,1,k)+TAUR*(cc(m1,i,3,k)-cc(m1,ic,2,k)))- &
                                (TAUI*(cc(m1,i-1,3,k)-cc(m1,ic-1,2,k)))) &
                                +wa2(i-1)* &
                                ((cc(m1,i-1,1,k)+TAUR*(cc(m1,i-1,3,k)+cc(m1,ic-1,2,k)))+ &
                                (TAUI*(cc(m1,i,3,k)+cc(m1,ic,2,k))))
                        end do
                    end do
                end do
            end if

        end subroutine mradb3

        subroutine mradb4(m, ido, l1, cc, im1, in1, ch, im2, in2, wa1, wa2, wa3)

            integer (ip) ido
            integer (ip) in1
            integer (ip) in2
            integer (ip) l1

            real (wp) cc(in1,ido,4,l1)
            real (wp) ch(in2,ido,l1,4)
            integer (ip) i
            integer (ip) ic
            integer (ip) idp2
            integer (ip) im1
            integer (ip) im2
            integer (ip) k
            integer (ip) m
            integer (ip) m1
            integer (ip) m1d
            integer (ip) m2
            integer (ip) m2s
            real (wp), parameter :: SQRT2 = sqrt(2.0_wp)
            real (wp) wa1(ido)
            real (wp) wa2(ido)
            real (wp) wa3(ido)

            m1d = (m-1)*im1+1
            m2s = 1-im2

            do k=1,l1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ch(m2,1,k,3) = (cc(m1,1,1,k)+cc(m1,ido,4,k)) &
                        -(cc(m1,ido,2,k)+cc(m1,ido,2,k))
                    ch(m2,1,k,1) = (cc(m1,1,1,k)+cc(m1,ido,4,k)) &
                        +(cc(m1,ido,2,k)+cc(m1,ido,2,k))
                    ch(m2,1,k,4) = (cc(m1,1,1,k)-cc(m1,ido,4,k)) &
                        +(cc(m1,1,3,k)+cc(m1,1,3,k))
                    ch(m2,1,k,2) = (cc(m1,1,1,k)-cc(m1,ido,4,k)) &
                        -(cc(m1,1,3,k)+cc(m1,1,3,k))
                end do
            end do

            if(ido-2 < 0) then
                return
            else if(ido-2 == 0) then
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ch(m2,ido,k,1) = (cc(m1,ido,1,k)+cc(m1,ido,3,k)) &
                            +(cc(m1,ido,1,k)+cc(m1,ido,3,k))
                        ch(m2,ido,k,2) = SQRT2*((cc(m1,ido,1,k)-cc(m1,ido,3,k)) &
                            -(cc(m1,1,2,k)+cc(m1,1,4,k)))
                        ch(m2,ido,k,3) = (cc(m1,1,4,k)-cc(m1,1,2,k)) &
                            +(cc(m1,1,4,k)-cc(m1,1,2,k))
                        ch(m2,ido,k,4) = -SQRT2*((cc(m1,ido,1,k)-cc(m1,ido,3,k)) &
                            +(cc(m1,1,2,k)+cc(m1,1,4,k)))
                    end do
                end do
            else
                idp2 = ido+2
                do k=1,l1
                    do i=3,ido,2
                        ic = idp2-i
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            ch(m2,i-1,k,1) = (cc(m1,i-1,1,k)+cc(m1,ic-1,4,k)) &
                                +(cc(m1,i-1,3,k)+cc(m1,ic-1,2,k))
                            ch(m2,i,k,1) = (cc(m1,i,1,k)-cc(m1,ic,4,k)) &
                                +(cc(m1,i,3,k)-cc(m1,ic,2,k))
                            ch(m2,i-1,k,2)=wa1(i-2)*((cc(m1,i-1,1,k)-cc(m1,ic-1,4,k)) &
                                -(cc(m1,i,3,k)+cc(m1,ic,2,k)))-wa1(i-1) &
                                *((cc(m1,i,1,k)+cc(m1,ic,4,k))+(cc(m1,i-1,3,k)-cc(m1,ic-1,2,k)))
                            ch(m2,i,k,2)=wa1(i-2)*((cc(m1,i,1,k)+cc(m1,ic,4,k)) &
                                +(cc(m1,i-1,3,k)-cc(m1,ic-1,2,k)))+wa1(i-1) &
                                *((cc(m1,i-1,1,k)-cc(m1,ic-1,4,k))-(cc(m1,i,3,k)+cc(m1,ic,2,k)))
                            ch(m2,i-1,k,3)=wa2(i-2)*((cc(m1,i-1,1,k)+cc(m1,ic-1,4,k)) &
                                -(cc(m1,i-1,3,k)+cc(m1,ic-1,2,k)))-wa2(i-1) &
                                *((cc(m1,i,1,k)-cc(m1,ic,4,k))-(cc(m1,i,3,k)-cc(m1,ic,2,k)))
                            ch(m2,i,k,3)=wa2(i-2)*((cc(m1,i,1,k)-cc(m1,ic,4,k)) &
                                -(cc(m1,i,3,k)-cc(m1,ic,2,k)))+wa2(i-1) &
                                *((cc(m1,i-1,1,k)+cc(m1,ic-1,4,k))-(cc(m1,i-1,3,k) &
                                +cc(m1,ic-1,2,k)))
                            ch(m2,i-1,k,4)=wa3(i-2)*((cc(m1,i-1,1,k)-cc(m1,ic-1,4,k)) &
                                +(cc(m1,i,3,k)+cc(m1,ic,2,k)))-wa3(i-1) &
                                *((cc(m1,i,1,k)+cc(m1,ic,4,k))-(cc(m1,i-1,3,k)-cc(m1,ic-1,2,k)))
                            ch(m2,i,k,4)=wa3(i-2)*((cc(m1,i,1,k)+cc(m1,ic,4,k)) &
                                -(cc(m1,i-1,3,k)-cc(m1,ic-1,2,k)))+wa3(i-1) &
                                *((cc(m1,i-1,1,k)-cc(m1,ic-1,4,k))+(cc(m1,i,3,k)+cc(m1,ic,2,k)))
                        end do
                    end do
                end do
                if (mod(ido,2) /= 1) then
                    do k=1,l1
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            ch(m2,ido,k,1) = (cc(m1,ido,1,k)+cc(m1,ido,3,k)) &
                                +(cc(m1,ido,1,k)+cc(m1,ido,3,k))
                            ch(m2,ido,k,2) = SQRT2*((cc(m1,ido,1,k)-cc(m1,ido,3,k)) &
                                -(cc(m1,1,2,k)+cc(m1,1,4,k)))
                            ch(m2,ido,k,3) = (cc(m1,1,4,k)-cc(m1,1,2,k)) &
                                +(cc(m1,1,4,k)-cc(m1,1,2,k))
                            ch(m2,ido,k,4) = -SQRT2*((cc(m1,ido,1,k)-cc(m1,ido,3,k)) &
                                +(cc(m1,1,2,k)+cc(m1,1,4,k)))
                        end do
                    end do
                end if
            end if

        end subroutine mradb4

        subroutine mradb5(m,ido,l1,cc,im1,in1,ch,im2,in2,wa1,wa2,wa3,wa4)

            integer (ip) ido
            integer (ip) in1
            integer (ip) in2
            integer (ip) l1

            real (wp) cc(in1,ido,5,l1)
            real (wp) ch(in2,ido,l1,5)
            integer (ip) i
            integer (ip) ic
            integer (ip) idp2
            integer (ip) im1
            integer (ip) im2
            integer (ip) k
            integer (ip) m
            integer (ip) m1
            integer (ip) m1d
            integer (ip) m2
            integer (ip) m2s
            real (wp) wa1(ido)
            real (wp) wa2(ido)
            real (wp) wa3(ido)
            real (wp) wa4(ido)

            real (wp), parameter :: TWO_PI = 2.0_wp * acos(-1.0_wp)
            real (wp), parameter :: ARG = TWO_PI/5
            real (wp), parameter :: TR11=cos(ARG)
            real (wp), parameter :: TI11=sin(ARG)
            real (wp), parameter :: TR12=cos(2.0_wp*ARG)
            real (wp), parameter :: TI12=sin(2.0_wp*ARG)

            m1d = (m-1)*im1+1
            m2s = 1-im2

            do k=1,l1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ch(m2,1,k,1) = cc(m1,1,1,k)+ 2.0_wp *cc(m1,ido,2,k)&
                        + 2.0_wp *cc(m1,ido,4,k)
                    ch(m2,1,k,2) = (cc(m1,1,1,k)+TR11* 2.0_wp *cc(m1,ido,2,k) &
                        +TR12* 2.0_wp *cc(m1,ido,4,k))-(TI11* 2.0_wp *cc(m1,1,3,k) &
                        +TI12* 2.0_wp *cc(m1,1,5,k))
                    ch(m2,1,k,3) = (cc(m1,1,1,k)+TR12* 2.0_wp *cc(m1,ido,2,k) &
                        +TR11* 2.0_wp *cc(m1,ido,4,k))-(TI12* 2.0_wp *cc(m1,1,3,k) &
                        -TI11* 2.0_wp *cc(m1,1,5,k))
                    ch(m2,1,k,4) = (cc(m1,1,1,k)+TR12* 2.0_wp *cc(m1,ido,2,k) &
                        +TR11* 2.0_wp *cc(m1,ido,4,k))+(TI12* 2.0_wp *cc(m1,1,3,k) &
                        -TI11* 2.0_wp *cc(m1,1,5,k))
                    ch(m2,1,k,5) = (cc(m1,1,1,k)+TR11* 2.0_wp *cc(m1,ido,2,k) &
                        +TR12* 2.0_wp *cc(m1,ido,4,k))+(TI11* 2.0_wp *cc(m1,1,3,k) &
                        +TI12* 2.0_wp *cc(m1,1,5,k))
                end do
            end do

            if (ido /= 1) then
                idp2 = ido+2
                do k=1,l1
                    do i=3,ido,2
                        ic = idp2-i
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            ch(m2,i-1,k,1) = cc(m1,i-1,1,k)+(cc(m1,i-1,3,k)+cc(m1,ic-1,2,k)) &
                                +(cc(m1,i-1,5,k)+cc(m1,ic-1,4,k))
                            ch(m2,i,k,1) = cc(m1,i,1,k)+(cc(m1,i,3,k)-cc(m1,ic,2,k)) &
                                +(cc(m1,i,5,k)-cc(m1,ic,4,k))
                            ch(m2,i-1,k,2) = wa1(i-2)*((cc(m1,i-1,1,k)+TR11* &
                                (cc(m1,i-1,3,k)+cc(m1,ic-1,2,k))+TR12 &
                                *(cc(m1,i-1,5,k)+cc(m1,ic-1,4,k)))-(TI11*(cc(m1,i,3,k) &
                                +cc(m1,ic,2,k))+TI12*(cc(m1,i,5,k)+cc(m1,ic,4,k)))) &
                                -wa1(i-1)*((cc(m1,i,1,k)+TR11*(cc(m1,i,3,k)-cc(m1,ic,2,k)) &
                                +TR12*(cc(m1,i,5,k)-cc(m1,ic,4,k)))+(TI11*(cc(m1,i-1,3,k) &
                                -cc(m1,ic-1,2,k))+TI12*(cc(m1,i-1,5,k)-cc(m1,ic-1,4,k))))

                            ch(m2,i,k,2) = wa1(i-2)*((cc(m1,i,1,k)+TR11*(cc(m1,i,3,k) &
                                -cc(m1,ic,2,k))+TR12*(cc(m1,i,5,k)-cc(m1,ic,4,k))) &
                                +(TI11*(cc(m1,i-1,3,k)-cc(m1,ic-1,2,k))+TI12 &
                                *(cc(m1,i-1,5,k)-cc(m1,ic-1,4,k))))+wa1(i-1) &
                                *((cc(m1,i-1,1,k)+TR11*(cc(m1,i-1,3,k) &
                                +cc(m1,ic-1,2,k))+TR12*(cc(m1,i-1,5,k)+cc(m1,ic-1,4,k))) &
                                -(TI11*(cc(m1,i,3,k)+cc(m1,ic,2,k))+TI12 &
                                *(cc(m1,i,5,k)+cc(m1,ic,4,k))))
                            ch(m2,i-1,k,3) = wa2(i-2) &
                                *((cc(m1,i-1,1,k)+TR12*(cc(m1,i-1,3,k)+cc(m1,ic-1,2,k)) &
                                +TR11*(cc(m1,i-1,5,k)+cc(m1,ic-1,4,k)))-(TI12*(cc(m1,i,3,k) &
                                +cc(m1,ic,2,k))-TI11*(cc(m1,i,5,k)+cc(m1,ic,4,k)))) &
                                -wa2(i-1) &
                                *((cc(m1,i,1,k)+TR12*(cc(m1,i,3,k)- &
                                cc(m1,ic,2,k))+TR11*(cc(m1,i,5,k)-cc(m1,ic,4,k))) &
                                +(TI12*(cc(m1,i-1,3,k)-cc(m1,ic-1,2,k))-TI11 &
                                *(cc(m1,i-1,5,k)-cc(m1,ic-1,4,k))))

                            ch(m2,i,k,3) = wa2(i-2) &
                                *((cc(m1,i,1,k)+TR12*(cc(m1,i,3,k)- &
                                cc(m1,ic,2,k))+TR11*(cc(m1,i,5,k)-cc(m1,ic,4,k))) &
                                +(TI12*(cc(m1,i-1,3,k)-cc(m1,ic-1,2,k))-TI11 &
                                *(cc(m1,i-1,5,k)-cc(m1,ic-1,4,k)))) &
                                +wa2(i-1) &
                                *((cc(m1,i-1,1,k)+TR12*(cc(m1,i-1,3,k)+cc(m1,ic-1,2,k)) &
                                +TR11*(cc(m1,i-1,5,k)+cc(m1,ic-1,4,k)))-(TI12*(cc(m1,i,3,k) &
                                +cc(m1,ic,2,k))-TI11*(cc(m1,i,5,k)+cc(m1,ic,4,k))))

                            ch(m2,i-1,k,4) = wa3(i-2) &
                                *((cc(m1,i-1,1,k)+TR12*(cc(m1,i-1,3,k)+cc(m1,ic-1,2,k)) &
                                +TR11*(cc(m1,i-1,5,k)+cc(m1,ic-1,4,k)))+(TI12*(cc(m1,i,3,k) &
                                +cc(m1,ic,2,k))-TI11*(cc(m1,i,5,k)+cc(m1,ic,4,k)))) &
                                -wa3(i-1) &
                                *((cc(m1,i,1,k)+TR12*(cc(m1,i,3,k)- &
                                cc(m1,ic,2,k))+TR11*(cc(m1,i,5,k)-cc(m1,ic,4,k))) &
                                -(TI12*(cc(m1,i-1,3,k)-cc(m1,ic-1,2,k))-TI11 &
                                *(cc(m1,i-1,5,k)-cc(m1,ic-1,4,k))))

                            ch(m2,i,k,4) = wa3(i-2) &
                                *((cc(m1,i,1,k)+TR12*(cc(m1,i,3,k)- &
                                cc(m1,ic,2,k))+TR11*(cc(m1,i,5,k)-cc(m1,ic,4,k))) &
                                -(TI12*(cc(m1,i-1,3,k)-cc(m1,ic-1,2,k))-TI11 &
                                *(cc(m1,i-1,5,k)-cc(m1,ic-1,4,k)))) &
                                +wa3(i-1) &
                                *((cc(m1,i-1,1,k)+TR12*(cc(m1,i-1,3,k)+cc(m1,ic-1,2,k)) &
                                +TR11*(cc(m1,i-1,5,k)+cc(m1,ic-1,4,k)))+(TI12*(cc(m1,i,3,k) &
                                +cc(m1,ic,2,k))-TI11*(cc(m1,i,5,k)+cc(m1,ic,4,k))))

                            ch(m2,i-1,k,5) = wa4(i-2) &
                                *((cc(m1,i-1,1,k)+TR11*(cc(m1,i-1,3,k)+cc(m1,ic-1,2,k)) &
                                +TR12*(cc(m1,i-1,5,k)+cc(m1,ic-1,4,k)))+(TI11*(cc(m1,i,3,k) &
                                +cc(m1,ic,2,k))+TI12*(cc(m1,i,5,k)+cc(m1,ic,4,k)))) &
                                -wa4(i-1) &
                                *((cc(m1,i,1,k)+TR11*(cc(m1,i,3,k)-cc(m1,ic,2,k)) &
                                +TR12*(cc(m1,i,5,k)-cc(m1,ic,4,k)))-(TI11*(cc(m1,i-1,3,k) &
                                -cc(m1,ic-1,2,k))+TI12*(cc(m1,i-1,5,k)-cc(m1,ic-1,4,k))))

                            ch(m2,i,k,5) = wa4(i-2) &
                                *((cc(m1,i,1,k)+TR11*(cc(m1,i,3,k)-cc(m1,ic,2,k)) &
                                +TR12*(cc(m1,i,5,k)-cc(m1,ic,4,k)))-(TI11*(cc(m1,i-1,3,k) &
                                -cc(m1,ic-1,2,k))+TI12*(cc(m1,i-1,5,k)-cc(m1,ic-1,4,k)))) &
                                +wa4(i-1) &
                                *((cc(m1,i-1,1,k)+TR11*(cc(m1,i-1,3,k)+cc(m1,ic-1,2,k)) &
                                +TR12*(cc(m1,i-1,5,k)+cc(m1,ic-1,4,k)))+(TI11*(cc(m1,i,3,k) &
                                +cc(m1,ic,2,k))+TI12*(cc(m1,i,5,k)+cc(m1,ic,4,k))))
                        end do
                    end do
                end do
            end if

        end subroutine mradb5

        subroutine mradbg (m,ido,iip,l1,idl1,cc,c1,c2,im1,in1,ch,ch2,im2,in2,wa)

            integer (ip) idl1
            integer (ip) ido
            integer (ip) in1
            integer (ip) in2
            integer (ip) iip
            integer (ip) l1

            real (wp) ai1
            real (wp) ai2
            real (wp) ar1
            real (wp) ar1h
            real (wp) ar2
            real (wp) ar2h, arg
            real (wp) c1(in1,ido,l1,iip)
            real (wp) c2(in1,idl1,iip)
            real (wp) cc(in1,ido,iip,l1)
            real (wp) ch(in2,ido,l1,iip)
            real (wp) ch2(in2,idl1,iip)
            real (wp) dc2, dcp
            real (wp) ds2, dsp
            integer (ip) i
            integer (ip) ic
            integer (ip) idij
            integer (ip) idp2
            integer (ip) ik
            integer (ip) im1
            integer (ip) im2
            integer (ip) iipp2
            integer (ip) iipph
            integer (ip) is
            integer (ip) j
            integer (ip) j2
            integer (ip) jc
            integer (ip) k
            integer (ip) l
            integer (ip) lc
            integer (ip) m
            integer (ip) m1
            integer (ip) m1d
            integer (ip) m2
            integer (ip) m2s
            integer (ip) nbd
            real (wp) wa(ido)

            real (wp), parameter :: TWO_PI = 2.0_wp * acos(-1.0_wp)

            arg = TWO_PI/iip
            dcp = cos(arg)
            dsp = sin(arg)

            m1d = (m - 1) * im1 + 1
            m2s = 1 - im2

            idp2 = ido + 2
            nbd = (ido-1)/2
            iipp2 = iip+2
            iipph = (iip+1)/2

            if (ido >= l1) then
                do k=1,l1
                    do i=1,ido
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            ch(m2,i,k,1) = cc(m1,i,1,k)
                        end do
                    end do
                end do
            else
                do i=1,ido
                    do k=1,l1
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            ch(m2,i,k,1) = cc(m1,i,1,k)
                        end do
                    end do
                end do
            end if

            do j=2,iipph
                jc = iipp2-j
                j2 = j+j
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ch(m2,1,k,j) = cc(m1,ido,j2-2,k)+cc(m1,ido,j2-2,k)
                        ch(m2,1,k,jc) = cc(m1,1,j2-1,k)+cc(m1,1,j2-1,k)
                    end do
                end do
            end do

            if (ido /= 1) then
                if (nbd >= l1) then
                    do j=2,iipph
                        jc = iipp2-j
                        do k=1,l1
                            do i=3,ido,2
                                ic = idp2-i
                                m2 = m2s
                                do m1=1,m1d,im1
                                    m2 = m2+im2
                                    ch(m2,i-1,k,j) = cc(m1,i-1,2*j-1,k)+cc(m1,ic-1,2*j-2,k)
                                    ch(m2,i-1,k,jc) = cc(m1,i-1,2*j-1,k)-cc(m1,ic-1,2*j-2,k)
                                    ch(m2,i,k,j) = cc(m1,i,2*j-1,k)-cc(m1,ic,2*j-2,k)
                                    ch(m2,i,k,jc) = cc(m1,i,2*j-1,k)+cc(m1,ic,2*j-2,k)
                                end do
                            end do
                        end do
                    end do
                else
                    do j=2,iipph
                        jc = iipp2-j
                        do i=3,ido,2
                            ic = idp2-i
                            do k=1,l1
                                m2 = m2s
                                do m1=1,m1d,im1
                                    m2 = m2+im2
                                    ch(m2,i-1,k,j) = cc(m1,i-1,2*j-1,k)+cc(m1,ic-1,2*j-2,k)
                                    ch(m2,i-1,k,jc) = cc(m1,i-1,2*j-1,k)-cc(m1,ic-1,2*j-2,k)
                                    ch(m2,i,k,j) = cc(m1,i,2*j-1,k)-cc(m1,ic,2*j-2,k)
                                    ch(m2,i,k,jc) = cc(m1,i,2*j-1,k)+cc(m1,ic,2*j-2,k)
                                end do
                            end do
                        end do
                    end do
                end if
            end if

            ar1 = 1.0_wp
            ai1 = 0.0_wp
            do l=2,iipph
                lc = iipp2-l
                ar1h = dcp*ar1-dsp*ai1
                ai1 = dcp*ai1+dsp*ar1
                ar1 = ar1h
                do ik=1,idl1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        c2(m1,ik,l) = ch2(m2,ik,1)+ar1*ch2(m2,ik,2)
                        c2(m1,ik,lc) = ai1*ch2(m2,ik,iip)
                    end do
                end do
                dc2 = ar1
                ds2 = ai1
                ar2 = ar1
                ai2 = ai1
                do j=3,iipph
                    jc = iipp2-j
                    ar2h = dc2*ar2-ds2*ai2
                    ai2 = dc2*ai2+ds2*ar2
                    ar2 = ar2h
                    do ik=1,idl1
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            c2(m1,ik,l) = c2(m1,ik,l)+ar2*ch2(m2,ik,j)
                            c2(m1,ik,lc) = c2(m1,ik,lc)+ai2*ch2(m2,ik,jc)
                        end do
                    end do
                end do
            end do

            do j=2,iipph
                do ik=1,idl1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ch2(m2,ik,1) = ch2(m2,ik,1)+ch2(m2,ik,j)
                    end do
                end do
            end do

            do j=2,iipph
                jc = iipp2-j
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ch(m2,1,k,j) = c1(m1,1,k,j)-c1(m1,1,k,jc)
                        ch(m2,1,k,jc) = c1(m1,1,k,j)+c1(m1,1,k,jc)
                    end do
                end do
            end do

            if (ido /= 1) then
                if (nbd >= l1) then
                    do j=2,iipph
                        jc = iipp2-j
                        do k=1,l1
                            do i=3,ido,2
                                m2 = m2s
                                do m1=1,m1d,im1
                                    m2 = m2+im2
                                    ch(m2,i-1,k,j) = c1(m1,i-1,k,j)-c1(m1,i,k,jc)
                                    ch(m2,i-1,k,jc) = c1(m1,i-1,k,j)+c1(m1,i,k,jc)
                                    ch(m2,i,k,j) = c1(m1,i,k,j)+c1(m1,i-1,k,jc)
                                    ch(m2,i,k,jc) = c1(m1,i,k,j)-c1(m1,i-1,k,jc)
                                end do
                            end do
                        end do
                    end do
                else
                    do j=2,iipph
                        jc = iipp2-j
                        do i=3,ido,2
                            do k=1,l1
                                m2 = m2s
                                do m1=1,m1d,im1
                                    m2 = m2+im2
                                    ch(m2,i-1,k,j) = c1(m1,i-1,k,j)-c1(m1,i,k,jc)
                                    ch(m2,i-1,k,jc) = c1(m1,i-1,k,j)+c1(m1,i,k,jc)
                                    ch(m2,i,k,j) = c1(m1,i,k,j)+c1(m1,i-1,k,jc)
                                    ch(m2,i,k,jc) = c1(m1,i,k,j)-c1(m1,i-1,k,jc)
                                end do
                            end do
                        end do
                    end do
                end if
            end if


            if (ido /= 1) then
                do ik=1,idl1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        c2(m1,ik,1) = ch2(m2,ik,1)
                    end do
                end do
                do j=2,iip
                    do k=1,l1
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            c1(m1,1,k,j) = ch(m2,1,k,j)
                        end do
                    end do
                end do
                if (l1 >= nbd ) then
                    is = -ido
                    do j=2,iip
                        is = is+ido
                        idij = is
                        do i=3,ido,2
                            idij = idij+2
                            do k=1,l1
                                m2 = m2s
                                do m1=1,m1d,im1
                                    m2 = m2+im2
                                    c1(m1,i-1,k,j) = &
                                        wa(idij-1)*ch(m2,i-1,k,j) &
                                        - wa(idij)* ch(m2,i,k,j)
                                    c1(m1,i,k,j) = &
                                        wa(idij-1)*ch(m2,i,k,j) &
                                        + wa(idij)* ch(m2,i-1,k,j)
                                end do
                            end do
                        end do
                    end do
                else
                    is = -ido
                    do j=2,iip
                        is = is+ido
                        do k=1,l1
                            idij = is
                            do i=3,ido,2
                                idij = idij+2
                                m2 = m2s
                                do m1=1,m1d,im1
                                    m2 = m2+im2
                                    c1(m1,i-1,k,j) = &
                                        wa(idij-1)*ch(m2,i-1,k,j)&
                                        - wa(idij)*ch(m2,i,k,j)
                                    c1(m1,i,k,j) = &
                                        wa(idij-1)*ch(m2,i,k,j)&
                                        + wa(idij)*ch(m2,i-1,k,j)
                                end do
                            end do
                        end do
                    end do
                end if
            end if

        end subroutine mradbg

    end subroutine mrftb1


    subroutine mrftf1(m,im,n,in,c,ch,wa,fac)

        integer (ip) in
        integer (ip) m
        integer (ip) n

        real (wp) c(in,*)
        real (wp) ch(m,*)
        real (wp) fac(15)
        integer (ip) i
        integer (ip) idl1
        integer (ip) ido
        integer (ip) im
        integer (ip) iip
        integer (ip) iw
        integer (ip) ix2
        integer (ip) ix3
        integer (ip) ix4
        integer (ip) j
        integer (ip) k1
        integer (ip) kh
        integer (ip) l1
        integer (ip) l2
        integer (ip) m2
        integer (ip) modn
        integer (ip) na
        integer (ip) nf
        integer (ip) nl
        real (wp) sn
        real (wp) tsn
        real (wp) tsnm
        real (wp) wa(n)

        nf = int(fac(2), kind=ip)
        na = 1
        l2 = n
        iw = n

        do k1=1,nf
            kh = nf-k1
            iip = int(fac(kh+3), kind=ip)
            l1 = l2/iip
            ido = n/l2
            idl1 = ido*l1
            iw = iw-(iip-1)*ido
            na = 1-na
            select case (iip)
                case (2)
                    if (na == 0) then
                        call mradf2(m,ido,l1,c,im,in,ch,1,m,wa(iw))
                    else
                        call mradf2(m,ido,l1,ch,1,m,c,im,in,wa(iw))
                    end if
                case(3)
                    ix2 = iw+ido
                    if (na == 0) then
                        call mradf3(m,ido,l1,c,im,in,ch,1,m,wa(iw),wa(ix2))
                    else
                        call mradf3(m,ido,l1,ch,1,m,c,im,in,wa(iw),wa(ix2))
                    end if
                case (4)
                    ix2 = iw+ido
                    ix3 = ix2+ido
                    if (na == 0) then
                        call mradf4(m,ido,l1,c,im,in,ch,1,m,wa(iw),wa(ix2),wa(ix3))
                    else
                        call mradf4(m,ido,l1,ch,1,m,c,im,in,wa(iw),wa(ix2),wa(ix3))
                    end if
                case(5)
                    ix2 = iw+ido
                    ix3 = ix2+ido
                    ix4 = ix3+ido
                    if (na == 0) then
                        call mradf5(m,ido,l1,c,im,in,ch,1,m,wa(iw),wa(ix2),wa(ix3),wa(ix4))
                    else
                        call mradf5(m,ido,l1,ch,1,m,c,im,in,wa(iw),wa(ix2),wa(ix3),wa(ix4))
                    end if
                case default
                    if (ido == 1) then
                        na = 1-na
                    end if
                    if (na == 0) then
                        call mradfg(m,ido,iip,l1,idl1,c,c,c,im,in,ch,ch,1,m,wa(iw))
                        na = 1
                    else
                        call mradfg(m,ido,iip,l1,idl1,ch,ch,ch,1,m,c,c,im,in,wa(iw))
                        na = 0
                    end if
            end select
            l2 = l1
        end do

        sn = 1.0_wp/n
        tsn =  2.0_wp/n
        tsnm = -tsn
        modn = mod(n,2)

        if(modn /= 0) then
            nl = n-1
        else
            nl = n-2
        end if

        if (na == 0) then
            m2 = 1-im

            do i=1,m
                m2 = m2+im
                c(m2,1) = sn*ch(i,1)
            end do

            do j=2,nl,2
                m2 = 1-im
                do i=1,m
                    m2 = m2+im
                    c(m2,j) = tsn*ch(i,j)
                    c(m2,j+1) = tsnm*ch(i,j+1)
                end do
            end do

            if (modn == 0) then
                m2 = 1-im
                do i=1,m
                    m2 = m2+im
                    c(m2,n) = sn*ch(i,n)
                end do
            end if
        else
            m2 = 1-im
            do i=1,m
                m2 = m2+im
                c(m2,1) = sn*c(m2,1)
            end do
            do j=2,nl,2
                m2 = 1-im
                do i=1,m
                    m2 = m2+im
                    c(m2,j) = tsn*c(m2,j)
                    c(m2,j+1) = tsnm*c(m2,j+1)
                end do
            end do

            if (modn == 0) then
                m2 = 1-im
                do i=1,m
                    m2 = m2+im
                    c(m2,n) = sn*c(m2,n)
                end do
            end if
        end if

    contains

        subroutine mradf2(m,ido,l1,cc,im1,in1,ch,im2,in2,wa1)

            integer (ip) ido
            integer (ip) in1
            integer (ip) in2
            integer (ip) l1

            real (wp) cc(in1,ido,l1,2)
            real (wp) ch(in2,ido,2,l1)
            integer (ip) i
            integer (ip) ic
            integer (ip) idp2
            integer (ip) im1
            integer (ip) im2
            integer (ip) k
            integer (ip) m
            integer (ip) m1
            integer (ip) m1d
            integer (ip) m2
            integer (ip) m2s
            real (wp) wa1(ido)

            m1d = (m-1)*im1+1
            m2s = 1-im2

            do k=1,l1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ch(m2,1,1,k) = cc(m1,1,k,1)+cc(m1,1,k,2)
                    ch(m2,ido,2,k) = cc(m1,1,k,1)-cc(m1,1,k,2)
                end do
            end do

            if(ido-2 < 0) then
                return
            else if(ido-2 == 0) then
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ch(m2,1,2,k) = -cc(m1,ido,k,2)
                        ch(m2,ido,1,k) = cc(m1,ido,k,1)
                    end do
                end do
            else
                idp2 = ido+2
                do k=1,l1
                    do i=3,ido,2
                        ic = idp2-i
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            ch(m2,i,1,k) = cc(m1,i,k,1)+(wa1(i-2)*cc(m1,i,k,2)- &
                                wa1(i-1)*cc(m1,i-1,k,2))
                            ch(m2,ic,2,k) = (wa1(i-2)*cc(m1,i,k,2)-wa1(i-1)* &
                                cc(m1,i-1,k,2))-cc(m1,i,k,1)
                            ch(m2,i-1,1,k) = cc(m1,i-1,k,1)+(wa1(i-2)*cc(m1,i-1,k,2)+ &
                                wa1(i-1)*cc(m1,i,k,2))
                            ch(m2,ic-1,2,k) = cc(m1,i-1,k,1)-(wa1(i-2)*cc(m1,i-1,k,2)+ &
                                wa1(i-1)*cc(m1,i,k,2))
                        end do
                    end do
                end do
                if (mod(ido,2) /= 1) then
                    do k=1,l1
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            ch(m2,1,2,k) = -cc(m1,ido,k,2)
                            ch(m2,ido,1,k) = cc(m1,ido,k,1)
                        end do
                    end do
                end if
            end if

        end subroutine mradf2

        subroutine mradf3(m,ido,l1,cc,im1,in1,ch,im2,in2,wa1,wa2)

            integer (ip) ido
            integer (ip) in1
            integer (ip) in2
            integer (ip) l1

            real (wp) cc(in1,ido,l1,3)
            real (wp) ch(in2,ido,3,l1)
            integer (ip) i
            integer (ip) ic
            integer (ip) idp2
            integer (ip) im1
            integer (ip) im2
            integer (ip) k
            integer (ip) m
            integer (ip) m1
            integer (ip) m1d
            integer (ip) m2
            integer (ip) m2s
            real (wp) wa1(ido)
            real (wp) wa2(ido)
            real (wp), parameter :: TWO_PI =2.0_wp * acos(-1.0_wp)
            real (wp), parameter :: ARG = TWO_PI/3
            real (wp), parameter :: TAUR = cos(ARG)
            real (wp), parameter :: TAUI = sin(ARG)

            m1d = (m-1)*im1+1
            m2s = 1-im2

            do k=1,l1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ch(m2,1,1,k) = cc(m1,1,k,1)+(cc(m1,1,k,2)+cc(m1,1,k,3))
                    ch(m2,1,3,k) = TAUI*(cc(m1,1,k,3)-cc(m1,1,k,2))
                    ch(m2,ido,2,k) = cc(m1,1,k,1)+TAUR*(cc(m1,1,k,2)+cc(m1,1,k,3))
                end do
            end do

            if (ido /= 1) then
                idp2 = ido+2
                do k=1,l1
                    do i=3,ido,2
                        ic = idp2-i
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            ch(m2,i-1,1,k) = cc(m1,i-1,k,1)+((wa1(i-2)*cc(m1,i-1,k,2)+ &
                                wa1(i-1)*cc(m1,i,k,2))+(wa2(i-2)*cc(m1,i-1,k,3)+wa2(i-1)* &
                                cc(m1,i,k,3)))

                            ch(m2,i,1,k) = cc(m1,i,k,1)+((wa1(i-2)*cc(m1,i,k,2)- &
                                wa1(i-1)*cc(m1,i-1,k,2))+(wa2(i-2)*cc(m1,i,k,3)-wa2(i-1)* &
                                cc(m1,i-1,k,3)))

                            ch(m2,i-1,3,k) = (cc(m1,i-1,k,1)+TAUR*((wa1(i-2)* &
                                cc(m1,i-1,k,2)+wa1(i-1)*cc(m1,i,k,2))+(wa2(i-2)* &
                                cc(m1,i-1,k,3)+wa2(i-1)*cc(m1,i,k,3))))+(TAUI*((wa1(i-2)* &
                                cc(m1,i,k,2)-wa1(i-1)*cc(m1,i-1,k,2))-(wa2(i-2)* &
                                cc(m1,i,k,3)-wa2(i-1)*cc(m1,i-1,k,3))))

                            ch(m2,ic-1,2,k) = (cc(m1,i-1,k,1)+TAUR*((wa1(i-2)* &
                                cc(m1,i-1,k,2)+wa1(i-1)*cc(m1,i,k,2))+(wa2(i-2)* &
                                cc(m1,i-1,k,3)+wa2(i-1)*cc(m1,i,k,3))))-(TAUI*((wa1(i-2)* &
                                cc(m1,i,k,2)-wa1(i-1)*cc(m1,i-1,k,2))-(wa2(i-2)* &
                                cc(m1,i,k,3)-wa2(i-1)*cc(m1,i-1,k,3))))

                            ch(m2,i,3,k) = (cc(m1,i,k,1)+TAUR*((wa1(i-2)*cc(m1,i,k,2)- &
                                wa1(i-1)*cc(m1,i-1,k,2))+(wa2(i-2)*cc(m1,i,k,3)-wa2(i-1)* &
                                cc(m1,i-1,k,3))))+(TAUI*((wa2(i-2)*cc(m1,i-1,k,3)+wa2(i-1)* &
                                cc(m1,i,k,3))-(wa1(i-2)*cc(m1,i-1,k,2)+wa1(i-1)* &
                                cc(m1,i,k,2))))

                            ch(m2,ic,2,k) = (TAUI*((wa2(i-2)*cc(m1,i-1,k,3)+wa2(i-1)* &
                                cc(m1,i,k,3))-(wa1(i-2)*cc(m1,i-1,k,2)+wa1(i-1)* &
                                cc(m1,i,k,2))))-(cc(m1,i,k,1)+TAUR*((wa1(i-2)*cc(m1,i,k,2)- &
                                wa1(i-1)*cc(m1,i-1,k,2))+(wa2(i-2)*cc(m1,i,k,3)-wa2(i-1)* &
                                cc(m1,i-1,k,3))))
                        end do
                    end do
                end do
            end if

        end subroutine mradf3


        subroutine mradf4(m,ido,l1,cc,im1,in1,ch,im2,in2,wa1,wa2,wa3)

            integer (ip) ido
            integer (ip) in1
            integer (ip) in2
            integer (ip) l1

            real (wp) cc(in1,ido,l1,4)
            real (wp) ch(in2,ido,4,l1)
            integer (ip) i
            integer (ip) ic
            integer (ip) idp2
            integer (ip) im1
            integer (ip) im2
            integer (ip) k
            integer (ip) m
            integer (ip) m1
            integer (ip) m1d
            integer (ip) m2
            integer (ip) m2s
            real (wp) wa1(ido)
            real (wp) wa2(ido)
            real (wp) wa3(ido)
            real (wp), parameter :: HALF_SQRT2 = sqrt(2.0_wp)/2

            m1d = (m-1)*im1+1
            m2s = 1-im2

            do k=1,l1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ch(m2,1,1,k) = (cc(m1,1,k,2)+cc(m1,1,k,4)) &
                        +(cc(m1,1,k,1)+cc(m1,1,k,3))
                    ch(m2,ido,4,k) = (cc(m1,1,k,1)+cc(m1,1,k,3)) &
                        -(cc(m1,1,k,2)+cc(m1,1,k,4))
                    ch(m2,ido,2,k) = cc(m1,1,k,1)-cc(m1,1,k,3)
                    ch(m2,1,3,k) = cc(m1,1,k,4)-cc(m1,1,k,2)
                end do
            end do

            if (ido-2 < 0) then
                return
            else if (ido-2 == 0) then
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ch(m2,ido,1,k) = (HALF_SQRT2*(cc(m1,ido,k,2)-cc(m1,ido,k,4)))+ &
                            cc(m1,ido,k,1)
                        ch(m2,ido,3,k) = cc(m1,ido,k,1)-(HALF_SQRT2*(cc(m1,ido,k,2)- &
                            cc(m1,ido,k,4)))
                        ch(m2,1,2,k) = (-HALF_SQRT2*(cc(m1,ido,k,2)+cc(m1,ido,k,4)))- &
                            cc(m1,ido,k,3)
                        ch(m2,1,4,k) = (-HALF_SQRT2*(cc(m1,ido,k,2)+cc(m1,ido,k,4)))+ &
                            cc(m1,ido,k,3)
                    end do
                end do
            else
                idp2 = ido+2
                do k=1,l1
                    do i=3,ido,2
                        ic = idp2-i
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            ch(m2,i-1,1,k) = ((wa1(i-2)*cc(m1,i-1,k,2)+wa1(i-1)* &
                                cc(m1,i,k,2))+(wa3(i-2)*cc(m1,i-1,k,4)+wa3(i-1)* &
                                cc(m1,i,k,4)))+(cc(m1,i-1,k,1)+(wa2(i-2)*cc(m1,i-1,k,3)+ &
                                wa2(i-1)*cc(m1,i,k,3)))

                            ch(m2,ic-1,4,k) = (cc(m1,i-1,k,1)+(wa2(i-2)*cc(m1,i-1,k,3)+ &
                                wa2(i-1)*cc(m1,i,k,3)))-((wa1(i-2)*cc(m1,i-1,k,2)+ &
                                wa1(i-1)*cc(m1,i,k,2))+(wa3(i-2)*cc(m1,i-1,k,4)+ &
                                wa3(i-1)*cc(m1,i,k,4)))

                            ch(m2,i,1,k) = ((wa1(i-2)*cc(m1,i,k,2)-wa1(i-1)* &
                                cc(m1,i-1,k,2))+(wa3(i-2)*cc(m1,i,k,4)-wa3(i-1)* &
                                cc(m1,i-1,k,4)))+(cc(m1,i,k,1)+(wa2(i-2)*cc(m1,i,k,3)- &
                                wa2(i-1)*cc(m1,i-1,k,3)))

                            ch(m2,ic,4,k) = ((wa1(i-2)*cc(m1,i,k,2)-wa1(i-1)* &
                                cc(m1,i-1,k,2))+(wa3(i-2)*cc(m1,i,k,4)-wa3(i-1)* &
                                cc(m1,i-1,k,4)))-(cc(m1,i,k,1)+(wa2(i-2)*cc(m1,i,k,3)- &
                                wa2(i-1)*cc(m1,i-1,k,3)))

                            ch(m2,i-1,3,k) = ((wa1(i-2)*cc(m1,i,k,2)-wa1(i-1)* &
                                cc(m1,i-1,k,2))-(wa3(i-2)*cc(m1,i,k,4)-wa3(i-1)* &
                                cc(m1,i-1,k,4)))+(cc(m1,i-1,k,1)-(wa2(i-2)*cc(m1,i-1,k,3)+ &
                                wa2(i-1)*cc(m1,i,k,3)))

                            ch(m2,ic-1,2,k) = (cc(m1,i-1,k,1)-(wa2(i-2)*cc(m1,i-1,k,3)+ &
                                wa2(i-1)*cc(m1,i,k,3)))-((wa1(i-2)*cc(m1,i,k,2)-wa1(i-1)* &
                                cc(m1,i-1,k,2))-(wa3(i-2)*cc(m1,i,k,4)-wa3(i-1)* &
                                cc(m1,i-1,k,4)))

                            ch(m2,i,3,k) = ((wa3(i-2)*cc(m1,i-1,k,4)+wa3(i-1)* &
                                cc(m1,i,k,4))-(wa1(i-2)*cc(m1,i-1,k,2)+wa1(i-1)* &
                                cc(m1,i,k,2)))+(cc(m1,i,k,1)-(wa2(i-2)*cc(m1,i,k,3)- &
                                wa2(i-1)*cc(m1,i-1,k,3)))

                            ch(m2,ic,2,k) = ((wa3(i-2)*cc(m1,i-1,k,4)+wa3(i-1)* &
                                cc(m1,i,k,4))-(wa1(i-2)*cc(m1,i-1,k,2)+wa1(i-1)* &
                                cc(m1,i,k,2)))-(cc(m1,i,k,1)-(wa2(i-2)*cc(m1,i,k,3)- &
                                wa2(i-1)*cc(m1,i-1,k,3)))
                        end do
                    end do
                end do
                if (mod(ido,2) /= 1) then
                    do k=1,l1
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            ch(m2,ido,1,k) = (HALF_SQRT2*(cc(m1,ido,k,2)-cc(m1,ido,k,4)))+ &
                                cc(m1,ido,k,1)
                            ch(m2,ido,3,k) = cc(m1,ido,k,1)-(HALF_SQRT2*(cc(m1,ido,k,2)- &
                                cc(m1,ido,k,4)))
                            ch(m2,1,2,k) = (-HALF_SQRT2*(cc(m1,ido,k,2)+cc(m1,ido,k,4)))- &
                                cc(m1,ido,k,3)
                            ch(m2,1,4,k) = (-HALF_SQRT2*(cc(m1,ido,k,2)+cc(m1,ido,k,4)))+ &
                                cc(m1,ido,k,3)
                        end do
                    end do
                end if
            end if

        end subroutine mradf4

        subroutine mradf5(m,ido,l1,cc,im1,in1,ch,im2,in2,wa1,wa2,wa3,wa4)

            integer (ip) ido
            integer (ip) in1
            integer (ip) in2
            integer (ip) l1

            real (wp) cc(in1,ido,l1,5)
            real (wp) ch(in2,ido,5,l1)
            integer (ip) i
            integer (ip) ic
            integer (ip) idp2
            integer (ip) im1
            integer (ip) im2
            integer (ip) k
            integer (ip) m
            integer (ip) m1
            integer (ip) m1d
            integer (ip) m2
            integer (ip) m2s
            real (wp) wa1(ido)
            real (wp) wa2(ido)
            real (wp) wa3(ido)
            real (wp) wa4(ido)
            real (wp), parameter :: TWO_PI = 2.0_wp * acos(-1.0_wp)
            real (wp), parameter :: ARG = TWO_PI/5
            real (wp), parameter :: TR11 = cos(ARG)
            real (wp), parameter :: TI11 = sin(ARG)
            real (wp), parameter :: TR12 = cos(2.0_wp*ARG)
            real (wp), parameter :: TI12 = sin(2.0_wp*ARG)

            m1d = (m-1)*im1+1
            m2s = 1-im2

            do k=1,l1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    ch(m2,1,1,k) = cc(m1,1,k,1)+(cc(m1,1,k,5)+cc(m1,1,k,2))+ &
                        (cc(m1,1,k,4)+cc(m1,1,k,3))
                    ch(m2,ido,2,k) = cc(m1,1,k,1)+TR11*(cc(m1,1,k,5)+cc(m1,1,k,2))+ &
                        TR12*(cc(m1,1,k,4)+cc(m1,1,k,3))
                    ch(m2,1,3,k) = TI11*(cc(m1,1,k,5)-cc(m1,1,k,2))+TI12* &
                        (cc(m1,1,k,4)-cc(m1,1,k,3))
                    ch(m2,ido,4,k) = cc(m1,1,k,1)+TR12*(cc(m1,1,k,5)+cc(m1,1,k,2))+ &
                        TR11*(cc(m1,1,k,4)+cc(m1,1,k,3))
                    ch(m2,1,5,k) = TI12*(cc(m1,1,k,5)-cc(m1,1,k,2))-TI11* &
                        (cc(m1,1,k,4)-cc(m1,1,k,3))
                end do
            end do

            if (ido /= 1) then
                idp2 = ido+2
                do k=1,l1
                    do i=3,ido,2
                        ic = idp2-i
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2

                            ch(m2,i-1,1,k) = cc(m1,i-1,k,1)+((wa1(i-2)*cc(m1,i-1,k,2)+ &
                                wa1(i-1)*cc(m1,i,k,2))+(wa4(i-2)*cc(m1,i-1,k,5)+wa4(i-1)* &
                                cc(m1,i,k,5)))+((wa2(i-2)*cc(m1,i-1,k,3)+wa2(i-1)* &
                                cc(m1,i,k,3))+(wa3(i-2)*cc(m1,i-1,k,4)+ &
                                wa3(i-1)*cc(m1,i,k,4)))

                            ch(m2,i,1,k) = cc(m1,i,k,1)+((wa1(i-2)*cc(m1,i,k,2)- &
                                wa1(i-1)*cc(m1,i-1,k,2))+(wa4(i-2)*cc(m1,i,k,5)-wa4(i-1)* &
                                cc(m1,i-1,k,5)))+((wa2(i-2)*cc(m1,i,k,3)-wa2(i-1)* &
                                cc(m1,i-1,k,3))+(wa3(i-2)*cc(m1,i,k,4)-wa3(i-1)* &
                                cc(m1,i-1,k,4)))

                            ch(m2,i-1,3,k) = cc(m1,i-1,k,1)+TR11* &
                                ( wa1(i-2)*cc(m1,i-1,k,2)+wa1(i-1)*cc(m1,i,k,2) &
                                +wa4(i-2)*cc(m1,i-1,k,5)+wa4(i-1)*cc(m1,i,k,5))+TR12* &
                                ( wa2(i-2)*cc(m1,i-1,k,3)+wa2(i-1)*cc(m1,i,k,3) &
                                +wa3(i-2)*cc(m1,i-1,k,4)+wa3(i-1)*cc(m1,i,k,4))+TI11* &
                                ( wa1(i-2)*cc(m1,i,k,2)-wa1(i-1)*cc(m1,i-1,k,2) &
                                -(wa4(i-2)*cc(m1,i,k,5)-wa4(i-1)*cc(m1,i-1,k,5)))+TI12* &
                                ( wa2(i-2)*cc(m1,i,k,3)-wa2(i-1)*cc(m1,i-1,k,3) &
                                -(wa3(i-2)*cc(m1,i,k,4)-wa3(i-1)*cc(m1,i-1,k,4)))

                            ch(m2,ic-1,2,k) = cc(m1,i-1,k,1)+TR11* &
                                ( wa1(i-2)*cc(m1,i-1,k,2)+wa1(i-1)*cc(m1,i,k,2) &
                                +wa4(i-2)*cc(m1,i-1,k,5)+wa4(i-1)*cc(m1,i,k,5))+TR12* &
                                ( wa2(i-2)*cc(m1,i-1,k,3)+wa2(i-1)*cc(m1,i,k,3) &
                                +wa3(i-2)*cc(m1,i-1,k,4)+wa3(i-1)*cc(m1,i,k,4))-(TI11* &
                                ( wa1(i-2)*cc(m1,i,k,2)-wa1(i-1)*cc(m1,i-1,k,2) &
                                -(wa4(i-2)*cc(m1,i,k,5)-wa4(i-1)*cc(m1,i-1,k,5)))+TI12* &
                                ( wa2(i-2)*cc(m1,i,k,3)-wa2(i-1)*cc(m1,i-1,k,3) &
                                -(wa3(i-2)*cc(m1,i,k,4)-wa3(i-1)*cc(m1,i-1,k,4))))

                            ch(m2,i,3,k) = (cc(m1,i,k,1)+TR11*((wa1(i-2)*cc(m1,i,k,2)- &
                                wa1(i-1)*cc(m1,i-1,k,2))+(wa4(i-2)*cc(m1,i,k,5)-wa4(i-1)* &
                                cc(m1,i-1,k,5)))+TR12*((wa2(i-2)*cc(m1,i,k,3)-wa2(i-1)* &
                                cc(m1,i-1,k,3))+(wa3(i-2)*cc(m1,i,k,4)-wa3(i-1)* &
                                cc(m1,i-1,k,4))))+(TI11*((wa4(i-2)*cc(m1,i-1,k,5)+ &
                                wa4(i-1)*cc(m1,i,k,5))-(wa1(i-2)*cc(m1,i-1,k,2)+wa1(i-1)* &
                                cc(m1,i,k,2)))+TI12*((wa3(i-2)*cc(m1,i-1,k,4)+wa3(i-1)* &
                                cc(m1,i,k,4))-(wa2(i-2)*cc(m1,i-1,k,3)+wa2(i-1)* &
                                cc(m1,i,k,3))))

                            ch(m2,ic,2,k) = (TI11*((wa4(i-2)*cc(m1,i-1,k,5)+wa4(i-1)* &
                                cc(m1,i,k,5))-(wa1(i-2)*cc(m1,i-1,k,2)+wa1(i-1)* &
                                cc(m1,i,k,2)))+TI12*((wa3(i-2)*cc(m1,i-1,k,4)+wa3(i-1)* &
                                cc(m1,i,k,4))-(wa2(i-2)*cc(m1,i-1,k,3)+wa2(i-1)* &
                                cc(m1,i,k,3))))-(cc(m1,i,k,1)+TR11*((wa1(i-2)*cc(m1,i,k,2)- &
                                wa1(i-1)*cc(m1,i-1,k,2))+(wa4(i-2)*cc(m1,i,k,5)-wa4(i-1)* &
                                cc(m1,i-1,k,5)))+TR12*((wa2(i-2)*cc(m1,i,k,3)-wa2(i-1)* &
                                cc(m1,i-1,k,3))+(wa3(i-2)*cc(m1,i,k,4)-wa3(i-1)* &
                                cc(m1,i-1,k,4))))

                            ch(m2,i-1,5,k) = (cc(m1,i-1,k,1)+TR12*((wa1(i-2)* &
                                cc(m1,i-1,k,2)+wa1(i-1)*cc(m1,i,k,2))+(wa4(i-2)* &
                                cc(m1,i-1,k,5)+wa4(i-1)*cc(m1,i,k,5)))+TR11*((wa2(i-2)* &
                                cc(m1,i-1,k,3)+wa2(i-1)*cc(m1,i,k,3))+(wa3(i-2)* &
                                cc(m1,i-1,k,4)+wa3(i-1)*cc(m1,i,k,4))))+(TI12*((wa1(i-2)* &
                                cc(m1,i,k,2)-wa1(i-1)*cc(m1,i-1,k,2))-(wa4(i-2)* &
                                cc(m1,i,k,5)-wa4(i-1)*cc(m1,i-1,k,5)))-TI11*((wa2(i-2)* &
                                cc(m1,i,k,3)-wa2(i-1)*cc(m1,i-1,k,3))-(wa3(i-2)* &
                                cc(m1,i,k,4)-wa3(i-1)*cc(m1,i-1,k,4))))

                            ch(m2,ic-1,4,k) = (cc(m1,i-1,k,1)+TR12*((wa1(i-2)* &
                                cc(m1,i-1,k,2)+wa1(i-1)*cc(m1,i,k,2))+(wa4(i-2)* &
                                cc(m1,i-1,k,5)+wa4(i-1)*cc(m1,i,k,5)))+TR11*((wa2(i-2)* &
                                cc(m1,i-1,k,3)+wa2(i-1)*cc(m1,i,k,3))+(wa3(i-2)* &
                                cc(m1,i-1,k,4)+wa3(i-1)*cc(m1,i,k,4))))-(TI12*((wa1(i-2)* &
                                cc(m1,i,k,2)-wa1(i-1)*cc(m1,i-1,k,2))-(wa4(i-2)* &
                                cc(m1,i,k,5)-wa4(i-1)*cc(m1,i-1,k,5)))-TI11*((wa2(i-2)* &
                                cc(m1,i,k,3)-wa2(i-1)*cc(m1,i-1,k,3))-(wa3(i-2)* &
                                cc(m1,i,k,4)-wa3(i-1)*cc(m1,i-1,k,4))))

                            ch(m2,i,5,k) = (cc(m1,i,k,1)+TR12*((wa1(i-2)*cc(m1,i,k,2)- &
                                wa1(i-1)*cc(m1,i-1,k,2))+(wa4(i-2)*cc(m1,i,k,5)-wa4(i-1)* &
                                cc(m1,i-1,k,5)))+TR11*((wa2(i-2)*cc(m1,i,k,3)-wa2(i-1)* &
                                cc(m1,i-1,k,3))+(wa3(i-2)*cc(m1,i,k,4)-wa3(i-1)* &
                                cc(m1,i-1,k,4))))+(TI12*((wa4(i-2)*cc(m1,i-1,k,5)+ &
                                wa4(i-1)*cc(m1,i,k,5))-(wa1(i-2)*cc(m1,i-1,k,2)+wa1(i-1)* &
                                cc(m1,i,k,2)))-TI11*((wa3(i-2)*cc(m1,i-1,k,4)+wa3(i-1)* &
                                cc(m1,i,k,4))-(wa2(i-2)*cc(m1,i-1,k,3)+wa2(i-1)* &
                                cc(m1,i,k,3))))

                            ch(m2,ic,4,k) = (TI12*((wa4(i-2)*cc(m1,i-1,k,5)+wa4(i-1)* &
                                cc(m1,i,k,5))-(wa1(i-2)*cc(m1,i-1,k,2)+wa1(i-1)* &
                                cc(m1,i,k,2)))-TI11*((wa3(i-2)*cc(m1,i-1,k,4)+wa3(i-1)* &
                                cc(m1,i,k,4))-(wa2(i-2)*cc(m1,i-1,k,3)+wa2(i-1)* &
                                cc(m1,i,k,3))))-(cc(m1,i,k,1)+TR12*((wa1(i-2)*cc(m1,i,k,2)- &
                                wa1(i-1)*cc(m1,i-1,k,2))+(wa4(i-2)*cc(m1,i,k,5)-wa4(i-1)* &
                                cc(m1,i-1,k,5)))+TR11*((wa2(i-2)*cc(m1,i,k,3)-wa2(i-1)* &
                                cc(m1,i-1,k,3))+(wa3(i-2)*cc(m1,i,k,4)-wa3(i-1)* &
                                cc(m1,i-1,k,4))))
                        end do
                    end do
                end do
            end if

        end subroutine mradf5

        subroutine mradfg(m,ido,iip,l1,idl1,cc,c1,c2,im1,in1,ch,ch2,im2,in2,wa)

            integer (ip) idl1
            integer (ip) ido
            integer (ip) in1
            integer (ip) in2
            integer (ip) iip
            integer (ip) l1

            real (wp) ai1
            real (wp) ai2
            real (wp) ar1
            real (wp) ar1h
            real (wp) ar2
            real (wp) ar2h
            real (wp) arg
            real (wp) c1(in1,ido,l1,iip)
            real (wp) c2(in1,idl1,iip)
            real (wp) cc(in1,ido,iip,l1)
            real (wp) ch(in2,ido,l1,iip)
            real (wp) ch2(in2,idl1,iip)
            real (wp) dc2
            real (wp) dcp
            real (wp) ds2
            real (wp) dsp
            integer (ip) i
            integer (ip) ic
            integer (ip) idij
            integer (ip) idp2
            integer (ip) ik
            integer (ip) im1
            integer (ip) im2
            integer (ip) iipp2
            integer (ip) iipph
            integer (ip) is
            integer (ip) j
            integer (ip) j2
            integer (ip) jc
            integer (ip) k
            integer (ip) l
            integer (ip) lc
            integer (ip) m
            integer (ip) m1
            integer (ip) m1d
            integer (ip) m2
            integer (ip) m2s
            integer (ip) nbd
            real (wp), parameter :: TWO_PI= 2.0_wp * acos(-1.0_wp)
            real (wp) wa(ido)

            m1d = (m-1)*im1+1
            m2s = 1-im2
            arg = TWO_PI / iip
            dcp = cos(arg)
            dsp = sin(arg)
            iipph = (iip+1)/2
            iipp2 = iip+2
            idp2 = ido+2
            nbd = (ido-1)/2

            if (ido /= 1) then

                do ik=1,idl1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ch2(m2,ik,1) = c2(m1,ik,1)
                    end do
                end do

                do j=2,iip
                    do k=1,l1
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            ch(m2,1,k,j) = c1(m1,1,k,j)
                        end do
                    end do
                end do

                if ( l1 >= nbd ) then
                    is = -ido
                    do j=2,iip
                        is = is+ido
                        idij = is
                        do i=3,ido,2
                            idij = idij+2
                            do k=1,l1
                                m2 = m2s
                                do m1=1,m1d,im1
                                    m2 = m2+im2
                                    ch(m2,i-1,k,j) = wa(idij-1)*c1(m1,i-1,k,j)+wa(idij)*c1(m1,i,k,j)
                                    ch(m2,i,k,j) = wa(idij-1)*c1(m1,i,k,j)-wa(idij)*c1(m1,i-1,k,j)
                                end do
                            end do
                        end do
                    end do
                else
                    is = -ido
                    do j=2,iip
                        is = is+ido
                        do k=1,l1
                            idij = is
                            do i=3,ido,2
                                idij = idij+2
                                m2 = m2s
                                do m1=1,m1d,im1
                                    m2 = m2+im2
                                    ch(m2,i-1,k,j) = wa(idij-1)*c1(m1,i-1,k,j)+wa(idij)*c1(m1,i,k,j)
                                    ch(m2,i,k,j) = wa(idij-1)*c1(m1,i,k,j)-wa(idij)*c1(m1,i-1,k,j)
                                end do
                            end do
                        end do
                    end do
                end if

                if (nbd >= l1) then
                    do j=2,iipph
                        jc = iipp2-j
                        do k=1,l1
                            do i=3,ido,2
                                m2 = m2s
                                do m1=1,m1d,im1
                                    m2 = m2+im2
                                    c1(m1,i-1,k,j) = ch(m2,i-1,k,j)+ch(m2,i-1,k,jc)
                                    c1(m1,i-1,k,jc) = ch(m2,i,k,j)-ch(m2,i,k,jc)
                                    c1(m1,i,k,j) = ch(m2,i,k,j)+ch(m2,i,k,jc)
                                    c1(m1,i,k,jc) = ch(m2,i-1,k,jc)-ch(m2,i-1,k,j)
                                end do
                            end do
                        end do
                    end do
                    go to 121
                else
                    do j=2,iipph
                        jc = iipp2-j
                        do i=3,ido,2
                            do k=1,l1
                                m2 = m2s
                                do m1=1,m1d,im1
                                    m2 = m2+im2
                                    c1(m1,i-1,k,j) = ch(m2,i-1,k,j)+ch(m2,i-1,k,jc)
                                    c1(m1,i-1,k,jc) = ch(m2,i,k,j)-ch(m2,i,k,jc)
                                    c1(m1,i,k,j) = ch(m2,i,k,j)+ch(m2,i,k,jc)
                                    c1(m1,i,k,jc) = ch(m2,i-1,k,jc)-ch(m2,i-1,k,j)
                                end do
                            end do
                        end do
                    end do
                    go to 121
                end if
            end if

            do ik=1,idl1
                m2 = m2s
                do m1=1,m1d,im1
                    m2 = m2+im2
                    c2(m1,ik,1) = ch2(m2,ik,1)
                end do
            end do

            121 do j=2,iipph
                jc = iipp2-j
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        c1(m1,1,k,j) = ch(m2,1,k,j)+ch(m2,1,k,jc)
                        c1(m1,1,k,jc) = ch(m2,1,k,jc)-ch(m2,1,k,j)
                    end do
                end do
            end do

            ar1 = 1.0_wp
            ai1 = 0.0_wp
            do l=2,iipph
                lc = iipp2-l
                ar1h = dcp*ar1-dsp*ai1
                ai1 = dcp*ai1+dsp*ar1
                ar1 = ar1h
                do ik=1,idl1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ch2(m2,ik,l) = c2(m1,ik,1)+ar1*c2(m1,ik,2)
                        ch2(m2,ik,lc) = ai1*c2(m1,ik,iip)
                    end do
                end do
                dc2 = ar1
                ds2 = ai1
                ar2 = ar1
                ai2 = ai1
                do j=3,iipph
                    jc = iipp2-j
                    ar2h = dc2*ar2-ds2*ai2
                    ai2 = dc2*ai2+ds2*ar2
                    ar2 = ar2h
                    do ik=1,idl1
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            ch2(m2,ik,l) = ch2(m2,ik,l)+ar2*c2(m1,ik,j)
                            ch2(m2,ik,lc) = ch2(m2,ik,lc)+ai2*c2(m1,ik,jc)
                        end do
                    end do
                end do
            end do
            do j=2,iipph
                do ik=1,idl1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        ch2(m2,ik,1) = ch2(m2,ik,1)+c2(m1,ik,j)
                    end do
                end do
            end do

            if (ido >= l1) then
                do k=1,l1
                    do i=1,ido
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            cc(m1,i,1,k) = ch(m2,i,k,1)
                        end do
                    end do
                end do
            else
                do i=1,ido
                    do k=1,l1
                        m2 = m2s
                        do m1=1,m1d,im1
                            m2 = m2+im2
                            cc(m1,i,1,k) = ch(m2,i,k,1)
                        end do
                    end do
                end do
            end if

            do j=2,iipph
                jc = iipp2-j
                j2 = j+j
                do k=1,l1
                    m2 = m2s
                    do m1=1,m1d,im1
                        m2 = m2+im2
                        cc(m1,ido,j2-2,k) = ch(m2,1,k,j)
                        cc(m1,1,j2-1,k) = ch(m2,1,k,jc)
                    end do
                end do
            end do
            if (ido /= 1) then
                if (nbd >= l1) then
                    do j=2,iipph
                        jc = iipp2-j
                        j2 = j+j
                        do k=1,l1
                            do i=3,ido,2
                                ic = idp2-i
                                m2 = m2s
                                do m1=1,m1d,im1
                                    m2 = m2+im2
                                    cc(m1,i-1,j2-1,k) = ch(m2,i-1,k,j)+ch(m2,i-1,k,jc)
                                    cc(m1,ic-1,j2-2,k) = ch(m2,i-1,k,j)-ch(m2,i-1,k,jc)
                                    cc(m1,i,j2-1,k) = ch(m2,i,k,j)+ch(m2,i,k,jc)
                                    cc(m1,ic,j2-2,k) = ch(m2,i,k,jc)-ch(m2,i,k,j)
                                end do
                            end do
                        end do
                    end do
                else
                    do j=2,iipph
                        jc = iipp2-j
                        j2 = j+j
                        do i=3,ido,2
                            ic = idp2-i
                            do k=1,l1
                                m2 = m2s
                                do m1=1,m1d,im1
                                    m2 = m2+im2
                                    cc(m1,i-1,j2-1,k) = ch(m2,i-1,k,j)+ch(m2,i-1,k,jc)
                                    cc(m1,ic-1,j2-2,k) = ch(m2,i-1,k,j)-ch(m2,i-1,k,jc)
                                    cc(m1,i,j2-1,k) = ch(m2,i,k,j)+ch(m2,i,k,jc)
                                    cc(m1,ic,j2-2,k) = ch(m2,i,k,jc)-ch(m2,i,k,j)
                                end do
                            end do
                        end do
                    end do
                end if
            end if

        end subroutine mradfg

    end subroutine mrftf1



    subroutine mrfti1(n,wa,fac)
        !
        !  input
        !  n, the number for which factorization and
        !  other information is needed.
        !
        !  output
        !   wa(n), trigonometric information.
        !
        !  output
        !  fac(15), factorization information. fac(1) is
        !  n, fac(2) is nf, the number of factors, and fac(3:nf+2) are the factors.
        !
        !--------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------
        integer (ip), intent (in)  :: n
        real (wp),    intent (out) :: wa(n)
        real (wp),    intent (out) :: fac(15)
        !--------------------------------------------------------------
        ! Dictionary: local variables
        !--------------------------------------------------------------
        integer (ip)            :: i, ib, ido, ii, iip, iipm, is
        integer (ip)            :: j, k1, l1, l2, ld
        integer (ip)            :: nf, nfm1, nl, nq, nr, ntry
        integer (ip), parameter :: ntryh(*) = [ 4, 2, 3, 5 ]
        real (wp),    parameter :: TWO_PI = 2.0_wp * acos(-1.0_wp)
        real (wp)               :: arg, argh, argld, fi
        !--------------------------------------------------------------

        nl = n
        nf = 0
        j = 0

101     j = j+1
        if(j < 4) then
            goto 102
        else if(j == 4) then
            goto 102
        else
            goto 103
        end if
102     ntry = ntryh(j)
        go to 104
103     ntry = ntryh(4)+2*(j-4) !ntry = ntry + 2
104     nq = nl/ntry
        nr = nl-ntry*nq
        if(nr < 0) then
            goto 101
        else if(nr == 0) then
            goto 105
        else
            goto 101
        end if
105     nf = nf+1
        fac(nf+2) = real(ntry, kind=wp)
        nl = nq
        if (ntry /= 2) go to 107
        do i=2,nf
            ib = nf-i+2
            fac(ib+2) = fac(ib+1)
        end do
        fac(3) = 2
107     if (nl /= 1) go to 104

        !        factorize_loop: do
        !            j = j + 1
        !            if (j <= 4) then
        !                ntry = ntryh(j)
        !            else
        !                ntry = ntryh(4)+2*(j-4) ! ntry = ntry + 2
        !                inner_loop: do while (nl /= 1 )
        !                    nq = nl/ntry
        !                    nr = nl-ntry*nq
        !                    if (nr /= 0) then
        !                        cycle factorize_loop
        !                    end if
        !                    nf = nf+1
        !                    fac(nf+2) = ntry
        !                    nl = nq
        !                    if (ntry == 2 .and. nf /= 1 ) then
        !                        do i=2,nf
        !                            ib = nf-i+2
        !                            fac(ib+2) = fac(ib+1)
        !                        end do
        !                        fac(3) = 2
        !                    end if
        !                end do inner_loop
        !            end if
        !            exit factorize_loop
        !        end do factorize_loop

        fac(1) = n
        fac(2) = nf
        argh = TWO_PI/n
        is = 0
        nfm1 = nf-1
        l1 = 1

        do k1=1,nfm1
            iip = int(fac(k1+2), kind=ip)
            ld = 0
            l2 = l1*iip
            ido = n/l2
            iipm = iip-1

            do j=1,iipm

                ld = ld+l1
                i = is
                argld = real(ld, kind=wp) * argh
                fi = 0.0_wp
                do ii=3,ido,2
                    i = i+2
                    fi = fi + 1.0_wp
                    arg = fi*argld
                    wa(i-1) = cos(arg)
                    wa(i) = sin(arg)
                end do
                is = is+ido

            end do
            l1 = l2
        end do

    end subroutine mrfti1



    subroutine msntb1(lot,jump,n,inc,x,wsave,dsum,xh,work,ier)

        integer (ip) inc
        integer (ip) lot

        real (wp) dsum(*)
        real (wp) fnp1s4
        integer (ip) i
        integer (ip) ier
        integer (ip) ier1
        integer (ip) jump
        integer (ip) k
        integer (ip) kc
        integer (ip) lj
        integer (ip) lnsv
        integer (ip) lnwk
        integer (ip) lnxh
        integer (ip) m
        integer (ip) m1
        integer (ip) modn
        integer (ip) n
        integer (ip) np1
        integer (ip) ns2
        real (wp), parameter :: HALF_SQRT3 = sqrt(3.0_wp)/2
        real (wp) t1
        real (wp) t2
        real (wp) work(*)
        real (wp) wsave(*)
        real (wp) x(inc,*)
        real (wp) xh(lot,*)
        real (wp) xhold

        ier = 0
        lj = (lot-1)*jump+1

        if(n-2 < 0) then
            return
        else if (n-2 == 0) then
            do m=1,lj,jump
                xhold = HALF_SQRT3*(x(m,1)+x(m,2))
                x(m,2) = HALF_SQRT3*(x(m,1)-x(m,2))
                x(m,1) = xhold
            end do
        else
            np1 = n+1
            ns2 = n/2
            do k=1,ns2
                kc = np1-k
                m1 = 0
                do m=1,lj,jump
                    m1 = m1+1
                    t1 = x(m,k)-x(m,kc)
                    t2 = wsave(k)*(x(m,k)+x(m,kc))
                    xh(m1,k+1) = t1+t2
                    xh(m1,kc+1) = t2-t1
                end do
            end do

            modn = mod(n,2)

            if (modn /= 0) then
                m1 = 0
                do m=1,lj,jump
                    m1 = m1+1
                    xh(m1,ns2+2) =  4.0_wp * x(m,ns2+1)
                end do
            end if

            do m=1,lot
                xh(m,1) = 0.0_wp
            end do

            lnxh = lot-1 + lot*(np1-1) + 1
            lnsv = np1 + int(log( real ( np1, kind=wp))/log(2.0_wp)) + 4
            lnwk = lot*np1

            call rfftmf(lot,1,np1,lot,xh,lnxh,wsave(ns2+1),lnsv,work,lnwk,ier1)

            if (ier1 /= 0) then
                ier = 20
                call xerfft('msntb1',-5)
                return
            end if

            if(mod(np1,2) == 0) then
                do m=1,lot
                    xh(m,np1) = xh(m,np1)+xh(m,np1)
                end do
            end if

            fnp1s4 = real(np1, kind=wp)/4
            m1 = 0

            do m=1,lj,jump
                m1 = m1+1
                x(m,1) = fnp1s4*xh(m1,1)
                dsum(m1) = x(m,1)
            end do

            do i=3,n,2
                m1 = 0
                do m=1,lj,jump
                    m1 = m1+1
                    x(m,i-1) = fnp1s4*xh(m1,i)
                    dsum(m1) = dsum(m1)+fnp1s4*xh(m1,i-1)
                    x(m,i) = dsum(m1)
                end do
            end do

            if (modn == 0) then
                m1 = 0
                do m=1,lj,jump
                    m1 = m1+1
                    x(m,n) = fnp1s4*xh(m1,n+1)
                end do
            end if
        end if

    end subroutine msntb1


    subroutine msntf1(lot,jump,n,inc,x,wsave,dsum,xh,work,ier)

        integer (ip) inc
        integer (ip) lot

        real (wp) dsum(*)
        integer (ip) i
        integer (ip) ier
        integer (ip) ier1
        integer (ip) jump
        integer (ip) k
        integer (ip) kc
        integer (ip) lj
        integer (ip) lnsv
        integer (ip) lnwk
        integer (ip) lnxh
        integer (ip) m
        integer (ip) m1
        integer (ip) modn
        integer (ip) n
        integer (ip) np1
        integer (ip) ns2
        real (wp) sfnp1
        real (wp) t1
        real (wp) t2
        real (wp) work(*)
        real (wp) wsave(*)
        real (wp) x(inc,*)
        real (wp) xh(lot,*)
        real (wp) xhold

        ier = 0
        lj = (lot-1)*jump+1

        if (n < 2) then
            return
        else if (n == 2) then
            do m=1,lj,jump
                associate( sqrt3 => sqrt(3.0_wp) )
                    xhold = (x(m,1)+x(m,2))/sqrt3
                    x(m,2) = (x(m,1)-x(m,2))/sqrt3
                    x(m,1) = xhold
                end associate
            end do
        else
            np1 = n+1
            ns2 = n/2
            do k=1,ns2
                kc = np1-k
                m1 = 0
                do m=1,lj,jump
                    m1 = m1 + 1
                    t1 = x(m,k)-x(m,kc)
                    t2 = wsave(k)*(x(m,k)+x(m,kc))
                    xh(m1,k+1) = t1+t2
                    xh(m1,kc+1) = t2-t1
                end do
            end do

            modn = mod(n,2)

            if (modn /= 0) then
                m1 = 0
                do m=1,lj,jump
                    m1 = m1 + 1
                    xh(m1,ns2+2) =  4.0_wp  * x(m,ns2+1)
                end do
            end if

            do m=1,lot
                xh(m,1) = 0.0_wp
            end do

            lnxh = lot-1 + lot*(np1-1) + 1
            lnsv = np1 + int(log(real(np1, kind=wp))/log(2.0_wp)) + 4
            lnwk = lot*np1

            call rfftmf(lot,1,np1,lot,xh,lnxh,wsave(ns2+1),lnsv,work,lnwk,ier1)
            if (ier1 /= 0) then
                ier = 20
                call xerfft('msntf1',-5)
                return
            end if

            if(mod(np1,2) == 0) then
                do m=1,lot
                    xh(m,np1) = xh(m,np1)+xh(m,np1)
                end do
            end if


            sfnp1 = 1.0_wp/np1
            m1 = 0

            do m=1,lj,jump
                m1 = m1+1
                x(m,1) = 0.5_wp * xh(m1,1)
                dsum(m1) = x(m,1)
            end do

            do i=3,n,2
                m1 = 0
                do m=1,lj,jump
                    m1 = m1+1
                    x(m,i-1) = 0.5_wp * xh(m1,i)
                    dsum(m1) = dsum(m1)+ 0.5_wp * xh(m1,i-1)
                    x(m,i) = dsum(m1)
                end do
            end do

            if (modn == 0) then
                m1 = 0
                do m=1,lj,jump
                    m1 = m1+1
                    x(m,n) = 0.5_wp * xh(m1,n+1)
                end do
            end if
        end if

    end subroutine msntf1


    subroutine r1f2kb(ido,l1,cc,in1,ch,in2,wa1)

        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) l1

        real (wp) cc(in1,ido,2,l1)
        real (wp) ch(in2,ido,l1,2)
        integer (ip) i
        integer (ip) ic
        integer (ip) idp2
        integer (ip) k
        real (wp) wa1(ido)

        do k=1,l1
            ch(1,1,k,1) = cc(1,1,1,k)+cc(1,ido,2,k)
            ch(1,1,k,2) = cc(1,1,1,k)-cc(1,ido,2,k)
        end do

        if(ido < 2) then
            return
        else if (ido == 2) then
            do k=1,l1
                ch(1,ido,k,1) = cc(1,ido,1,k)+cc(1,ido,1,k)
                ch(1,ido,k,2) = -(cc(1,1,2,k)+cc(1,1,2,k))
            end do
        else
            idp2 = ido+2
            do k=1,l1
                do i=3,ido,2
                    ic = idp2-i

                    ch(1,i-1,k,1) = cc(1,i-1,1,k)+cc(1,ic-1,2,k)
                    ch(1,i,k,1) = cc(1,i,1,k)-cc(1,ic,2,k)

                    ch(1,i-1,k,2) = wa1(i-2)*(cc(1,i-1,1,k)-cc(1,ic-1,2,k)) &
                        -wa1(i-1)*(cc(1,i,1,k)+cc(1,ic,2,k))
                    ch(1,i,k,2) = wa1(i-2)*(cc(1,i,1,k)+cc(1,ic,2,k))+wa1(i-1) &
                        *(cc(1,i-1,1,k)-cc(1,ic-1,2,k))
                end do
            end do
            if (mod(ido,2) /= 1) then
                do k=1,l1
                    ch(1,ido,k,1) = cc(1,ido,1,k)+cc(1,ido,1,k)
                    ch(1,ido,k,2) = -(cc(1,1,2,k)+cc(1,1,2,k))
                end do
            end if
        end if

    end subroutine r1f2kb

    subroutine r1f2kf(ido,l1,cc,in1,ch,in2,wa1)

        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) l1

        real (wp) ch(in2,ido,2,l1)
        real (wp) cc(in1,ido,l1,2)
        integer (ip) i
        integer (ip) ic
        integer (ip) idp2
        integer (ip) k
        real (wp) wa1(ido)

        do k=1,l1
            ch(1,1,1,k) = cc(1,1,k,1)+cc(1,1,k,2)
            ch(1,ido,2,k) = cc(1,1,k,1)-cc(1,1,k,2)
        end do

        if(ido < 2) then
            return
        else if (ido == 2) then
            do k=1,l1
                ch(1,1,2,k) = -cc(1,ido,k,2)
                ch(1,ido,1,k) = cc(1,ido,k,1)
            end do
        else
            idp2 = ido+2
            do k=1,l1
                do i=3,ido,2
                    ic = idp2-i
                    ch(1,i,1,k) = cc(1,i,k,1)+(wa1(i-2)*cc(1,i,k,2) &
                        -wa1(i-1)*cc(1,i-1,k,2))
                    ch(1,ic,2,k) = (wa1(i-2)*cc(1,i,k,2) &
                        -wa1(i-1)*cc(1,i-1,k,2))-cc(1,i,k,1)
                    ch(1,i-1,1,k) = cc(1,i-1,k,1)+(wa1(i-2)*cc(1,i-1,k,2) &
                        +wa1(i-1)*cc(1,i,k,2))
                    ch(1,ic-1,2,k) = cc(1,i-1,k,1)-(wa1(i-2)*cc(1,i-1,k,2) &
                        +wa1(i-1)*cc(1,i,k,2))
                end do
            end do
            if (mod(ido,2) /= 1) then
                do k=1,l1
                    ch(1,1,2,k) = -cc(1,ido,k,2)
                    ch(1,ido,1,k) = cc(1,ido,k,1)
                end do
            end if
        end if

    end subroutine r1f2kf

    subroutine r1f3kb(ido,l1,cc,in1,ch,in2,wa1,wa2)

        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) l1

        real (wp) cc(in1,ido,3,l1)
        real (wp) ch(in2,ido,l1,3)
        integer (ip) i
        integer (ip) ic
        integer (ip) idp2
        integer (ip) k
        real (wp) wa1(ido)
        real (wp) wa2(ido)
        real (wp), parameter :: TWO_PI = 2.0_wp * acos(-1.0_wp)
        real (wp), parameter :: ARG =TWO_PI/3
        real (wp), parameter :: TAUR = cos(ARG)
        real (wp), parameter :: TAUI = sin(ARG)

        do k = 1, l1
            ch(1,1,k,1) = cc(1,1,1,k) + 2.0_wp * cc(1,ido,2,k)
            ch(1,1,k,2) = cc(1,1,1,k) + ( 2.0_wp * TAUR ) * cc(1,ido,2,k) &
                - ( 2.0_wp *TAUI)*cc(1,1,3,k)
            ch(1,1,k,3) = cc(1,1,1,k) + ( 2.0_wp *TAUR)*cc(1,ido,2,k) &
                + 2.0_wp *TAUI*cc(1,1,3,k)
        end do

        if (ido /= 1) then
            idp2 = ido+2
            do k=1,l1
                do i=3,ido,2
                    ic = idp2-i
                    ch(1,i-1,k,1) = cc(1,i-1,1,k)+(cc(1,i-1,3,k)+cc(1,ic-1,2,k))
                    ch(1,i,k,1) = cc(1,i,1,k)+(cc(1,i,3,k)-cc(1,ic,2,k))

                    ch(1,i-1,k,2) = wa1(i-2)* &
                        ((cc(1,i-1,1,k)+TAUR*(cc(1,i-1,3,k)+cc(1,ic-1,2,k)))- &
                        (TAUI*(cc(1,i,3,k)+cc(1,ic,2,k)))) &
                        -wa1(i-1)* &
                        ((cc(1,i,1,k)+TAUR*(cc(1,i,3,k)-cc(1,ic,2,k)))+ &
                        (TAUI*(cc(1,i-1,3,k)-cc(1,ic-1,2,k))))

                    ch(1,i,k,2) = wa1(i-2)* &
                        ((cc(1,i,1,k)+TAUR*(cc(1,i,3,k)-cc(1,ic,2,k)))+ &
                        (TAUI*(cc(1,i-1,3,k)-cc(1,ic-1,2,k)))) &
                        +wa1(i-1)* &
                        ((cc(1,i-1,1,k)+TAUR*(cc(1,i-1,3,k)+cc(1,ic-1,2,k)))- &
                        (TAUI*(cc(1,i,3,k)+cc(1,ic,2,k))))

                    ch(1,i-1,k,3) = wa2(i-2)* &
                        ((cc(1,i-1,1,k)+TAUR*(cc(1,i-1,3,k)+cc(1,ic-1,2,k)))+ &
                        (TAUI*(cc(1,i,3,k)+cc(1,ic,2,k)))) &
                        -wa2(i-1)* &
                        ((cc(1,i,1,k)+TAUR*(cc(1,i,3,k)-cc(1,ic,2,k)))- &
                        (TAUI*(cc(1,i-1,3,k)-cc(1,ic-1,2,k))))

                    ch(1,i,k,3) = wa2(i-2)* &
                        ((cc(1,i,1,k)+TAUR*(cc(1,i,3,k)-cc(1,ic,2,k)))- &
                        (TAUI*(cc(1,i-1,3,k)-cc(1,ic-1,2,k)))) &
                        +wa2(i-1)* &
                        ((cc(1,i-1,1,k)+TAUR*(cc(1,i-1,3,k)+cc(1,ic-1,2,k)))+ &
                        (TAUI*(cc(1,i,3,k)+cc(1,ic,2,k))))
                end do
            end do
        end if

    end subroutine r1f3kb

    subroutine r1f3kf(ido,l1,cc,in1,ch,in2,wa1,wa2)

        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) l1

        real (wp) cc(in1,ido,l1,3)
        real (wp) ch(in2,ido,3,l1)
        integer (ip) i
        integer (ip) ic
        integer (ip) idp2
        integer (ip) k
        real (wp) wa1(ido)
        real (wp) wa2(ido)
        real (wp), parameter :: TWO_PI = 2.0_wp * acos(-1.0_wp)
        real (wp), parameter :: ARG = TWO_PI/3
        real (wp), parameter :: TAUR = cos(ARG)
        real (wp), parameter :: TAUI = sin(ARG)

        do k=1,l1
            ch(1,1,1,k) = cc(1,1,k,1)+(cc(1,1,k,2)+cc(1,1,k,3))
            ch(1,1,3,k) = TAUI*(cc(1,1,k,3)-cc(1,1,k,2))
            ch(1,ido,2,k) = cc(1,1,k,1)+TAUR*(cc(1,1,k,2)+cc(1,1,k,3))
        end do

        if (ido /= 1) then
            idp2 = ido+2
            do k=1,l1
                do i=3,ido,2
                    ic = idp2-i

                    ch(1,i-1,1,k) = cc(1,i-1,k,1)+((wa1(i-2)*cc(1,i-1,k,2)+ &
                        wa1(i-1)*cc(1,i,k,2))+(wa2(i-2)*cc(1,i-1,k,3)+wa2(i-1)* &
                        cc(1,i,k,3)))

                    ch(1,i,1,k) = cc(1,i,k,1)+((wa1(i-2)*cc(1,i,k,2)- &
                        wa1(i-1)*cc(1,i-1,k,2))+(wa2(i-2)*cc(1,i,k,3)-wa2(i-1)* &
                        cc(1,i-1,k,3)))

                    ch(1,i-1,3,k) = (cc(1,i-1,k,1)+TAUR*((wa1(i-2)* &
                        cc(1,i-1,k,2)+wa1(i-1)*cc(1,i,k,2))+(wa2(i-2)* &
                        cc(1,i-1,k,3)+wa2(i-1)*cc(1,i,k,3))))+(TAUI*((wa1(i-2)* &
                        cc(1,i,k,2)-wa1(i-1)*cc(1,i-1,k,2))-(wa2(i-2)* &
                        cc(1,i,k,3)-wa2(i-1)*cc(1,i-1,k,3))))

                    ch(1,ic-1,2,k) = (cc(1,i-1,k,1)+TAUR*((wa1(i-2)* &
                        cc(1,i-1,k,2)+wa1(i-1)*cc(1,i,k,2))+(wa2(i-2)* &
                        cc(1,i-1,k,3)+wa2(i-1)*cc(1,i,k,3))))-(TAUI*((wa1(i-2)* &
                        cc(1,i,k,2)-wa1(i-1)*cc(1,i-1,k,2))-(wa2(i-2)* &
                        cc(1,i,k,3)-wa2(i-1)*cc(1,i-1,k,3))))

                    ch(1,i,3,k) = (cc(1,i,k,1)+TAUR*((wa1(i-2)*cc(1,i,k,2)- &
                        wa1(i-1)*cc(1,i-1,k,2))+(wa2(i-2)*cc(1,i,k,3)-wa2(i-1)* &
                        cc(1,i-1,k,3))))+(TAUI*((wa2(i-2)*cc(1,i-1,k,3)+wa2(i-1)* &
                        cc(1,i,k,3))-(wa1(i-2)*cc(1,i-1,k,2)+wa1(i-1)* &
                        cc(1,i,k,2))))

                    ch(1,ic,2,k) = (TAUI*((wa2(i-2)*cc(1,i-1,k,3)+wa2(i-1)* &
                        cc(1,i,k,3))-(wa1(i-2)*cc(1,i-1,k,2)+wa1(i-1)* &
                        cc(1,i,k,2))))-(cc(1,i,k,1)+TAUR*((wa1(i-2)*cc(1,i,k,2)- &
                        wa1(i-1)*cc(1,i-1,k,2))+(wa2(i-2)*cc(1,i,k,3)-wa2(i-1)* &
                        cc(1,i-1,k,3))))
                end do
            end do
        end if

    end subroutine r1f3kf

    subroutine r1f4kb(ido,l1,cc,in1,ch,in2,wa1,wa2,wa3)

        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) l1

        real (wp) cc(in1,ido,4,l1)
        real (wp) ch(in2,ido,l1,4)
        integer (ip) i
        integer (ip) ic
        integer (ip) idp2
        integer (ip) k
        real (wp) wa1(ido)
        real (wp) wa2(ido)
        real (wp) wa3(ido)
        real (wp), parameter :: SQRT2 = sqrt(2.0_wp)

        do k=1,l1
            ch(1,1,k,3) = (cc(1,1,1,k)+cc(1,ido,4,k)) &
                -(cc(1,ido,2,k)+cc(1,ido,2,k))
            ch(1,1,k,1) = (cc(1,1,1,k)+cc(1,ido,4,k)) &
                +(cc(1,ido,2,k)+cc(1,ido,2,k))
            ch(1,1,k,4) = (cc(1,1,1,k)-cc(1,ido,4,k)) &
                +(cc(1,1,3,k)+cc(1,1,3,k))
            ch(1,1,k,2) = (cc(1,1,1,k)-cc(1,ido,4,k)) &
                -(cc(1,1,3,k)+cc(1,1,3,k))
        end do

        if (ido < 2) then
            return
        else if (ido == 2) then
            do k=1,l1
                ch(1,ido,k,1) = (cc(1,ido,1,k)+cc(1,ido,3,k)) &
                    +(cc(1,ido,1,k)+cc(1,ido,3,k))
                ch(1,ido,k,2) = SQRT2*((cc(1,ido,1,k)-cc(1,ido,3,k)) &
                    -(cc(1,1,2,k)+cc(1,1,4,k)))
                ch(1,ido,k,3) = (cc(1,1,4,k)-cc(1,1,2,k)) &
                    +(cc(1,1,4,k)-cc(1,1,2,k))
                ch(1,ido,k,4) = -SQRT2*((cc(1,ido,1,k)-cc(1,ido,3,k)) &
                    +(cc(1,1,2,k)+cc(1,1,4,k)))
            end do
        else
            idp2 = ido+2
            do k=1,l1
                do i=3,ido,2
                    ic = idp2-i
                    ch(1,i-1,k,1) = (cc(1,i-1,1,k)+cc(1,ic-1,4,k)) &
                        +(cc(1,i-1,3,k)+cc(1,ic-1,2,k))
                    ch(1,i,k,1) = (cc(1,i,1,k)-cc(1,ic,4,k)) &
                        +(cc(1,i,3,k)-cc(1,ic,2,k))
                    ch(1,i-1,k,2)=wa1(i-2)*((cc(1,i-1,1,k)-cc(1,ic-1,4,k)) &
                        -(cc(1,i,3,k)+cc(1,ic,2,k)))-wa1(i-1) &
                        *((cc(1,i,1,k)+cc(1,ic,4,k))+(cc(1,i-1,3,k)-cc(1,ic-1,2,k)))
                    ch(1,i,k,2)=wa1(i-2)*((cc(1,i,1,k)+cc(1,ic,4,k)) &
                        +(cc(1,i-1,3,k)-cc(1,ic-1,2,k)))+wa1(i-1) &
                        *((cc(1,i-1,1,k)-cc(1,ic-1,4,k))-(cc(1,i,3,k)+cc(1,ic,2,k)))
                    ch(1,i-1,k,3)=wa2(i-2)*((cc(1,i-1,1,k)+cc(1,ic-1,4,k)) &
                        -(cc(1,i-1,3,k)+cc(1,ic-1,2,k)))-wa2(i-1) &
                        *((cc(1,i,1,k)-cc(1,ic,4,k))-(cc(1,i,3,k)-cc(1,ic,2,k)))
                    ch(1,i,k,3)=wa2(i-2)*((cc(1,i,1,k)-cc(1,ic,4,k)) &
                        -(cc(1,i,3,k)-cc(1,ic,2,k)))+wa2(i-1) &
                        *((cc(1,i-1,1,k)+cc(1,ic-1,4,k))-(cc(1,i-1,3,k) &
                        +cc(1,ic-1,2,k)))
                    ch(1,i-1,k,4)=wa3(i-2)*((cc(1,i-1,1,k)-cc(1,ic-1,4,k)) &
                        +(cc(1,i,3,k)+cc(1,ic,2,k)))-wa3(i-1) &
                        *((cc(1,i,1,k)+cc(1,ic,4,k))-(cc(1,i-1,3,k)-cc(1,ic-1,2,k)))
                    ch(1,i,k,4)=wa3(i-2)*((cc(1,i,1,k)+cc(1,ic,4,k)) &
                        -(cc(1,i-1,3,k)-cc(1,ic-1,2,k)))+wa3(i-1) &
                        *((cc(1,i-1,1,k)-cc(1,ic-1,4,k))+(cc(1,i,3,k)+cc(1,ic,2,k)))
                end do
            end do
            if (mod(ido,2) /= 1) then
                do k=1,l1
                    ch(1,ido,k,1) = (cc(1,ido,1,k)+cc(1,ido,3,k)) &
                        +(cc(1,ido,1,k)+cc(1,ido,3,k))
                    ch(1,ido,k,2) = SQRT2*((cc(1,ido,1,k)-cc(1,ido,3,k)) &
                        -(cc(1,1,2,k)+cc(1,1,4,k)))
                    ch(1,ido,k,3) = (cc(1,1,4,k)-cc(1,1,2,k)) &
                        +(cc(1,1,4,k)-cc(1,1,2,k))
                    ch(1,ido,k,4) = -SQRT2*((cc(1,ido,1,k)-cc(1,ido,3,k)) &
                        +(cc(1,1,2,k)+cc(1,1,4,k)))
                end do
            end if
        end if

    end subroutine r1f4kb

    subroutine r1f4kf(ido,l1,cc,in1,ch,in2,wa1,wa2,wa3)

        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) l1

        real (wp) cc(in1,ido,l1,4)
        real (wp) ch(in2,ido,4,l1)
        integer (ip) i
        integer (ip) ic
        integer (ip) idp2
        integer (ip) k
        real (wp) wa1(ido)
        real (wp) wa2(ido)
        real (wp) wa3(ido)
        real (wp), parameter :: HALF_SQRT2=sqrt(2.0_wp)/2

        do k=1,l1
            ch(1,1,1,k) = (cc(1,1,k,2)+cc(1,1,k,4))+(cc(1,1,k,1)+cc(1,1,k,3))
            ch(1,ido,4,k) = (cc(1,1,k,1)+cc(1,1,k,3))-(cc(1,1,k,2)+cc(1,1,k,4))
            ch(1,ido,2,k) = cc(1,1,k,1)-cc(1,1,k,3)
            ch(1,1,3,k) = cc(1,1,k,4)-cc(1,1,k,2)
        end do

        if (ido < 2) then
            return
        else if (ido == 2) then
            do k=1,l1
                ch(1,ido,1,k) = (HALF_SQRT2*(cc(1,ido,k,2)-cc(1,ido,k,4)))+cc(1,ido,k,1)
                ch(1,ido,3,k) = cc(1,ido,k,1)-(HALF_SQRT2*(cc(1,ido,k,2)-cc(1,ido,k,4)))
                ch(1,1,2,k) = (-HALF_SQRT2*(cc(1,ido,k,2)+cc(1,ido,k,4)))-cc(1,ido,k,3)
                ch(1,1,4,k) = (-HALF_SQRT2*(cc(1,ido,k,2)+cc(1,ido,k,4)))+cc(1,ido,k,3)
            end do
        else
            idp2 = ido+2
            do k=1,l1
                do i=3,ido,2
                    ic = idp2-i
                    ch(1,i-1,1,k) = ((wa1(i-2)*cc(1,i-1,k,2)+wa1(i-1)* &
                        cc(1,i,k,2))+(wa3(i-2)*cc(1,i-1,k,4)+wa3(i-1)* &
                        cc(1,i,k,4)))+(cc(1,i-1,k,1)+(wa2(i-2)*cc(1,i-1,k,3)+ &
                        wa2(i-1)*cc(1,i,k,3)))
                    ch(1,ic-1,4,k) = (cc(1,i-1,k,1)+(wa2(i-2)*cc(1,i-1,k,3)+ &
                        wa2(i-1)*cc(1,i,k,3)))-((wa1(i-2)*cc(1,i-1,k,2)+ &
                        wa1(i-1)*cc(1,i,k,2))+(wa3(i-2)*cc(1,i-1,k,4)+ &
                        wa3(i-1)*cc(1,i,k,4)))
                    ch(1,i,1,k) = ((wa1(i-2)*cc(1,i,k,2)-wa1(i-1)* &
                        cc(1,i-1,k,2))+(wa3(i-2)*cc(1,i,k,4)-wa3(i-1)* &
                        cc(1,i-1,k,4)))+(cc(1,i,k,1)+(wa2(i-2)*cc(1,i,k,3)- &
                        wa2(i-1)*cc(1,i-1,k,3)))
                    ch(1,ic,4,k) = ((wa1(i-2)*cc(1,i,k,2)-wa1(i-1)* &
                        cc(1,i-1,k,2))+(wa3(i-2)*cc(1,i,k,4)-wa3(i-1)* &
                        cc(1,i-1,k,4)))-(cc(1,i,k,1)+(wa2(i-2)*cc(1,i,k,3)- &
                        wa2(i-1)*cc(1,i-1,k,3)))
                    ch(1,i-1,3,k) = ((wa1(i-2)*cc(1,i,k,2)-wa1(i-1)* &
                        cc(1,i-1,k,2))-(wa3(i-2)*cc(1,i,k,4)-wa3(i-1)* &
                        cc(1,i-1,k,4)))+(cc(1,i-1,k,1)-(wa2(i-2)*cc(1,i-1,k,3)+ &
                        wa2(i-1)*cc(1,i,k,3)))
                    ch(1,ic-1,2,k) = (cc(1,i-1,k,1)-(wa2(i-2)*cc(1,i-1,k,3)+ &
                        wa2(i-1)*cc(1,i,k,3)))-((wa1(i-2)*cc(1,i,k,2)-wa1(i-1)* &
                        cc(1,i-1,k,2))-(wa3(i-2)*cc(1,i,k,4)-wa3(i-1)* &
                        cc(1,i-1,k,4)))
                    ch(1,i,3,k) = ((wa3(i-2)*cc(1,i-1,k,4)+wa3(i-1)* &
                        cc(1,i,k,4))-(wa1(i-2)*cc(1,i-1,k,2)+wa1(i-1)* &
                        cc(1,i,k,2)))+(cc(1,i,k,1)-(wa2(i-2)*cc(1,i,k,3)- &
                        wa2(i-1)*cc(1,i-1,k,3)))
                    ch(1,ic,2,k) = ((wa3(i-2)*cc(1,i-1,k,4)+wa3(i-1)* &
                        cc(1,i,k,4))-(wa1(i-2)*cc(1,i-1,k,2)+wa1(i-1)* &
                        cc(1,i,k,2)))-(cc(1,i,k,1)-(wa2(i-2)*cc(1,i,k,3)- &
                        wa2(i-1)*cc(1,i-1,k,3)))
                end do
            end do
            if (mod(ido,2) /= 1) then
                do k=1,l1
                    ch(1,ido,1,k) = (HALF_SQRT2*(cc(1,ido,k,2)-cc(1,ido,k,4)))+cc(1,ido,k,1)
                    ch(1,ido,3,k) = cc(1,ido,k,1)-(HALF_SQRT2*(cc(1,ido,k,2)-cc(1,ido,k,4)))
                    ch(1,1,2,k) = (-HALF_SQRT2*(cc(1,ido,k,2)+cc(1,ido,k,4)))-cc(1,ido,k,3)
                    ch(1,1,4,k) = (-HALF_SQRT2*(cc(1,ido,k,2)+cc(1,ido,k,4)))+cc(1,ido,k,3)
                end do
            end if
        end if

    end subroutine r1f4kf

    subroutine r1f5kb(ido,l1,cc,in1,ch,in2,wa1,wa2,wa3,wa4)
        !--------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------
        integer (ip), intent (in)     :: ido
        integer (ip), intent (in)     :: l1
        real (wp),    intent (in out) :: cc(in1,ido,5,l1)
        integer (ip), intent (in)     :: in1
        real (wp),    intent (in out) :: ch(in2,ido,l1,5)
        integer (ip), intent (in)     :: in2
        real (wp),    intent (in)     :: wa1(ido)
        real (wp),    intent (in)     :: wa2(ido)
        real (wp),    intent (in)     :: wa3(ido)
        real (wp),    intent (in)     :: wa4(ido)
        !--------------------------------------------------
        ! Dictionary: local variables
        !--------------------------------------------------
        integer (ip)         :: i, ic, idp2
        real (wp), parameter :: TWO_PI = 2.0_wp * acos(-1.0_wp)
        real (wp), parameter :: ARG= TWO_PI/5
        real (wp), parameter :: TR11=cos(ARG)
        real (wp), parameter :: TI11=sin(ARG)
        real (wp), parameter :: TR12=cos(2.0_wp*ARG)
        real (wp), parameter :: TI12=sin(2.0_wp*ARG)
        !--------------------------------------------------

        ch(1,1,:,1) = cc(1,1,1,:)+ 2.0_wp *cc(1,ido,2,:)+ 2.0_wp *cc(1,ido,4,:)
        ch(1,1,:,2) = (cc(1,1,1,:)+TR11* 2.0_wp *cc(1,ido,2,:) &
            +TR12* 2.0_wp *cc(1,ido,4,:))-(TI11* 2.0_wp *cc(1,1,3,:) &
            +TI12* 2.0_wp *cc(1,1,5,:))
        ch(1,1,:,3) = (cc(1,1,1,:)+TR12* 2.0_wp *cc(1,ido,2,:) &
            +TR11* 2.0_wp *cc(1,ido,4,:))-(TI12* 2.0_wp *cc(1,1,3,:) &
            -TI11* 2.0_wp *cc(1,1,5,:))
        ch(1,1,:,4) = (cc(1,1,1,:)+TR12* 2.0_wp *cc(1,ido,2,:) &
            +TR11* 2.0_wp *cc(1,ido,4,:))+(TI12* 2.0_wp *cc(1,1,3,:) &
            -TI11* 2.0_wp *cc(1,1,5,:))
        ch(1,1,:,5) = (cc(1,1,1,:)+TR11* 2.0_wp *cc(1,ido,2,:) &
            +TR12* 2.0_wp *cc(1,ido,4,:))+(TI11* 2.0_wp *cc(1,1,3,:) &
            +TI12* 2.0_wp *cc(1,1,5,:))

        if (ido /= 1) then
            idp2 = ido+2
            do i=3,ido,2
                ic = idp2-i
                ch(1,i-1,:,1) = cc(1,i-1,1,:)+(cc(1,i-1,3,:)+cc(1,ic-1,2,:)) &
                    +(cc(1,i-1,5,:)+cc(1,ic-1,4,:))
                ch(1,i,:,1) = cc(1,i,1,:)+(cc(1,i,3,:)-cc(1,ic,2,:)) &
                    +(cc(1,i,5,:)-cc(1,ic,4,:))
                ch(1,i-1,:,2) = wa1(i-2)*((cc(1,i-1,1,:)+TR11* &
                    (cc(1,i-1,3,:)+cc(1,ic-1,2,:))+TR12 &
                    *(cc(1,i-1,5,:)+cc(1,ic-1,4,:)))-(TI11*(cc(1,i,3,:) &
                    +cc(1,ic,2,:))+TI12*(cc(1,i,5,:)+cc(1,ic,4,:)))) &
                    -wa1(i-1)*((cc(1,i,1,:)+TR11*(cc(1,i,3,:)-cc(1,ic,2,:)) &
                    +TR12*(cc(1,i,5,:)-cc(1,ic,4,:)))+(TI11*(cc(1,i-1,3,:) &
                    -cc(1,ic-1,2,:))+TI12*(cc(1,i-1,5,:)-cc(1,ic-1,4,:))))

                ch(1,i,:,2) = wa1(i-2)*((cc(1,i,1,:)+TR11*(cc(1,i,3,:) &
                    -cc(1,ic,2,:))+TR12*(cc(1,i,5,:)-cc(1,ic,4,:))) &
                    +(TI11*(cc(1,i-1,3,:)-cc(1,ic-1,2,:))+TI12 &
                    *(cc(1,i-1,5,:)-cc(1,ic-1,4,:))))+wa1(i-1) &
                    *((cc(1,i-1,1,:)+TR11*(cc(1,i-1,3,:) &
                    +cc(1,ic-1,2,:))+TR12*(cc(1,i-1,5,:)+cc(1,ic-1,4,:))) &
                    -(TI11*(cc(1,i,3,:)+cc(1,ic,2,:))+TI12 &
                    *(cc(1,i,5,:)+cc(1,ic,4,:))))

                ch(1,i-1,:,3) = wa2(i-2) &
                    *((cc(1,i-1,1,:)+TR12*(cc(1,i-1,3,:)+cc(1,ic-1,2,:)) &
                    +TR11*(cc(1,i-1,5,:)+cc(1,ic-1,4,:)))-(TI12*(cc(1,i,3,:) &
                    +cc(1,ic,2,:))-TI11*(cc(1,i,5,:)+cc(1,ic,4,:)))) &
                    -wa2(i-1) &
                    *((cc(1,i,1,:)+TR12*(cc(1,i,3,:)- &
                    cc(1,ic,2,:))+TR11*(cc(1,i,5,:)-cc(1,ic,4,:))) &
                    +(TI12*(cc(1,i-1,3,:)-cc(1,ic-1,2,:))-TI11 &
                    *(cc(1,i-1,5,:)-cc(1,ic-1,4,:))))

                ch(1,i,:,3) = wa2(i-2) &
                    *((cc(1,i,1,:)+TR12*(cc(1,i,3,:)- &
                    cc(1,ic,2,:))+TR11*(cc(1,i,5,:)-cc(1,ic,4,:))) &
                    +(TI12*(cc(1,i-1,3,:)-cc(1,ic-1,2,:))-TI11 &
                    *(cc(1,i-1,5,:)-cc(1,ic-1,4,:)))) &
                    +wa2(i-1) &
                    *((cc(1,i-1,1,:)+TR12*(cc(1,i-1,3,:)+cc(1,ic-1,2,:)) &
                    +TR11*(cc(1,i-1,5,:)+cc(1,ic-1,4,:)))-(TI12*(cc(1,i,3,:) &
                    +cc(1,ic,2,:))-TI11*(cc(1,i,5,:)+cc(1,ic,4,:))))

                ch(1,i-1,:,4) = wa3(i-2) &
                    *((cc(1,i-1,1,:)+TR12*(cc(1,i-1,3,:)+cc(1,ic-1,2,:)) &
                    +TR11*(cc(1,i-1,5,:)+cc(1,ic-1,4,:)))+(TI12*(cc(1,i,3,:) &
                    +cc(1,ic,2,:))-TI11*(cc(1,i,5,:)+cc(1,ic,4,:)))) &
                    -wa3(i-1) &
                    *((cc(1,i,1,:)+TR12*(cc(1,i,3,:)- &
                    cc(1,ic,2,:))+TR11*(cc(1,i,5,:)-cc(1,ic,4,:))) &
                    -(TI12*(cc(1,i-1,3,:)-cc(1,ic-1,2,:))-TI11 &
                    *(cc(1,i-1,5,:)-cc(1,ic-1,4,:))))

                ch(1,i,:,4) = wa3(i-2) &
                    *((cc(1,i,1,:)+TR12*(cc(1,i,3,:)- &
                    cc(1,ic,2,:))+TR11*(cc(1,i,5,:)-cc(1,ic,4,:))) &
                    -(TI12*(cc(1,i-1,3,:)-cc(1,ic-1,2,:))-TI11 &
                    *(cc(1,i-1,5,:)-cc(1,ic-1,4,:)))) &
                    +wa3(i-1) &
                    *((cc(1,i-1,1,:)+TR12*(cc(1,i-1,3,:)+cc(1,ic-1,2,:)) &
                    +TR11*(cc(1,i-1,5,:)+cc(1,ic-1,4,:)))+(TI12*(cc(1,i,3,:) &
                    +cc(1,ic,2,:))-TI11*(cc(1,i,5,:)+cc(1,ic,4,:))))

                ch(1,i-1,:,5) = wa4(i-2) &
                    *((cc(1,i-1,1,:)+TR11*(cc(1,i-1,3,:)+cc(1,ic-1,2,:)) &
                    +TR12*(cc(1,i-1,5,:)+cc(1,ic-1,4,:)))+(TI11*(cc(1,i,3,:) &
                    +cc(1,ic,2,:))+TI12*(cc(1,i,5,:)+cc(1,ic,4,:)))) &
                    -wa4(i-1) &
                    *((cc(1,i,1,:)+TR11*(cc(1,i,3,:)-cc(1,ic,2,:)) &
                    +TR12*(cc(1,i,5,:)-cc(1,ic,4,:)))-(TI11*(cc(1,i-1,3,:) &
                    -cc(1,ic-1,2,:))+TI12*(cc(1,i-1,5,:)-cc(1,ic-1,4,:))))

                ch(1,i,:,5) = wa4(i-2) &
                    *((cc(1,i,1,:)+TR11*(cc(1,i,3,:)-cc(1,ic,2,:)) &
                    +TR12*(cc(1,i,5,:)-cc(1,ic,4,:)))-(TI11*(cc(1,i-1,3,:) &
                    -cc(1,ic-1,2,:))+TI12*(cc(1,i-1,5,:)-cc(1,ic-1,4,:)))) &
                    +wa4(i-1) &
                    *((cc(1,i-1,1,:)+TR11*(cc(1,i-1,3,:)+cc(1,ic-1,2,:)) &
                    +TR12*(cc(1,i-1,5,:)+cc(1,ic-1,4,:)))+(TI11*(cc(1,i,3,:) &
                    +cc(1,ic,2,:))+TI12*(cc(1,i,5,:)+cc(1,ic,4,:))))
            end do
        end if

    end subroutine r1f5kb

    subroutine r1f5kf(ido,l1,cc,in1,ch,in2,wa1,wa2,wa3,wa4)
        ! Dictionary: calling arguments
        integer (ip), intent (in)     :: ido
        integer (ip), intent (in)     :: l1
        real (wp),    intent (in out) :: cc(in1,ido,l1,5)
        integer (ip), intent (in)     :: in1
        real (wp),    intent (in out) :: ch(in2,ido,5,l1)
        integer (ip), intent (in)     :: in2
        real (wp),    intent (in)     :: wa1(ido)
        real (wp),    intent (in)     :: wa2(ido)
        real (wp),    intent (in)     :: wa3(ido)
        real (wp),    intent (in)     :: wa4(ido)
        ! Dictionary: local variables
        integer (ip)         :: i, ic, idp2
        real (wp), parameter :: TWO_PI = 2.0_wp * acos(-1.0_wp)
        real (wp), parameter :: ARG= TWO_PI/5
        real (wp), parameter :: TR11=cos(ARG)
        real (wp), parameter :: TI11=sin(ARG)
        real (wp), parameter :: TR12=cos(2.0_wp *ARG)
        real (wp), parameter :: TI12=sin(2.0_wp *ARG)

        ch(1,1,1,:) = cc(1,1,:,1)+(cc(1,1,:,5)+cc(1,1,:,2))+ &
            (cc(1,1,:,4)+cc(1,1,:,3))
        ch(1,ido,2,:) = cc(1,1,:,1)+TR11*(cc(1,1,:,5)+cc(1,1,:,2))+ &
            TR12*(cc(1,1,:,4)+cc(1,1,:,3))
        ch(1,1,3,:) = TI11*(cc(1,1,:,5)-cc(1,1,:,2))+TI12* &
            (cc(1,1,:,4)-cc(1,1,:,3))
        ch(1,ido,4,:) = cc(1,1,:,1)+TR12*(cc(1,1,:,5)+cc(1,1,:,2))+ &
            TR11*(cc(1,1,:,4)+cc(1,1,:,3))
        ch(1,1,5,:) = TI12*(cc(1,1,:,5)-cc(1,1,:,2))-TI11* &
            (cc(1,1,:,4)-cc(1,1,:,3))

        if (ido /= 1) then
            idp2 = ido+2
            do i=3,ido,2
                ic = idp2-i
                ch(1,i-1,1,:) = cc(1,i-1,:,1)+((wa1(i-2)*cc(1,i-1,:,2)+ &
                    wa1(i-1)*cc(1,i,:,2))+(wa4(i-2)*cc(1,i-1,:,5)+wa4(i-1)* &
                    cc(1,i,:,5)))+((wa2(i-2)*cc(1,i-1,:,3)+wa2(i-1)* &
                    cc(1,i,:,3))+(wa3(i-2)*cc(1,i-1,:,4)+ &
                    wa3(i-1)*cc(1,i,:,4)))

                ch(1,i,1,:) = cc(1,i,:,1)+((wa1(i-2)*cc(1,i,:,2)- &
                    wa1(i-1)*cc(1,i-1,:,2))+(wa4(i-2)*cc(1,i,:,5)-wa4(i-1)* &
                    cc(1,i-1,:,5)))+((wa2(i-2)*cc(1,i,:,3)-wa2(i-1)* &
                    cc(1,i-1,:,3))+(wa3(i-2)*cc(1,i,:,4)-wa3(i-1)* &
                    cc(1,i-1,:,4)))

                ch(1,i-1,3,:) = cc(1,i-1,:,1)+TR11* &
                    ( wa1(i-2)*cc(1,i-1,:,2)+wa1(i-1)*cc(1,i,:,2) &
                    +wa4(i-2)*cc(1,i-1,:,5)+wa4(i-1)*cc(1,i,:,5))+TR12* &
                    ( wa2(i-2)*cc(1,i-1,:,3)+wa2(i-1)*cc(1,i,:,3) &
                    +wa3(i-2)*cc(1,i-1,:,4)+wa3(i-1)*cc(1,i,:,4))+TI11* &
                    ( wa1(i-2)*cc(1,i,:,2)-wa1(i-1)*cc(1,i-1,:,2) &
                    -(wa4(i-2)*cc(1,i,:,5)-wa4(i-1)*cc(1,i-1,:,5)))+TI12* &
                    ( wa2(i-2)*cc(1,i,:,3)-wa2(i-1)*cc(1,i-1,:,3) &
                    -(wa3(i-2)*cc(1,i,:,4)-wa3(i-1)*cc(1,i-1,:,4)))

                ch(1,ic-1,2,:) = cc(1,i-1,:,1)+TR11* &
                    ( wa1(i-2)*cc(1,i-1,:,2)+wa1(i-1)*cc(1,i,:,2) &
                    +wa4(i-2)*cc(1,i-1,:,5)+wa4(i-1)*cc(1,i,:,5))+TR12* &
                    ( wa2(i-2)*cc(1,i-1,:,3)+wa2(i-1)*cc(1,i,:,3) &
                    +wa3(i-2)*cc(1,i-1,:,4)+wa3(i-1)*cc(1,i,:,4))-(TI11* &
                    ( wa1(i-2)*cc(1,i,:,2)-wa1(i-1)*cc(1,i-1,:,2) &
                    -(wa4(i-2)*cc(1,i,:,5)-wa4(i-1)*cc(1,i-1,:,5)))+TI12* &
                    ( wa2(i-2)*cc(1,i,:,3)-wa2(i-1)*cc(1,i-1,:,3) &
                    -(wa3(i-2)*cc(1,i,:,4)-wa3(i-1)*cc(1,i-1,:,4))))

                ch(1,i,3,:) = (cc(1,i,:,1)+TR11*((wa1(i-2)*cc(1,i,:,2)- &
                    wa1(i-1)*cc(1,i-1,:,2))+(wa4(i-2)*cc(1,i,:,5)-wa4(i-1)* &
                    cc(1,i-1,:,5)))+TR12*((wa2(i-2)*cc(1,i,:,3)-wa2(i-1)* &
                    cc(1,i-1,:,3))+(wa3(i-2)*cc(1,i,:,4)-wa3(i-1)* &
                    cc(1,i-1,:,4))))+(TI11*((wa4(i-2)*cc(1,i-1,:,5)+ &
                    wa4(i-1)*cc(1,i,:,5))-(wa1(i-2)*cc(1,i-1,:,2)+wa1(i-1)* &
                    cc(1,i,:,2)))+TI12*((wa3(i-2)*cc(1,i-1,:,4)+wa3(i-1)* &
                    cc(1,i,:,4))-(wa2(i-2)*cc(1,i-1,:,3)+wa2(i-1)* &
                    cc(1,i,:,3))))

                ch(1,ic,2,:) = (TI11*((wa4(i-2)*cc(1,i-1,:,5)+wa4(i-1)* &
                    cc(1,i,:,5))-(wa1(i-2)*cc(1,i-1,:,2)+wa1(i-1)* &
                    cc(1,i,:,2)))+TI12*((wa3(i-2)*cc(1,i-1,:,4)+wa3(i-1)* &
                    cc(1,i,:,4))-(wa2(i-2)*cc(1,i-1,:,3)+wa2(i-1)* &
                    cc(1,i,:,3))))-(cc(1,i,:,1)+TR11*((wa1(i-2)*cc(1,i,:,2)- &
                    wa1(i-1)*cc(1,i-1,:,2))+(wa4(i-2)*cc(1,i,:,5)-wa4(i-1)* &
                    cc(1,i-1,:,5)))+TR12*((wa2(i-2)*cc(1,i,:,3)-wa2(i-1)* &
                    cc(1,i-1,:,3))+(wa3(i-2)*cc(1,i,:,4)-wa3(i-1)* &
                    cc(1,i-1,:,4))))

                ch(1,i-1,5,:) = (cc(1,i-1,:,1)+TR12*((wa1(i-2)* &
                    cc(1,i-1,:,2)+wa1(i-1)*cc(1,i,:,2))+(wa4(i-2)* &
                    cc(1,i-1,:,5)+wa4(i-1)*cc(1,i,:,5)))+TR11*((wa2(i-2)* &
                    cc(1,i-1,:,3)+wa2(i-1)*cc(1,i,:,3))+(wa3(i-2)* &
                    cc(1,i-1,:,4)+wa3(i-1)*cc(1,i,:,4))))+(TI12*((wa1(i-2)* &
                    cc(1,i,:,2)-wa1(i-1)*cc(1,i-1,:,2))-(wa4(i-2)* &
                    cc(1,i,:,5)-wa4(i-1)*cc(1,i-1,:,5)))-TI11*((wa2(i-2)* &
                    cc(1,i,:,3)-wa2(i-1)*cc(1,i-1,:,3))-(wa3(i-2)* &
                    cc(1,i,:,4)-wa3(i-1)*cc(1,i-1,:,4))))

                ch(1,ic-1,4,:) = (cc(1,i-1,:,1)+TR12*((wa1(i-2)* &
                    cc(1,i-1,:,2)+wa1(i-1)*cc(1,i,:,2))+(wa4(i-2)* &
                    cc(1,i-1,:,5)+wa4(i-1)*cc(1,i,:,5)))+TR11*((wa2(i-2)* &
                    cc(1,i-1,:,3)+wa2(i-1)*cc(1,i,:,3))+(wa3(i-2)* &
                    cc(1,i-1,:,4)+wa3(i-1)*cc(1,i,:,4))))-(TI12*((wa1(i-2)* &
                    cc(1,i,:,2)-wa1(i-1)*cc(1,i-1,:,2))-(wa4(i-2)* &
                    cc(1,i,:,5)-wa4(i-1)*cc(1,i-1,:,5)))-TI11*((wa2(i-2)* &
                    cc(1,i,:,3)-wa2(i-1)*cc(1,i-1,:,3))-(wa3(i-2)* &
                    cc(1,i,:,4)-wa3(i-1)*cc(1,i-1,:,4))))

                ch(1,i,5,:) = (cc(1,i,:,1)+TR12*((wa1(i-2)*cc(1,i,:,2)- &
                    wa1(i-1)*cc(1,i-1,:,2))+(wa4(i-2)*cc(1,i,:,5)-wa4(i-1)* &
                    cc(1,i-1,:,5)))+TR11*((wa2(i-2)*cc(1,i,:,3)-wa2(i-1)* &
                    cc(1,i-1,:,3))+(wa3(i-2)*cc(1,i,:,4)-wa3(i-1)* &
                    cc(1,i-1,:,4))))+(TI12*((wa4(i-2)*cc(1,i-1,:,5)+ &
                    wa4(i-1)*cc(1,i,:,5))-(wa1(i-2)*cc(1,i-1,:,2)+wa1(i-1)* &
                    cc(1,i,:,2)))-TI11*((wa3(i-2)*cc(1,i-1,:,4)+wa3(i-1)* &
                    cc(1,i,:,4))-(wa2(i-2)*cc(1,i-1,:,3)+wa2(i-1)* &
                    cc(1,i,:,3))))

                ch(1,ic,4,:) = (TI12*((wa4(i-2)*cc(1,i-1,:,5)+wa4(i-1)* &
                    cc(1,i,:,5))-(wa1(i-2)*cc(1,i-1,:,2)+wa1(i-1)* &
                    cc(1,i,:,2)))-TI11*((wa3(i-2)*cc(1,i-1,:,4)+wa3(i-1)* &
                    cc(1,i,:,4))-(wa2(i-2)*cc(1,i-1,:,3)+wa2(i-1)* &
                    cc(1,i,:,3))))-(cc(1,i,:,1)+TR12*((wa1(i-2)*cc(1,i,:,2)- &
                    wa1(i-1)*cc(1,i-1,:,2))+(wa4(i-2)*cc(1,i,:,5)-wa4(i-1)* &
                    cc(1,i-1,:,5)))+TR11*((wa2(i-2)*cc(1,i,:,3)-wa2(i-1)* &
                    cc(1,i-1,:,3))+(wa3(i-2)*cc(1,i,:,4)-wa3(i-1)* &
                    cc(1,i-1,:,4))))
            end do
        end if


    end subroutine r1f5kf

    subroutine r1fgkb(ido,iip,l1,idl1,cc,c1,c2,in1,ch,ch2,in2,wa)
        ! Dictionary: calling arguments
        integer (ip), intent (in)     :: ido
        integer (ip), intent (in)     :: iip
        integer (ip), intent (in)     :: l1
        integer (ip), intent (in)     :: idl1
        real (wp),    intent (in out) :: c1(in1,ido,l1,iip)
        real (wp),    intent (in out) :: c2(in1,idl1,iip)
        real (wp),    intent (in out) :: cc(in1,ido,iip,l1)
        integer (ip), intent (in)     :: in1
        real (wp),    intent (in out) :: ch(in2,ido,l1,iip)
        real (wp),    intent (in out) :: ch2(in2,idl1,iip)
        integer (ip), intent (in)     :: in2
        real (wp),    intent (in) :: wa(ido)
        ! Dictionary: local variables
        real (wp) ai1
        real (wp) ai2
        real (wp) ar1
        real (wp) ar1h
        real (wp) ar2
        real (wp) ar2h
        real (wp) arg
        real (wp) dc2
        real (wp) dcp
        real (wp) ds2
        real (wp) dsp
        integer (ip) i
        integer (ip) ic
        integer (ip) idij
        integer (ip) idp2
        integer (ip) ik
        integer (ip) iipp2
        integer (ip) iipph
        integer (ip) is
        integer (ip) j
        integer (ip) j2
        integer (ip) jc
        integer (ip) k
        integer (ip) l
        integer (ip) lc
        integer (ip) nbd
        real (wp), parameter :: TWO_PI = acos(-1.0_wp)

        arg = TWO_PI /iip
        dcp = cos(arg)
        dsp = sin(arg)
        idp2 = ido+2
        nbd = (ido-1)/2
        iipp2 = iip+2
        iipph = (iip+1)/2

        if (ido >= l1) then
            do k=1,l1
                do i=1,ido
                    ch(1,i,k,1) = cc(1,i,1,k)
                end do
            end do
        else
            do i=1,ido
                do k=1,l1
                    ch(1,i,k,1) = cc(1,i,1,k)
                end do
            end do
        end if

        do j=2,iipph
            jc = iipp2-j
            j2 = j+j
            do k=1,l1
                ch(1,1,k,j) = cc(1,ido,j2-2,k)+cc(1,ido,j2-2,k)
                ch(1,1,k,jc) = cc(1,1,j2-1,k)+cc(1,1,j2-1,k)
            end do
        end do

        if (ido /= 1) then
            if (nbd >= l1) then
                do j=2,iipph
                    jc = iipp2-j
                    do k=1,l1
                        do i=3,ido,2
                            ic = idp2-i
                            ch(1,i-1,k,j) = cc(1,i-1,2*j-1,k)+cc(1,ic-1,2*j-2,k)
                            ch(1,i-1,k,jc) = cc(1,i-1,2*j-1,k)-cc(1,ic-1,2*j-2,k)
                            ch(1,i,k,j) = cc(1,i,2*j-1,k)-cc(1,ic,2*j-2,k)
                            ch(1,i,k,jc) = cc(1,i,2*j-1,k)+cc(1,ic,2*j-2,k)
                        end do
                    end do
                end do
            else
                do j=2,iipph
                    jc = iipp2-j
                    do i=3,ido,2
                        ic = idp2-i
                        do k=1,l1
                            ch(1,i-1,k,j) = cc(1,i-1,2*j-1,k)+cc(1,ic-1,2*j-2,k)
                            ch(1,i-1,k,jc) = cc(1,i-1,2*j-1,k)-cc(1,ic-1,2*j-2,k)
                            ch(1,i,k,j) = cc(1,i,2*j-1,k)-cc(1,ic,2*j-2,k)
                            ch(1,i,k,jc) = cc(1,i,2*j-1,k)+cc(1,ic,2*j-2,k)
                        end do
                    end do
                end do
            end if
        end if

        ar1 = 1.0_wp
        ai1 = 0.0_wp

        do l=2,iipph
            lc = iipp2-l
            ar1h = dcp*ar1-dsp*ai1
            ai1 = dcp*ai1+dsp*ar1
            ar1 = ar1h
            do ik=1,idl1
                c2(1,ik,l) = ch2(1,ik,1)+ar1*ch2(1,ik,2)
                c2(1,ik,lc) = ai1*ch2(1,ik,iip)
            end do
            dc2 = ar1
            ds2 = ai1
            ar2 = ar1
            ai2 = ai1
            do j=3,iipph
                jc = iipp2-j
                ar2h = dc2*ar2-ds2*ai2
                ai2 = dc2*ai2+ds2*ar2
                ar2 = ar2h
                do ik=1,idl1
                    c2(1,ik,l) = c2(1,ik,l)+ar2*ch2(1,ik,j)
                    c2(1,ik,lc) = c2(1,ik,lc)+ai2*ch2(1,ik,jc)
                end do
            end do
        end do

        do j=2,iipph
            do ik=1,idl1
                ch2(1,ik,1) = ch2(1,ik,1)+ch2(1,ik,j)
            end do
        end do

        do j=2,iipph
            jc = iipp2-j
            do k=1,l1
                ch(1,1,k,j) = c1(1,1,k,j)-c1(1,1,k,jc)
                ch(1,1,k,jc) = c1(1,1,k,j)+c1(1,1,k,jc)
            end do
        end do

        if (ido /= 1) then
            if (nbd >= l1) then
                do j=2,iipph
                    jc = iipp2-j
                    do k=1,l1
                        do i=3,ido,2
                            ch(1,i-1,k,j) = c1(1,i-1,k,j)-c1(1,i,k,jc)
                            ch(1,i-1,k,jc) = c1(1,i-1,k,j)+c1(1,i,k,jc)
                            ch(1,i,k,j) = c1(1,i,k,j)+c1(1,i-1,k,jc)
                            ch(1,i,k,jc) = c1(1,i,k,j)-c1(1,i-1,k,jc)
                        end do
                    end do
                end do
            else
                do j=2,iipph
                    jc = iipp2-j
                    do i=3,ido,2
                        do k=1,l1
                            ch(1,i-1,k,j) = c1(1,i-1,k,j)-c1(1,i,k,jc)
                            ch(1,i-1,k,jc) = c1(1,i-1,k,j)+c1(1,i,k,jc)
                            ch(1,i,k,j) = c1(1,i,k,j)+c1(1,i-1,k,jc)
                            ch(1,i,k,jc) = c1(1,i,k,j)-c1(1,i-1,k,jc)
                        end do
                    end do
                end do
            end if
        end if

        if (ido /= 1) then

            do ik=1,idl1
                c2(1,ik,1) = ch2(1,ik,1)
            end do

            do j=2,iip
                do k=1,l1
                    c1(1,1,k,j) = ch(1,1,k,j)
                end do
            end do

            if ( l1 >= nbd ) then
                is = -ido
                do j=2,iip
                    is = is+ido
                    idij = is
                    do i=3,ido,2
                        idij = idij+2
                        do k=1,l1
                            c1(1,i-1,k,j) = wa(idij-1)*ch(1,i-1,k,j)-wa(idij)*ch(1,i,k,j)
                            c1(1,i,k,j) = wa(idij-1)*ch(1,i,k,j)+wa(idij)*ch(1,i-1,k,j)
                        end do
                    end do
                end do
            else
                is = -ido
                do j=2,iip
                    is = is+ido
                    do k=1,l1
                        idij = is
                        do i=3,ido,2
                            idij = idij+2
                            c1(1,i-1,k,j) = &
                                wa(idij-1)*ch(1,i-1,k,j) - wa(idij)*ch(1,i,k,j)
                            c1(1,i,k,j) = &
                                wa(idij-1)*ch(1,i,k,j) + wa(idij)*ch(1,i-1,k,j)
                        end do
                    end do
                end do
            end if
        end if

    end subroutine r1fgkb

    subroutine r1fgkf(ido,iip,l1,idl1,cc,c1,c2,in1,ch,ch2,in2,wa)

        integer (ip) idl1
        integer (ip) ido
        integer (ip) in1
        integer (ip) in2
        integer (ip) iip
        integer (ip) l1
        real (wp) wa(ido)

        real (wp) ai1
        real (wp) ai2
        real (wp) ar1
        real (wp) ar1h
        real (wp) ar2
        real (wp) ar2h
        real (wp) arg
        real (wp) c1(in1,ido,l1,iip)
        real (wp) c2(in1,idl1,iip)
        real (wp) cc(in1,ido,iip,l1)
        real (wp) ch(in2,ido,l1,iip)
        real (wp) ch2(in2,idl1,iip)
        real (wp) dc2
        real (wp) dcp
        real (wp) ds2
        real (wp) dsp
        integer (ip) i
        integer (ip) ic
        integer (ip) idij
        integer (ip) idp2
        integer (ip) ik
        integer (ip) iipp2
        integer (ip) iipph
        integer (ip) is
        integer (ip) j
        integer (ip) j2
        integer (ip) jc
        integer (ip) k
        integer (ip) l
        integer (ip) lc
        integer (ip) nbd
        real (wp), parameter :: TWO_PI = 2.0_wp * acos(-1.0_wp)

        arg = TWO_PI/iip
        dcp = cos(arg)
        dsp = sin(arg)
        iipph = (iip+1)/2
        iipp2 = iip+2
        idp2 = ido+2
        nbd = (ido-1)/2

        if (ido /= 1) then

            do ik=1,idl1
                ch2(1,ik,1) = c2(1,ik,1)
            end do

            do j=2,iip
                do k=1,l1
                    ch(1,1,k,j) = c1(1,1,k,j)
                end do
            end do

            if ( l1 >= nbd ) then
                is = -ido
                do j=2,iip
                    is = is+ido
                    idij = is
                    do i=3,ido,2
                        idij = idij+2
                        do k=1,l1
                            ch(1,i-1,k,j) = wa(idij-1)*c1(1,i-1,k,j)+wa(idij)*c1(1,i,k,j)
                            ch(1,i,k,j) = wa(idij-1)*c1(1,i,k,j)-wa(idij)*c1(1,i-1,k,j)
                        end do
                    end do
                end do
            else
                is = -ido
                do j=2,iip
                    is = is+ido
                    do k=1,l1
                        idij = is
                        do i=3,ido,2
                            idij = idij+2
                            ch(1,i-1,k,j) = wa(idij-1)*c1(1,i-1,k,j)+wa(idij)*c1(1,i,k,j)
                            ch(1,i,k,j) = wa(idij-1)*c1(1,i,k,j)-wa(idij)*c1(1,i-1,k,j)
                        end do
                    end do
                end do
            end if

            if (nbd >= l1) then
                do j=2,iipph
                    jc = iipp2-j
                    do k=1,l1
                        do i=3,ido,2
                            c1(1,i-1,k,j) = ch(1,i-1,k,j)+ch(1,i-1,k,jc)
                            c1(1,i-1,k,jc) = ch(1,i,k,j)-ch(1,i,k,jc)
                            c1(1,i,k,j) = ch(1,i,k,j)+ch(1,i,k,jc)
                            c1(1,i,k,jc) = ch(1,i-1,k,jc)-ch(1,i-1,k,j)
                        end do
                    end do
                end do
            else
                do j=2,iipph
                    jc = iipp2-j
                    do i=3,ido,2
                        do k=1,l1
                            c1(1,i-1,k,j) = ch(1,i-1,k,j)+ch(1,i-1,k,jc)
                            c1(1,i-1,k,jc) = ch(1,i,k,j)-ch(1,i,k,jc)
                            c1(1,i,k,j) = ch(1,i,k,j)+ch(1,i,k,jc)
                            c1(1,i,k,jc) = ch(1,i-1,k,jc)-ch(1,i-1,k,j)
                        end do
                    end do
                end do
            end if
        else
            do ik=1,idl1
                c2(1,ik,1) = ch2(1,ik,1)
            end do
        end if

        do j=2,iipph
            jc = iipp2-j
            do k=1,l1
                c1(1,1,k,j) = ch(1,1,k,j)+ch(1,1,k,jc)
                c1(1,1,k,jc) = ch(1,1,k,jc)-ch(1,1,k,j)
            end do
        end do

        ar1 = 1.0_wp
        ai1 = 0.0_wp
        do l=2,iipph
            lc = iipp2-l
            ar1h = dcp*ar1-dsp*ai1
            ai1 = dcp*ai1+dsp*ar1
            ar1 = ar1h
            do ik=1,idl1
                ch2(1,ik,l) = c2(1,ik,1)+ar1*c2(1,ik,2)
                ch2(1,ik,lc) = ai1*c2(1,ik,iip)
            end do
            dc2 = ar1
            ds2 = ai1
            ar2 = ar1
            ai2 = ai1
            do j=3,iipph
                jc = iipp2-j
                ar2h = dc2*ar2-ds2*ai2
                ai2 = dc2*ai2+ds2*ar2
                ar2 = ar2h
                do ik=1,idl1
                    ch2(1,ik,l) = ch2(1,ik,l)+ar2*c2(1,ik,j)
                    ch2(1,ik,lc) = ch2(1,ik,lc)+ai2*c2(1,ik,jc)
                end do
            end do
        end do

        do j=2,iipph
            do ik=1,idl1
                ch2(1,ik,1) = ch2(1,ik,1)+c2(1,ik,j)
            end do
        end do

        if (ido >= l1) then
            do k=1,l1
                do i=1,ido
                    cc(1,i,1,k) = ch(1,i,k,1)
                end do
            end do
        else
            do i=1,ido
                do k=1,l1
                    cc(1,i,1,k) = ch(1,i,k,1)
                end do
            end do
        end if

        do j=2,iipph
            jc = iipp2-j
            j2 = j+j
            do k=1,l1
                cc(1,ido,j2-2,k) = ch(1,1,k,j)
                cc(1,1,j2-1,k) = ch(1,1,k,jc)
            end do
        end do


        if (ido /= 1) then
            if (nbd >= l1) then
                do j=2,iipph
                    jc = iipp2-j
                    j2 = j+j
                    do k=1,l1
                        do i=3,ido,2
                            ic = idp2-i
                            cc(1,i-1,j2-1,k) = ch(1,i-1,k,j)+ch(1,i-1,k,jc)
                            cc(1,ic-1,j2-2,k) = ch(1,i-1,k,j)-ch(1,i-1,k,jc)
                            cc(1,i,j2-1,k) = ch(1,i,k,j)+ch(1,i,k,jc)
                            cc(1,ic,j2-2,k) = ch(1,i,k,jc)-ch(1,i,k,j)
                        end do
                    end do
                end do
            else
                do j=2,iipph
                    jc = iipp2-j
                    j2 = j+j
                    do i=3,ido,2
                        ic = idp2-i
                        do k=1,l1
                            cc(1,i-1,j2-1,k) = ch(1,i-1,k,j)+ch(1,i-1,k,jc)
                            cc(1,ic-1,j2-2,k) = ch(1,i-1,k,j)-ch(1,i-1,k,jc)
                            cc(1,i,j2-1,k) = ch(1,i,k,j)+ch(1,i,k,jc)
                            cc(1,ic,j2-2,k) = ch(1,i,k,jc)-ch(1,i,k,j)
                        end do
                    end do
                end do
            end if
        end if

    end subroutine r1fgkf


    subroutine copy_r_into_w(ldr, ldw, l, m, r, w)
        !
        ! Purpose:
        !
        ! copies a 2D array, allowing for different leading dimensions.
        !
        integer (ip), intent (in)     :: ldr
        integer (ip), intent (in)     :: ldw
        integer (ip), intent (in)     :: m
        integer (ip), intent (in)     :: l
        real (wp),    intent (in)     :: r(ldr,m)
        real (wp),    intent (in out) :: w(ldw,m)

        w(1:l,:) = r(1:l,:)

    end subroutine copy_r_into_w



    pure subroutine mcfti1(n, wa, fnf, fac)
        !
        ! Purpose:
        !
        ! Sets up factors and tables, 64-bit float precision arithmetic.
        !
        !--------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------
        integer (ip), intent (in)  :: n
        real (wp),    intent (out) :: wa(*)
        real (wp),    intent (out) :: fnf
        real (wp),    intent (out) :: fac(*)
        !--------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------
        integer (ip) :: ido, iip, iw, k1, l1, l2, nf
        !--------------------------------------------------

        !
        !==> Get the factorization of n.
        !
        call factor(n, nf, fac)
        fnf = real(nf, kind=wp)
        iw = 1
        l1 = 1
        !
        !==> Set up the trigonometric tables.
        !
        do k1 = 1, nf
            iip = int(fac(k1), kind=ip)
            l2 = l1 * iip
            ido = n / l2
            call tables(ido, iip, wa(iw) )
            iw = iw + ( iip - 1 ) * (2*ido)
            l1 = l2
        end do

    contains

        pure subroutine factor(n, nf, fac)
            !
            ! Purpose:
            !
            ! Factors of an integer for 64-bit float precision computations.
            !
            !  Parameters:
            !
            !  n, the number for which factorization and other information is needed.
            !
            !  nf, the number of factors.
            !
            !  fac(*), a list of factors of n.
            !
            !--------------------------------------------------
            ! Dictionary: calling arguments
            !--------------------------------------------------
            integer (ip), intent (in)  :: n
            integer (ip), intent (out) :: nf
            real (wp),    intent (out) :: fac(*)
            !--------------------------------------------------
            ! Dictionary: local variables
            !--------------------------------------------------
            integer (ip) :: j, nl, nq, nr, ntry
            !--------------------------------------------------

            nl = n
            nf = 0
            j = 0

            do while (1 < nl)
                j = j + 1
                select case (j)
                    case (1)
                        ntry = 4
                    case (2)
                        ntry = 2
                    case (3)
                        ntry = 3
                    case (4)
                        ntry = 5
                    case default
                        ntry = ntry + 2
                end select

                inner_loop: do
                    nq = nl / ntry
                    nr = nl - ntry * nq

                    if ( nr /= 0 ) then
                        exit inner_loop
                    end if

                    nf = nf + 1
                    fac(nf) = real(ntry, kind=wp)
                    nl = nq

                end do inner_loop
            end do

        end subroutine factor

        pure subroutine tables(ido, iip, wa)
            !
            ! Purpose:
            !
            ! Computes trigonometric tables, 64-bit float precision arithmetic.
            !
            !--------------------------------------------------
            ! Dictionary: calling arguments
            !--------------------------------------------------
            integer (ip), intent (in)  :: ido
            integer (ip), intent (in)  :: iip
            real (wp),    intent (out) :: wa(ido,iip-1,2)
            !--------------------------------------------------
            ! Dictionary: local variables
            !--------------------------------------------------
            integer (ip)         :: i, j !! Counters
            real (wp), parameter :: TWO_PI = 2.0_wp * acos(-1.0_wp)
            real (wp)            :: argz, arg1, arg2, arg3, arg4
            !--------------------------------------------------

            argz = TWO_PI/iip
            arg1 = TWO_PI/( ido * iip)

            do j = 2, iip
                arg2 = real(j - 1, kind=wp) * arg1
                do i = 1, ido
                    arg3 = real(i - 1, kind=wp) * arg2
                    wa(i,j-1,1) = cos(arg3)
                    wa(i,j-1,2) = sin(arg3)
                end do
                if (5 < iip) then
                    arg4 = real(j - 1, kind=wp) * argz
                    wa(1,j-1,1) = cos(arg4)
                    wa(1,j-1,2) = sin(arg4)
                end if
            end do

        end subroutine tables

    end subroutine mcfti1


    subroutine rfft1b(n, inc, r, lenr, wsave, lensav, work, lenwrk, ier)
        !
        ! Purpose:
        !
        !  Computes the one-dimensional Fourier transform of a periodic
        !  sequence within a real array. This is referred to as the backward
        !  transform or Fourier synthesis, transforming the sequence from
        !  spectral to physical space.  This transform is normalized since a
        !  call to rfft1b followed by a call to rfft1f (or vice-versa) reproduces
        !  the original array within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer N, the length of the sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations,
        !  in array R, of two consecutive elements within the sequence.
        !
        !  Input/output, real (wp) R(LENR), on input, the data to be
        !  transformed, and on output, the transformed data.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least INC*(N-1) + 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to RFFT1I before the first call to routine
        !  RFFT1F or RFFT1B for a given transform length N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least N.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough.
        !

        integer (ip) lenr
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) inc
        integer (ip) n
        real (wp) r(lenr)
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)


        !
        !==> Check validity of calling arguments
        !
        if (lenr < inc*(n-1) + 1) then
            ier = 1
            call xerfft('rfft1b ', 6)
        else if (lensav < &
            n + int(log(real(n, kind=wp) )/log(2.0_wp))+4) then
            ier = 2
            call xerfft('rfft1b ', 8)
        else if (lenwrk < n) then
            ier = 3
            call xerfft('rfft1b ', 10)
        else
            ier = 0
        end if

        !
        !==> Perform transform
        !
        if (n /= 1) then
            call rfftb1(n,inc,r,work,wsave,wsave(n+1))
        end if

    end subroutine rfft1b

    subroutine rfft1f(n, inc, r, lenr, wsave, lensav, work, lenwrk, ier)


        !
        !! RFFT1F: 64-bit float precision forward fast Fourier transform, 1D.
        !
        !  Purpose:
        !
        !  RFFT1F computes the one-dimensional Fourier transform of a periodic
        !  sequence within a real array.  This is referred to as the forward
        !  transform or Fourier analysis, transforming the sequence from physical
        !  to spectral space.  This transform is normalized since a call to
        !  RFFT1F followed by a call to RFFT1B (or vice-versa) reproduces the
        !  original array within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer N, the length of the sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations, in
        !  array R, of two consecutive elements within the sequence.
        !
        !  Input/output, real (wp) R(LENR), on input, contains the sequence
        !  to be transformed, and on output, the transformed data.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least INC*(N-1) + 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to RFFT1I before the first call to routine RFFT1F
        !  or RFFT1B for a given transform length N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least N.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough:
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough.
        !


        integer (ip) lenr
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) inc
        integer (ip) n
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) r(lenr)

        ier = 0

        if (lenr < inc*(n-1) + 1) then
            ier = 1
            call xerfft('rfft1f ', 6)
        else if (lensav < n + int(log( real(n, kind=wp) )/log(2.0_wp)) +4) then
            ier = 2
            call xerfft('rfft1f ', 8)
        else if (lenwrk < n) then
            ier = 3
            call xerfft('rfft1f ', 10)
        end if

        if (n /= 1) then
            call rfftf1 (n,inc,r,work,wsave,wsave(n+1))
        end if

    end subroutine rfft1f


    subroutine rfft1i(n, wsave, lensav, ier)
        !
        !! RFFT1I: initialization for RFFT1B and RFFT1F.
        !
        !  Purpose:
        !
        !  RFFT1I initializes array WSAVE for use in its companion routines
        !  RFFT1B and RFFT1F.  The prime factorization of N together with a
        !  tabulation of the trigonometric functions are computed and stored
        !  in array WSAVE.  Separate WSAVE arrays are required for different
        !  values of N.
        !
        !  Parameters:
        !
        !  input, integer N, the length of the sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  Output, real (wp) WSAVE(LENSAV), containing the prime factors of
        !  N and also containing certain trigonometric values which will be used in
        !  routines RFFT1B or RFFT1F.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least N + INT(LOG(REAL(N))) + 4.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough.
        !


        integer (ip) lensav

        integer (ip) ier
        integer (ip) n
        real (wp) wsave(lensav)

        ier = 0

        if (lensav < n + int(log( real(n, kind=wp) )/log(2.0_wp)) +4) then
            ier = 2
            call xerfft('rfft1i ', 3)
        end if

        if (n /= 1) then
            call rffti1(n,wsave(1),wsave(n+1))
        end if

    end subroutine rfft1i


    subroutine rfft2b ( ldim, l, m, r, wsave, lensav, work, lenwrk, ier)
        !
        ! rfft2b: 64-bit float precision backward fast Fourier transform, 2D.
        !
        ! Purpose:
        !
        !  Computes the two-dimensional discrete Fourier transform of the
        !  complex Fourier coefficients a real periodic array.  This transform is
        !  known as the backward transform or Fourier synthesis, transforming from
        !  spectral to physical space.  Routine RFFT2B is normalized: a call to
        !  RFFT2B followed by a call to RFFT2F (or vice-versa) reproduces the
        !  original array within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer LDIM, the first dimension of the 2D real
        !  array R, which must be at least 2*(L/2+1).
        !
        !  input, integer L, the number of elements to be transformed
        !  in the first dimension of the two-dimensional real array R.  The value of
        !  L must be less than or equal to that of LDIM.  The transform is most
        !  efficient when L is a product of small primes.
        !
        !  input, integer M, the number of elements to be transformed
        !  in the second dimension of the two-dimensional real array R.  The transform
        !  is most efficient when M is a product of small primes.
        !
        !  Input/output, real (wp) R(LDIM,M), the real array of two
        !  dimensions.  On input, R contains the L/2+1-by-M complex subarray of
        !  spectral coefficients, on output, the physical coefficients.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to RFFT2I before the first call to routine RFFT2F
        !  or RFFT2B with lengths L and M.  WSAVE's contents may be re-used for
        !  subsequent calls to RFFT2F and RFFT2B with the same transform lengths
        !  L and M.
        !
        !  input, integer LENSAV, the number of elements in the WSAVE
        !  array.  LENSAV must be at least L + M + INT(LOG(REAL(L)))
        !  + INT(LOG(REAL(M))) + 8.
        !
        !  Workspace, real (wp) WORK(LENWRK).  WORK provides workspace, and
        !  its contents need not be saved between calls to routines RFFT2B and RFFT2F.
        !
        !  input, integer  LENWRK, the number of elements in the WORK
        !  array.  LENWRK must be at least LDIM*M.
        !
        !  Output, integer (ip) IER, the error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  6, input parameter LDIM < 2*(L/2+1);
        !  20, input error returned by lower level routine.
        !
        integer (ip) ldim
        integer (ip) lensav
        integer (ip) lenwrk
        integer (ip) m

        integer (ip) i
        integer (ip) ier
        integer (ip) ier1
        integer (ip) j
        integer (ip) l
        integer (ip) ldh
        integer (ip) ldw
        integer (ip) ldx
        integer (ip) lwsav
        integer (ip) mmsav
        integer (ip) modl
        integer (ip) modm
        integer (ip) mwsav
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) r(ldim,m)

        ier = 0
        !
        !==> verify lensav
        !
        lwsav = l+int(log(real(l, kind=wp))/log(2.0_wp))+4
        mwsav = 2*m+int(log(real(m, kind=wp))/log(2.0_wp))+4
        mmsav = m+int(log(real(m, kind=wp))/log(2.0_wp))+4
        modl = mod(l,2)
        modm = mod(m,2)

        if (lensav < lwsav+mwsav+mmsav) then
            ier = 2
            call xerfft('rfft2f', 6)
            return
        end if
        !
        ! verify lenwrk
        !
        if (lenwrk < (l+1)*m) then
            ier = 3
            call xerfft('rfft2f', 8)
            return
        end if
        !
        ! verify ldim is as big as l
        !
        if (ldim < l) then
            ier = 5
            call xerfft('rfft2f', -6)
            return
        end if
        !
        !==> Transform second dimension of array
        !
        do j=2,2*((m+1)/2)-1
            r(1,j) = r(1,j)+r(1,j)
        end do

        do j=3,m,2
            r(1,j) = -r(1,j)
        end do

        call rfftmb(1,1,m,ldim,r,m*ldim, wsave(lwsav+mwsav+1),mmsav,work,lenwrk,ier1)

        ldh = int((l+1)/2)

        if( 1 < ldh ) then
            ldw = ldh+ldh
            !
            !  r and work are switched because the the first dimension
            !  of the input to complex cfftmf must be even.
            !
            call copy_r_into_w(ldim,ldw,l,m,r,work)

            call cfftmb(ldh-1,1,m,ldh,work(2),ldh*m, &
                wsave(lwsav+1),mwsav,r,l*m, ier1)

            if(ier1/=0) then
                ier=20
                call xerfft('rfft2b',-5)
                return
            end if

            call copy_w_into_r(ldim,ldw,l,m,r,work)
        end if

        if(modl == 0) then

            do j=2,2*((m+1)/2)-1
                r(l,j) = r(l,j)+r(l,j)
            end do

            do j=3,m,2
                r(l,j) = -r(l,j)
            end do

            call rfftmb(1,1,m,ldim,r(l,1),m*ldim, &
                wsave(lwsav+mwsav+1),mmsav,work,lenwrk,ier1)
        end if
        !
        !==> Transform first dimension of array
        !
        ldx = 2*int((l+1)/2)-1

        do i=2,ldx
            do j=1,m
                r(i,j) = r(i,j)+r(i,j)
            end do
        end do
        do j=1,m
            do i=3,ldx,2
                r(i,j) = -r(i,j)
            end do
        end do

        associate( &
            arg_1 => m*ldim, &
            arg_2 => l+int(log( real ( l, kind=wp) )/log(2.0_wp))+4 &
            )

            call rfftmb(m,ldim,l,1,r,arg_1,wsave(1), arg_2,work,lenwrk,ier1)

        end associate

        if (ier1 /= 0) then
            ier=20
            call xerfft('rfft2f',-5)
        end if

    end subroutine rfft2b


    subroutine rfft2f(ldim, l, m, r, wsave, lensav, work, lenwrk, ier)
        !
        ! rfft2f: 64-bit float precision forward fast Fourier transform, 2D.
        !
        ! Purpose:
        !
        !  RFFT2F computes the two-dimensional discrete Fourier transform of a
        !  real periodic array.  This transform is known as the forward transform
        !  or Fourier analysis, transforming from physical to spectral space.
        !  Routine rfft2f is normalized: a call to rfft2f followed by a call to
        !  rfft2b (or vice-versa) reproduces the original array within roundoff
        !  error.
        !
        !  Parameters:
        !
        !  input, integer LDIM, the first dimension of the 2D real
        !  array R, which must be at least 2*(L/2+1).
        !
        !  input, integer L, the number of elements to be transformed
        !  in the first dimension of the two-dimensional real array R.  The value
        !  of L must be less than or equal to that of LDIM.  The transform is most
        !  efficient when L is a product of small primes.
        !
        !  input, integer M, the number of elements to be transformed
        !  in the second dimension of the two-dimensional real array R.  The
        !  transform is most efficient when M is a product of small primes.
        !
        !  Input/output, real (wp) R(LDIM,M), the real array of two
        !  dimensions.  On input, containing the L-by-M physical data to be
        !  transformed.  On output, the spectral coefficients.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to RFFT2I before the first call to routine RFFT2F
        !  or RFFT2B with lengths L and M.  WSAVE's contents may be re-used for
        !  subsequent calls to RFFT2F and RFFT2B with the same transform lengths.
        !
        !  input, integer LENSAV, the number of elements in the WSAVE
        !  array.  LENSAV must be at least L + M + INT(LOG(REAL(L)))
        !  + INT(LOG(REAL(M))) + 8.
        !
        !  Workspace, real (wp) WORK(LENWRK), provides workspace, and its
        !  contents need not be saved between calls to routines RFFT2F and RFFT2B.
        !
        !  input, integer LENWRK, the number of elements in the WORK
        !  array.  LENWRK must be at least LDIM*M.
        !
        !  Output, integer (ip) IER, the error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  6, input parameter LDIM < 2*(L+1);
        !  20, input error returned by lower level routine.
        !


        integer (ip) ldim
        integer (ip) lensav
        integer (ip) lenwrk
        integer (ip) m

        integer (ip) i
        integer (ip) ier
        integer (ip) ier1
        integer (ip) j
        integer (ip) l
        integer (ip) ldh
        integer (ip) ldw
        integer (ip) ldx
        integer (ip) lwsav
        integer (ip) mmsav
        integer (ip) modl
        integer (ip) modm
        integer (ip) mwsav
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) r(ldim,m)

        ier = 0
        !
        !==> verify lensav
        !
        lwsav = l+int(log(real (l, kind=wp))/log(2.0_wp))+4
        mwsav = 2*m+int(log(real(m, kind=wp))/log(2.0_wp))+4
        mmsav = m+int(log(real(m, kind=wp))/log(2.0_wp))+4

        if (lensav < lwsav+mwsav+mmsav) then
            ier = 2
            call xerfft('rfft2f', 6)
            return
        end if
        !
        !==>  verify lenwrk
        !
        if (lenwrk < (l+1)*m) then
            ier = 3
            call xerfft('rfft2f', 8)
            return
        end if
        !
        !==>  verify ldim is as big as l
        !
        if (ldim < l) then
            ier = 5
            call xerfft('rfft2f', -6)
            return
        end if
        !
        !==>  Transform first dimension of array
        !
        associate( &
            arg_1 => m*ldim, &
            arg_2 =>  l+int(log( real ( l, kind=wp) )/log(2.0_wp))+4 &
            )

            call rfftmf(m,ldim,l,1,r,arg_1,wsave(1), arg_2,work,lenwrk,ier1)

        end associate

        if(ier1 /= 0 ) then
            ier=20
            call xerfft('rfft2f',-5)
            return
        end if

        ldx = 2*int((l+1)/2)-1

        do i=2,ldx
            do j=1,m
                r(i,j) = 0.5_wp * r(i,j)
            end do
        end do

        do j=1,m
            do i=3,ldx,2
                r(i,j) = -r(i,j)
            end do
        end do
        !
        !==>  Reshuffle to add in nyquist imaginary components
        !
        modl = mod(l,2)
        modm = mod(m,2)
        !
        !==>  Transform second dimension of array
        !
        call rfftmf(1,1,m,ldim,r,m*ldim, &
            wsave(lwsav+mwsav+1),mmsav,work,lenwrk,ier1)

        do j=2,2*((m+1)/2)-1
            r(1,j) = 0.5_wp * r(1,j)
        end do

        do j=3,m,2
            r(1,j) = -r(1,j)
        end do

        ldh = int((l+1)/2)

        if ( 1 < ldh ) then
            ldw = 2*ldh
            !
            !==> r and work are switched because the the first dimension
            !    of the input to complex cfftmf must be even.
            !
            call copy_r_into_w(ldim,ldw,l,m,r,work)
            call cfftmf(ldh-1,1,m,ldh,work(2),ldh*m, &
                wsave(lwsav+1),mwsav,r,l*m, ier1)

            if(ier1 /= 0 ) then
                ier=20
                call xerfft('rfft2f',-5)
                return
            end if

            call copy_w_into_r(ldim,ldw,l,m,r,work)
        end if

        if(modl == 0) then

            call rfftmf(1,1,m,ldim,r(l,1),m*ldim, &
                wsave(lwsav+mwsav+1),mmsav,work,lenwrk,ier1)

            do j=2,2*((m+1)/2)-1
                r(l,j) = 0.5_wp * r(l,j)
            end do

            do j=3,m,2
                r(l,j) = -r(l,j)
            end do

        end if

        if(ier1 /= 0 ) then
            ier=20
            call xerfft('rfft2f',-5)
        end if

    end subroutine rfft2f

    subroutine rfft2i(l, m, wsave, lensav, ier)
        ! RFFT2I: initialization for RFFT2B and RFFT2F.
        !
        !  Purpose:
        !  RFFT2I initializes real array WSAVE for use in its companion routines
        !  RFFT2F and RFFT2B for computing the two-dimensional fast Fourier
        !  transform of real data.  Prime factorizations of L and M, together with
        !  tabulations of the trigonometric functions, are computed and stored in
        !  array WSAVE.  RFFT2I must be called prior to the first call to RFFT2F
        !  or RFFT2B.  Separate WSAVE arrays are required for different values of
        !  L or M.
        !
        !
        !  input, integer L, the number of elements to be transformed
        !  in the first dimension.  The transform is most efficient when L is a
        !  product of small primes.
        !
        !  input, integer M, the number of elements to be transformed
        !  in the second dimension.  The transform is most efficient when M is a
        !  product of small primes.
        !
        !  input, integer LENSAV, the number of elements in the WSAVE
        !  array.  LENSAV must be at least L + M + INT(LOG(REAL(L)))
        !  + INT(LOG(REAL(M))) + 8.
        !
        !  Output, real (wp) WSAVE(LENSAV), containing the prime factors
        !  of L and M, and also containing certain trigonometric values which
        !  will be used in routines RFFT2B or RFFT2F.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough;
        !  20, input error returned by lower level routine.
        !


        integer (ip) lensav

        integer (ip) ier
        integer (ip) ier1
        integer (ip) l
        integer (ip) lwsav
        integer (ip) m
        integer (ip) mmsav
        integer (ip) mwsav
        real (wp) wsave(lensav)
        !
        ! initialize ier
        !
        ier = 0
        !
        ! verify lensav
        !
        lwsav = l+int(log( real ( l, kind=wp) )/log(2.0_wp))+4
        mwsav = 2*m+int(log( real ( m, kind=wp) )/log(2.0_wp))+4
        mmsav = m+int(log( real ( m, kind=wp) )/log(2.0_wp))+4

        if (lensav < lwsav+mwsav+mmsav) then
            ier = 2
            call xerfft('rfft2i', 4)
            return
        end if

        call rfftmi (l, wsave(1), lwsav, ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('rfft2i',-5)
            return
        end if

        call cfftmi (m, wsave(lwsav+1),mwsav,ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('rfft2i',-5)
            return
        end if

        call rfftmi (m,wsave(lwsav+mwsav+1),mmsav, ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('rfft2i',-5)
            return
        end if

        return
    end subroutine rfft2i

    subroutine rfftb1(n, in, c, ch, wa, fac)

        integer (ip) in
        integer (ip) n

        real (wp) c(in,*)
        real (wp) ch(*)
        real (wp) fac(15)
        integer (ip) idl1
        integer (ip) ido
        integer (ip) iip
        integer (ip) iw
        integer (ip) ix2
        integer (ip) ix3
        integer (ip) ix4
        integer (ip) j
        integer (ip) k1
        integer (ip) l1
        integer (ip) l2
        integer (ip) modn
        integer (ip) na
        integer (ip) nf
        integer (ip) nl
        real (wp) wa(n)

        nf = int(fac(2), kind=ip)
        na = 0
        do k1=1,nf
            iip = int(fac(k1+2), kind=ip)
            na = 1-na
            if(iip <= 5) then
                cycle
            end if
            if(k1 == nf) then
                cycle
            end if
            na = 1-na
        end do

        modn = mod(n,2)

        if(modn /= 0) then
            nl = n-1
        else
            nl = n-2
        end if

        if (na /= 0) then

            ch(1) = c(1,1)
            ch(n) = c(1,n)
            do j=2,nl,2
                ch(j) = 0.5_wp*c(1,j)
                ch(j+1) = -0.5_wp*c(1,j+1)
            end do
        else
            do j=2,nl,2
                c(1,j) = 0.5_wp*c(1,j)
                c(1,j+1) = -0.5_wp*c(1,j+1)
            end do
        end if

        l1 = 1
        iw = 1
        do k1=1,nf
            iip = int(fac(k1+2), kind=ip)
            l2 = iip*l1
            ido = n/l2
            idl1 = ido*l1
            select case (iip)
                case (2)
                    if (na == 0) then
                        call r1f2kb(ido,l1,c,in,ch,1,wa(iw))
                    else
                        call r1f2kb(ido,l1,ch,1,c,in,wa(iw))
                    end if
                    na = 1-na
                case (3)
                    ix2 = iw+ido
                    if (na == 0) then
                        call r1f3kb(ido,l1,c,in,ch,1,wa(iw),wa(ix2))
                    else
                        call r1f3kb(ido,l1,ch,1,c,in,wa(iw),wa(ix2))
                    end if
                    na = 1-na
                case (4)
                    ix2 = iw+ido
                    ix3 = ix2+ido
                    if (na == 0) then
                        call r1f4kb(ido,l1,c,in,ch,1,wa(iw),wa(ix2),wa(ix3))
                    else
                        call r1f4kb(ido,l1,ch,1,c,in,wa(iw),wa(ix2),wa(ix3))
                    end if
                    na = 1-na
                case (5)
                    ix2 = iw+ido
                    ix3 = ix2+ido
                    ix4 = ix3+ido
                    if (na == 0) then
                        call r1f5kb(ido,l1,c,in,ch,1,wa(iw),wa(ix2),wa(ix3),wa(ix4))
                    else
                        call r1f5kb(ido,l1,ch,1,c,in,wa(iw),wa(ix2),wa(ix3),wa(ix4))
                    end if
                    na = 1-na
                case default
                    if (na == 0) then
                        call r1fgkb(ido,iip,l1,idl1,c,c,c,in,ch,ch,1,wa(iw))
                    else
                        call r1fgkb(ido,iip,l1,idl1,ch,ch,ch,1,c,c,in,wa(iw))
                    end if
                    if (ido == 1) then
                        na = 1-na
                    end if
            end select
            l1 = l2
            iw = iw+(iip-1)*ido
        end do

    end subroutine rfftb1

    subroutine rfftf1(n, in, c, ch, wa, fac)

        integer (ip) in
        integer (ip) n

        real (wp) c(in,*)
        real (wp) ch(*)
        real (wp) fac(15)
        integer (ip) idl1
        integer (ip) ido
        integer (ip) iip
        integer (ip) iw
        integer (ip) ix2
        integer (ip) ix3
        integer (ip) ix4
        integer (ip) j
        integer (ip) k1
        integer (ip) kh
        integer (ip) l1
        integer (ip) l2
        integer (ip) modn
        integer (ip) na
        integer (ip) nf
        integer (ip) nl
        real (wp) sn
        real (wp) tsn
        real (wp) tsnm
        real (wp) wa(n)

        nf = int(fac(2), kind=ip)
        na = 1
        l2 = n
        iw = n

        do k1=1,nf
            kh = nf-k1
            iip = int(fac(kh+3), kind=ip)
            l1 = l2/iip
            ido = n/l2
            idl1 = ido*l1
            iw = iw-(iip-1)*ido
            na = 1-na
            select case (iip)
                case (2)
                    if (na == 0) then
                        call r1f2kf(ido,l1,c,in,ch,1,wa(iw))
                    else
                        call r1f2kf(ido,l1,ch,1,c,in,wa(iw))
                    end if
                case (3)
                    ix2 = iw+ido
                    if (na == 0) then
                        call r1f3kf(ido,l1,c,in,ch,1,wa(iw),wa(ix2))
                    else
                        call r1f3kf(ido,l1,ch,1,c,in,wa(iw),wa(ix2))
                    end if
                case (4)
                    ix2 = iw+ido
                    ix3 = ix2+ido
                    if (na == 0) then
                        call r1f4kf(ido,l1,c,in,ch,1,wa(iw),wa(ix2),wa(ix3))
                    else
                        call r1f4kf(ido,l1,ch,1,c,in,wa(iw),wa(ix2),wa(ix3))
                    end if
                case (5)
                    ix2 = iw+ido
                    ix3 = ix2+ido
                    ix4 = ix3+ido
                    if (na == 0) then
                        call r1f5kf(ido,l1,c,in,ch,1,wa(iw),wa(ix2),wa(ix3),wa(ix4))
                    else
                        call r1f5kf(ido,l1,ch,1,c,in,wa(iw),wa(ix2),wa(ix3),wa(ix4))
                    end if
                case default
                    if (ido == 1) then
                        na = 1-na
                    end if
                    if (na == 0) then
                        call r1fgkf(ido,iip,l1,idl1,c,c,c,in,ch,ch,1,wa(iw))
                        na = 1
                    else
                        call r1fgkf(ido,iip,l1,idl1,ch,ch,ch,1,c,c,in,wa(iw))
                        na = 0
                    end if
            end select
            l2 = l1
        end do

        sn = 1.0_wp/n
        tsn =  2.0_wp/n
        tsnm = -tsn
        modn = mod(n,2)

        if(modn /= 0) then
            nl = n-1
        else
            nl = n-2
        end if

        if (na == 0) then
            c(1,1) = sn*ch(1)
            do j=2,nl,2
                c(1,j) = tsn*ch(j)
                c(1,j+1) = tsnm*ch(j+1)
            end do
            if(modn == 0) then
                c(1,n) = sn*ch(n)
            end if
        else
            c(1,1) = sn*c(1,1)
            do j=2,nl,2
                c(1,j) = tsn*c(1,j)
                c(1,j+1) = tsnm*c(1,j+1)
            end do
            if(modn == 0) then
                c(1,n) = sn*c(1,n)
            end if
        end if

    end subroutine rfftf1


    subroutine rffti1(n, wa, fac)
        !
        !  Parameters:
        !
        !  input
        !
        ! n, the number for which factorization
        !  and other information is needed.
        !
        !  output
        ! wa(n), trigonometric information.
        !
        !  output
        !
        !  fac(15), factorization information.
        !  fac(1) is n, fac(2) is nf, the number of factors, and fac(3:nf+2) are the
        !  factors.
        !
        !--------------------------------------------------------------
        ! Dictionary: calling arguments
        !--------------------------------------------------------------
        integer (ip), intent (in)  :: n
        real (wp),    intent (out) :: fac(15)
        real (wp),    intent (out) :: wa(n)
        !--------------------------------------------------------------
        ! Dictionary: local variables
        !--------------------------------------------------------------
        integer (ip)            :: i, ib, ido, ii, iip, ipm, is
        integer (ip)            :: j, k1, l1, l2, ld
        integer (ip)            :: nf, nfm1, nl, nq, nr, ntry
        integer (ip), parameter :: ntryh(*)=[ 4, 2, 3, 5]
        real (wp),    parameter :: TWO_PI = 2.0_wp * acos(-1.0_wp)
        real (wp)               :: arg,  argh, argld, fi
        !--------------------------------------------------------------


        ntry = 0
        nl = n
        nf = 0
        j = 0

        factorize_loop: do
            ! Increment j
            j = j+1

            ! Choose ntry
            if (j <= 4) then
                ntry = ntryh(j)
            else
                ntry = ntry+2
            end if

            inner_loop: do
                nq = nl/ntry
                nr = nl-ntry*nq
                if (nr < 0) then
                    cycle factorize_loop
                else if (nr == 0) then
                    nf = nf+1
                    fac(nf+2) = ntry
                    nl = nq

                    if (ntry == 2 .and. nf /= 1) then

                        do i=2,nf
                            ib = nf-i+2
                            fac(ib+2) = fac(ib+1)
                        end do

                        fac(3) = 2

                    end if

                    if (nl /= 1) cycle inner_loop

                else
                    cycle factorize_loop
                end if
                exit inner_loop
            end do inner_loop
            exit factorize_loop
        end do factorize_loop

        fac(1) = n
        fac(2) = nf
        argh = TWO_PI/n
        is = 0
        nfm1 = nf-1
        l1 = 1

        if (nfm1 /= 0) then
            do k1=1,nfm1
                iip = int(fac(k1+2), kind=ip)
                ld = 0
                l2 = l1*iip
                ido = n/l2
                ipm = iip-1
                do j=1,ipm
                    ld = ld+l1
                    i = is
                    argld = real(ld, kind=wp) * argh
                    fi = 0.0_wp
                    do ii=3,ido,2
                        i = i+2
                        fi = fi + 1.0_wp
                        arg = fi*argld
                        wa(i-1) = cos(arg)
                        wa(i) = sin(arg)
                    end do
                    is = is+ido
                end do
                l1 = l2
            end do
        end if

    end subroutine rffti1



    subroutine rfftmb(lot, jump, n, inc, r, lenr, wsave, &
        lensav, work, lenwrk, ier)
        !
        ! rfftmb: 64-bit float precision backward fft, 1d, multiple vectors.
        !
        ! Purpose:
        !
        !  Computes the one-dimensional Fourier transform of multiple
        !  periodic sequences within a real array.  This transform is referred
        !  to as the backward transform or Fourier synthesis, transforming the
        !  sequences from spectral to physical space.
        !
        !  This transform is normalized since a call to RFFTMB followed
        !  by a call to RFFTMF (or vice-versa) reproduces the original
        !  array  within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer LOT, the number of sequences to be transformed
        !  within array R.
        !
        !  input, integer JUMP, the increment between the locations, in
        !  array R, of the first elements of two consecutive sequences to be
        !  transformed.
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations, in
        !  array R, of two consecutive elements within the same sequence.
        !
        !  Input/output, real (wp) R(LENR), real array containing LOT
        !  sequences, each having length N.  R can have any number of dimensions,
        !  but the total number of locations must be at least LENR.  On input, the
        !  spectral data to be transformed, on output the physical data.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least (LOT-1)*JUMP + INC*(N-1) + 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to RFFTMI before the first call to routine RFFTMF
        !  or RFFTMB for a given transform length N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must  be at least N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least LOT*N.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  4, input parameters INC, JUMP, N, LOT are not consistent.
        !
        integer (ip) lenr
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) inc
        integer (ip) jump
        integer (ip) lot
        integer (ip) n
        real (wp) r(lenr)
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)

        !
        !==> Validity of calling arguments
        !
        if (lenr < (lot-1)*jump + inc*(n-1) + 1) then
            ier = 1
            call xerfft('rfftmb ', 6)
            return
        else if (lensav < n+int(log(real(n, kind=wp))/log(2.0_wp))+4) then
            ier = 2
            call xerfft('rfftmb ', 8)
            return
        else if (lenwrk < lot*n) then
            ier = 3
            call xerfft('rfftmb ', 10)
            return
        else if (.not. xercon(inc,jump,n,lot)) then
            ier = 4
            call xerfft('rfftmb ', -1)
            return
        else
            ier = 0
        end if

        !
        !==> Perform transform
        !
        if (n /= 1) then
            call mrftb1(lot,jump,n,inc,r,work,wsave,wsave(n+1))
        end if

    end subroutine rfftmb


    subroutine rfftmf(lot, jump, n, inc, r, lenr, wsave, lensav, &
        work, lenwrk, ier)
        !
        ! RFFTMF: 64-bit float precision forward FFT, 1D, multiple vectors.
        !
        !  Purpose:
        !
        !  RFFTMF computes the one-dimensional Fourier transform of multiple
        !  periodic sequences within a real array.  This transform is referred
        !  to as the forward transform or Fourier analysis, transforming the
        !  sequences from physical to spectral space.
        !
        !  This transform is normalized since a call to RFFTMF followed
        !  by a call to RFFTMB (or vice-versa) reproduces the original array
        !  within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer LOT, the number of sequences to be transformed
        !  within array R.
        !
        !  input, integer JUMP, the increment between the locations, in
        !  array R, of the first elements of two consecutive sequences to be
        !  transformed.
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations,
        !  in array R, of two consecutive elements within the same sequence.
        !
        !  Input/output, real (wp) R(LENR), real array containing LOT
        !  sequences, each having length N.  R can have any number of dimensions, but
        !  the total number of locations must be at least LENR.  On input, the
        !  physical data to be transformed, on output the spectral data.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least (LOT-1)*JUMP + INC*(N-1) + 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to RFFTMI before the first call to routine RFFTMF
        !  or RFFTMB for a given transform length N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least LOT*N.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  4, input parameters INC, JUMP, N, LOT are not consistent.
        !


        integer (ip) lenr
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) inc
        integer (ip) jump
        integer (ip) lot
        integer (ip) n
        real (wp) r(lenr)
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)

        if (lenr < (lot-1)*jump + inc*(n-1) + 1) then
            ier = 1
            call xerfft('rfftmf ', 6)
            return
        else if (lensav < n + int(log( real(n, kind=wp) )/log(2.0_wp)) +4) then
            ier = 2
            call xerfft('rfftmf ', 8)
            return
        else if (lenwrk < lot*n) then
            ier = 3
            call xerfft('rfftmf ', 10)
            return
        else if (.not. xercon(inc,jump,n,lot)) then
            ier = 4
            call xerfft('rfftmf ', -1)
            return
        else
            ier = 0
        end if

        if (n /= 1) then
            call mrftf1(lot,jump,n,inc,r,work,wsave,wsave(n+1))
        end if

    end subroutine rfftmf

    subroutine rfftmi(n, wsave, lensav, ier)


        !
        !! RFFTMI: initialization for RFFTMB and RFFTMF.
        !
        !  Purpose:
        !
        !  RFFTMI initializes array WSAVE for use in its companion routines
        !  RFFTMB and RFFTMF.  The prime factorization of N together with a
        !  tabulation of the trigonometric functions are computed and stored
        !  in array WSAVE.  Separate WSAVE arrays are required for different
        !  values of N.
        !
        !  Parameters:
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least N + INT(LOG(REAL(N))) + 4.
        !
        !  Output, real (wp) WSAVE(LENSAV), work array containing the prime
        !  factors of N and also containing certain trigonometric
        !  values which will be used in routines RFFTMB or RFFTMF.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough.
        !


        integer (ip) lensav

        integer (ip) ier
        integer (ip) n
        real (wp) wsave(lensav)

        ier = 0

        if (lensav < n + int(log( real(n, kind=wp) )/log(2.0_wp)) +4) then
            ier = 2
            call xerfft('rfftmi ', 3)
            return
        end if

        if (n == 1) then
            return
        end if

        call mrfti1 (n,wsave(1),wsave(n+1))

        return
    end subroutine rfftmi


    subroutine sinq1b(n, inc, x, lenx, wsave, lensav, work, lenwrk, ier)
        !
        ! sinq1b: 64-bit float precision backward sine quarter wave transform, 1D.
        !
        !  Purpose:
        !
        !  Computes the one-dimensional Fourier transform of a sequence
        !  which is a sine series with odd wave numbers.  This transform is
        !  referred to as the backward transform or Fourier synthesis,
        !  transforming the sequence from spectral to physical space.
        !
        !  This transform is normalized since a call to sinq1b followed
        !  by a call to sinq1f (or vice-versa) reproduces the original
        !  array within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer N, the length of the sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations, in
        !  array R, of two consecutive elements within the sequence.
        !
        !  Input/output, real (wp) R(LENR), on input, the sequence to be
        !  transformed.  On output, the transformed sequence.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least INC*(N-1)+ 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to SINQ1I before the first call to routine SINQ1F
        !  or SINQ1B for a given transform length N.  WSAVE's contents may be
        !  re-used for subsequent calls to SINQ1F and SINQ1B with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least N.
        !
        !  Output, integer (ip) IER, the error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  20, input error returned by lower level routine.
        !

        integer (ip) inc
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) ier1
        integer (ip) k
        integer (ip) kc
        integer (ip) lenx
        integer (ip) n
        integer (ip) ns2
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) x(inc,*)
        real (wp) xhold

        if (lenx < inc*(n-1) + 1) then
            ier = 1
            call xerfft('sinq1b', 6)
        else if (lensav < 2*n + int(log(real(n, kind=wp)) &
            /log(2.0_wp)) +4) then
            ier = 2
            call xerfft('sinq1b', 8)
        else if (lenwrk < n) then
            ier = 3
            call xerfft('sinq1b', 10)
        else
            ier = 0
        end if

        if ( 1 >= n ) then
            !
            !   x(1,1) = 4.*x(1,1) line disabled by dick valent 08/26/2010
            !
            return
        else
            ns2 = n/2

            do k=2,n,2
                x(1,k) = -x(1,k)
            end do

            call cosq1b(n,inc,x,lenx,wsave,lensav,work,lenwrk,ier1)

            if (ier1 /= 0) then
                ier = 20
                call xerfft('sinq1b',-5)
                return
            end if

            do k=1,ns2
                kc = n-k
                xhold = x(1,k)
                x(1,k) = x(1,kc+1)
                x(1,kc+1) = xhold
            end do
        end if

    end subroutine sinq1b


    subroutine sinq1f(n, inc, x, lenx, wsave, lensav, work, lenwrk, ier)
        !
        ! sinq1f: 64-bit float precision forward sine quarter wave transform, 1D.
        !
        !  Purpose:
        !
        !  Computes the one-dimensional Fourier transform of a sequence
        !  which is a sine series of odd wave numbers.  This transform is
        !  referred to as the forward transform or Fourier analysis, transforming
        !  the sequence from physical to spectral space.
        !
        !  This transform is normalized since a call to sinq1f followed
        !  by a call to sinq1b (or vice-versa) reproduces the original
        !  array within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer N, the length of the sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations,
        !  in array R, of two consecutive elements within the sequence.
        !
        !  Input/output, real (wp) R(LENR), on input, the sequence to be
        !  transformed.  On output, the transformed sequence.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least INC*(N-1)+ 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to SINQ1I before the first call to routine SINQ1F
        !  or SINQ1B for a given transform length N.  WSAVE's contents may be re-used
        !  for subsequent calls to SINQ1F and SINQ1B with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least N.
        !
        !  Output, integer (ip) IER, the error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  20, input error returned by lower level routine.
        !
        integer (ip) inc
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) ier1
        integer (ip) k
        integer (ip) kc
        integer (ip) lenx
        integer (ip) n
        integer (ip) ns2
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) x(inc,*)
        real (wp) xhold

        if (lenx < inc*(n-1) + 1) then
            ier = 1
            call xerfft('sinq1f', 6)
            return
        else if (lensav < 2*n + int(log( real(n, kind=wp) )&
            /log(2.0_wp)) +4) then
            ier = 2
            call xerfft('sinq1f', 8)
            return
        else if (lenwrk < n) then
            ier = 3
            call xerfft('sinq1f', 10)
            return
        else
            ier = 0
        end if

        if (n /= 1) then
            ns2 = n/2
            do k=1,ns2
                kc = n-k
                xhold = x(1,k)
                x(1,k) = x(1,kc+1)
                x(1,kc+1) = xhold
            end do
            call cosq1f(n,inc,x,lenx,wsave,lensav,work,lenwrk,ier1)
            if (ier1 /= 0) then
                ier = 20
                call xerfft('sinq1f',-5)
                return
            end if
            do k=2,n,2
                x(1,k) = -x(1,k)
            end do
        end if

    end subroutine sinq1f


    subroutine sinq1i(n, wsave, lensav, ier)
        !
        !  sinq1i: initialization for sinq1b and sinq1f.
        !
        !  Purpose:
        !
        !  Initializes array wsave for use in its companion routines
        !  sinq1f and sinq1b. The prime factorization of n together with a
        !  tabulation of the trigonometric functions are computed and stored
        !  in array wsave. Separate wsave arrays are required for different
        !  values of n.
        !
        !  Parameters:
        !
        !  input, integer N, the length of the sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Output, real (wp) WSAVE(LENSAV), containing the prime factors
        !  of N and also containing certain trigonometric values which will be used
        ! in routines SINQ1B or SINQ1F.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough;
        !  20, input error returned by lower level routine.
        !

        integer (ip) lensav
        integer (ip) ier
        integer (ip) ier1
        integer (ip) n
        real (wp) wsave(lensav)

        if (lensav < 2*n + int(log(real(n, kind=wp)) &
            /log(2.0_wp))+4) then
            ier = 2
            call xerfft('sinq1i', 3)
            return
        else
            ier = 0
        end if

        call cosq1i(n, wsave, lensav, ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('sinq1i',-5)
        end if

    end subroutine sinq1i

    subroutine sinqmb(lot, jump, n, inc, x, lenx, wsave, lensav, &
        work, lenwrk, ier)
        !
        ! SINQMB: 64-bit float precision backward sine quarter wave, multiple vectors.
        !
        !  Purpose:
        !
        !  SINQMB computes the one-dimensional Fourier transform of multiple
        !  sequences within a real array, where each of the sequences is a
        !  sine series with odd wave numbers.  This transform is referred to as
        !  the backward transform or Fourier synthesis, transforming the
        !  sequences from spectral to physical space.
        !
        !  This transform is normalized since a call to SINQMB followed
        !  by a call to SINQMF (or vice-versa) reproduces the original
        !  array  within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer LOT, the number of sequences to be transformed
        !  within array R.
        !
        !  input, integer JUMP, the increment between the locations, in
        !  array R, of the first elements of two consecutive sequences to be
        !  transformed.
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations, in
        !  array R, of two consecutive elements within the same sequence.
        !
        !  Input/output, real (wp) R(LENR), containing LOT sequences, each
        !  having length N.  R can have any number of dimensions, but the total
        !  number of locations must be at least LENR.  On input, R contains the data
        !  to be transformed, and on output the transformed data.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least (LOT-1)*JUMP + INC*(N-1)+ 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to SINQMI before the first call to routine SINQMF
        !  or SINQMB for a given transform length N.  WSAVE's contents may be re-used
        !  for subsequent calls to SINQMF and SINQMB with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least LOT*N.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  4, input parameters INC,JUMP,N,LOT are not consistent;
        !  20, input error returned by lower level routine.
        !

        integer (ip) inc
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) ier1
        integer (ip) jump
        integer (ip) k
        integer (ip) kc
        integer (ip) lenx
        integer (ip) lj
        integer (ip) lot
        integer (ip) m
        integer (ip) n
        integer (ip) ns2
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) x(inc,*)
        real (wp) xhold

        if (lenx < (lot-1)*jump + inc*(n-1) + 1) then
            ier = 1
            call xerfft('sinqmb', 6)
        else if (lensav < 2*n + int(log( real(n, kind=wp) ) &
            /log(2.0_wp)) +4) then
            ier = 2
            call xerfft('sinqmb', 8)
        else if (lenwrk < lot*n) then
            ier = 3
            call xerfft('sinqmb', 10)
        else if (.not. xercon(inc,jump,n,lot)) then
            ier = 4
            call xerfft('sinqmb', -1)
        else
            ier = 0
        end if

        lj = (lot-1)*jump+1

        if (1 >= n ) then
            do m=1,lj,jump
                x(m,1) =  4.0_wp * x(m,1)
            end do
        else
            ns2 = n/2

            do k=2,n,2
                do m=1,lj,jump
                    x(m,k) = -x(m,k)
                end do
            end do

            call cosqmb(lot,jump,n,inc,x,lenx,wsave,lensav,work,lenwrk,ier1)

            if (ier1 /= 0) then
                ier = 20
                call xerfft('sinqmb',-5)
                return
            end if
            do k=1,ns2
                kc = n-k
                do m=1,lj,jump
                    xhold = x(m,k)
                    x(m,k) = x(m,kc+1)
                    x(m,kc+1) = xhold
                end do
            end do
        end if

    end subroutine sinqmb

    subroutine sinqmf(lot, jump, n, inc, x, lenx, wsave, lensav, &
        work, lenwrk, ier)
        !
        ! SINQMF: 64-bit float precision forward sine quarter wave, multiple vectors.
        !
        !  Purpose:
        !
        !  SINQMF computes the one-dimensional Fourier transform of multiple
        !  sequences within a real array, where each sequence is a sine series
        !  with odd wave numbers.  This transform is referred to as the forward
        !  transform or Fourier synthesis, transforming the sequences from
        !  spectral to physical space.
        !
        !  This transform is normalized since a call to SINQMF followed
        !  by a call to SINQMB (or vice-versa) reproduces the original
        !  array within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer LOT, the number of sequences to be transformed
        !  within array R.
        !
        !  input, integer JUMP, the increment between the locations,
        !  in array R, of the first elements of two consecutive sequences to
        !  be transformed.
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations,
        !  in array R, of two consecutive elements within the same sequence.
        !
        !  Input/output, real (wp) R(LENR), containing LOT sequences, each
        !  having length N.  R can have any number of dimensions, but the total
        !  number of locations must be at least LENR.  On input, R contains the data
        !  to be transformed, and on output the transformed data.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least (LOT-1)*JUMP + INC*(N-1)+ 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to SINQMI before the first call to routine SINQMF
        !  or SINQMB for a given transform length N.  WSAVE's contents may be re-used
        !  for subsequent calls to SINQMF and SINQMB with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least LOT*N.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  4, input parameters INC,JUMP,N,LOT are not consistent;
        !  20, input error returned by lower level routine.
        !


        integer (ip) inc
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) ier1
        integer (ip) jump
        integer (ip) k
        integer (ip) kc
        integer (ip) lenx
        integer (ip) lj
        integer (ip) lot
        integer (ip) m
        integer (ip) n
        integer (ip) ns2
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) x(inc,*)
        real (wp) xhold


        if (lenx < (lot-1)*jump + inc*(n-1) + 1) then
            ier = 1
            call xerfft('sinqmf', 6)
            return
        else if (lensav < 2*n + int(log( real(n, kind=wp) ) &
            /log(2.0_wp)) +4) then
            ier = 2
            call xerfft('sinqmf', 8)
            return
        else if (lenwrk < lot*n) then
            ier = 3
            call xerfft('sinqmf', 10)
            return
        else if (.not. xercon(inc,jump,n,lot)) then
            ier = 4
            call xerfft('sinqmf', -1)
            return
        else
            ier = 0
        end if

        if (n /= 1) then

            ns2 = n/2
            lj = (lot-1)*jump+1

            do k=1,ns2
                kc = n-k
                do m=1,lj,jump
                    xhold = x(m,k)
                    x(m,k) = x(m,kc+1)
                    x(m,kc+1) = xhold
                end do
            end do

            call cosqmf(lot,jump,n,inc,x,lenx,wsave,lensav,work,lenwrk,ier1)

            if (ier1 /= 0) then
                ier = 20
                call xerfft('sinqmf',-5)
                return
            end if

            do k=2,n,2
                do m=1,lj,jump
                    x(m,k) = -x(m,k)
                end do
            end do
        end if

    end subroutine sinqmf



    subroutine sinqmi(n, wsave, lensav, ier)


        !
        !! SINQMI: initialization for SINQMB and SINQMF.
        !
        !  Purpose:
        !
        !  SINQMI initializes array WSAVE for use in its companion routines
        !  SINQMF and SINQMB.  The prime factorization of N together with a
        !  tabulation of the trigonometric functions are computed and stored
        !  in array WSAVE.  Separate WSAVE arrays are required for different
        !  values of N.
        !
        !  Parameters:
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least 2*N + INT(LOG(REAL(N))) + 4.
        !
        !  Output, real (wp) WSAVE(LENSAV), containing the prime factors
        !  of N and also containing certain trigonometric values which will be used
        !  in routines SINQMB or SINQMF.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough;
        !  20, input error returned by lower level routine.
        !


        integer (ip) lensav

        integer (ip) ier
        integer (ip) ier1
        integer (ip) n
        real (wp) wsave(lensav)

        ier = 0

        if (lensav < 2*n + int(log( real(n, kind=wp) )/log(2.0_wp)) +4) then
            ier = 2
            call xerfft('sinqmi', 3)
            return
        end if

        call cosqmi(n, wsave, lensav, ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('sinqmi',-5)
        end if

        return
    end subroutine sinqmi

    subroutine sint1b(n, inc, x, lenx, wsave, lensav, work, lenwrk, ier)


        !
        !! SINT1B: 64-bit float precision backward sine transform, 1D.
        !
        !  Purpose:
        !
        !  SINT1B computes the one-dimensional Fourier transform of an odd
        !  sequence within a real array.  This transform is referred to as
        !  the backward transform or Fourier synthesis, transforming the
        !  sequence from spectral to physical space.
        !
        !  This transform is normalized since a call to SINT1B followed
        !  by a call to SINT1F (or vice-versa) reproduces the original
        !  array within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer N, the length of the sequence to be
        !  transformed.  The transform is most efficient when N+1 is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations, in
        !  array R, of two consecutive elements within the sequence.
        !
        !  Input/output, real (wp) R(LENR), on input, contains the sequence
        !  to be transformed, and on output, the transformed sequence.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least INC*(N-1)+ 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to SINT1I before the first call to routine SINT1F
        !  or SINT1B for a given transform length N.  WSAVE's contents may be re-used
        !  for subsequent calls to SINT1F and SINT1B with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least N/2 + N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least 2*N+2.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  20, input error returned by lower level routine.
        !


        integer (ip) inc
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) ier1
        integer (ip) lenx
        integer (ip) n
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) x(inc,*)

        ier = 0

        if (lenx < inc*(n-1) + 1) then
            ier = 1
            call xerfft('sint1b', 6)
            return
        else if ( lensav < n / 2 + n + int ( log(real(n, kind=wp) ) &
            / log(2.0_wp ) ) + 4 ) then
            ier = 2
            call xerfft('sint1b', 8)
            return
        else if (lenwrk < (2*n+2)) then
            ier = 3
            call xerfft('sint1b', 10)
            return
        end if

        call sintb1(n,inc,x,wsave,work,work(n+2),ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('sint1b',-5)
        end if

        return
    end subroutine sint1b
    subroutine sint1f(n, inc, x, lenx, wsave, lensav, work, lenwrk, ier)
        !
        !! SINT1F: 64-bit float precision forward sine transform, 1D.
        !
        !  Purpose:
        !
        !  SINT1F computes the one-dimensional Fourier transform of an odd
        !  sequence within a real array.  This transform is referred to as the
        !  forward transform or Fourier analysis, transforming the sequence
        !  from physical to spectral space.
        !
        !  This transform is normalized since a call to SINT1F followed
        !  by a call to SINT1B (or vice-versa) reproduces the original
        !  array within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer N, the length of the sequence to be
        !  transformed.  The transform is most efficient when N+1 is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations,
        !  in array R, of two consecutive elements within the sequence.
        !
        !  Input/output, real (wp) R(LENR), on input, contains the sequence
        !  to be transformed, and on output, the transformed sequence.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least INC*(N-1)+ 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to SINT1I before the first call to routine SINT1F
        !  or SINT1B for a given transform length N.  WSAVE's contents may be re-used
        !  for subsequent calls to SINT1F and SINT1B with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least N/2 + N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least 2*N+2.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  20, input error returned by lower level routine.
        !


        integer (ip) inc
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) ier1
        integer (ip) lenx
        integer (ip) n
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) x(inc,*)

        ier = 0

        if (lenx < inc*(n-1) + 1) then
            ier = 1
            call xerfft('sint1f', 6)
            return
        else if (lensav < n/2 + n + int(log( real(n, kind=wp) ) &
            /log(2.0_wp)) +4) then
            ier = 2
            call xerfft('sint1f', 8)
            return
        else if (lenwrk < (2*n+2)) then
            ier = 3
            call xerfft('sint1f', 10)
            return
        end if

        call sintf1(n,inc,x,wsave,work,work(n+2),ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('sint1f',-5)
        end if

    end subroutine sint1f



    subroutine sint1i(n, wsave, lensav, ier)
        !
        !! SINT1I: initialization for SINT1B and SINT1F.
        !
        !  Purpose:
        !
        !  SINT1I initializes array WSAVE for use in its companion routines
        !  SINT1F and SINT1B.  The prime factorization of N together with a
        !  tabulation of the trigonometric functions are computed and stored
        !  in array WSAVE.  Separate WSAVE arrays are required for different
        !  values of N.
        !
        !  Parameters:
        !
        !  input, integer N, the length of the sequence to be
        !  transformed.  The transform is most efficient when N+1 is a product
        !  of small primes.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least N/2 + N + INT(LOG(REAL(N))) + 4.
        !
        !  Output, real (wp) WSAVE(LENSAV), containing the prime factors
        !  of N and also containing certain trigonometric values which will be used
        !  in routines SINT1B or SINT1F.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough;
        !  20, input error returned by lower level routine.
        !


        integer (ip) lensav

        real (wp) dt
        integer (ip) ier
        integer (ip) ier1
        integer (ip) k
        integer (ip) lnsv
        integer (ip) n
        integer (ip) np1
        integer (ip) ns2
        real (wp) pi
        real (wp) wsave(lensav)

        ier = 0

        if (lensav < n/2 + n + int(log( real(n, kind=wp) ) &
            /log(2.0_wp)) +4) then
            ier = 2
            call xerfft('sint1i', 3)
            return
        end if

        pi =  acos(-1.0_wp)

        if (n <= 1) then
            return
        end if

        ns2 = n/2
        np1 = n+1
        dt = pi / real ( np1, kind=wp)

        do k=1,ns2
            wsave(k) =  2.0_wp *sin(k*dt)
        end do

        lnsv = np1 + int(log( real ( np1, kind=wp))/log(2.0_wp)) +4

        call rfft1i (np1, wsave(ns2+1), lnsv, ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('sint1i',-5)
        end if

        return
    end subroutine sint1i

    subroutine sintb1(n, inc, x, wsave, xh, work, ier)

        integer (ip) inc
        real (wp) dsum
        real (wp) fnp1s4
        integer (ip) i
        integer (ip) ier
        integer (ip) ier1
        integer (ip) k
        integer (ip) kc
        integer (ip) lnsv
        integer (ip) lnwk
        integer (ip) lnxh
        integer (ip) modn
        integer (ip) n
        integer (ip) np1
        integer (ip) ns2
        real (wp), parameter :: HALF_SQRT3 = sqrt(3.0_wp)/2
        real (wp) t1
        real (wp) t2
        real (wp) work(*)
        real (wp) wsave(*)
        real (wp) x(inc,*)
        real (wp) xh(*)
        real (wp) xhold

        ier = 0

        if (n < 2) then
            return
        else if (n == 2) then
            xhold = HALF_SQRT3*(x(1,1)+x(1,2))
            x(1,2) = HALF_SQRT3*(x(1,1)-x(1,2))
            x(1,1) = xhold
        else
            np1 = n+1
            ns2 = n/2
            do k=1,ns2
                kc = np1-k
                t1 = x(1,k)-x(1,kc)
                t2 = wsave(k)*(x(1,k)+x(1,kc))
                xh(k+1) = t1+t2
                xh(kc+1) = t2-t1
            end do

            modn = mod(n,2)

            if (modn /= 0) then
                xh(ns2+2) =  4.0_wp * x(1,ns2+1)
            end if

            xh(1) = 0.0_wp
            lnxh = np1
            lnsv = np1 + int(log(real(np1, kind=wp))/log(2.0_wp)) + 4
            lnwk = np1

            call rfft1f(np1,1,xh,lnxh,wsave(ns2+1),lnsv,work,lnwk,ier1)

            if (ier1 /= 0) then
                ier = 20
                call xerfft('sintb1',-5)
                return
            end if

            if(mod(np1,2) == 0) then
                xh(np1) = xh(np1)+xh(np1)
            end if

            fnp1s4 = real(np1, kind=wp)/4
            x(1,1) = fnp1s4*xh(1)
            dsum = x(1,1)

            do i=3,n,2
                x(1,i-1) = fnp1s4*xh(i)
                dsum = dsum+fnp1s4*xh(i-1)
                x(1,i) = dsum
            end do

            if (modn == 0) then
                x(1,n) = fnp1s4*xh(n+1)
            end if
        end if

    end subroutine sintb1

    subroutine sintf1(n, inc, x, wsave, xh, work, ier)

        integer (ip) inc
        real (wp) dsum
        integer (ip) i
        integer (ip) ier
        integer (ip) ier1
        integer (ip) k
        integer (ip) kc
        integer (ip) lnsv
        integer (ip) lnwk
        integer (ip) lnxh
        integer (ip) modn
        integer (ip) n
        integer (ip) np1
        integer (ip) ns2
        real (wp) sfnp1
        real (wp) t1
        real (wp) t2
        real (wp) work(*)
        real (wp) wsave(*)
        real (wp) x(inc,*)
        real (wp) xh(*)
        real (wp) xhold

        ier = 0

        if(n < 2) then
            return
        else if(n == 2) then
            xhold = (x(1,1)+x(1,2))/sqrt(3.0_wp)
            x(1,2) = (x(1,1)-x(1,2))/sqrt(3.0_wp)
            x(1,1) = xhold
        else
            np1 = n+1
            ns2 = n/2
            do k=1,ns2
                kc = np1-k
                t1 = x(1,k)-x(1,kc)
                t2 = wsave(k)*(x(1,k)+x(1,kc))
                xh(k+1) = t1+t2
                xh(kc+1) = t2-t1
            end do

            modn = mod(n,2)

            if (modn /= 0) then
                xh(ns2+2) =  4.0_wp * x(1,ns2+1)
            end if

            xh(1) = 0.0_wp
            lnxh = np1
            lnsv = np1 + int(log(real(np1, kind=wp))/log(2.0_wp)) + 4
            lnwk = np1

            call rfft1f(np1,1,xh,lnxh,wsave(ns2+1),lnsv,work, lnwk,ier1)

            if (ier1 /= 0) then
                ier = 20
                call xerfft('sintf1',-5)
                return
            end if

            if(mod(np1,2) == 0) then
                xh(np1) = xh(np1)+xh(np1)
            end if

            sfnp1 = 1.0_wp/np1
            x(1,1) = 0.5_wp * xh(1)
            dsum = x(1,1)

            do i=3,n,2
                x(1,i-1) = 0.5_wp * xh(i)
                dsum = dsum + 0.5_wp * xh(i-1)
                x(1,i) = dsum
            end do

            if (modn == 0) then
                x(1,n) = 0.5_wp * xh(n+1)
            end if
        end if

    end subroutine sintf1


    subroutine sintmb(lot, jump, n, inc, x, lenx, wsave, lensav, &
        work, lenwrk, ier)
        !
        ! SINTMB: 64-bit float precision backward sine transform, multiple vectors.
        !
        !  Purpose:
        !
        !  SINTMB computes the one-dimensional Fourier transform of multiple
        !  odd sequences within a real array.  This transform is referred to as
        !  the backward transform or Fourier synthesis, transforming the
        !  sequences from spectral to physical space.
        !
        !  This transform is normalized since a call to SINTMB followed
        !  by a call to SINTMF (or vice-versa) reproduces the original
        !  array within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer LOT, the number of sequences to be transformed
        !  within the array R.
        !
        !  input, integer JUMP, the increment between the locations, in
        !  array R, of the first elements of two consecutive sequences.
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N+1 is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations, in
        !  array R, of two consecutive elements within the same sequence.
        !
        !  Input/output, real (wp) R(LENR), containing LOT sequences, each
        !  having length N.  R can have any number of dimensions, but the total
        !  number of locations must be at least LENR.  On input, R contains the data
        !  to be transformed, and on output, the transformed data.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least (LOT-1)*JUMP + INC*(N-1)+ 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to SINTMI before the first call to routine SINTMF
        !  or SINTMB for a given transform length N.  WSAVE's contents may be re-used
        !  for subsequent calls to SINTMF and SINTMB with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least N/2 + N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least LOT*(2*N+4).
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  4, input parameters INC,JUMP,N,LOT are not consistent;
        !  20, input error returned by lower level routine.
        !


        integer (ip) inc
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) ier1
        integer (ip) iw1
        integer (ip) iw2
        integer (ip) jump
        integer (ip) lenx
        integer (ip) lot
        integer (ip) n
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) x(inc,*)

        if (lenx < (lot-1)*jump + inc*(n-1) + 1) then
            ier = 1
            call xerfft('sintmb', 6)
            return
        else if ( lensav < n / 2 + n + int ( log(real(n, kind=wp) ) &
            /log(2.0_wp)) +4) then
            ier = 2
            call xerfft('sintmb', 8)
            return
        else if (lenwrk < lot*(2*n+4)) then
            ier = 3
            call xerfft('sintmb', 10)
            return
        else if (.not. xercon(inc,jump,n,lot)) then
            ier = 4
            call xerfft('sintmb', -1)
            return
        else
            ier = 0
        end if

        iw1 = lot+lot+1
        iw2 = iw1+lot*(n+1)

        call msntb1(lot,jump,n,inc,x,wsave,work,work(iw1),work(iw2),ier1)

        if (ier1 /= 0) then
            ier = 20
            call xerfft('sintmb',-5)
            return
        end if

    end subroutine sintmb


    subroutine sintmf(lot, jump, n, inc, x, lenx, wsave, lensav, &
        work, lenwrk, ier)
        !
        !! SINTMF: 64-bit float precision forward sine transform, multiple vectors.
        !
        !  Purpose:
        !
        !  SINTMF computes the one-dimensional Fourier transform of multiple
        !  odd sequences within a real array.  This transform is referred to as
        !  the forward transform or Fourier analysis, transforming the sequences
        !  from physical to spectral space.
        !
        !  This transform is normalized since a call to SINTMF followed
        !  by a call to SINTMB (or vice-versa) reproduces the original
        !  array within roundoff error.
        !
        !  Parameters:
        !
        !  input, integer LOT, the number of sequences to be
        !  transformed within.
        !
        !  input, integer JUMP, the increment between the locations,
        !  in array R, of the first elements of two consecutive sequences.
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N+1 is a product of
        !  small primes.
        !
        !  input, integer INC, the increment between the locations, in
        !  array R, of two consecutive elements within the same sequence.
        !
        !  Input/output, real (wp) R(LENR), containing LOT sequences, each
        !  having length N.  R can have any number of dimensions, but the total
        !  number of locations must be at least LENR.  On input, R contains the data
        !  to be transformed, and on output, the transformed data.
        !
        !  input, integer LENR, the dimension of the R array.
        !  LENR must be at least (LOT-1)*JUMP + INC*(N-1)+ 1.
        !
        !  Input, real (wp) WSAVE(LENSAV).  WSAVE's contents must be
        !  initialized with a call to SINTMI before the first call to routine SINTMF
        !  or SINTMB for a given transform length N.  WSAVE's contents may be re-used
        !  for subsequent calls to SINTMF and SINTMB with the same N.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least N/2 + N + INT(LOG(REAL(N))) + 4.
        !
        !  Workspace, real (wp) WORK(LENWRK).
        !
        !  input, integer LENWRK, the dimension of the WORK array.
        !  LENWRK must be at least LOT*(2*N+4).
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  1, input parameter LENR not big enough;
        !  2, input parameter LENSAV not big enough;
        !  3, input parameter LENWRK not big enough;
        !  4, input parameters INC,JUMP,N,LOT are not consistent;
        !  20, input error returned by lower level routine.
        !


        integer (ip) inc
        integer (ip) lensav
        integer (ip) lenwrk

        integer (ip) ier
        integer (ip) ier1
        integer (ip) iw1
        integer (ip) iw2
        integer (ip) jump
        integer (ip) lenx
        integer (ip) lot
        integer (ip) n
        real (wp) work(lenwrk)
        real (wp) wsave(lensav)
        real (wp) x(inc,*)

        if ( lenx < ( lot - 1) * jump + inc * ( n - 1 ) + 1 ) then
            ier = 1
            call xerfft( 'sintmf', 6 )
            return
        else if ( lensav < n / 2 + n + int ( log(real(n, kind=wp) ) &
            / log(2.0_wp ) ) + 4 ) then
            ier = 2
            call xerfft( 'sintmf', 8 )
            return
        else if ( lenwrk < lot * ( 2 * n + 4 ) ) then
            ier = 3
            call xerfft( 'sintmf', 10 )
            return
        else if ( .not. xercon ( inc, jump, n, lot ) ) then
            ier = 4
            call xerfft( 'sintmf', -1 )
            return
        else
            ier = 0
        end if

        iw1 = lot + lot + 1
        iw2 = iw1 + lot * ( n + 1 )
        call msntf1(lot, jump, n, inc, x, wsave, work, work(iw1), work(iw2), ier1 )

        if ( ier1 /= 0 ) then
            ier = 20
            call xerfft( 'sintmf', -5 )
        end if

    end subroutine sintmf


    subroutine sintmi(n, wsave, lensav, ier)
        !
        ! sintmi: initialization for sintmb and sintmf.
        !
        !  Purpose:
        !
        !  Initializes array wsave for use in its companion routines
        !  sintmf and sintmb.  The prime factorization of n together with a
        !  tabulation of the trigonometric functions are computed and stored
        !  in array wsave.  Separate wsave arrays are required for different
        !  values of n.
        !
        !  Parameters:
        !
        !  input, integer N, the length of each sequence to be
        !  transformed.  The transform is most efficient when N is a product of
        !  small primes.
        !
        !  input, integer LENSAV, the dimension of the WSAVE array.
        !  LENSAV must be at least N/2 + N + INT(LOG(REAL(N))) + 4.
        !
        !  Output, real (wp) WSAVE(LENSAV), containing the prime factors
        !  of N and also containing certain trigonometric values which will be used
        !  in routines SINTMB or SINTMF.
        !
        !  Output, integer (ip) IER, error flag.
        !  0, successful exit;
        !  2, input parameter LENSAV not big enough;
        !  20, input error returned by lower level routine.
        !


        integer (ip) lensav

        real (wp) dt
        integer (ip) ier
        integer (ip) ier1
        integer (ip) k
        integer (ip) lnsv
        integer (ip) n
        integer (ip) np1
        integer (ip) ns2
        real (wp), parameter :: PI = acos(-1.0_wp)
        real (wp) wsave(lensav)

        ier = 0

        if ( lensav < n / 2 + n + int ( log(real(n, kind=wp) ) &
            / log(2.0_wp ) ) + 4 ) then
            ier = 2
            call xerfft( 'sintmi', 3 )
            return
        end if

        if ( n > 1 ) then

            ns2 = n / 2
            np1 = n + 1
            dt = PI/np1

            do k = 1, ns2
                wsave(k) = 2.0_wp * sin(k*dt)
            end do

            lnsv = np1 + int(log(real(np1, kind=wp) )/log(2.0_wp)) + 4

            call rfftmi(np1, wsave(ns2+1), lnsv, ier1)

            if ( ier1 /= 0 ) then
                ier = 20
                call xerfft( 'sintmi', -5 )
            end if
        end if

    end subroutine sintmi


    subroutine copy_w_into_r(ldr, ldw, l, m, r, w)
        !
        !
        ! Purpose:
        !
        ! Copies a 2D array, allowing for different leading dimensions.
        !
        integer (ip), intent (in)     :: ldr
        integer (ip), intent (in)     :: ldw
        integer (ip), intent (in)     :: m
        integer (ip), intent (in)     :: l
        real (wp),    intent (in out) :: r(ldr,m)
        real (wp),    intent (in)     :: w(ldw,m)

        r(1:l,:) = w(1:l,:)

    end subroutine copy_w_into_r


    function xercon(inc, jump, n, lot) result (return_value)
        !
        ! xercon checks inc, jump, n and lot for consistency.
        !
        !  Purpose:
        !
        !  Positive integers inc, jump, n and lot are "consistent" if,
        !  for any values i1 and i2 < n, and j1 and j2 < lot,
        !
        !  i1 * inc + j1 * jump = i2 * inc + j2 * jump
        !
        !  can only occur if i1 = i2 and j1 = j2.
        !
        !  For multiple FFT's to execute correctly, inc, jump, n and lot must
        !  be consistent, or else at least one array element will be
        !  transformed more than once.
        !
        !  Parameters:
        !
        !  input, integer INC, JUMP, N, LOT, the parameters to check.
        !
        !  Output, logical xercon, is TRUE if the parameters are consistent.
        !

        integer (ip) i
        integer (ip) inc
        integer (ip) j
        integer (ip) jnew
        integer (ip) jump
        integer (ip) lcm
        integer (ip) lot
        integer (ip) n
        logical return_value

        i = inc
        j = jump

        do while (j /= 0)
            jnew = mod(i, j)
            i = j
            j = jnew
        end do
        !
        !  LCM = least common multiple of INC and JUMP.
        !
        lcm = ( inc * jump ) / i

        if ( lcm <= ( n - 1 ) * inc .and. lcm <= ( lot - 1 ) * jump ) then
            return_value = .false.
        else
            return_value = .true.
        end if

    end function xercon


    subroutine xerfft(srname, info)
        !
        ! XERFFT is an error handler for the FFTPACK routines.
        !
        !  Purpose:
        !
        !  XERFFT is an error handler for FFTPACK version 5.1 routines.
        !  It is called by an FFTPACK 5.1 routine if an input parameter has an
        !  invalid value.  A message is printed and execution stops.
        !
        !  Installers may consider modifying the stop statement in order to
        !  call system-specific exception-handling facilities.
        !
        !  Parameters:
        !
        !  Input, character (len=*) SRNAME, the name of the calling routine.
        !
        !  input, integer INFO, an error code.  When a single invalid
        !  parameter in the parameter list of the calling routine has been detected,
        !  INFO is the position of that parameter.  In the case when an illegal
        !  combination of LOT, JUMP, N, and INC has been detected, the calling
        !  subprogram calls XERFFT with INFO = -1.
        !

        integer (ip),      intent (in) :: info
        character (len=*), intent (in) :: srname

        write ( stderr, '(A)' ) ''
        write ( stderr, '(A)' ) ' Object of class (FFTpack): '
        write ( stderr, '(A)' ) ' xerfft - fatal error'

        if ( 1 <= info ) then
            write ( stderr, '(a,a,a,i3,a)') '  On entry to ',trim(srname),&
                ' parameter number ', info, ' had an illegal value.'
        else if ( info == -1 ) then
            write( stderr, '(4(A))') '  On entry to ',trim(srname), &
                ' parameters lot, jump, n and inc are inconsistent.'
        else if ( info == -2 ) then
            write( stderr, '(4(A))')  '  On ntry to ', trim(srname), &
                ' parameter l is greater than ldim.'
        else if ( info == -3 ) then
            write( stderr, '(4(A))')  '  On entry to ', trim(srname), &
                ' parameter m is greater than mdim.'
        else if ( info == -5 ) then
            write( stderr, '(4(A))')  '  Within ', trim(srname), &
                ' input error returned by lower level routine.'
        else if ( info == -6 ) then
            write( stderr, '(4(A))')  '  On entry to ', trim(srname), &
                ' parameter ldim is less than 2*(l/2+1).'
        end if

    end subroutine xerfft

end module type_FFTpack