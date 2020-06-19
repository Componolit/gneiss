with Gneiss.Stream;
with Gneiss.Stream.Dispatcher;
with Gneiss.Stream.Server;

package body Stream_Server.Component with
   SPARK_Mode
is

   package Stream is new Gneiss.Stream (Positive, Character, String);

   type Server_Slot is record
      Ready : Boolean := False;
   end record;

   subtype Server_Index is Gneiss.Session_Index range 1 .. 2;
   type Server_Reg is array (Server_Index'Range) of Stream.Server_Session;
   type Server_Slots is array (Server_Index'Range) of Server_Slot;

   type Server_Meta is record
      Slots  : Server_Slots;
   end record;

   procedure Initialize (Session : in out Stream.Server_Session;
                         Context : in out Server_Meta) with
      Pre    => Stream.Initialized (Session),
      Post   => Stream.Initialized (Session),
      Global => null;

   procedure Finalize (Session : in out Stream.Server_Session;
                       Context : in out Server_Meta) with
      Pre    => Stream.Initialized (Session),
      Post   => Stream.Initialized (Session),
      Global => null;

   procedure Receive (Session : in out Stream.Server_Session;
                      Data    :        String;
                      Read    :    out Natural);

   function Ready (Session : Stream.Server_Session;
                   Context : Server_Meta) return Boolean with
      Global => null;

   procedure Dispatch (Session  : in out Stream.Dispatcher_Session;
                       Disp_Cap :        Stream.Dispatcher_Capability;
                       Name     :        String;
                       Label    :        String) with
      Pre    => Stream.Initialized (Session)
                and then Stream.Registered (Session),
      Post   => Stream.Initialized (Session)
                and then Stream.Registered (Session);

   package Stream_Server is new Stream.Server (Server_Meta, Initialize, Finalize, Ready, Receive);
   package Stream_Dispatcher is new Stream.Dispatcher (Stream_Server, Dispatch);

   Dispatcher  : Stream.Dispatcher_Session;
   Capability  : Gneiss.Capability;
   Servers     : Server_Reg;
   Server_Data : Server_Meta;
   Buf         : String (1 .. 512);
   Length      : Natural;

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Stream_Dispatcher.Initialize (Dispatcher, Cap);
      if Stream.Initialized (Dispatcher) then
         Stream_Dispatcher.Register (Dispatcher);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Receive (Session : in out Stream.Server_Session;
                      Data    :        String;
                      Read    :    out Natural)
   is
   begin
      Stream_Server.Send (Session, Data, Read, Server_Data);
   end Receive;

   procedure Destruct
   is
   begin
      null;
   end Destruct;

   procedure Initialize (Session : in out Stream.Server_Session;
                         Context : in out Server_Meta)
   is
   begin
      if Stream.Index (Session).Value in Context.Slots'Range then
         Context.Slots (Stream.Index (Session).Value).Ready := True;
      end if;
   end Initialize;

   procedure Finalize (Session : in out Stream.Server_Session;
                       Context : in out Server_Meta)
   is
   begin
      if Stream.Index (Session).Value in Context.Slots'Range then
         Context.Slots (Stream.Index (Session).Value).Ready := False;
      end if;
   end Finalize;

   procedure Dispatch (Session  : in out Stream.Dispatcher_Session;
                       Disp_Cap :        Stream.Dispatcher_Capability;
                       Name     :        String;
                       Label    :        String)
   is
      pragma Unreferenced (Name);
      pragma Unreferenced (Label);
   begin
      if Stream_Dispatcher.Valid_Session_Request (Session, Disp_Cap) then
         for I in Servers'Range loop
            if not Ready (Servers (I), Server_Data) and then not Stream.Initialized (Servers (I)) then
               Stream_Dispatcher.Session_Initialize (Session, Disp_Cap, Servers (I), Server_Data, I);
               if Ready (Servers (I), Server_Data) and then Stream.Initialized (Servers (I)) then
                  Stream_Dispatcher.Session_Accept (Session, Disp_Cap, Servers (I), Server_Data);
                  exit;
               end if;
            end if;
         end loop;
      end if;
      for S of Servers loop
         Stream_Dispatcher.Session_Cleanup (Session, Disp_Cap, S, Server_Data);
      end loop;
   end Dispatch;

   function Ready (Session : Stream.Server_Session;
                   Context : Server_Meta) return Boolean is
      (if
          Stream.Index (Session).Valid
          and then Stream.Index (Session).Value in Context.Slots'Range
       then Context.Slots (Stream.Index (Session).Value).Ready
       else False);

end Stream_Server.Component;
