
with Gneiss.Message;
with Gneiss.Message.Client;
with Componolit.Runtime.Debug;

package body Component with
   SPARK_Mode
is

   type Unsigned_Char is mod 2 ** 8;
   type C_String is array (Positive range <>) of Unsigned_Char;
   procedure Event;

   package Message is new Gneiss.Message (Positive, Unsigned_Char, C_String, 1, 128);
   package Message_Client is new Message.Client (Event);

   Client     : Message.Client_Session;
   Msg        : Message.Message_Buffer;
   Capability : Gneiss.Capability;

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Componolit.Runtime.Debug.Log_Debug ("Message client");
      Capability := Cap;
      Message_Client.Initialize (Client, Cap, "log");
   end Construct;

   procedure Event
   is
   begin
      case Message.Status (Client) is
         when Gneiss.Initialized =>
            Msg := (72, 101, 108, 108, 111, others => 0);
            Message_Client.Write (Client, Msg);
            Main.Vacate (Capability, Main.Success);
         when Gneiss.Pending =>
            Message_Client.Initialize (Client, Capability, "log");
         when Gneiss.Uninitialized =>
            Main.Vacate (Capability, Main.Failure);
      end case;
   end Event;

   procedure Destruct
   is
   begin
      Message_Client.Finalize (Client);
   end Destruct;

end Component;
