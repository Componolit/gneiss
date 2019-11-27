
with System;
with RFLX.Session;
with Gneiss.Epoll;
with Gneiss.Platform;
with Gneiss.Syscall;
--  with Componolit.Runtime.Debug;

package body Gneiss.Message.Client with
   SPARK_Mode
is

   function Get_Event_Address return System.Address;
   function Create_Request (Label : String) return Buffer;
   procedure Send_Request (Session : in out Client_Session;
                           Request :        Buffer);

   function Get_Event_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Event'Address;
   end Get_Event_Address;

   function Create_Request (Label : String) return Buffer
   is
      Request : Buffer (1 .. Label'Length + 4) := (others => 0);
   begin
      Request (1) := RFLX.Session.Action_Type'Pos (RFLX.Session.Request);
      Request (2) := RFLX.Session.Kind_Type'Pos (RFLX.Session.Message);
      Request (3) := 0;
      Request (4) := Label'Length;
      for I in 5 .. Request'Last loop
         Request (I) := Character'Pos (Label (Label'First + Integer (I - 5)));
      end loop;
      return Request;
   end Create_Request;

   procedure Send_Request (Session : in out Client_Session;
                           Request :        Buffer) with
      SPARK_Mode => Off
   is
   begin
      Gneiss.Syscall.Write_Message (Session.Broker, Request'Address, Request'Length);
   end Send_Request;

   procedure Initialize (Session    : in out Client_Session;
                         Capability :        Gneiss.Types.Capability;
                         Label      :        String)
   is
      Success : Integer;
   begin
      --  Componolit.Runtime.Debug.Log_Debug ("Initialize " & Label);
      case Status (Session) is
         when Initialized =>
            return;
         when Pending =>
            return;
         when Uninitialized =>
            Gneiss.Syscall.Dup (Gneiss.Platform.Get_Broker (Capability), Session.Broker);
            if Session.Broker < 0 then
               return;
            end if;
            Gneiss.Epoll.Add (Gneiss.Platform.Get_Epoll (Capability),
                              Session.Broker,
                              Get_Event_Address,
                              Success);
            if Success /= 0 then
               Session.Broker := -1;
               return;
            end if;
            Send_Request (Session, Create_Request (Label));
      end case;
   end Initialize;

   function Available (Session : Client_Session) return Boolean is (False);

   procedure Write (Session : in out Client_Session;
                    Content :        Message_Buffer)
   is
   begin
      null;
   end Write;

   procedure Read (Session : in out Client_Session;
                   Content :    out Message_Buffer)
   is
   begin
      null;
   end Read;

   procedure Finalize (Session : in out Client_Session)
   is
   begin
      null;
   end Finalize;

end Gneiss.Message.Client;
