
with System;
with Gneiss_Protocol.Session;
with Gneiss_Internal.Syscall;
with Gneiss_Internal.Epoll;
with Gneiss_Internal.Client;
with Gneiss_Internal.Message_Syscall;

package body Gneiss.Message.Client with
   SPARK_Mode
is

   function Get_Event_Address (Session : Client_Session) return System.Address;

   procedure Session_Event (Session : in out Client_Session;
                            Fd      :        Gneiss_Internal.File_Descriptor);
   procedure Session_Error (Session : in out Client_Session;
                            Fd      :        Gneiss_Internal.File_Descriptor) is null;

   function Event_Cap is new Gneiss_Internal.Create_Event_Cap (Client_Session,
                                                               Client_Session,
                                                               Session_Event,
                                                               Session_Error);

   function Get_Event_Address (Session : Client_Session) return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Session.E_Cap'Address;
   end Get_Event_Address;

   procedure Session_Event (Session : in out Client_Session;
                            Fd      :        Gneiss_Internal.File_Descriptor)
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
      use type Gneiss_Internal.File_Descriptor;
      Fds     : Gneiss_Internal.Fd_Array (1 .. 1) := (others => -1);
      Success : Boolean;
   begin
      if
         Initialized (Session)
         or else Session.Label.Value'Length < Label'Length
         or else Message_Buffer'Size /= 128 * 8
      then
         return;
      end if;
      Gneiss_Internal.Client.Initialize (Cap.Broker_Fd, Gneiss_Protocol.Session.Message, Fds, Label);
      if not Gneiss_Internal.Valid (Fds (Fds'First)) then
         return;
      end if;
      Session.E_Cap := Event_Cap (Session, Session, Fds (Fds'First));
      Gneiss_Internal.Epoll.Add (Cap.Efd, Fds (Fds'First), Get_Event_Address (Session), Success);
      if not Success then
         Gneiss_Internal.Syscall.Close (Fds (Fds'First));
         Gneiss_Internal.Invalidate (Session.E_Cap);
         return;
      end if;
      Session.Fd         := Fds (Fds'First);
      Session.Efd        := Cap.Efd;
      Session.Index      := Session_Index_Option'(Valid => True, Value => Idx);
      Session.Label.Last := Session.Label.Value'First + Label'Length - 1;
      Session.Label.Value (Session.Label.Value'First .. Session.Label.Last) := Label;
   end Initialize;

   procedure Finalize (Session : in out Client_Session)
   is
      Ignore_Success : Boolean;
   begin
      if not Initialized (Session) then
         return;
      end if;
      Gneiss_Internal.Epoll.Remove (Session.Efd, Session.Fd, Ignore_Success);
      Gneiss_Internal.Syscall.Close (Session.Fd);
      Gneiss_Internal.Invalidate (Session.E_Cap);
      Session.Label.Last := 0;
      Session.Index      := Gneiss.Session_Index_Option'(Valid => False);
   end Finalize;

   function Available (Session : Client_Session) return Boolean is
      (Gneiss_Internal.Message_Syscall.Peek (Session.Fd) >= Message_Buffer'Size * 8);

   procedure Write (Session : in out Client_Session;
                    Content :        Message_Buffer) with
      SPARK_Mode => Off
   is
   begin
      Gneiss_Internal.Message_Syscall.Write (Session.Fd, Content'Address, Content'Size * 8);
   end Write;

   procedure Read (Session : in out Client_Session;
                   Content :    out Message_Buffer) with
      SPARK_Mode => Off
   is
   begin
      Gneiss_Internal.Message_Syscall.Read (Session.Fd, Content'Address, Content'Size * 8);
   end Read;

end Gneiss.Message.Client;
