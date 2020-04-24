
with System;
with Gneiss_Internal.Epoll;
with Gneiss_Internal.Syscall;
with Gneiss_Internal.Client;
with Gneiss_Protocol.Session;

package body Gneiss.Timer.Client with
   SPARK_Mode
is

   function Event_Address (Session : Client_Session) return System.Address;
   procedure Session_Event (Session : in out Client_Session;
                            Fd      :        Gneiss_Internal.File_Descriptor);
   procedure Session_Error (Session : in out Client_Session;
                            Fd      :        Gneiss_Internal.File_Descriptor) is null;
   function Event_Cap is new Gneiss_Internal.Create_Event_Cap (Client_Session,
                                                               Client_Session,
                                                               Session_Event,
                                                               Session_Error);

   procedure Timer_Set (Fd : Gneiss_Internal.File_Descriptor;
                        D  : Duration) with
      Import,
      Convention    => C,
      External_Name => "gneiss_timer_set",
      Global        => (In_Out => Gneiss_Internal.Platform_State);

   function Timer_Get (Fd : Gneiss_Internal.File_Descriptor) return Time with
      Import,
      Convention    => C,
      External_Name => "gneiss_timer_get",
      Global        => (Input => Gneiss_Internal.Platform_State),
      Volatile_Function;

   procedure Timer_Read (Fd : Gneiss_Internal.File_Descriptor) with
      Import,
      Convention    => C,
      External_Name => "gneiss_timer_read",
      Global        => (In_Out => Gneiss_Internal.Platform_State);

   function Event_Address (Session : Client_Session) return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Session.E_Cap'Address;
   end Event_Address;

   procedure Session_Event (Session : in out Client_Session;
                            Fd      :        Gneiss_Internal.File_Descriptor)
   is
      pragma Unreferenced (Fd);
   begin
      Timer_Read (Session.Fd);
      Event;
   end Session_Event;

   procedure Initialize (C     : in out Client_Session;
                         Cap   :        Capability;
                         Label :        String;
                         Idx   :        Session_Index := 1)
   is
      use type Gneiss_Internal.File_Descriptor;
      Fds     : Gneiss_Internal.Fd_Array (1 .. 1) := (others => -1);
      Success : Boolean;
   begin
      if Initialized (C) then
         return;
      end if;
      Gneiss_Internal.Client.Initialize (Cap.Broker_Fd, Gneiss_Protocol.Session.Timer, Fds, Label);
      if not Gneiss_Internal.Valid (Fds (Fds'First)) then
         return;
      end if;
      C.E_Cap := Event_Cap (C, C, Fds (Fds'First));
      Gneiss_Internal.Epoll.Add (Cap.Efd, Fds (Fds'First), Event_Address (C), Success);
      if not Success then
         Gneiss_Internal.Syscall.Close (Fds (Fds'First));
         Gneiss_Internal.Invalidate (C.E_Cap);
         return;
      end if;
      C.Fd    := Fds (Fds'First);
      C.Epoll := Cap.Efd;
      C.Index := Session_Index_Option'(Valid => True, Value => Idx);
   end Initialize;

   function Clock (C : Client_Session) return Time with
      SPARK_Mode => Off
      --  Clock is not recognized as volatile even though Timer_Get is
   is
   begin
      return Timer_Get (C.Fd);
   end Clock;

   procedure Set_Timeout (C : in out Client_Session;
                          D :        Duration)
   is
   begin
      Timer_Set (C.Fd, D);
   end Set_Timeout;

   procedure Finalize (C : in out Client_Session)
   is
      use type Gneiss_Internal.Epoll_Fd;
      Ignore_Success : Boolean;
   begin
      if not Initialized (C) then
         return;
      end if;
      Gneiss_Internal.Epoll.Remove (C.Epoll, C.Fd, Ignore_Success);
      C.Epoll := -1;
      Gneiss_Internal.Syscall.Close (C.Fd);
      C.Index := Session_Index_Option'(Valid => False);
      Gneiss_Internal.Invalidate (C.E_Cap);
   end Finalize;

end Gneiss.Timer.Client;
