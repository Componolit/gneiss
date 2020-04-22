
with System;

package Gneiss_Internal.Epoll with
   SPARK_Mode
is

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

   function Get_Type (E : Event) return Event_Type is
      (if E.Epoll_Hup or else E.Epoll_Err or else E.Epoll_Rdhup then Epoll_Er else Epoll_Ev);

   procedure Create (Efd : out Epoll_Fd) with
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Add (Efd     :     Epoll_Fd;
                  Fd      :     File_Descriptor;
                  Index   :     Integer;
                  Success : out Boolean) with
      Pre    => Valid (Fd) and then Valid (Efd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Add (Efd     :     Epoll_Fd;
                  Fd      :     File_Descriptor;
                  Ptr     :     System.Address;
                  Success : out Boolean) with
      Pre    => Valid (Fd) and then Valid (Efd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Remove (Efd     :     Epoll_Fd;
                     Fd      :     File_Descriptor;
                     Success : out Boolean) with
      Pre    => Valid (Fd) and then Valid (Efd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Wait (Efd   :     Epoll_Fd;
                   Ev    : out Event;
                   Index : out Integer) with
      Pre    => Valid (Efd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

   procedure Wait (Efd :     Epoll_Fd;
                   Ev  : out Event;
                   Ptr : out System.Address) with
      Pre    => Valid (Efd),
      Global => (In_Out => Gneiss_Internal.Platform_State);

end Gneiss_Internal.Epoll;
