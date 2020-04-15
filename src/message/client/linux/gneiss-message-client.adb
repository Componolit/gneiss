
with RFLX.Session;
with System;
with Gneiss_Syscall;
with Gneiss_Epoll;
with Gneiss_Platform;
with Gneiss.Platform_Client;
with Gneiss_Internal.Message_Syscall;

package body Gneiss.Message.Client with
   SPARK_Mode
is

   function Get_Event_Address (Session : Client_Session) return System.Address;

   procedure Session_Event (Session : in out Client_Session;
                            Fd      :        Integer);
   procedure Session_Error (Session : in out Client_Session;
                            Fd      :        Integer) is null;

   function Event_Cap is new Gneiss_Platform.Create_Event_Cap (Client_Session,
                                                               Client_Session,
                                                               Session_Event,
                                                               Session_Error);

   function Get_Event_Address (Session : Client_Session) return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Session.Event_Cap'Address;
   end Get_Event_Address;

   procedure Session_Event (Session : in out Client_Session;
                            Fd      :        Integer)
   is
      pragma Unreferenced (Session);
      pragma Unreferenced (Fd);
   begin
      Event;
   end Session_Event;

   procedure Initialize (Session : in out Client_Session;
                         Cap     :        Capability;
                         Label   :        String;
                         Idx     :        Session_Index := 1)
   is
      Fds : Gneiss_Syscall.Fd_Array (1 .. 1) := (others => -1);
      Success : Integer;
   begin
      if Initialized (Session) or else Session.Label.Value'Length < Label'Length then
         return;
      end if;
      Platform_Client.Initialize (Cap, RFLX.Session.Message, Fds, Label);
      if Fds (Fds'First) < 0 then
         return;
      end if;
      Session.Event_Cap := Event_Cap (Session, Session, Fds (Fds'First));
      Gneiss_Epoll.Add (Cap.Epoll_Fd, Fds (Fds'First), Get_Event_Address (Session), Success);
      if Success < 0 then
         Gneiss_Syscall.Close (Fds (Fds'First));
         Gneiss_Platform.Invalidate (Session.Event_Cap);
         return;
      end if;
      Session.File_Descriptor := Fds (Fds'First);
      Session.Epoll_Fd        := Cap.Epoll_Fd;
      Session.Index           := Session_Index_Option'(Valid => True, Value => Idx);
      Session.Label.Last      := Session.Label.Value'First + Label'Length - 1;
      Session.Label.Value (Session.Label.Value'First .. Session.Label.Last) := Label;
   end Initialize;

   procedure Finalize (Session : in out Client_Session)
   is
      Ignore_Success : Integer;
   begin
      Gneiss_Epoll.Remove (Session.Epoll_Fd, Session.File_Descriptor, Ignore_Success);
      Gneiss_Syscall.Close (Session.File_Descriptor);
      Gneiss_Platform.Invalidate (Session.Event_Cap);
      Session.Label.Last := 0;
      Session.Index      := Gneiss.Session_Index_Option'(Valid => False);
   end Finalize;

   function Available (Session : Client_Session) return Boolean is
      (Gneiss_Internal.Message_Syscall.Peek (Session.File_Descriptor) >= Message_Buffer'Size * 8);

   procedure Write (Session : in out Client_Session;
                    Content :        Message_Buffer) with
      SPARK_Mode => Off
   is
   begin
      Gneiss_Internal.Message_Syscall.Write (Session.File_Descriptor, Content'Address, Content'Size * 8);
   end Write;

   procedure Read (Session : in out Client_Session;
                   Content :    out Message_Buffer) with
      SPARK_Mode => Off
   is
   begin
      Gneiss_Internal.Message_Syscall.Read (Session.File_Descriptor, Content'Address, Content'Size * 8);
   end Read;

end Gneiss.Message.Client;
