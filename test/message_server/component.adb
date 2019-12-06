
with Gneiss.Message;
with Gneiss.Message.Dispatcher;
with Gneiss.Message.Server;

package body Component with
   SPARK_Mode
is

   type Unsigned_Char is mod 2 ** 8;
   type C_String is array (Positive range <>) of Unsigned_Char;

   package Message is new Gneiss.Message (Positive, Unsigned_Char, C_String, 1, 128);

   procedure Event;

   procedure Initialize (Session : in out Message.Server_Session;
                         Label   :        String);

   procedure Finalize (Session : in out Message.Server_Session);

   function Ready (Session : Message.Server_Session) return Boolean;

   procedure Dispatch (Session  : in out Message.Dispatcher_Session;
                       Disp_Cap :        Message.Dispatcher_Capability);

   package Message_Server is new Message.Server (Event, Initialize, Finalize, Ready);
   package Message_Dispatcher is new Message.Dispatcher (Message_Server, Dispatch);

   Dispatcher : Message.Dispatcher_Session;
   Server     : Message.Server_Session;
   Capability : Gneiss.Capability;

   procedure Construct (Cap : Gns.Capability)
   is
   begin
      Capability := Cap;
      Message_Dispatcher.Initialize (Dispatcher, Cap);
      if Message.Initialized (Dispatcher) then
         --  Message_Dispatcher.Register (Dispatcher);
         null;
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      Message_Dispatcher.Finalize (Dispatcher);
   end Destruct;

   procedure Event
   is
   begin
      null;
   end Event;

   procedure Initialize (Session : in out Message.Server_Session;
                         Label   :        String)
   is
   begin
      null;
   end Initialize;

   procedure Finalize (Session : in out Message.Server_Session)
   is
   begin
      null;
   end Finalize;

   procedure Dispatch (Session  : in out Message.Dispatcher_Session;
                       Disp_Cap :        Message.Dispatcher_Capability)
   is
   begin
      if Message_Dispatcher.Valid_Session_Request (Session, Disp_Cap) then
         Message_Dispatcher.Session_Initialize (Session, Disp_Cap, Server);
         if Ready (Server) and then Message.Initialized (Server) then
            Message_Dispatcher.Session_Accept (Session, Disp_Cap, Server);
         end if;
      end if;
      Message_Dispatcher.Session_Cleanup (Session, Disp_Cap, Server);
   end Dispatch;

   function Ready (Session : Message.Server_Session) return Boolean is
      (False);

end Component;
