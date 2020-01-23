
with Gneiss.Message;
with Gneiss.Message.Client;
with Gneiss.Memory;
with Gneiss.Memory.Client;

package body Component with
   SPARK_Mode
is

   procedure Event;

   procedure Initialize_Memory;

   package Memory is new Gneiss.Memory (Character, Positive, String);

   procedure Read (Session : in out Memory.Client_Session;
                   Data    :        String) is null;

   procedure Modify (Session : in out Memory.Client_Session;
                     Data    : in out String);

   package Memory_Client is new Memory.Client (Initialize_Memory, Read, Modify);

   package Message is new Gneiss.Message (Positive, Character, String, 1, 1);
   package Message_Client is new Message.Client (Event);

   Client     : Message.Client_Session;
   Mem        : Memory.Client_Session;
   Capability : Gneiss.Capability;

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Message_Client.Initialize (Client, Cap, "log");
      Memory_Client.Initialize (Mem, Cap, "shared", Memory.Read_Write);
   end Construct;

   procedure Initialize_Memory
   is
   begin
      case Memory.Status (Mem) is
         when Gneiss.Initialized =>
            Event;
         when Gneiss.Pending =>
            Memory_Client.Initialize (Mem, Capability, "");
         when Gneiss.Uninitialized =>
            Main.Vacate (Capability, Main.Failure);
      end case;
   end Initialize_Memory;

   procedure Event
   is
      use type Gneiss.Session_Status;
      Msg : constant String (1 .. 1) := (1 => ASCII.NUL);
   begin
      case Message.Status (Client) is
         when Gneiss.Initialized =>
            if Memory.Status (Mem) = Gneiss.Initialized then
               Memory_Client.Update (Mem);
               Message_Client.Write (Client, Msg);
               Main.Vacate (Capability, Main.Success);
            end if;
         when Gneiss.Pending =>
            Message_Client.Initialize (Client, Capability, "log");
         when Gneiss.Uninitialized =>
            Main.Vacate (Capability, Main.Failure);
      end case;
   end Event;

   procedure Modify (Session : in out Memory.Client_Session;
                     Data    : in out String)
   is
   begin
      Data := (others => ASCII.NUL);
      Data (Data'First .. Data'First + 11) := "Hello World!";
   end Modify;

   procedure Destruct
   is
   begin
      Message_Client.Finalize (Client);
   end Destruct;

end Component;
