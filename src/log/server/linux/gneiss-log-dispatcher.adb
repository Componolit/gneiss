
with RFLX.Session;
with System;
with Gneiss_Epoll;
with Gneiss_Platform;
with Gneiss_Syscall;
with Gneiss_Internal.Log;
with Gneiss_Internal.Message_Syscall;

package body Gneiss.Log.Dispatcher with
   SPARK_Mode
is

   function Event_Cap_Address (Session : Server_Session) return System.Address;

   procedure Dispatch_Event (Session : in out Dispatcher_Session;
                             Name    :        String;
                             Label   :        String;
                             Fd      : in out Gneiss_Syscall.Fd_Array;
                             Num     :    out Natural);

   procedure Session_Event (Session : in out Server_Session);

   function Event_Cap is new Gneiss_Platform.Create_Event_Cap (Server_Session, Session_Event);

   procedure Read_Buffer (Session : in out Server_Session) with
      Pre =>  Initialized (Session)
              and then Gneiss_Internal.Message_Syscall.Peek (Session.Fd)
                       >= Gneiss_Internal.Log.Message_Buffer'Length,
      Post => Initialized (Session)
              and then Session.Cursor = Session.Buffer'Last;

   function Event_Cap_Address (Session : Server_Session) return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Session.E_Cap'Address;
   end Event_Cap_Address;

   procedure Dispatch_Event (Session : in out Dispatcher_Session;
                             Name    :        String;
                             Label   :        String;
                             Fd      : in out Gneiss_Syscall.Fd_Array;
                             Num     :    out Natural)
   is
   begin
      Session.Client_Fd := -1;
      Session.Accepted  := False;
      if Fd'Length = 1 then
         Dispatch (Session, Dispatcher_Capability'(Clean_Fd => Fd (Fd'First), others => -1), "", "");
         Num := 0;
         return;
      end if;
      Dispatch (Session, Dispatcher_Capability'(Clean_Fd  => -1,
                                                Client_Fd => Fd (Fd'First),
                                                Server_Fd => Fd (Fd'First + 1)),
                Name, Label);
      Num := (if Session.Accepted then 1 else 0);
   end Dispatch_Event;

   procedure Initialize (Session : in out Dispatcher_Session;
                         Cap     :        Capability;
                         Idx     :        Session_Index := 1)
   is
   begin
      Session.Register_Service := Cap.Register_Service;
      Session.Epoll_Fd         := Cap.Epoll_Fd;
      Session.Index            := Gneiss.Session_Index_Option'(Valid => True, Value => Idx);
   end Initialize;

   function Reg_Dispatcher_Cap is new Gneiss_Platform.Create_Dispatcher_Cap
      (Dispatcher_Session, Dispatch_Event);

   procedure Register (Session : in out Dispatcher_Session)
   is
      Ignore_Success : Boolean;
   begin
      Gneiss_Platform.Call (Session.Register_Service,
                            RFLX.Session.Log,
                            Reg_Dispatcher_Cap (Session),
                            Ignore_Success);
   end Register;

   function Valid_Session_Request (Session : Dispatcher_Session;
                                   Cap     : Dispatcher_Capability) return Boolean is
      (Cap.Clean_Fd < 0);

   procedure Session_Initialize (Session  : in out Dispatcher_Session;
                                 Cap      :        Dispatcher_Capability;
                                 Server_S : in out Server_Session;
                                 Idx      :        Session_Index := 1)
   is
      pragma Unreferenced (Session);
   begin
      Server_S.Fd    := Cap.Server_Fd;
      Server_S.Index := Gneiss.Session_Index_Option'(Valid => True, Value => Idx);
      Server_S.E_Cap := Event_Cap (Server_S);
      Server_Instance.Initialize (Server_S);
      if not Server_Instance.Ready (Server_S) then
         Gneiss_Syscall.Close (Server_S.Fd);
         Server_S.Index := Gneiss.Session_Index_Option'(Valid => False);
      end if;
   end Session_Initialize;

   procedure Session_Accept (Session  : in out Dispatcher_Session;
                             Cap      :        Dispatcher_Capability;
                             Server_S : in out Server_Session)
   is
      Ignore_Success : Integer;
   begin
      Session.Client_Fd := Cap.Client_Fd;
      Gneiss_Epoll.Add (Session.Epoll_Fd, Server_S.Fd, Event_Cap_Address (Server_S), Ignore_Success);
      Session.Accepted := True;
   end Session_Accept;

   procedure Session_Cleanup (Session  : in out Dispatcher_Session;
                              Cap      :        Dispatcher_Capability;
                              Server_S : in out Server_Session)
   is
      Ignore_Success : Integer;
   begin
      if
         Cap.Clean_Fd >= 0
         and then Server_S.Fd = Cap.Clean_Fd
      then
         Gneiss_Epoll.Remove (Session.Epoll_Fd, Server_S.Fd, Ignore_Success);
         Gneiss_Syscall.Close (Server_S.Fd);
         Server_Instance.Finalize (Server_S);
         Gneiss_Platform.Invalidate (Server_S.E_Cap);
         Server_S.Index := Gneiss.Session_Index_Option'(Valid => False);
      end if;
   end Session_Cleanup;

   procedure Session_Event (Session : in out Server_Session)
   is
   begin
      Read_Buffer (Session);
      for I in Session.Buffer'Range loop
         exit when Session.Buffer (I) = ASCII.NUL;
         Session.Cursor := I;
      end loop;
      if Session.Cursor > Session.Buffer'First then
         Server_Instance.Write (Session, Session.Buffer (Session.Buffer'First .. Session.Cursor));
      end if;
   end Session_Event;

   procedure Read_Buffer (Session : in out Server_Session) with
      SPARK_Mode => Off
   is
   begin
      Gneiss_Internal.Message_Syscall.Read (Session.Fd, Session.Buffer'Address, Session.Buffer'Length);
      Session.Cursor := Session.Buffer'First;
   end Read_Buffer;

end Gneiss.Log.Dispatcher;
