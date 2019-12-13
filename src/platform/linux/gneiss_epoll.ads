
with System;

package Gneiss_Epoll with
   SPARK_Mode,
   Abstract_State => Linux,
   Initializes => Linux,
   Elaborate_Body
is

   type Epoll_Fd is new Integer;
   type Event is record
      Epoll_In        : Boolean;
      Epoll_Pri       : Boolean;
      Epoll_Out       : Boolean;
      Epoll_Rdnorm    : Boolean;
      Epoll_Rdband    : Boolean;
      Epoll_Wrnorm    : Boolean;
      Epoll_Wrband    : Boolean;
      Epoll_Msg       : Boolean;
      Epoll_Err       : Boolean;
      Epoll_Hup       : Boolean;
      Epoll_Rdhup     : Boolean;
      Epoll_Exclusive : Boolean;
      Epoll_Wakeup    : Boolean;
      Epoll_Oneshot   : Boolean;
      Epoll_Et        : Boolean;
   end record with
      Size => 32;
   for Event use record
      Epoll_In        at 0 range  0 ..  0;
      Epoll_Pri       at 0 range  1 ..  1;
      Epoll_Out       at 0 range  2 ..  2;
      Epoll_Err       at 0 range  3 ..  3;
      Epoll_Hup       at 0 range  4 ..  4;
      Epoll_Rdnorm    at 0 range  6 ..  6;
      Epoll_Rdband    at 0 range  7 ..  7;
      Epoll_Wrnorm    at 0 range  8 ..  8;
      Epoll_Wrband    at 0 range  9 ..  9;
      Epoll_Msg       at 0 range 10 .. 10;
      Epoll_Rdhup     at 0 range 13 .. 13;
      Epoll_Exclusive at 0 range 28 .. 28;
      Epoll_Wakeup    at 0 range 29 .. 29;
      Epoll_Oneshot   at 0 range 30 .. 30;
      Epoll_Et        at 0 range 31 .. 31;
   end record;

   procedure Create (Efd : out Epoll_Fd) with
      Import,
      Convention    => C,
      External_Name => "gneiss_epoll_create",
      Global        => (In_Out => Linux);

   procedure Add (Efd     :     Epoll_Fd;
                  Fd      :     Integer;
                  Index   :     Integer;
                  Success : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_epoll_add_fd",
      Global        => (In_Out => Linux);

   procedure Add (Efd     :     Epoll_Fd;
                  Fd      :     Integer;
                  Ptr     :     System.Address;
                  Success : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_epoll_add_ptr",
      Global        => (In_Out => Linux);

   procedure Remove (Efd : Epoll_Fd;
                     Fd : Integer;
                     Success : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_epoll_remove",
      Global        => (In_Out => Linux);

   procedure Wait (Efd   :     Epoll_Fd;
                   Ev    : out Event;
                   Index : out Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_epoll_wait_fd",
      Global        => (In_Out => Linux);

   procedure Wait (Efd   :     Epoll_Fd;
                   Ev    : out Event;
                   Ptr   : out System.Address) with
      Import,
      Convention    => C,
      External_Name => "gneiss_epoll_wait_ptr",
      Global        => (In_Out => Linux);

end Gneiss_Epoll;
