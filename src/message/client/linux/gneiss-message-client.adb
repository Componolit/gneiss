
with System;
with RFLX.Session;
with Gneiss.Epoll;
with Gneiss.Platform;
with Gneiss.Syscall;
with Gneiss.Protocoll;
with Componolit.Runtime.Debug;

package body Gneiss.Message.Client with
   SPARK_Mode
is

   function Get_Event_Address return System.Address;
   type RFLX_String is array (RFLX.Session.Length_Type range <>) of Character;
   package Proto is new Gneiss.Protocoll (Character, RFLX_String);

   function Get_Event_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Event'Address;
   end Get_Event_Address;

   function Create_Request (Label : RFLX_String) return Proto.Message is
      (Proto.Message'(Length      => Label'Length,
                      Action      => RFLX.Session.Request,
                      Kind        => RFLX.Session.Message,
                      Name_Length => 0,
                      Payload     => Label));

   procedure Initialize (Session    : in out Client_Session;
                         Capability :        Gneiss.Types.Capability;
                         Label      :        String)
   is
      Success : Integer;
      C_Label : RFLX_String (RFLX.Session.Length_Type (Label'First) .. RFLX.Session.Length_Type (Label'Last));
   begin
      --  Componolit.Runtime.Debug.Log_Debug ("Initialize " & Label);
      for I in C_Label'Range loop
         C_Label (I) := Label (Positive (I));
      end loop;
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
            Componolit.Runtime.Debug.Log_Debug ("Initialize label: " & Label);
            Proto.Send_Message (Session.Broker, Create_Request (C_Label));
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
