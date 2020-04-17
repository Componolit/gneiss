
with Gneiss.Log;
with Gneiss.Log.Client;
with Gneiss.Message;
with Gneiss.Message.Client;

package body Component with
   SPARK_Mode
is

   package Gneiss_Log is new Gneiss.Log;
   package Log_Client is new Gneiss_Log.Client;

   subtype Message_Buffer is String (1 .. 128);
   Null_Buffer : constant Message_Buffer := (others => ASCII.NUL);

   procedure Event;
   function Null_Terminate (S : String) return String with
      Post => Null_Terminate'Result'First = S'First
              and then Null_Terminate'Result'Length <= S'Length;

   package Message is new Gneiss.Message (Message_Buffer, Null_Buffer);

   package Message_Client is new Message.Client (Event);

   Client     : Message.Client_Session;
   Log        : Gneiss_Log.Client_Session;
   Capability : Gneiss.Capability;

   function Null_Terminate (S : String) return String
   is
   begin
      for I in S'Range loop
         if S (I) = ASCII.NUL then
            return S (S'First .. I - 1);
         end if;
      end loop;
      return S;
   end Null_Terminate;

   procedure Construct (Cap : Gneiss.Capability)
   is
      Msg : Message_Buffer := (others => ASCII.NUL);
   begin
      Capability := Cap;
      Log_Client.Initialize (Log, Capability, "log_message");
      Message_Client.Initialize (Client, Capability, "log");
      if Gneiss_Log.Initialized (Log) and Message.Initialized (Client) then
         Msg (Msg'First .. Msg'First + 11) := "Hello World!";
         Log_Client.Info (Log, "Sending: " & Null_Terminate (Msg));
         Message_Client.Write (Client, Msg);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Event
   is
      Msg : Message_Buffer;
   begin
      if Gneiss_Log.Initialized (Log) and then Message.Initialized (Client) then
         while Message_Client.Available (Client) loop
            pragma Loop_Invariant (Gneiss_Log.Initialized (Log));
            pragma Loop_Invariant (Message.Initialized (Client));
            Message_Client.Read (Client, Msg);
            Log_Client.Info (Log, "Received: " & Null_Terminate (Msg));
            Main.Vacate (Capability, Main.Success);
         end loop;
      end if;
   end Event;

   procedure Destruct
   is
   begin
      Log_Client.Finalize (Log);
      Message_Client.Finalize (Client);
   end Destruct;

end Component;
