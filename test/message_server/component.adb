
with Gneiss.Message;
with Gneiss.Message.Dispatcher;
with Gneiss.Message.Server;

package body Component with
   SPARK_Mode
is

   subtype Message_Buffer is String (1 .. 128);
   Null_Buffer : constant Message_Buffer := (others => ASCII.NUL);

   package Message is new Gneiss.Message (Message_Buffer, Null_Buffer);

   type Server_Slot is record
      Ident : String (1 .. 513) := (others => ASCII.NUL);
      Ready : Boolean := False;
   end record;

   type Server_Reg is array (Gneiss.Session_Index range <>) of Message.Server_Session;
   type Server_Meta is array (Gneiss.Session_Index range <>) of Server_Slot;

   procedure Initialize (Session : in out Message.Server_Session) with
      Pre  => Message.Initialized (Session),
      Post => Message.Initialized (Session);

   procedure Finalize (Session : in out Message.Server_Session) with
      Pre  => Message.Initialized (Session),
      Post => Message.Initialized (Session);

   procedure Recv (Session : in out Message.Server_Session;
                   Data    :        Message_Buffer) with
      Pre  => Message.Initialized (Session)
              and then Ready (Session),
      Post => Message.Initialized (Session)
              and then Ready (Session);

   function Ready (Session : Message.Server_Session) return Boolean;

   procedure Dispatch (Session  : in out Message.Dispatcher_Session;
                       Disp_Cap :        Message.Dispatcher_Capability;
                       Name     :        String;
                       Label    :        String) with
      Pre  => Message.Initialized (Session),
      Post => Message.Initialized (Session);

   package Message_Server is new Message.Server (Initialize, Finalize, Recv, Ready);
   package Message_Dispatcher is new Message.Dispatcher (Message_Server, Dispatch);

   Dispatcher  : Message.Dispatcher_Session;
   Capability  : Gneiss.Capability;
   Servers     : Server_Reg (1 .. 2);
   Server_Data : Server_Meta (Servers'Range);

   procedure Construct (Cap : Gneiss.Capability)
   is
   begin
      Capability := Cap;
      Message_Dispatcher.Initialize (Dispatcher, Cap);
      if Message.Initialized (Dispatcher) then
         Message_Dispatcher.Register (Dispatcher);
      else
         Main.Vacate (Capability, Main.Failure);
      end if;
   end Construct;

   procedure Destruct
   is
   begin
      null;
   end Destruct;

   procedure Recv (Session : in out Message.Server_Session;
                   Data    :        Message_Buffer)
   is
   begin
      Message_Server.Send (Session, Data);
   end Recv;

   procedure Initialize (Session : in out Message.Server_Session)
   is
   begin
      if Message.Index (Session).Value in Server_Data'Range then
         Server_Data (Message.Index (Session).Value).Ready := True;
      end if;
   end Initialize;

   procedure Finalize (Session : in out Message.Server_Session)
   is
   begin
      if Message.Index (Session).Value in Server_Data'Range then
         Server_Data (Message.Index (Session).Value).Ready := False;
      end if;
   end Finalize;

   procedure Dispatch (Session  : in out Message.Dispatcher_Session;
                       Disp_Cap :        Message.Dispatcher_Capability;
                       Name     :        String;
                       Label    :        String)
   is
   begin
      if Message_Dispatcher.Valid_Session_Request (Session, Disp_Cap) then
         for I in Servers'Range loop
            if
               not Ready (Servers (I))
               and then not Message.Initialized (Servers (I))
               and then Name'Length < Server_Data (I).Ident'Last
               and then Label'Length < Server_Data (I).Ident'Last
               and then Name'Length + Label'Length + 1 <= Server_Data (I).Ident'Last
               and then Name'First < Positive'Last - Server_Data (I).Ident'Length
            then
               Message_Dispatcher.Session_Initialize (Session, Disp_Cap, Servers (I), I);
               if Ready (Servers (I)) and then Message.Initialized (Servers (I)) then
                  Server_Data (I).Ident (1 .. Name'Length + Label'Length + 1) := Name & ":" & Label;
                  Message_Dispatcher.Session_Accept (Session, Disp_Cap, Servers (I));
                  exit;
               end if;
            end if;
         end loop;
      end if;
      for S of Servers loop
         Message_Dispatcher.Session_Cleanup (Session, Disp_Cap, S);
      end loop;
   end Dispatch;

   function Ready (Session : Message.Server_Session) return Boolean is
      (if
          Message.Index (Session).Valid
          and then Message.Index (Session).Value in Server_Data'Range
       then Server_Data (Message.Index (Session).Value).Ready
       else False);

end Component;
