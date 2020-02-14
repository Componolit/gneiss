
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

   procedure Initialize (Session : in out Message.Client_Session);
   procedure Initialize (Session : in out Gneiss.Log.Client_Session);

   package Message_Client is new Message.Client (Initialize, Event);
   package Log_Client is new Gneiss.Log.Client (Initialize);

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
   begin
      Capability := Cap;
      Log_Client.Initialize (Log, Capability, "log_message");
   end Construct;

   procedure Initialize (Session : in out Gneiss.Log.Client_Session)
   is
      use type Gneiss.Session_Status;
   begin
      if Gneiss.Log.Status (Session) = Gneiss.Initialized then
         Message_Client.Initialize (Client, Capability, "log");
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Initialize;

   procedure Initialize (Session : in out Message.Client_Session)
   is
      use type Gneiss.Session_Status;
      Msg : Message_Buffer := (others => ASCII.NUL);
   begin
      if Message.Status (Session) = Gneiss.Initialized then
         Msg (Msg'First .. Msg'First + 11) := "Hello World!";
         Log_Client.Info (Log, "Sending: " & Null_Terminate (Msg));
         Message_Client.Write (Session, Msg);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Initialize;

   procedure Event
   is
      use type Gneiss.Session_Status;
      Msg : Message_Buffer;
   begin
      if
         Gneiss.Log.Status (Log) = Gneiss.Initialized
         and then Message.Status (Client) = Gneiss.Initialized
      then
         while Message_Client.Available (Client) loop
            Message_Client.Read (Client, Msg);
            Log_Client.Info (Log, "Received: " & Null_Terminate (Msg));
            Main.Vacate (Capability, Main.Success);
         end loop;
      end if;
   end Event;

   procedure Destruct
   is
   begin
      Message_Client.Finalize (Client);
   end Destruct;

end Component;
