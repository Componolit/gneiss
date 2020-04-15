
with System;
with Gneiss_Epoll;
with Gneiss_Platform;
with Gneiss_Syscall;
with Gneiss.Platform_Client;
with RFLX.Session;

package body Gneiss.Timer.Client with
   SPARK_Mode
is

   function Event_Address (Session : Client_Session) return System.Address;
   procedure Session_Event (Session : in out Client_Session;
                            Fd      :        Integer);
   procedure Session_Error (Session : in out Client_Session;
                            Fd      :        Integer) is null;
   function Event_Cap is new Gneiss_Platform.Create_Event_Cap (Client_Session,
                                                               Client_Session,
                                                               Session_Event,
                                                               Session_Error);

   procedure Timer_Set (Fd : Integer;
                        D  : Duration) with
      Import,
      Convention    => C,
      External_Name => "gneiss_timer_set";

   function Timer_Get (Fd : Integer) return Time with
      Import,
      Convention    => C,
      External_Name => "gneiss_timer_get",
      Volatile_Function;

   procedure Timer_Read (Fd : Integer) with
      Import,
      Convention    => C,
      External_Name => "gneiss_timer_read";

   function Event_Address (Session : Client_Session) return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Session.E_Cap'Address;
   end Event_Address;

   procedure Session_Event (Session : in out Client_Session;
                            Fd      :        Integer)
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
      Fds     : Gneiss_Syscall.Fd_Array (1 .. 1) := (others => -1);
      Success : Integer;
   begin
      if Initialized (C) then
         return;
      end if;
      Platform_Client.Initialize (Cap, RFLX.Session.Timer, Fds, Label);
      if Fds (Fds'First) < 0 then
         return;
      end if;
      C.E_Cap := Event_Cap (C, C, Fds (Fds'First));
      Gneiss_Epoll.Add (Cap.Epoll_Fd, Fds (Fds'First), Event_Address (C), Success);
      if Success < 0 then
         Gneiss_Syscall.Close (Fds (Fds'First));
         Gneiss_Platform.Invalidate (C.E_Cap);
         return;
      end if;
      C.Fd    := Fds (Fds'First);
      C.Epoll := Cap.Epoll_Fd;
      C.Index := Session_Index_Option'(Valid => True, Value => Idx);
   end Initialize;

   function Clock (C : Client_Session) return Time
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
      use type Gneiss_Epoll.Epoll_Fd;
      Ignore_Success : Integer;
   begin
      if not Initialized (C) then
         return;
      end if;
      Gneiss_Epoll.Remove (C.Epoll, C.Fd, Ignore_Success);
      C.Epoll := -1;
      Gneiss_Syscall.Close (C.Fd);
      C.Index := Session_Index_Option'(Valid => False);
      Gneiss_Platform.Invalidate (C.E_Cap);
   end Finalize;

end Gneiss.Timer.Client;
