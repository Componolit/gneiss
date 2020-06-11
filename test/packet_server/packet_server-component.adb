
with Gneiss.Packet;
with Gneiss.Packet.Dispatcher;
with Gneiss.Packet.Server;

package body Packet_Server.Component with
   SPARK_Mode,
   Refined_State => (Component_State => Capability,
                     Platform_State  => (Dispatcher,
                                         Servers,
                                         Server_Data,
                                         Buf,
                                         Length))
is

   package Packet is new Gneiss.Packet (Positive, Character, String);

   type Server_Slot is record
      Ready : Boolean := False;
   end record;

   subtype Server_Index is Gneiss.Session_Index range 1 .. 2;
   type Server_Reg is array (Server_Index'Range) of Packet.Server_Session;
   type Server_Slots is array (Server_Index'Range) of Server_Slot;

   type Server_Meta is record
      Slots  : Server_Slots;
   end record;

   procedure Initialize (Session : in out Packet.Server_Session;
                         Context : in out Server_Meta) with
      Pre    => Packet.Initialized (Session),
      Post   => Packet.Initialized (Session),
      Global => null;

   procedure Finalize (Session : in out Packet.Server_Session;
                       Context : in out Server_Meta) with
      Pre    => Packet.Initialized (Session),
      Post   => Packet.Initialized (Session),
      Global => null;

   procedure Event with
      Global => (In_Out => (Servers,
                            Buf,
                            Length,
                            Gneiss_Internal.Platform_State),
                 Input  => Server_Data);

   function Ready (Session : Packet.Server_Session;
                   Context : Server_Meta) return Boolean with
      Global => null;

   procedure Dispatch (Session  : in out Packet.Dispatcher_Session;
                       Disp_Cap :        Packet.Dispatcher_Capability;
                       Name     :        String;
                       Label    :        String) with
      Pre    => Packet.Initialized (Session)
                and then Packet.Registered (Session),
      Post   => Packet.Initialized (Session)
                and then Packet.Registered (Session),
      Global => (In_Out => (Servers, Server_Data,
                            Gneiss_Internal.Platform_State));

   package Packet_Server is new Packet.Server (Server_Meta, Initialize, Finalize, Event, Ready);
   package Packet_Dispatcher is new Packet.Dispatcher (Packet_Server, Dispatch);

   Dispatcher  : Packet.Dispatcher_Session;
   Capability  : Gneiss.Capability;
   Servers     : Server_Reg;
   Server_Data : Server_Meta;
   Buf         : String (1 .. 512) := (others => Character'First);
   Length      : Natural           := 0;

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Packet_Dispatcher.Initialize (Dispatcher, Cap);
      if Packet.Initialized (Dispatcher) then
         Packet_Dispatcher.Register (Dispatcher);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Event
   is
      Ignore_Success : Boolean;
   begin
      for S of Servers loop
         if Packet.Initialized (S) and then Ready (S, Server_Data) then
            Packet_Server.Receive (S, Buf, Length, Server_Data);
            if Length > Buf'Length then
               Length := Buf'Length;
            end if;
            Packet_Server.Send (S, Buf (Buf'First .. Buf'First + Length - 1), Ignore_Success, Server_Data);
         end if;
      end loop;
   end Event;

   procedure Destruct
   is
   begin
      null;
   end Destruct;

   procedure Initialize (Session : in out Packet.Server_Session;
                         Context : in out Server_Meta)
   is
   begin
      if Packet.Index (Session).Value in Context.Slots'Range then
         Context.Slots (Packet.Index (Session).Value).Ready := True;
      end if;
   end Initialize;

   procedure Finalize (Session : in out Packet.Server_Session;
                       Context : in out Server_Meta)
   is
   begin
      if Packet.Index (Session).Value in Context.Slots'Range then
         Context.Slots (Packet.Index (Session).Value).Ready := False;
      end if;
   end Finalize;

   procedure Dispatch (Session  : in out Packet.Dispatcher_Session;
                       Disp_Cap :        Packet.Dispatcher_Capability;
                       Name     :        String;
                       Label    :        String)
   is
      pragma Unreferenced (Name);
      pragma Unreferenced (Label);
   begin
      if Packet_Dispatcher.Valid_Session_Request (Session, Disp_Cap) then
         for I in Servers'Range loop
            if not Ready (Servers (I), Server_Data) and then not Packet.Initialized (Servers (I)) then
               Packet_Dispatcher.Session_Initialize (Session, Disp_Cap, Servers (I), Server_Data, I);
               if Ready (Servers (I), Server_Data) and then Packet.Initialized (Servers (I)) then
                  Packet_Dispatcher.Session_Accept (Session, Disp_Cap, Servers (I), Server_Data);
                  exit;
               end if;
            end if;
         end loop;
      end if;
      for S of Servers loop
         Packet_Dispatcher.Session_Cleanup (Session, Disp_Cap, S, Server_Data);
      end loop;
   end Dispatch;

   function Ready (Session : Packet.Server_Session;
                   Context : Server_Meta) return Boolean is
      (if
          Packet.Index (Session).Valid
          and then Packet.Index (Session).Value in Context.Slots'Range
       then Context.Slots (Packet.Index (Session).Value).Ready
       else False);

end Packet_Server.Component;
