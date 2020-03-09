
with Gneiss.Log;
with Gneiss.Log.Client;
with Gneiss.Message;
with Gneiss.Message.Client;

package body Component with
   SPARK_Mode
is

   subtype Message_Buffer is String (1 .. 128);
   Null_Buffer : constant Message_Buffer := (others => ASCII.NUL);

   procedure Event;
   function Null_Terminate (S : String) return String;

   package Message is new Gneiss.Message (Message_Buffer, Null_Buffer);

   package Message_Client is new Message.Client (Event);

   Client     : Message.Client_Session;
   Log        : Gneiss.Log.Client_Session;
   Capability : Gneiss.Capability;

   function Null_Terminate (S : String) return String
   is
      Last : Natural := S'First - 1;
   begin
      for I in S'Range loop
         exit when S (I) = ASCII.NUL;
         Last := I;
      end loop;
      return S (S'First .. Last);
   end Null_Terminate;

   procedure Construct (Cap : Gneiss.Capability)
   is
      Msg : Message_Buffer := (others => ASCII.NUL);
   begin
      Capability := Cap;
      Gneiss.Log.Client.Initialize (Log, Capability, "log_message");
      Message_Client.Initialize (Client, Capability, "log");
      if Gneiss.Log.Initialized (Log) and Message.Initialized (Client) then
         Msg (Msg'First .. Msg'First + 11) := "Hello World!";
         Gneiss.Log.Client.Info (Log, "Sending: " & Null_Terminate (Msg));
         Message_Client.Write (Client, Msg);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Event
   is
      Msg : Message_Buffer;
   begin
      if Gneiss.Log.Initialized (Log) and then Message.Initialized (Client) then
         while Message_Client.Available (Client) loop
            Message_Client.Read (Client, Msg);
            Gneiss.Log.Client.Info (Log, "Received: " & Null_Terminate (Msg));
            Main.Vacate (Capability, Main.Success);
         end loop;
      end if;
   end Event;

   procedure Destruct
   is
   begin
      Gneiss.Log.Client.Finalize (Log);
      Message_Client.Finalize (Client);
   end Destruct;

end Component;
