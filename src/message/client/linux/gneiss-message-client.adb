
with System;
with RFLX.Session;
with Gneiss.Epoll;
with Gneiss.Platform;
with Gneiss.Syscall;
with Gneiss.Protocoll;
with Basalt.Strings;
with Componolit.Runtime.Debug;

package body Gneiss.Message.Client with
   SPARK_Mode
is

   function Get_Event_Address return System.Address;
   type RFLX_String is array (RFLX.Session.Length_Type range <>) of Character;
   package Proto is new Gneiss.Protocoll (Character, RFLX_String);

   procedure Peek_Message (Fd : Integer);

   function Get_Event_Address return System.Address with
      SPARK_Mode => Off
   is
   begin
      return Event'Address;
   end Get_Event_Address;

   Read_Buffer : Proto.Message := (Length      => 255,
                                   Action      => RFLX.Session.Request,
                                   Kind        => RFLX.Session.Message,
                                   Name_Length => 0,
                                   Payload     => (others => Character'First));
   Read_String : String (1 .. 255) with
      Address => Read_Buffer.Payload'Address;

   procedure Peek_Message (Fd : Integer) with
      SPARK_Mode => Off
   is
      Len    : Integer;
      Trunc  : Integer;
      New_Fd : Integer;
   begin
      Gneiss.Syscall.Peek_Message (Fd, Read_Buffer'Address, Read_Buffer'Size / 8, New_Fd, Len, Trunc);
      Componolit.Runtime.Debug.Log_Debug ("Peek New_Fd="
                                          & Basalt.Strings.Image (New_Fd)
                                          & " Len="
                                          & Basalt.Strings.Image (Len)
                                          & " Trunc="
                                          & Basalt.Strings.Image (Trunc));
   end Peek_Message;

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
      Componolit.Runtime.Debug.Log_Debug ("Initialize " & Label);
      for I in C_Label'Range loop
         C_Label (I) := Label (Positive (I));
      end loop;
      case Status (Session) is
         when Initialized =>
            return;
         when Pending =>
            Peek_Message (Gneiss.Platform.Get_Broker (Capability));
            Componolit.Runtime.Debug.Log_Debug ("Pending label: " & Read_String);
            Gneiss.Syscall.Drop_Message (Gneiss.Platform.Get_Broker (Capability));
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
